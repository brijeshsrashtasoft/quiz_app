import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';

/// Authentication repository interface for Clean Architecture
/// Defines all authentication operations for the domain layer
abstract class AuthRepository {
  /// Sign in with email and password
  /// Returns [AuthEntity] on success or [Failure] on error
  Future<Result<AuthEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create user account with email and password
  /// Returns [AuthEntity] on success or [Failure] on error
  Future<Result<AuthEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google account
  /// Returns [AuthEntity] on success or [Failure] on error
  Future<Result<AuthEntity>> signInWithGoogle();

  /// Sign out current user
  /// Returns success result or [Failure] on error
  Future<Result<void>> signOut();

  /// Send password reset email
  /// Returns success result or [Failure] on error
  Future<Result<void>> sendPasswordResetEmail({required String email});

  /// Update user profile information
  /// Returns success result or [Failure] on error
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Delete current user account
  /// Returns success result or [Failure] on error
  Future<Result<void>> deleteUserAccount();

  /// Send email verification to current user
  /// Returns success result or [Failure] on error
  Future<Result<void>> sendEmailVerification();

  /// Reload current user data
  /// Returns success result or [Failure] on error
  Future<Result<void>> reloadUser();

  /// Get current Firebase user (for compatibility)
  /// Returns [User] if authenticated, null otherwise
  User? getCurrentUser();

  /// Check if user is currently authenticated
  bool get isAuthenticated;

  /// Get current authenticated user's ID
  String? get currentUserId;

  /// Stream of authentication state changes
  /// Emits [User] when authenticated, null when not
  Stream<User?> authStateChanges();

  /// Stream of ID token changes (more reliable for auth state)
  /// Emits [User] when token changes, null when signed out
  Stream<User?> idTokenChanges();

  /// Stream of user profile changes
  /// Emits [User] when user data changes
  Stream<User?> userChanges();
}
