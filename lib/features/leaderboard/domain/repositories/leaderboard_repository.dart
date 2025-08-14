import 'dart:async';
import '../../../../core/utils/result.dart';
import '../entities/leaderboard.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/score_entity.dart';

abstract class LeaderboardRepository {
  Stream<Result<Leaderboard>> watchLeaderboard(String sessionId);

  Future<Result<void>> updateScore(String sessionId, ScoreEntity score);

  Future<Result<Leaderboard>> getLeaderboard(String sessionId);

  Future<Result<List<LeaderboardEntry>>> getHistoricalLeaderboard({
    required String quizId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<Result<LeaderboardEntry>> getPlayerStats({
    required String playerId,
    required String sessionId,
  });

  Future<Result<void>> recordFinalLeaderboard(Leaderboard leaderboard);

  Future<Result<List<Leaderboard>>> getPlayerHistory(String playerId);

  Future<Result<void>> clearLeaderboard(String sessionId);
}
