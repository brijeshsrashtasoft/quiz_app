/// Authentication testing utilities and helpers
/// Provides centralized mocks, fixtures, and test utilities for authentication tests

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import '../test_config.dart';

/// Authentication test utilities and fixtures
class AuthTestHelper {
  AuthTestHelper._();

  /// Create test user entity with optional parameters
  static UserEntity createTestUser({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    UserStats? stats,
  }) {
    return UserEntity(
      id: id ?? 'test-user-123',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: createdAt ?? DateTime.now(),
      stats: stats ?? createTestUserStats(),
    );
  }

  /// Create test user stats
  static UserStats createTestUserStats({
    int? totalQuizzes,
    int? totalGamesPlayed,
    int? totalGamesWon,
    double? averageScore,
  }) {
    return UserStats(
      totalQuizzes: totalQuizzes ?? 5,
      totalGamesPlayed: totalGamesPlayed ?? 10,
      totalGamesWon: totalGamesWon ?? 3,
      averageScore: averageScore ?? 85.5,
    );
  }

  /// Create authenticated auth state for testing
  static AuthState createAuthenticatedState({
    User? firebaseUser,
    UserEntity? user,
  }) {
    return AuthState.authenticated(
      firebaseUser: firebaseUser ?? createMockFirebaseUser(),
      user: user ?? createTestUser(),
    );
  }

  /// Create unauthenticated auth state
  static AuthState createUnauthenticatedState() {
    return const AuthState.unauthenticated();
  }

  /// Create error auth state
  static AuthState createErrorState({String? message, User? firebaseUser}) {
    return AuthState.error(
      message: message ?? 'Authentication error',
      firebaseUser: firebaseUser,
    );
  }

  /// Create loading auth state
  static AuthState createLoadingState() {
    return const AuthState.loading();
  }

  /// Create mock Firebase User for testing
  static User createMockFirebaseUser({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
  }) {
    final mockUser = MockUser();
    when(mockUser.uid).thenReturn(uid ?? 'test-firebase-uid');
    when(mockUser.email).thenReturn(email ?? 'test@example.com');
    when(mockUser.displayName).thenReturn(displayName ?? 'Test User');
    when(mockUser.emailVerified).thenReturn(emailVerified ?? true);
    return mockUser;
  }

  /// Create mock UserCredential for testing
  static UserCredential createMockUserCredential({User? user}) {
    final mockCredential = MockUserCredential();
    when(mockCredential.user).thenReturn(user ?? createMockFirebaseUser());
    return mockCredential;
  }

  /// Setup authentication service mock with common behaviors
  static MockAuthService setupMockAuthService({
    bool signInSuccess = true,
    bool createUserSuccess = true,
    bool signOutSuccess = true,
    bool passwordResetSuccess = true,
  }) {
    final mockService = MockAuthService();

    // Setup sign in behavior
    if (signInSuccess) {
      when(
        mockService.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Result.success(createMockUserCredential()));
    } else {
      when(
        mockService.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => Result.failure(
          Failure.authFailure(
            message: 'Sign in failed',
            code: 'AUTH_SIGNIN_ERROR',
          ),
        ),
      );
    }

    // Setup create user behavior
    if (createUserSuccess) {
      when(
        mockService.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        ),
      ).thenAnswer((_) async => Result.success(createMockUserCredential()));
    } else {
      when(
        mockService.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        ),
      ).thenAnswer(
        (_) async => Result.failure(
          Failure.authFailure(
            message: 'User creation failed',
            code: 'AUTH_CREATE_USER_ERROR',
          ),
        ),
      );
    }

    // Setup sign out behavior
    if (signOutSuccess) {
      when(
        mockService.signOut(),
      ).thenAnswer((_) async => const Result.success(null));
    } else {
      when(mockService.signOut()).thenAnswer(
        (_) async => Result.failure(
          Failure.authFailure(
            message: 'Sign out failed',
            code: 'AUTH_SIGNOUT_ERROR',
          ),
        ),
      );
    }

    // Setup password reset behavior
    if (passwordResetSuccess) {
      when(
        mockService.sendPasswordResetEmail(email: anyNamed('email')),
      ).thenAnswer((_) async => const Result.success(null));
    } else {
      when(
        mockService.sendPasswordResetEmail(email: anyNamed('email')),
      ).thenAnswer(
        (_) async => Result.failure(
          Failure.authFailure(
            message: 'Password reset failed',
            code: 'AUTH_PASSWORD_RESET_ERROR',
          ),
        ),
      );
    }

    return mockService;
  }

  /// Create test provider container with authentication overrides
  static ProviderContainer createTestContainer({
    AuthService? authService,
    Stream<User?>? firebaseAuthStream,
    Stream<AuthState>? authStateStream,
  }) {
    final overrides = <Override>[];

    if (authService != null) {
      overrides.add(authServiceProvider.overrideWithValue(authService));
    }

    if (firebaseAuthStream != null) {
      overrides.add(
        firebaseAuthProvider.overrideWith((ref) => firebaseAuthStream),
      );
    }

    if (authStateStream != null) {
      overrides.add(authStateProvider.overrideWith((ref) => authStateStream));
    }

    return ProviderContainer(overrides: overrides);
  }

  /// Create test widget with authentication providers
  static Widget createTestAuthWidget({
    required Widget child,
    List<Override>? overrides,
  }) {
    return TestWrappers.providerScope(
      overrides: overrides ?? [],
      child: TestWrappers.materialApp(child: child),
    );
  }

  /// Common test email addresses
  static const String validEmail = 'test@example.com';
  static const String invalidEmail = 'invalid-email';
  static const String existingEmail = 'existing@example.com';
  static const String nonExistentEmail = 'nonexistent@example.com';

  /// Common test passwords
  static const String validPassword = 'password123';
  static const String weakPassword = '123';
  static const String strongPassword = 'StrongPassword123!';

  /// Common test user data
  static const String testUserName = 'Test User';
  static const String testUserId = 'test-user-123';

  /// Form field finders for authentication pages
  static Finder get emailField =>
      find.widgetWithText(TextFormField, 'Enter your email address');

  static Finder get passwordField =>
      find.widgetWithText(TextFormField, 'Enter your password');

  static Finder get confirmPasswordField =>
      find.widgetWithText(TextFormField, 'Confirm your password');

  static Finder get nameField =>
      find.widgetWithText(TextFormField, 'Enter your full name');

  /// Common button finders
  static Finder get signInButton => find.text('Sign In');
  static Finder get createAccountButton => find.text('Create Account');
  static Finder get forgotPasswordButton => find.text('Forgot Password?');
  static Finder get sendResetEmailButton => find.text('Send Reset Email');
  static Finder get signUpLink => find.text('Sign Up');

  /// Common error message finders
  static Finder get emailRequiredError => find.text('Email is required');
  static Finder get passwordRequiredError => find.text('Password is required');
  static Finder get invalidEmailError =>
      find.text('Please enter a valid email address');
  static Finder get weakPasswordError =>
      find.text('Password must be at least 6 characters');
  static Finder get passwordMismatchError =>
      find.text('Passwords do not match');

  /// Helper method to fill authentication form
  static Future<void> fillAuthForm(
    WidgetTester tester, {
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
  }) async {
    if (name != null) {
      await tester.enterText(nameField, name);
    }

    if (email != null) {
      await tester.enterText(emailField, email);
    }

    if (password != null) {
      await tester.enterText(passwordField, password);
    }

    if (confirmPassword != null) {
      await tester.enterText(confirmPasswordField, confirmPassword);
    }
  }

  /// Helper method to verify authentication error display
  static void verifyAuthError(String errorMessage) {
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  }

  /// Helper method to verify loading state
  static void verifyLoadingState() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Helper method to verify successful state
  static void verifySuccessState() {
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  }

  /// Create test failure objects
  static Failure createAuthFailure({String? message, String? code}) {
    return Failure.authFailure(
      message: message ?? 'Authentication failed',
      code: code ?? 'AUTH_ERROR',
    );
  }

  static Failure createNetworkFailure({String? message, String? code}) {
    return Failure.networkFailure(
      message: message ?? 'Network error',
      code: code ?? 'NETWORK_ERROR',
    );
  }

  static Failure createValidationFailure({String? message, String? code}) {
    return Failure.validationFailure(
      message: message ?? 'Validation failed',
      code: code ?? 'VALIDATION_ERROR',
    );
  }

  /// Performance test helpers
  static Future<void> expectAuthPerformant(
    Future<void> Function() operation, {
    Duration threshold = const Duration(milliseconds: 200),
  }) async {
    await TestExpectations.expectPerformant(operation, threshold: threshold);
  }

  /// Accessibility test helpers
  static void verifyAuthAccessibility(WidgetTester tester) {
    TestExpectations.expectAccessible(tester);

    // Verify specific auth accessibility features
    expect(find.bySemanticsLabel('Email input'), findsWidgets);
    expect(find.bySemanticsLabel('Password input'), findsWidgets);
    expect(find.bySemanticsLabel('Sign in button'), findsWidgets);
  }

  /// Animation test helpers
  static Future<void> verifyAuthAnimations(WidgetTester tester) async {
    // Check for fade animations
    expect(find.byType(FadeTransition), findsWidgets);

    // Check for slide animations
    expect(find.byType(SlideTransition), findsWidgets);

    // Pump animations to completion
    await tester.pumpAndSettle();
  }

  /// Dark mode test helpers
  static Widget createDarkModeTestWidget(Widget child) {
    return TestWrappers.materialApp(theme: ThemeData.dark(), child: child);
  }

  /// Multi-platform test helpers
  static List<Size> get testScreenSizes => [
    const Size(320, 568), // iPhone SE
    const Size(375, 667), // iPhone 8
    const Size(414, 896), // iPhone 11 Pro Max
    const Size(768, 1024), // iPad
  ];

  /// Test data validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Test stream helpers
  static Stream<User?> createAuthStream({
    bool authenticated = true,
    User? user,
  }) {
    if (authenticated) {
      return Stream.value(user ?? createMockFirebaseUser());
    } else {
      return Stream.value(null);
    }
  }

  static Stream<AuthState> createAuthStateStream({
    bool authenticated = true,
    bool hasError = false,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return Stream.value(createLoadingState());
    } else if (hasError) {
      return Stream.value(createErrorState());
    } else if (authenticated) {
      return Stream.value(createAuthenticatedState());
    } else {
      return Stream.value(createUnauthenticatedState());
    }
  }
}

/// Mock classes for authentication testing
class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthService extends Mock implements AuthService {}
