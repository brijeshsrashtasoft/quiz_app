import 'dart:async';
import '../../../../core/utils/logger.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../models/game_session_model.dart';
import '../../domain/entities/game_session_entity.dart';

/// Enhanced PIN lookup service with real-time validation and caching
/// Optimized for instant PIN validation with comprehensive error handling
class PinLookupService {
  static const int _cacheExpirationMinutes = 3;
  static const int _rateLimitPerMinute = 20;
  static const int _maxCacheSize = 500;

  // Enhanced cache for PIN lookups with session details
  final _pinCache = <String, _PinCacheEntry>{};
  final _lookupHistory = <DateTime>[];
  final Map<String, StreamSubscription> _activeWatchers = {};
  Timer? _cleanupTimer;

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

  /// Enhanced real-time PIN validation with comprehensive session info
  Future<Result<PinValidationResult>> validatePinRealtime(String pin) async {
    if (!_isValidPin(pin)) {
      return Result.success(
        PinValidationResult(
          pin: pin,
          isValid: false,
          errorMessage: 'PIN must be exactly 6 digits',
          sessionInfo: null,
        ),
      );
    }

    if (!_checkRateLimit()) {
      return Result.failure(
        const ServerFailure(
          message: 'Too many PIN lookups. Please try again later.',
        ),
      );
    }

    try {
      final startTime = DateTime.now();

      // Check enhanced cache first
      final cachedEntry = _pinCache[pin];
      if (cachedEntry != null &&
          !cachedEntry.isExpired &&
          cachedEntry.sessionData != null) {
        AppLogger.firebase(
          'PinLookupService',
          'PIN validation from cache: $pin',
        );
        return Result.success(_buildValidationFromCache(pin, cachedEntry));
      }

      _lookupHistory.add(DateTime.now());

      // Enhanced Firestore query with session details
      final query = await FirestoreConfig.gameSessionsCollection
          .where('pin', isEqualTo: pin)
          .where('status', whereIn: ['waiting', 'active'])
          .limit(1)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Real-time PIN validation', duration);

      if (query.docs.isEmpty) {
        _cachePinResult(pin, null);
        return Result.success(
          PinValidationResult(
            pin: pin,
            isValid: false,
            errorMessage: 'PIN not found or game session has ended',
            sessionInfo: null,
          ),
        );
      }

      final doc = query.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      final session = GameSessionModel.fromFirestore(data);

      _cachePinResult(pin, session);

      final validationResult = _buildValidationResult(pin, session);
      return Result.success(validationResult);
    } catch (e, stackTrace) {
      AppLogger.error('PIN validation failed: $pin', e, stackTrace);
      return Result.failure(
        ServerFailure(message: 'Failed to validate PIN: ${e.toString()}'),
      );
    }
  }

  /// Build validation result from session data
  PinValidationResult _buildValidationResult(
    String pin,
    GameSessionModel session,
  ) {
    final entity = session.toEntity();

    return PinValidationResult(
      pin: pin,
      isValid: true,
      errorMessage: null,
      sessionInfo: SessionInfo(
        sessionId: session.id,
        pin: pin,
        status: session.status,
        playerCount: session.players.length,
        maxPlayers: session.settings?.maxPlayers ?? 50,
        canJoin: session.status == GameSessionStatus.waiting && !entity.isFull,
        createdAt: session.createdAt,
      ),
    );
  }

  /// Build validation result from cache
  PinValidationResult _buildValidationFromCache(
    String pin,
    _PinCacheEntry cached,
  ) {
    if (cached.sessionData == null) {
      return PinValidationResult(
        pin: pin,
        isValid: false,
        errorMessage: 'PIN not found or session has ended',
        sessionInfo: null,
      );
    }

    return _buildValidationResult(pin, cached.sessionData!);
  }

  /// Cache PIN result with enhanced session data
  void _cachePinResult(String pin, GameSessionModel? session) {
    if (_pinCache.length >= _maxCacheSize) {
      clearExpiredCache();
    }

    _pinCache[pin] = _PinCacheEntry(
      sessionId: session?.id,
      sessionData: session,
      timestamp: DateTime.now(),
    );
  }

  /// Clear all cache
  void clearCache() {
    _pinCache.clear();
    _lookupHistory.clear();
    AppLogger.firebase('PinLookupService', 'Cache cleared');
  }

  /// Dispose service and cleanup resources
  void dispose() {
    _cleanupTimer?.cancel();

    for (final subscription in _activeWatchers.values) {
      subscription.cancel();
    }
    _activeWatchers.clear();

    clearCache();

    AppLogger.firebase('PinLookupService', 'Disposed PIN lookup service');
  }
}

/// Enhanced cache entry for PIN lookups with session data
class _PinCacheEntry {
  final String? sessionId;
  final GameSessionModel? sessionData;
  final DateTime timestamp;

  _PinCacheEntry({
    required this.sessionId,
    this.sessionData,
    required this.timestamp,
  });

  bool get isExpired {
    final age = DateTime.now().difference(timestamp);
    return age.inMinutes >= PinLookupService._cacheExpirationMinutes;
  }
}

/// PIN validation result
class PinValidationResult {
  final String pin;
  final bool isValid;
  final String? errorMessage;
  final SessionInfo? sessionInfo;

  const PinValidationResult({
    required this.pin,
    required this.isValid,
    this.errorMessage,
    this.sessionInfo,
  });
}

/// Session information
class SessionInfo {
  final String sessionId;
  final String pin;
  final GameSessionStatus status;
  final int playerCount;
  final int maxPlayers;
  final bool canJoin;
  final DateTime createdAt;

  const SessionInfo({
    required this.sessionId,
    required this.pin,
    required this.status,
    required this.playerCount,
    required this.maxPlayers,
    required this.canJoin,
    required this.createdAt,
  });

  bool get isFull => playerCount >= maxPlayers;
  int get availableSlots => maxPlayers - playerCount;
  double get fillPercentage => maxPlayers > 0 ? playerCount / maxPlayers : 0.0;
}

/// PIN status update for real-time monitoring
class PinStatusUpdate {
  final String pin;
  final bool exists;
  final GameSessionStatus? status;
  final int playerCount;
  final int maxPlayers;
  final bool canJoin;
  final DateTime lastUpdated;

  const PinStatusUpdate({
    required this.pin,
    required this.exists,
    this.status,
    required this.playerCount,
    required this.maxPlayers,
    required this.canJoin,
    required this.lastUpdated,
  });
}
