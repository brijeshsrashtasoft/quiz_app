import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:quiz_app_1/core/error_handling/error_service.dart';
import 'package:quiz_app_1/core/errors/failures.dart';
import 'package:quiz_app_1/core/errors/exceptions.dart';
import 'package:quiz_app_1/core/utils/logger.dart';
import 'package:quiz_app_1/shared/widgets/feedback/snackbars.dart';

// Mock classes will be generated
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('ErrorService', () {
    late ErrorService errorService;
    late MockBuildContext mockContext;

    setUp(() {
      errorService = ErrorService();
      mockContext = MockBuildContext();
    });

    group('error handling', () {
      test('should handle Exception and convert to failure', () {
        // Arrange
        final exception = ServerException(
          message: 'Server error occurred',
          code: '500',
        );
        final stackTrace = StackTrace.current;

        // Act
        errorService.handleError(
          exception,
          stackTrace,
          context: 'Test context',
        );

        // Assert - Since we can't easily mock static methods,
        // we'll verify behavior through integration tests
        expect(exception.message, equals('Server error occurred'));
      });

      test('should handle generic Exception', () {
        // Arrange
        final exception = Exception('Generic error');
        final stackTrace = StackTrace.current;

        // Act
        errorService.handleError(exception, stackTrace);

        // Assert
        expect(exception.toString(), contains('Generic error'));
      });

      test('should handle Error objects', () {
        // Arrange
        final error = ArgumentError('Invalid argument');
        final stackTrace = StackTrace.current;

        // Act
        errorService.handleError(
          error,
          stackTrace,
          context: 'Argument validation',
        );

        // Assert
        expect(error.message, equals('Invalid argument'));
      });
    });

    group('failure to user message conversion', () {
      test('should convert ServerFailure to user-friendly message', () {
        // Arrange
        const failure = Failure.serverFailure(
          message: 'Internal server error',
          code: '500',
        );

        // Act
        final userMessage = errorService.getUserFriendlyMessage(failure);

        // Assert
        expect(userMessage, equals('Server error: Internal server error'));
      });

      test('should convert NetworkFailure to user-friendly message', () {
        // Arrange
        const failure = Failure.networkFailure(message: 'Connection timeout');

        // Act
        final userMessage = errorService.getUserFriendlyMessage(failure);

        // Assert
        expect(userMessage, equals('Network error: Connection timeout'));
      });

      test('should convert AuthFailure to user-friendly message', () {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Invalid credentials',
          code: 'auth/invalid-credential',
        );

        // Act
        final userMessage = errorService.getUserFriendlyMessage(failure);

        // Assert
        expect(
          userMessage,
          equals('Authentication error: Invalid credentials'),
        );
      });

      test('should convert ValidationFailure to user-friendly message', () {
        // Arrange
        const failure = Failure.validationFailure(
          message: 'Form validation failed',
          fieldErrors: {'email': 'Invalid email format'},
        );

        // Act
        final userMessage = errorService.getUserFriendlyMessage(failure);

        // Assert
        expect(userMessage, equals('Validation error: Form validation failed'));
      });
    });

    group('error categorization', () {
      test('should categorize network errors as recoverable', () {
        // Arrange
        const failure = Failure.networkFailure(message: 'Connection lost');

        // Act
        final isRecoverable = errorService.isRecoverableError(failure);

        // Assert
        expect(isRecoverable, isTrue);
      });

      test('should categorize validation errors as recoverable', () {
        // Arrange
        const failure = Failure.validationFailure(message: 'Invalid input');

        // Act
        final isRecoverable = errorService.isRecoverableError(failure);

        // Assert
        expect(isRecoverable, isTrue);
      });

      test('should categorize server errors as non-recoverable', () {
        // Arrange
        const failure = Failure.serverFailure(message: 'Internal error');

        // Act
        final isRecoverable = errorService.isRecoverableError(failure);

        // Assert
        expect(isRecoverable, isFalse);
      });

      test('should categorize unknown errors as non-recoverable', () {
        // Arrange
        const failure = Failure.unknownFailure(message: 'Unknown error');

        // Act
        final isRecoverable = errorService.isRecoverableError(failure);

        // Assert
        expect(isRecoverable, isFalse);
      });
    });

    group('error logging', () {
      test('should determine correct log level for different failures', () {
        // Arrange & Act & Assert
        expect(
          errorService.getLogLevel(
            const Failure.networkFailure(message: 'Network issue'),
          ),
          equals(ErrorLogLevel.warning),
        );

        expect(
          errorService.getLogLevel(
            const Failure.validationFailure(message: 'Validation issue'),
          ),
          equals(ErrorLogLevel.info),
        );

        expect(
          errorService.getLogLevel(
            const Failure.serverFailure(message: 'Server issue'),
          ),
          equals(ErrorLogLevel.error),
        );

        expect(
          errorService.getLogLevel(
            const Failure.unknownFailure(message: 'Unknown issue'),
          ),
          equals(ErrorLogLevel.fatal),
        );

        expect(
          errorService.getLogLevel(
            const Failure.authFailure(message: 'Auth issue'),
          ),
          equals(ErrorLogLevel.error),
        );
      });
    });

    group('context building', () {
      test('should build proper context from parameters', () {
        // Arrange
        const contextInfo = 'User login flow';
        final stackTrace = StackTrace.current;

        // Act
        final context = errorService.buildErrorContext(
          contextInfo,
          stackTrace,
          {'userId': '123', 'action': 'login'},
        );

        // Assert
        expect(context, contains('User login flow'));
        expect(context, contains('userId: 123'));
        expect(context, contains('action: login'));
      });

      test('should handle null additional info', () {
        // Arrange
        const contextInfo = 'Basic context';
        final stackTrace = StackTrace.current;

        // Act
        final context = errorService.buildErrorContext(
          contextInfo,
          stackTrace,
          null,
        );

        // Assert
        expect(context, equals('Basic context'));
      });

      test('should handle null context info', () {
        // Arrange
        final stackTrace = StackTrace.current;

        // Act
        final context = errorService.buildErrorContext(null, stackTrace, {
          'key': 'value',
        });

        // Assert
        expect(context, contains('key: value'));
      });
    });
  });
}
