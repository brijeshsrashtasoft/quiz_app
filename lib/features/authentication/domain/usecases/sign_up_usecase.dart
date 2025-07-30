import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';

/// Use case for signing up with email and password
/// Following CLAUDE.md authentication patterns and Result pattern
class SignUpUseCase extends BaseUseCase<UserCredential, SignUpParams> {
  SignUpUseCase();

  @override
  Future<Result<UserCredential>> call(SignUpParams params) async {
    try {
      AppLogger.firebase(
        'SignUpUseCase',
        'Attempting sign up for: ${params.email}',
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

      if (params.name.trim().isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Full name is required',
            fieldErrors: {'name': 'Full name is required'},
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

      // Validate password strength
      if (params.password.length < 6) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Password must be at least 6 characters long',
            fieldErrors: {
              'password': 'Password must be at least 6 characters long',
            },
          ),
        );
      }

      // Advanced password validation
      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(params.password)) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Password must contain both letters and numbers',
            fieldErrors: {
              'password': 'Password must contain both letters and numbers',
            },
          ),
        );
      }

      // Validate name length
      if (params.name.trim().length < 2) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Name must be at least 2 characters long',
            fieldErrors: {'name': 'Name must be at least 2 characters long'},
          ),
        );
      }

      final startTime = DateTime.now();

      final credential = await AuthConfig.createUserWithEmailAndPassword(
        email: params.email.trim(),
        password: params.password,
      );

      // Update display name after account creation
      if (credential.user != null) {
        await AuthConfig.updateUserProfile(displayName: params.name.trim());
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Sign Up Use Case', duration);
      AppLogger.firebase(
        'SignUpUseCase',
        'Sign up successful for: ${params.email}',
      );

      return Result.success(credential);
    } catch (e) {
      AppLogger.error('Sign up failed for: ${params.email}', e);

      // Convert Firebase Auth exceptions to appropriate failures
      if (e.toString().contains('email-already-in-use')) {
        return Result.failure(
          Failure.authFailure(
            message: 'An account with this email already exists',
            code: 'AUTH_EMAIL_ALREADY_IN_USE',
          ),
        );
      }

      if (e.toString().contains('weak-password')) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Password is too weak. Please choose a stronger password',
            fieldErrors: {
              'password':
                  'Password is too weak. Please choose a stronger password',
            },
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

      if (e.toString().contains('operation-not-allowed')) {
        return Result.failure(
          Failure.authFailure(
            message: 'Email/password sign up is not enabled',
            code: 'AUTH_OPERATION_NOT_ALLOWED',
          ),
        );
      }

      return Result.failure(
        Failure.authFailure(
          message: 'Account creation failed. Please try again',
          code: 'AUTH_SIGNUP_ERROR',
        ),
      );
    }
  }
}

/// Parameters for SignUpUseCase
class SignUpParams {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  String toString() => 'SignUpParams(email: $email, name: $name)';
}
