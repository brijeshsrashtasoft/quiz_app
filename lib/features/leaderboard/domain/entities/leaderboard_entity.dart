import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entity.freezed.dart';

/// Leaderboard entity for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore structure
@freezed
class LeaderboardEntity with _$LeaderboardEntity {
  const factory LeaderboardEntity({
    required String sessionId,
    required List<ScoreEntity> scores,
    required DateTime updatedAt,
    @Default(false) bool finalResults,
  }) = _LeaderboardEntity;

  /// Create from Firestore map
  factory LeaderboardEntity.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntity(
      sessionId: map['sessionId'] ?? '',
      scores: (map['scores'] as List<dynamic>? ?? [])
          .map((score) => ScoreEntity.fromMap(score as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      finalResults: map['finalResults'] ?? false,
    );
  }
}

/// Individual score entry entity
@freezed
class ScoreEntity with _$ScoreEntity {
  const factory ScoreEntity({
    required String playerId,
    required String playerName,
    required int score,
    required int correctAnswers,
    required int totalAnswers,
    int? rank,
    int? timeTaken,
  }) = _ScoreEntity;

  /// Create from Firestore map
  factory ScoreEntity.fromMap(Map<String, dynamic> map) {
    return ScoreEntity(
      playerId: map['playerId'] ?? '',
      playerName: map['playerName'] ?? '',
      score: map['score'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalAnswers: map['totalAnswers'] ?? 0,
      rank: map['rank'],
      timeTaken: map['timeTaken'],
    );
  }
}

/// Leaderboard entity extensions for business logic
extension LeaderboardEntityX on LeaderboardEntity {
  /// Check if leaderboard is valid
  bool get isValid {
    return scores.isNotEmpty &&
        scores.length <= 50 &&
        scores.every((score) => score.isValid);
  }

  /// Get leaderboard sorted by score (highest first)
  List<ScoreEntity> get sortedScores {
    final sorted = List<ScoreEntity>.from(scores);
    sorted.sort((a, b) {
      // Primary sort: by score (descending)
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;

      // Secondary sort: by accuracy (descending)
      final accuracyA = a.accuracyRate;
      final accuracyB = b.accuracyRate;
      final accuracyComparison = accuracyB.compareTo(accuracyA);
      if (accuracyComparison != 0) return accuracyComparison;

      // Tertiary sort: by time taken (ascending - faster is better)
      if (a.timeTaken != null && b.timeTaken != null) {
        return a.timeTaken!.compareTo(b.timeTaken!);
      }

      return 0;
    });

    // Assign ranks
    return sorted.asMap().entries.map((entry) {
      return entry.value.copyWith(rank: entry.key + 1);
    }).toList();
  }

  /// Get top N players
  List<ScoreEntity> getTopPlayers(int count) {
    final sorted = sortedScores;
    return sorted.take(count).toList();
  }

  /// Get player's position by ID
  int? getPlayerRank(String playerId) {
    final sorted = sortedScores;
    final index = sorted.indexWhere((score) => score.playerId == playerId);
    return index == -1 ? null : index + 1;
  }

  /// Get winner (top player)
  ScoreEntity? get winner {
    if (scores.isEmpty) return null;
    return sortedScores.first;
  }

  /// Get average score
  double get averageScore {
    if (scores.isEmpty) return 0.0;
    final totalScore = scores.fold(0, (sum, score) => sum + score.score);
    return totalScore / scores.length;
  }

  /// Get highest score
  int get highestScore {
    if (scores.isEmpty) return 0;
    return scores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
  }

  /// Get lowest score
  int get lowestScore {
    if (scores.isEmpty) return 0;
    return scores.map((s) => s.score).reduce((a, b) => a < b ? a : b);
  }

  /// Get total participants
  int get participantCount => scores.length;

  /// Check if leaderboard has ties
  bool get hasTies {
    final sorted = sortedScores;
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i].score == sorted[i + 1].score) {
        return true;
      }
    }
    return false;
  }

  /// Get players with perfect scores
  List<ScoreEntity> get perfectScores {
    return scores.where((score) => score.isPerfectScore).toList();
  }

  /// Get completion rate statistics
  LeaderboardStats get stats {
    if (scores.isEmpty) {
      return const LeaderboardStats(
        totalParticipants: 0,
        averageScore: 0.0,
        averageAccuracy: 0.0,
        perfectScores: 0,
        averageTimeTaken: 0,
      );
    }

    final totalAccuracy = scores.fold(
      0.0,
      (sum, score) => sum + score.accuracyRate,
    );
    final averageAccuracy = totalAccuracy / scores.length;

    final timeTakenScores = scores.where((s) => s.timeTaken != null).toList();
    final averageTime = timeTakenScores.isEmpty
        ? 0
        : timeTakenScores.fold(0, (sum, score) => sum + score.timeTaken!) ~/
              timeTakenScores.length;

    return LeaderboardStats(
      totalParticipants: scores.length,
      averageScore: averageScore,
      averageAccuracy: averageAccuracy,
      perfectScores: perfectScores.length,
      averageTimeTaken: averageTime,
    );
  }
}

/// Score entity extensions
extension ScoreEntityX on ScoreEntity {
  /// Check if score entry is valid
  bool get isValid {
    return playerId.isNotEmpty &&
        playerName.isNotEmpty &&
        score >= 0 &&
        correctAnswers >= 0 &&
        totalAnswers >= 0 &&
        correctAnswers <= totalAnswers;
  }

  /// Get accuracy rate as percentage
  double get accuracyRate {
    if (totalAnswers == 0) return 0.0;
    return (correctAnswers / totalAnswers) * 100;
  }

  /// Check if player has perfect score
  bool get isPerfectScore {
    return correctAnswers == totalAnswers && totalAnswers > 0;
  }

  /// Get performance grade
  PerformanceGrade get performanceGrade {
    final accuracy = accuracyRate;
    if (accuracy >= 90) return PerformanceGrade.excellent;
    if (accuracy >= 80) return PerformanceGrade.good;
    if (accuracy >= 70) return PerformanceGrade.fair;
    return PerformanceGrade.needsImprovement;
  }

  /// Get score per correct answer
  double get scorePerCorrectAnswer {
    if (correctAnswers == 0) return 0.0;
    return score / correctAnswers;
  }

  /// Format time taken as string
  String get formattedTimeTaken {
    if (timeTaken == null) return 'N/A';
    final seconds = timeTaken! % 60;
    final minutes = timeTaken! ~/ 60;
    return '${minutes}m ${seconds}s';
  }
}

/// Performance grades
enum PerformanceGrade {
  excellent,
  good,
  fair,
  needsImprovement;

  String get displayName {
    switch (this) {
      case PerformanceGrade.excellent:
        return 'Excellent';
      case PerformanceGrade.good:
        return 'Good';
      case PerformanceGrade.fair:
        return 'Fair';
      case PerformanceGrade.needsImprovement:
        return 'Needs Improvement';
    }
  }

  String get emoji {
    switch (this) {
      case PerformanceGrade.excellent:
        return '🏆';
      case PerformanceGrade.good:
        return '👍';
      case PerformanceGrade.fair:
        return '👌';
      case PerformanceGrade.needsImprovement:
        return '📚';
    }
  }
}

/// Leaderboard statistics
@freezed
class LeaderboardStats with _$LeaderboardStats {
  const factory LeaderboardStats({
    required int totalParticipants,
    required double averageScore,
    required double averageAccuracy,
    required int perfectScores,
    required int averageTimeTaken,
  }) = _LeaderboardStats;
}
