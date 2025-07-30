import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';
import '../entities/user_profile_entity.dart';
import '../../../../core/errors/failures.dart';

/// Use case for updating user profile information
/// Handles profile validation and update operations
/// Following CLAUDE.md patterns and Result pattern for error handling
class UpdateUserProfileUseCase
    extends BaseUseCase<UserProfileEntity, UpdateUserProfileParams> {
  final ProfileRepository profileRepository;

  UpdateUserProfileUseCase({required this.profileRepository});

  @override
  Future<Result<UserProfileEntity>> call(UpdateUserProfileParams params) async {
    try {
      AppLogger.info(
        'UpdateUserProfileUseCase',
        'Updating profile for user: ${params.userId}',
      );

      // Validate profile data
      final validationResult = await profileRepository.validateProfileData(
        params.profile,
      );
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.failureOrNull!);
      }

      // Check username availability if username is being changed
      if (params.profile.username != null &&
          params.profile.username!.isNotEmpty) {
        final usernameAvailable = await profileRepository.isUsernameAvailable(
          params.profile.username!,
        );
        if (!usernameAvailable.isSuccess) {
          return Result.failure(usernameAvailable.failureOrNull!);
        }
        if (!(usernameAvailable.dataOrNull ?? false)) {
          return Result.failure(
            Failure.validationFailure(
              message: 'Username "${params.profile.username}" is already taken',
            ),
          );
        }
      }

      final startTime = DateTime.now();

      // Update profile
      final updatedProfile = params.profile.copyWith(updatedAt: DateTime.now());

      final updateResult = await profileRepository.updateProfile(
        updatedProfile,
      );
      if (!updateResult.isSuccess) {
        return Result.failure(updateResult.failureOrNull!);
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update User Profile Use Case', duration);
      AppLogger.info(
        'UpdateUserProfileUseCase',
        'Profile update successful for user: ${params.userId}',
      );

      return Result.success(updateResult.dataOrNull!);
    } catch (e) {
      AppLogger.error('Profile update failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update profile. Please try again.',
        ),
      );
    }
  }
}

/// Parameters for UpdateUserProfileUseCase
class UpdateUserProfileParams extends BaseUseCaseParams {
  final String userId;
  final UserProfileEntity profile;

  const UpdateUserProfileParams({required this.userId, required this.profile});

  @override
  String toString() =>
      'UpdateUserProfileParams(userId: $userId, profile: ${profile.name})';
}
