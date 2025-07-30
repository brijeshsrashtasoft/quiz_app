import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/firebase/auth_config.dart';
import '../repositories/user_repository.dart';
import '../../data/datasources/profile_storage_datasource.dart';

/// Use case for deleting user avatar from Firebase Storage and updating profile
/// Following CLAUDE.md Clean Architecture patterns
class DeleteAvatarUseCase extends BaseUseCase<void, NoParams> {
  final UserRepository userRepository;
  final ProfileStorageDataSource storageDataSource;

  DeleteAvatarUseCase({
    required this.userRepository,
    required this.storageDataSource,
  });

  @override
  Future<Result<void>> call(NoParams params) async {
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

      AppLogger.firebase(
        'DeleteAvatarUseCase',
        'Starting avatar deletion for user: ${currentUser.uid}',
      );
      final startTime = DateTime.now();

      // Step 1: Delete avatar from Firebase Storage
      final deleteResult = await storageDataSource.deleteAvatar(currentUser.uid);
      if (deleteResult.isFailure) {
        AppLogger.error(
          'Failed to delete avatar from storage: ${currentUser.uid}',
          deleteResult.failureOrNull,
        );
        return Result.failure(deleteResult.failureOrNull!);
      }

      // Step 2: Update user profile to remove avatar URL
      final getUserResult = await userRepository.getUserById(currentUser.uid);
      if (getUserResult.isFailure) {
        AppLogger.error(
          'Failed to get user for profile update: ${currentUser.uid}',
          getUserResult.failureOrNull,
        );
        return Result.failure(getUserResult.failureOrNull!);
      }

      final currentUserEntity = getUserResult.dataOrNull!;
      final updatedUser = currentUserEntity.copyWith(
        profileImageUrl: null, // Remove avatar URL
      );

      final updateResult = await userRepository.updateUser(updatedUser);
      if (updateResult.isFailure) {
        AppLogger.error(
          'Failed to update user profile after avatar deletion',
          updateResult.failureOrNull,
        );
        return Result.failure(updateResult.failureOrNull!);
      }

      // Step 3: Update Firebase Auth profile photo URL
      try {
        await AuthConfig.updateUserProfile(photoURL: null);
        AppLogger.firebase(
          'DeleteAvatarUseCase',
          'Updated Firebase Auth to remove profile photo URL',
        );
      } catch (e) {
        // This is non-critical - the Firestore profile has been updated correctly
        AppLogger.warning('Failed to update Firebase Auth photo URL: $e');
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete Avatar Use Case', duration);
      AppLogger.firebase(
        'DeleteAvatarUseCase',
        'Avatar deletion completed successfully for user: ${currentUser.uid}',
      );

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Avatar deletion failed', e, stackTrace);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Avatar deletion failed: ${e.toString()}',
        ),
      );
    }
  }
}

/// No parameters needed for avatar deletion
class NoParams {
  const NoParams();
}