class AppConstants {
  // App Info
  static const String appName = 'Quiz App';
  static const String appVersion = '1.0.0';
  
  // Firestore Configuration
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String gameSessionsCollection = 'game_sessions';
  static const String leaderboardsCollection = 'leaderboards';
  
  // Game Configuration
  static const int maxPlayersPerGame = 50;
  static const Duration questionTimeLimit = Duration(seconds: 30);
  static const Duration gameJoinTimeLimit = Duration(minutes: 5);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}