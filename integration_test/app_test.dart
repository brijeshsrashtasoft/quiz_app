import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import all test files
import 'features/splash/splash_screen_test.dart' as splash_tests;
import 'features/home/home_screen_test.dart' as home_tests;

/// Main integration test suite that runs all E2E tests
/// This file orchestrates the execution of all feature tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quiz App E2E Test Suite', () {
    group('Splash Screen Tests', splash_tests.main);
    group('Home Screen Tests', home_tests.main);
  });
}