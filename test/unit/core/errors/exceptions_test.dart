import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/errors/exceptions.dart';

void main() {
  group('Exceptions', () {
    group('ServerException', () {
      test('should create exception with message and code', () {
        // Arrange
        const message = 'Server error occurred';
        const code = '500';
        
        // Act
        const exception = ServerException(message: message, code: code);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, equals(code));
        expect(exception.toString(), equals('ServerException: $message (Code: $code)'));
      });

      test('should create exception with message only', () {
        // Arrange
        const message = 'Server error occurred';
        
        // Act
        const exception = ServerException(message: message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, isNull);
        expect(exception.toString(), equals('ServerException: $message'));
      });
    });

    group('NetworkException', () {
      test('should create exception with message', () {
        // Arrange
        const message = 'Network connection failed';
        
        // Act
        const exception = NetworkException(message: message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.toString(), equals('NetworkException: $message'));
      });
    });

    group('AuthException', () {
      test('should create exception with message and code', () {
        // Arrange
        const message = 'Authentication failed';
        const code = 'user-not-found';
        
        // Act
        const exception = AuthException(message: message, code: code);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, equals(code));
        expect(exception.toString(), equals('AuthException: $message (Code: $code)'));
      });

      test('should create exception with message only', () {
        // Arrange
        const message = 'Authentication failed';
        
        // Act
        const exception = AuthException(message: message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, isNull);
        expect(exception.toString(), equals('AuthException: $message'));
      });
    });

    group('FirestoreException', () {
      test('should create exception with message and code', () {
        // Arrange
        const message = 'Firestore operation failed';
        const code = 'permission-denied';
        
        // Act
        const exception = FirestoreException(message: message, code: code);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, equals(code));
        expect(exception.toString(), equals('FirestoreException: $message (Code: $code)'));
      });

      test('should create exception with message only', () {
        // Arrange
        const message = 'Firestore operation failed';
        
        // Act
        const exception = FirestoreException(message: message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, isNull);
        expect(exception.toString(), equals('FirestoreException: $message'));
      });
    });

    group('ValidationException', () {
      test('should create exception with message and field errors', () {
        // Arrange
        const message = 'Validation failed';
        const fieldErrors = {'email': 'Invalid format', 'password': 'Too short'};
        
        // Act
        const exception = ValidationException(
          message: message,
          fieldErrors: fieldErrors,
        );
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.fieldErrors, equals(fieldErrors));
        expect(exception.toString(), equals('ValidationException: $message'));
      });

      test('should create exception with message only', () {
        // Arrange
        const message = 'Validation failed';
        
        // Act
        const exception = ValidationException(message: message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.fieldErrors, isNull);
        expect(exception.toString(), equals('ValidationException: $message'));
      });
    });

    group('CacheException', () {
      test('should create exception with message', () {
        // Arrange
        const message = 'Cache operation failed';
        
        // Act
        const exception = CacheException(message: message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.toString(), equals('CacheException: $message'));
      });
    });
  });

  group('Exception hierarchy', () {
    test('all custom exceptions should implement Exception', () {
      // Arrange & Act
      const serverException = ServerException(message: 'test');
      const networkException = NetworkException(message: 'test');
      const authException = AuthException(message: 'test');
      const firestoreException = FirestoreException(message: 'test');
      const validationException = ValidationException(message: 'test');
      const cacheException = CacheException(message: 'test');
      
      // Assert
      expect(serverException, isA<Exception>());
      expect(networkException, isA<Exception>());
      expect(authException, isA<Exception>());
      expect(firestoreException, isA<Exception>());
      expect(validationException, isA<Exception>());
      expect(cacheException, isA<Exception>());
    });
  });
}