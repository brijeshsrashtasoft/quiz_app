import '../../../../core/utils/result.dart';
import '../models/notification_model.dart';
import '../../domain/failures/notification_failure.dart';

/// Abstract local data source for notifications
/// Defines contract for local notification storage (cache, offline support)
abstract class NotificationLocalDataSource {
  /// Cache notifications locally
  Future<void> cacheNotifications(
    String userId,
    List<NotificationModel> notifications,
  );

  /// Get cached notifications
  Future<List<NotificationModel>> getCachedNotifications(String userId);

  /// Get cached unread count
  Future<int> getCachedUnreadCount(String userId);

  /// Update cached notification status
  Future<void> updateCachedNotificationStatus(
    String notificationId,
    bool isRead,
  );

  /// Remove cached notification
  Future<void> removeCachedNotification(String notificationId);

  /// Clear all cached notifications for user
  Future<void> clearCachedNotifications(String userId);

  /// Check if notifications are cached
  Future<bool> hasCache(String userId);

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp(String userId);
}

/// Local data source implementation using dummy data
/// For development and testing purposes
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  // In-memory cache for development
  final Map<String, List<NotificationModel>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  @override
  Future<void> cacheNotifications(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    try {
      _cache[userId] = List.from(notifications);
      _cacheTimestamps[userId] = DateTime.now();
    } catch (e) {
      throw Exception('Failed to cache notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications(String userId) async {
    try {
      return _cache[userId] ?? [];
    } catch (e) {
      throw Exception('Failed to get cached notifications: $e');
    }
  }

  @override
  Future<int> getCachedUnreadCount(String userId) async {
    try {
      final notifications = _cache[userId] ?? [];
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      throw Exception('Failed to get cached unread count: $e');
    }
  }

  @override
  Future<void> updateCachedNotificationStatus(
    String notificationId,
    bool isRead,
  ) async {
    try {
      for (final userId in _cache.keys) {
        final notifications = _cache[userId] ?? [];
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = notifications[index].copyWith(
            isRead: isRead,
          );
          notifications[index] = updatedNotification;
          _cache[userId] = notifications;
          _cacheTimestamps[userId] = DateTime.now();
          break;
        }
      }
    } catch (e) {
      throw Exception('Failed to update cached notification status: $e');
    }
  }

  @override
  Future<void> removeCachedNotification(String notificationId) async {
    try {
      for (final userId in _cache.keys) {
        final notifications = _cache[userId] ?? [];
        notifications.removeWhere((n) => n.id == notificationId);
        _cache[userId] = notifications;
        _cacheTimestamps[userId] = DateTime.now();
      }
    } catch (e) {
      throw Exception('Failed to remove cached notification: $e');
    }
  }

  @override
  Future<void> clearCachedNotifications(String userId) async {
    try {
      _cache.remove(userId);
      _cacheTimestamps.remove(userId);
    } catch (e) {
      throw Exception('Failed to clear cached notifications: $e');
    }
  }

  @override
  Future<bool> hasCache(String userId) async {
    try {
      return _cache.containsKey(userId) &&
          (_cache[userId]?.isNotEmpty ?? false);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String userId) async {
    try {
      return _cacheTimestamps[userId];
    } catch (e) {
      return null;
    }
  }
}
