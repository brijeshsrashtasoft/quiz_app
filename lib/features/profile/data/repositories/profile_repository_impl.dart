import 'dart:io';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

/// Profile repository implementation for Clean Architecture
/// Handles data layer coordination between remote and local sources
/// Following CLAUDE.md patterns and offline-first approach
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<UserProfileEntity>> getProfile(String userId) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Getting profile: $userId');

      if (await networkInfo.isConnected) {
        // Online: Get from remote and cache locally
        try {
          final remoteProfile = await remoteDataSource.getProfile(userId);
          await localDataSource.cacheProfile(remoteProfile);
          await localDataSource.setLastSyncTimestamp(userId, DateTime.now());
          
          return Result.success(remoteProfile.toEntity());
        } catch (e) {
          AppLogger.warning('Failed to get remote profile, trying cache', e);
          // Fall back to cached data if remote fails
          return _getCachedProfile(userId);
        }
      } else {
        // Offline: Get from cache
        return _getCachedProfile(userId);
      }
    } catch (e) {
      AppLogger.error('Get profile failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to get profile',
        ),
      );
    }
  }

  Future<Result<UserProfileEntity>> _getCachedProfile(String userId) async {
    final cachedProfile = await localDataSource.getCachedProfile(userId);
    if (cachedProfile != null) {
      return Result.success(cachedProfile.toEntity());
    }
    
    return Result.failure(
      Failure.serverFailure(
        message: 'Profile not found',
      ),
    );
  }

  @override
  Future<Result<UserProfileEntity>> updateProfile(UserProfileEntity profile) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Updating profile: ${profile.id}');

      if (await networkInfo.isConnected) {
        final profileModel = UserProfileModel.fromEntity(profile);
        final updatedProfile = await remoteDataSource.updateProfile(profileModel);
        
        // Cache updated profile
        await localDataSource.cacheProfile(updatedProfile);
        await localDataSource.setLastSyncTimestamp(profile.id, DateTime.now());
        
        return Result.success(updatedProfile.toEntity());
      } else {
        // Offline: Cache for later sync
        final profileModel = UserProfileModel.fromEntity(profile);
        await localDataSource.cacheProfile(profileModel);
        
        return Result.failure(
          Failure.networkFailure(
            message: 'Profile update will sync when online',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Update profile failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update profile',
        ),
      );
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String userId, File imageFile) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Uploading avatar: $userId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to upload avatar',
          ),
        );
      }

      final avatarUrl = await remoteDataSource.uploadAvatar(userId, imageFile);
      return Result.success(avatarUrl);
    } catch (e) {
      AppLogger.error('Upload avatar failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to upload avatar',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteAvatar(String userId) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Deleting avatar: $userId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to delete avatar',
          ),
        );
      }

      await remoteDataSource.deleteAvatar(userId);
      return Result.success(null);
    } catch (e) {
      AppLogger.error('Delete avatar failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to delete avatar',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Checking username availability: $username');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to check username',
          ),
        );
      }

      final isAvailable = await remoteDataSource.isUsernameAvailable(username);
      return Result.success(isAvailable);
    } catch (e) {
      AppLogger.error('Username availability check failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.validationFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.validationFailure(
          message: 'Failed to check username availability',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfileEntity>> updateUserStats(String userId, UserStats stats) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Updating user stats: $userId');

      if (await networkInfo.isConnected) {
        final statsModel = UserStatsModel.fromEntity(stats);
        final updatedProfile = await remoteDataSource.updateUserStats(userId, statsModel);
        
        // Cache updated profile and stats
        await localDataSource.cacheProfile(updatedProfile);
        await localDataSource.cacheUserStats(userId, statsModel);
        await localDataSource.setLastSyncTimestamp(userId, DateTime.now());
        
        return Result.success(updatedProfile.toEntity());
      } else {
        // Offline: Cache for later sync
        final statsModel = UserStatsModel.fromEntity(stats);
        await localDataSource.cacheUserStats(userId, statsModel);
        
        return Result.failure(
          Failure.networkFailure(
            message: 'Stats update will sync when online',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Update user stats failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update user statistics',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfileEntity>> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Updating user preferences: $userId');

      final preferencesModel = UserPreferencesModel.fromEntity(preferences);
      
      // Always cache preferences locally for immediate app behavior
      await localDataSource.cacheUserPreferences(userId, preferencesModel);

      if (await networkInfo.isConnected) {
        final updatedProfile = await remoteDataSource.updateUserPreferences(userId, preferencesModel);
        await localDataSource.cacheProfile(updatedProfile);
        await localDataSource.setLastSyncTimestamp(userId, DateTime.now());
        
        return Result.success(updatedProfile.toEntity());
      } else {
        // Offline: Return current cached profile with updated preferences
        final cachedProfile = await localDataSource.getCachedProfile(userId);
        if (cachedProfile != null) {
          final updatedProfile = cachedProfile.copyWith(preferences: preferencesModel);
          await localDataSource.cacheProfile(updatedProfile);
          return Result.success(updatedProfile.toEntity());
        }
        
        return Result.failure(
          Failure.networkFailure(
            message: 'Preferences update will sync when online',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Update user preferences failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update user preferences',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfileEntity>> updatePrivacySettings(String userId, PrivacySettings privacySettings) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Updating privacy settings: $userId');

      if (await networkInfo.isConnected) {
        final privacyModel = PrivacySettingsModel.fromEntity(privacySettings);
        final updatedProfile = await remoteDataSource.updatePrivacySettings(userId, privacyModel);
        
        await localDataSource.cacheProfile(updatedProfile);
        await localDataSource.setLastSyncTimestamp(userId, DateTime.now());
        
        return Result.success(updatedProfile.toEntity());
      } else {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to update privacy settings',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Update privacy settings failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update privacy settings',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfileEntity>> updateOnboardingStatus(String userId, OnboardingStatus onboardingStatus) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Updating onboarding status: $userId');

      if (await networkInfo.isConnected) {
        final onboardingModel = OnboardingStatusModel.fromEntity(onboardingStatus);
        final updatedProfile = await remoteDataSource.updateOnboardingStatus(userId, onboardingModel);
        
        await localDataSource.cacheProfile(updatedProfile);
        await localDataSource.setLastSyncTimestamp(userId, DateTime.now());
        
        return Result.success(updatedProfile.toEntity());
      } else {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to update onboarding status',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Update onboarding status failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update onboarding status',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount(String userId) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Deleting account: $userId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to delete account',
          ),
        );
      }

      await remoteDataSource.deleteAccount(userId);
      await localDataSource.removeCachedProfile(userId);
      
      return Result.success(null);
    } catch (e) {
      AppLogger.error('Delete account failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to delete account',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserProfileEntity>>> searchProfiles(String query) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Searching profiles: $query');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to search profiles',
          ),
        );
      }

      final profiles = await remoteDataSource.searchProfiles(query);
      final entities = profiles.map((profile) => profile.toEntity()).toList();
      
      return Result.success(entities);
    } catch (e) {
      AppLogger.error('Search profiles failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to search profiles',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserProfileEntity>>> getTopUsers(int limit) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Getting top users: $limit');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to get top users',
          ),
        );
      }

      final profiles = await remoteDataSource.getTopUsers(limit);
      final entities = profiles.map((profile) => profile.toEntity()).toList();
      
      return Result.success(entities);
    } catch (e) {
      AppLogger.error('Get top users failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to get top users',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserProfileEntity>>> getUserConnections(String userId) async {
    // This would be implemented based on your connection/friend system requirements
    // For now, returning empty list as connections feature is not in current scope
    return Result.success(<UserProfileEntity>[]);
  }

  @override
  Stream<Result<UserProfileEntity>> watchProfile(String userId) {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Watching profile: $userId');

      return remoteDataSource.watchProfile(userId).map((profile) {
        // Cache received profile updates
        localDataSource.cacheProfile(profile);
        localDataSource.setLastSyncTimestamp(userId, DateTime.now());
        
        return Result.success(profile.toEntity());
      }).handleError((error) {
        AppLogger.error('Watch profile stream error', error);
        return Result.failure(
          Failure.serverFailure(
            message: 'Failed to watch profile',
          ),
        );
      });
    } catch (e) {
      AppLogger.error('Watch profile failed', e);
      return Stream.value(
        Result.failure(
          Failure.serverFailure(
            message: 'Failed to watch profile',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<List<String>>> getProfileCompletionSuggestions(String userId) async {
    try {
      final profileResult = await getProfile(userId);
      if (!profileResult.isSuccess) {
        return Result.failure(profileResult.failureOrNull!);
      }

      final profile = profileResult.dataOrNull!;
      final suggestions = <String>[];

      if (profile.username == null || profile.username!.isEmpty) {
        suggestions.add('Add a unique username');
      }
      if (profile.profileImageUrl == null || profile.profileImageUrl!.isEmpty) {
        suggestions.add('Upload a profile picture');
      }
      if (profile.bio == null || profile.bio!.isEmpty) {
        suggestions.add('Write a short bio');
      }
      if (profile.preferences == null) {
        suggestions.add('Set your game preferences');
      }
      if (profile.privacySettings == null) {
        suggestions.add('Configure privacy settings');
      }

      return Result.success(suggestions);
    } catch (e) {
      AppLogger.error('Get profile completion suggestions failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to get suggestions',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> validateProfileData(UserProfileEntity profile) async {
    try {
      // Basic validation rules
      if (profile.name.isEmpty) {
        return Result.failure(
          Failure.serverFailure(
            message: 'Name cannot be empty',
          ),
        );
      }

      if (profile.email.isEmpty) {
        return Result.failure(
          Failure.serverFailure(
            message: 'Email cannot be empty',
          ),
        );
      }

      if (profile.bio != null && profile.bio!.length > 500) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Bio must be less than 500 characters',
          ),
        );
      }

      return Result.success(true);
    } catch (e) {
      AppLogger.error('Validate profile data failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Profile validation failed',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserActivitySummary(String userId) async {
    try {
      final profileResult = await getProfile(userId);
      if (!profileResult.isSuccess) {
        return Result.failure(profileResult.failureOrNull!);
      }

      final profile = profileResult.dataOrNull!;
      final stats = profile.stats;

      final summary = <String, dynamic>{
        'totalGames': stats?.totalGamesPlayed ?? 0,
        'totalWins': stats?.totalGamesWon ?? 0,
        'winRate': profile.winRate,
        'totalPoints': stats?.totalPoints ?? 0,
        'currentStreak': stats?.currentStreak ?? 0,
        'bestStreak': stats?.bestStreak ?? 0,
        'userLevel': profile.userLevel,
        'userRank': profile.userRank,
        'isExperiencedPlayer': profile.isExperiencedPlayer,
        'lastActive': stats?.lastGameDate,
      };

      return Result.success(summary);
    } catch (e) {
      AppLogger.error('Get user activity summary failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to get activity summary',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfileEntity>> updateUserLevel(String userId) async {
    try {
      final profileResult = await getProfile(userId);
      if (!profileResult.isSuccess) {
        return Result.failure(profileResult.failureOrNull!);
      }

      final profile = profileResult.dataOrNull!;
      // Level is calculated automatically in the entity extension
      // This method could trigger achievements or notifications
      
      return Result.success(profile);
    } catch (e) {
      AppLogger.error('Update user level failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update user level',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserProfileEntity>>> getUsersByRegion(String region) async {
    // This would be implemented based on your regional requirements
    // For now, returning empty list as regional features are not in current scope
    return Result.success(<UserProfileEntity>[]);
  }

  @override
  Future<Result<void>> blockUser(String userId, String targetUserId) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Blocking user: $userId -> $targetUserId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to block user',
          ),
        );
      }

      await remoteDataSource.blockUser(userId, targetUserId);
      return Result.success(null);
    } catch (e) {
      AppLogger.error('Block user failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to block user',
        ),
      );
    }
  }

  @override
  Future<Result<void>> unblockUser(String userId, String targetUserId) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Unblocking user: $userId -> $targetUserId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to unblock user',
          ),
        );
      }

      await remoteDataSource.unblockUser(userId, targetUserId);
      return Result.success(null);
    } catch (e) {
      AppLogger.error('Unblock user failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to unblock user',
        ),
      );
    }
  }

  @override
  Future<Result<List<String>>> getBlockedUsers(String userId) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Getting blocked users: $userId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to get blocked users',
          ),
        );
      }

      final blockedUsers = await remoteDataSource.getBlockedUsers(userId);
      return Result.success(blockedUsers);
    } catch (e) {
      AppLogger.error('Get blocked users failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to get blocked users',
        ),
      );
    }
  }

  @override
  Future<Result<void>> reportUser(String reporterId, String reportedUserId, String reason) async {
    try {
      AppLogger.info('ProfileRepositoryImpl', 'Reporting user: $reporterId -> $reportedUserId');

      if (!(await networkInfo.isConnected)) {
        return Result.failure(
          Failure.networkFailure(
            message: 'Internet connection required to report user',
          ),
        );
      }

      await remoteDataSource.reportUser(reporterId, reportedUserId, reason);
      return Result.success(null);
    } catch (e) {
      AppLogger.error('Report user failed', e);
      
      if (e is ServerException) {
        return Result.failure(
          Failure.serverFailure(
            message: e.message,
          ),
        );
      }
      
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to report user',
        ),
      );
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getUserReports(String userId) async {
    // This would be implemented for admin users to view reports
    // For now, returning empty list as admin features are not in current scope
    return Result.success(<Map<String, dynamic>>[]);
  }
}