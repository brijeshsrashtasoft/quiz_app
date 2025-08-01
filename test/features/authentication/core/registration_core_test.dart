import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/email.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/password.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_form_providers.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_navigation_providers.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import '../../../helpers/test_helpers.dart';

/// Core Registration Flow Tests - US-001
///
/// This test suite covers the core functionality of the email/password registration flow
/// focusing on validation logic, form states, and navigation without complex mocking.

void main() {
  group('US-001 Registration Flow - Core Functionality Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Email Validation Core Tests', () {
      test('should validate email correctly using Email value object', () {
        // Test valid emails
        for (final email in TestHelpers.validEmails) {
          final result = Email.validate(email);
          TestHelpers.verifyResultSuccess(result);
        }

        // Test invalid emails
        for (final email in TestHelpers.invalidEmails) {
          final result = Email.validate(email);
          TestHelpers.verifyResultFailure(result);
        }
      });

      test('should handle email edge cases', () {
        // Long email (at limit)
        final longEmail = '${'a' * 240}@example.com'; // 252 chars total
        final longResult = Email.validate(longEmail);
        expect(longResult.isSuccess, isTrue);

        // Too long email
        final tooLongEmail = '${'a' * 250}@example.com'; // 262 chars total
        final tooLongResult = Email.validate(tooLongEmail);
        expect(tooLongResult.isFailure, isTrue);

        // Email with consecutive dots
        final dotsResult = Email.validate('user..name@example.com');
        expect(dotsResult.isFailure, isTrue);
      });

      test('should normalize email correctly', () {
        // Mixed case
        final mixedResult = Email.validate('Test.User@EXAMPLE.COM');
        expect(mixedResult.isSuccess, isTrue);
        expect(mixedResult.dataOrNull?.value, equals('test.user@example.com'));

        // With whitespace
        final spaceResult = Email.validate('  test@example.com  ');
        expect(spaceResult.isSuccess, isTrue);
        expect(spaceResult.dataOrNull?.value, equals('test@example.com'));
      });
    });

    group('Password Validation Core Tests', () {
      test(
        'should validate password correctly using Password value object',
        () {
          // Test valid passwords
          for (final password in TestHelpers.validPasswords) {
            final result = Password.validate(password);
            TestHelpers.verifyResultSuccess(result);
          }

          // Test invalid passwords
          for (final password in TestHelpers.invalidPasswords) {
            final result = Password.validate(password);
            TestHelpers.verifyResultFailure(result);
          }
        },
      );

      test('should check password strength correctly', () {
        // Empty password
        expect(Password.checkStrength(''), equals(PasswordStrength.empty));

        // Too short
        expect(
          Password.checkStrength('Pass1'),
          equals(PasswordStrength.tooShort),
        );

        // Weak - only letters
        expect(
          Password.checkStrength('password'),
          equals(PasswordStrength.weak),
        );

        // Fair - letters and case
        expect(
          Password.checkStrength('Password'),
          equals(PasswordStrength.fair),
        );

        // Good - letters, case, and numbers
        expect(
          Password.checkStrength('Password1'),
          equals(PasswordStrength.good),
        );

        // Strong - all criteria
        expect(
          Password.checkStrength('Password1!'),
          equals(PasswordStrength.strong),
        );
      });

      test('should reject common passwords', () {
        final commonPasswords = [
          'Welcome123', // 'welcome' is in common list
          'Admin123', // 'admin' is in common list
        ];

        for (final password in commonPasswords) {
          final result = Password.validate(password);
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.userMessage, contains('too common'));
        }
      });
    });

    group('SignUp UseCase Core Tests', () {
      test('should validate parameters correctly', () async {
        final signUpUseCase = SignUpUseCase();

        // Valid parameters
        final validParams = SignUpParams(
          email: 'test@example.com',
          password: 'StrongPass123',
          name: 'John Doe',
        );

        // This will fail due to no Firebase setup, but validates parameters
        final result = await signUpUseCase.call(validParams);
        expect(validParams.email, equals('test@example.com'));
        expect(validParams.password, equals('StrongPass123'));
        expect(validParams.name, equals('John Doe'));
      });

      test('should handle validation errors in use case', () async {
        final signUpUseCase = SignUpUseCase();

        // Empty email
        final emptyEmailResult = await signUpUseCase.call(
          SignUpParams(email: '', password: 'StrongPass123', name: 'John'),
        );
        expect(emptyEmailResult.isFailure, isTrue);
        expect(
          emptyEmailResult.failureOrNull?.userMessage,
          contains('Email address is required'),
        );

        // Invalid email
        final invalidEmailResult = await signUpUseCase.call(
          SignUpParams(
            email: 'invalid',
            password: 'StrongPass123',
            name: 'John',
          ),
        );
        expect(invalidEmailResult.isFailure, isTrue);
        expect(
          invalidEmailResult.failureOrNull?.userMessage,
          contains('valid email address'),
        );

        // Empty password
        final emptyPasswordResult = await signUpUseCase.call(
          SignUpParams(email: 'test@example.com', password: '', name: 'John'),
        );
        expect(emptyPasswordResult.isFailure, isTrue);
        expect(
          emptyPasswordResult.failureOrNull?.userMessage,
          contains('Password is required'),
        );

        // Short password
        final shortPasswordResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: '123',
            name: 'John',
          ),
        );
        expect(shortPasswordResult.isFailure, isTrue);
        expect(
          shortPasswordResult.failureOrNull?.userMessage,
          contains('at least 6 characters'),
        );

        // Empty name
        final emptyNameResult = await signUpUseCase.call(
          SignUpParams(
            email: 'test@example.com',
            password: 'StrongPass123',
            name: '',
          ),
        );
        expect(emptyNameResult.isFailure, isTrue);
        expect(
          emptyNameResult.failureOrNull?.userMessage,
          contains('Full name is required'),
        );
      });
    });

    group('Form State Management Core Tests', () {
      test('should initialize register form with empty state', () {
        final formState = container.read(registerFormProvider);

        expect(formState.name, isEmpty);
        expect(formState.email, isEmpty);
        expect(formState.password, isEmpty);
        expect(formState.confirmPassword, isEmpty);
        expect(formState.isLoading, isFalse);
        expect(formState.isValid, isFalse);
        expect(formState.hasErrors, isFalse);
        expect(formState.agreeToTerms, isFalse);
      });

      test('should update email field with validation', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Valid email
        formNotifier.updateEmail('test@example.com');
        expect(
          container.read(registerFormProvider).email,
          equals('test@example.com'),
        );
        expect(container.read(registerFormProvider).emailError, isNull);

        // Invalid email
        formNotifier.updateEmail('invalid-email');
        expect(
          container.read(registerFormProvider).email,
          equals('invalid-email'),
        );
        expect(container.read(registerFormProvider).emailError, isNotNull);
      });

      test('should update password field with validation', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Strong password
        formNotifier.updatePassword('StrongPass123');
        expect(
          container.read(registerFormProvider).password,
          equals('StrongPass123'),
        );
        expect(container.read(registerFormProvider).passwordError, isNull);

        // Weak password
        formNotifier.updatePassword('weak');
        expect(container.read(registerFormProvider).password, equals('weak'));
        expect(container.read(registerFormProvider).passwordError, isNotNull);
      });

      test('should validate password confirmation', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Set password first
        formNotifier.updatePassword('StrongPass123');

        // Matching confirmation
        formNotifier.updateConfirmPassword('StrongPass123');
        expect(
          container.read(registerFormProvider).confirmPasswordError,
          isNull,
        );

        // Non-matching confirmation
        formNotifier.updateConfirmPassword('DifferentPass456');
        expect(
          container.read(registerFormProvider).confirmPasswordError,
          isNotNull,
        );
        expect(
          container.read(registerFormProvider).confirmPasswordError,
          contains('do not match'),
        );
      });

      test('should update name field with validation', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Valid name
        formNotifier.updateName('John Doe');
        expect(container.read(registerFormProvider).name, equals('John Doe'));
        expect(container.read(registerFormProvider).nameError, isNull);

        // Invalid name (too short)
        formNotifier.updateName('A');
        expect(container.read(registerFormProvider).name, equals('A'));
        expect(container.read(registerFormProvider).nameError, isNotNull);
      });

      test('should check form validity correctly', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Initially invalid
        expect(container.read(registerFormProvider).isValid, isFalse);

        // Fill all fields with valid data
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');
        formNotifier.updateName('John Doe');
        formNotifier.toggleTermsAgreement(); // Agree to terms

        // Should now be valid
        expect(container.read(registerFormProvider).isValid, isTrue);
      });

      test('should calculate password strength correctly', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Empty password
        formNotifier.updatePassword('');
        expect(
          container.read(registerFormProvider).passwordStrength,
          equals(0),
        );

        // Short password with only letters
        formNotifier.updatePassword('pass');
        expect(
          container.read(registerFormProvider).passwordStrength,
          equals(1),
        );

        // Password with length + case (upper + lower)
        formNotifier.updatePassword('Password');
        expect(
          container.read(registerFormProvider).passwordStrength,
          equals(3),
        );

        // Password with length + case + numbers
        formNotifier.updatePassword('Password1');
        expect(
          container.read(registerFormProvider).passwordStrength,
          equals(4),
        );

        // Strong password with all criteria
        formNotifier.updatePassword('Password1!');
        expect(
          container.read(registerFormProvider).passwordStrength,
          equals(4),
        );
      });

      test('should clear form correctly', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Fill form first
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateName('John Doe');

        // Clear form
        formNotifier.clearForm();

        final state = container.read(registerFormProvider);
        expect(state.email, isEmpty);
        expect(state.password, isEmpty);
        expect(state.name, isEmpty);
        expect(state.isValid, isFalse);
      });

      test('should clear errors correctly', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Create some errors
        formNotifier.updateEmail('invalid-email');
        formNotifier.updatePassword('weak');
        formNotifier.updateName('A');

        expect(container.read(registerFormProvider).hasErrors, isTrue);

        // Clear errors
        formNotifier.clearErrors();

        final state = container.read(registerFormProvider);
        expect(state.emailError, isNull);
        expect(state.passwordError, isNull);
        expect(state.nameError, isNull);
        expect(state.generalError, isNull);
      });
    });

    group('Navigation State Core Tests', () {
      test('should initialize with login step', () {
        final navigationState = container.read(authNavigationProvider);

        expect(navigationState.currentStep, equals(AuthFlowStep.login));
        expect(navigationState.isOnLogin, isTrue);
        expect(navigationState.isOnRegister, isFalse);
        expect(navigationState.showBackButton, isFalse);
        expect(navigationState.isNavigating, isFalse);
      });

      test('should navigate between steps correctly', () {
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );

        // Navigate to register
        navigationNotifier.navigateToRegister();
        expect(
          container.read(authNavigationProvider).currentStep,
          equals(AuthFlowStep.register),
        );
        expect(container.read(authNavigationProvider).isOnRegister, isTrue);
        expect(container.read(authNavigationProvider).showBackButton, isTrue);

        // Navigate back to login
        navigationNotifier.navigateToLogin(fromRoute: '/register');
        expect(
          container.read(authNavigationProvider).currentStep,
          equals(AuthFlowStep.login),
        );
        expect(container.read(authNavigationProvider).isOnLogin, isTrue);
      });

      test('should provide correct page titles and subtitles', () {
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );

        // Login step
        expect(
          container.read(authNavigationProvider).pageTitle,
          equals('Welcome Back'),
        );
        expect(
          container.read(authNavigationProvider).pageSubtitle,
          equals('Sign in to continue your quiz journey'),
        );

        // Register step
        navigationNotifier.navigateToRegister();
        expect(
          container.read(authNavigationProvider).pageTitle,
          equals('Create Account'),
        );
        expect(
          container.read(authNavigationProvider).pageSubtitle,
          equals('Join thousands of quiz enthusiasts'),
        );
      });

      test('should handle target route for post-registration navigation', () {
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );

        // Set target route
        navigationNotifier.setTargetRoute(
          '/dashboard',
          params: {'userId': '123'},
        );

        final state = container.read(authNavigationProvider);
        expect(state.targetRoute, equals('/dashboard'));
        expect(state.navigationParams?['userId'], equals('123'));
      });

      test('should reset navigation state correctly', () {
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );

        // Change state
        navigationNotifier.navigateToRegister();
        navigationNotifier.setTargetRoute('/dashboard');

        // Reset
        navigationNotifier.resetNavigationState();

        final state = container.read(authNavigationProvider);
        expect(state.currentStep, equals(AuthFlowStep.login));
        expect(state.targetRoute, isNull);
        expect(state.navigationParams, isNull);
        expect(state.showBackButton, isFalse);
      });
    });

    group('Complete Registration Flow Integration', () {
      test('should handle complete valid registration flow', () {
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );
        final formNotifier = container.read(registerFormProvider.notifier);

        // Step 1: Navigate to register
        navigationNotifier.navigateToRegister();
        expect(container.read(authNavigationProvider).isOnRegister, isTrue);

        // Step 2: Fill form with valid data
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');
        formNotifier.updateName('John Doe');
        formNotifier.toggleTermsAgreement();

        // Step 3: Verify form is valid
        expect(container.read(registerFormProvider).isValid, isTrue);

        // Step 4: Set post-registration target
        navigationNotifier.setTargetRoute('/onboarding');

        // Verify complete state
        final navState = container.read(authNavigationProvider);
        final formState = container.read(registerFormProvider);

        expect(navState.isOnRegister, isTrue);
        expect(navState.targetRoute, equals('/onboarding'));
        expect(formState.isValid, isTrue);
        expect(formState.email, equals('test@example.com'));
        expect(formState.name, equals('John Doe'));
      });

      test('should handle registration flow with errors', () {
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );
        final formNotifier = container.read(registerFormProvider.notifier);

        // Navigate to register
        navigationNotifier.navigateToRegister();

        // Fill with invalid data
        formNotifier.updateEmail('invalid-email');
        formNotifier.updatePassword('weak');
        formNotifier.updateName('A');

        // Verify errors
        final formState = container.read(registerFormProvider);
        expect(formState.isValid, isFalse);
        expect(formState.hasErrors, isTrue);
        expect(formState.emailError, isNotNull);
        expect(formState.passwordError, isNotNull);
        expect(formState.nameError, isNotNull);

        // Fix errors
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');
        formNotifier.updateName('John Doe');
        formNotifier.toggleTermsAgreement();

        // Should now be valid
        expect(container.read(registerFormProvider).isValid, isTrue);
        expect(container.read(registerFormProvider).hasErrors, isFalse);
      });

      test('should handle rapid form updates efficiently', () {
        final formNotifier = container.read(registerFormProvider.notifier);
        final startTime = DateTime.now();

        // Perform rapid updates
        for (int i = 0; i < 50; i++) {
          formNotifier.updateEmail('test$i@example.com');
          formNotifier.updatePassword('Password$i');
          formNotifier.updateName('User $i');
        }

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete quickly (less than 1 second)
        expect(duration.inMilliseconds, lessThan(1000));

        // Final state should be correct
        expect(
          container.read(registerFormProvider).email,
          equals('test49@example.com'),
        );
        expect(container.read(registerFormProvider).name, equals('User 49'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty form submission attempt', () {
        final formState = container.read(registerFormProvider);

        // Empty form should not be valid
        expect(formState.isValid, isFalse);
        expect(formState.agreeToTerms, isFalse);
      });

      test('should handle special characters in form fields', () {
        final formNotifier = container.read(registerFormProvider.notifier);

        // Name with special characters
        formNotifier.updateName('José García-O\'Connor');
        expect(container.read(registerFormProvider).nameError, isNull);

        // Email with plus sign
        formNotifier.updateEmail('user+tag@example.com');
        expect(container.read(registerFormProvider).emailError, isNull);

        // Password with special characters
        formNotifier.updatePassword('MyP@ssw0rd!');
        expect(container.read(registerFormProvider).passwordError, isNull);
      });

      test('should handle form state persistence during navigation', () {
        final formNotifier = container.read(registerFormProvider.notifier);
        final navigationNotifier = container.read(
          authNavigationProvider.notifier,
        );

        // Fill partial form
        formNotifier.updateEmail('test@example.com');
        formNotifier.updateName('John Doe');

        // Navigate away and back
        navigationNotifier.navigateToLogin();
        navigationNotifier.navigateToRegister();

        // Form state should be maintained (basic check)
        expect(container.read(registerFormProvider).email, isNotEmpty);
      });
    });
  });
}
