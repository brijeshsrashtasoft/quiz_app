import '../../../../core/utils/result.dart';
import '../entities/leaderboard_entity.dart';

/// Leaderboard repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore integration
abstract class LeaderboardRepository {
  /// Get leaderboard by session ID
  Future<Result<LeaderboardEntity>> getLeaderboardBySessionId(String sessionId);

  /// Create new leaderboard
  Future<Result<LeaderboardEntity>> createLeaderboard(
    LeaderboardEntity leaderboard,
  );

  /// Update leaderboard
  Future<Result<LeaderboardEntity>> updateLeaderboard(
    LeaderboardEntity leaderboard,
  );

  /// Delete leaderboard
  Future<Result<void>> deleteLeaderboard(String sessionId);

  /// Add score to leaderboard
  Future<Result<LeaderboardEntity>> addScore(
    String sessionId,
    ScoreEntity score,
  );

  /// Update score in leaderboard
  Future<Result<LeaderboardEntity>> updateScore(
    String sessionId,
    ScoreEntity score,
  );

  /// Remove score from leaderboard
  Future<Result<LeaderboardEntity>> removeScore(
    String sessionId,
    String playerId,
  );

  /// Finalize leaderboard (mark as final results)
  Future<Result<LeaderboardEntity>> finalizeLeaderboard(String sessionId);

  /// Get recent leaderboards
  Future<Result<List<LeaderboardEntity>>> getRecentLeaderboards({
    int? limit,
    DateTime? lastUpdatedAt,
  });

  /// Get leaderboards by final status
  Future<Result<List<LeaderboardEntity>>> getLeaderboardsByStatus(
    bool finalResults, {
    int? limit,
  });

  /// Get top performers across all leaderboards
  Future<Result<List<ScoreEntity>>> getTopPerformers(int limit);

  /// Get player's best scores
  Future<Result<List<ScoreEntity>>> getPlayerBestScores(
    String playerId,
    int limit,
  );

  /// Get player's average performance
  Future<Result<PlayerPerformance>> getPlayerPerformance(String playerId);

  /// Get leaderboard statistics
  Future<Result<LeaderboardStats>> getLeaderboardStats(String sessionId);

  /// Get global statistics
  Future<Result<GlobalLeaderboardStats>> getGlobalStats();

  /// Stream leaderboard for real-time updates
  Stream<Result<LeaderboardEntity>> watchLeaderboard(String sessionId);

  /// Stream top performers for real-time global leaderboard
  Stream<Result<List<ScoreEntity>>> watchTopPerformers(int limit);

  /// Search players by name in leaderboards
  Future<Result<List<ScoreEntity>>> searchPlayerScores(String playerName);

  /// Batch operations
  Future<Result<void>> batchUpdateLeaderboards(
    List<LeaderboardEntity> leaderboards,
  );
  Future<Result<void>> batchDeleteLeaderboards(List<String> sessionIds);

  /// Analytics methods
  Future<Result<List<ScoreEntity>>> getScoreDistribution();
  Future<Result<Map<String, int>>> getAccuracyDistribution();
}

/// Player performance analytics
class PlayerPerformance {
  final String playerId;
  final int totalGames;
  final double averageScore;
  final double averageAccuracy;
  final int bestScore;
  final int totalWins;
  final double winRate;
  final List<ScoreEntity> recentScores;

  const PlayerPerformance({
    required this.playerId,
    required this.totalGames,
    required this.averageScore,
    required this.averageAccuracy,
    required this.bestScore,
    required this.totalWins,
    required this.winRate,
    required this.recentScores,
  });
}

/// Global leaderboard statistics
class GlobalLeaderboardStats {
  final int totalGames;
  final int totalPlayers;
  final double globalAverageScore;
  final double globalAverageAccuracy;
  final int highestScore;
  final ScoreEntity? topPerformer;
  final DateTime lastUpdated;

  const GlobalLeaderboardStats({
    required this.totalGames,
    required this.totalPlayers,
    required this.globalAverageScore,
    required this.globalAverageAccuracy,
    required this.highestScore,
    this.topPerformer,
    required this.lastUpdated,
  });
}
