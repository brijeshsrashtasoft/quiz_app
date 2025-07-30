import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_profile_entity.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

/// User profile data model for Clean Architecture data layer
/// Following CLAUDE.md patterns and Firestore integration
@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String id,
    required String name,
    required String email,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? profileImageUrl,
    String? username,
    String? bio,
    UserStatsModel? stats,
    UserPreferencesModel? preferences,
    PrivacySettingsModel? privacySettings,
    OnboardingStatusModel? onboardingStatus,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  /// Convert from domain entity
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      profileImageUrl: entity.profileImageUrl,
      username: entity.username,
      bio: entity.bio,
      stats: entity.stats != null
          ? UserStatsModel.fromEntity(entity.stats!)
          : null,
      preferences: entity.preferences != null
          ? UserPreferencesModel.fromEntity(entity.preferences!)
          : null,
      privacySettings: entity.privacySettings != null
          ? PrivacySettingsModel.fromEntity(entity.privacySettings!)
          : null,
      onboardingStatus: entity.onboardingStatus != null
          ? OnboardingStatusModel.fromEntity(entity.onboardingStatus!)
          : null,
    );
  }

  /// Convert from Firestore document
  factory UserProfileModel.fromFirestore(Map<String, dynamic> doc) {
    return UserProfileModel(
      id: doc['id'] ?? '',
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        doc['createdAt']?.millisecondsSinceEpoch ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        doc['updatedAt']?.millisecondsSinceEpoch ?? 0,
      ),
      profileImageUrl: doc['profileImageUrl'],
      username: doc['username'],
      bio: doc['bio'],
      stats: doc['stats'] != null
          ? UserStatsModel.fromFirestore(doc['stats'])
          : null,
      preferences: doc['preferences'] != null
          ? UserPreferencesModel.fromFirestore(doc['preferences'])
          : null,
      privacySettings: doc['privacySettings'] != null
          ? PrivacySettingsModel.fromFirestore(doc['privacySettings'])
          : null,
      onboardingStatus: doc['onboardingStatus'] != null
          ? OnboardingStatusModel.fromFirestore(doc['onboardingStatus'])
          : null,
    );
  }
}

/// User statistics data model
@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    @Default(0) int totalQuizzes,
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalGamesWon,
    @Default(0.0) double averageScore,
    @Default(0) int totalPoints,
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
    DateTime? lastGameDate,
    Map<String, int>? categoryStats,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);

  /// Convert from domain entity
  factory UserStatsModel.fromEntity(UserStats entity) {
    return UserStatsModel(
      totalQuizzes: entity.totalQuizzes,
      totalGamesPlayed: entity.totalGamesPlayed,
      totalGamesWon: entity.totalGamesWon,
      averageScore: entity.averageScore,
      totalPoints: entity.totalPoints,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
      lastGameDate: entity.lastGameDate,
      categoryStats: entity.categoryStats,
    );
  }

  /// Convert from Firestore document
  factory UserStatsModel.fromFirestore(Map<String, dynamic> doc) {
    return UserStatsModel(
      totalQuizzes: doc['totalQuizzes'] ?? 0,
      totalGamesPlayed: doc['totalGamesPlayed'] ?? 0,
      totalGamesWon: doc['totalGamesWon'] ?? 0,
      averageScore: (doc['averageScore'] ?? 0.0).toDouble(),
      totalPoints: doc['totalPoints'] ?? 0,
      currentStreak: doc['currentStreak'] ?? 0,
      bestStreak: doc['bestStreak'] ?? 0,
      lastGameDate: doc['lastGameDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc['lastGameDate'].millisecondsSinceEpoch,
            )
          : null,
      categoryStats: doc['categoryStats'] != null
          ? Map<String, int>.from(doc['categoryStats'])
          : null,
    );
  }
}

/// User preferences data model
@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  const factory UserPreferencesModel({
    @Default(true) bool soundEnabled,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool vibrationEnabled,
    @Default('light') String theme,
    @Default('en') String language,
    @Default('medium') String difficultyPreference,
    @Default(true) bool showOnlineStatus,
    @Default(true) bool allowFriendRequests,
  }) = _UserPreferencesModel;

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  /// Convert from domain entity
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      soundEnabled: entity.soundEnabled,
      notificationsEnabled: entity.notificationsEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      theme: entity.theme,
      language: entity.language,
      difficultyPreference: entity.difficultyPreference,
      showOnlineStatus: entity.showOnlineStatus,
      allowFriendRequests: entity.allowFriendRequests,
    );
  }

  /// Convert from Firestore document
  factory UserPreferencesModel.fromFirestore(Map<String, dynamic> doc) {
    return UserPreferencesModel(
      soundEnabled: doc['soundEnabled'] ?? true,
      notificationsEnabled: doc['notificationsEnabled'] ?? true,
      vibrationEnabled: doc['vibrationEnabled'] ?? true,
      theme: doc['theme'] ?? 'light',
      language: doc['language'] ?? 'en',
      difficultyPreference: doc['difficultyPreference'] ?? 'medium',
      showOnlineStatus: doc['showOnlineStatus'] ?? true,
      allowFriendRequests: doc['allowFriendRequests'] ?? true,
    );
  }
}

/// Privacy settings data model
@freezed
class PrivacySettingsModel with _$PrivacySettingsModel {
  const factory PrivacySettingsModel({
    @Default(true) bool profileVisible,
    @Default(true) bool statsVisible,
    @Default(false) bool emailVisible,
    @Default(true) bool allowGameInvites,
    @Default(true) bool showInLeaderboards,
    @Default(false) bool shareDataForAnalytics,
  }) = _PrivacySettingsModel;

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsModelFromJson(json);

  /// Convert from domain entity
  factory PrivacySettingsModel.fromEntity(PrivacySettings entity) {
    return PrivacySettingsModel(
      profileVisible: entity.profileVisible,
      statsVisible: entity.statsVisible,
      emailVisible: entity.emailVisible,
      allowGameInvites: entity.allowGameInvites,
      showInLeaderboards: entity.showInLeaderboards,
      shareDataForAnalytics: entity.shareDataForAnalytics,
    );
  }

  /// Convert from Firestore document
  factory PrivacySettingsModel.fromFirestore(Map<String, dynamic> doc) {
    return PrivacySettingsModel(
      profileVisible: doc['profileVisible'] ?? true,
      statsVisible: doc['statsVisible'] ?? true,
      emailVisible: doc['emailVisible'] ?? false,
      allowGameInvites: doc['allowGameInvites'] ?? true,
      showInLeaderboards: doc['showInLeaderboards'] ?? true,
      shareDataForAnalytics: doc['shareDataForAnalytics'] ?? false,
    );
  }
}

/// Onboarding status data model
@freezed
class OnboardingStatusModel with _$OnboardingStatusModel {
  const factory OnboardingStatusModel({
    @Default(false) bool profileSetupComplete,
    @Default(false) bool firstGamePlayed,
    @Default(false) bool preferencesSet,
    @Default(false) bool privacySettingsSet,
    @Default(false) bool tutorialCompleted,
    DateTime? completedAt,
  }) = _OnboardingStatusModel;

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusModelFromJson(json);

  /// Convert from domain entity
  factory OnboardingStatusModel.fromEntity(OnboardingStatus entity) {
    return OnboardingStatusModel(
      profileSetupComplete: entity.profileSetupComplete,
      firstGamePlayed: entity.firstGamePlayed,
      preferencesSet: entity.preferencesSet,
      privacySettingsSet: entity.privacySettingsSet,
      tutorialCompleted: entity.tutorialCompleted,
      completedAt: entity.completedAt,
    );
  }

  /// Convert from Firestore document
  factory OnboardingStatusModel.fromFirestore(Map<String, dynamic> doc) {
    return OnboardingStatusModel(
      profileSetupComplete: doc['profileSetupComplete'] ?? false,
      firstGamePlayed: doc['firstGamePlayed'] ?? false,
      preferencesSet: doc['preferencesSet'] ?? false,
      privacySettingsSet: doc['privacySettingsSet'] ?? false,
      tutorialCompleted: doc['tutorialCompleted'] ?? false,
      completedAt: doc['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc['completedAt'].millisecondsSinceEpoch,
            )
          : null,
    );
  }
}

/// Extension methods for converting models to entities
extension UserProfileModelX on UserProfileModel {
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profileImageUrl: profileImageUrl,
      username: username,
      bio: bio,
      stats: stats?.toEntity(),
      preferences: preferences?.toEntity(),
      privacySettings: privacySettings?.toEntity(),
      onboardingStatus: onboardingStatus?.toEntity(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio,
      if (stats != null) 'stats': stats!.toFirestore(),
      if (preferences != null) 'preferences': preferences!.toFirestore(),
      if (privacySettings != null) 'privacySettings': privacySettings!.toFirestore(),
      if (onboardingStatus != null) 'onboardingStatus': onboardingStatus!.toFirestore(),
    };
  }
}

extension UserStatsModelX on UserStatsModel {
  UserStats toEntity() {
    return UserStats(
      totalQuizzes: totalQuizzes,
      totalGamesPlayed: totalGamesPlayed,
      totalGamesWon: totalGamesWon,
      averageScore: averageScore,
      totalPoints: totalPoints,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastGameDate: lastGameDate,
      categoryStats: categoryStats,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalQuizzes': totalQuizzes,
      'totalGamesPlayed': totalGamesPlayed,
      'totalGamesWon': totalGamesWon,
      'averageScore': averageScore,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      if (lastGameDate != null) 'lastGameDate': lastGameDate,
      if (categoryStats != null) 'categoryStats': categoryStats,
    };
  }
}

extension UserPreferencesModelX on UserPreferencesModel {
  UserPreferences toEntity() {
    return UserPreferences(
      soundEnabled: soundEnabled,
      notificationsEnabled: notificationsEnabled,
      vibrationEnabled: vibrationEnabled,
      theme: theme,
      language: language,
      difficultyPreference: difficultyPreference,
      showOnlineStatus: showOnlineStatus,
      allowFriendRequests: allowFriendRequests,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'vibrationEnabled': vibrationEnabled,
      'theme': theme,
      'language': language,
      'difficultyPreference': difficultyPreference,
      'showOnlineStatus': showOnlineStatus,
      'allowFriendRequests': allowFriendRequests,
    };
  }
}

extension PrivacySettingsModelX on PrivacySettingsModel {
  PrivacySettings toEntity() {
    return PrivacySettings(
      profileVisible: profileVisible,
      statsVisible: statsVisible,
      emailVisible: emailVisible,
      allowGameInvites: allowGameInvites,
      showInLeaderboards: showInLeaderboards,
      shareDataForAnalytics: shareDataForAnalytics,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profileVisible': profileVisible,
      'statsVisible': statsVisible,
      'emailVisible': emailVisible,
      'allowGameInvites': allowGameInvites,
      'showInLeaderboards': showInLeaderboards,
      'shareDataForAnalytics': shareDataForAnalytics,
    };
  }
}

extension OnboardingStatusModelX on OnboardingStatusModel {
  OnboardingStatus toEntity() {
    return OnboardingStatus(
      profileSetupComplete: profileSetupComplete,
      firstGamePlayed: firstGamePlayed,
      preferencesSet: preferencesSet,
      privacySettingsSet: privacySettingsSet,
      tutorialCompleted: tutorialCompleted,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profileSetupComplete': profileSetupComplete,
      'firstGamePlayed': firstGamePlayed,
      'preferencesSet': preferencesSet,
      'privacySettingsSet': privacySettingsSet,
      'tutorialCompleted': tutorialCompleted,
      if (completedAt != null) 'completedAt': completedAt,
    };
  }
}