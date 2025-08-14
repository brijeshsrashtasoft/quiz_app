/// Route constants for type-safe navigation
/// All routes are defined here to prevent typos and enable refactoring
class RouteConstants {
  RouteConstants._();

  // Root routes
  static const String root = '/';
  static const String splash = '/splash';

  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/register/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Home and dashboard
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Quiz creation flow
  static const String quizCreation = '/quiz-creation';
  static const String quizCreationForm = '/quiz-creation/form';
  static const String quizCreationPreview = '/quiz-creation/preview';
  static const String quizCreationPublish = '/quiz-creation/publish';
  static const String quizManagement = '/quiz-management';
  static const String quizDetails = '/quiz/:quizId';
  static const String quizEdit = '/quiz/:quizId/edit';

  // Game session flow
  static const String gameJoin = '/game/join';
  static const String gameSession = '/game/:sessionId';
  static const String gameWaiting = '/game/:sessionId/waiting';
  static const String gameQuestion = '/game/:sessionId/question/:questionIndex';
  static const String gameResults = '/game/:sessionId/results';
  static const String gameHost = '/game/host';
  static const String gameHostSetup = '/game/host/setup';
  static const String quizSelection = '/quiz-selection';

  // Leaderboard
  static const String leaderboard = '/leaderboard';
  static const String leaderboardGlobal = '/leaderboard/global';
  static const String leaderboardSession = '/leaderboard/session/:sessionId';

  // Notifications
  static const String notifications = '/notifications';

  // Settings and preferences
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';

  // Error and utility routes
  static const String notFound = '/404';
  static const String error = '/error';

  // Helper methods for dynamic routes
  static String quizDetailsPath(String quizId) => '/quiz/$quizId';
  static String quizEditPath(String quizId) => '/quiz/$quizId/edit';
  static String gameSessionPath(String sessionId) => '/game/$sessionId';
  static String gameWaitingPath(String sessionId) => '/game/$sessionId/waiting';
  static String gameQuestionPath(String sessionId, int questionIndex) =>
      '/game/$sessionId/question/$questionIndex';
  static String gameResultsPath(String sessionId) => '/game/$sessionId/results';
  static String leaderboardSessionPath(String sessionId) =>
      '/leaderboard/session/$sessionId';
}
