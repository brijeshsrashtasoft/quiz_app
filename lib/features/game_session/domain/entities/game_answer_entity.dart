import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_answer_entity.freezed.dart';

/// Entity for tracking player answers in real-time
/// Optimized for minimal Firestore operations
@freezed
class GameAnswerEntity with _$GameAnswerEntity {
  const factory GameAnswerEntity({
    required String playerId,
    required String playerName,
    required int questionIndex,
    required int selectedAnswer,
    required DateTime answeredAt,
    required int responseTimeMs,
    @Default(false) bool isCorrect,
    @Default(0) int pointsEarned,
    @Default(0) int streakBonus,
  }) = _GameAnswerEntity;
}

/// Batch answer submission for optimized writes
@freezed
class AnswerBatch with _$AnswerBatch {
  const factory AnswerBatch({
    required String sessionId,
    required List<GameAnswerEntity> answers,
    required DateTime batchTime,
  }) = _AnswerBatch;
}

/// Answer statistics for real-time display
@freezed
class AnswerStats with _$AnswerStats {
  const factory AnswerStats({
    required int questionIndex,
    required Map<int, int> answerDistribution,
    required int totalAnswers,
    required double averageResponseTime,
    required int correctAnswers,
    @Default([]) List<String> fastestPlayers,
  }) = _AnswerStats;
}

/// Extensions for answer processing
extension GameAnswerEntityX on GameAnswerEntity {
  /// Calculate points based on speed and correctness
  int calculatePoints({required int basePoints, required int maxTimeMs}) {
    if (!isCorrect) return 0;

    // Base points for correct answer
    int points = basePoints;

    // Speed bonus (up to 50% extra)
    if (responseTimeMs < maxTimeMs) {
      final speedBonus =
          ((maxTimeMs - responseTimeMs) / maxTimeMs * basePoints * 0.5).round();
      points += speedBonus;
    }

    // Add streak bonus if any
    points += streakBonus;

    return points;
  }

  /// Check if answer was submitted quickly
  bool get isQuickAnswer => responseTimeMs < 3000; // Less than 3 seconds

  /// Get performance rating
  AnswerPerformance get performance {
    if (!isCorrect) return AnswerPerformance.incorrect;
    if (responseTimeMs < 2000) return AnswerPerformance.excellent;
    if (responseTimeMs < 5000) return AnswerPerformance.good;
    return AnswerPerformance.slow;
  }
}

/// Answer performance categories
enum AnswerPerformance {
  excellent,
  good,
  slow,
  incorrect;

  String get displayName {
    switch (this) {
      case AnswerPerformance.excellent:
        return 'Lightning Fast!';
      case AnswerPerformance.good:
        return 'Good Speed';
      case AnswerPerformance.slow:
        return 'Correct';
      case AnswerPerformance.incorrect:
        return 'Incorrect';
    }
  }

  String get emoji {
    switch (this) {
      case AnswerPerformance.excellent:
        return '⚡';
      case AnswerPerformance.good:
        return '👍';
      case AnswerPerformance.slow:
        return '✓';
      case AnswerPerformance.incorrect:
        return '✗';
    }
  }
}
