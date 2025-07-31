import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_entity.freezed.dart';

@freezed
class ScoreEntity with _$ScoreEntity {
  const factory ScoreEntity({
    required String playerId,
    required String playerName,
    required int basePoints,
    required int speedBonus,
    required int streakBonus,
    required int totalScore,
    required DateTime timestamp,
    required int questionIndex,
    required Duration responseTime,
    required bool isCorrect,
  }) = _ScoreEntity;

  const ScoreEntity._();

  int get finalScore => basePoints + speedBonus + streakBonus;
}