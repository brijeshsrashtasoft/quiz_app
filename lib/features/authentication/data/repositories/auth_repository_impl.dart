import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Authentication repository implementation
/// Implements Clean Architecture patterns with Firebase Auth data source
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl({required FirebaseAuthDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<AuthEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('AuthRepository: Attempting sign in for $email');

      final result = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.when(
        success: (userCredential) {
          if (userCredential.user == null) {
            AppLogger.error(
              'AuthRepository: UserCredential contains null user',
            );
            return Result.failure(
              Failure.authFailure(
                message: 'Authentication failed: User data is null',
                code: 'null-user-error',
              ),
            );
          }

          final authEntity = _mapUserCredentialToAuthEntity(userCredential);
          AppLogger.info('AuthRepository: Sign in successful for $email');
          return Result.success(authEntity);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: Sign in failed for $email', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('AuthRepository: Unexpected error during sign in', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during sign in',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<AuthEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('AuthRepository: Attempting user creation for $email');

      final result = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.when(
        success: (userCredential) {
          if (userCredential.user == null) {
            AppLogger.error(
              'AuthRepository: UserCredential contains null user',
            );
            return Result.failure(
              Failure.authFailure(
                message: 'User creation failed: User data is null',
                code: 'null-user-error',
              ),
            );
          }

          final authEntity = _mapUserCredentialToAuthEntity(userCredential);
          AppLogger.info('AuthRepository: User creation successful for $email');
          return Result.success(authEntity);
        },
        failure: (failure) {
          AppLogger.error(
            'AuthRepository: User creation failed for $email',
            failure,
          );
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error(
        'AuthRepository: Unexpected error during user creation',
        e,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during user creation',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<AuthEntity>> signInWithGoogle() async {
    try {
      AppLogger.info('AuthRepository: Attempting Google sign in');

      final result = await _dataSource.signInWithGoogle();

      return result.when(
        success: (userCredential) {
          if (userCredential.user == null) {
            AppLogger.error(
              'AuthRepository: Google UserCredential contains null user',
            );
            return Result.failure(
              Failure.authFailure(
                message: 'Google sign in failed: User data is null',
                code: 'null-user-error',
              ),
            );
          }

          final authEntity = _mapUserCredentialToAuthEntity(userCredential);
          AppLogger.info('AuthRepository: Google sign in successful');
          return Result.success(authEntity);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: Google sign in failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error(
        'AuthRepository: Unexpected error during Google sign in',
        e,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during Google sign in',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      final currentUser = _dataSource.getCurrentUser();
      AppLogger.info(
        'AuthRepository: Attempting sign out for ${currentUser?.email}',
      );

      final result = await _dataSource.signOut();

      return result.when(
        success: (_) {
          AppLogger.info('AuthRepository: Sign out successful');
          return const Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: Sign out failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('AuthRepository: Unexpected error during sign out', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during sign out',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.info('AuthRepository: Sending password reset email to $email');

      final result = await _dataSource.sendPasswordResetEmail(email: email);

      return result.when(
        success: (_) {
          AppLogger.info('AuthRepository: Password reset email sent to $email');
          return const Result.success(null);
        },
        failure: (failure) {
          AppLogger.error(
            'AuthRepository: Password reset failed for $email',
            failure,
          );
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error(
        'AuthRepository: Unexpected error during password reset',
        e,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during password reset',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final currentUser = _dataSource.getCurrentUser();
      AppLogger.info(
        'AuthRepository: Updating profile for ${currentUser?.email}',
      );

      final result = await _dataSource.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      return result.when(
        success: (_) {
          AppLogger.info('AuthRepository: Profile update successful');
          return const Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: Profile update failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error(
        'AuthRepository: Unexpected error during profile update',
        e,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during profile update',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteUserAccount() async {
    try {
      final currentUser = _dataSource.getCurrentUser();
      AppLogger.info(
        'AuthRepository: Deleting account for ${currentUser?.email}',
      );

      final result = await _dataSource.deleteUserAccount();

      return result.when(
        success: (_) {
          AppLogger.info('AuthRepository: Account deletion successful');
          return const Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: Account deletion failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error(
        'AuthRepository: Unexpected error during account deletion',
        e,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during account deletion',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      final currentUser = _dataSource.getCurrentUser();
      AppLogger.info(
        'AuthRepository: Sending email verification to ${currentUser?.email}',
      );

      final result = await _dataSource.sendEmailVerification();

      return result.when(
        success: (_) {
          AppLogger.info('AuthRepository: Email verification sent');
          return const Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: Email verification failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error(
        'AuthRepository: Unexpected error during email verification',
        e,
      );
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during email verification',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> reloadUser() async {
    try {
      final currentUser = _dataSource.getCurrentUser();
      AppLogger.info('AuthRepository: Reloading user ${currentUser?.email}');

      final result = await _dataSource.reloadUser();

      return result.when(
        success: (_) {
          AppLogger.info('AuthRepository: User reload successful');
          return const Result.success(null);
        },
        failure: (failure) {
          AppLogger.error('AuthRepository: User reload failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('AuthRepository: Unexpected error during user reload', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during user reload',
          code: 'unknown_error',
        ),
      );
    }
  }

  @override
  User? getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  bool get isAuthenticated {
    return _dataSource.isAuthenticated;
  }

  @override
  String? get currentUserId {
    return _dataSource.currentUserId;
  }

  @override
  Stream<User?> authStateChanges() {
    return _dataSource.authStateChanges();
  }

  @override
  Stream<User?> idTokenChanges() {
    return _dataSource.idTokenChanges();
  }

  @override
  Stream<User?> userChanges() {
    return _dataSource.userChanges();
  }

  /// Maps Firebase UserCredential to domain AuthEntity
  AuthEntity _mapUserCredentialToAuthEntity(UserCredential userCredential) {
    final user = userCredential.user!;

    return AuthEntity(
      user: AuthUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoURL: user.photoURL,
      ),
      isEmailVerified: user.emailVerified,
      lastSignInTime: user.metadata.lastSignInTime,
      creationTime: user.metadata.creationTime,
    );
  }
}
