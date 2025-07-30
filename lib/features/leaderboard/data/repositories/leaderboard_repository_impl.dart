import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_repository.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_firestore_datasource.dart';
import '../models/leaderboard_model.dart';

/// Leaderboard repository implementation for Clean Architecture
/// Following CLAUDE.md patterns and error handling
class LeaderboardRepositoryImpl extends BaseRepository
    implements LeaderboardRepository {
  final LeaderboardFirestoreDataSource dataSource;

  LeaderboardRepositoryImpl({required this.dataSource});

  @override
  Future<Result<LeaderboardEntity>> getLeaderboardBySessionId(
    String sessionId,
  ) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.getLeaderboardBySessionId(sessionId);

      return result.when(
        success: (leaderboardModel) =>
            Result.success(leaderboardModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get leaderboard by session ID: ${e.toString()}',
          code: 'get_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntity>> createLeaderboard(
    LeaderboardEntity leaderboard,
  ) async {
    try {
      final validationError = _validateLeaderboard(leaderboard);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final leaderboardModel = leaderboard.toModel();
      final result = await dataSource.createLeaderboard(leaderboardModel);

      return result.when(
        success: (createdModel) => Result.success(createdModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to create leaderboard: ${e.toString()}',
          code: 'create_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntity>> updateLeaderboard(
    LeaderboardEntity leaderboard,
  ) async {
    try {
      final validationError = _validateLeaderboard(leaderboard);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final leaderboardModel = leaderboard.toModel();
      final result = await dataSource.updateLeaderboard(leaderboardModel);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update leaderboard: ${e.toString()}',
          code: 'update_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> deleteLeaderboard(String sessionId) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.deleteLeaderboard(sessionId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to delete leaderboard: ${e.toString()}',
          code: 'delete_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntity>> addScore(
    String sessionId,
    ScoreEntity score,
  ) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      final scoreValidationError = _validateScore(score);
      if (scoreValidationError != null) {
        return Result.failure(scoreValidationError.toFailure());
      }

      final scoreModel = score.toModel();
      final result = await dataSource.addScore(sessionId, scoreModel);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to add score to leaderboard: ${e.toString()}',
          code: 'add_score_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntity>> updateScore(
    String sessionId,
    ScoreEntity score,
  ) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      final scoreValidationError = _validateScore(score);
      if (scoreValidationError != null) {
        return Result.failure(scoreValidationError.toFailure());
      }

      final scoreModel = score.toModel();
      final result = await dataSource.updateScore(sessionId, scoreModel);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update score in leaderboard: ${e.toString()}',
          code: 'update_score_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntity>> removeScore(
    String sessionId,
    String playerId,
  ) async {
    try {
      if (sessionId.isEmpty || playerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID and Player ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.removeScore(sessionId, playerId);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to remove score from leaderboard: ${e.toString()}',
          code: 'remove_score_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntity>> finalizeLeaderboard(
    String sessionId,
  ) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.finalizeLeaderboard(sessionId);

      return result.when(
        success: (finalizedModel) => Result.success(finalizedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to finalize leaderboard: ${e.toString()}',
          code: 'finalize_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<LeaderboardEntity>>> getRecentLeaderboards({
    int? limit,
    DateTime? lastUpdatedAt,
  }) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getRecentLeaderboards(
        limit: limit,
        lastUpdatedAt: lastUpdatedAt,
      );

      return result.when(
        success: (leaderboardModels) => Result.success(
          leaderboardModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get recent leaderboards: ${e.toString()}',
          code: 'get_recent_leaderboards_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<LeaderboardEntity>>> getLeaderboardsByStatus(
    bool finalResults, {
    int? limit,
  }) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getLeaderboardsByStatus(
        finalResults,
        limit: limit,
      );

      return result.when(
        success: (leaderboardModels) => Result.success(
          leaderboardModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get leaderboards by status: ${e.toString()}',
          code: 'get_leaderboards_by_status_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<ScoreEntity>>> getTopPerformers(int limit) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getTopPerformers(limit);

      return result.when(
        success: (scoreModels) => Result.success(
          scoreModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get top performers: ${e.toString()}',
          code: 'get_top_performers_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<ScoreEntity>>> getPlayerBestScores(
    String playerId,
    int limit,
  ) async {
    try {
      if (playerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Player ID cannot be empty',
          ).toFailure(),
        );
      }

      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getPlayerBestScores(playerId, limit);

      return result.when(
        success: (scoreModels) => Result.success(
          scoreModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get player best scores: ${e.toString()}',
          code: 'get_player_scores_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<PlayerPerformance>> getPlayerPerformance(
    String playerId,
  ) async {
    try {
      if (playerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Player ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.getPlayerPerformance(playerId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get player performance: ${e.toString()}',
          code: 'get_player_performance_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<LeaderboardStats>> getLeaderboardStats(String sessionId) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.getLeaderboardStats(sessionId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get leaderboard stats: ${e.toString()}',
          code: 'get_leaderboard_stats_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GlobalLeaderboardStats>> getGlobalStats() async {
    try {
      return await dataSource.getGlobalStats();
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get global stats: ${e.toString()}',
          code: 'get_global_stats_error',
        ).toFailure(),
      );
    }
  }

  @override
  Stream<Result<LeaderboardEntity>> watchLeaderboard(String sessionId) {
    try {
      if (sessionId.isEmpty) {
        return Stream.value(
          Result.failure(
            const ValidationException(
              message: 'Session ID cannot be empty',
            ).toFailure(),
          ),
        );
      }

      return dataSource.watchLeaderboard(sessionId).map((result) {
        return result.when(
          success: (leaderboardModel) =>
              Result.success(leaderboardModel.toEntity()),
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch leaderboard: ${e.toString()}',
            code: 'watch_leaderboard_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Stream<Result<List<ScoreEntity>>> watchTopPerformers(int limit) {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Stream.value(Result.failure(validationError.toFailure()));
      }

      return dataSource.watchTopPerformers(limit).map((result) {
        return result.when(
          success: (scoreModels) => Result.success(
            scoreModels.map((model) => model.toEntity()).toList(),
          ),
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch top performers: ${e.toString()}',
            code: 'watch_top_performers_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Future<Result<List<ScoreEntity>>> searchPlayerScores(
    String playerName,
  ) async {
    try {
      if (playerName.length < 2) {
        return Result.failure(
          const ValidationException(
            message: 'Player name must be at least 2 characters',
          ).toFailure(),
        );
      }

      // Sanitize search query to prevent injection attacks
      final sanitizedQuery = _sanitizeSearchQuery(playerName);

      final result = await dataSource.searchPlayerScores(sanitizedQuery);

      return result.when(
        success: (scoreModels) => Result.success(
          scoreModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to search player scores: ${e.toString()}',
          code: 'search_player_scores_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> batchUpdateLeaderboards(
    List<LeaderboardEntity> leaderboards,
  ) async {
    try {
      if (leaderboards.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Leaderboard list cannot be empty',
          ).toFailure(),
        );
      }

      if (leaderboards.length > 500) {
        return Result.failure(
          const ValidationException(
            message: 'Batch size cannot exceed 500 leaderboards',
          ).toFailure(),
        );
      }

      // Validate all leaderboards before batch operation
      for (final leaderboard in leaderboards) {
        final validationError = _validateLeaderboard(leaderboard);
        if (validationError != null) {
          return Result.failure(validationError.toFailure());
        }
      }

      final leaderboardModels = leaderboards.map((lb) => lb.toModel()).toList();

      return await dataSource.batchUpdateLeaderboards(leaderboardModels);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to batch update leaderboards: ${e.toString()}',
          code: 'batch_update_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> batchDeleteLeaderboards(List<String> sessionIds) async {
    try {
      if (sessionIds.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID list cannot be empty',
          ).toFailure(),
        );
      }

      if (sessionIds.length > 500) {
        return Result.failure(
          const ValidationException(
            message: 'Batch size cannot exceed 500 session IDs',
          ).toFailure(),
        );
      }

      return await dataSource.batchDeleteLeaderboards(sessionIds);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to batch delete leaderboards: ${e.toString()}',
          code: 'batch_delete_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<ScoreEntity>>> getScoreDistribution() async {
    try {
      final result = await dataSource.getScoreDistribution();

      return result.when(
        success: (scoreModels) => Result.success(
          scoreModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get score distribution: ${e.toString()}',
          code: 'get_score_distribution_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getAccuracyDistribution() async {
    try {
      return await dataSource.getAccuracyDistribution();
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get accuracy distribution: ${e.toString()}',
          code: 'get_accuracy_distribution_error',
        ).toFailure(),
      );
    }
  }

  // ===========================
  // PRIVATE VALIDATION METHODS
  // ===========================

  /// Validate leaderboard entity
  ValidationException? _validateLeaderboard(LeaderboardEntity leaderboard) {
    if (leaderboard.sessionId.isEmpty) {
      return const ValidationException(message: 'Session ID cannot be empty');
    }

    if (leaderboard.scores.isEmpty) {
      return const ValidationException(
        message: 'Leaderboard must have at least one score',
      );
    }

    if (leaderboard.scores.length > 1000) {
      return const ValidationException(
        message: 'Leaderboard cannot have more than 1000 scores',
      );
    }

    // Validate each score
    for (int i = 0; i < leaderboard.scores.length; i++) {
      final score = leaderboard.scores[i];
      final scoreError = _validateScore(score);
      if (scoreError != null) {
        return ValidationException(
          message: 'Score ${i + 1}: ${scoreError.message}',
        );
      }
    }

    return null;
  }

  /// Validate score entity
  ValidationException? _validateScore(ScoreEntity score) {
    if (score.playerId.isEmpty) {
      return const ValidationException(message: 'Player ID cannot be empty');
    }

    if (score.playerName.isEmpty) {
      return const ValidationException(message: 'Player name cannot be empty');
    }

    if (score.playerName.length > 50) {
      return const ValidationException(
        message: 'Player name cannot exceed 50 characters',
      );
    }

    if (score.score < 0) {
      return const ValidationException(message: 'Score cannot be negative');
    }

    if (score.correctAnswers < 0) {
      return const ValidationException(
        message: 'Correct answers cannot be negative',
      );
    }

    if (score.totalAnswers < 0) {
      return const ValidationException(
        message: 'Total answers cannot be negative',
      );
    }

    if (score.correctAnswers > score.totalAnswers) {
      return const ValidationException(
        message: 'Correct answers cannot exceed total answers',
      );
    }

    if (score.rank != null && score.rank! < 1) {
      return const ValidationException(message: 'Rank must be greater than 0');
    }

    if (score.timeTaken != null && score.timeTaken! < 0) {
      return const ValidationException(
        message: 'Time taken cannot be negative',
      );
    }

    return null;
  }

  /// Validate pagination parameters
  ValidationException? _validatePaginationParams(int? limit) {
    if (limit != null) {
      if (limit <= 0) {
        return const ValidationException(
          message: 'Limit must be greater than 0',
        );
      }

      if (limit > 1000) {
        return const ValidationException(message: 'Limit cannot exceed 1000');
      }
    }

    return null;
  }

  /// Sanitize search query to prevent injection attacks
  String _sanitizeSearchQuery(String query) {
    return query
        .replaceAll(
          RegExp(r'[<>"\\/]'),
          '',
        ) // Remove potentially dangerous characters
        .trim()
        .toLowerCase();
  }
}
