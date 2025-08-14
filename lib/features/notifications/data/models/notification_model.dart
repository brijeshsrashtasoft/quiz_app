import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification model for data layer
/// Handles JSON serialization and conversion to domain entities
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String message,
    required NotificationTypeModel type,
    required String timestamp,
    required String userId,
    @Default(false) bool isRead,
    Map<String, dynamic>? metadata,
    String? actionUrl,
    String? imageUrl,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

/// Notification type model for JSON serialization
@freezed
class NotificationTypeModel with _$NotificationTypeModel {
  const factory NotificationTypeModel.quizInvite({
    required String quizId,
    required String fromUserId,
    required String fromUserName,
  }) = _QuizInviteNotificationModel;

  const factory NotificationTypeModel.gameInvite({
    required String gameSessionId,
    required String gamePin,
    required String fromUserId,
    required String fromUserName,
  }) = _GameInviteNotificationModel;

  const factory NotificationTypeModel.achievementUnlocked({
    required String achievementId,
    required String achievementName,
    required String achievementDescription,
    required int pointsEarned,
  }) = _AchievementNotificationModel;

  const factory NotificationTypeModel.gameResult({
    required String gameSessionId,
    required int finalScore,
    required int totalQuestions,
    required int correctAnswers,
    required String leaderboardPosition,
  }) = _GameResultNotificationModel;

  const factory NotificationTypeModel.friendRequest({
    required String fromUserId,
    required String fromUserName,
    required String fromUserAvatar,
  }) = _FriendRequestNotificationModel;

  const factory NotificationTypeModel.quizLiked({
    required String quizId,
    required String quizTitle,
    required String fromUserId,
    required String fromUserName,
  }) = _QuizLikedNotificationModel;

  const factory NotificationTypeModel.leaderboardUpdate({
    required String gameSessionId,
    required String oldPosition,
    required String newPosition,
    required bool isImprovement,
  }) = _LeaderboardUpdateNotificationModel;

  const factory NotificationTypeModel.systemMessage({
    required String category,
    required String priority,
  }) = _SystemMessageNotificationModel;

  factory NotificationTypeModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationTypeModelFromJson(json);
}

/// Extension for converting models to domain entities
extension NotificationModelX on NotificationModel {
  /// Convert model to domain entity
  NotificationEntity toDomain() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: type.toDomain(),
      timestamp: DateTime.parse(timestamp),
      userId: userId,
      isRead: isRead,
      metadata: metadata,
      actionUrl: actionUrl,
      imageUrl: imageUrl,
    );
  }
}

/// Extension for converting notification type models to domain entities
extension NotificationTypeModelX on NotificationTypeModel {
  /// Convert type model to domain entity
  NotificationType toDomain() {
    return when(
      quizInvite: (quizId, fromUserId, fromUserName) =>
          NotificationType.quizInvite(
            quizId: quizId,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
          ),
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          NotificationType.gameInvite(
            gameSessionId: gameSessionId,
            gamePin: gamePin,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
          ),
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => NotificationType.achievementUnlocked(
            achievementId: achievementId,
            achievementName: achievementName,
            achievementDescription: achievementDescription,
            pointsEarned: pointsEarned,
          ),
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => NotificationType.gameResult(
            gameSessionId: gameSessionId,
            finalScore: finalScore,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            leaderboardPosition: leaderboardPosition,
          ),
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) =>
          NotificationType.friendRequest(
            fromUserId: fromUserId,
            fromUserName: fromUserName,
            fromUserAvatar: fromUserAvatar,
          ),
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) =>
          NotificationType.quizLiked(
            quizId: quizId,
            quizTitle: quizTitle,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
          ),
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) =>
              NotificationType.leaderboardUpdate(
                gameSessionId: gameSessionId,
                oldPosition: oldPosition,
                newPosition: newPosition,
                isImprovement: isImprovement,
              ),
      systemMessage: (category, priority) => NotificationType.systemMessage(
        category: category,
        priority: _stringToPriority(priority),
      ),
    );
  }
}

/// Extension for converting domain entities to models
extension NotificationEntityX on NotificationEntity {
  /// Convert domain entity to model
  NotificationModel toModel() {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type.toModel(),
      timestamp: timestamp.toIso8601String(),
      userId: userId,
      isRead: isRead,
      metadata: metadata,
      actionUrl: actionUrl,
      imageUrl: imageUrl,
    );
  }
}

/// Extension for converting domain notification types to models
extension NotificationTypeEntityX on NotificationType {
  /// Convert domain type to model
  NotificationTypeModel toModel() {
    return when(
      quizInvite: (quizId, fromUserId, fromUserName) =>
          NotificationTypeModel.quizInvite(
            quizId: quizId,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
          ),
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          NotificationTypeModel.gameInvite(
            gameSessionId: gameSessionId,
            gamePin: gamePin,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
          ),
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => NotificationTypeModel.achievementUnlocked(
            achievementId: achievementId,
            achievementName: achievementName,
            achievementDescription: achievementDescription,
            pointsEarned: pointsEarned,
          ),
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => NotificationTypeModel.gameResult(
            gameSessionId: gameSessionId,
            finalScore: finalScore,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            leaderboardPosition: leaderboardPosition,
          ),
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) =>
          NotificationTypeModel.friendRequest(
            fromUserId: fromUserId,
            fromUserName: fromUserName,
            fromUserAvatar: fromUserAvatar,
          ),
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) =>
          NotificationTypeModel.quizLiked(
            quizId: quizId,
            quizTitle: quizTitle,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
          ),
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) =>
              NotificationTypeModel.leaderboardUpdate(
                gameSessionId: gameSessionId,
                oldPosition: oldPosition,
                newPosition: newPosition,
                isImprovement: isImprovement,
              ),
      systemMessage: (category, priority) =>
          NotificationTypeModel.systemMessage(
            category: category,
            priority: _priorityToString(priority),
          ),
    );
  }
}

/// Helper function to convert string to priority enum
SystemMessagePriority _stringToPriority(String priority) {
  switch (priority.toLowerCase()) {
    case 'low':
      return SystemMessagePriority.low;
    case 'medium':
      return SystemMessagePriority.medium;
    case 'high':
      return SystemMessagePriority.high;
    case 'urgent':
      return SystemMessagePriority.urgent;
    default:
      return SystemMessagePriority.low;
  }
}

/// Helper function to convert priority enum to string
String _priorityToString(SystemMessagePriority priority) {
  switch (priority) {
    case SystemMessagePriority.low:
      return 'low';
    case SystemMessagePriority.medium:
      return 'medium';
    case SystemMessagePriority.high:
      return 'high';
    case SystemMessagePriority.urgent:
      return 'urgent';
  }
}
