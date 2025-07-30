import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/password.dart';

/// Use case for re-authenticating user before sensitive operations
/// Following CLAUDE.md security patterns and Result pattern
class ReauthenticateUseCase extends BaseUseCase<void, ReauthenticateParams> {
  final AuthRepository _authRepository;

  ReauthenticateUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<void>> call(ReauthenticateParams params) async {
    try {
      AppLogger.firebase(
        'ReauthenticateUseCase',
        'Attempting to re-authenticate user',
      );

      // Check if user is signed in
      if (!_authRepository.isAuthenticated) {
        return Result.failure(
          Failure.authFailure(
            message: 'Please sign in to continue',
            code: 'AUTH_USER_NOT_SIGNED_IN',
          ),
        );
      }

      // Validate password
      final passwordValidation = Password.validate(params.password);
      if (passwordValidation.isFailure) {
        return Result.failure(passwordValidation.failureOrNull!);
      }

      final startTime = DateTime.now();

      final result = await _authRepository.reauthenticate(
        password: params.password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Reauthenticate Use Case', duration);

      return result.when(
        success: (_) {
          AppLogger.firebase(
            'ReauthenticateUseCase',
            'User re-authentication successful',
          );
          return Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('Re-authentication failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during re-authentication',
        e,
        stackTrace,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'Re-authentication failed. Please try again',
          code: 'AUTH_REAUTHENTICATION_ERROR',
        ),
      );
    }
  }
}

/// Parameters for ReauthenticateUseCase
class ReauthenticateParams {
  final String password;

  const ReauthenticateParams({required this.password});

  @override
  String toString() => 'ReauthenticateParams(password: [HIDDEN])';
}
