import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/score_entity.dart';

part 'score_model.freezed.dart';
part 'score_model.g.dart';

@freezed
class ScoreModel with _$ScoreModel {
  const factory ScoreModel({
    required String playerId,
    required String playerName,
    required int basePoints,
    required int speedBonus,
    required int streakBonus,
    required int totalScore,
    required DateTime timestamp,
    required int questionIndex,
    required int responseTimeMs,
    required bool isCorrect,
  }) = _ScoreModel;

  const ScoreModel._();

  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);

  factory ScoreModel.fromEntity(ScoreEntity entity) => ScoreModel(
    playerId: entity.playerId,
    playerName: entity.playerName,
    basePoints: entity.basePoints,
    speedBonus: entity.speedBonus,
    streakBonus: entity.streakBonus,
    totalScore: entity.totalScore,
    timestamp: entity.timestamp,
    questionIndex: entity.questionIndex,
    responseTimeMs: entity.responseTime.inMilliseconds,
    isCorrect: entity.isCorrect,
  );

  ScoreEntity toEntity() => ScoreEntity(
    playerId: playerId,
    playerName: playerName,
    basePoints: basePoints,
    speedBonus: speedBonus,
    streakBonus: streakBonus,
    totalScore: totalScore,
    timestamp: timestamp,
    questionIndex: questionIndex,
    responseTime: Duration(milliseconds: responseTimeMs),
    isCorrect: isCorrect,
  );
}
