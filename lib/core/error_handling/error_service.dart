import 'package:flutter/material.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';
import '../utils/exception_mapper.dart';
import '../../shared/widgets/feedback/snackbars.dart';

/// Error log levels for categorizing errors
enum ErrorLogLevel { info, warning, error, fatal }

/// Service for handling errors globally with user feedback and logging
/// Following CLAUDE.md Clean Architecture patterns
class ErrorService {
  static ErrorService? _instance;
  static ErrorService get instance => _instance ??= ErrorService._();

  ErrorService._();

  factory ErrorService() => instance;

  /// Handle any error object with proper logging and user feedback
  void handleError(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
    Map<String, dynamic>? additionalInfo,
    BuildContext? buildContext,
  }) {
    try {
      // Convert error to Failure for consistent handling
      final failure = _convertToFailure(error);

      // Build error context for logging
      final errorContext = buildErrorContext(
        context,
        stackTrace,
        additionalInfo,
      );

      // Log the error with appropriate level
      _logError(failure, stackTrace, errorContext);

      // Show user feedback if context is available
      if (buildContext != null && buildContext.mounted) {
        _showUserFeedback(buildContext, failure);
      }
    } catch (e, st) {
      // Fallback logging if error handling itself fails
      AppLogger.fatal('Error in error handling', e, st);
    }
  }

  /// Convert any error to Failure for consistent handling
  Failure _convertToFailure(dynamic error) {
    if (error is Exception) {
      return error.toFailure();
    } else if (error is Error) {
      return Failure.unknownFailure(message: error.toString());
    } else {
      return Failure.unknownFailure(message: error.toString());
    }
  }

  /// Get user-friendly message from failure
  String getUserFriendlyMessage(Failure failure) {
    return failure.userMessage;
  }

  /// Check if error is recoverable (user can retry)
  bool isRecoverableError(Failure failure) {
    return failure.when(
      serverFailure: (_, __) => false,
      networkFailure: (_) => true,
      authFailure: (_, __) => false,
      firestoreFailure: (_, __) => false,
      validationFailure: (_, __) => true,
      cacheFailure: (_) => false,
      unknownFailure: (_) => false,
    );
  }

  /// Get appropriate log level for failure type
  ErrorLogLevel getLogLevel(Failure failure) {
    return failure.when(
      serverFailure: (_, __) => ErrorLogLevel.error,
      networkFailure: (_) => ErrorLogLevel.warning,
      authFailure: (_, __) => ErrorLogLevel.error,
      firestoreFailure: (_, __) => ErrorLogLevel.error,
      validationFailure: (_, __) => ErrorLogLevel.info,
      cacheFailure: (_) => ErrorLogLevel.warning,
      unknownFailure: (_) => ErrorLogLevel.fatal,
    );
  }

  /// Build comprehensive error context for logging
  String buildErrorContext(
    String? context,
    StackTrace stackTrace,
    Map<String, dynamic>? additionalInfo,
  ) {
    final buffer = StringBuffer();

    if (context != null) {
      buffer.write(context);
    }

    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' - ');
      final infoStrings = additionalInfo.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      buffer.write(infoStrings);
    }

    return buffer.toString();
  }

  /// Log error with appropriate level
  void _logError(Failure failure, StackTrace stackTrace, String context) {
    final level = getLogLevel(failure);
    final message =
        '${failure.userMessage}${context.isNotEmpty ? ' - $context' : ''}';

    switch (level) {
      case ErrorLogLevel.info:
        AppLogger.info(message, failure, stackTrace);
        break;
      case ErrorLogLevel.warning:
        AppLogger.warning(message, failure, stackTrace);
        break;
      case ErrorLogLevel.error:
        AppLogger.error(message, failure, stackTrace);
        break;
      case ErrorLogLevel.fatal:
        AppLogger.fatal(message, failure, stackTrace);
        break;
    }
  }

  /// Show user feedback based on error type
  void _showUserFeedback(BuildContext context, Failure failure) {
    final message = getUserFriendlyMessage(failure);
    final isRecoverable = isRecoverableError(failure);

    if (isRecoverable) {
      CustomSnackBar.showWarning(
        context,
        message,
        actionLabel: 'Retry',
        onAction: () {
          // Retry logic could be implemented here
          AppLogger.info('User requested retry for recoverable error');
        },
      );
    } else {
      CustomSnackBar.showError(context, message);
    }
  }

  /// Handle Firestore-specific errors with enhanced context
  void handleFirestoreError(
    dynamic error,
    StackTrace stackTrace, {
    required String operation,
    Map<String, dynamic>? metadata,
    BuildContext? buildContext,
  }) {
    handleError(
      error,
      stackTrace,
      context: 'Firestore $operation',
      additionalInfo: metadata,
      buildContext: buildContext,
    );
  }

  /// Handle authentication-specific errors
  void handleAuthError(
    dynamic error,
    StackTrace stackTrace, {
    required String operation,
    String? userId,
    BuildContext? buildContext,
  }) {
    handleError(
      error,
      stackTrace,
      context: 'Auth $operation',
      additionalInfo: userId != null ? {'userId': userId} : null,
      buildContext: buildContext,
    );
  }

  /// Handle network-specific errors with retry capability
  void handleNetworkError(
    dynamic error,
    StackTrace stackTrace, {
    required String endpoint,
    String? requestId,
    BuildContext? buildContext,
  }) {
    handleError(
      error,
      stackTrace,
      context: 'Network request to $endpoint',
      additionalInfo: requestId != null ? {'requestId': requestId} : null,
      buildContext: buildContext,
    );
  }
}
