import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_multiplier.freezed.dart';

@freezed
class ScoreMultiplier with _$ScoreMultiplier {
  const factory ScoreMultiplier({
    required double speedMultiplier,
    required double streakMultiplier,
    required double accuracyMultiplier,
    required int basePoints,
  }) = _ScoreMultiplier;

  const ScoreMultiplier._();

  static const int maxSpeedBonus = 500;
  static const int maxStreakBonus = 200;
  static const int baseQuestionPoints = 1000;
  static const double maxSpeedMultiplier = 2.0;
  static const double maxStreakMultiplier = 1.5;

  int calculateSpeedBonus(Duration responseTime, Duration questionDuration) {
    if (responseTime >= questionDuration) return 0;

    final double remainingRatio =
        1 - (responseTime.inMilliseconds / questionDuration.inMilliseconds);
    return (maxSpeedBonus * remainingRatio * speedMultiplier).round();
  }

  int calculateStreakBonus(int currentStreak) {
    if (currentStreak <= 0) return 0;

    final double streakFactor = (currentStreak.clamp(0, 10) / 10.0);
    return (maxStreakBonus * streakFactor * streakMultiplier).round();
  }

  int calculateTotalScore({
    required bool isCorrect,
    required Duration responseTime,
    required Duration questionDuration,
    required int currentStreak,
  }) {
    if (!isCorrect) return 0;

    final int speedBonus = calculateSpeedBonus(responseTime, questionDuration);
    final int streakBonus = calculateStreakBonus(currentStreak);

    return basePoints + speedBonus + streakBonus;
  }
}
