// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      stats: json['stats'] == null
          ? null
          : UserStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
      profileImageUrl: json['profileImageUrl'] as String?,
      preferences: json['preferences'] == null
          ? null
          : UserPreferencesModel.fromJson(
              json['preferences'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'createdAt': instance.createdAt.toIso8601String(),
      'stats': instance.stats,
      'profileImageUrl': instance.profileImageUrl,
      'preferences': instance.preferences,
    };

_$UserStatsModelImpl _$$UserStatsModelImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsModelImpl(
      totalQuizzes: (json['totalQuizzes'] as num?)?.toInt() ?? 0,
      totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      totalGamesWon: (json['totalGamesWon'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      lastGameDate: json['lastGameDate'] == null
          ? null
          : DateTime.parse(json['lastGameDate'] as String),
    );

Map<String, dynamic> _$$UserStatsModelImplToJson(
  _$UserStatsModelImpl instance,
) => <String, dynamic>{
  'totalQuizzes': instance.totalQuizzes,
  'totalGamesPlayed': instance.totalGamesPlayed,
  'totalGamesWon': instance.totalGamesWon,
  'averageScore': instance.averageScore,
  'lastGameDate': instance.lastGameDate?.toIso8601String(),
};

_$UserPreferencesModelImpl _$$UserPreferencesModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesModelImpl(
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  theme: json['theme'] as String? ?? 'light',
  language: json['language'] as String? ?? 'en',
);

Map<String, dynamic> _$$UserPreferencesModelImplToJson(
  _$UserPreferencesModelImpl instance,
) => <String, dynamic>{
  'soundEnabled': instance.soundEnabled,
  'notificationsEnabled': instance.notificationsEnabled,
  'theme': instance.theme,
  'language': instance.language,
};
