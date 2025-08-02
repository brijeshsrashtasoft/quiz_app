import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

/// Notification entity for Clean Architecture domain layer
/// Represents different types of notifications in the quiz app
@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String title,
    required String message,
    required NotificationType type,
    required DateTime timestamp,
    required String userId,
    @Default(false) bool isRead,
    Map<String, dynamic>? metadata,
    String? actionUrl,
    String? imageUrl,
  }) = _NotificationEntity;
}

/// Enum for different notification types following quiz app features
@freezed
class NotificationType with _$NotificationType {
  const factory NotificationType.quizInvite({
    required String quizId,
    required String fromUserId,
    required String fromUserName,
  }) = QuizInviteNotification;

  const factory NotificationType.gameInvite({
    required String gameSessionId,
    required String gamePin,
    required String fromUserId,
    required String fromUserName,
  }) = GameInviteNotification;

  const factory NotificationType.achievementUnlocked({
    required String achievementId,
    required String achievementName,
    required String achievementDescription,
    required int pointsEarned,
  }) = AchievementNotification;

  const factory NotificationType.gameResult({
    required String gameSessionId,
    required int finalScore,
    required int totalQuestions,
    required int correctAnswers,
    required String leaderboardPosition,
  }) = GameResultNotification;

  const factory NotificationType.friendRequest({
    required String fromUserId,
    required String fromUserName,
    required String fromUserAvatar,
  }) = FriendRequestNotification;

  const factory NotificationType.quizLiked({
    required String quizId,
    required String quizTitle,
    required String fromUserId,
    required String fromUserName,
  }) = QuizLikedNotification;

  const factory NotificationType.leaderboardUpdate({
    required String gameSessionId,
    required String oldPosition,
    required String newPosition,
    required bool isImprovement,
  }) = LeaderboardUpdateNotification;

  const factory NotificationType.systemMessage({
    required String category,
    required SystemMessagePriority priority,
  }) = SystemMessageNotification;
}

/// System message priority levels
enum SystemMessagePriority { low, medium, high, urgent }

/// Notification entity extensions for business logic
extension NotificationEntityX on NotificationEntity {
  /// Check if notification requires immediate action
  bool get requiresAction {
    return type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => true,
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) => true,
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) => true,
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => false,
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => false,
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) => false,
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) => false,
      systemMessage: (category, priority) =>
          priority == SystemMessagePriority.urgent,
    );
  }

  /// Check if notification has expired (older than 7 days for invites)
  bool get isExpired {
    final now = DateTime.now();
    final daysDifference = now.difference(timestamp).inDays;

    return type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => daysDifference > 7,
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          daysDifference > 1, // Game invites expire quickly
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) =>
          daysDifference > 30,
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => false, // Never expire
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => false, // Never expire
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) =>
          daysDifference > 14,
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) =>
              daysDifference > 7,
      systemMessage: (category, priority) =>
          priority == SystemMessagePriority.low ? daysDifference > 3 : false,
    );
  }

  /// Get notification priority for sorting
  int get priority {
    return type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => isRead ? 3 : 1,
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          isRead ? 2 : 0, // Highest priority
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) =>
          isRead ? 4 : 2,
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => isRead ? 6 : 5,
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => isRead ? 7 : 6,
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) =>
          isRead ? 8 : 7,
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) =>
              isRead ? 9 : 8,
      systemMessage: (category, priority) => switch (priority) {
        SystemMessagePriority.urgent => isRead ? 2 : 1,
        SystemMessagePriority.high => isRead ? 4 : 3,
        SystemMessagePriority.medium => isRead ? 6 : 5,
        SystemMessagePriority.low => isRead ? 10 : 9,
      },
    );
  }

  /// Get display icon for notification type
  String get iconName {
    return type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => 'quiz',
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          'videogame_asset',
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) => 'person_add',
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => 'emoji_events',
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => 'leaderboard',
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) => 'favorite',
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) =>
              'trending_up',
      systemMessage: (category, priority) => switch (priority) {
        SystemMessagePriority.urgent => 'priority_high',
        SystemMessagePriority.high => 'info',
        SystemMessagePriority.medium => 'announcement',
        SystemMessagePriority.low => 'message',
      },
    );
  }

  /// Get notification category for grouping
  String get category {
    return type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => 'invites',
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          'invites',
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) => 'social',
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => 'achievements',
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => 'results',
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) => 'social',
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) => 'results',
      systemMessage: (category, priority) => category,
    );
  }

  /// Check if notification is time-sensitive
  bool get isTimeSensitive {
    return type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => true,
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) => true,
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) => false,
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => false,
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => false,
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) => false,
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) => true,
      systemMessage: (category, priority) =>
          priority == SystemMessagePriority.urgent,
    );
  }
}
