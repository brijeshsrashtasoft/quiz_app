import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/email.dart';
import '../value_objects/password.dart';

/// Use case for updating user email address
/// Following CLAUDE.md security patterns and Result pattern
class UpdateEmailUseCase extends BaseUseCase<void, UpdateEmailParams> {
  final AuthRepository _authRepository;

  UpdateEmailUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<void>> call(UpdateEmailParams params) async {
    try {
      AppLogger.firebase(
        'UpdateEmailUseCase',
        'Attempting to update user email to: ${params.newEmail}',
      );

      // Check if user is signed in
      if (!_authRepository.isAuthenticated) {
        return Result.failure(
          Failure.authFailure(
            message: 'Please sign in to update your email',
            code: 'AUTH_USER_NOT_SIGNED_IN',
          ),
        );
      }

      // Get current user
      final currentUserResult = _authRepository.getCurrentUser();
      if (currentUserResult.isFailure) {
        return Result.failure(
          Failure.authFailure(
            message: 'Unable to get current user information',
            code: 'AUTH_USER_NOT_FOUND',
          ),
        );
      }

      final currentUser = currentUserResult.dataOrNull;
      if (currentUser == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user currently signed in',
            code: 'AUTH_USER_NOT_SIGNED_IN',
          ),
        );
      }

      // Validate new email
      final emailValidation = Email.validate(params.newEmail);
      if (emailValidation.isFailure) {
        return Result.failure(emailValidation.failureOrNull!);
      }

      // Check that new email is different from current
      if (currentUser.email.toLowerCase() == params.newEmail.toLowerCase()) {
        return Result.failure(
          Failure.validationFailure(
            message: 'New email must be different from current email',
            fieldErrors: {
              'newEmail': 'New email must be different from current email',
            },
          ),
        );
      }

      // Validate password
      final passwordValidation = Password.validate(params.password);
      if (passwordValidation.isFailure) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Password is required for email update',
            fieldErrors: {'password': 'Password is required for email update'},
          ),
        );
      }

      final startTime = DateTime.now();

      final result = await _authRepository.updateEmail(
        newEmail: params.newEmail,
        password: params.password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update Email Use Case', duration);

      return result.when(
        success: (_) {
          AppLogger.firebase(
            'UpdateEmailUseCase',
            'Email updated successfully to: ${params.newEmail}',
          );
          return Result.success(null);
        },
        failure: (failure) {
          AppLogger.error(
            'Email update failed for: ${params.newEmail}',
            failure,
          );
          return Result.failure(failure);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during email update to: ${params.newEmail}',
        e,
        stackTrace,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to update email. Please try again',
          code: 'AUTH_EMAIL_UPDATE_ERROR',
        ),
      );
    }
  }
}

/// Parameters for UpdateEmailUseCase
class UpdateEmailParams {
  final String newEmail;
  final String password;

  const UpdateEmailParams({required this.newEmail, required this.password});

  @override
  String toString() =>
      'UpdateEmailParams(newEmail: $newEmail, password: [HIDDEN])';
}
