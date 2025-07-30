import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google
/// Following CLAUDE.md authentication patterns and free tier services
class SignInWithGoogleUseCase extends BaseUseCase<UserEntity, NoParams> {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<UserEntity>> call(NoParams params) async {
    try {
      AppLogger.firebase(
        'SignInWithGoogleUseCase',
        'Attempting Google sign in',
      );

      final startTime = DateTime.now();

      final result = await _authRepository.signInWithGoogle();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Google Sign In Use Case', duration);

      return result.when(
        success: (user) {
          AppLogger.firebase(
            'SignInWithGoogleUseCase',
            'Google sign in successful: ${user.email}',
          );
          return Result.success(user);
        },
        failure: (failure) {
          AppLogger.error('Google sign in failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Google sign in', e, stackTrace);
      return Result.failure(
        Failure.authFailure(
          message: 'Google sign in failed. Please try again',
          code: 'AUTH_GOOGLE_SIGNIN_ERROR',
        ),
      );
    }
  }
}
