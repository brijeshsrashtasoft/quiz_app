import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../models/user_model.dart';

/// Authentication repository implementation
/// Following CLAUDE.md Clean Architecture patterns
class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _authDataSource;

  const AuthRepositoryImpl({required AuthFirebaseDataSource authDataSource})
    : _authDataSource = authDataSource;

  @override
  Future<Result<UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );

      return result.transform((userModel) => userModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository sign in failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Authentication failed',
          code: 'auth_repository_signin_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<UserEntity>> createUserWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _authDataSource.createUserWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );

      return result.transform((userModel) => userModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository user creation failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'User creation failed',
          code: 'auth_repository_creation_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final result = await _authDataSource.signInWithGoogle();
      return result.transform((userModel) => userModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository Google sign in failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Google authentication failed',
          code: 'auth_repository_google_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      return await _authDataSource.signOut();
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository sign out failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Sign out failed',
          code: 'auth_repository_signout_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      return await _authDataSource.sendPasswordResetEmail(email: email);
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository password reset failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Password reset failed',
          code: 'auth_repository_reset_error',
        ).toFailure(),
      );
    }
  }

  @override
  Result<UserEntity?> getCurrentUser() {
    try {
      final result = _authDataSource.getCurrentUser();
      return result.transform((userModel) => userModel?.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository get current user failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Failed to get current user',
          code: 'auth_repository_get_user_error',
        ).toFailure(),
      );
    }
  }

  @override
  Stream<Result<UserEntity?>> watchAuthState() {
    try {
      return _authDataSource.watchAuthState().map(
        (result) => result.transform((userModel) => userModel?.toEntity()),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository watch auth state failed', e, stackTrace);
      return Stream.value(
        Result.failure(
          const AuthException(
            message: 'Failed to watch authentication state',
            code: 'auth_repository_watch_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  bool get isAuthenticated => _authDataSource.isAuthenticated;

  @override
  String? get currentUserId => _authDataSource.currentUserId;

  @override
  Future<Result<void>> deleteCurrentUser() async {
    try {
      return await _authDataSource.deleteCurrentUser();
    } catch (e, stackTrace) {
      AppLogger.error('Auth repository delete user failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'User deletion failed',
          code: 'auth_repository_delete_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null) {
        return Result.failure(
          const AuthException(
            message: 'No user is currently signed in',
            code: 'no_current_user',
          ).toFailure(),
        );
      }

      await user.sendEmailVerification();
      AppLogger.firebase('AuthRepository', 'Email verification sent');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Email verification failed', e);
      return Result.failure(
        AuthException(
          message: 'Failed to send email verification: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during email verification',
        e,
        stackTrace,
      );
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during email verification',
          code: 'email_verification_error',
        ).toFailure(),
      );
    }
  }

  @override
  bool get isEmailVerified {
    final user = AuthConfig.currentUser;
    return user?.emailVerified ?? false;
  }

  @override
  Future<Result<void>> reloadUser() async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null) {
        return Result.failure(
          const AuthException(
            message: 'No user is currently signed in',
            code: 'no_current_user',
          ).toFailure(),
        );
      }

      await user.reload();
      AppLogger.firebase('AuthRepository', 'User data reloaded');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('User reload failed', e);
      return Result.failure(
        AuthException(
          message: 'Failed to reload user data: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during user reload', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during user reload',
          code: 'user_reload_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null || user.email == null) {
        return Result.failure(
          const AuthException(
            message: 'No user is currently signed in',
            code: 'no_current_user',
          ).toFailure(),
        );
      }

      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      AppLogger.firebase('AuthRepository', 'Password updated successfully');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password update failed', e);
      return Result.failure(
        AuthException(
          message: 'Failed to update password: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during password update', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during password update',
          code: 'password_update_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null || user.email == null) {
        return Result.failure(
          const AuthException(
            message: 'No user is currently signed in',
            code: 'no_current_user',
          ).toFailure(),
        );
      }

      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      AppLogger.firebase('AuthRepository', 'Email updated successfully');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Email update failed', e);
      return Result.failure(
        AuthException(
          message: 'Failed to update email: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during email update', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during email update',
          code: 'email_update_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> reauthenticate({required String password}) async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null || user.email == null) {
        return Result.failure(
          const AuthException(
            message: 'No user is currently signed in',
            code: 'no_current_user',
          ).toFailure(),
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      AppLogger.firebase(
        'AuthRepository',
        'User re-authenticated successfully',
      );
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Re-authentication failed', e);
      return Result.failure(
        AuthException(
          message: 'Re-authentication failed: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during re-authentication',
        e,
        stackTrace,
      );
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during re-authentication',
          code: 'reauthenticate_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<UserEntity>> linkGoogleAccount() async {
    try {
      // This would implement linking Google account to existing user
      // For now, return error as this requires more complex implementation
      return Result.failure(
        const AuthException(
          message: 'Account linking not yet implemented',
          code: 'link_not_implemented',
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Account linking failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Account linking failed',
          code: 'link_account_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> unlinkGoogleAccount() async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null) {
        return Result.failure(
          const AuthException(
            message: 'No user is currently signed in',
            code: 'no_current_user',
          ).toFailure(),
        );
      }

      await user.unlink(GoogleAuthProvider.PROVIDER_ID);
      AppLogger.firebase('AuthRepository', 'Google account unlinked');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Account unlinking failed', e);
      return Result.failure(
        AuthException(
          message: 'Failed to unlink Google account: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during account unlinking',
        e,
        stackTrace,
      );
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during account unlinking',
          code: 'unlink_account_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<String>>> getSignInMethodsForEmail({
    required String email,
  }) async {
    try {
      // fetchSignInMethodsForEmail is deprecated for security reasons
      // Return empty list as recommended by Firebase documentation
      AppLogger.firebase(
        'AuthRepository',
        'Sign-in methods check requested for: $email (deprecated API)',
      );
      return const Result.success([]);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Failed to get sign-in methods', e);
      return Result.failure(
        AuthException(
          message: 'Failed to get sign-in methods: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error getting sign-in methods',
        e,
        stackTrace,
      );
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred getting sign-in methods',
          code: 'get_signin_methods_error',
        ).toFailure(),
      );
    }
  }
}
