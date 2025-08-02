import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_notification_usecase.freezed.dart';

/// Use case for deleting notifications
class DeleteNotificationUseCase
    extends BaseUseCase<void, DeleteNotificationParams> {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  @override
  Future<Result<void>> call(DeleteNotificationParams params) async {
    return params.when(
      single: (notificationId) =>
          _repository.deleteNotification(notificationId),
      all: (userId) => _repository.deleteAllNotifications(userId),
      bulk: (notificationIds) =>
          _repository.bulkDeleteNotifications(notificationIds),
    );
  }
}

/// Parameters for deleting notifications
@freezed
class DeleteNotificationParams
    with _$DeleteNotificationParams
    implements BaseUseCaseParams {
  /// Delete single notification
  const factory DeleteNotificationParams.single({
    required String notificationId,
  }) = _DeleteNotificationSingleParams;

  /// Delete all notifications for user
  const factory DeleteNotificationParams.all({required String userId}) =
      _DeleteNotificationAllParams;

  /// Delete multiple notifications
  const factory DeleteNotificationParams.bulk({
    required List<String> notificationIds,
  }) = _DeleteNotificationBulkParams;
}
