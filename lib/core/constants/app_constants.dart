/// Application-wide constants following CLAUDE.md guidelines
class AppConstants {
  // App Information
  static const String appName = 'Quiz App';
  static const String appVersion = '1.0.0';

  // Environment Configuration
  static const String developmentEnvironment = 'development';
  static const String productionEnvironment = 'production';

  // Local Storage Keys
  static const String userSessionKey = 'user_session';
  static const String themePreferenceKey = 'theme_preference';
  static const String gameHistoryKey = 'game_history';

  // Error Messages
  static const String networkErrorMessage =
      'Network connection failed. Please check your internet connection.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';
  static const String firestoreErrorMessage =
      'Database operation failed. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Successfully logged in!';
  static const String quizCreatedMessage = 'Quiz created successfully!';
  static const String gameJoinedMessage = 'Successfully joined the game!';
}
