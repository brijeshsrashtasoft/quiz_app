import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/password.dart';

/// Use case for updating user password
/// Following CLAUDE.md security patterns and Result pattern
class UpdatePasswordUseCase extends BaseUseCase<void, UpdatePasswordParams> {
  final AuthRepository _authRepository;

  UpdatePasswordUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<void>> call(UpdatePasswordParams params) async {
    try {
      AppLogger.firebase(
        'UpdatePasswordUseCase',
        'Attempting to update user password',
      );

      // Check if user is signed in
      if (!_authRepository.isAuthenticated) {
        return Result.failure(
          Failure.authFailure(
            message: 'Please sign in to update your password',
            code: 'AUTH_USER_NOT_SIGNED_IN',
          ),
        );
      }

      // Validate current password
      final currentPasswordValidation = Password.validate(
        params.currentPassword,
      );
      if (currentPasswordValidation.isFailure) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Current password is invalid',
            fieldErrors: {'currentPassword': 'Current password is required'},
          ),
        );
      }

      // Validate new password
      final newPasswordValidation = Password.validate(params.newPassword);
      if (newPasswordValidation.isFailure) {
        return Result.failure(newPasswordValidation.failureOrNull!);
      }

      // Check that new password is different from current
      if (params.currentPassword == params.newPassword) {
        return Result.failure(
          Failure.validationFailure(
            message: 'New password must be different from current password',
            fieldErrors: {
              'newPassword':
                  'New password must be different from current password',
            },
          ),
        );
      }

      // Check password strength
      final newPasswordStrength = Password.checkStrength(params.newPassword);
      if (!newPasswordStrength.meetsRequirements) {
        return Result.failure(
          Failure.validationFailure(
            message: 'New password does not meet security requirements',
            fieldErrors: {'newPassword': 'Password must be stronger'},
          ),
        );
      }

      final startTime = DateTime.now();

      final result = await _authRepository.updatePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update Password Use Case', duration);

      return result.when(
        success: (_) {
          AppLogger.firebase(
            'UpdatePasswordUseCase',
            'Password updated successfully',
          );
          return Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('Password update failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during password update', e, stackTrace);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to update password. Please try again',
          code: 'AUTH_PASSWORD_UPDATE_ERROR',
        ),
      );
    }
  }
}

/// Parameters for UpdatePasswordUseCase
class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  String toString() =>
      'UpdatePasswordParams(currentPassword: [HIDDEN], newPassword: [HIDDEN])';
}
