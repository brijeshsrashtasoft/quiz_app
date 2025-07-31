import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/score_entity.dart';

abstract class LeaderboardRepository {
  Stream<Either<Failure, Leaderboard>> watchLeaderboard(String sessionId);

  Future<Either<Failure, void>> updateScore(
    String sessionId,
    ScoreEntity score,
  );

  Future<Either<Failure, Leaderboard>> getLeaderboard(String sessionId);

  Future<Either<Failure, List<LeaderboardEntry>>> getHistoricalLeaderboard({
    required String quizId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<Either<Failure, LeaderboardEntry>> getPlayerStats({
    required String playerId,
    required String sessionId,
  });

  Future<Either<Failure, void>> recordFinalLeaderboard(Leaderboard leaderboard);

  Future<Either<Failure, List<Leaderboard>>> getPlayerHistory(String playerId);

  Future<Either<Failure, void>> clearLeaderboard(String sessionId);
}
