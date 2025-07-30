import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
/// Following CLAUDE.md authentication patterns and Result pattern
class SignInUseCase extends BaseUseCase<UserEntity, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<UserEntity>> call(SignInParams params) async {
    try {
      AppLogger.firebase(
        'SignInUseCase',
        'Attempting sign in for: ${params.email}',
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

      if (params.password.isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Password is required',
            fieldErrors: {'password': 'Password is required'},
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

      final result = await _authRepository.signInWithEmailPassword(
        email: params.email.trim(),
        password: params.password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Sign In Use Case', duration);

      return result.when(
        success: (user) {
          AppLogger.firebase(
            'SignInUseCase',
            'Sign in successful for: ${params.email}',
          );
          return Result.success(user);
        },
        failure: (failure) {
          AppLogger.error('Sign in failed for: ${params.email}', failure);
          return Result.failure(failure);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during sign in: ${params.email}',
        e,
        stackTrace,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'Sign in failed. Please try again',
          code: 'AUTH_SIGNIN_ERROR',
        ),
      );
    }
  }
}

/// Parameters for SignInUseCase
class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  String toString() => 'SignInParams(email: $email)';
}
