import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/errors/failures.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('should create ServerFailure with message and code', () {
        // Arrange
        const message = 'Server error occurred';
        const code = '500';

        // Act
        const failure = Failure.serverFailure(message: message, code: code);

        // Assert
        expect(failure, isA<ServerFailure>());
        failure.when(
          serverFailure: (msg, c) {
            expect(msg, equals(message));
            expect(c, equals(code));
          },
          networkFailure: (_) => fail('Should be ServerFailure'),
          authFailure: (_, __) => fail('Should be ServerFailure'),
          firestoreFailure: (_, __) => fail('Should be ServerFailure'),
          validationFailure: (_, __) => fail('Should be ServerFailure'),
          cacheFailure: (_) => fail('Should be ServerFailure'),
          unknownFailure: (_) => fail('Should be ServerFailure'),
        );
      });

      test('should create ServerFailure with message only', () {
        // Arrange
        const message = 'Server error occurred';

        // Act
        const failure = Failure.serverFailure(message: message);

        // Assert
        failure.when(
          serverFailure: (msg, code) {
            expect(msg, equals(message));
            expect(code, isNull);
          },
          networkFailure: (_) => fail('Should be ServerFailure'),
          authFailure: (_, __) => fail('Should be ServerFailure'),
          firestoreFailure: (_, __) => fail('Should be ServerFailure'),
          validationFailure: (_, __) => fail('Should be ServerFailure'),
          cacheFailure: (_) => fail('Should be ServerFailure'),
          unknownFailure: (_) => fail('Should be ServerFailure'),
        );
      });
    });

    group('NetworkFailure', () {
      test('should create NetworkFailure with message', () {
        // Arrange
        const message = 'Network connection failed';

        // Act
        const failure = Failure.networkFailure(message: message);

        // Assert
        expect(failure, isA<NetworkFailure>());
        failure.when(
          networkFailure: (msg) {
            expect(msg, equals(message));
          },
          serverFailure: (_, __) => fail('Should be NetworkFailure'),
          authFailure: (_, __) => fail('Should be NetworkFailure'),
          firestoreFailure: (_, __) => fail('Should be NetworkFailure'),
          validationFailure: (_, __) => fail('Should be NetworkFailure'),
          cacheFailure: (_) => fail('Should be NetworkFailure'),
          unknownFailure: (_) => fail('Should be NetworkFailure'),
        );
      });
    });

    group('AuthFailure', () {
      test('should create AuthFailure with message and code', () {
        // Arrange
        const message = 'Authentication failed';
        const code = 'user-not-found';

        // Act
        const failure = Failure.authFailure(message: message, code: code);

        // Assert
        expect(failure, isA<AuthFailure>());
        failure.when(
          authFailure: (msg, c) {
            expect(msg, equals(message));
            expect(c, equals(code));
          },
          serverFailure: (_, __) => fail('Should be AuthFailure'),
          networkFailure: (_) => fail('Should be AuthFailure'),
          firestoreFailure: (_, __) => fail('Should be AuthFailure'),
          validationFailure: (_, __) => fail('Should be AuthFailure'),
          cacheFailure: (_) => fail('Should be AuthFailure'),
          unknownFailure: (_) => fail('Should be AuthFailure'),
        );
      });
    });

    group('FirestoreFailure', () {
      test('should create FirestoreFailure with message and code', () {
        // Arrange
        const message = 'Firestore operation failed';
        const code = 'permission-denied';

        // Act
        const failure = Failure.firestoreFailure(message: message, code: code);

        // Assert
        expect(failure, isA<FirestoreFailure>());
        failure.when(
          firestoreFailure: (msg, c) {
            expect(msg, equals(message));
            expect(c, equals(code));
          },
          serverFailure: (_, __) => fail('Should be FirestoreFailure'),
          networkFailure: (_) => fail('Should be FirestoreFailure'),
          authFailure: (_, __) => fail('Should be FirestoreFailure'),
          validationFailure: (_, __) => fail('Should be FirestoreFailure'),
          cacheFailure: (_) => fail('Should be FirestoreFailure'),
          unknownFailure: (_) => fail('Should be FirestoreFailure'),
        );
      });
    });

    group('ValidationFailure', () {
      test('should create ValidationFailure with message and field errors', () {
        // Arrange
        const message = 'Validation failed';
        const fieldErrors = {
          'email': 'Invalid email format',
          'password': 'Too short',
        };

        // Act
        const failure = Failure.validationFailure(
          message: message,
          fieldErrors: fieldErrors,
        );

        // Assert
        expect(failure, isA<ValidationFailure>());
        failure.when(
          validationFailure: (msg, errors) {
            expect(msg, equals(message));
            expect(errors, equals(fieldErrors));
          },
          serverFailure: (_, __) => fail('Should be ValidationFailure'),
          networkFailure: (_) => fail('Should be ValidationFailure'),
          authFailure: (_, __) => fail('Should be ValidationFailure'),
          firestoreFailure: (_, __) => fail('Should be ValidationFailure'),
          cacheFailure: (_) => fail('Should be ValidationFailure'),
          unknownFailure: (_) => fail('Should be ValidationFailure'),
        );
      });
    });

    group('CacheFailure', () {
      test('should create CacheFailure with message', () {
        // Arrange
        const message = 'Cache operation failed';

        // Act
        const failure = Failure.cacheFailure(message: message);

        // Assert
        expect(failure, isA<CacheFailure>());
        failure.when(
          cacheFailure: (msg) {
            expect(msg, equals(message));
          },
          serverFailure: (_, __) => fail('Should be CacheFailure'),
          networkFailure: (_) => fail('Should be CacheFailure'),
          authFailure: (_, __) => fail('Should be CacheFailure'),
          firestoreFailure: (_, __) => fail('Should be CacheFailure'),
          validationFailure: (_, __) => fail('Should be CacheFailure'),
          unknownFailure: (_) => fail('Should be CacheFailure'),
        );
      });
    });

    group('UnknownFailure', () {
      test('should create UnknownFailure with message', () {
        // Arrange
        const message = 'Unknown error occurred';

        // Act
        const failure = Failure.unknownFailure(message: message);

        // Assert
        expect(failure, isA<UnknownFailure>());
        failure.when(
          unknownFailure: (msg) {
            expect(msg, equals(message));
          },
          serverFailure: (_, __) => fail('Should be UnknownFailure'),
          networkFailure: (_) => fail('Should be UnknownFailure'),
          authFailure: (_, __) => fail('Should be UnknownFailure'),
          firestoreFailure: (_, __) => fail('Should be UnknownFailure'),
          validationFailure: (_, __) => fail('Should be UnknownFailure'),
          cacheFailure: (_) => fail('Should be UnknownFailure'),
        );
      });
    });
  });

  group('FailureX extension', () {
    group('userMessage', () {
      test('should return correct user message for ServerFailure', () {
        // Arrange
        const failure = Failure.serverFailure(message: 'Internal server error');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(userMessage, equals('Server error: Internal server error'));
      });

      test('should return correct user message for NetworkFailure', () {
        // Arrange
        const failure = Failure.networkFailure(message: 'Connection timeout');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(userMessage, equals('Network error: Connection timeout'));
      });

      test('should return correct user message for AuthFailure', () {
        // Arrange
        const failure = Failure.authFailure(message: 'Invalid credentials');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(
          userMessage,
          equals('Authentication error: Invalid credentials'),
        );
      });

      test('should return correct user message for FirestoreFailure', () {
        // Arrange
        const failure = Failure.firestoreFailure(message: 'Permission denied');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(userMessage, equals('Database error: Permission denied'));
      });

      test('should return correct user message for ValidationFailure', () {
        // Arrange
        const failure = Failure.validationFailure(message: 'Invalid input');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(userMessage, equals('Validation error: Invalid input'));
      });

      test('should return correct user message for CacheFailure', () {
        // Arrange
        const failure = Failure.cacheFailure(message: 'Cache is full');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(userMessage, equals('Cache error: Cache is full'));
      });

      test('should return correct user message for UnknownFailure', () {
        // Arrange
        const failure = Failure.unknownFailure(message: 'Something went wrong');

        // Act
        final userMessage = failure.userMessage;

        // Assert
        expect(userMessage, equals('Unknown error: Something went wrong'));
      });
    });
  });
}
