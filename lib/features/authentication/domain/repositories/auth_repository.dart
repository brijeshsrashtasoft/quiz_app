import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firebase Auth integration
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Create user with email and password
  Future<Result<UserEntity>> createUserWithEmailPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in with Google (free tier)
  Future<Result<UserEntity>> signInWithGoogle();

  /// Sign out current user
  Future<Result<void>> signOut();

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email});

  /// Get current authenticated user
  Result<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<Result<UserEntity?>> watchAuthState();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Get current user ID
  String? get currentUserId;

  /// Delete current user account
  Future<Result<void>> deleteCurrentUser();

  /// Verify email address
  Future<Result<void>> sendEmailVerification();

  /// Check if current user's email is verified
  bool get isEmailVerified;

  /// Reload current user data
  Future<Result<void>> reloadUser();

  /// Update user password
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Update user email
  Future<Result<void>> updateEmail({
    required String newEmail,
    required String password,
  });

  /// Re-authenticate user before sensitive operations
  Future<Result<void>> reauthenticate({required String password});

  /// Link Google account to current user
  Future<Result<UserEntity>> linkGoogleAccount();

  /// Unlink Google account from current user
  Future<Result<void>> unlinkGoogleAccount();

  /// Get available sign-in methods for email
  Future<Result<List<String>>> getSignInMethodsForEmail({
    required String email,
  });
}
