import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mark_as_read_usecase.freezed.dart';

/// Use case for marking notifications as read
class MarkAsReadUseCase extends BaseUseCase<void, MarkAsReadParams> {
  final NotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  @override
  Future<Result<void>> call(MarkAsReadParams params) async {
    return params.when(
      single: (notificationId) => _repository.markAsRead(notificationId),
      all: (userId) => _repository.markAllAsRead(userId),
      bulk: (notificationIds) => _repository.bulkMarkAsRead(notificationIds),
    );
  }
}

/// Parameters for marking notifications as read
@freezed
class MarkAsReadParams with _$MarkAsReadParams implements BaseUseCaseParams {
  /// Mark single notification as read
  const factory MarkAsReadParams.single({required String notificationId}) =
      _MarkAsReadSingleParams;

  /// Mark all notifications as read for user
  const factory MarkAsReadParams.all({required String userId}) =
      _MarkAsReadAllParams;

  /// Mark multiple notifications as read
  const factory MarkAsReadParams.bulk({required List<String> notificationIds}) =
      _MarkAsReadBulkParams;
}
