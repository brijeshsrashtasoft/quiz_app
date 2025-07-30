// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardModelImpl _$$LeaderboardModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardModelImpl(
  sessionId: json['sessionId'] as String,
  scores: (json['scores'] as List<dynamic>)
      .map((e) => ScoreModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  finalResults: json['finalResults'] as bool? ?? false,
);

Map<String, dynamic> _$$LeaderboardModelImplToJson(
  _$LeaderboardModelImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'scores': instance.scores,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'finalResults': instance.finalResults,
};

_$ScoreModelImpl _$$ScoreModelImplFromJson(Map<String, dynamic> json) =>
    _$ScoreModelImpl(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      score: (json['score'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      totalAnswers: (json['totalAnswers'] as num).toInt(),
      rank: (json['rank'] as num?)?.toInt(),
      timeTaken: (json['timeTaken'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ScoreModelImplToJson(_$ScoreModelImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'score': instance.score,
      'correctAnswers': instance.correctAnswers,
      'totalAnswers': instance.totalAnswers,
      'rank': instance.rank,
      'timeTaken': instance.timeTaken,
    };
