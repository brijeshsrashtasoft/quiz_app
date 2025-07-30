/// Firebase configuration constants and collection names
/// Following CLAUDE.md guidelines for centralized constants
class FirebaseConstants {
  // Firestore Collection Names
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String gameSessionsCollection = 'game_sessions';
  static const String leaderboardsCollection = 'leaderboards';

  // Firebase Storage Paths
  static const String userAvatarsPath = 'users';
  static const String quizImagesPath = 'quizzes';
  static const String gameAttachmentsPath = 'game_sessions';

  // Storage Configuration (Free Tier Limits)
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB per file
  static const int maxUserStorageMB = 100; // 100MB per user recommended
  static const int totalStorageWarningGB =
      4; // Warning at 4GB (5GB free tier limit)
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Auth Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 3;
  static const int tokenRefreshThresholdMinutes = 5;
  static const int maxActiveSessions = 5;

  // Security Collections (subcollections under users)
  static const String sessionsSubcollection = 'sessions';
  static const String devicesSubcollection = 'devices';
  static const String securityEventsSubcollection = 'security_events';
  static const String settingsSubcollection = 'settings';
  static const String securitySettingsDoc = 'security';

  // Security Event Types
  static const String loginSuccessEvent = 'login_success';
  static const String loginFailedEvent = 'login_failed';
  static const String passwordChangeEvent = 'password_change';
  static const String sessionTerminatedEvent = 'session_terminated';
  static const String suspiciousActivityEvent = 'suspicious_activity';
  static const String newDeviceEvent = 'new_device';
  static const String deviceRevokedEvent = 'device_revoked';

  // Security Severity Levels
  static const String lowSeverity = 'low';
  static const String mediumSeverity = 'medium';
  static const String highSeverity = 'high';
  static const String criticalSeverity = 'critical';

  // Device Trust Levels
  static const String unknownTrust = 'unknown';
  static const String trustedTrust = 'trusted';
  static const String suspiciousTrust = 'suspicious';
  static const String revokedTrust = 'revoked';

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
