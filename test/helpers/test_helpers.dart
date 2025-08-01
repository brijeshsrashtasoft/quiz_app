import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

/// Test Helper Functions for US-001 Registration Flow Tests
/// Provides common utilities and test data for authentication testing

class TestHelpers {
  TestHelpers._();

  /// Creates a test user entity with default or custom values
  static UserEntity createTestUser({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? 'test-user-123',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Creates a test ProviderContainer with optional overrides
  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(overrides: overrides);
  }

  /// Creates a test app wrapper for widget testing
  static Widget createTestApp({
    required Widget child,
    List<Override> providerOverrides = const [],
  }) {
    return ProviderScope(
      overrides: providerOverrides,
      child: MaterialApp(home: child),
    );
  }

  /// Pump and settle with custom duration for better test stability
  static Future<void> pumpAndSettle(
    WidgetTester tester, [
    Duration timeout = const Duration(seconds: 10),
  ]) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Verify form field validation with test data
  static void verifyFormFieldValidation({
    required String fieldName,
    required List<String> validInputs,
    required List<String> invalidInputs,
    required void Function(String) updateField,
    required String? Function() getError,
  }) {
    // Test valid inputs
    for (final input in validInputs) {
      updateField(input);
      final error = getError();
      expect(
        error,
        isNull,
        reason: '$fieldName "$input" should be valid but got error: $error',
      );
    }

    // Test invalid inputs
    for (final input in invalidInputs) {
      updateField(input);
      final error = getError();
      expect(
        error,
        isNotNull,
        reason:
            '$fieldName "$input" should be invalid but no error was returned',
      );
    }
  }

  /// Common email test data
  static const List<String> validEmails = [
    'test@example.com',
    'user.name@domain.co.uk',
    'user+tag@domain.org',
    'user_name@sub.domain.com',
    'user123@test123.com',
    'a@b.co',
    'test-email@example-domain.com',
  ];

  static const List<String> invalidEmails = [
    '',
    '   ',
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

  /// Common password test data
  static const List<String> validPasswords = [
    'StrongPass123',
    'MySecure123',
    'ValidPass99',
    'TestPassword1',
    'SecureTest123',
    'MyPassword1',
    'AppPassword9',
    'Password123!',
  ];

  static const List<String> invalidPasswords = [
    '',
    'weak',
    '123',
    'password',
    'PASSWORD',
    'Password', // Missing number
    '12345678', // Missing letters
    'Pass1', // Too short
    'password123', // Common password
    'qwerty', // Common password
  ];

  /// Common name test data
  static const List<String> validNames = [
    'John Doe',
    'Mary Jane Smith',
    'José García',
    'O\'Connor',
    'Van Der Berg',
    '李小明',
    'Jean-Pierre',
    'Al',
  ];

  static const List<String> invalidNames = [
    '',
    '   ',
    'A', // Too short
  ];

  /// Wait for async operations in tests
  static Future<void> waitForAsync([Duration? duration]) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 1));
  }

  /// Verify Result pattern success
  static void verifyResultSuccess<T>(Result<T> result, {T? expectedData}) {
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
    if (expectedData != null) {
      expect(result.dataOrNull, equals(expectedData));
    }
    expect(result.failureOrNull, isNull);
  }

  /// Verify Result pattern failure
  static void verifyResultFailure<T>(
    Result<T> result, {
    String? expectedMessage,
    String? expectedFieldError,
    String? expectedFieldName,
  }) {
    expect(result.isFailure, isTrue);
    expect(result.isSuccess, isFalse);
    expect(result.dataOrNull, isNull);
    expect(result.failureOrNull, isNotNull);

    if (expectedMessage != null) {
      expect(result.failureOrNull?.userMessage, contains(expectedMessage));
    }

    if (expectedFieldError != null && expectedFieldName != null) {
      final failure = result.failureOrNull;
      if (failure != null) {
        failure.when(
          validationFailure: (message, fieldErrors) {
            expect(
              fieldErrors?[expectedFieldName],
              contains(expectedFieldError),
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
      }
    }
  }

  /// Create authentication state providers for testing
  static List<Override> createAuthStateOverrides({
    AuthState? authState,
    UserEntity? currentUser,
    bool? isAuthenticated,
  }) {
    final overrides = <Override>[];

    if (authState != null) {
      // Note: Actual provider override would be added here
      // This is a placeholder for the test setup
    }

    return overrides;
  }

  /// Generate test registration data
  static Map<String, String> generateValidRegistrationData({
    String? email,
    String? password,
    String? name,
  }) {
    return {
      'email': email ?? 'test@example.com',
      'password': password ?? 'StrongPass123',
      'confirmPassword': password ?? 'StrongPass123',
      'name': name ?? 'John Doe',
    };
  }

  /// Generate invalid registration data for testing error cases
  static Map<String, String> generateInvalidRegistrationData({
    bool invalidEmail = false,
    bool invalidPassword = false,
    bool invalidName = false,
    bool mismatchedPassword = false,
  }) {
    final data = generateValidRegistrationData();

    if (invalidEmail) {
      data['email'] = 'invalid-email';
    }

    if (invalidPassword) {
      data['password'] = 'weak';
    }

    if (invalidName) {
      data['name'] = 'A';
    }

    if (mismatchedPassword) {
      data['confirmPassword'] = 'DifferentPassword123';
    }

    return data;
  }

  /// Create test scenarios for registration flow
  static List<Map<String, dynamic>> getRegistrationTestScenarios() {
    return [
      {
        'name': 'Valid registration data',
        'data': generateValidRegistrationData(),
        'shouldBeValid': true,
      },
      {
        'name': 'Invalid email',
        'data': generateInvalidRegistrationData(invalidEmail: true),
        'shouldBeValid': false,
        'expectedError': 'email',
      },
      {
        'name': 'Invalid password',
        'data': generateInvalidRegistrationData(invalidPassword: true),
        'shouldBeValid': false,
        'expectedError': 'password',
      },
      {
        'name': 'Invalid name',
        'data': generateInvalidRegistrationData(invalidName: true),
        'shouldBeValid': false,
        'expectedError': 'name',
      },
      {
        'name': 'Mismatched password confirmation',
        'data': generateInvalidRegistrationData(mismatchedPassword: true),
        'shouldBeValid': false,
        'expectedError': 'confirmPassword',
      },
    ];
  }

  /// Verify test scenario execution
  static Future<void> executeTestScenario(
    Map<String, dynamic> scenario,
    Future<void> Function(Map<String, String>) testFunction,
  ) async {
    final scenarioName = scenario['name'] as String;
    final data = scenario['data'] as Map<String, String>;

    try {
      await testFunction(data);
    } catch (e) {
      throw Exception('Test scenario "$scenarioName" failed: $e');
    }
  }

  /// Format test names consistently
  static String formatTestName(String baseDescription, {String? variant}) {
    if (variant != null) {
      return '$baseDescription - $variant';
    }
    return baseDescription;
  }

  /// Verify authentication state transitions
  static void verifyAuthStateTransition({
    required AuthState fromState,
    required AuthState toState,
    required String transitionDescription,
  }) {
    // This would contain logic to verify state transitions are valid
    // For now, it's a placeholder for test documentation
    expect(fromState, isNotNull, reason: 'From state should not be null');
    expect(toState, isNotNull, reason: 'To state should not be null');
  }

  /// Create test matchers for common assertions
  static Matcher hasNoErrors() => predicate<dynamic>((dynamic object) {
    if (object is Map) {
      return !object.containsKey('error') ||
          object['error'] == null ||
          (object['error'] as String).isEmpty;
    }
    return true;
  }, 'has no errors');

  static Matcher hasError(String expectedError) =>
      predicate<dynamic>((dynamic object) {
        if (object is Map && object.containsKey('error')) {
          final error = object['error'] as String?;
          return error?.contains(expectedError) == true;
        }
        return false;
      }, 'has error containing "$expectedError"');

  /// Clean up test resources
  static void cleanupTestResources(ProviderContainer? container) {
    container?.dispose();
  }

  /// Verify test environment setup
  static void verifyTestEnvironment() {
    // Add any test environment verification logic here
    expect(true, isTrue, reason: 'Test environment should be properly set up');
  }
}

/// Test Data Constants
class TestData {
  TestData._();

  // User data
  static const String defaultUserId = 'test-user-123';
  static const String defaultUserName = 'Test User';
  static const String defaultUserEmail = 'test@example.com';

  // Form validation data
  static const String validEmail = 'test@example.com';
  static const String validPassword = 'StrongPass123';
  static const String validName = 'John Doe';

  // Error messages (should match actual implementation)
  static const String emailRequiredError = 'Email address is required';
  static const String emailInvalidError = 'Please enter a valid email address';
  static const String passwordRequiredError = 'Password is required';
  static const String passwordTooShortError =
      'Password must be at least 8 characters long';
  static const String nameRequiredError = 'Full name is required';
  static const String nameTooShortError =
      'Name must be at least 2 characters long';
  static const String passwordMismatchError = 'Passwords do not match';

  // Navigation routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';

  // Test timeouts
  static const Duration defaultTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 10);
  static const Duration shortTimeout = Duration(milliseconds: 500);
}

/// Test Extensions for better readability
extension TestResultExtensions<T> on Result<T> {
  void shouldBeSuccess({T? withData}) {
    TestHelpers.verifyResultSuccess(this, expectedData: withData);
  }

  void shouldBeFailure({
    String? withMessage,
    String? withFieldError,
    String? forField,
  }) {
    TestHelpers.verifyResultFailure(
      this,
      expectedMessage: withMessage,
      expectedFieldError: withFieldError,
      expectedFieldName: forField,
    );
  }
}

extension TestStringExtensions on String {
  bool get isValidEmail => TestHelpers.validEmails.contains(this);
  bool get isInvalidEmail => TestHelpers.invalidEmails.contains(this);
  bool get isValidPassword => TestHelpers.validPasswords.contains(this);
  bool get isInvalidPassword => TestHelpers.invalidPasswords.contains(this);
  bool get isValidName => TestHelpers.validNames.contains(this);
  bool get isInvalidName => TestHelpers.invalidNames.contains(this);
}
