import 'dart:async';
import 'dart:math';
import '../../../../core/utils/result.dart';
import '../models/notification_model.dart';
import '../../domain/failures/notification_failure.dart';

/// Abstract remote data source for notifications
/// Defines contract for remote notification operations (Firebase, API, etc.)
abstract class NotificationRemoteDataSource {
  /// Get notifications from remote source
  Future<List<NotificationModel>> getNotifications(String userId);

  /// Get notifications stream for real-time updates
  Stream<List<NotificationModel>> watchNotifications(String userId);

  /// Get unread notification count
  Future<int> getUnreadCount(String userId);

  /// Get unread count stream for real-time updates
  Stream<int> watchUnreadCount(String userId);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read for user
  Future<void> markAllAsRead(String userId);

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Delete all notifications for user
  Future<void> deleteAllNotifications(String userId);

  /// Create new notification
  Future<NotificationModel> createNotification(NotificationModel notification);

  /// Bulk mark notifications as read
  Future<void> bulkMarkAsRead(List<String> notificationIds);

  /// Bulk delete notifications
  Future<void> bulkDeleteNotifications(List<String> notificationIds);
}

/// Remote data source implementation with dummy data
/// For development and testing purposes - simulates Firebase/API behavior
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  // Simulated storage for development
  final Map<String, List<NotificationModel>> _userNotifications = {};
  final StreamController<Map<String, List<NotificationModel>>>
  _notificationsController = StreamController.broadcast();

  // Initialize with dummy data
  NotificationRemoteDataSourceImpl() {
    _initializeDummyData();
  }

  /// Initialize with sample notifications for testing
  void _initializeDummyData() {
    final now = DateTime.now();

    // Create sample notifications for user 'demo_user'
    _userNotifications['demo_user'] = [
      NotificationModel(
        id: 'notif_1',
        title: 'Quiz Invitation',
        message: 'Sarah invited you to play "Science Quiz Pro"',
        type: const NotificationTypeModel.quizInvite(
          quizId: 'quiz_123',
          fromUserId: 'user_sarah',
          fromUserName: 'Sarah Miller',
        ),
        timestamp: now.subtract(const Duration(minutes: 30)).toIso8601String(),
        userId: 'demo_user',
        isRead: false,
        actionUrl: '/quiz/quiz_123',
        imageUrl: 'https://via.placeholder.com/48x48/6C5CE7/ffffff?text=Q',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Achievement Unlocked!',
        message: 'Congratulations! You earned "Quiz Master" achievement',
        type: const NotificationTypeModel.achievementUnlocked(
          achievementId: 'achievement_quiz_master',
          achievementName: 'Quiz Master',
          achievementDescription: 'Complete 50 quizzes with 80% accuracy',
          pointsEarned: 500,
        ),
        timestamp: now.subtract(const Duration(hours: 2)).toIso8601String(),
        userId: 'demo_user',
        isRead: false,
        imageUrl: 'https://via.placeholder.com/48x48/FFD700/ffffff?text=🏆',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Game Results',
        message: 'Great job! You scored 850 points in "Math Challenge"',
        type: const NotificationTypeModel.gameResult(
          gameSessionId: 'game_456',
          finalScore: 850,
          totalQuestions: 10,
          correctAnswers: 8,
          leaderboardPosition: '3rd',
        ),
        timestamp: now.subtract(const Duration(hours: 4)).toIso8601String(),
        userId: 'demo_user',
        isRead: true,
        actionUrl: '/leaderboard/session/game_456',
        imageUrl: 'https://via.placeholder.com/48x48/00D2D3/ffffff?text=🎯',
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'Game Invitation',
        message: 'Alex started a live game! Join now with PIN: 123456',
        type: const NotificationTypeModel.gameInvite(
          gameSessionId: 'live_game_789',
          gamePin: '123456',
          fromUserId: 'user_alex',
          fromUserName: 'Alex Johnson',
        ),
        timestamp: now.subtract(const Duration(minutes: 5)).toIso8601String(),
        userId: 'demo_user',
        isRead: false,
        actionUrl: '/game/join?pin=123456',
        imageUrl: 'https://via.placeholder.com/48x48/FF6B6B/ffffff?text=🎮',
      ),
      NotificationModel(
        id: 'notif_5',
        title: 'Friend Request',
        message: 'Mike wants to be your quiz buddy!',
        type: const NotificationTypeModel.friendRequest(
          fromUserId: 'user_mike',
          fromUserName: 'Mike Davis',
          fromUserAvatar:
              'https://via.placeholder.com/48x48/4ECDC4/ffffff?text=MD',
        ),
        timestamp: now.subtract(const Duration(days: 1)).toIso8601String(),
        userId: 'demo_user',
        isRead: false,
        imageUrl: 'https://via.placeholder.com/48x48/4ECDC4/ffffff?text=MD',
      ),
      NotificationModel(
        id: 'notif_6',
        title: 'Quiz Liked',
        message: 'Emma liked your quiz "Geography Challenge"',
        type: const NotificationTypeModel.quizLiked(
          quizId: 'my_quiz_321',
          quizTitle: 'Geography Challenge',
          fromUserId: 'user_emma',
          fromUserName: 'Emma Wilson',
        ),
        timestamp: now.subtract(const Duration(days: 2)).toIso8601String(),
        userId: 'demo_user',
        isRead: true,
        actionUrl: '/quiz/my_quiz_321',
        imageUrl: 'https://via.placeholder.com/48x48/FFE66D/ffffff?text=❤️',
      ),
      NotificationModel(
        id: 'notif_7',
        title: 'Leaderboard Update',
        message: 'You moved up to 2nd place in "Weekly Challenge"!',
        type: const NotificationTypeModel.leaderboardUpdate(
          gameSessionId: 'weekly_challenge',
          oldPosition: '5th',
          newPosition: '2nd',
          isImprovement: true,
        ),
        timestamp: now.subtract(const Duration(days: 3)).toIso8601String(),
        userId: 'demo_user',
        isRead: true,
        actionUrl: '/leaderboard/session/weekly_challenge',
        imageUrl: 'https://via.placeholder.com/48x48/00D2D3/ffffff?text=📈',
      ),
      NotificationModel(
        id: 'notif_8',
        title: 'System Update',
        message: 'New features available! Check out the latest quiz templates.',
        type: const NotificationTypeModel.systemMessage(
          category: 'updates',
          priority: 'medium',
        ),
        timestamp: now.subtract(const Duration(days: 5)).toIso8601String(),
        userId: 'demo_user',
        isRead: false,
        imageUrl: 'https://via.placeholder.com/48x48/6C5CE7/ffffff?text=ℹ️',
      ),
    ];

    // Emit initial data
    _notificationsController.add(_userNotifications);
  }

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate random network failure (5% chance)
    if (Random().nextInt(100) < 5) {
      throw Exception('Network error: Failed to fetch notifications');
    }

    return _userNotifications[userId] ?? [];
  }

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    // Emit current data immediately and then listen for updates
    final controller = StreamController<List<NotificationModel>>();
    
    // Emit current data first
    controller.add(_userNotifications[userId] ?? []);
    
    // Listen to updates and emit them
    _notificationsController.stream.listen((allNotifications) {
      controller.add(allNotifications[userId] ?? []);
    });
    
    return controller.stream;
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final notifications = _userNotifications[userId] ?? [];
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    // Emit current data immediately and then listen for updates
    final controller = StreamController<int>();
    
    // Emit current count first
    final currentNotifications = _userNotifications[userId] ?? [];
    controller.add(currentNotifications.where((n) => !n.isRead).length);
    
    // Listen to updates and emit new counts
    _notificationsController.stream.listen((allNotifications) {
      final notifications = allNotifications[userId] ?? [];
      controller.add(notifications.where((n) => !n.isRead).length);
    });
    
    return controller.stream;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find and update notification
    for (final userId in _userNotifications.keys) {
      final notifications = _userNotifications[userId] ?? [];
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        _notificationsController.add(_userNotifications);
        break;
      }
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final notifications = _userNotifications[userId] ?? [];
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    _userNotifications[userId] = notifications;
    _notificationsController.add(_userNotifications);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // Find and remove notification
    for (final userId in _userNotifications.keys) {
      final notifications = _userNotifications[userId] ?? [];
      notifications.removeWhere((n) => n.id == notificationId);
      _userNotifications[userId] = notifications;
    }
    _notificationsController.add(_userNotifications);
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    _userNotifications[userId] = [];
    _notificationsController.add(_userNotifications);
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final notifications = _userNotifications[notification.userId] ?? [];
    notifications.insert(0, notification); // Add to beginning (newest first)
    _userNotifications[notification.userId] = notifications;
    _notificationsController.add(_userNotifications);

    return notification;
  }

  @override
  Future<void> bulkMarkAsRead(List<String> notificationIds) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    for (final userId in _userNotifications.keys) {
      final notifications = _userNotifications[userId] ?? [];
      for (int i = 0; i < notifications.length; i++) {
        if (notificationIds.contains(notifications[i].id)) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      _userNotifications[userId] = notifications;
    }
    _notificationsController.add(_userNotifications);
  }

  @override
  Future<void> bulkDeleteNotifications(List<String> notificationIds) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    for (final userId in _userNotifications.keys) {
      final notifications = _userNotifications[userId] ?? [];
      notifications.removeWhere((n) => notificationIds.contains(n.id));
      _userNotifications[userId] = notifications;
    }
    _notificationsController.add(_userNotifications);
  }

  /// Dispose resources
  void dispose() {
    _notificationsController.close();
  }
}
