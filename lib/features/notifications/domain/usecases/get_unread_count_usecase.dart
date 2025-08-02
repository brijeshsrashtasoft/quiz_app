import '../../../../core/base/base_usecase.dart';
import '../../../../core/usecases/stream_usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_unread_count_usecase.freezed.dart';

/// Use case for getting unread notification count
class GetUnreadCountUseCase extends BaseUseCase<int, GetUnreadCountParams> {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  @override
  Future<Result<int>> call(GetUnreadCountParams params) async {
    return _repository.getUnreadCount(params.userId);
  }
}

/// Use case for watching unread notification count in real-time
class WatchUnreadCountUseCase extends StreamUseCase<int, GetUnreadCountParams> {
  final NotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  @override
  Stream<Result<int>> call(GetUnreadCountParams params) {
    return _repository.watchUnreadCount(params.userId);
  }
}

/// Parameters for getting unread count
@freezed
class GetUnreadCountParams
    with _$GetUnreadCountParams
    implements BaseUseCaseParams {
  const factory GetUnreadCountParams({required String userId}) =
      _GetUnreadCountParams;
}
