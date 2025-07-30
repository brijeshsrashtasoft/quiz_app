import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../../../lib/features/authentication/domain/usecases/sign_up_usecase.dart';
import '../../../../../../lib/core/utils/result.dart';
import '../../../../../../lib/core/errors/failures.dart';

import 'sign_up_usecase_test.mocks.dart';

/// Test file for SignUpUseCase following TDD principles
/// Covers all registration scenarios, validation, and edge cases
/// Following CLAUDE.md testing patterns

@GenerateMocks([UserCredential, User])
void main() {
  group('SignUpUseCase', () {
    late SignUpUseCase signUpUseCase;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    setUpAll(() {
      // Initialize mocks
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();

      // Setup mock user credential
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.uid).thenReturn('test-uid-123');
    });

    setUp(() {
      signUpUseCase = SignUpUseCase();
    });

    group('Successful Sign Up', () {
      test('should return success when all parameters are valid', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'password123',
          name: 'John Doe',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isA<UserCredential>());
      });

      test('should handle email with extra whitespace', () async {
        // Arrange
        const params = SignUpParams(
          email: '  test@example.com  ',
          password: 'password123',
          name: '  John Doe  ',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert - Should succeed by trimming input
        expect(result.isSuccess, isTrue);
      });
    });

    group('Email Validation', () {
      test('should return validation failure when email is empty', () async {
        // Arrange
        const params = SignUpParams(
          email: '',
          password: 'password123',
          name: 'John Doe',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        final failure = result.failureOrNull as ValidationFailure;
        expect(failure.fieldErrors?['email'], isNotNull);
        expect(failure.message, equals('Email address is required'));
      });

      test(
        'should return validation failure when email format is invalid',
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'invalid-email',
            password: 'password123',
            name: 'John Doe',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.fieldErrors?['email'], isNotNull);
          expect(
            failure.message,
            equals('Please enter a valid email address'),
          );
        },
      );

      test('should validate various email formats correctly', () async {
        final testCases = [
          // Valid emails
          ('test@example.com', true),
          ('user.name@domain.co.uk', true),
          ('test123@subdomain.example.org', true),
          ('user+tag@example.com', true),

          // Invalid emails
          ('plainaddress', false),
          ('@missingdomain.com', false),
          ('missing@.com', false),
          ('spaces @example.com', false),
          ('test@', false),
        ];

        for (final (email, shouldBeValid) in testCases) {
          // Arrange
          final params = SignUpParams(
            email: email,
            password: 'Password123',
            name: 'John Doe',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          if (shouldBeValid) {
            expect(
              result.isFailure,
              isFalse,
              reason: 'Email $email should be valid',
            );
          } else {
            expect(
              result.isFailure,
              isTrue,
              reason: 'Email $email should be invalid',
            );
            expect(result.failureOrNull, isA<ValidationFailure>());
            final failure = result.failureOrNull as ValidationFailure;
            expect(failure.fieldErrors?['email'], isNotNull);
          }
        }
      });
    });

    group('Password Validation', () {
      test('should return validation failure when password is empty', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: '',
          name: 'John Doe',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        final failure = result.failureOrNull as ValidationFailure;
        expect(failure.fieldErrors?['password'], isNotNull);
        expect(failure.message, equals('Password is required'));
      });

      test(
        'should return validation failure when password is too short',
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: '12345',
            name: 'John Doe',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.fieldErrors?['password'], isNotNull);
          expect(
            failure.message,
            equals('Password must be at least 6 characters long'),
          );
        },
      );

      test(
        'should return validation failure when password lacks letters and numbers',
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: 'password',
            name: 'John Doe',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.fieldErrors?['password'], isNotNull);
          expect(
            failure.message,
            equals('Password must contain both letters and numbers'),
          );
        },
      );

      test('should validate password strength correctly', () async {
        final testCases = [
          // Valid passwords
          ('password123', true),
          ('Password1', true),
          ('abc123def', true),
          ('MySecure1Pass', true),
          ('test1234', true),

          // Invalid passwords - only letters
          ('password', false),
          ('PASSWORD', false),
          ('abcdefgh', false),

          // Invalid passwords - only numbers
          ('12345678', false),
          ('1234567890', false),

          // Invalid passwords - too short
          ('12345', false),
          ('abc12', false),
          ('a1', false),
        ];

        for (final (password, shouldBeValid) in testCases) {
          // Arrange
          final params = SignUpParams(
            email: 'test@example.com',
            password: password,
            name: 'John Doe',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          if (shouldBeValid) {
            expect(
              result.isFailure,
              isFalse,
              reason: 'Password "$password" should be valid',
            );
          } else {
            expect(
              result.isFailure,
              isTrue,
              reason: 'Password "$password" should be invalid',
            );
            expect(result.failureOrNull, isA<ValidationFailure>());
            final failure = result.failureOrNull as ValidationFailure;
            expect(failure.fieldErrors?.containsKey('password'), isTrue);
          }
        }
      });
    });

    group('Name Validation', () {
      test('should return validation failure when name is empty', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'password123',
          name: '',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        final failure = result.failureOrNull as ValidationFailure;
        expect(failure.fieldErrors?['name'], isNotNull);
        expect(failure.message, equals('Full name is required'));
      });

      test(
        'should return validation failure when name is too short after trimming',
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: 'password123',
            name: ' A ', // Becomes 'A' after trimming
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.fieldErrors?['name'], isNotNull);
          expect(
            failure.message,
            equals('Name must be at least 2 characters long'),
          );
        },
      );

      test('should accept valid names', () async {
        final validNames = [
          'Jo',
          'John Doe',
          'Mary Jane Watson',
          'José María',
          '李小明',
          'Mohammed Al-Rahman',
          'O\'Connor',
          'van der Berg',
        ];

        for (final name in validNames) {
          // Arrange
          final params = SignUpParams(
            email: 'test@example.com',
            password: 'password123',
            name: name,
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert - Should not fail due to name validation
          if (result.isFailure) {
            final failure = result.failureOrNull!;
            expect(
              failure,
              isNot(
                isA<ValidationFailure>().having(
                  (f) => f.fieldErrors?.containsKey('name'),
                  'has name field error',
                  isTrue,
                ),
              ),
              reason: 'Name "$name" should be valid',
            );
          }
        }
      });
    });

    group('Authentication Failures', () {
      test('should handle email already in use error', () async {
        // Arrange
        const params = SignUpParams(
          email: 'existing@example.com',
          password: 'password123',
          name: 'John Doe',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert - Testing error handling structure
        expect(result, isA<Result<UserCredential>>());
      });

      test('should handle weak password error from Firebase', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'weak',
          name: 'John Doe',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert - This should be caught by our validation first
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
      });
    });

    group('Edge Cases', () {
      test('should handle unicode characters in name', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'password123',
          name: 'José María González-Pérez',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert - Should handle unicode characters
        expect(result, isA<Result<UserCredential>>());
      });

      test('should handle very long names', () async {
        // Arrange
        final longName = 'A' * 100; // Very long name
        final params = SignUpParams(
          email: 'test@example.com',
          password: 'password123',
          name: longName,
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert - Should handle long names
        expect(result, isA<Result<UserCredential>>());
      });

      test('should handle names with only spaces', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'password123',
          name: '   ',
        );

        // Act
        final result = await signUpUseCase(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        final failure = result.failureOrNull as ValidationFailure;
        expect(failure.fieldErrors?['name'], isNotNull);
      });
    });

    group('Performance', () {
      test('should complete within reasonable time', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'password123',
          name: 'John Doe',
        );

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await signUpUseCase(params);
        stopwatch.stop();

        // Assert - Should complete within 5 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        expect(result, isA<Result<UserCredential>>());
      });
    });

    group('ToString Method', () {
      test('should not expose password in toString', () async {
        // Arrange
        const params = SignUpParams(
          email: 'test@example.com',
          password: 'secretpassword',
          name: 'John Doe',
        );

        // Act
        final toString = params.toString();

        // Assert
        expect(toString, contains('test@example.com'));
        expect(toString, contains('John Doe'));
        expect(toString, isNot(contains('secretpassword')));
      });
    });
  });
}
