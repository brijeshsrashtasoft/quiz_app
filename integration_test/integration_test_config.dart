/// Integration Test Configuration
/// Centralized configuration for integration tests
class IntegrationTestConfig {
  // Test timeouts
  static const Duration defaultTimeout = Duration(minutes: 5);
  static const Duration longTimeout = Duration(minutes: 10);
  static const Duration shortTimeout = Duration(minutes: 2);

  // Test delays
  static const Duration appInitDelay = Duration(seconds: 3);
  static const Duration networkDelay = Duration(seconds: 2);
  static const Duration animationDelay = Duration(milliseconds: 500);

  // Test data
  static const String testQuizTitle = 'Integration Test Quiz';
  static const String testQuestion = 'What is 2 + 2?';
  static const List<String> testAnswers = ['3', '4', '5', '6'];
  static const int correctAnswerIndex = 1;

  // Firebase test configuration
  static const bool useFirebaseEmulator = false;
  static const String emulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
  static const int authEmulatorPort = 9099;

  // Test user management
  static const bool cleanupTestData = true;
  static const bool createTestUsersIfMissing = false;

  // Performance thresholds
  static const Duration maxSignInTime = Duration(seconds: 15);
  static const Duration maxQuizCreationTime = Duration(seconds: 30);
  static const Duration maxGameJoinTime = Duration(seconds: 10);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Debug settings
  static const bool enableDebugLogs = true;
  static const bool captureScreenshots = false;
  static const bool recordVideo = false;

  // Test environment
  static const String environment = 'test';
  static const bool skipSlowTests = false;
  static const bool runOnlyBasicTests = false;
}
