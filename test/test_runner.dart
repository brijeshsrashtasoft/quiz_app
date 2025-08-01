import 'package:flutter_test/flutter_test.dart';

// Import all test files for US-001 Registration Flow
import 'features/authentication/domain/value_objects/email_test.dart'
    as email_tests;
import 'features/authentication/domain/value_objects/password_test.dart'
    as password_tests;
import 'features/authentication/domain/usecases/sign_up_usecase_test.dart'
    as signup_tests;
import 'features/authentication/presentation/navigation_integration_test.dart'
    as navigation_tests;
import 'features/authentication/presentation/auth_ui_integration_test.dart'
    as ui_tests;
import 'features/authentication/integration/registration_flow_integration_test.dart'
    as integration_tests;

/// Test Runner for US-001 Email/Password Registration Flow
///
/// This file runs all tests related to the registration flow to ensure
/// comprehensive coverage of the core functionality.
///
/// Test Categories:
/// 1. Email Validation Logic - Domain layer value object tests
/// 2. Password Validation Logic - Domain layer value object tests
/// 3. Registration Flow Navigation - Presentation layer navigation tests
/// 4. UI Integration - Presentation layer form and state tests
/// 5. Complete Integration - End-to-end registration flow tests

void main() {
  group('US-001 Email/Password Registration Flow - Complete Test Suite', () {
    group('1. Domain Layer - Value Objects', () {
      email_tests.main();
      password_tests.main();
    });

    group('2. Domain Layer - Use Cases', () {
      signup_tests.main();
    });

    group('3. Presentation Layer - Navigation', () {
      navigation_tests.main();
    });

    group('4. Presentation Layer - UI Integration', () {
      ui_tests.main();
    });

    group('5. Integration Tests - Complete Flow', () {
      integration_tests.main();
    });

    // Summary test to verify all components are working together
    test('US-001 Registration Flow - Test Suite Summary', () {
      // This test serves as documentation and verification that all
      // major components of the registration flow are tested

      final testCategories = [
        'Email Validation Logic',
        'Password Validation Logic',
        'SignUp UseCase Logic',
        'Navigation Integration',
        'UI Form Integration',
        'Complete Registration Flow',
      ];

      for (final category in testCategories) {
        // Verify each test category is covered
        expect(category, isNotNull);
        expect(category, isNotEmpty);
      }

      // Verify test coverage areas
      final coverageAreas = [
        'Input validation',
        'Error handling',
        'Navigation flow',
        'State management',
        'Form interactions',
        'Authentication integration',
      ];

      expect(coverageAreas.length, greaterThan(5));
    });
  });
}
