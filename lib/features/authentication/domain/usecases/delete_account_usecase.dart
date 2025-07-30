import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/user_repository.dart';

/// Use case for deleting user account
/// Handles both Firebase Auth account deletion and Firestore data cleanup
/// Following CLAUDE.md authentication patterns and Result pattern
class DeleteAccountUseCase extends BaseUseCase<void, DeleteAccountParams> {
  final UserRepository userRepository;

  DeleteAccountUseCase({required this.userRepository});

  @override
  Future<Result<void>> call(DeleteAccountParams params) async {
    try {
      final currentUser = AuthConfig.currentUser;
      if (currentUser == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
            code: 'AUTH_NO_CURRENT_USER',
          ),
        );
      }

      final userEmail = currentUser.email ?? 'Unknown';
      AppLogger.firebase(
        'DeleteAccountUseCase',
        'Attempting account deletion for: $userEmail',
      );

      // Validate password for security (re-authentication)
      if (params.password.isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Password is required to delete your account',
            fieldErrors: {
              'password': 'Password is required to delete your account',
            },
          ),
        );
      }

      final startTime = DateTime.now();

      // Re-authenticate user before account deletion for security
      try {
        await AuthConfig.signInWithEmailAndPassword(
          email: currentUser.email!,
          password: params.password,
        );
      } catch (e) {
        if (e.toString().contains('wrong-password')) {
          return Result.failure(
            Failure.authFailure(
              message: 'Incorrect password. Please try again',
              code: 'AUTH_WRONG_PASSWORD',
            ),
          );
        }
        return Result.failure(
          Failure.authFailure(
            message: 'Re-authentication failed. Please try again',
            code: 'AUTH_REAUTHENTICATION_FAILED',
          ),
        );
      }

      // Delete user data from Firestore first
      final deleteUserDataResult = await userRepository.deleteUser(
        currentUser.uid,
      );
      if (!deleteUserDataResult.isSuccess) {
        AppLogger.error(
          'Failed to delete user data from Firestore',
          deleteUserDataResult.failureOrNull,
        );
        // Continue with auth account deletion even if Firestore deletion fails
        AppLogger.warning(
          'DeleteAccountUseCase',
          'Firestore data deletion failed, continuing with auth account deletion',
        );
      }

      // TODO: Add cleanup for other user-related data when features are implemented
      // - Delete quiz creations
      // - Remove from game sessions
      // - Clean up leaderboard entries
      // - Delete user-generated content

      // Finally, delete Firebase Auth account
      await AuthConfig.deleteUser();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete Account Use Case', duration);
      AppLogger.firebase(
        'DeleteAccountUseCase',
        'Account deletion successful for: $userEmail',
      );

      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Account deletion failed', e);

      if (e.toString().contains('requires-recent-login')) {
        return Result.failure(
          Failure.authFailure(
            message: 'Please sign in again to delete your account',
            code: 'AUTH_REQUIRES_RECENT_LOGIN',
          ),
        );
      }

      return Result.failure(
        Failure.authFailure(
          message: 'Account deletion failed. Please try again',
          code: 'AUTH_DELETE_ACCOUNT_ERROR',
        ),
      );
    }
  }
}

/// Parameters for DeleteAccountUseCase
class DeleteAccountParams {
  final String password;
  final bool confirmDeletion;

  const DeleteAccountParams({
    required this.password,
    this.confirmDeletion = false,
  });

  @override
  String toString() => 'DeleteAccountParams(confirmDeletion: $confirmDeletion)';
}
