/// Firebase configuration constants and collection names
/// Following CLAUDE.md guidelines for centralized constants
class FirebaseConstants {
  // Firestore Collection Names
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String gameSessionsCollection = 'game_sessions';
  static const String leaderboardsCollection = 'leaderboards';

  // Auth Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 3;

  // Game Configuration
  static const int maxPlayersPerSession = 50;
  static const int gameSessionExpiryHours = 24;
  static const int questionTimeoutSeconds = 30;

  // Real-time Performance Requirements (from CLAUDE.md)
  static const int maxLatencyMs = 200;
  static const int connectionTimeoutSeconds = 10;

  // Security Rules Constants
  static const List<String> requiredUserFields = ['name', 'email', 'createdAt'];

  static const List<String> requiredQuizFields = [
    'title',
    'description',
    'createdBy',
    'questions',
    'isPublic',
    'createdAt',
  ];
}
