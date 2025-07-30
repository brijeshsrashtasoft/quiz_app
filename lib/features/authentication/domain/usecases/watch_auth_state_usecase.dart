import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for watching authentication state changes
/// Following CLAUDE.md authentication patterns and real-time updates
class WatchAuthStateUseCase extends BaseStreamUseCase<UserEntity?, NoParams> {
  final AuthRepository _authRepository;

  WatchAuthStateUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Stream<Result<UserEntity?>> call(NoParams params) {
    try {
      AppLogger.firebase(
        'WatchAuthStateUseCase',
        'Starting auth state monitoring',
      );

      return _authRepository.watchAuthState().map(
        (result) => result.when(
          success: (user) {
            AppLogger.firebase(
              'WatchAuthStateUseCase',
              'Auth state changed: ${user != null ? 'signed in (${user.email})' : 'signed out'}',
            );
            return Result.success(user);
          },
          failure: (failure) {
            AppLogger.error('Auth state error', failure);
            return Result.failure(failure);
          },
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to setup auth state monitoring', e, stackTrace);
      return Stream.value(
        Result.failure(
          const Failure.unknownFailure(
            message: 'Failed to monitor authentication state',
          ),
        ),
      );
    }
  }
}

/// Base class for stream use cases
abstract class BaseStreamUseCase<T, P> {
  Stream<Result<T>> call(P params);
}
