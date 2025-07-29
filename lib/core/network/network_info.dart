import 'dart:io';

/// Network connectivity checker for Firebase operations
/// Following CLAUDE.md Clean Architecture patterns
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      // Check connectivity by attempting to reach Google's DNS
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

/// Firebase-specific network utilities
class FirebaseNetworkHelper {
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Retry logic for Firebase operations
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxRetryAttempts,
    Duration delay = retryDelay,
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;

        await Future.delayed(delay);
      }
    }

    throw Exception('Operation failed after $maxAttempts attempts');
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unavailable');
  }
}
