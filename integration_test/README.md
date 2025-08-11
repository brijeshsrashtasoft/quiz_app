# Integration Tests

This directory contains comprehensive integration tests for the Quiz App, focusing on end-to-end testing of quiz hosting and joining functionality.

## Test Structure

### Core Test Files

- **`quiz_hosting_integration_test.dart`** - Comprehensive integration tests with placeholder test cases for various scenarios
- **`quiz_game_flow_test.dart`** - Focused tests for the complete quiz hosting and joining flow
- **`integration_test_config.dart`** - Centralized configuration for all integration tests

### Helper Files

- **`test_helpers/integration_test_helpers.dart`** - Reusable utility functions and test helpers

## Test Users

The integration tests use three predefined test user accounts:

| Role | Email | Password | Name |
|------|-------|----------|------|
| Host | brijesh@yopmail.com | Brijesh@123 | Brijesh |
| Player 1 | ayushi@yopmail.com | Ayushi@123 | Ayushi |
| Player 2 | pankaj@yopmail.com | Pankaj!@#123 | Pankaj |

## Test Scenarios

### Primary Flow Test (`quiz_game_flow_test.dart`)

1. **Complete Quiz Game Flow**
   - Host (Brijesh) signs in and creates a quiz
   - Host generates a game PIN and waits for players
   - Player 1 (Ayushi) signs in and joins using the PIN
   - Player 2 (Pankaj) signs in and joins using the PIN
   - Host starts the game with 2 players

2. **Authentication Tests**
   - Validates all three test users can sign in successfully
   - Tests error handling for invalid credentials

3. **Error Handling Tests**
   - Invalid PIN entry handling
   - Network error recovery
   - App stability under rapid navigation

4. **Performance Tests**
   - Sign-in time measurement
   - Overall operation performance validation

### Comprehensive Test Suite (`quiz_hosting_integration_test.dart`)

Contains placeholder test cases for future implementation:

- **Quiz Creation & Hosting**
  - Quiz validation and creation flow
  - Game session management
  - Host control panel functionality

- **Player Joining & Gameplay**
  - PIN validation and joining flow
  - Real-time player updates
  - Answer submission and scoring

- **Real-time Features**
  - Live player count updates
  - Game state synchronization
  - Leaderboard updates

- **Network & Connectivity**
  - Network interruption handling
  - Firebase reconnection
  - Offline/online transitions

- **Security & Validation**
  - User permission validation
  - Game access controls
  - Data validation and sanitization

- **Edge Cases & Boundaries**
  - Maximum player limits
  - Host disconnection scenarios
  - Invalid quiz configurations

## Running Integration Tests

### Prerequisites

1. Ensure all three test users exist in your Firebase Authentication system
2. Make sure Firebase Firestore has proper security rules for testing
3. Verify network connectivity to Firebase services

### Run All Integration Tests

```bash
flutter test integration_test/
```

### Run Specific Test File

```bash
# Run the focused game flow tests
flutter test integration_test/quiz_game_flow_test.dart

# Run the comprehensive test suite
flutter test integration_test/quiz_hosting_integration_test.dart
```

### Run Tests on Device/Emulator

```bash
# Android
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/quiz_game_flow_test.dart

# iOS
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/quiz_game_flow_test.dart -d ios
```

## Test Configuration

The `integration_test_config.dart` file contains:

- **Timeouts**: Default, long, and short test timeouts
- **Delays**: App initialization, network, and animation delays
- **Test Data**: Default quiz content and test parameters
- **Performance Thresholds**: Maximum acceptable operation times
- **Environment Settings**: Debug options and test environment configuration

## Test Helpers

The `IntegrationTestHelpers` class provides:

- **Authentication**: User sign-in/sign-out utilities
- **Quiz Management**: Quiz creation and hosting helpers
- **Game Flow**: PIN entry and game joining utilities
- **Validation**: Text and widget existence checks
- **Performance**: Operation timing and measurement
- **Error Handling**: Graceful error recovery utilities

## Known Limitations

1. **Real-time Testing**: Some real-time features require complex multi-instance testing
2. **Network Simulation**: Network failure scenarios are not fully implemented
3. **Firebase Emulator**: Tests currently run against live Firebase (not emulator)
4. **Screenshot/Video**: Capture features are configured but not fully implemented

## Future Enhancements

1. **Multi-Device Testing**: Coordinate tests across multiple devices/emulators
2. **Network Simulation**: Implement network failure and recovery testing
3. **Performance Monitoring**: Add detailed performance metrics collection
4. **Visual Testing**: Screenshot comparison and visual regression testing
5. **Load Testing**: Test with larger numbers of concurrent players

## Troubleshooting

### Common Issues

1. **Test User Authentication Failures**
   - Verify user accounts exist in Firebase Auth
   - Check password requirements and formatting
   - Ensure Firebase project configuration is correct

2. **Timeout Errors**
   - Increase timeout values in `integration_test_config.dart`
   - Check network connectivity to Firebase
   - Verify app performance on test device

3. **Widget Not Found Errors**
   - Verify UI element locators match current app implementation
   - Check for timing issues with async operations
   - Ensure proper screen navigation sequences

4. **Firebase Permission Errors**
   - Review Firestore security rules
   - Verify user authentication state
   - Check read/write permissions for test data

### Debug Tips

1. Enable debug logs in `integration_test_config.dart`
2. Use `debugPrint()` statements for test flow debugging
3. Add screenshot capture at failure points
4. Check Flutter and Firebase SDK versions compatibility

## Contributing

When adding new integration tests:

1. Follow the existing test structure and naming conventions
2. Use the `IntegrationTestHelpers` class for common operations
3. Add appropriate timeout values and error handling
4. Update this README with new test scenarios
5. Ensure tests are deterministic and can run independently