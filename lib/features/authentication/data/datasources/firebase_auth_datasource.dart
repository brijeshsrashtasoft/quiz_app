import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';

/// Firebase Authentication data source
/// Handles all Firebase Auth operations following Clean Architecture patterns
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Sign in with email and password
  Future<Result<UserCredential>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Attempting sign in for: $email',
      );
      final startTime = DateTime.now();

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Auth Sign In', duration);
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Sign in successful for: $email',
      );

      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase sign in failed for: $email', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during sign in for: $email', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during sign in',
          code: 'unknown_error',
        ),
      );
    }  
  }

  /// Create user with email and password
  Future<Result<UserCredential>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Attempting user creation for: $email',
      );
      final startTime = DateTime.now();

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Auth Create User', duration);
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'User creation successful for: $email',
      );

      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase user creation failed for: $email', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during user creation for: $email', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during user creation',
          code: 'unknown_error',
        ),
      );
    }
  }

  /// Sign in with Google
  Future<Result<UserCredential>> signInWithGoogle() async {
    try {
      AppLogger.firebase('FirebaseAuthDataSource', 'Attempting Google sign in');
      final startTime = DateTime.now();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancels the sign-in flow
      if (googleUser == null) {
        AppLogger.warning('Google sign in cancelled by user');
        return Result.failure(
          Failure.authFailure(
            message: 'Google sign in was cancelled',
            code: 'sign_in_cancelled',
          ),
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Google Sign In', duration);
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Google sign in successful for: ${userCredential.user?.email}',
      );

      return Result.success(userCredential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase Google sign in failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during Google sign in', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during Google sign in',
          code: 'google_signin_error',
        ),
      );
    }
  }

  /// Sign out current user
  Future<Result<void>> signOut() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Attempting sign out for: ${currentUser?.email}',
      );
      final startTime = DateTime.now();

      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();

      // Sign out from Google Sign In
      await _googleSignIn.signOut();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Auth Sign Out', duration);
      AppLogger.firebase('FirebaseAuthDataSource', 'Sign out successful');

      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Sign out failed: ${e.toString()}',
          code: 'signout_error',
        ),
      );
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Sending password reset email to: $email',
      );
      final startTime = DateTime.now();

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firebase Password Reset', duration);
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Password reset email sent to: $email',
      );

      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed for: $email', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during password reset for: $email', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during password reset',
          code: 'password_reset_error',
        ),
      );
    }
  }

  /// Update user profile
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Updating profile for: ${user.email}',
      );

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Profile update successful for: ${user.email}',
      );
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Profile update failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during profile update', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during profile update',
          code: 'profile_update_error',
        ),
      );
    }
  }

  /// Delete current user account
  Future<Result<void>> deleteUserAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      final userEmail = user.email;
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Deleting account for: $userEmail',
      );

      await user.delete();

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Account deletion successful for: $userEmail',
      );
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Account deletion failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during account deletion', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during account deletion',
          code: 'delete_account_error',
        ),
      );
    }
  }

  /// Get current user
  User? getCurrentUser() {
    try {
      return _firebaseAuth.currentUser;
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => getCurrentUser() != null;

  /// Get current user ID
  String? get currentUserId => getCurrentUser()?.uid;

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Stream of ID token changes (more reliable for auth state)
  Stream<User?> idTokenChanges() {
    return _firebaseAuth.idTokenChanges();
  }

  /// Stream of user changes (includes profile changes)
  Stream<User?> userChanges() {
    return _firebaseAuth.userChanges();
  }

  /// Enhanced authentication state stream with comprehensive state tracking
  /// Combines authStateChanges, idTokenChanges, and userChanges for maximum reliability
  Stream<User?> enhancedAuthStateChanges() {
    try {
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Setting up enhanced auth state stream',
      );

      // Use idTokenChanges as the primary stream (most reliable for auth state)
      // Combined with periodic auth state verification
      return _firebaseAuth.idTokenChanges().distinct().asyncMap((user) async {
        try {
          if (user == null) {
            AppLogger.firebase(
              'FirebaseAuthDataSource', 
              'Auth state: User signed out',
            );
            return null;
          }

          // Reload user to get fresh authentication state
          await user.reload();
          final refreshedUser = _firebaseAuth.currentUser;
          
          AppLogger.firebase(
            'FirebaseAuthDataSource',
            'Auth state: User authenticated - ${refreshedUser?.email}',
          );
          
          return refreshedUser;
        } catch (e) {
          AppLogger.error('Error refreshing user state', e);
          // Return the original user if refresh fails
          return user;
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to setup enhanced auth state stream', e, stackTrace);
      // Fallback to standard auth state changes
      return _firebaseAuth.authStateChanges();
    }
  }

  /// Check if current user's email is verified
  bool get isEmailVerified {
    final user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Get current user's provider information
  List<String> get userProviders {
    final user = _firebaseAuth.currentUser;
    if (user == null) return [];
    
    return user.providerData.map((info) => info.providerId).toList();
  }

  /// Check if user is signed in with Google
  bool get isSignedInWithGoogle {
    return userProviders.contains(GoogleAuthProvider.PROVIDER_ID);
  }

  /// Check if user is signed in with email/password
  bool get isSignedInWithEmail {
    return userProviders.contains(EmailAuthProvider.PROVIDER_ID);
  }

  /// Refresh authentication token
  Future<Result<String?>> refreshAuthToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Refreshing auth token for: ${user.email}',
      );

      final idToken = await user.getIdToken(true); // Force refresh
      
      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Auth token refreshed successfully',
      );

      return Result.success(idToken);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Token refresh failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during token refresh', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to refresh authentication token',
          code: 'token_refresh_error',
        ),
      );
    }
  }

  /// Link Google account to current user
  Future<Result<UserCredential>> linkGoogleAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Linking Google account for: ${user.email}',
      );

      // Start Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'Google account linking was cancelled',
            code: 'link_cancelled',
          ),
        );
      }

      // Get Google auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the credential to the current user
      final userCredential = await user.linkWithCredential(credential);

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Google account linked successfully',
      );

      return Result.success(userCredential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Google account linking failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during Google account linking', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to link Google account',
          code: 'link_error',
        ),
      );
    }
  }

  /// Unlink Google account from current user
  Future<Result<User>> unlinkGoogleAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Unlinking Google account for: ${user.email}',
      );

      final updatedUser = await user.unlink(GoogleAuthProvider.PROVIDER_ID);

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Google account unlinked successfully',
      );

      return Result.success(updatedUser);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Google account unlinking failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during Google account unlinking', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to unlink Google account',
          code: 'unlink_error',
        ),
      );
    }
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      if (user.emailVerified) {
        return Result.failure(
          Failure.authFailure(
            message: 'Email is already verified',
          code: 'email_already_verified',
          ),
        );
      }

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Sending email verification to: ${user.email}',
      );
      await user.sendEmailVerification();

      AppLogger.firebase(
        'FirebaseAuthDataSource',
        'Email verification sent to: ${user.email}',
      );
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Email verification failed', e);
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during email verification', e);
      return Result.failure(
        Failure.authFailure(
          message: 'An unexpected error occurred during email verification',
          code: 'email_verification_error',
        ),
      );
    }
  }

  /// Reload current user data
  Future<Result<void>> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
          code: 'no_current_user',
          ),
        );
      }

      await user.reload();
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Failed to reload user', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to reload user data',
          code: 'reload_user_error',
        ),
      );
    }
  }

  /// Map Firebase AuthException to core Failure.authFailure
  Failure _mapAuthException(FirebaseAuthException e) {
    // All Firebase auth errors are mapped to the core authFailure
    // Domain-specific AuthFailure types are used in the domain layer only
    final userMessage = _getUserFriendlyMessage(e.code, e.message);
    return Failure.authFailure(message: userMessage, code: e.code);
  }

  /// Get user-friendly error messages for Firebase auth errors
  String _getUserFriendlyMessage(String errorCode, String? originalMessage) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again';
      case 'invalid-credential':
        return 'The provided authentication credential is invalid';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account';
      case 'session-cookie-expired':
      case 'id-token-expired':
        return 'Your session has expired. Please sign in again';
      case 'user-not-signed-in':
        return 'No user is currently signed in';
      case 'email-not-verified':
        return 'Please verify your email address before continuing';
      default:
        return originalMessage ?? 'Authentication failed. Please try again';
    }
  }
}
