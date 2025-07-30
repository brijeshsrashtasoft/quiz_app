import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_datasource.dart';
import '../models/user_model.dart';

/// Firebase Authentication datasource implementation
/// Following CLAUDE.md Firebase Auth patterns and free tier services
class AuthFirebaseDataSource extends BaseFirebaseDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with email and password
  Future<Result<UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final startTime = DateTime.now();

      final credential = await AuthConfig.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Auth Sign In', duration);

      if (credential.user == null) {
        return Result.failure(
          const AuthException(
            message: 'Authentication failed - no user returned',
            code: 'auth_no_user',
          ).toFailure(),
        );
      }

      final userModel = _firebaseUserToModel(credential.user!);
      AppLogger.firebase(
        'AuthDataSource',
        'User signed in: ${userModel.email}',
      );

      return Result.success(userModel);
    } on AuthException catch (e) {
      AppLogger.error('Auth sign in failed', e);
      return Result.failure(e.toFailure());
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign in', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during sign in',
          code: 'unexpected_signin_error',
        ).toFailure(),
      );
    }
  }

  /// Create user with email and password
  Future<Result<UserModel>> createUserWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final startTime = DateTime.now();

      final credential = await AuthConfig.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Auth Create User', duration);

      if (credential.user == null) {
        return Result.failure(
          const AuthException(
            message: 'User creation failed - no user returned',
            code: 'auth_no_user',
          ).toFailure(),
        );
      }

      // Update user profile with display name
      await AuthConfig.updateUserProfile(displayName: name);

      final userModel = _firebaseUserToModel(credential.user!, name: name);
      AppLogger.firebase('AuthDataSource', 'User created: ${userModel.email}');

      return Result.success(userModel);
    } on AuthException catch (e) {
      AppLogger.error('Auth user creation failed', e);
      return Result.failure(e.toFailure());
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during user creation', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during user creation',
          code: 'unexpected_creation_error',
        ).toFailure(),
      );
    }
  }

  /// Sign in with Google (free tier)
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final startTime = DateTime.now();

      // Start Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return Result.failure(
          const AuthException(
            message: 'Google sign in was cancelled by user',
            code: 'google_signin_cancelled',
          ).toFailure(),
        );
      }

      // Get Google auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await AuthConfig.instance.signInWithCredential(
        credential,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Google Auth', duration);

      if (userCredential.user == null) {
        return Result.failure(
          const AuthException(
            message: 'Google authentication failed - no user returned',
            code: 'google_auth_no_user',
          ).toFailure(),
        );
      }

      final userModel = _firebaseUserToModel(userCredential.user!);
      AppLogger.firebase(
        'AuthDataSource',
        'Google user signed in: ${userModel.email}',
      );

      return Result.success(userModel);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Google auth failed', e);
      return Result.failure(
        AuthException(
          message: 'Google authentication failed: ${e.message}',
          code: e.code,
        ).toFailure(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Google sign in', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during Google sign in',
          code: 'unexpected_google_error',
        ).toFailure(),
      );
    }
  }

  /// Sign out current user
  Future<Result<void>> signOut() async {
    try {
      final startTime = DateTime.now();

      // Sign out from Google if signed in with Google
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await AuthConfig.signOut();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Auth Sign Out', duration);

      AppLogger.firebase('AuthDataSource', 'User signed out successfully');
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Failed to sign out',
          code: 'signout_error',
        ).toFailure(),
      );
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      final startTime = DateTime.now();

      await AuthConfig.sendPasswordResetEmail(email: email);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Password Reset', duration);

      AppLogger.firebase(
        'AuthDataSource',
        'Password reset email sent to: $email',
      );
      return const Result.success(null);
    } on AuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      return Result.failure(e.toFailure());
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during password reset', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during password reset',
          code: 'unexpected_reset_error',
        ).toFailure(),
      );
    }
  }

  /// Get current authenticated user
  Result<UserModel?> getCurrentUser() {
    try {
      final firebaseUser = AuthConfig.currentUser;

      if (firebaseUser == null) {
        return const Result.success(null);
      }

      final userModel = _firebaseUserToModel(firebaseUser);
      return Result.success(userModel);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current user', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'Failed to get current user',
          code: 'get_current_user_error',
        ).toFailure(),
      );
    }
  }

  /// Stream of authentication state changes
  Stream<Result<UserModel?>> watchAuthState() {
    try {
      return AuthConfig.authStateChanges.map<Result<UserModel?>>((
        firebaseUser,
      ) {
        try {
          if (firebaseUser == null) {
            return const Result.success(null);
          }

          final userModel = _firebaseUserToModel(firebaseUser);
          return Result.success(userModel);
        } catch (e, stackTrace) {
          AppLogger.error('Error processing auth state change', e, stackTrace);
          return Result.failure(
            const AuthException(
              message: 'Error processing authentication state change',
              code: 'auth_state_error',
            ).toFailure(),
          );
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to setup auth state listener', e, stackTrace);
      return Stream.value(
        Result.failure(
          const AuthException(
            message: 'Failed to setup authentication listener',
            code: 'auth_listener_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => AuthConfig.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => AuthConfig.currentUserId;

  /// Delete current user account
  Future<Result<void>> deleteCurrentUser() async {
    try {
      final startTime = DateTime.now();

      await AuthConfig.deleteUser();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Delete User', duration);

      AppLogger.firebase('AuthDataSource', 'User account deleted');
      return const Result.success(null);
    } on AuthException catch (e) {
      AppLogger.error('User deletion failed', e);
      return Result.failure(e.toFailure());
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during user deletion', e, stackTrace);
      return Result.failure(
        const AuthException(
          message: 'An unexpected error occurred during account deletion',
          code: 'unexpected_deletion_error',
        ).toFailure(),
      );
    }
  }

  /// Convert Firebase User to UserModel
  UserModel _firebaseUserToModel(User firebaseUser, {String? name}) {
    return UserModel(
      id: firebaseUser.uid,
      name: name ?? firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      profileImageUrl: firebaseUser.photoURL,
      stats: null, // Stats will be managed separately in Firestore
      preferences: null, // Preferences will be managed separately in Firestore
    );
  }
}
