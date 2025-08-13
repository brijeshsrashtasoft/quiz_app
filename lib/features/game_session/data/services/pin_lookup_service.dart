import 'dart:async';
import '../../../../core/utils/logger.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

/// Optimized PIN lookup service with caching and rate limiting
/// Follows CLAUDE.md FREE tier optimization guidelines
class PinLookupService {
  static const int _cacheExpirationMinutes = 5;
  static const int _rateLimitPerMinute = 10;

  // In-memory cache for PIN lookups to minimize Firestore reads
  final _pinCache = <String, _PinCacheEntry>{};
  final _lookupHistory = <DateTime>[];

  /// Look up game session by PIN with caching
  Future<Result<String?>> lookupSessionByPin(String pin) async {
    // Validate PIN format
    if (!_isValidPin(pin)) {
      return Result.failure(
        const ValidationFailure(
          message: 'Invalid PIN format. Must be 6 digits.',
        ),
      );
    }

    // Check rate limit
    if (!_checkRateLimit()) {
      return Result.failure(
        const ServerFailure(
          message: 'Too many PIN lookups. Please try again later.',
        ),
      );
    }

    // Check cache first
    final cachedEntry = _pinCache[pin];
    if (cachedEntry != null && !cachedEntry.isExpired) {
      AppLogger.firebase('PinLookupService', 'PIN $pin found in cache');
      return Result.success(cachedEntry.sessionId);
    }

    // Record lookup for rate limiting
    _lookupHistory.add(DateTime.now());

    try {
      final startTime = DateTime.now();

      // Query Firestore with optimized index
      final query = await FirestoreConfig.gameSessionsCollection
          .where('pin', isEqualTo: pin)
          .where('status', whereIn: ['waiting', 'active'])
          .limit(1)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('PIN lookup', duration);

      if (query.docs.isEmpty) {
        // Cache negative result to prevent repeated lookups
        _pinCache[pin] = _PinCacheEntry(
          sessionId: null,
          timestamp: DateTime.now(),
        );
        return const Result.success(null);
      }

      final sessionId = query.docs.first.id;

      // Cache positive result
      _pinCache[pin] = _PinCacheEntry(
        sessionId: sessionId,
        timestamp: DateTime.now(),
      );

      AppLogger.firebase(
        'PinLookupService',
        'Found session $sessionId for PIN $pin',
      );

      return Result.success(sessionId);
    } catch (e) {
      AppLogger.error('PIN lookup failed', e);
      return Result.failure(
        ServerFailure(message: 'Failed to look up PIN: ${e.toString()}'),
      );
    }
  }

  /// Batch PIN validation for multiple PINs
  Future<Result<Map<String, bool>>> validatePins(List<String> pins) async {
    if (pins.isEmpty) {
      return const Result.success({});
    }

    // Remove duplicates and invalid PINs
    final validPins = pins.where(_isValidPin).toSet().toList();

    if (validPins.isEmpty) {
      return const Result.success({});
    }

    try {
      final results = <String, bool>{};
      final pinsToQuery = <String>[];

      // Check cache first
      for (final pin in validPins) {
        final cachedEntry = _pinCache[pin];
        if (cachedEntry != null && !cachedEntry.isExpired) {
          results[pin] = cachedEntry.sessionId != null;
        } else {
          pinsToQuery.add(pin);
        }
      }

      // Query remaining PINs in batch (max 10 per query due to 'in' limitation)
      if (pinsToQuery.isNotEmpty) {
        final chunks = _chunkList(pinsToQuery, 10);

        for (final chunk in chunks) {
          final query = await FirestoreConfig.gameSessionsCollection
              .where('pin', whereIn: chunk)
              .where('status', whereIn: ['waiting', 'active'])
              .get();

          // Mark found PINs as valid
          final foundPins = query.docs
              .map((doc) => doc.data()['pin'] as String)
              .toSet();

          for (final pin in chunk) {
            final isValid = foundPins.contains(pin);
            results[pin] = isValid;

            // Update cache
            _pinCache[pin] = _PinCacheEntry(
              sessionId: isValid ? 'exists' : null,
              timestamp: DateTime.now(),
            );
          }
        }
      }

      return Result.success(results);
    } catch (e) {
      AppLogger.error('Batch PIN validation failed', e);
      return Result.failure(
        ServerFailure(message: 'Failed to validate PINs: ${e.toString()}'),
      );
    }
  }

  /// Generate suggestions for similar PINs (for typo correction)
  List<String> generatePinSuggestions(String pin) {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return [];
    }

    final suggestions = <String>[];
    final digits = pin.split('');

    // Generate single-digit variations
    for (int i = 0; i < digits.length; i++) {
      final currentDigit = int.parse(digits[i]);

      // Try adjacent digits
      for (final offset in [-1, 1]) {
        final newDigit = (currentDigit + offset) % 10;
        final suggestion = List<String>.from(digits);
        suggestion[i] = newDigit.toString();
        suggestions.add(suggestion.join());
      }
    }

    // Try transpositions (swapped adjacent digits)
    for (int i = 0; i < digits.length - 1; i++) {
      final suggestion = List<String>.from(digits);
      final temp = suggestion[i];
      suggestion[i] = suggestion[i + 1];
      suggestion[i + 1] = temp;
      suggestions.add(suggestion.join());
    }

    return suggestions.toSet().toList()..remove(pin);
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now();
    _pinCache.removeWhere((_, entry) => entry.isExpired);

    // Clean up old rate limit entries
    _lookupHistory.removeWhere((time) => now.difference(time).inMinutes > 1);

    AppLogger.firebase('PinLookupService', 'Cleared expired cache entries');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final validEntries = _pinCache.values.where((e) => !e.isExpired).length;
    final totalEntries = _pinCache.length;

    return {
      'totalEntries': totalEntries,
      'validEntries': validEntries,
      'expiredEntries': totalEntries - validEntries,
      'hitRate': totalEntries > 0 ? validEntries / totalEntries : 0,
      'recentLookups': _lookupHistory.length,
    };
  }

  /// Validate PIN format
  bool _isValidPin(String pin) {
    return RegExp(r'^[0-9]{6}$').hasMatch(pin);
  }

  /// Check rate limit
  bool _checkRateLimit() {
    final now = DateTime.now();
    final recentLookups = _lookupHistory
        .where((time) => now.difference(time).inMinutes < 1)
        .length;

    return recentLookups < _rateLimitPerMinute;
  }

  /// Split list into chunks
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  /// Clear all cache
  void clearCache() {
    _pinCache.clear();
    _lookupHistory.clear();
    AppLogger.firebase('PinLookupService', 'Cache cleared');
  }
}

/// Cache entry for PIN lookups
class _PinCacheEntry {
  final String? sessionId;
  final DateTime timestamp;

  _PinCacheEntry({required this.sessionId, required this.timestamp});

  bool get isExpired {
    final age = DateTime.now().difference(timestamp);
    return age.inMinutes >= PinLookupService._cacheExpirationMinutes;
  }
}
