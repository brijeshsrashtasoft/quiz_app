import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/password.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

void main() {
  group('Password Value Object Tests - US-001 Registration Flow', () {
    group('Password Validation Logic', () {
      test('should create valid password meeting all requirements', () {
        // Arrange
        const validPassword = 'StrongPass123';

        // Act
        final result = Password.validate(validPassword);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.value, equals('StrongPass123'));
      });

      test('should fail validation for empty password', () {
        // Arrange
        const emptyPassword = '';

        // Act
        final result = Password.validate(emptyPassword);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Password is required'),
        );
        result.failureOrNull?.when(
          validationFailure: (message, fieldErrors) {
            expect(fieldErrors?['password'], contains('Password is required'));
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

      test('should fail validation for password shorter than 8 characters', () {
        // Arrange
        const shortPassword = 'Pass1';

        // Act
        final result = Password.validate(shortPassword);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Password must be at least 8 characters long'),
        );
        result.failureOrNull?.when(
          validationFailure: (message, fieldErrors) {
            expect(
              fieldErrors?['password'],
              contains('Password must be at least 8 characters long'),
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

      test(
        'should fail validation for password longer than 128 characters',
        () {
          // Arrange
          final longPassword = 'A1a!' + 'a' * 125; // 129 characters total

          // Act
          final result = Password.validate(longPassword);

          // Assert
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull?.userMessage,
            contains('Password is too long'),
          );
        },
      );

      test('should fail validation for password without uppercase letter', () {
        // Arrange
        const noUppercasePassword = 'password123';

        // Act
        final result = Password.validate(noUppercasePassword);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Password must contain at least one uppercase letter'),
        );
      });

      test('should fail validation for password without lowercase letter', () {
        // Arrange
        const noLowercasePassword = 'PASSWORD123';

        // Act
        final result = Password.validate(noLowercasePassword);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Password must contain at least one lowercase letter'),
        );
      });

      test('should fail validation for password without number', () {
        // Arrange
        const noNumberPassword = 'PasswordAbc';

        // Act
        final result = Password.validate(noNumberPassword);

        // Assert
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.userMessage,
          contains('Password must contain at least one number'),
        );
      });

      test('should reject common weak passwords', () {
        // Arrange
        final commonPasswords = [
          'Password123',
          'Welcome123',
          'Admin123',
          'Letmein123',
          'Qwerty123',
          'Monkey123',
          'Football1',
          'Baseball1',
          'Basketball1',
          'Sunshine1',
        ];

        for (final password in commonPasswords) {
          // Act
          final result = Password.validate(password);

          // Assert
          expect(
            result.isFailure,
            isTrue,
            reason: 'Password "$password" should be rejected as too common',
          );
          expect(
            result.failureOrNull?.userMessage,
            contains('Password is too common'),
            reason: 'Password "$password" should have common password error',
          );
        }
      });

      test('should validate various strong password formats', () {
        // Arrange
        final strongPasswords = [
          'MySecure123',
          'P@ssw0rd123',
          'StrongPass1',
          'ValidPass99',
          'TestPassword1',
          'SecureTest123',
          'MyPassword1',
          'AppPassword9',
        ];

        for (final password in strongPasswords) {
          // Act
          final result = Password.validate(password);

          // Assert
          expect(
            result.isSuccess,
            isTrue,
            reason: 'Password "$password" should be valid',
          );
          expect(result.dataOrNull?.value, equals(password));
        }
      });
    });

    group('Password Strength Analysis', () {
      test('should return empty strength for empty password', () {
        // Arrange
        const emptyPassword = '';

        // Act
        final strength = Password.checkStrength(emptyPassword);

        // Assert
        expect(strength, equals(PasswordStrength.empty));
        expect(strength.description, contains('Password is required'));
      });

      test('should return tooShort strength for short password', () {
        // Arrange
        const shortPassword = 'Pass1';

        // Act
        final strength = Password.checkStrength(shortPassword);

        // Assert
        expect(strength, equals(PasswordStrength.tooShort));
        expect(strength.description, contains('Password is too short'));
      });

      test(
        'should return weak strength for password with few criteria met',
        () {
          // Arrange
          const weakPassword = 'password';

          // Act
          final strength = Password.checkStrength(weakPassword);

          // Assert
          expect(strength, equals(PasswordStrength.weak));
          expect(strength.description, equals('Weak password'));
        },
      );

      test(
        'should return fair strength for password with some criteria met',
        () {
          // Arrange
          const fairPassword = 'Password';

          // Act
          final strength = Password.checkStrength(fairPassword);

          // Assert
          expect(strength, equals(PasswordStrength.fair));
          expect(strength.description, equals('Fair password'));
        },
      );

      test(
        'should return good strength for password with most criteria met',
        () {
          // Arrange
          const goodPassword = 'Password1';

          // Act
          final strength = Password.checkStrength(goodPassword);

          // Assert
          expect(strength, equals(PasswordStrength.good));
          expect(strength.description, equals('Good password'));
        },
      );

      test(
        'should return strong strength for password with all criteria met',
        () {
          // Arrange
          const strongPassword = 'Password1!';

          // Act
          final strength = Password.checkStrength(strongPassword);

          // Assert
          expect(strength, equals(PasswordStrength.strong));
          expect(strength.description, equals('Strong password'));
        },
      );

      test('should provide color indicators for different strength levels', () {
        // Arrange & Act & Assert
        expect(PasswordStrength.empty.colorIndicator, equals('#FF0000'));
        expect(PasswordStrength.tooShort.colorIndicator, equals('#FF0000'));
        expect(PasswordStrength.weak.colorIndicator, equals('#FF6600'));
        expect(PasswordStrength.fair.colorIndicator, equals('#FFCC00'));
        expect(PasswordStrength.good.colorIndicator, equals('#66CC00'));
        expect(PasswordStrength.strong.colorIndicator, equals('#00CC00'));
      });

      test('should check if password meets minimum requirements', () {
        // Act & Assert
        expect(PasswordStrength.empty.meetsRequirements, isFalse);
        expect(PasswordStrength.tooShort.meetsRequirements, isFalse);
        expect(PasswordStrength.weak.meetsRequirements, isFalse);
        expect(PasswordStrength.fair.meetsRequirements, isTrue);
        expect(PasswordStrength.good.meetsRequirements, isTrue);
        expect(PasswordStrength.strong.meetsRequirements, isTrue);
      });
    });

    group('Password Factory Methods', () {
      test('should create password using constructor with valid input', () {
        // Arrange & Act
        final password = Password('ValidPass123');

        // Assert
        expect(password.value, equals('ValidPass123'));
      });

      test(
        'should throw ArgumentError when creating password with invalid input',
        () {
          // Arrange & Act & Assert
          expect(() => Password('weak'), throwsA(isA<ArgumentError>()));
        },
      );

      test('should return null for invalid password using tryCreate', () {
        // Arrange
        const invalidPassword = 'weak';

        // Act
        final result = Password.tryCreate(invalidPassword);

        // Assert
        expect(result, isNull);
      });

      test(
        'should return password object for valid password using tryCreate',
        () {
          // Arrange
          const validPassword = 'ValidPass123';

          // Act
          final result = Password.tryCreate(validPassword);

          // Assert
          expect(result, isNotNull);
          expect(result?.value, equals('ValidPass123'));
        },
      );
    });

    group('Password Extension Methods', () {
      test('should get strength from password instance', () {
        // Arrange
        final password = Password('StrongPass123!');

        // Act
        final strength = password.strength;

        // Assert
        expect(strength, equals(PasswordStrength.strong));
      });

      test('should check if password is strong enough', () {
        // Arrange
        final strongPassword = Password('GoodPass123');
        final veryStrongPassword = Password('StrongPass123!');

        // Act & Assert
        expect(strongPassword.isStrongEnough, isTrue);
        expect(veryStrongPassword.isStrongEnough, isTrue);
      });
    });

    group('Password Edge Cases for Registration Flow', () {
      test('should handle password with special characters', () {
        // Arrange
        const specialCharPassword = 'MyPass123!@#';

        // Act
        final result = Password.validate(specialCharPassword);

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle password with spaces', () {
        // Arrange
        const passwordWithSpaces = 'My Pass 123';

        // Act
        final result = Password.validate(passwordWithSpaces);

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle password with unicode characters', () {
        // Arrange
        const unicodePassword = 'MyPäss123';

        // Act
        final result = Password.validate(unicodePassword);

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should detect common password variations are still weak', () {
        // Arrange
        final variations = [
          'Password', // Common variation
          'PASSWORD', // All caps
          'password1', // With number but still common base
        ];

        for (final password in variations) {
          // Act
          final result = Password.validate(password);

          // Assert - These should fail due to missing requirements or being too common
          expect(
            result.isFailure,
            isTrue,
            reason: 'Password "$password" should fail validation',
          );
        }
      });

      test('should pass validation for minimum valid password', () {
        // Arrange - Meets all minimum requirements: 8+ chars, uppercase, lowercase, number
        const minValidPassword = 'Password1';

        // Act
        final result = Password.validate(minValidPassword);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.strength, equals(PasswordStrength.good));
      });
    });
  });
}
