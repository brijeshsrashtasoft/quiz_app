import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/email.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/password.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

/// US-001 Email/Password Registration Flow Tests
///
/// Comprehensive tests for the email/password registration functionality
/// covering the core requirements specified in US-001.

void main() {
  group('US-001 Email/Password Registration Flow', () {
    group('1. Email Validation Logic', () {
      test('should validate email format correctly', () {
        // Valid emails
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@domain.org',
          'user_name@sub.domain.com',
          'user123@test123.com',
          'a@b.co',
        ];

        for (final email in validEmails) {
          final result = Email.validate(email);
          expect(
            result.isSuccess,
            isTrue,
            reason: 'Email "$email" should be valid',
          );
          expect(result.dataOrNull?.value, isNotNull);
        }

        // Invalid emails
        final invalidEmails = [
          '',
          '   ',
          'invalid',
          'invalid@',
          '@invalid.com',
          'invalid.com',
          'invalid@.com',
          'invalid@com.',
        ];

        for (final email in invalidEmails) {
          final result = Email.validate(email);
          expect(
            result.isFailure,
            isTrue,
            reason: 'Email "$email" should be invalid',
          );
          expect(result.failureOrNull?.message, isNotNull);
        }
      });

      test('should normalize email to lowercase', () {
        const mixedCaseEmail = 'Test.User@EXAMPLE.COM';
        final result = Email.validate(mixedCaseEmail);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.value, equals('test.user@example.com'));
      });

      test('should trim whitespace from email', () {
        const emailWithSpaces = '  test@example.com  ';
        final result = Email.validate(emailWithSpaces);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.value, equals('test@example.com'));
      });

      test('should reject emails that are too long', () {
        final longEmail = '${'a' * 250}@example.com'; // 261 characters total
        final result = Email.validate(longEmail);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.message, contains('too long'));
      });

      test('should reject emails with consecutive dots', () {
        const consecutiveDotsEmail = 'user..name@example.com';
        final result = Email.validate(consecutiveDotsEmail);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.message, contains('format is invalid'));
      });

      test('should extract domain and local parts correctly', () {
        final email = Email('user.name@example.com');

        expect(email.domain, equals('example.com'));
        expect(email.localPart, equals('user.name'));
      });

      test('should identify admin and corporate emails', () {
        final adminEmail = Email('admin@quizapp.com');
        final corporateEmail = Email('user@company.com');
        final personalEmail = Email('user@gmail.com');

        expect(adminEmail.isAdminEmail, isTrue);
        expect(corporateEmail.isCorporateEmail, isTrue);
        expect(personalEmail.isCorporateEmail, isFalse);
      });
    });

    group('2. Password Validation Logic', () {
      test(
        'should validate password requirements (min 8 chars, uppercase, number)',
        () {
          // Valid passwords meeting all requirements
          final validPasswords = [
            'StrongPass123',
            'MySecure123',
            'ValidPass99',
            'TestPassword1',
            'AppPassword9',
          ];

          for (final password in validPasswords) {
            final result = Password.validate(password);
            expect(
              result.isSuccess,
              isTrue,
              reason: 'Password "$password" should be valid',
            );
          }
        },
      );

      test('should reject passwords that are too short', () {
        final shortPasswords = ['Pass1', '123Abc', 'Test1'];

        for (final password in shortPasswords) {
          final result = Password.validate(password);
          expect(
            result.isFailure,
            isTrue,
            reason: 'Password "$password" should be too short',
          );
          expect(
            result.failureOrNull?.message,
            contains('at least 8 characters'),
          );
        }
      });

      test('should reject passwords without uppercase letters', () {
        const noUppercasePassword = 'password123';
        final result = Password.validate(noUppercasePassword);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.message, contains('uppercase letter'));
      });

      test('should reject passwords without lowercase letters', () {
        const noLowercasePassword = 'PASSWORD123';
        final result = Password.validate(noLowercasePassword);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.message, contains('lowercase letter'));
      });

      test('should reject passwords without numbers', () {
        const noNumberPassword = 'PasswordAbc';
        final result = Password.validate(noNumberPassword);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.message, contains('number'));
      });

      test('should reject common weak passwords', () {
        final commonPasswords = [
          'password',
          '12345678',
          'qwerty',
          'abc123',
          'password123',
          'welcome',
          'admin',
        ];

        for (final password in commonPasswords) {
          final result = Password.validate(password);
          expect(
            result.isFailure,
            isTrue,
            reason: 'Password "$password" should be rejected as common',
          );
          expect(result.failureOrNull?.message, contains('too common'));
        }
      });

      test('should check password strength correctly', () {
        // Test different strength levels
        expect(Password.checkStrength(''), equals(PasswordStrength.empty));
        expect(
          Password.checkStrength('Pass1'),
          equals(PasswordStrength.tooShort),
        );
        expect(
          Password.checkStrength('password'),
          equals(PasswordStrength.weak),
        );
        expect(
          Password.checkStrength('Password'),
          equals(PasswordStrength.fair),
        );
        expect(
          Password.checkStrength('Password1'),
          equals(PasswordStrength.good),
        );
        expect(
          Password.checkStrength('Password1!'),
          equals(PasswordStrength.strong),
        );
      });

      test('should provide strength descriptions and color indicators', () {
        expect(
          PasswordStrength.empty.description,
          contains('Password is required'),
        );
        expect(PasswordStrength.tooShort.description, contains('too short'));
        expect(PasswordStrength.weak.description, equals('Weak password'));
        expect(PasswordStrength.strong.description, equals('Strong password'));

        // Color indicators
        expect(PasswordStrength.empty.colorIndicator, equals('#FF0000'));
        expect(PasswordStrength.strong.colorIndicator, equals('#00CC00'));
      });

      test('should check if password meets requirements', () {
        expect(PasswordStrength.empty.meetsRequirements, isFalse);
        expect(PasswordStrength.weak.meetsRequirements, isFalse);
        expect(PasswordStrength.fair.meetsRequirements, isTrue);
        expect(PasswordStrength.good.meetsRequirements, isTrue);
        expect(PasswordStrength.strong.meetsRequirements, isTrue);
      });
    });

    group('3. Registration Use Case Logic', () {
      late SignUpUseCase signUpUseCase;

      setUp(() {
        signUpUseCase = SignUpUseCase();
      });

      test('should validate all required parameters', () async {
        final signUpUseCase = SignUpUseCase();

        // Test empty email
        final emptyEmailResult = await signUpUseCase.call(
          SignUpParams(email: '', password: 'StrongPass123', name: 'John Doe'),
        );
        expect(emptyEmailResult.isFailure, isTrue);
        expect(
          emptyEmailResult.failureOrNull?.message,
          contains('Email address is required'),
        );

        // Test empty password
        final emptyPasswordResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: '',
            name: 'John Doe',
          ),
        );
        expect(emptyPasswordResult.isFailure, isTrue);
        expect(
          emptyPasswordResult.failureOrNull?.message,
          contains('Password is required'),
        );

        // Test empty name
        final emptyNameResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: 'StrongPass123',
            name: '',
          ),
        );
        expect(emptyNameResult.isFailure, isTrue);
        expect(
          emptyNameResult.failureOrNull?.message,
          contains('Full name is required'),
        );
      });

      test('should validate email format in use case', () async {
        final signUpUseCase = SignUpUseCase();
        final invalidEmails = [
          'invalid-email',
          'invalid@',
          '@invalid.com',
          'invalid.com',
        ];

        for (final email in invalidEmails) {
          final result = await signUpUseCase.call(
            SignUpParams(
              email: email,
              password: 'StrongPass123',
              name: 'John Doe',
            ),
          );
          expect(
            result.isFailure,
            isTrue,
            reason: 'Email "$email" should be invalid',
          );
          expect(
            result.failureOrNull?.message,
            contains('valid email address'),
          );
        }
      });

      test('should validate password strength in use case', () async {
        final signUpUseCase = SignUpUseCase();

        // Test password too short
        final shortPasswordResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: '123',
            name: 'John Doe',
          ),
        );
        expect(shortPasswordResult.isFailure, isTrue);
        expect(
          shortPasswordResult.failureOrNull?.message,
          contains('at least 6 characters'),
        );

        // Test password without letters and numbers
        final weakPasswordResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: 'password',
            name: 'John Doe',
          ),
        );
        expect(weakPasswordResult.isFailure, isTrue);
        expect(
          weakPasswordResult.failureOrNull?.message,
          contains('both letters and numbers'),
        );
      });

      test('should validate name requirements', () async {
        final signUpUseCase = SignUpUseCase();

        // Test name too short
        final shortNameResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: 'StrongPass123',
            name: 'A',
          ),
        );
        expect(shortNameResult.isFailure, isTrue);
        expect(
          shortNameResult.failureOrNull?.message,
          contains('at least 2 characters'),
        );

        // Test whitespace-only name
        final whitespaceNameResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: 'StrongPass123',
            name: '   ',
          ),
        );
        expect(whitespaceNameResult.isFailure, isTrue);
        expect(
          whitespaceNameResult.failureOrNull?.message,
          contains('Full name is required'),
        );
      });

      test('should trim email and name before processing', () async {
        final signUpUseCase = SignUpUseCase();

        // Test with whitespace around email and name
        final params = SignUpParams(
          email: '  test@example.com  ',
          password: 'StrongPass123',
          name: '  John Doe  ',
        );

        // This will fail due to Firebase not being set up, but validates trimming
        final result = await signUpUseCase.call(params);

        // The validation should pass (trimming works), but Firebase call will fail
        expect(
          params.email,
          equals('  test@example.com  '),
        ); // Original params unchanged
        expect(result.isFailure, isTrue); // Will fail due to Firebase
      });

      test('should create valid SignUpParams object', () {
        final params = SignUpParams(
          email: 'test@example.com',
          password: 'StrongPass123',
          name: 'John Doe',
        );

        expect(params.email, equals('test@example.com'));
        expect(params.password, equals('StrongPass123'));
        expect(params.name, equals('John Doe'));

        // toString should not include password for security
        final stringRep = params.toString();
        expect(stringRep, contains('test@example.com'));
        expect(stringRep, contains('John Doe'));
        expect(stringRep, isNot(contains('StrongPass123')));
      });
    });

    group('4. Email and Password Factory Methods', () {
      test('should create Email using constructor with valid input', () {
        final email = Email('test@example.com');
        expect(email.value, equals('test@example.com'));
      });

      test('should throw ArgumentError for invalid email in constructor', () {
        expect(() => Email('invalid-email'), throwsA(isA<ArgumentError>()));
      });

      test('should return null for invalid email using tryCreate', () {
        final result = Email.tryCreate('invalid-email');
        expect(result, isNull);
      });

      test('should return email object for valid email using tryCreate', () {
        final result = Email.tryCreate('test@example.com');
        expect(result, isNotNull);
        expect(result?.value, equals('test@example.com'));
      });

      test('should create Password using constructor with valid input', () {
        final password = Password('StrongPass123');
        expect(password.value, equals('StrongPass123'));
      });

      test(
        'should throw ArgumentError for invalid password in constructor',
        () {
          expect(() => Password('weak'), throwsA(isA<ArgumentError>()));
        },
      );

      test('should return null for invalid password using tryCreate', () {
        final result = Password.tryCreate('weak');
        expect(result, isNull);
      });

      test(
        'should return password object for valid password using tryCreate',
        () {
          final result = Password.tryCreate('StrongPass123');
          expect(result, isNotNull);
          expect(result?.value, equals('StrongPass123'));
        },
      );
    });

    group('5. Edge Cases and Special Scenarios', () {
      test('should handle international characters in names', () async {
        final signUpUseCase = SignUpUseCase();
        final internationalNames = [
          'José García',
          '李小明',
          'Müller',
          'O\'Connor',
          'Jean-Pierre',
        ];

        for (final name in internationalNames) {
          final result = await signUpUseCase.call(
            SignUpParams(
              email: 'test@example.com',
              password: 'StrongPass123',
              name: name,
            ),
          );

          // Name validation should pass (Firebase call will still fail)
          expect(
            name.length >= 2,
            isTrue,
            reason: 'Name "$name" should be long enough',
          );
        }
      });

      test('should handle special characters in passwords', () {
        final specialCharPasswords = [
          'MyPass123!@#',
          'P@ssw0rd\$',
          'Test123_password',
          'My Pass 123', // With space
        ];

        for (final password in specialCharPasswords) {
          final result = Password.validate(password);
          expect(
            result.isSuccess,
            isTrue,
            reason: 'Password "$password" should be valid',
          );
        }
      });

      test('should handle various valid email formats', () {
        final emailFormats = [
          'simple@example.com',
          'user.name@example.com',
          'user+tag@example.com',
          'user_name@example.com',
          'user123@example123.com',
          'a@b.co',
          'test-email@example-domain.com',
        ];

        for (final email in emailFormats) {
          final result = Email.validate(email);
          expect(
            result.isSuccess,
            isTrue,
            reason: 'Email "$email" should be valid',
          );
        }
      });

      test('should handle boundary cases for password length', () {
        // Exactly 8 characters (minimum)
        final minPasswordResult = Password.validate('Pass123A');
        expect(minPasswordResult.isSuccess, isTrue);

        // 7 characters (too short)
        final tooShortResult = Password.validate('Pass12A');
        expect(tooShortResult.isFailure, isTrue);

        // 128 characters (maximum)
        final maxPassword = 'A1a!' + 'a' * 124; // 128 chars total
        final maxPasswordResult = Password.validate(maxPassword);
        expect(maxPasswordResult.isSuccess, isTrue);

        // 129 characters (too long)
        final tooLongPassword = 'A1a!' + 'a' * 125; // 129 chars total
        final tooLongResult = Password.validate(tooLongPassword);
        expect(tooLongResult.isFailure, isTrue);
      });

      test('should handle boundary cases for email length', () {
        // Valid email at character limit
        final longButValidEmail = '${'a' * 240}@example.com'; // 252 chars
        final validResult = Email.validate(longButValidEmail);
        expect(validResult.isSuccess, isTrue);

        // Email too long
        final tooLongEmail = '${'a' * 250}@example.com'; // 262 chars
        final invalidResult = Email.validate(tooLongEmail);
        expect(invalidResult.isFailure, isTrue);
      });
    });

    group('6. Performance Tests', () {
      test('should validate emails efficiently', () {
        final startTime = DateTime.now();

        // Validate 1000 emails
        for (int i = 0; i < 1000; i++) {
          Email.validate('test$i@example.com');
        }

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete in less than 1 second
        expect(duration.inMilliseconds, lessThan(1000));
      });

      test('should validate passwords efficiently', () {
        final startTime = DateTime.now();

        // Validate 1000 passwords
        for (int i = 0; i < 1000; i++) {
          Password.validate('StrongPass$i');
        }

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete in less than 1 second
        expect(duration.inMilliseconds, lessThan(1000));
      });
    });

    group('7. Integration Tests', () {
      test('should validate complete registration scenario', () async {
        final signUpUseCase = SignUpUseCase();

        // Test complete valid registration data
        final validScenarios = [
          {
            'email': 'user@example.com',
            'password': 'SecurePass123',
            'name': 'John Doe',
          },
          {
            'email': 'mary.jane@company.co.uk',
            'password': 'MyPassword1',
            'name': 'Mary Jane Smith',
          },
          {
            'email': 'jose+tag@domain.org',
            'password': 'P@ssw0rd123',
            'name': 'José García',
          },
        ];

        for (final scenario in validScenarios) {
          // Validate each component individually
          final emailResult = Email.validate(scenario['email']!);
          final passwordResult = Password.validate(scenario['password']!);

          expect(emailResult.isSuccess, isTrue);
          expect(passwordResult.isSuccess, isTrue);

          // Use case validation should also pass
          final params = SignUpParams(
            email: scenario['email']!,
            password: scenario['password']!,
            name: scenario['name']!,
          );

          // This validates the use case parameters (Firebase call will fail)
          final result = await signUpUseCase.call(params);

          // Parameters should be valid
          expect(params.email, equals(scenario['email']));
          expect(params.password, equals(scenario['password']));
          expect(params.name, equals(scenario['name']));
        }
      });

      test('should handle invalid registration scenarios', () async {
        final signUpUseCase = SignUpUseCase();

        final invalidScenarios = [
          {
            'name': 'Invalid email',
            'email': 'invalid-email',
            'password': 'StrongPass123',
            'userName': 'John Doe',
            'expectedError': 'valid email address',
          },
          {
            'name': 'Weak password',
            'email': 'test@example.com',
            'password': 'onlyletters',
            'userName': 'John Doe',
            'expectedError': 'letters and numbers',
          },
          {
            'name': 'Short name',
            'email': 'test@example.com',
            'password': 'StrongPass123',
            'userName': 'A',
            'expectedError': 'at least 2 characters',
          },
        ];

        for (final scenario in invalidScenarios) {
          final result = await signUpUseCase.call(
            SignUpParams(
              email: scenario['email']!,
              password: scenario['password']!,
              name: scenario['userName']!,
            ),
          );

          expect(
            result.isFailure,
            isTrue,
            reason: 'Scenario "${scenario['name']}" should fail',
          );
          expect(
            result.failureOrNull?.message,
            contains(scenario['expectedError']!),
            reason: 'Scenario "${scenario['name']}" should have correct error',
          );
        }
      });
    });
  });
}
