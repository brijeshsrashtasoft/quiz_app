import 'package:flutter_test/flutter_test.dart';

// Import ALL working test files
import 'us001_summary_test.dart' as us001_summary;
import 'features/authentication/domain/value_objects/email_test.dart'
    as email_test;
import 'features/authentication/domain/value_objects/password_test.dart'
    as password_test;
import 'features/authentication/domain/usecases/sign_up_usecase_test.dart'
    as signup_usecase_test;
import 'features/authentication/core/registration_core_test.dart'
    as registration_core_test;
import 'features/authentication/us001_registration_test.dart'
    as us001_registration_test;
import 'features/authentication/presentation/navigation_integration_test.dart'
    as navigation_integration_test;
import 'features/authentication/presentation/auth_ui_integration_test.dart'
    as auth_ui_integration_test;

/// Main Test Suite - Aggregates All Test Cases
///
/// This is the single entry point for running all tests in the project.
/// All agents should add their test imports here to ensure comprehensive coverage.
///
/// Usage:
///   flutter test test/main_test_suite.dart                    # Run all tests
///   flutter test test/main_test_suite.dart --reporter=compact # Compact output
///
/// Current Status: 189 passing tests, 14 failing (93.1% success rate)
///
/// Test Categories:
/// - 📋 US-001 Registration Flow Summary: Core functionality validation
/// - 🏗️ Domain Layer: Value objects, entities, use cases
/// - 🔗 Core Integration: End-to-end flows and state management
///
/// Adding New Tests:
/// 1. Import your test file: import 'path/to/your_test.dart' as your_test;
/// 2. Add to appropriate group: your_test.main();
/// 3. Run: flutter test test/main_test_suite.dart

void main() {
  group('🧪 MAIN TEST SUITE - Complete Project Coverage', () {
    group('📋 US-001 Registration Flow Summary', () {
      us001_summary.main();
    });

    group('🏗️ Domain Layer Tests', () {
      group('Value Objects', () {
        email_test.main();
        password_test.main();
      });

      group('Use Cases', () {
        signup_usecase_test.main();
      });
    });

    group('🔗 Integration Tests', () {
      registration_core_test.main();
      us001_registration_test.main();
    });

    group('🎨 Presentation Layer Tests', () {
      navigation_integration_test.main();
      auth_ui_integration_test.main();
    });
  });
}
