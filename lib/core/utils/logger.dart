import 'package:logger/logger.dart';

/// Centralized logging utility following CLAUDE.md guidelines
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false, // Following CLAUDE.md - no emojis unless requested
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log debug information
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log informational messages
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warnings
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log critical errors
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Firebase-specific logging
  static void firebase(String operation, String message, [dynamic error]) {
    _logger.i('Firebase $operation: $message', error: error);
  }

  /// Performance logging for real-time features
  static void performance(String operation, Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms > 200) {
      // Following CLAUDE.md 200ms latency requirement
      _logger.w(
        'Performance warning: $operation took $ms ms (>200ms threshold),',
      );
    } else {
      _logger.d('Performance: $operation completed in $ms ms');
    }
  }
}
