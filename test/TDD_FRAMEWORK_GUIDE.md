# TDD Test Framework Guide

## Overview

This document outlines the Test-Driven Development (TDD) framework established for the quiz application. The framework supports comprehensive testing across unit, widget, integration, and end-to-end test categories.

## Framework Structure

### Core Components

1. **test_config.dart** - Central test configuration and utilities
2. **test/helpers/test_utilities.dart** - Common testing utilities and mock builders  
3. **scripts/tdd-workflow.sh** - Automated TDD workflow script

### Test Directory Structure

```
test/
├── unit/                    # Unit tests (business logic)
│   ├── core/               # Core functionality tests
│   ├── features/           # Feature-specific unit tests
│   └── shared/             # Shared component tests
├── widget/                 # Widget tests (UI components)
│   └── shared/             # Shared widget tests
├── integration/            # Integration tests (feature workflows)
├── helpers/                # Test utilities and fixtures
├── mocks/                  # Generated mock files
└── test_config.dart        # Test configuration
```

## TDD Workflow

### Red-Green-Refactor Cycle

1. **Red Phase**: Write failing test
   ```bash
   ./scripts/tdd-workflow.sh red test/unit/feature/test_file.dart
   ```

2. **Green Phase**: Write minimal code to pass
   ```bash
   ./scripts/tdd-workflow.sh green test/unit/feature/test_file.dart
   ```

3. **Refactor Phase**: Improve code while maintaining tests
   ```bash
   ./scripts/tdd-workflow.sh refactor test/unit/feature/test_file.dart
   ```

### Automated Commands

```bash
# Initialize TDD environment
./scripts/tdd-workflow.sh init

# Watch files and auto-run tests
./scripts/tdd-workflow.sh watch

# Generate coverage report
./scripts/tdd-workflow.sh coverage

# Validate test structure
./scripts/tdd-workflow.sh validate

# Clean test artifacts
./scripts/tdd-workflow.sh clean
```

## Test Categories

### Unit Tests (Business Logic)

**Location**: `test/unit/`
**Purpose**: Test individual classes, functions, and business logic
**Example**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/utils/result.dart';
import '../../../test_config.dart';

void main() {
  testGroup('Feature Name', TestCategory.unit, () {
    testCase('should perform expected behavior', TestCategory.unit, () {
      // Arrange
      const input = 'test';
      
      // Act
      final result = Result.success(input);
      
      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(input));
    });
  });
}
```

### Widget Tests (UI Components)

**Location**: `test/widget/`
**Purpose**: Test UI components, user interactions, and rendering
**Example**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/shared/widgets/buttons/primary_button.dart';
import '../../../../test_config.dart';

void main() {
  testGroup('Primary Button Widget', TestCategory.widget, () {
    widgetTestCase('should display button text', TestCategory.widget, (tester) async {
      // Arrange
      const buttonText = 'Test Button';
      
      // Act
      await tester.pumpWidget(
        TestWrappers.materialApp(
          child: PrimaryButton(
            text: buttonText,
            onPressed: () {},
          ),
        ),
      );
      
      // Assert
      expect(find.text(buttonText), findsOneWidget);
    });
  });
}
```

### Integration Tests (Feature Flows)

**Location**: `test/integration/`
**Purpose**: Test complete user workflows and feature integration
**Example**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import '../test_config.dart';

void main() {
  testGroup('User Authentication Flow', TestCategory.integration, () {
    testWidgets('user should navigate through auth flow', (tester) async {
      // Arrange
      await tester.pumpWidget(TestWrappers.fullApp());
      
      // Act
      AppRouter.go('/login');
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Login'), findsWidgets);
    });
  });
}
```

## Test Utilities

### TestWrappers

- **materialApp()**: Basic Material app wrapper
- **providerScope()**: Riverpod provider scope wrapper  
- **fullApp()**: Complete app with navigation
- **scaffoldWrapper()**: Scaffold wrapper for isolated testing

### TestExpectations

- **expectWidgetBuilds()**: Verify widget builds without errors
- **expectAsyncCompletion()**: Test async operations with timeout
- **expectAccessible()**: Basic accessibility verification
- **expectPerformant()**: Performance threshold testing

### TestDataBuilders

- **createUserData()**: Generate test user data
- **createQuizData()**: Generate test quiz data
- **createGameSessionData()**: Generate test game session data
- **createLeaderboardData()**: Generate test leaderboard data

## Current Test Coverage

### Working Tests ✅

1. **Result Pattern Tests** (`test/unit/core/utils/result_test.dart`)
   - Complete coverage of success/failure cases
   - Transformation and chaining operations
   - Error handling patterns

2. **Navigation System Tests** (`test/navigation_system_test.dart`)
   - Basic navigation functionality
   - Route constants validation

### Test Categories Coverage

- **Unit Tests**: Result pattern, core utilities ✅
- **Widget Tests**: Basic structure in place ⚠️
- **Integration Tests**: Navigation basics ⚠️  
- **Performance Tests**: Framework ready ⚠️

## Test Quality Requirements

### Coverage Standards
- **Minimum Coverage**: 80%
- **Performance Threshold**: <200ms for operations
- **Memory Usage**: <100MB for mobile
- **Test Execution Time**: <5 minutes total

### Code Quality
- All tests follow AAA pattern (Arrange, Act, Assert)
- Descriptive test names explaining scenarios
- Proper error handling and edge case testing
- No flaky or intermittent failures

## Platform Verification

### Required Verifications
```bash
# Run platform verification before any PR
./scripts/quality-check.sh

# This verifies:
# ✅ All tests pass
# ✅ Code analysis passes
# ✅ Coverage meets minimum (80%)
# ✅ All platforms build successfully
```

### Platform Requirements
- **Android**: APK builds with proper Firebase config
- **iOS**: Builds with iOS 13.0+ deployment target
- **Web**: Builds successfully to build/web

## Best Practices

### Test Organization
1. Group related tests together
2. Use descriptive test names
3. Keep tests focused and atomic
4. Mock external dependencies
5. Use test fixtures for complex data

### TDD Approach
1. Always write tests first (Red phase)
2. Write minimal code to pass (Green phase)  
3. Refactor while keeping tests green (Refactor phase)
4. Commit after each successful TDD cycle

### Performance Testing
1. Test with realistic data volumes
2. Monitor memory usage during tests
3. Validate response times meet requirements
4. Test on different screen sizes

## Troubleshooting

### Common Issues

1. **Mock Generation Errors**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Test Compilation Errors**
   ```bash
   flutter analyze test/
   flutter test --dry-run
   ```

3. **Coverage Issues**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

### Test Environment Issues

1. **Firebase Emulator Setup**
   ```bash
   firebase emulators:start --only firestore,auth
   ```

2. **Clean Test Environment**
   ```bash
   ./scripts/tdd-workflow.sh clean
   flutter clean
   flutter pub get
   ```

## Integration with Development Workflow

### Pre-Commit Hooks
- Run static analysis on tests
- Verify test compilation
- Check for minimum coverage

### Continuous Integration
- All tests must pass before PR merge
- Coverage reports generated automatically
- Performance benchmarks tracked

### Agent Coordination
- Testing specialist validates all implementations
- Other agents follow TDD workflow
- Cross-agent test validation ensures consistency

## Next Steps

### Immediate Actions Required
1. Fix compilation errors in existing test files
2. Generate missing mock files
3. Complete widget test coverage for shared components
4. Implement integration tests for complete user flows

### Framework Enhancements
1. Add golden file testing support
2. Implement E2E testing with Playwright
3. Add accessibility testing automation
4. Create performance benchmarking suite

## Summary

The TDD framework is established with:
- ✅ **Core infrastructure** ready for development
- ✅ **Automated workflow scripts** for TDD cycle
- ✅ **Basic test utilities** and wrappers
- ✅ **Working unit tests** as examples
- ⚠️ **Compilation errors** need fixing in some test files
- ⚠️ **Mock generation** needs completion
- ⚠️ **Coverage expansion** required for full feature coverage

The framework provides a solid foundation for test-driven development while ensuring quality, performance, and platform compatibility standards are maintained.