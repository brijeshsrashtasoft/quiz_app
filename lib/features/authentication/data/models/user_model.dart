import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model for data layer
/// Following CLAUDE.md patterns and Firestore integration
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required DateTime createdAt,
    UserStatsModel? stats,
    String? profileImageUrl,
    UserPreferencesModel? preferences,
  }) = _UserModel;

  /// Create from Firestore document data
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      stats: data['stats'] != null
          ? UserStatsModel.fromMap(data['stats'] as Map<String, dynamic>)
          : null,
      profileImageUrl: data['profileImageUrl'] as String?,
      preferences: data['preferences'] != null
          ? UserPreferencesModel.fromMap(
              data['preferences'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// User statistics model
@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    @Default(0) int totalQuizzes,
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalGamesWon,
    @Default(0.0) double averageScore,
    DateTime? lastGameDate,
  }) = _UserStatsModel;

  /// Create from Firestore map
  factory UserStatsModel.fromMap(Map<String, dynamic> data) {
    return UserStatsModel(
      totalQuizzes: (data['totalQuizzes'] as num?)?.toInt() ?? 0,
      totalGamesPlayed: (data['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      totalGamesWon: (data['totalGamesWon'] as num?)?.toInt() ?? 0,
      averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
      lastGameDate: data['lastGameDate'] != null
          ? (data['lastGameDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create from JSON
  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);
}

/// User preferences model
@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  const factory UserPreferencesModel({
    @Default(true) bool soundEnabled,
    @Default(true) bool notificationsEnabled,
    @Default('light') String theme,
    @Default('en') String language,
  }) = _UserPreferencesModel;

  /// Create from Firestore map
  factory UserPreferencesModel.fromMap(Map<String, dynamic> data) {
    return UserPreferencesModel(
      soundEnabled: data['soundEnabled'] as bool? ?? true,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      theme: data['theme'] as String? ?? 'light',
      language: data['language'] as String? ?? 'en',
    );
  }

  /// Create from JSON
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);
}

/// Extensions for model conversions
extension UserModelX on UserModel {
  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt,
      stats: stats?.toEntity(),
      profileImageUrl: profileImageUrl,
      preferences: preferences?.toEntity(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (stats != null) {
      data['stats'] = stats!.toFirestore();
    }

    if (profileImageUrl != null) {
      data['profileImageUrl'] = profileImageUrl;
    }

    if (preferences != null) {
      data['preferences'] = preferences!.toFirestore();
    }

    return data;
  }
}

extension UserStatsModelX on UserStatsModel {
  /// Convert to domain entity
  UserStats toEntity() {
    return UserStats(
      totalQuizzes: totalQuizzes,
      totalGamesPlayed: totalGamesPlayed,
      totalGamesWon: totalGamesWon,
      averageScore: averageScore,
      lastGameDate: lastGameDate,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'totalQuizzes': totalQuizzes,
      'totalGamesPlayed': totalGamesPlayed,
      'totalGamesWon': totalGamesWon,
      'averageScore': averageScore,
    };

    if (lastGameDate != null) {
      data['lastGameDate'] = Timestamp.fromDate(lastGameDate!);
    }

    return data;
  }
}

extension UserPreferencesModelX on UserPreferencesModel {
  /// Convert to domain entity
  UserPreferences toEntity() {
    return UserPreferences(
      soundEnabled: soundEnabled,
      notificationsEnabled: notificationsEnabled,
      theme: theme,
      language: language,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
      'language': language,
    };
  }
}

/// Factory extensions for entity to model conversion
extension UserEntityX on UserEntity {
  /// Convert to data model
  UserModel toModel() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt,
      stats: stats?.toModel(),
      profileImageUrl: profileImageUrl,
      preferences: preferences?.toModel(),
    );
  }
}

extension UserStatsX on UserStats {
  /// Convert to data model
  UserStatsModel toModel() {
    return UserStatsModel(
      totalQuizzes: totalQuizzes,
      totalGamesPlayed: totalGamesPlayed,
      totalGamesWon: totalGamesWon,
      averageScore: averageScore,
      lastGameDate: lastGameDate,
    );
  }
}

extension UserPreferencesX on UserPreferences {
  /// Convert to data model
  UserPreferencesModel toModel() {
    return UserPreferencesModel(
      soundEnabled: soundEnabled,
      notificationsEnabled: notificationsEnabled,
      theme: theme,
      language: language,
    );
  }
}
