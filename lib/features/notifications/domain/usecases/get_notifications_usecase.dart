import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_notifications_usecase.freezed.dart';

/// Use case for getting user notifications
class GetNotificationsUseCase
    extends BaseUseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Result<List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) async {
    final result = await _repository.getNotifications(params.userId);

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
  }
}

/// Parameters for getting notifications
@freezed
class GetNotificationsParams
    with _$GetNotificationsParams
    implements BaseUseCaseParams {
  const factory GetNotificationsParams({
    required String userId,
    @Default(false) bool excludeExpired,
  }) = _GetNotificationsParams;
}
