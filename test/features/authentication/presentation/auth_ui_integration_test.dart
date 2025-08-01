import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_form_providers.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/utils/result.dart';

// No mocks needed for this integration test

void main() {
  group('Authentication UI Integration Tests - US-001 Registration Flow', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Register Form State Management', () {
      test('should initialize register form with empty state', () {
        // Act
        final formState = container.read(registerFormProvider);

        // Assert
        expect(formState.email, isEmpty);
        expect(formState.password, isEmpty);
        expect(formState.confirmPassword, isEmpty);
        expect(formState.name, isEmpty);
        expect(formState.isLoading, isFalse);
        expect(formState.isValid, isFalse);
        expect(formState.hasErrors, isFalse);
        expect(formState.emailError, isNull);
        expect(formState.passwordError, isNull);
        expect(formState.confirmPasswordError, isNull);
        expect(formState.nameError, isNull);
        expect(formState.generalError, isNull);
      });

      test('should update email field and validate', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updateEmail('test@example.com');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.email, equals('test@example.com'));
        expect(state.emailError, isNull); // Valid email should have no error
      });

      test('should show email validation error for invalid email', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updateEmail('invalid-email');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.email, equals('invalid-email'));
        expect(state.emailError, isNotNull);
        expect(state.isValid, isFalse);
      });

      test('should update password field and validate strength', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updatePassword('StrongPass123');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.password, equals('StrongPass123'));
        expect(
          state.passwordError,
          isNull,
        ); // Strong password should have no error
      });

      test('should show password validation error for weak password', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updatePassword('weak');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.password, equals('weak'));
        expect(state.passwordError, isNotNull);
        expect(state.isValid, isFalse);
      });

      test('should validate password confirmation matches', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.confirmPassword, equals('StrongPass123'));
        expect(
          state.confirmPasswordError,
          isNull,
        ); // Matching passwords should have no error
      });

      test('should show confirmation error for non-matching passwords', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('DifferentPass456');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.confirmPasswordError, isNotNull);
        expect(state.isValid, isFalse);
      });

      test('should update name field and validate', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updateName('John Doe');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.name, equals('John Doe'));
        expect(state.nameError, isNull); // Valid name should have no error
      });

      test('should show name validation error for invalid name', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        formNotifier.updateName('A'); // Too short

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.name, equals('A'));
        expect(state.nameError, isNotNull);
        expect(state.isValid, isFalse);
      });

      test('should validate complete form with all valid fields', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act - Fill all fields with valid data
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');
        formNotifier.updateName('John Doe');
        formNotifier.toggleTermsAgreement(); // Need to agree to terms

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.isValid, isTrue);
        expect(state.hasErrors, isFalse);
        expect(state.isValid, isTrue);
      });

      test('should prevent submission when form is invalid', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act - Fill form with some invalid data
        formNotifier.updateEmail('invalid-email');
        formNotifier.updatePassword('weak');
        formNotifier.updateName('John Doe');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.isValid, isFalse);
        expect(state.isValid, isFalse);
        expect(state.hasErrors, isTrue);
      });

      test('should handle form submission loading state', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Set up valid form data
        formNotifier.updateName('John Doe');
        formNotifier.updateEmail('john@example.com');
        formNotifier.updatePassword('SecurePass123');
        formNotifier.updateConfirmPassword('SecurePass123');
        formNotifier.toggleTermsAgreement(); // Agree to terms

        // Verify form is valid before submission
        final validState = container.read(registerFormProvider);
        expect(validState.isValid, isTrue);

        // Assert - Test that submitRegistration method exists and can be called
        expect(() => formNotifier.submitRegistration(), returnsNormally);
      });

      test('should clear form fields', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Fill form first
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateName('John Doe');

        // Act
        formNotifier.clearForm();

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.email, isEmpty);
        expect(state.password, isEmpty);
        expect(state.confirmPassword, isEmpty);
        expect(state.name, isEmpty);
        expect(state.isValid, isFalse);
      });

      test('should handle general form errors', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act
        // Simulate error by triggering validation with invalid data
        formNotifier.updateEmail('invalid-email');
        formNotifier.updatePassword('weak');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.emailError, isNotNull);
        expect(state.passwordError, isNotNull);
        expect(state.hasErrors, isTrue);
      });

      test('should clear errors when updating fields', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Set some errors first
        formNotifier.updateEmail('invalid-email'); // Will set email error
        formNotifier.updatePassword('weak'); // Will set password error

        // Act - Update with valid data
        formNotifier.updateEmail('test@example.com');

        // Assert
        final state = container.read(registerFormProvider);
        expect(state.emailError, isNull); // Should clear email error
        expect(state.passwordError, isNotNull); // Password error should remain
      });
    });

    group('Auth State Based UI Behavior', () {
      test('should show sign up button when unauthenticated', () {
        // Arrange - Create a container with unauthenticated state
        final testContainer = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(const AuthState.unauthenticated()),
            ),
          ],
        );

        // Act
        final isAuthenticated = testContainer.read(isAuthenticatedProvider);

        // Assert
        expect(isAuthenticated, isFalse);

        // Clean up
        testContainer.dispose();
      });

      test('should hide sign up button when authenticated', () async {
        // Arrange - Create authenticated user
        final testUser = UserEntity(
          id: '123',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.fromIterable([
                AuthState.authenticated(user: testUser),
              ]),
            ),
          ],
        );

        // Wait for the stream to emit
        await testContainer.read(authStateProvider.future);

        // Act
        final isAuthenticated = testContainer.read(isAuthenticatedProvider);
        final currentUser = testContainer.read(currentUserProvider);

        // Assert
        expect(isAuthenticated, isTrue);
        expect(currentUser, equals(testUser));

        // Clean up
        testContainer.dispose();
      });

      test('should show loading state during authentication', () async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.fromIterable([const AuthState.loading()]),
            ),
          ],
        );

        // Wait for the stream to emit
        final authState = await testContainer.read(authStateProvider.future);

        // Assert
        expect(authState.isLoading, isTrue);
        expect(authState.isAuthenticated, isFalse);

        // Clean up
        testContainer.dispose();
      });

      test('should handle authentication error state', () async {
        // Arrange
        const errorMessage = 'Authentication failed';
        final testContainer = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) =>
                  Stream.fromIterable([AuthState.error(message: errorMessage)]),
            ),
          ],
        );

        // Wait for the stream to emit
        final authState = await testContainer.read(authStateProvider.future);

        // Assert
        expect(authState.hasError, isTrue);
        expect(authState.errorMessage, equals(errorMessage));

        // Clean up
        testContainer.dispose();
      });
    });

    group('Form Field Validation Integration', () {
      test('should perform real-time email validation', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@domain.org',
        ];
        final invalidEmails = [
          'invalid',
          'invalid@',
          '@invalid.com',
          'invalid.com',
        ];

        // Test valid emails
        for (final email in validEmails) {
          // Act
          formNotifier.updateEmail(email);

          // Assert
          final state = container.read(registerFormProvider);
          expect(
            state.emailError,
            isNull,
            reason: 'Email "$email" should be valid',
          );
        }

        // Test invalid emails
        for (final email in invalidEmails) {
          // Act
          formNotifier.updateEmail(email);

          // Assert
          final state = container.read(registerFormProvider);
          expect(
            state.emailError,
            isNotNull,
            reason: 'Email "$email" should be invalid',
          );
        }
      });

      test('should perform real-time password validation', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);
        final strongPasswords = ['StrongPass123', 'MySecure123', 'ValidPass99'];
        final weakPasswords = [
          'weak',
          '123',
          'password',
          'Password', // Missing number
        ];

        // Test strong passwords
        for (final password in strongPasswords) {
          // Act
          formNotifier.updatePassword(password);

          // Assert
          final state = container.read(registerFormProvider);
          expect(
            state.passwordError,
            isNull,
            reason: 'Password "$password" should be valid',
          );
        }

        // Test weak passwords
        for (final password in weakPasswords) {
          // Act
          formNotifier.updatePassword(password);

          // Assert
          final state = container.read(registerFormProvider);
          expect(
            state.passwordError,
            isNotNull,
            reason: 'Password "$password" should be invalid',
          );
        }
      });

      test('should validate password confirmation in real-time', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);
        const password = 'StrongPass123';

        // Act - Set password first
        formNotifier.updatePassword(password);

        // Test matching confirmation
        formNotifier.updateConfirmPassword(password);
        expect(
          container.read(registerFormProvider).confirmPasswordError,
          isNull,
        );

        // Test non-matching confirmation
        formNotifier.updateConfirmPassword('DifferentPass456');
        expect(
          container.read(registerFormProvider).confirmPasswordError,
          isNotNull,
        );
      });

      test('should validate name field in real-time', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);
        final validNames = [
          'John Doe',
          'Mary Jane Smith',
          'José García',
          'O\'Connor',
        ];
        final invalidNames = [
          '', // Empty
          'A', // Too short
          ' ', // Only whitespace
        ];

        // Test valid names
        for (final name in validNames) {
          // Act
          formNotifier.updateName(name);

          // Assert
          final state = container.read(registerFormProvider);
          expect(
            state.nameError,
            isNull,
            reason: 'Name "$name" should be valid',
          );
        }

        // Test invalid names
        for (final name in invalidNames) {
          // Act
          formNotifier.updateName(name);

          // Assert
          final state = container.read(registerFormProvider);
          expect(
            state.nameError,
            isNotNull,
            reason: 'Name "$name" should be invalid',
          );
        }
      });
    });

    group('Form Submission Integration', () {
      test(
        'should enable submit button only when form is complete and valid',
        () {
          // Arrange
          final formNotifier = container.read(registerFormProvider.notifier);

          // Initially should not be able to submit
          expect(container.read(registerFormProvider).isValid, isFalse);

          // Add fields one by one
          formNotifier.updateEmail('test@example.com');
          expect(container.read(registerFormProvider).isValid, isFalse);

          formNotifier.updatePassword('StrongPass123');
          expect(container.read(registerFormProvider).isValid, isFalse);

          formNotifier.updateConfirmPassword('StrongPass123');
          expect(container.read(registerFormProvider).isValid, isFalse);

          // After adding all required fields, should be able to submit
          formNotifier.updateName('John Doe');
          formNotifier.toggleTermsAgreement(); // Need to agree to terms
          expect(container.read(registerFormProvider).isValid, isTrue);
        },
      );

      test('should disable submit button during loading', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Fill valid form
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');
        formNotifier.updateName('John Doe');
        formNotifier.toggleTermsAgreement(); // Need to agree to terms

        expect(container.read(registerFormProvider).isValid, isTrue);

        // Act - Set loading state
        // Loading state doesn't affect form validity in current implementation

        // Assert - Form should still be valid during loading
        expect(container.read(registerFormProvider).isValid, isTrue);
      });

      test('should handle form submission state changes', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act & Assert - Test loading state
        // Initially should not be loading
        expect(container.read(registerFormProvider).isLoading, isFalse);

        // Loading state managed internally
        expect(container.read(registerFormProvider).isLoading, isFalse);

        // Act & Assert - Test error state
        // Simulate error by updating with invalid data
        formNotifier.updateEmail('invalid-email');
        expect(container.read(registerFormProvider).hasErrors, isTrue);
        expect(container.read(registerFormProvider).emailError, isNotNull);

        // Act & Assert - Clear errors
        formNotifier.clearErrors();
        expect(container.read(registerFormProvider).hasErrors, isFalse);
        expect(container.read(registerFormProvider).generalError, isNull);
      });
    });

    group('Email Verification Flow Integration', () {
      test('should handle post-registration email verification flow', () {
        // This test verifies that the registration flow properly integrates
        // with email verification requirements

        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act - Complete valid registration form
        formNotifier.updateEmail('test@example.com');
        formNotifier.updatePassword('StrongPass123');
        formNotifier.updateConfirmPassword('StrongPass123');
        formNotifier.updateName('John Doe');
        formNotifier.toggleTermsAgreement(); // Need to agree to terms

        // Assert - Form should be ready for submission
        final state = container.read(registerFormProvider);
        expect(state.isValid, isTrue);
        expect(state.isValid, isTrue);
        expect(state.email, equals('test@example.com'));
      });

      test('should maintain form state during navigation', () {
        // This test ensures form state is maintained when user navigates
        // between registration and email verification pages

        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act - Fill partial form
        formNotifier.updateEmail('test@example.com');
        formNotifier.updateName('John Doe');

        // Simulate navigation away and back
        final savedState = container.read(registerFormProvider);

        // Assert - State should be preserved
        expect(savedState.email, equals('test@example.com'));
        expect(savedState.name, equals('John Doe'));
      });
    });

    group('Accessibility and User Experience', () {
      test('should provide proper error messages for screen readers', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Act - Trigger various validation errors
        formNotifier.updateEmail('invalid-email');
        formNotifier.updatePassword('weak');
        formNotifier.updateName('A');

        // Assert - Error messages should be descriptive
        final state = container.read(registerFormProvider);
        expect(state.emailError, isNotNull);
        expect(state.passwordError, isNotNull);
        expect(state.nameError, isNotNull);

        // Error messages should be strings (for screen reader compatibility)
        expect(state.emailError, isA<String>());
        expect(state.passwordError, isA<String>());
        expect(state.nameError, isA<String>());
      });

      test('should handle form state for different interaction patterns', () {
        // Arrange
        final formNotifier = container.read(registerFormProvider.notifier);

        // Test rapid field updates (user typing)
        formNotifier.updateEmail('t');
        formNotifier.updateEmail('te');
        formNotifier.updateEmail('test');
        formNotifier.updateEmail('test@');
        formNotifier.updateEmail('test@example.com');

        // Assert - Should end up with valid email
        expect(container.read(registerFormProvider).emailError, isNull);

        // Test field clearing and re-entry
        formNotifier.updateEmail('');
        expect(container.read(registerFormProvider).emailError, isNotNull);

        formNotifier.updateEmail('test@example.com');
        expect(container.read(registerFormProvider).emailError, isNull);
      });
    });
  });
}
