import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/email.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/password.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';

/// US-001 Registration Flow - Summary Test
///
/// This test suite validates that all core components of the email/password
/// registration flow are working correctly for US-001.

void main() {
  group('US-001 Registration Flow - Core Functionality Summary', () {
    test('✅ Email validation works correctly', () {
      // Valid email should succeed
      final validResult = Email.validate('test@example.com');
      expect(validResult.isSuccess, isTrue);
      expect(validResult.dataOrNull?.value, equals('test@example.com'));

      // Invalid email should fail
      final invalidResult = Email.validate('invalid-email');
      expect(invalidResult.isFailure, isTrue);
      expect(invalidResult.failureOrNull?.message, isNotNull);
    });

    test('✅ Password validation works correctly', () {
      // Strong password should succeed
      final strongResult = Password.validate('StrongPass123');
      expect(strongResult.isSuccess, isTrue);
      expect(strongResult.dataOrNull?.value, equals('StrongPass123'));

      // Weak password should fail
      final weakResult = Password.validate('weak');
      expect(weakResult.isFailure, isTrue);
      expect(weakResult.failureOrNull?.message, isNotNull);
    });

    test('✅ Password strength checking works correctly', () {
      expect(Password.checkStrength(''), equals(PasswordStrength.empty));
      expect(Password.checkStrength('weak'), equals(PasswordStrength.tooShort));
      expect(
        Password.checkStrength('StrongPass123'),
        equals(PasswordStrength.good),
      );
      expect(
        Password.checkStrength('StrongPass123!'),
        equals(PasswordStrength.strong),
      );
    });

    test('✅ SignUp use case validates parameters correctly', () async {
      final signUpUseCase = SignUpUseCase();

      // Valid parameters should pass validation (Firebase call will fail)
      final validParams = SignUpParams(
        email: 'test@example.com',
        password: 'StrongPass123',
        name: 'John Doe',
      );

      expect(validParams.email, equals('test@example.com'));
      expect(validParams.password, equals('StrongPass123'));
      expect(validParams.name, equals('John Doe'));

      // Invalid email should fail
      final invalidEmailResult = await signUpUseCase.call(
        SignUpParams(email: '', password: 'StrongPass123', name: 'John Doe'),
      );
      expect(invalidEmailResult.isFailure, isTrue);
      expect(
        invalidEmailResult.failureOrNull?.message,
        contains('Email address is required'),
      );

      // Invalid password should fail
      final invalidPasswordResult = await signUpUseCase.call(
        SignUpParams(email: 'test@example.com', password: '', name: 'John Doe'),
      );
      expect(invalidPasswordResult.isFailure, isTrue);
      expect(
        invalidPasswordResult.failureOrNull?.message,
        contains('Password is required'),
      );

      // Invalid name should fail
      final invalidNameResult = await signUpUseCase.call(
        SignUpParams(
          email: 'test@example.com',
          password: 'StrongPass123',
          name: '',
        ),
      );
      expect(invalidNameResult.isFailure, isTrue);
      expect(
        invalidNameResult.failureOrNull?.message,
        contains('Full name is required'),
      );
    });

    test('✅ Email normalization works correctly', () {
      // Should convert to lowercase
      final mixedCaseResult = Email.validate('Test@EXAMPLE.COM');
      expect(mixedCaseResult.isSuccess, isTrue);
      expect(mixedCaseResult.dataOrNull?.value, equals('test@example.com'));

      // Should trim whitespace
      final spacesResult = Email.validate('  test@example.com  ');
      expect(spacesResult.isSuccess, isTrue);
      expect(spacesResult.dataOrNull?.value, equals('test@example.com'));
    });

    test('✅ Password requirements are enforced', () {
      // Missing uppercase
      final noUppercase = Password.validate('password123');
      expect(noUppercase.isFailure, isTrue);
      expect(noUppercase.failureOrNull?.message, contains('uppercase letter'));

      // Missing lowercase
      final noLowercase = Password.validate('PASSWORD123');
      expect(noLowercase.isFailure, isTrue);
      expect(noLowercase.failureOrNull?.message, contains('lowercase letter'));

      // Missing number
      final noNumber = Password.validate('PasswordAbc');
      expect(noNumber.isFailure, isTrue);
      expect(noNumber.failureOrNull?.message, contains('number'));

      // Too short
      final tooShort = Password.validate('Pass1');
      expect(tooShort.isFailure, isTrue);
      expect(
        tooShort.failureOrNull?.message,
        contains('at least 8 characters'),
      );
    });

    test('✅ Common weak passwords are rejected', () {
      // Test actual common passwords from the implementation (matching common list exactly)
      final commonPasswords = ['Welcome123', 'Admin123', 'Letmein123'];

      for (final password in commonPasswords) {
        final result = Password.validate(password);
        expect(
          result.isFailure,
          isTrue,
          reason: 'Password "$password" should be rejected',
        );
        final failureMessage = result.failureOrNull?.message ?? '';
        expect(
          failureMessage.contains('too common'),
          isTrue,
          reason:
              'Password "$password" should fail for being too common, got: $failureMessage',
        );
      }
    });

    test('✅ Email factory methods work correctly', () {
      // Constructor with valid email
      final email = Email('test@example.com');
      expect(email.value, equals('test@example.com'));

      // Constructor with invalid email should throw
      expect(() => Email('invalid'), throwsA(isA<ArgumentError>()));

      // tryCreate with valid email
      final validTry = Email.tryCreate('test@example.com');
      expect(validTry, isNotNull);
      expect(validTry?.value, equals('test@example.com'));

      // tryCreate with invalid email
      final invalidTry = Email.tryCreate('invalid');
      expect(invalidTry, isNull);
    });

    test('✅ Password factory methods work correctly', () {
      // Constructor with valid password
      final password = Password('StrongPass123');
      expect(password.value, equals('StrongPass123'));

      // Constructor with invalid password should throw
      expect(() => Password('weak'), throwsA(isA<ArgumentError>()));

      // tryCreate with valid password
      final validTry = Password.tryCreate('StrongPass123');
      expect(validTry, isNotNull);
      expect(validTry?.value, equals('StrongPass123'));

      // tryCreate with invalid password
      final invalidTry = Password.tryCreate('weak');
      expect(invalidTry, isNull);
    });

    test('✅ Email domain and utility methods work', () {
      final email = Email('user.name@example.com');

      expect(email.domain, equals('example.com'));
      expect(email.localPart, equals('user.name'));
      expect(email.isFromDomain('example.com'), isTrue);
      expect(email.isFromDomain('other.com'), isFalse);
    });

    test('✅ Password strength indicators work', () {
      // Test strength descriptions
      expect(PasswordStrength.empty.description, contains('required'));
      expect(PasswordStrength.weak.description, equals('Weak password'));
      expect(PasswordStrength.strong.description, equals('Strong password'));

      // Test color indicators
      expect(PasswordStrength.empty.colorIndicator, equals('#FF0000'));
      expect(PasswordStrength.strong.colorIndicator, equals('#00CC00'));

      // Test requirements check
      expect(PasswordStrength.weak.meetsRequirements, isFalse);
      expect(PasswordStrength.good.meetsRequirements, isTrue);
      expect(PasswordStrength.strong.meetsRequirements, isTrue);
    });

    test('✅ Performance is acceptable for validation', () {
      final startTime = DateTime.now();

      // Validate 100 emails and passwords
      for (int i = 0; i < 100; i++) {
        Email.validate('test$i@example.com');
        Password.validate('Password$i');
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Should complete in reasonable time
      expect(duration.inMilliseconds, lessThan(1000));
    });
  });
}
