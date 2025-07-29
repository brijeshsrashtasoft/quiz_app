import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// User entity for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore structure
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String name,
    required String email,
    required DateTime createdAt,
    UserStats? stats,
    String? profileImageUrl,
    UserPreferences? preferences,
  }) = _UserEntity;
}

/// User statistics entity
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    @Default(0) int totalScore,
    @Default(0) int correctAnswers,
    @Default(0) int totalQuestions,
    @Default(0.0) double averageScore,
    DateTime? lastGameDate,
  }) = _UserStats;
}

/// User preferences entity
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool soundEnabled,
    @Default(true) bool notificationsEnabled,
    @Default('light') String theme,
    @Default('en') String language,
  }) = _UserPreferences;
}

/// User entity extensions for business logic
extension UserEntityX on UserEntity {
  /// Check if user profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty && email.isNotEmpty;
  }
  
  /// Get user's win rate as percentage
  double get winRate {
    if (stats == null || stats!.gamesPlayed == 0) return 0.0;
    return (stats!.gamesWon / stats!.gamesPlayed) * 100;
  }
  
  /// Get accuracy rate as percentage
  double get accuracyRate {
    if (stats == null || stats!.totalQuestions == 0) return 0.0;
    return (stats!.correctAnswers / stats!.totalQuestions) * 100;
  }
  
  /// Check if user is new (created within last 7 days)
  bool get isNewUser {
    final now = DateTime.now();
    final daysDifference = now.difference(createdAt).inDays;
    return daysDifference <= 7;
  }
}