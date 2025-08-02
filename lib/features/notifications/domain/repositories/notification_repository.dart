import '../../../../core/utils/result.dart';
import '../entities/notification_entity.dart';

/// Abstract notification repository interface
/// Defines contract for notification data operations
abstract class NotificationRepository {
  /// Get all notifications for a user
  Future<Result<List<NotificationEntity>>> getNotifications(String userId);

  /// Get notifications stream for real-time updates
  Stream<Result<List<NotificationEntity>>> watchNotifications(String userId);

  /// Get unread notification count
  Future<Result<int>> getUnreadCount(String userId);

  /// Get unread count stream for real-time updates
  Stream<Result<int>> watchUnreadCount(String userId);

  /// Mark notification as read
  Future<Result<void>> markAsRead(String notificationId);

  /// Mark all notifications as read for user
  Future<Result<void>> markAllAsRead(String userId);

  /// Delete notification
  Future<Result<void>> deleteNotification(String notificationId);

  /// Delete all notifications for user
  Future<Result<void>> deleteAllNotifications(String userId);

  /// Create new notification (for system/admin use)
  Future<Result<NotificationEntity>> createNotification(
    NotificationEntity notification,
  );

  /// Get notifications by category
  Future<Result<List<NotificationEntity>>> getNotificationsByCategory(
    String userId,
    String category,
  );

  /// Get notifications by type
  Future<Result<List<NotificationEntity>>> getNotificationsByType(
    String userId,
    NotificationType type,
  );

  /// Get recent notifications (last 24 hours)
  Future<Result<List<NotificationEntity>>> getRecentNotifications(
    String userId,
  );

  /// Search notifications by title or message
  Future<Result<List<NotificationEntity>>> searchNotifications(
    String userId,
    String query,
  );

  /// Bulk mark notifications as read
  Future<Result<void>> bulkMarkAsRead(List<String> notificationIds);

  /// Bulk delete notifications
  Future<Result<void>> bulkDeleteNotifications(List<String> notificationIds);
}
