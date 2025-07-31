import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entry.freezed.dart';

@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String playerId,
    required String playerName,
    required int rank,
    required int previousRank,
    required int totalScore,
    required int correctAnswers,
    required int totalQuestions,
    required double averageResponseTime,
    required int currentStreak,
    required int maxStreak,
    required DateTime lastUpdated,
    String? avatarUrl,
  }) = _LeaderboardEntry;

  const LeaderboardEntry._();

  RankChange get rankChange {
    if (previousRank == 0) return RankChange.new_;
    if (rank < previousRank) return RankChange.up;
    if (rank > previousRank) return RankChange.down;
    return RankChange.same;
  }

  double get accuracy => totalQuestions > 0 
      ? (correctAnswers / totalQuestions) * 100 
      : 0.0;
}

enum RankChange { up, down, same, new_ }