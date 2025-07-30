import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';

/// Use case for signing out current user
/// Following CLAUDE.md authentication patterns and Result pattern
class SignOutUseCase extends BaseUseCase<void, NoParams> {
  SignOutUseCase();

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      final currentUser = AuthConfig.currentUser;
      final userEmail = currentUser?.email ?? 'Unknown';

      AppLogger.firebase(
        'SignOutUseCase',
        'Attempting sign out for: $userEmail',
      );

      // Check if user is currently signed in
      if (!AuthConfig.isAuthenticated) {
        AppLogger.warning('SignOutUseCase', 'No user is currently signed in');
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
            code: 'AUTH_NO_CURRENT_USER',
          ),
        );
      }

      final startTime = DateTime.now();

      await AuthConfig.signOut();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Sign Out Use Case', duration);
      AppLogger.firebase(
        'SignOutUseCase',
        'Sign out successful for: $userEmail',
      );

      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Sign out failed', e);

      return Result.failure(
        Failure.authFailure(
          message: 'Sign out failed. Please try again',
          code: 'AUTH_SIGNOUT_ERROR',
        ),
      );
    }
  }
}

/// Use case for signing out and clearing user session data
/// This provides a more comprehensive sign out with cleanup
class SignOutAndClearSessionUseCase extends BaseUseCase<void, NoParams> {
  SignOutAndClearSessionUseCase();

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      final currentUser = AuthConfig.currentUser;
      final userEmail = currentUser?.email ?? 'Unknown';

      AppLogger.firebase(
        'SignOutAndClearSessionUseCase',
        'Attempting comprehensive sign out for: $userEmail',
      );

      // Check if user is currently signed in
      if (!AuthConfig.isAuthenticated) {
        AppLogger.warning(
          'SignOutAndClearSessionUseCase',
          'No user is currently signed in',
        );
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
            code: 'AUTH_NO_CURRENT_USER',
          ),
        );
      }

      final startTime = DateTime.now();

      // Sign out from Firebase Auth
      await AuthConfig.signOut();

      // TODO: Add additional cleanup here when other features are implemented
      // - Clear cached user data
      // - Clear local storage/shared preferences
      // - Cancel ongoing streams/subscriptions
      // - Clear quiz session data
      // - Clear leaderboard cache

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Sign Out And Clear Session Use Case', duration);
      AppLogger.firebase(
        'SignOutAndClearSessionUseCase',
        'Comprehensive sign out successful for: $userEmail',
      );

      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Comprehensive sign out failed', e);

      return Result.failure(
        Failure.authFailure(
          message: 'Sign out failed. Please try again',
          code: 'AUTH_SIGNOUT_ERROR',
        ),
      );
    }
  }
}
