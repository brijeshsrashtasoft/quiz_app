// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardModelImpl _$$LeaderboardModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardModelImpl(
  sessionId: json['sessionId'] as String,
  quizId: json['quizId'] as String,
  entries: (json['entries'] as List<dynamic>)
      .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  type: json['type'] as String,
  totalPlayers: (json['totalPlayers'] as num).toInt(),
);

Map<String, dynamic> _$$LeaderboardModelImplToJson(
  _$LeaderboardModelImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'quizId': instance.quizId,
  'entries': instance.entries,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'type': instance.type,
  'totalPlayers': instance.totalPlayers,
};
