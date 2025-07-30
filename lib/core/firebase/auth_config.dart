import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';

/// Firebase Authentication configuration and utilities
/// Following CLAUDE.md Firebase Auth integration patterns
class AuthConfig {
  static FirebaseAuth? _instance;

  /// Get Firebase Auth instance with configuration
  static FirebaseAuth get instance {
    _instance ??= _configureAuth();
    return _instance!;
  }

  /// Configure Firebase Auth settings
  static FirebaseAuth _configureAuth() {
    final auth = FirebaseAuth.instance;

    try {
      // Configure Auth settings
      if (kDebugMode) {
        AppLogger.firebase('Auth', 'Firebase Auth configured for debug mode');
      }

      // Set language code for auth errors
      auth.setLanguageCode('en');

      // Configure authentication persistence
      _configurePersistence(auth);

      AppLogger.firebase('Auth', 'Firebase Auth configured successfully');
      return auth;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to configure Firebase Auth', e, stackTrace);
      throw AuthException(
        message: 'Failed to configure Firebase Authentication',
        code: 'auth_config_error',
      );
    }
  }

  /// Configure authentication persistence for cross-platform compatibility
  static void _configurePersistence(FirebaseAuth auth) {
    try {
      // Authentication persistence is handled automatically by Firebase Auth
      // but we can configure additional settings here

      // Set auth persistence (this is handled automatically by Firebase)
      // Firebase Auth automatically persists user authentication state
      // across app restarts on all platforms (Web, Android, iOS)

      AppLogger.firebase('Auth', 'Authentication persistence configured');
    } catch (e) {
      AppLogger.warning(
        'Failed to configure auth persistence: ${e.toString()}',
      );
      // Non-critical error, continue with default behavior
    }
  }

  /// Get current user with null safety
  static User? get currentUser {
    try {
      final user = instance.currentUser;
      if (user != null) {
        AppLogger.firebase('Auth', 'Current user: ${user.email}');
      }
      return user;
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      return null;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    return currentUser != null;
  }

  /// Get user ID safely
  static String? get currentUserId {
    return currentUser?.uid;
  }

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges {
    return instance.authStateChanges();
  }

  /// Stream of ID token changes (more reliable for auth state)
  static Stream<User?> get idTokenChanges {
    return instance.idTokenChanges();
  }

  /// Stream of user changes (includes profile changes)
  static Stream<User?> get userChanges {
    return instance.userChanges();
  }

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final startTime = DateTime.now();

      final credential = await instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Auth Sign In', duration);
      AppLogger.firebase('Auth', 'User signed in: ${credential.user?.email}');

      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign in failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during sign in', e);
      throw AuthException(
        message: 'An unexpected error occurred during sign in',
        code: 'unknown_error',
      );
    }
  }

  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final startTime = DateTime.now();

      final credential = await instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Auth Create User', duration);
      AppLogger.firebase('Auth', 'User created: ${credential.user?.email}');

      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('User creation failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during user creation', e);
      throw AuthException(
        message: 'An unexpected error occurred during user creation',
        code: 'unknown_error',
      );
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      final userEmail = currentUser?.email;
      await instance.signOut();
      AppLogger.firebase('Auth', 'User signed out: $userEmail');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      throw AuthException(message: 'Failed to sign out', code: 'signout_error');
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await instance.sendPasswordResetEmail(email: email.trim());
      AppLogger.firebase('Auth', 'Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during password reset', e);
      throw AuthException(
        message: 'An unexpected error occurred during password reset',
        code: 'unknown_error',
      );
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException(
          message: 'No user is currently signed in',
          code: 'no_current_user',
        );
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();

      AppLogger.firebase('Auth', 'User profile updated: ${user.email}');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Profile update failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during profile update', e);
      throw AuthException(
        message: 'An unexpected error occurred during profile update',
        code: 'unknown_error',
      );
    }
  }

  /// Delete current user account
  static Future<void> deleteUser() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException(
          message: 'No user is currently signed in',
          code: 'no_current_user',
        );
      }

      final userEmail = user.email;
      await user.delete();
      AppLogger.firebase('Auth', 'User account deleted: $userEmail');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('User deletion failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during user deletion', e);
      throw AuthException(
        message: 'An unexpected error occurred during user deletion',
        code: 'unknown_error',
      );
    }
  }

  /// Get user-friendly error messages
  static String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
