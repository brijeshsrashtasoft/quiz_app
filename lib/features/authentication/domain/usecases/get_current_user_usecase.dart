import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current authenticated user
/// Following CLAUDE.md Clean Architecture patterns
class GetCurrentUserUseCase extends BaseUseCaseNoParams<UserEntity?> {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  @override
  Future<Result<UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}

/// Use case for checking if user is authenticated
/// Following CLAUDE.md Clean Architecture patterns
class IsAuthenticatedUseCase extends BaseUseCaseNoParams<bool> {
  final AuthRepository repository;

  IsAuthenticatedUseCase({required this.repository});

  @override
  Future<Result<bool>> call() async {
    final isAuthenticated = repository.isAuthenticated();
    return Result.success(isAuthenticated);
  }
}

/// Use case for watching authentication state changes
/// Following CLAUDE.md real-time patterns
class WatchAuthStateUseCase extends BaseStreamUseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  WatchAuthStateUseCase({required this.repository});

  @override
  Stream<Result<UserEntity?>> call(NoParams params) {
    return repository.watchAuthState();
  }
}
