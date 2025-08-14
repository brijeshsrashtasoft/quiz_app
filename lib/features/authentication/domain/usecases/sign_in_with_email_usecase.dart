import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Sign in with email and password use case
/// Implements Clean Architecture use case pattern
class SignInWithEmailUseCase
    extends BaseUseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository repository;

  SignInWithEmailUseCase({required this.repository});

  @override
  Future<Result<UserEntity>> call(SignInWithEmailParams params) async {
    try {
      AppLogger.info('SignInWithEmailUseCase: Validating input parameters');

      // Validate input parameters
      final validationResult = _validateParams(params);
      if (validationResult.isFailure) {
        return validationResult;
      }

      AppLogger.info(
        'SignInWithEmailUseCase: Attempting sign in for ${params.email}',
      );

      // Call repository to sign in
      final result = await repository.signInWithEmailPassword(
        email: params.email,
        password: params.password,
      );

      return result.when(
        success: (userEntity) {
          AppLogger.info(
            'SignInWithEmailUseCase: Sign in successful for ${params.email}',
          );
          return Result.success(userEntity);
        },
        failure: (failure) {
          AppLogger.error(
            'SignInWithEmailUseCase: Sign in failed for ${params.email}',
            failure,
          );
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('SignInWithEmailUseCase: Unexpected error', e);
      return Result.failure(
        AuthFailure(
          message: 'An unexpected error occurred during sign in',
          code: 'unexpected-error',
        ),
      );
    }
  }

  /// Validate input parameters
  Result<UserEntity> _validateParams(SignInWithEmailParams params) {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return Result.failure(
        ValidationFailure(message: 'Please enter a valid email address'),
      );
    }

    // Validate password length
    if (!_isValidPassword(params.password)) {
      return Result.failure(
        ValidationFailure(
          message: 'Password must be at least 8 characters long',
        ),
      );
    }

    // Return success with dummy result for validation only
    return Result.success(
      UserEntity(
        id: '',
        email: params.email,
        name: '',
        createdAt: DateTime.now(),
      ),
    );
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
}

/// Parameters for sign in with email use case
class SignInWithEmailParams extends BaseUseCaseParams {
  final String email;
  final String password;

  const SignInWithEmailParams({required this.email, required this.password});

  List<Object?> get props => [email, password];
}
