import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/user_repository.dart';
import '../entities/user_entity.dart';

/// Use case for updating user profile information
/// Handles both Firebase Auth profile and Firestore user data updates
/// Following CLAUDE.md authentication patterns and Result pattern
class UpdateUserProfileUseCase
    extends BaseUseCase<UserEntity, UpdateUserProfileParams> {
  final UserRepository userRepository;

  UpdateUserProfileUseCase({required this.userRepository});

  @override
  Future<Result<UserEntity>> call(UpdateUserProfileParams params) async {
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
        'UpdateUserProfileUseCase',
        'Updating profile for: ${currentUser.email}',
      );

      // Validate display name if provided
      if (params.displayName != null && params.displayName!.trim().length < 2) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Display name must be at least 2 characters long',
            fieldErrors: {
              'displayName': 'Display name must be at least 2 characters long',
            },
          ),
        );
      }

      // Validate photo URL if provided
      if (params.photoURL != null && params.photoURL!.isNotEmpty) {
        final urlRegex = RegExp(
          r'^https?://.*\.(jpg|jpeg|png|gif|webp)(\?.*)?$',
          caseSensitive: false,
        );
        if (!urlRegex.hasMatch(params.photoURL!)) {
          return Result.failure(
            Failure.validationFailure(
              message: 'Please provide a valid image URL',
              fieldErrors: {'photoURL': 'Please provide a valid image URL'},
            ),
          );
        }
      }

      final startTime = DateTime.now();

      // Update Firebase Auth profile
      await AuthConfig.updateUserProfile(
        displayName: params.displayName?.trim(),
        photoURL: params.photoURL?.trim(),
      );

      // Get current user data from Firestore
      final userResult = await userRepository.getUserById(currentUser.uid);
      if (!userResult.isSuccess) {
        return Result.failure(userResult.failureOrNull!);
      }

      final currentUserEntity = userResult.dataOrNull!;

      // Create updated user entity
      final updatedUser = currentUserEntity.copyWith(
        name: params.displayName?.trim() ?? currentUserEntity.name,
        profileImageUrl:
            params.photoURL?.trim() ?? currentUserEntity.profileImageUrl,
        preferences: params.preferences ?? currentUserEntity.preferences,
      );

      // Update user data in Firestore
      final updateResult = await userRepository.updateUser(updatedUser);
      if (!updateResult.isSuccess) {
        return Result.failure(updateResult.failureOrNull!);
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update User Profile Use Case', duration);
      AppLogger.firebase(
        'UpdateUserProfileUseCase',
        'Profile update successful for: ${currentUser.email}',
      );

      return Result.success(updateResult.dataOrNull!);
    } catch (e) {
      AppLogger.error('Profile update failed', e);

      if (e.toString().contains('requires-recent-login')) {
        return Result.failure(
          Failure.authFailure(
            message: 'Please sign in again to update your profile',
            code: 'AUTH_REQUIRES_RECENT_LOGIN',
          ),
        );
      }

      return Result.failure(
        Failure.authFailure(
          message: 'Profile update failed. Please try again',
          code: 'AUTH_PROFILE_UPDATE_ERROR',
        ),
      );
    }
  }
}

/// Parameters for UpdateUserProfileUseCase
class UpdateUserProfileParams {
  final String? displayName;
  final String? photoURL;
  final UserPreferences? preferences;

  const UpdateUserProfileParams({
    this.displayName,
    this.photoURL,
    this.preferences,
  });

  @override
  String toString() =>
      'UpdateUserProfileParams(displayName: $displayName, photoURL: $photoURL)';
}
