import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending email verification to current user
/// Following CLAUDE.md authentication patterns and Result pattern
class SendEmailVerificationUseCase extends BaseUseCaseNoParams<void> {
  final AuthRepository _authRepository;

  SendEmailVerificationUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<void>> call() async {
    try {
      AppLogger.firebase(
        'SendEmailVerificationUseCase',
        'Attempting to send email verification',
      );

      // Check if user is signed in
      if (!_authRepository.isAuthenticated) {
        return Result.failure(
          Failure.authFailure(
            message: 'Please sign in to verify your email',
            code: 'AUTH_USER_NOT_SIGNED_IN',
          ),
        );
      }

      // Check if email is already verified
      if (_authRepository.isEmailVerified) {
        return Result.failure(
          Failure.authFailure(
            message: 'Email is already verified',
            code: 'AUTH_EMAIL_ALREADY_VERIFIED',
          ),
        );
      }

      final startTime = DateTime.now();

      final result = await _authRepository.sendEmailVerification();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Send Email Verification Use Case', duration);

      return result.when(
        success: (_) {
          AppLogger.firebase(
            'SendEmailVerificationUseCase',
            'Email verification sent successfully',
          );
          return Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('Email verification send failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during email verification send',
        e,
        stackTrace,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to send verification email. Please try again',
          code: 'AUTH_EMAIL_VERIFICATION_ERROR',
        ),
      );
    }
  }
}
