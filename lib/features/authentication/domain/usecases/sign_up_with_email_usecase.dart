import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Sign up with email and password use case
/// Implements Clean Architecture use case pattern
class SignUpWithEmailUseCase
    extends BaseUseCase<AuthEntity, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmailUseCase({required this.repository});

  @override
  Future<Result<AuthEntity>> call(SignUpWithEmailParams params) async {
    try {
      AppLogger.info('SignUpWithEmailUseCase: Validating input parameters');

      // Validate input parameters
      final validationResult = _validateParams(params);
      if (validationResult.isFailure) {
        return validationResult;
      }

      AppLogger.info(
        'SignUpWithEmailUseCase: Attempting sign up for ${params.email}',
      );

      // Call repository to create user
      final result = await repository.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      return result.when(
        success: (authEntity) async {
          AppLogger.info(
            'SignUpWithEmailUseCase: Sign up successful for ${params.email}',
          );

          // Update profile with display name if provided
          if (params.displayName != null) {
            AppLogger.info('SignUpWithEmailUseCase: Updating display name');
            await repository.updateUserProfile(displayName: params.displayName);
          }

          return Result.success(authEntity);
        },
        failure: (failure) {
          AppLogger.error(
            'SignUpWithEmailUseCase: Sign up failed for ${params.email}',
            failure,
          );
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('SignUpWithEmailUseCase: Unexpected error', e);
      return Result.failure(
        AuthFailure(
          message: 'An unexpected error occurred during sign up',
          code: 'unexpected-error',
        ),
      );
    }
  }

  /// Validate input parameters
  Result<AuthEntity> _validateParams(SignUpWithEmailParams params) {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return Result.failure(
        ValidationFailure(
          message: 'Please enter a valid email address',
          code: 'invalid-email',
        ),
      );
    }

    // Validate password strength
    if (!_isValidPassword(params.password)) {
      return Result.failure(
        ValidationFailure(
          message: 'Password must be at least 8 characters long',
          code: 'weak-password',
        ),
      );
    }

    // Validate display name if provided
    if (params.displayName != null &&
        !_isValidDisplayName(params.displayName!)) {
      return Result.failure(
        ValidationFailure(
          message: 'Display name must be between 1 and 100 characters',
          code: 'invalid-display-name',
        ),
      );
    }

    return const Result.success(null);
  }

  /// Email validation helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Password validation helper
  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Display name validation helper
  bool _isValidDisplayName(String displayName) {
    return displayName.trim().isNotEmpty && displayName.length <= 100;
  }
}

/// Parameters for sign up with email use case
class SignUpWithEmailParams extends BaseUseCaseParams {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}
