import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/user_repository.dart';
import '../entities/user_entity.dart';

/// Use case for getting current authenticated user with complete profile data
/// Combines Firebase Auth user with Firestore user data
/// Following CLAUDE.md authentication patterns and Result pattern
class GetCurrentUserUseCase extends BaseUseCase<UserEntity, NoParams> {
  final UserRepository userRepository;

  GetCurrentUserUseCase({required this.userRepository});

  @override
  Future<Result<UserEntity>> call(NoParams params) async {
    try {
      final currentUser = AuthConfig.currentUser;
      if (currentUser == null) {
        AppLogger.firebase(
          'GetCurrentUserUseCase',
          'No user is currently signed in',
        );
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
            code: 'AUTH_NO_CURRENT_USER',
          ),
        );
      }

      AppLogger.firebase(
        'GetCurrentUserUseCase',
        'Getting current user data for: ${currentUser.email}',
      );

      final startTime = DateTime.now();

      // Get user data from Firestore
      final userResult = await userRepository.getUserById(currentUser.uid);

      if (!userResult.isSuccess) {
        AppLogger.error(
          'Failed to get current user data',
          userResult.failureOrNull,
        );
        return Result.failure(userResult.failureOrNull!);
      }

      final userEntity = userResult.dataOrNull!;

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get Current User Use Case', duration);
      AppLogger.firebase(
        'GetCurrentUserUseCase',
        'Current user data retrieved for: ${userEntity.email}',
      );

      return Result.success(userEntity);
    } catch (e) {
      AppLogger.error('Failed to get current user', e);

      return Result.failure(
        Failure.authFailure(
          message: 'Failed to get current user data',
          code: 'AUTH_GET_CURRENT_USER_ERROR',
        ),
      );
    }
  }
}

/// Use case for checking if user is currently authenticated
/// Simple boolean check without fetching user data
class IsAuthenticatedUseCase extends BaseUseCase<bool, NoParams> {
  IsAuthenticatedUseCase();

  @override
  Future<Result<bool>> call(NoParams params) async {
    try {
      final isAuthenticated = AuthConfig.isAuthenticated;
      AppLogger.firebase(
        'IsAuthenticatedUseCase',
        'Authentication status: $isAuthenticated',
      );

      return Result.success(isAuthenticated);
    } catch (e) {
      AppLogger.error('Failed to check authentication status', e);

      // Return false if there's an error checking auth status
      return const Result.success(false);
    }
  }
}

/// Use case for getting current user ID only
/// Lightweight operation for quick user ID access
class GetCurrentUserIdUseCase extends BaseUseCase<String?, NoParams> {
  GetCurrentUserIdUseCase();

  @override
  Future<Result<String?>> call(NoParams params) async {
    try {
      final userId = AuthConfig.currentUserId;
      AppLogger.firebase(
        'GetCurrentUserIdUseCase',
        'Current user ID: ${userId ?? 'None'}',
      );

      return Result.success(userId);
    } catch (e) {
      AppLogger.error('Failed to get current user ID', e);

      return Result.failure(
        Failure.authFailure(
          message: 'Failed to get current user ID',
          code: 'AUTH_GET_USER_ID_ERROR',
        ),
      );
    }
  }
}
