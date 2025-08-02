import '../../../../core/usecases/stream_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'watch_notifications_usecase.freezed.dart';

/// Use case for watching user notifications in real-time
class WatchNotificationsUseCase
    extends StreamUseCase<List<NotificationEntity>, WatchNotificationsParams> {
  final NotificationRepository _repository;

  WatchNotificationsUseCase(this._repository);

  @override
  Stream<Result<List<NotificationEntity>>> call(
    WatchNotificationsParams params,
  ) {
    return _repository.watchNotifications(params.userId).map((result) {
      return result.when(
        success: (notifications) {
          // Sort notifications by priority and timestamp
          final sortedNotifications = List<NotificationEntity>.from(
            notifications,
          );
          sortedNotifications.sort((a, b) {
            // First sort by priority (lower number = higher priority)
            final priorityComparison = a.priority.compareTo(b.priority);
            if (priorityComparison != 0) return priorityComparison;

            // Then sort by timestamp (newer first)
            return b.timestamp.compareTo(a.timestamp);
          });

          // Filter out expired notifications if requested
          if (params.excludeExpired) {
            final validNotifications = sortedNotifications
                .where((n) => !n.isExpired)
                .toList();
            return Result.success(validNotifications);
          }

          return Result.success(sortedNotifications);
        },
        failure: (failure) => Result.failure(failure),
      );
    });
  }
}

/// Parameters for watching notifications
@freezed
class WatchNotificationsParams with _$WatchNotificationsParams {
  const factory WatchNotificationsParams({
    required String userId,
    @Default(false) bool excludeExpired,
  }) = _WatchNotificationsParams;
}
