import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app_1/core/error_handling/global_error_handler.dart';
import 'package:quiz_app_1/core/error_handling/error_service.dart';
import 'package:quiz_app_1/core/errors/failures.dart';
import 'package:quiz_app_1/core/errors/exceptions.dart';
import 'package:quiz_app_1/shared/widgets/feedback/snackbars.dart';

void main() {
  group('Error Handling Integration Tests', () {
    late GlobalErrorHandler globalErrorHandler;
    late ErrorService errorService;

    setUp(() {
      globalErrorHandler = GlobalErrorHandler.instance;
      errorService = ErrorService.instance;
    });

    testWidgets('should show error snackbar when error occurs', (tester) async {
      // Create a test app with error handling
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    // Simulate an error
                    final error = ServerException(
                      message: 'Test server error',
                      code: '500',
                    );
                    globalErrorHandler.reportErrorWithContext(
                      error,
                      StackTrace.current,
                      context,
                    );
                  },
                  child: const Text('Trigger Error'),
                ),
              );
            },
          ),
        ),
      );

      // Tap the button to trigger error
      await tester.tap(find.text('Trigger Error'));
      await tester.pump();

      // Wait for snackbar to appear
      await tester.pump(const Duration(milliseconds: 100));

      // Verify error snackbar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Server error: Test server error'), findsOneWidget);
    });

    testWidgets('should handle recoverable errors with retry action', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    // Simulate a recoverable network error
                    final error = NetworkException(
                      message: 'Connection timeout',
                    );
                    globalErrorHandler.reportErrorWithContext(
                      error,
                      StackTrace.current,
                      context,
                    );
                  },
                  child: const Text('Trigger Network Error'),
                ),
              );
            },
          ),
        ),
      );

      // Tap the button to trigger network error
      await tester.tap(find.text('Trigger Network Error'));
      await tester.pump();

      // Wait for snackbar to appear
      await tester.pump(const Duration(milliseconds: 100));

      // Verify warning snackbar with retry action is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Network error: Connection timeout'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    test('should convert exceptions to failures correctly', () {
      // Test different exception types
      final serverException = ServerException(
        message: 'Server error',
        code: '500',
      );
      final networkException = NetworkException(message: 'Network error');
      final authException = AuthException(
        message: 'Auth error',
        code: 'auth/invalid',
      );
      final validationException = ValidationException(
        message: 'Validation error',
      );

      // Convert to failures using extension method
      final serverFailure = serverException.toFailure();
      final networkFailure = networkException.toFailure();
      final authFailure = authException.toFailure();
      final validationFailure = validationException.toFailure();

      // Verify correct failure types
      expect(serverFailure, isA<ServerFailure>());
      expect(networkFailure, isA<NetworkFailure>());
      expect(authFailure, isA<AuthFailure>());
      expect(validationFailure, isA<ValidationFailure>());

      // Verify user messages
      expect(serverFailure.userMessage, equals('Server error: Server error'));
      expect(
        networkFailure.userMessage,
        equals('Network error: Network error'),
      );
      expect(
        authFailure.userMessage,
        equals('Authentication error: Auth error'),
      );
      expect(
        validationFailure.userMessage,
        equals('Validation error: Validation error'),
      );
    });

    test('should categorize errors by recoverability correctly', () {
      const serverFailure = Failure.serverFailure(message: 'Server error');
      const networkFailure = Failure.networkFailure(message: 'Network error');
      const authFailure = Failure.authFailure(message: 'Auth error');
      const validationFailure = Failure.validationFailure(
        message: 'Validation error',
      );
      const unknownFailure = Failure.unknownFailure(message: 'Unknown error');

      // Test recoverability
      expect(errorService.isRecoverableError(serverFailure), isFalse);
      expect(errorService.isRecoverableError(networkFailure), isTrue);
      expect(errorService.isRecoverableError(authFailure), isFalse);
      expect(errorService.isRecoverableError(validationFailure), isTrue);
      expect(errorService.isRecoverableError(unknownFailure), isFalse);
    });

    test('should determine correct log levels for different failure types', () {
      const serverFailure = Failure.serverFailure(message: 'Server error');
      const networkFailure = Failure.networkFailure(message: 'Network error');
      const authFailure = Failure.authFailure(message: 'Auth error');
      const validationFailure = Failure.validationFailure(
        message: 'Validation error',
      );
      const cacheFailure = Failure.cacheFailure(message: 'Cache error');
      const unknownFailure = Failure.unknownFailure(message: 'Unknown error');

      // Test log levels
      expect(
        errorService.getLogLevel(serverFailure),
        equals(ErrorLogLevel.error),
      );
      expect(
        errorService.getLogLevel(networkFailure),
        equals(ErrorLogLevel.warning),
      );
      expect(
        errorService.getLogLevel(authFailure),
        equals(ErrorLogLevel.error),
      );
      expect(
        errorService.getLogLevel(validationFailure),
        equals(ErrorLogLevel.info),
      );
      expect(
        errorService.getLogLevel(cacheFailure),
        equals(ErrorLogLevel.warning),
      );
      expect(
        errorService.getLogLevel(unknownFailure),
        equals(ErrorLogLevel.fatal),
      );
    });

    test('should build error context with additional info', () {
      final stackTrace = StackTrace.current;
      const context = 'User authentication';
      final additionalInfo = {
        'userId': '123',
        'action': 'login',
        'timestamp': '2024-01-01T00:00:00Z',
      };

      final errorContext = errorService.buildErrorContext(
        context,
        stackTrace,
        additionalInfo,
      );

      expect(errorContext, contains('User authentication'));
      expect(errorContext, contains('userId: 123'));
      expect(errorContext, contains('action: login'));
      expect(errorContext, contains('timestamp: 2024-01-01T00:00:00Z'));
    });

    test('should handle null context and additional info gracefully', () {
      final stackTrace = StackTrace.current;

      // Test with null context
      final contextWithNullContext = errorService.buildErrorContext(
        null,
        stackTrace,
        {'key': 'value'},
      );
      expect(contextWithNullContext, equals('key: value'));

      // Test with null additional info
      final contextWithNullInfo = errorService.buildErrorContext(
        'Test context',
        stackTrace,
        null,
      );
      expect(contextWithNullInfo, equals('Test context'));

      // Test with both null
      final contextWithBothNull = errorService.buildErrorContext(
        null,
        stackTrace,
        null,
      );
      expect(contextWithBothNull, equals(''));
    });
  });
}
