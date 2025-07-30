import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';

/// Use case for sending password reset email
/// Following CLAUDE.md authentication patterns and Result pattern
class ResetPasswordUseCase extends BaseUseCase<void, ResetPasswordParams> {
  ResetPasswordUseCase();

  @override
  Future<Result<void>> call(ResetPasswordParams params) async {
    try {
      AppLogger.firebase(
        'ResetPasswordUseCase',
        'Attempting password reset for: ${params.email}',
      );

      // Validate input parameters
      if (params.email.trim().isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Email address is required',
            fieldErrors: {'email': 'Email address is required'},
          ),
        );
      }

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(params.email.trim())) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Please enter a valid email address',
            fieldErrors: {'email': 'Please enter a valid email address'},
          ),
        );
      }

      final startTime = DateTime.now();

      await AuthConfig.sendPasswordResetEmail(email: params.email.trim());

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Reset Password Use Case', duration);
      AppLogger.firebase(
        'ResetPasswordUseCase',
        'Password reset email sent to: ${params.email}',
      );

      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Password reset failed for: ${params.email}', e);

      // Convert Firebase Auth exceptions to appropriate failures
      if (e.toString().contains('user-not-found')) {
        return Result.failure(
          Failure.authFailure(
            message: 'No account found with this email address',
            code: 'AUTH_USER_NOT_FOUND',
          ),
        );
      }

      if (e.toString().contains('invalid-email')) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Please enter a valid email address',
            fieldErrors: {'email': 'Please enter a valid email address'},
          ),
        );
      }

      if (e.toString().contains('too-many-requests')) {
        return Result.failure(
          Failure.authFailure(
            message: 'Too many reset attempts. Please try again later',
            code: 'AUTH_TOO_MANY_REQUESTS',
          ),
        );
      }

      return Result.failure(
        Failure.authFailure(
          message: 'Failed to send password reset email. Please try again',
          code: 'AUTH_PASSWORD_RESET_ERROR',
        ),
      );
    }
  }
}

/// Parameters for ResetPasswordUseCase
class ResetPasswordParams {
  final String email;

  const ResetPasswordParams({required this.email});

  @override
  String toString() => 'ResetPasswordParams(email: $email)';
}
