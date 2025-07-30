import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

/// User profile entity for Clean Architecture domain layer
/// Focused on profile management-specific fields and operations
/// Following CLAUDE.md patterns and extending base user functionality
@freezed
class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String name,
    required String email,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? profileImageUrl,
    String? username,
    String? bio,
    UserStats? stats,
    UserPreferences? preferences,
    PrivacySettings? privacySettings,
    OnboardingStatus? onboardingStatus,
  }) = _UserProfileEntity;
}

/// User statistics entity for profile tracking
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int totalQuizzes,
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalGamesWon,
    @Default(0.0) double averageScore,
    @Default(0) int totalPoints,
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
    DateTime? lastGameDate,
    Map<String, int>? categoryStats,
  }) = _UserStats;
}

/// User preferences entity for settings management
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool soundEnabled,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool vibrationEnabled,
    @Default('light') String theme,
    @Default('en') String language,
    @Default('medium') String difficultyPreference,
    @Default(true) bool showOnlineStatus,
    @Default(true) bool allowFriendRequests,
  }) = _UserPreferences;
}

/// Privacy settings entity for user privacy control
@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(true) bool profileVisible,
    @Default(true) bool statsVisible,
    @Default(false) bool emailVisible,
    @Default(true) bool allowGameInvites,
    @Default(true) bool showInLeaderboards,
    @Default(false) bool shareDataForAnalytics,
  }) = _PrivacySettings;
}

/// Onboarding status entity for tracking user onboarding progress
@freezed
class OnboardingStatus with _$OnboardingStatus {
  const factory OnboardingStatus({
    @Default(false) bool profileSetupComplete,
    @Default(false) bool firstGamePlayed,
    @Default(false) bool preferencesSet,
    @Default(false) bool privacySettingsSet,
    @Default(false) bool tutorialCompleted,
    DateTime? completedAt,
  }) = _OnboardingStatus;
}

/// User profile entity extensions for business logic
extension UserProfileEntityX on UserProfileEntity {
  /// Check if user profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        username != null &&
        username!.isNotEmpty;
  }

  /// Check if profile setup is complete
  bool get isSetupComplete {
    return onboardingStatus?.profileSetupComplete ?? false;
  }

  /// Get user's win rate as percentage
  double get winRate {
    if (stats == null || stats!.totalGamesPlayed == 0) return 0.0;
    return (stats!.totalGamesWon / stats!.totalGamesPlayed) * 100;
  }

  /// Check if user is experienced player
  bool get isExperiencedPlayer {
    return stats != null && stats!.totalGamesPlayed >= 10;
  }

  /// Check if user is new (created within last 7 days)
  bool get isNewUser {
    final now = DateTime.now();
    final daysDifference = now.difference(createdAt).inDays;
    return daysDifference <= 7;
  }

  /// Check if user can host games
  bool get canHostGames {
    return isProfileComplete &&
        !isNewUser &&
        (stats?.totalGamesPlayed ?? 0) >= 3;
  }

  /// Check if user profile is public
  bool get isPublicProfile {
    return privacySettings?.profileVisible ?? true;
  }

  /// Check if user allows game invites
  bool get allowsGameInvites {
    return privacySettings?.allowGameInvites ?? true;
  }

  /// Get user level based on total points
  int get userLevel {
    final points = stats?.totalPoints ?? 0;
    if (points < 100) return 1;
    if (points < 500) return 2;
    if (points < 1500) return 3;
    if (points < 3000) return 4;
    if (points < 5000) return 5;
    return 6; // Max level
  }

  /// Get user rank title based on level
  String get userRank {
    switch (userLevel) {
      case 1:
        return 'Newcomer';
      case 2:
        return 'Quiz Explorer';
      case 3:
        return 'Knowledge Seeker';
      case 4:
        return 'Quiz Master';
      case 5:
        return 'Trivia Champion';
      case 6:
        return 'Quiz Legend';
      default:
        return 'Player';
    }
  }

  /// Check if onboarding is complete
  bool get isOnboardingComplete {
    return (onboardingStatus?.profileSetupComplete ?? false) &&
           (onboardingStatus?.preferencesSet ?? false) &&
           (onboardingStatus?.privacySettingsSet ?? false);
  }

  /// Get completion percentage for profile setup
  double get profileCompletionPercentage {
    int completed = 0;
    int total = 6;

    if (name.isNotEmpty) completed++;
    if (username != null && username!.isNotEmpty) completed++;
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;
    if (preferences != null) completed++;
    if (privacySettings != null) completed++;

    return (completed / total) * 100;
  }
}
