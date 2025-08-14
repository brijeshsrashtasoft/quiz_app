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
    String? photoURL, // For Firebase Auth compatibility
    String? displayName, // For profile display
    String? username, // For unique usernames
    String? bio, // For user description
    UserPreferences? preferences,
  }) = _UserEntity;
}

/// User statistics entity matching Firestore schema
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int totalQuizzes,
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalGamesWon,
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

  /// Check if user can host games (basic host permission check)
  bool get canHostGames {
    return isProfileComplete && !isNewUser;
  }

  /// Check if user has admin privileges (basic implementation)
  bool get isAdmin {
    // This is a simple implementation - in production, use proper role-based access
    const adminEmails = ['admin@quizapp.com', 'support@quizapp.com'];

    return adminEmails.contains(email.toLowerCase()) ||
        email.toLowerCase().endsWith('@quizapp.com');
  }
}
