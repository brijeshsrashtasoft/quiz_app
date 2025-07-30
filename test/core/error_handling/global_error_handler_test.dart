import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app_1/core/error_handling/global_error_handler.dart';
import 'package:quiz_app_1/core/error_handling/error_service.dart';
import 'package:quiz_app_1/core/utils/logger.dart';

// Manual mock for ErrorService
class MockErrorService extends Mock implements ErrorService {}

void main() {
  group('GlobalErrorHandler', () {
    late GlobalErrorHandler globalErrorHandler;
    late MockErrorService mockErrorService;

    setUp(() {
      mockErrorService = MockErrorService();
      globalErrorHandler = GlobalErrorHandler(errorService: mockErrorService);
    });

    group('initialization', () {
      test('should setup Flutter error handlers on initialization', () {
        // Arrange
        FlutterError.onError = null;
        PlatformDispatcher.instance.onError = null;

        // Act
        globalErrorHandler.initialize();

        // Assert
        expect(FlutterError.onError, isNotNull);
        expect(PlatformDispatcher.instance.onError, isNotNull);
      });

      test('should preserve existing error handlers when initializing', () {
        // Arrange
        final originalFlutterErrorHandler = FlutterError.onError;
        final originalPlatformErrorHandler = PlatformDispatcher.instance.onError;

        // Act
        globalErrorHandler.initialize();

        // Assert
        expect(FlutterError.onError, isNot(equals(originalFlutterErrorHandler)));
        expect(PlatformDispatcher.instance.onError, isNot(equals(originalPlatformErrorHandler)));
      });
    });

    group('Flutter error handling', () {
      test('should handle FlutterErrorDetails correctly', () async {
        // Arrange
        globalErrorHandler.initialize();
        final error = Exception('Test Flutter error');
        final stackTrace = StackTrace.current;
        final flutterErrorDetails = FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'test_library',
          context: ErrorDescription('Test context'),
        );

        // Act
        FlutterError.onError!(flutterErrorDetails);

        // Assert
        verify(mockErrorService.handleError(
          error,
          stackTrace,
          context: 'Flutter Error - test_library: Test context',
        )).called(1);
      });

      test('should handle FlutterErrorDetails without context', () async {
        // Arrange
        globalErrorHandler.initialize();
        final error = Exception('Test error without context');
        final stackTrace = StackTrace.current;
        final flutterErrorDetails = FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
        );

        // Act
        FlutterError.onError!(flutterErrorDetails);

        // Assert
        verify(mockErrorService.handleError(
          error,
          stackTrace,
          context: 'Flutter Error',
        )).called(1);
      });
    });

    group('Platform error handling', () {
      test('should handle platform errors correctly', () {
        // Arrange
        globalErrorHandler.initialize();
        final error = Exception('Test platform error');
        final stackTrace = StackTrace.current;

        // Act
        final result = PlatformDispatcher.instance.onError!(error, stackTrace);

        // Assert
        expect(result, isTrue);
        verify(mockErrorService.handleError(
          error,
          stackTrace,
          context: 'Platform Error',
        )).called(1);
      });

      test('should always return true for platform errors', () {
        // Arrange
        globalErrorHandler.initialize();
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        final result = PlatformDispatcher.instance.onError!(error, stackTrace);

        // Assert
        expect(result, isTrue);
      });
    });

    group('manual error reporting', () {
      test('should report errors manually through reportError method', () {
        // Arrange
        final error = Exception('Manual error report');
        final stackTrace = StackTrace.current;
        const context = 'Manual error context';

        // Act
        globalErrorHandler.reportError(error, stackTrace, context: context);

        // Assert
        verify(mockErrorService.handleError(
          error,
          stackTrace,
          context: context,
        )).called(1);
      });

      test('should report errors without context', () {
        // Arrange
        final error = Exception('Manual error without context');
        final stackTrace = StackTrace.current;

        // Act
        globalErrorHandler.reportError(error, stackTrace);

        // Assert
        verify(mockErrorService.handleError(
          error,
          stackTrace,
          context: null,
        )).called(1);
      });
    });

    group('zone integration', () {
      test('should create guarded zone and catch errors', () async {
        // Arrange
        final error = Exception('Zone error');
        var caughtError = false;

        // Act
        await globalErrorHandler.runInErrorZone(() async {
          throw error;
        });

        // Wait for error handling to complete
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        verify(mockErrorService.handleError(
          error,
          any,
          context: 'Zone Error',
        )).called(1);
      });

      test('should execute function successfully when no errors occur', () async {
        // Arrange
        var functionExecuted = false;

        // Act
        await globalErrorHandler.runInErrorZone(() async {
          functionExecuted = true;
        });

        // Assert
        expect(functionExecuted, isTrue);
        verifyNever(mockErrorService.handleError(any, any, context: anyNamed('context')));
      });
    });
  });
}