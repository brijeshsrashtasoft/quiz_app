import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Stream use case for watching user changes in real-time
/// Following CLAUDE.md real-time requirements (<200ms latency)
class WatchUserUseCase extends BaseStreamUseCase<UserEntity, WatchUserParams> {
  final UserRepository repository;

  WatchUserUseCase({required this.repository});

  @override
  Stream<Result<UserEntity>> call(WatchUserParams params) {
    return repository.watchUser(params.userId);
  }
}

/// Parameters for WatchUserUseCase
class WatchUserParams {
  final String userId;

  const WatchUserParams({required this.userId});
}
