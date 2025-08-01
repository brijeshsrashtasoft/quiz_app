import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/email.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

void main() {
  group('Email Value Object Tests - US-001 Registration Flow', () {
    group('Email Validation Logic', () {
      test('should create valid email with proper format', () {
        // Arrange
        const validEmail = 'test@example.com';

        // Act
        final result = Email.validate(validEmail);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.value, equals('test@example.com'));
      });

      test('should convert email to lowercase', () {
        // Arrange
        const mixedCaseEmail = 'Test.User@EXAMPLE.COM';

        // Act
        final result = Email.validate(mixedCaseEmail);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.value, equals('test.user@example.com'));
      });

      test('should trim whitespace from email', () {
        // Arrange
        const emailWithSpaces = '  test@example.com  ';

        // Act
        final result = Email.validate(emailWithSpaces);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.value, equals('test@example.com'));
      });

      test('should fail validation for empty email', () {
        // Arrange
        const emptyEmail = '';

        // Act
        final result = Email.validate(emptyEmail);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Email address is required'),
        );
        result.failureOrNull?.when(
          validationFailure: (message, fieldErrors) {
            expect(
              fieldErrors?['email'],
              contains('Email address is required'),
            );
          },
          serverFailure: (_, __) => fail('Expected validation failure'),
          networkFailure: (_) => fail('Expected validation failure'),
          authFailure: (_, __) => fail('Expected validation failure'),
          firestoreFailure: (_, __) => fail('Expected validation failure'),
          cacheFailure: (_) => fail('Expected validation failure'),
          unknownFailure: (_) => fail('Expected validation failure'),
          securityFailure: (_, __) => fail('Expected validation failure'),
          biometricFailure: (_, __) => fail('Expected validation failure'),
          sessionFailure: (_, __) => fail('Expected validation failure'),
          deviceFailure: (_, __) => fail('Expected validation failure'),
        );
      });

      test('should fail validation for whitespace-only email', () {
        // Arrange
        const whitespaceEmail = '   ';

        // Act
        final result = Email.validate(whitespaceEmail);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Email address is required'),
        );
      });

      test('should fail validation for invalid email formats', () {
        // Arrange
        final invalidEmails = [
          'invalid',
          'invalid@',
          '@invalid.com',
          'invalid.com',
          'invalid@.com',
          'invalid@com.',
          'invalid..test@example.com',
          '.invalid@example.com',
          'invalid.@example.com',
        ];

        for (final email in invalidEmails) {
          // Act
          final result = Email.validate(email);

          // Assert
          expect(
            result.isFailure,
            isTrue,
            reason: 'Email "$email" should be invalid',
          );
          expect(
            result.failureOrNull?.userMessage,
            anyOf([
              contains('Please enter a valid email address'),
              contains('Email format is invalid'),
            ]),
            reason: 'Email "$email" should have proper error message',
          );
        }
      });

      test('should fail validation for email that is too long', () {
        // Arrange
        final longEmail = '${'a' * 250}@example.com'; // 261 characters total

        // Act
        final result = Email.validate(longEmail);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Email address is too long'),
        );
      });

      test('should validate various valid email formats', () {
        // Arrange
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'user_name@sub.domain.com',
          'user123@test123.com',
          'a@b.co',
          'test-email@example-domain.com',
        ];

        for (final email in validEmails) {
          // Act
          final result = Email.validate(email);

          // Assert
          expect(
            result.isSuccess,
            isTrue,
            reason: 'Email "$email" should be valid',
          );
          expect(result.dataOrNull?.value, isNotNull);
        }
      });
    });

    group('Email Factory Methods', () {
      test('should create email using constructor with valid input', () {
        // Arrange & Act
        final email = Email('test@example.com');

        // Assert
        expect(email.value, equals('test@example.com'));
      });

      test(
        'should throw ArgumentError when creating email with invalid input',
        () {
          // Arrange & Act & Assert
          expect(() => Email('invalid-email'), throwsA(isA<ArgumentError>()));
        },
      );

      test('should return null for invalid email using tryCreate', () {
        // Arrange
        const invalidEmail = 'invalid-email';

        // Act
        final result = Email.tryCreate(invalidEmail);

        // Assert
        expect(result, isNull);
      });

      test('should return email object for valid email using tryCreate', () {
        // Arrange
        const validEmail = 'test@example.com';

        // Act
        final result = Email.tryCreate(validEmail);

        // Assert
        expect(result, isNotNull);
        expect(result?.value, equals('test@example.com'));
      });
    });

    group('Email Extension Methods', () {
      test('should extract domain from email', () {
        // Arrange
        final email = Email('user@example.com');

        // Act
        final domain = email.domain;

        // Assert
        expect(domain, equals('example.com'));
      });

      test('should extract local part from email', () {
        // Arrange
        final email = Email('user.name@example.com');

        // Act
        final localPart = email.localPart;

        // Assert
        expect(localPart, equals('user.name'));
      });

      test('should check if email is from specific domain', () {
        // Arrange
        final email = Email('user@example.com');

        // Act & Assert
        expect(email.isFromDomain('example.com'), isTrue);
        expect(email.isFromDomain('EXAMPLE.COM'), isTrue); // Case insensitive
        expect(email.isFromDomain('other.com'), isFalse);
      });

      test('should identify admin emails correctly', () {
        // Arrange
        final adminEmail = Email('admin@quizapp.com');
        final regularEmail = Email('user@gmail.com');

        // Act & Assert
        expect(adminEmail.isAdminEmail, isTrue);
        expect(regularEmail.isAdminEmail, isFalse);
      });

      test('should identify corporate emails correctly', () {
        // Arrange
        final corporateEmail = Email('user@company.com');
        final personalEmail = Email('user@gmail.com');

        // Act & Assert
        expect(corporateEmail.isCorporateEmail, isTrue);
        expect(personalEmail.isCorporateEmail, isFalse);
      });
    });

    group('Email Edge Cases for Registration Flow', () {
      test('should handle international domain names', () {
        // Arrange
        const internationalEmail = 'user@domain.co.uk';

        // Act
        final result = Email.validate(internationalEmail);

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle emails with numbers in domain', () {
        // Arrange
        const numericDomainEmail = 'user@domain123.com';

        // Act
        final result = Email.validate(numericDomainEmail);

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle emails with hyphens', () {
        // Arrange
        const hyphenatedEmail = 'test-user@test-domain.com';

        // Act
        final result = Email.validate(hyphenatedEmail);

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should reject emails with consecutive dots', () {
        // Arrange
        const consecutiveDotsEmail = 'user..name@example.com';

        // Act
        final result = Email.validate(consecutiveDotsEmail);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Email format is invalid'),
        );
      });
    });
  });
}
