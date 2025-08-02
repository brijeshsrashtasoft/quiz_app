import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

/// Implementation of notification repository
/// Handles data operations with caching and error handling
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required NotificationLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Result<List<NotificationEntity>>> getNotifications(
    String userId,
  ) async {
    try {
      // Try to get from remote first
      final remoteNotifications = await _remoteDataSource.getNotifications(
        userId,
      );

      // Cache the results
      await _localDataSource.cacheNotifications(userId, remoteNotifications);

      // Convert to domain entities
      final entities = remoteNotifications
          .map((model) => model.toDomain())
          .toList();

      return Result.success(entities);
    } catch (e) {
      try {
        // Fall back to cache if remote fails
        final cachedNotifications = await _localDataSource
            .getCachedNotifications(userId);
        final entities = cachedNotifications
            .map((model) => model.toDomain())
            .toList();

        return Result.success(entities);
      } catch (cacheError) {
        return const Result.failure(
          Failure.networkFailure(message: 'Failed to load notifications'),
        );
      }
    }
  }

  @override
  Stream<Result<List<NotificationEntity>>> watchNotifications(String userId) {
    try {
      return _remoteDataSource
          .watchNotifications(userId)
          .map((notifications) {
            // Cache the notifications asynchronously
            _localDataSource.cacheNotifications(userId, notifications);

            // Convert to domain entities
            final entities = notifications
                .map((model) => model.toDomain())
                .toList();
            return Result.success(entities);
          })
          .handleError((error) {
            return Result.failure(
              Failure.networkFailure(message: error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(
        Result.failure(Failure.networkFailure(message: e.toString())),
      );
    }
  }

  @override
  Future<Result<int>> getUnreadCount(String userId) async {
    try {
      final count = await _remoteDataSource.getUnreadCount(userId);
      return Result.success(count);
    } catch (e) {
      try {
        // Fall back to cache
        final count = await _localDataSource.getCachedUnreadCount(userId);
        return Result.success(count);
      } catch (cacheError) {
        return Result.failure(Failure.networkFailure(message: e.toString()));
      }
    }
  }

  @override
  Stream<Result<int>> watchUnreadCount(String userId) {
    try {
      return _remoteDataSource
          .watchUnreadCount(userId)
          .map((count) {
            return Result.success(count);
          })
          .handleError((error) {
            return Result.failure(
              Failure.networkFailure(message: error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(
        Result.failure(Failure.networkFailure(message: e.toString())),
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);

      // Update cache
      await _localDataSource.updateCachedNotificationStatus(
        notificationId,
        true,
      );

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(message: e.toString(), code: 'MARK_READ_FAILED'),
      );
    }
  }

  @override
  Future<Result<void>> markAllAsRead(String userId) async {
    try {
      await _remoteDataSource.markAllAsRead(userId);

      // Update cache by getting fresh data
      final notifications = await _remoteDataSource.getNotifications(userId);
      await _localDataSource.cacheNotifications(userId, notifications);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: e.toString(),
          code: 'MARK_ALL_READ_FAILED',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);

      // Remove from cache
      await _localDataSource.removeCachedNotification(notificationId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(message: e.toString(), code: 'DELETE_FAILED'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAllNotifications(String userId) async {
    try {
      await _remoteDataSource.deleteAllNotifications(userId);

      // Clear cache
      await _localDataSource.clearCachedNotifications(userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(message: e.toString(), code: 'DELETE_ALL_FAILED'),
      );
    }
  }

  @override
  Future<Result<NotificationEntity>> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = notification.toModel();
      final createdModel = await _remoteDataSource.createNotification(model);

      return Result.success(createdModel.toDomain());
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(message: e.toString(), code: 'CREATE_FAILED'),
      );
    }
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotificationsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final allNotifications = await _remoteDataSource.getNotifications(userId);
      final entities = allNotifications
          .map((model) => model.toDomain())
          .toList();

      // Filter by category
      final filteredNotifications = entities
          .where((n) => n.category == category)
          .toList();

      return Result.success(filteredNotifications);
    } catch (e) {
      return Result.failure(Failure.networkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    try {
      final allNotifications = await _remoteDataSource.getNotifications(userId);
      final entities = allNotifications
          .map((model) => model.toDomain())
          .toList();

      // Filter by type (this is a simplified implementation - in production,
      // you might want to implement proper type comparison)
      final filteredNotifications = entities.where((n) {
        return n.type.toString() == type.toString();
      }).toList();

      return Result.success(filteredNotifications);
    } catch (e) {
      return Result.failure(Failure.networkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<NotificationEntity>>> getRecentNotifications(
    String userId,
  ) async {
    try {
      final allNotifications = await _remoteDataSource.getNotifications(userId);
      final entities = allNotifications
          .map((model) => model.toDomain())
          .toList();

      // Filter for notifications from last 24 hours
      final now = DateTime.now();
      final oneDayAgo = now.subtract(const Duration(days: 1));

      final recentNotifications = entities.where((n) {
        return n.timestamp.isAfter(oneDayAgo);
      }).toList();

      return Result.success(recentNotifications);
    } catch (e) {
      return Result.failure(Failure.networkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<NotificationEntity>>> searchNotifications(
    String userId,
    String query,
  ) async {
    try {
      final allNotifications = await _remoteDataSource.getNotifications(userId);
      final entities = allNotifications
          .map((model) => model.toDomain())
          .toList();

      // Simple search implementation
      final searchQuery = query.toLowerCase();
      final searchResults = entities.where((n) {
        return n.title.toLowerCase().contains(searchQuery) ||
            n.message.toLowerCase().contains(searchQuery);
      }).toList();

      return Result.success(searchResults);
    } catch (e) {
      return Result.failure(Failure.networkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> bulkMarkAsRead(List<String> notificationIds) async {
    try {
      await _remoteDataSource.bulkMarkAsRead(notificationIds);

      // Update cache for each notification
      for (final id in notificationIds) {
        await _localDataSource.updateCachedNotificationStatus(id, true);
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: e.toString(),
          code: 'BULK_MARK_READ_FAILED',
        ),
      );
    }
  }

  @override
  Future<Result<void>> bulkDeleteNotifications(
    List<String> notificationIds,
  ) async {
    try {
      await _remoteDataSource.bulkDeleteNotifications(notificationIds);

      // Remove from cache
      for (final id in notificationIds) {
        await _localDataSource.removeCachedNotification(id);
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: e.toString(),
          code: 'BULK_DELETE_FAILED',
        ),
      );
    }
  }
}
