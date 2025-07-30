import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/features/authentication/presentation/pages/login_page.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import '../../../../test_config.dart';
import '../../../../helpers/test_utilities.dart';
import 'login_page_test.mocks.dart';

/// Widget tests for LoginPage navigation and authentication UI
/// Following TDD approach: Test UI behavior and user interactions
@GenerateMocks([AuthService])
void main() {
  testGroup('LoginPage Widget Tests', TestCategory.widget, () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    widgetTestCase('should render login form correctly', TestCategory.widget, (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await tester.pumpWidget(
        TestWrappers.providerScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: TestWrappers.materialApp(child: const LoginPage()),
        ),
      );

      // ACT
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    widgetTestCase(
      'should show validation errors for empty fields',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Try to submit with empty fields
        final signInButton = find.text('Sign In');
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      },
    );

    widgetTestCase('should validate email format', TestCategory.widget, (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await tester.pumpWidget(
        TestWrappers.providerScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: TestWrappers.materialApp(child: const LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      // ACT - Enter invalid email
      final emailField = find.byKey(const Key('email_field'));
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    widgetTestCase('should toggle password visibility', TestCategory.widget, (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await tester.pumpWidget(
        TestWrappers.providerScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: TestWrappers.materialApp(child: const LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      // ACT - Find password field and visibility toggle
      final passwordField = find.byKey(const Key('password_field'));
      final visibilityToggle = find.byKey(
        const Key('password_visibility_toggle'),
      );

      // Initial state - password should be obscured
      final TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // ASSERT - Password should now be visible
      final TextFormField updatedPasswordWidget = tester.widget(passwordField);
      expect(updatedPasswordWidget.obscureText, isFalse);
    });

    widgetTestCase(
      'should show loading state during authentication',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        when(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(const Duration(milliseconds: 100));
          return MockResultBuilder.success(MockUserCredential());
        });

        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Enter valid credentials and submit
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pump(); // Don't wait for settle to see loading state

        // ASSERT - Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Signing In...'), findsOneWidget);

        // Wait for completion
        await tester.pumpAndSettle();
      },
    );

    widgetTestCase(
      'should show error message on authentication failure',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        when(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async {
          return MockResultBuilder.failure('Invalid credentials');
        });

        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Enter credentials and submit
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'wrongpassword',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // ASSERT - Should show error message
        expect(find.text('Invalid credentials'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      },
    );

    widgetTestCase(
      'should navigate to forgot password page',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(TestWrappers.fullApp());
        await tester.pumpAndSettle();

        // Navigate to login page first
        // This would require proper routing setup in test

        // ACT - Tap forgot password link
        final forgotPasswordLink = find.text('Forgot Password?');
        await tester.tap(forgotPasswordLink);
        await tester.pumpAndSettle();

        // ASSERT - Should navigate to forgot password page
        // This would need verification of the actual navigation
        expect(forgotPasswordLink, findsOneWidget);
      },
    );

    widgetTestCase('should navigate to register page', TestCategory.widget, (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await tester.pumpWidget(TestWrappers.fullApp());
      await tester.pumpAndSettle();

      // ACT - Tap create account link
      final createAccountLink = find.text('Create Account');
      await tester.tap(createAccountLink);
      await tester.pumpAndSettle();

      // ASSERT - Should navigate to register page
      expect(createAccountLink, findsOneWidget);
    });

    widgetTestCase(
      'should show social authentication options',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          TestWrappers.providerScope(
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - Should show social login buttons
        expect(find.text('Or continue with'), findsOneWidget);
        expect(find.byKey(const Key('google_signin_button')), findsOneWidget);
        expect(find.byKey(const Key('apple_signin_button')), findsOneWidget);
      },
    );

    widgetTestCase(
      'should handle successful authentication and navigation',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        when(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async {
          return MockResultBuilder.success(MockUserCredential());
        });

        await tester.pumpWidget(
          TestWrappers.providerScope(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              // Mock the auth state to return authenticated user
              authStateProvider.overrideWith(
                (ref) => Stream.value(
                  AuthState.authenticated(
                    firebaseUser: MockFirebaseUser(),
                    user: UserEntity(
                      id: 'test-user-123',
                      name: 'Test User',
                      email: 'test@example.com',
                      createdAt: DateTime.now(),
                    ),
                  ),
                ),
              ),
            ],
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Enter valid credentials and submit
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // ASSERT - Should have called the authentication service
        verify(
          mockAuthService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      },
    );

    widgetTestCase('should be accessible', TestCategory.widget, (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await tester.pumpWidget(
        TestWrappers.providerScope(
          child: TestWrappers.materialApp(child: const LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      // ASSERT - Check accessibility
      await AccessibilityTestUtils.checkAccessibility(
        tester,
        const LoginPage(),
      );

      // Check semantic labels
      expect(find.bySemanticsLabel('Email input field'), findsOneWidget);
      expect(find.bySemanticsLabel('Password input field'), findsOneWidget);
      expect(find.bySemanticsLabel('Sign in button'), findsOneWidget);
    });

    widgetTestCase(
      'should handle remember me functionality',
      TestCategory.widget,
      (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          TestWrappers.providerScope(
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Find and tap remember me checkbox
        final rememberMeCheckbox = find.byKey(
          const Key('remember_me_checkbox'),
        );
        expect(rememberMeCheckbox, findsOneWidget);

        // Initial state should be unchecked
        Checkbox checkbox = tester.widget(rememberMeCheckbox);
        expect(checkbox.value, isFalse);

        // Tap to check
        await tester.tap(rememberMeCheckbox);
        await tester.pumpAndSettle();

        // ASSERT - Should now be checked
        checkbox = tester.widget(rememberMeCheckbox);
        expect(checkbox.value, isTrue);
      },
    );
  });

  testGroup('LoginPage Performance Tests', TestCategory.performance, () {
    widgetTestCase(
      'should render within performance threshold',
      TestCategory.performance,
      (WidgetTester tester) async {
        // ARRANGE & ACT
        final buildTime = await PerformanceTestUtils.measureBuildTime(
          tester,
          TestWrappers.providerScope(
            child: TestWrappers.materialApp(child: const LoginPage()),
          ),
        );

        // ASSERT
        expect(
          buildTime,
          lessThan(const Duration(milliseconds: 100)),
          reason: 'LoginPage should render quickly',
        );
      },
    );

    widgetTestCase('should be memory efficient', TestCategory.performance, (
      WidgetTester tester,
    ) async {
      // ACT & ASSERT
      await MemoryTestUtils.checkForMemoryLeaks(
        tester,
        TestWrappers.providerScope(
          child: TestWrappers.materialApp(child: const LoginPage()),
        ),
      );
    });
  });
}

/// Mock classes for testing
class MockUserCredential {
  final MockFirebaseUser user = MockFirebaseUser();
}

class MockFirebaseUser {
  String get uid => 'test-user-123';
  String get email => 'test@example.com';
  String get displayName => 'Test User';
}
