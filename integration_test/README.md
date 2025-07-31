# E2E Testing for Quiz App

This directory contains End-to-End (E2E) integration tests for the Quiz App, following the same clean architecture structure as the main application.

## 📁 Structure

```
integration_test/
├── app_test.dart              # Main test suite runner
├── test_driver.dart           # Integration test driver
├── helpers/                   # Test utilities and helpers
│   ├── test_helpers.dart      # Common test helper functions
│   └── mock_providers.dart    # Mock providers for testing
├── features/                  # Feature-specific tests
│   ├── splash/
│   │   └── splash_screen_test.dart
│   └── home/
│       └── home_screen_test.dart
└── scripts/
    └── run-e2e-tests.sh      # Test execution script
```

## 🚀 Running Tests

### Prerequisites

1. **Flutter SDK** installed and configured
2. **Device/Emulator** running for mobile tests
3. **Chrome browser** for web tests (optional)

### Quick Start

```bash
# Run all E2E tests
./scripts/run-e2e-tests.sh

# Run tests on specific platform
./scripts/run-e2e-tests.sh --platform web
./scripts/run-e2e-tests.sh --platform android
./scripts/run-e2e-tests.sh --platform ios

# Run specific test file
./scripts/run-e2e-tests.sh --test splash_screen_test.dart

# Run with verbose output
./scripts/run-e2e-tests.sh --verbose
```

### Manual Test Execution

```bash
# Run all integration tests
flutter test integration_test/

# Run specific test file
flutter test integration_test/features/splash/splash_screen_test.dart

# Run tests on web
flutter test integration_test/ -d web-server

# Run tests on specific device
flutter test integration_test/ -d chrome
flutter test integration_test/ -d android
```

## 🧪 Test Structure

### Test Helpers (`helpers/test_helpers.dart`)

Provides common utilities for E2E testing:

- **E2ETestHelpers**: Core testing utilities
  - `waitForWidget()` - Wait for widgets with timeout
  - `waitForNavigation()` - Wait for navigation completion
  - `takeScreenshot()` - Capture screenshots for debugging
  - `verifyTextExists()` - Verify text presence
  - `tapAndWait()` - Tap and wait for result
  - `scrollUntilVisible()` - Scroll to find widgets

- **E2EFinders**: Custom finders for common UI patterns
  - `buttonWithText()` - Find buttons by text
  - `iconButton()` - Find icon buttons
  - `textFieldWithLabel()` - Find text fields by label
  - `cardWithText()` - Find cards containing text

- **E2ETestData**: Test data and constants
  - Mock user data
  - Mock quiz data
  - Test PIN codes

### Mock Providers (`helpers/mock_providers.dart`)

Provides mock authentication states for testing:

- **TestAuthStates**: Static test states
  - `authenticatedState` - Logged in user
  - `unauthenticatedState` - Logged out user
  - `loadingState` - Loading authentication
  - `errorState()` - Authentication error

- **TestProviderOverrides**: Provider overrides for testing
  - `authenticatedUser()` - Override for authenticated state
  - `unauthenticatedUser()` - Override for unauthenticated state
  - `loadingState()` - Override for loading state
  - `errorState()` - Override for error state
  - `slowLoading()` - Override for slow loading simulation

- **TestScenarioManager**: Centralized scenario management
  - Maps test scenarios to provider overrides
  - Simplifies test setup

## 📱 Feature Tests

### Splash Screen Tests (`features/splash/splash_screen_test.dart`)

Tests for the splash screen functionality:

- ✅ **UI Elements**: Verifies splash screen displays correctly
- ✅ **Navigation**: Tests navigation to login/home based on auth state
- ✅ **Loading States**: Handles loading and error states
- ✅ **Accessibility**: Checks accessibility features
- ✅ **Performance**: Validates splash screen timing
- ✅ **Responsive**: Tests different screen sizes

### Home Screen Tests (`features/home/home_screen_test.dart`)

Tests for the home screen functionality:

- ✅ **UI Layout**: Verifies all home screen components
- ✅ **Welcome Header**: Tests greeting and user display
- ✅ **Quick Actions**: Validates quick action grid
- ✅ **Featured Quizzes**: Tests featured quiz carousel
- ✅ **Recent Activity**: Verifies activity list
- ✅ **Navigation**: Tests navigation bar functionality
- ✅ **Interactions**: Tests button taps and scrolling
- ✅ **Animations**: Validates animations and transitions
- ✅ **Responsive**: Tests orientation and screen size changes

## 🎯 Test Scenarios

The tests cover multiple scenarios using `TestScenario` enum:

- **authenticatedUser**: User is logged in
- **unauthenticatedUser**: User is not logged in
- **loadingState**: Authentication is loading
- **errorState**: Authentication error occurred
- **slowLoading**: Simulates slow network conditions

## 🔧 Configuration

### Integration Test Setup

The tests use Flutter's `integration_test` package with:

- **IntegrationTestWidgetsFlutterBinding**: Enables integration testing
- **ProviderScope**: Provides dependency injection for testing
- **Mock Overrides**: Replaces real providers with test doubles

### Test Environment

Tests are designed to:

- ✅ **Isolate Dependencies**: Use mocked providers
- ✅ **Control State**: Override authentication states
- ✅ **Handle Timing**: Wait for navigation and loading
- ✅ **Capture Issues**: Take screenshots on failure
- ✅ **Cross-Platform**: Run on Web, Android, and iOS

## 📊 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Web** | ✅ Supported | Chrome recommended |
| **Android** | ✅ Supported | Requires emulator/device |
| **iOS** | ✅ Supported | macOS only, requires simulator |

## 🐛 Troubleshooting

### Common Issues

1. **Tests Timeout**
   ```bash
   # Increase timeout in test files
   await E2ETestHelpers.waitForWidget(tester, finder, timeout: Duration(seconds: 30));
   ```

2. **Widget Not Found**
   ```bash
   # Add debug output
   await E2ETestHelpers.takeScreenshot(tester, 'debug_screen');
   print('Available widgets: ${find.byType(Widget).evaluate().length}');
   ```

3. **Platform-Specific Issues**
   ```bash
   # Use platform-specific setup
   await E2ETestHelpers.handlePlatformSpecificSetup(tester);
   ```

4. **UI Overflow Warnings**
   - These are visual warnings in tests and don't affect functionality
   - Can be ignored for E2E testing purposes
   - Should be fixed in main UI components for production

### Debug Commands

```bash
# Run with Flutter logs
flutter test integration_test/ --verbose

# Run single test with debug output
flutter test integration_test/features/splash/splash_screen_test.dart --verbose

# Check test compilation
flutter analyze integration_test/
```

## 🎯 Best Practices

1. **Isolated Tests**: Each test should be independent
2. **Realistic Data**: Use realistic test data
3. **Wait Patterns**: Always wait for navigation and loading
4. **Error Handling**: Test both success and error scenarios
5. **Cross-Platform**: Consider platform differences
6. **Performance**: Keep tests fast and focused
7. **Maintainable**: Use helper functions and constants

## 🔄 CI/CD Integration

The E2E tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run E2E Tests
  run: |
    flutter test integration_test/ --platform web
    flutter test integration_test/ --platform android
```

## 📝 Adding New Tests

To add new E2E tests:

1. **Create Test File**: Follow the existing structure
   ```dart
   // integration_test/features/new_feature/new_feature_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import '../../helpers/test_helpers.dart';
   
   void main() {
     E2ETestHelpers.initialize();
     
     group('New Feature E2E Tests', () {
       testWidgets('should do something', (tester) async {
         // Test implementation
       });
     });
   }
   ```

2. **Add to Main Suite**: Include in `app_test.dart`
   ```dart
   import 'features/new_feature/new_feature_test.dart' as new_feature_tests;
   
   group('New Feature Tests', new_feature_tests.main);
   ```

3. **Update Documentation**: Add to this README

## 🏆 Test Coverage

The E2E tests provide coverage for:

- ✅ **User Flows**: Complete user journeys
- ✅ **Authentication**: Login/logout flows  
- ✅ **Navigation**: Route transitions
- ✅ **UI Components**: Widget interactions
- ✅ **Error Handling**: Error states and recovery
- ✅ **Performance**: Loading and timing
- ✅ **Accessibility**: Screen reader support
- ✅ **Responsive Design**: Multiple screen sizes

---

**Note**: These E2E tests complement the unit and widget tests in the main `test/` directory. Together, they provide comprehensive test coverage for the Quiz App.