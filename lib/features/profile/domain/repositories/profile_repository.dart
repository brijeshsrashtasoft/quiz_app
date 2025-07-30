import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/user_profile_entity.dart';

/// Profile repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and defining contracts for profile operations
abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Result<UserProfileEntity>> getProfile(String userId);

  /// Update user profile information
  Future<Result<UserProfileEntity>> updateProfile(UserProfileEntity profile);

  /// Upload avatar image and return URL
  Future<Result<String>> uploadAvatar(String userId, File imageFile);

  /// Delete avatar image
  Future<Result<void>> deleteAvatar(String userId);

  /// Check if username is available
  Future<Result<bool>> isUsernameAvailable(String username);

  /// Update user statistics
  Future<Result<UserProfileEntity>> updateUserStats(
    String userId,
    UserStats stats,
  );

  /// Update user preferences
  Future<Result<UserProfileEntity>> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  );

  /// Update privacy settings
  Future<Result<UserProfileEntity>> updatePrivacySettings(
    String userId,
    PrivacySettings privacySettings,
  );

  /// Update onboarding status
  Future<Result<UserProfileEntity>> updateOnboardingStatus(
    String userId,
    OnboardingStatus onboardingStatus,
  );

  /// Delete user account completely
  Future<Result<void>> deleteAccount(String userId);

  /// Search profiles by username
  Future<Result<List<UserProfileEntity>>> searchProfiles(String query);

  /// Get top users by points
  Future<Result<List<UserProfileEntity>>> getTopUsers(int limit);

  /// Get user's friends/connections
  Future<Result<List<UserProfileEntity>>> getUserConnections(String userId);

  /// Stream profile for real-time updates
  Stream<Result<UserProfileEntity>> watchProfile(String userId);

  /// Get profile completion suggestions
  Future<Result<List<String>>> getProfileCompletionSuggestions(String userId);

  /// Validate profile data
  Future<Result<bool>> validateProfileData(UserProfileEntity profile);

  /// Get user activity summary
  Future<Result<Map<String, dynamic>>> getUserActivitySummary(String userId);

  /// Update user level/rank based on achievements
  Future<Result<UserProfileEntity>> updateUserLevel(String userId);

  /// Get users by location/region (for local leaderboards)
  Future<Result<List<UserProfileEntity>>> getUsersByRegion(String region);

  /// Block/unblock user
  Future<Result<void>> blockUser(String userId, String targetUserId);
  Future<Result<void>> unblockUser(String userId, String targetUserId);

  /// Get blocked users list
  Future<Result<List<String>>> getBlockedUsers(String userId);

  /// Report user profile
  Future<Result<void>> reportUser(
    String reporterId,
    String reportedUserId,
    String reason,
  );

  /// Get user reports (admin function)
  Future<Result<List<Map<String, dynamic>>>> getUserReports(String userId);
}
