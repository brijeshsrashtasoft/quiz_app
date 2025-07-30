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

  /// Get current user's ID token for API calls
  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentUser;
      if (user == null) {
        AppLogger.warning('Auth', 'No user signed in for token request');
        return null;
      }

      final token = await user.getIdToken(forceRefresh);
      if (forceRefresh) {
        AppLogger.firebase(
          'Auth',
          'ID token refreshed for user: ${user.email}',
        );
      }

      return token;
    } catch (e) {
      AppLogger.error('Failed to get ID token', e);
      throw AuthException(
        message: 'Failed to get authentication token',
        code: 'token_error',
      );
    }
  }

  /// Refresh the current user's ID token
  static Future<String?> refreshIdToken() async {
    return await getIdToken(forceRefresh: true);
  }

  /// Get token result with custom claims
  static Future<IdTokenResult?> getIdTokenResult({
    bool forceRefresh = false,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return null;
      }

      return await user.getIdTokenResult(forceRefresh);
    } catch (e) {
      AppLogger.error('Failed to get ID token result', e);
      throw AuthException(
        message: 'Failed to get token result',
        code: 'token_result_error',
      );
    }
  }

  /// Check if user's token needs refresh (expires within 5 minutes)
  static Future<bool> needsTokenRefresh() async {
    try {
      final tokenResult = await getIdTokenResult();
      if (tokenResult == null) {
        return false;
      }

      final expirationTime = tokenResult.expirationTime;
      if (expirationTime == null) {
        return true; // If we can't determine expiration, refresh to be safe
      }

      final now = DateTime.now();
      final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

      return expirationTime.isBefore(fiveMinutesFromNow);
    } catch (e) {
      AppLogger.error('Failed to check token refresh need', e);
      return true; // If we can't check, assume refresh is needed
    }
  }

  /// Automatically refresh token if needed
  static Future<String?> ensureFreshToken() async {
    try {
      final needsRefresh = await needsTokenRefresh();
      return await getIdToken(forceRefresh: needsRefresh);
    } catch (e) {
      AppLogger.error('Failed to ensure fresh token', e);
      return null;
    }
  }

  /// Reauthenticate user with email and password (required for sensitive operations)
  static Future<UserCredential> reauthenticateWithEmailAndPassword({
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw AuthException(
          message: 'No user is currently signed in',
          code: 'no_current_user',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      final result = await user.reauthenticateWithCredential(credential);
      AppLogger.firebase('Auth', 'User reauthenticated: ${user.email}');

      return result;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Reauthentication failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during reauthentication', e);
      throw AuthException(
        message: 'An unexpected error occurred during reauthentication',
        code: 'unknown_error',
      );
    }
  }

  /// Change user password (requires recent authentication)
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // First reauthenticate the user
      await reauthenticateWithEmailAndPassword(password: currentPassword);

      // Then update the password
      final user = currentUser;
      if (user == null) {
        throw AuthException(
          message: 'No user is currently signed in',
          code: 'no_current_user',
        );
      }

      await user.updatePassword(newPassword);
      AppLogger.firebase('Auth', 'Password changed for user: ${user.email}');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password change failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during password change', e);
      throw AuthException(
        message: 'An unexpected error occurred during password change',
        code: 'unknown_error',
      );
    }
  }

  /// Send email verification to current user
  static Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException(
          message: 'No user is currently signed in',
          code: 'no_current_user',
        );
      }

      if (user.emailVerified) {
        AppLogger.firebase('Auth', 'Email already verified for: ${user.email}');
        return;
      }

      await user.sendEmailVerification();
      AppLogger.firebase('Auth', 'Email verification sent to: ${user.email}');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Email verification failed', e);
      throw AuthException(message: _getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected error during email verification', e);
      throw AuthException(
        message: 'An unexpected error occurred during email verification',
        code: 'unknown_error',
      );
    }
  }

  /// Check if current user's email is verified
  static bool get isEmailVerified {
    return currentUser?.emailVerified ?? false;
  }

  /// Reload current user data (to check for email verification updates)
  static Future<void> reloadUser() async {
    try {
      final user = currentUser;
      if (user == null) {
        return;
      }

      await user.reload();
      AppLogger.firebase('Auth', 'User data reloaded for: ${user.email}');
    } catch (e) {
      AppLogger.error('Failed to reload user', e);
      // Don't throw - this is not critical
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
