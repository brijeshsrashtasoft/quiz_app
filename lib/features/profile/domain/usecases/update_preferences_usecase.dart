import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';
import '../entities/user_profile_entity.dart';
import '../../../../core/errors/failures.dart';

/// Use case for updating user preferences and settings
/// Handles preference validation and persistence
/// Following CLAUDE.md patterns and user experience optimization
class UpdatePreferencesUseCase
    extends BaseUseCase<UserProfileEntity, UpdatePreferencesParams> {
  final ProfileRepository profileRepository;

  UpdatePreferencesUseCase({required this.profileRepository});

  @override
  Future<Result<UserProfileEntity>> call(UpdatePreferencesParams params) async {
    try {
      AppLogger.info(
        'UpdatePreferencesUseCase',
        'Updating preferences for user: ${params.userId}',
      );

      // Validate preferences
      final validationResult = _validatePreferences(params.preferences);
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.failureOrNull!);
      }

      final startTime = DateTime.now();

      // Update user preferences
      final updateResult = await profileRepository.updateUserPreferences(
        params.userId,
        params.preferences,
      );

      if (!updateResult.isSuccess) {
        return Result.failure(updateResult.failureOrNull!);
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update Preferences Use Case', duration);
      AppLogger.info(
        'UpdatePreferencesUseCase',
        'Preferences update successful for user: ${params.userId}',
      );

      return Result.success(updateResult.dataOrNull!);
    } catch (e) {
      AppLogger.error('Preferences update failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update preferences. Please try again.',
        ),
      );
    }
  }

  /// Validate user preferences
  Result<void> _validatePreferences(UserPreferences preferences) {
    // Validate theme
    const validThemes = ['light', 'dark', 'system'];
    if (!validThemes.contains(preferences.theme)) {
      return Result.failure(
        Failure.serverFailure(message: 'Invalid theme selection'),
      );
    }

    // Validate language
    const validLanguages = [
      'en',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ru',
      'ja',
      'ko',
      'zh',
    ];
    if (!validLanguages.contains(preferences.language)) {
      return Result.failure(
        Failure.serverFailure(message: 'Invalid language selection'),
      );
    }

    // Validate difficulty preference
    const validDifficulties = ['easy', 'medium', 'hard', 'mixed'];
    if (!validDifficulties.contains(preferences.difficultyPreference)) {
      return Result.failure(
        Failure.serverFailure(message: 'Invalid difficulty preference'),
      );
    }

    return Result.success(null);
  }
}

/// Parameters for UpdatePreferencesUseCase
class UpdatePreferencesParams extends BaseUseCaseParams {
  final String userId;
  final UserPreferences preferences;

  const UpdatePreferencesParams({
    required this.userId,
    required this.preferences,
  });

  @override
  String toString() =>
      'UpdatePreferencesParams(userId: $userId, preferences: ${preferences.theme})';
}
