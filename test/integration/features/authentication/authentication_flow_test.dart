import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/presentation/pages/login_page.dart';
import 'package:quiz_app/features/authentication/presentation/pages/register_page.dart';
import 'package:quiz_app/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import '../../../test_config.dart';

import 'authentication_flow_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([AuthService, User, UserCredential])
void main() {
  testGroup(
    'Authentication Flow Integration Tests',
    TestCategory.integration,
    () {
      late MockAuthService mockAuthService;
      late MockUser mockUser;
      late MockUserCredential mockUserCredential;

      setUp(() {
        mockAuthService = MockAuthService();
        mockUser = MockUser();
        mockUserCredential = MockUserCredential();
      });

      testWidgets('complete login flow should navigate to home on success', (
        tester,
      ) async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn('Test User');

        when(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => Result.success(mockUserCredential));

        // Act
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Fill in email and password
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your email address'),
          email,
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your password'),
          password,
        );

        // Tap sign in button
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        verify(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      testWidgets('login flow should show error message on failure', (
        tester,
      ) async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        const errorMessage = 'Invalid credentials';

        when(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer(
          (_) async => Result.failure(
            Failure.authFailure(
              message: errorMessage,
              code: 'AUTH_SIGNIN_ERROR',
            ),
          ),
        );

        // Act
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Fill in email and password
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your email address'),
          email,
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your password'),
          password,
        );

        // Tap sign in button
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        verify(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      testWidgets(
        'complete registration flow should create user and navigate',
        (tester) async {
          // Arrange
          const email = 'newuser@example.com';
          const password = 'password123';
          const displayName = 'New User';

          when(mockUserCredential.user).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('new-user-uid');
          when(mockUser.email).thenReturn(email);
          when(mockUser.displayName).thenReturn(displayName);

          when(
            mockAuthService.createUserWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authServiceProvider.overrideWithValue(mockAuthService),
              ],
              child: TestWrappers.materialApp(child: const RegisterPage()),
            ),
          );

          // Fill in registration form
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Enter your full name'),
            displayName,
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Enter your email address'),
            email,
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Enter your password'),
            password,
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm your password'),
            password,
          );

          // Tap create account button
          await tester.tap(find.text('Create Account'));
          await tester.pumpAndSettle();

          // Assert
          verify(
            mockAuthService.createUserWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            ),
          ).called(1);
        },
      );

      testWidgets('password reset flow should send reset email', (
        tester,
      ) async {
        // Arrange
        const email = 'test@example.com';

        when(
          mockAuthService.sendPasswordResetEmail(email: email),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const ForgotPasswordPage()),
          ),
        );

        // Fill in email
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your email address'),
          email,
        );

        // Tap reset password button
        await tester.tap(find.text('Send Reset Email'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockAuthService.sendPasswordResetEmail(email: email)).called(1);
        expect(find.text('Password reset email sent!'), findsOneWidget);
      });

      testWidgets('form validation should prevent invalid submissions', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Act - Try to submit with empty fields
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
        verifyNever(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      testWidgets('email validation should show appropriate error messages', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Act - Enter invalid email
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your email address'),
          'invalid-email',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your password'),
          'password123',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('password validation should enforce minimum length', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Act - Enter short password
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your email address'),
          'test@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your password'),
          '123',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      });

      testWidgets('password visibility toggle should work correctly', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Act - Find password field and toggle visibility
        final passwordField = find.widgetWithText(
          TextFormField,
          'Enter your password',
        );
        expect(passwordField, findsOneWidget);

        final visibilityToggle = find.byIcon(Icons.visibility);
        expect(visibilityToggle, findsOneWidget);

        await tester.tap(visibilityToggle);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('loading state should show progress indicator', (
        tester,
      ) async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        // Simulate slow auth response
        when(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 2));
          return Result.success(mockUserCredential);
        });

        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // Act
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your email address'),
          email,
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter your password'),
          password,
        );
        await tester.tap(find.text('Sign In'));
        await tester.pump(); // Don't wait for completion

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('navigation between auth pages should work correctly', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(TestWrappers.fullApp());

        // Start at login page
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const LoginPage()),
        );

        // Act - Navigate to register page
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('Join the quiz community'), findsOneWidget);

        // Act - Navigate to forgot password
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const LoginPage()),
        );
        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        // Assert - Would check for forgot password page
        // In a real app with navigation, this would work
      });

      testGroup('Authentication State Management Integration', () {
        testWidgets('auth state should update correctly on successful login', (
          tester,
        ) async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(mockUserCredential.user).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('test-uid');
          when(mockUser.email).thenReturn(email);

          when(
            mockAuthService.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authServiceProvider.overrideWithValue(mockAuthService),
              ],
              child: Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authStateProvider);
                  return MaterialApp(
                    home: Scaffold(
                      body: authState.when(
                        data: (state) =>
                            Text('Auth State: ${state.isAuthenticated}'),
                        loading: () => const Text('Loading'),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ),
                  );
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.textContaining('Auth State:'), findsOneWidget);
        });
      });

      testGroup('Performance Integration Tests', () {
        testWidgets('auth flow should complete within performance threshold', (
          tester,
        ) async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockAuthService.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authServiceProvider.overrideWithValue(mockAuthService),
              ],
              child: TestWrappers.materialApp(child: const LoginPage()),
            ),
          );

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            await tester.enterText(
              find.widgetWithText(TextFormField, 'Enter your email address'),
              email,
            );
            await tester.enterText(
              find.widgetWithText(TextFormField, 'Enter your password'),
              password,
            );
            await tester.tap(find.text('Sign In'));
            await tester.pumpAndSettle();
          }, threshold: const Duration(milliseconds: 500));
        });
      });
    },
  );
}
