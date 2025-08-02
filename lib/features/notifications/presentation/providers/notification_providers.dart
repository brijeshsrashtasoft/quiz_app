import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/watch_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../data/datasources/notification_local_datasource.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';

/// Notification repository provider
final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: NotificationRemoteDataSourceImpl(),
    localDataSource: NotificationLocalDataSourceImpl(),
  );
});

/// Get notifications use case provider
final getNotificationsUseCaseProvider = Provider((ref) {
  return GetNotificationsUseCase(ref.read(notificationRepositoryProvider));
});

/// Watch notifications use case provider
final watchNotificationsUseCaseProvider = Provider((ref) {
  return WatchNotificationsUseCase(ref.read(notificationRepositoryProvider));
});

/// Mark as read use case provider
final markAsReadUseCaseProvider = Provider((ref) {
  return MarkAsReadUseCase(ref.read(notificationRepositoryProvider));
});

/// Delete notification use case provider
final deleteNotificationUseCaseProvider = Provider((ref) {
  return DeleteNotificationUseCase(ref.read(notificationRepositoryProvider));
});

/// Get unread count use case provider
final getUnreadCountUseCaseProvider = Provider((ref) {
  return GetUnreadCountUseCase(ref.read(notificationRepositoryProvider));
});

/// Watch unread count use case provider
final watchUnreadCountUseCaseProvider = Provider((ref) {
  return WatchUnreadCountUseCase(ref.read(notificationRepositoryProvider));
});

/// Current user ID provider (simplified for demo - normally from auth)
final currentUserIdProvider = Provider<String>((ref) {
  return 'demo_user'; // In real app, get from authentication state
});

/// Notifications state provider - watches real-time notifications
final notificationsProvider = StreamProvider<Result<List<NotificationEntity>>>((
  ref,
) {
  final useCase = ref.read(watchNotificationsUseCaseProvider);
  final userId = ref.read(currentUserIdProvider);

  return useCase.call(
    WatchNotificationsParams(userId: userId, excludeExpired: true),
  );
});

/// Unread count provider - watches real-time unread count
final unreadCountProvider = StreamProvider<Result<int>>((ref) {
  final useCase = ref.read(watchUnreadCountUseCaseProvider);
  final userId = ref.read(currentUserIdProvider);

  return useCase.call(GetUnreadCountParams(userId: userId));
});

/// Filtered notifications by category
final notificationsByCategoryProvider =
    Provider.family<List<NotificationEntity>, String>((ref, category) {
      final notificationsAsync = ref.watch(notificationsProvider);

      return notificationsAsync.when(
        data: (result) => result.when(
          success: (notifications) =>
              notifications.where((n) => n.category == category).toList(),
          failure: (_) => [],
        ),
        loading: () => [],
        error: (_, __) => [],
      );
    });

/// Unread notifications provider
final unreadNotificationsProvider = Provider<List<NotificationEntity>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.when(
    data: (result) => result.when(
      success: (notifications) =>
          notifications.where((n) => !n.isRead).toList(),
      failure: (_) => [],
    ),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Recent notifications provider (last 24 hours)
final recentNotificationsProvider = Provider<List<NotificationEntity>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  final now = DateTime.now();
  final oneDayAgo = now.subtract(const Duration(days: 1));

  return notificationsAsync.when(
    data: (result) => result.when(
      success: (notifications) =>
          notifications.where((n) => n.timestamp.isAfter(oneDayAgo)).toList(),
      failure: (_) => [],
    ),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Notification categories provider
final notificationCategoriesProvider = Provider<AsyncValue<List<String>>>((
  ref,
) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.when(
    data: (result) => result.when(
      success: (notifications) {
        final categories = notifications
            .map((n) => n.category)
            .toSet()
            .toList();
        categories.sort();
        return AsyncValue.data(categories);
      },
      failure: (_) => const AsyncValue.data([]),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Notification actions notifier for managing state changes
final notificationActionsProvider =
    StateNotifierProvider<
      NotificationActionsNotifier,
      NotificationActionsState
    >((ref) {
      return NotificationActionsNotifier(
        markAsReadUseCase: ref.read(markAsReadUseCaseProvider),
        deleteNotificationUseCase: ref.read(deleteNotificationUseCaseProvider),
        userId: ref.read(currentUserIdProvider),
      );
    });

/// State for notification actions
class NotificationActionsState {
  final bool isLoading;
  final String? error;
  final Set<String> processingIds;

  const NotificationActionsState({
    this.isLoading = false,
    this.error,
    this.processingIds = const {},
  });

  NotificationActionsState copyWith({
    bool? isLoading,
    String? error,
    Set<String>? processingIds,
  }) {
    return NotificationActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      processingIds: processingIds ?? this.processingIds,
    );
  }
}

/// Notifier for handling notification actions
class NotificationActionsNotifier
    extends StateNotifier<NotificationActionsState> {
  final MarkAsReadUseCase _markAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final String _userId;

  NotificationActionsNotifier({
    required MarkAsReadUseCase markAsReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
    required String userId,
  }) : _markAsReadUseCase = markAsReadUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       _userId = userId,
       super(const NotificationActionsState());

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    if (state.processingIds.contains(notificationId)) return;

    state = state.copyWith(
      processingIds: {...state.processingIds, notificationId},
      error: null,
    );

    final result = await _markAsReadUseCase.call(
      MarkAsReadParams.single(notificationId: notificationId),
    );

    result.when(
      success: (_) {
        state = state.copyWith(
          processingIds: state.processingIds
              .where((id) => id != notificationId)
              .toSet(),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          processingIds: state.processingIds
              .where((id) => id != notificationId)
              .toSet(),
          error: failure.userMessage,
        );
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _markAsReadUseCase.call(
      MarkAsReadParams.all(userId: _userId),
    );

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.userMessage);
      },
    );
  }

  /// Delete single notification
  Future<void> deleteNotification(String notificationId) async {
    if (state.processingIds.contains(notificationId)) return;

    state = state.copyWith(
      processingIds: {...state.processingIds, notificationId},
      error: null,
    );

    final result = await _deleteNotificationUseCase.call(
      DeleteNotificationParams.single(notificationId: notificationId),
    );

    result.when(
      success: (_) {
        state = state.copyWith(
          processingIds: state.processingIds
              .where((id) => id != notificationId)
              .toSet(),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          processingIds: state.processingIds
              .where((id) => id != notificationId)
              .toSet(),
          error: failure.userMessage,
        );
      },
    );
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _deleteNotificationUseCase.call(
      DeleteNotificationParams.all(userId: _userId),
    );

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.userMessage);
      },
    );
  }

  /// Bulk mark as read
  Future<void> bulkMarkAsRead(List<String> notificationIds) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _markAsReadUseCase.call(
      MarkAsReadParams.bulk(notificationIds: notificationIds),
    );

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.userMessage);
      },
    );
  }

  /// Bulk delete notifications
  Future<void> bulkDeleteNotifications(List<String> notificationIds) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _deleteNotificationUseCase.call(
      DeleteNotificationParams.bulk(notificationIds: notificationIds),
    );

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.userMessage);
      },
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
