import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Sign in with Google use case
/// Implements Clean Architecture use case pattern
class SignInWithGoogleUseCase extends BaseUseCase<AuthEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  @override
  Future<Result<AuthEntity>> call(NoParams params) async {
    try {
      AppLogger.info('SignInWithGoogleUseCase: Attempting Google sign in');

      final result = await repository.signInWithGoogle();

      return result.when(
        success: (authEntity) {
          AppLogger.info('SignInWithGoogleUseCase: Google sign in successful');
          return Result.success(authEntity);
        },
        failure: (failure) {
          AppLogger.error(
            'SignInWithGoogleUseCase: Google sign in failed',
            failure,
          );
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('SignInWithGoogleUseCase: Unexpected error', e);
      return Result.failure(
        AuthFailure(
          message: 'An unexpected error occurred during Google sign in',
          code: 'unexpected-error',
        ),
      );
    }
  }
}
