import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_datasource.dart';
import '../models/leaderboard_model.dart';

/// Leaderboard Firestore data source implementation
/// Following CLAUDE.md patterns and Firestore integration with real-time support
class LeaderboardFirestoreDataSource extends BaseFirebaseDataSource {
  static const String _collection = 'leaderboards';

  /// Create new leaderboard
  Future<Result<LeaderboardModel>> createLeaderboard(
    LeaderboardModel leaderboard,
  ) async {
    try {
      final startTime = DateTime.now();

      final data = leaderboard.toFirestore();

      // Use sessionId as document ID for easy retrieval
      await FirestoreConfig.getDocument(
        _collection,
        leaderboard.sessionId,
      ).set(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Create leaderboard', duration);

      AppLogger.firebase(
        'LeaderboardDataSource',
        'Created leaderboard for session: ${leaderboard.sessionId}',
      );
      return Result.success(leaderboard);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create leaderboard', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to create leaderboard: ${e.toString()}',
          code: 'create_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  /// Get leaderboard by session ID
  Future<Result<LeaderboardModel>> getLeaderboardBySessionId(
    String sessionId,
  ) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(
        _collection,
        sessionId,
      ).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get leaderboard by session ID', duration);

      if (!doc.exists) {
        return Result.failure(
          const FirestoreException(
            message: 'Leaderboard not found',
            code: 'leaderboard_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      final leaderboard = LeaderboardModel.fromFirestore(data);
      return Result.success(leaderboard);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get leaderboard by session ID: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to get leaderboard: ${e.toString()}',
          code: 'get_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  /// Update leaderboard
  Future<Result<LeaderboardModel>> updateLeaderboard(
    LeaderboardModel leaderboard,
  ) async {
    try {
      final startTime = DateTime.now();

      final data = leaderboard.toFirestore();

      await FirestoreConfig.getDocument(
        _collection,
        leaderboard.sessionId,
      ).set(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update leaderboard', duration);

      AppLogger.firebase(
        'LeaderboardDataSource',
        'Updated leaderboard for session: ${leaderboard.sessionId}',
      );
      return Result.success(leaderboard);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update leaderboard: ${leaderboard.sessionId}',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to update leaderboard: ${e.toString()}',
          code: 'update_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  /// Add or update player score in leaderboard
  Future<Result<LeaderboardModel>> updatePlayerScore(
    String sessionId,
    ScoreModel score,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<LeaderboardModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        LeaderboardModel leaderboard;

        if (!doc.exists) {
          // Create new leaderboard if it doesn't exist
          leaderboard = LeaderboardModel(
            sessionId: sessionId,
            scores: [score],
            updatedAt: DateTime.now(),
          );
        } else {
          // Update existing leaderboard
          final data = doc.data()!;
          leaderboard = LeaderboardModel.fromFirestore(data);

          // Find and update existing score or add new one
          final updatedScores = List<ScoreModel>.from(leaderboard.scores);
          final existingIndex = updatedScores.indexWhere(
            (s) => s.playerId == score.playerId,
          );

          if (existingIndex != -1) {
            updatedScores[existingIndex] = score;
          } else {
            updatedScores.add(score);
          }

          leaderboard = leaderboard.copyWith(
            scores: updatedScores,
            updatedAt: DateTime.now(),
          );
        }

        final updateData = leaderboard.toFirestore();
        transaction.set(docRef, updateData);

        return leaderboard;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update player score in leaderboard', duration);

      AppLogger.firebase(
        'LeaderboardDataSource',
        'Updated score for player ${score.playerId} in session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update player score: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to update player score: ${e.toString()}',
          code: 'update_player_score_error',
        ).toFailure(),
      );
    }
  }

  /// Get top scores for a session
  Future<Result<List<ScoreModel>>> getTopScores(
    String sessionId, {
    int limit = 10,
  }) async {
    try {
      final startTime = DateTime.now();

      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      if (leaderboardResult.isFailure) {
        return Result.failure(leaderboardResult.failureOrThrow);
      }

      final leaderboard = leaderboardResult.data;
      final sortedScores = List<ScoreModel>.from(leaderboard.scores ?? []);

      // Sort by score (descending), then by accuracy, then by time taken
      sortedScores.sort((a, b) {
        // Primary sort: by score (descending)
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;

        // Secondary sort: by accuracy (descending)
        final accuracyA = a.totalAnswers > 0
            ? a.correctAnswers / a.totalAnswers
            : 0.0;
        final accuracyB = b.totalAnswers > 0
            ? b.correctAnswers / b.totalAnswers
            : 0.0;
        final accuracyComparison = accuracyB.compareTo(accuracyA);
        if (accuracyComparison != 0) return accuracyComparison;

        // Tertiary sort: by time taken (ascending - faster is better)
        if (a.timeTaken != null && b.timeTaken != null) {
          return a.timeTaken!.compareTo(b.timeTaken!);
        }

        return 0;
      });

      final topScores = sortedScores.take(limit).toList();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get top scores', duration);

      return Result.success(topScores);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get top scores: $sessionId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get top scores: ${e.toString()}',
          code: 'get_top_scores_error',
        ).toFailure(),
      );
    }
  }

  /// Get player rank in leaderboard
  Future<Result<int?>> getPlayerRank(String sessionId, String playerId) async {
    try {
      final startTime = DateTime.now();

      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      if (leaderboardResult.isFailure) {
        return Result.failure(leaderboardResult.failureOrThrow);
      }

      final leaderboard = leaderboardResult.data;
      final sortedScores = List<ScoreModel>.from(leaderboard.scores ?? []);

      // Sort by score (descending), then by accuracy, then by time taken
      sortedScores.sort((a, b) {
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;

        final accuracyA = a.totalAnswers > 0
            ? a.correctAnswers / a.totalAnswers
            : 0.0;
        final accuracyB = b.totalAnswers > 0
            ? b.correctAnswers / b.totalAnswers
            : 0.0;
        final accuracyComparison = accuracyB.compareTo(accuracyA);
        if (accuracyComparison != 0) return accuracyComparison;

        if (a.timeTaken != null && b.timeTaken != null) {
          return a.timeTaken!.compareTo(b.timeTaken!);
        }

        return 0;
      });

      final index = sortedScores.indexWhere(
        (score) => score.playerId == playerId,
      );
      final rank = index == -1 ? null : index + 1;

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get player rank', duration);

      return Result.success(rank);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get player rank: $sessionId, $playerId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to get player rank: ${e.toString()}',
          code: 'get_player_rank_error',
        ).toFailure(),
      );
    }
  }

  /// Stream leaderboard for real-time updates (CRITICAL for live leaderboard)
  Stream<Result<LeaderboardModel>> watchLeaderboard(String sessionId) {
    try {
      return FirestoreConfig.getDocument(_collection, sessionId)
          .snapshots()
          .map<Result<LeaderboardModel>>((doc) {
            if (!doc.exists) {
              // Return empty leaderboard if not found
              return Result.success(
                LeaderboardModel(
                  sessionId: sessionId,
                  scores: [],
                  updatedAt: DateTime.now(),
                ),
              );
            }

            final data = doc.data()!;
            final leaderboard = LeaderboardModel.fromFirestore(data);
            return Result.success(leaderboard);
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'Error watching leaderboard: $sessionId',
              error,
              stackTrace,
            );
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to setup leaderboard watch: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup leaderboard watch: ${e.toString()}',
            code: 'watch_setup_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Finalize leaderboard (mark as final results)
  Future<Result<LeaderboardModel>> finalizeLeaderboard(String sessionId) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<LeaderboardModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Leaderboard not found',
            code: 'leaderboard_not_found',
          );
        }

        final data = doc.data()!;
        final leaderboard = LeaderboardModel.fromFirestore(data);

        final finalizedLeaderboard = leaderboard.copyWith(
          finalResults: true,
          updatedAt: DateTime.now(),
        );

        final updateData = finalizedLeaderboard.toFirestore();
        transaction.set(docRef, updateData);

        return finalizedLeaderboard;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Finalize leaderboard', duration);

      AppLogger.firebase(
        'LeaderboardDataSource',
        'Finalized leaderboard for session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to finalize leaderboard: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to finalize leaderboard: ${e.toString()}',
          code: 'finalize_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  /// Delete leaderboard
  Future<Result<void>> deleteLeaderboard(String sessionId) async {
    try {
      final startTime = DateTime.now();

      await FirestoreConfig.getDocument(_collection, sessionId).delete();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete leaderboard', duration);

      AppLogger.firebase(
        'LeaderboardDataSource',
        'Deleted leaderboard for session: $sessionId',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete leaderboard: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to delete leaderboard: ${e.toString()}',
          code: 'delete_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  /// Batch update multiple player scores
  Future<Result<LeaderboardModel>> batchUpdateScores(
    String sessionId,
    List<ScoreModel> scores,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<LeaderboardModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        LeaderboardModel leaderboard;

        if (!doc.exists) {
          // Create new leaderboard if it doesn't exist
          leaderboard = LeaderboardModel(
            sessionId: sessionId,
            scores: scores,
            updatedAt: DateTime.now(),
          );
        } else {
          // Update existing leaderboard
          final data = doc.data()!;
          leaderboard = LeaderboardModel.fromFirestore(data);

          final updatedScores = List<ScoreModel>.from(leaderboard.scores);

          // Update or add each score
          for (final score in scores) {
            final existingIndex = updatedScores.indexWhere(
              (s) => s.playerId == score.playerId,
            );

            if (existingIndex != -1) {
              updatedScores[existingIndex] = score;
            } else {
              updatedScores.add(score);
            }
          }

          leaderboard = leaderboard.copyWith(
            scores: updatedScores,
            updatedAt: DateTime.now(),
          );
        }

        final updateData = leaderboard.toFirestore();
        transaction.set(docRef, updateData);

        return leaderboard;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Batch update scores', duration);

      AppLogger.firebase(
        'LeaderboardDataSource',
        'Batch updated ${scores.length} scores for session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to batch update scores: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch update scores: ${e.toString()}',
          code: 'batch_update_scores_error',
        ).toFailure(),
      );
    }
  }

  /// Get leaderboard statistics
  Future<Result<Map<String, dynamic>>> getLeaderboardStats(
    String sessionId,
  ) async {
    try {
      final startTime = DateTime.now();

      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      if (leaderboardResult.isFailure) {
        return Result.failure(leaderboardResult.failureOrThrow);
      }

      final leaderboard = leaderboardResult.data;
      final scores = leaderboard.scores;

      if (scores.isEmpty) {
        return Result.success(<String, dynamic>{
          'totalParticipants': 0,
          'averageScore': 0.0,
          'averageAccuracy': 0.0,
          'highestScore': 0,
          'lowestScore': 0,
          'perfectScores': 0,
        });
      }

      final totalScore = scores.fold(0, (sum, s) => sum + s.score);
      final averageScore = totalScore / scores.length;

      final totalAccuracy = scores.fold(0.0, (sum, s) {
        return sum +
            (s.totalAnswers > 0 ? s.correctAnswers / s.totalAnswers : 0.0);
      });
      final averageAccuracy = (totalAccuracy / scores.length) * 100;

      final highestScore = scores
          .map((s) => s.score)
          .reduce((a, b) => a > b ? a : b);
      final lowestScore = scores
          .map((s) => s.score)
          .reduce((a, b) => a < b ? a : b);

      final perfectScores = scores.where((s) {
        return s.totalAnswers > 0 && s.correctAnswers == s.totalAnswers;
      }).length;

      final stats = <String, dynamic>{
        'totalParticipants': scores.length,
        'averageScore': averageScore,
        'averageAccuracy': averageAccuracy,
        'highestScore': highestScore,
        'lowestScore': lowestScore,
        'perfectScores': perfectScores,
      };

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get leaderboard stats', duration);

      return Result.success(stats);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get leaderboard stats: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to get leaderboard stats: ${e.toString()}',
          code: 'get_leaderboard_stats_error',
        ).toFailure(),
      );
    }
  }

  /// Check if leaderboard exists
  Future<Result<bool>> leaderboardExists(String sessionId) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(
        _collection,
        sessionId,
      ).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Check leaderboard exists', duration);

      return Result.success(doc.exists);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check leaderboard existence: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to check leaderboard existence: ${e.toString()}',
          code: 'check_leaderboard_error',
        ).toFailure(),
      );
    }
  }

  /// Add score to leaderboard
  Future<Result<LeaderboardModel>> addScore(
    String sessionId,
    ScoreModel score,
  ) async {
    try {
      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      return leaderboardResult.when(
        success: (leaderboard) async {
          final updatedScores = List<ScoreModel>.from(leaderboard.scores);
          updatedScores.add(score);

          final updatedLeaderboard = leaderboard.copyWith(
            scores: updatedScores,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateLeaderboard(updatedLeaderboard);
          return updateResult;
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(e.toFailure());
    }
  }

  /// Update existing score
  Future<Result<LeaderboardModel>> updateScore(
    String sessionId,
    ScoreModel score,
  ) async {
    try {
      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      return leaderboardResult.when(
        success: (leaderboard) async {
          final updatedScores = List<ScoreModel>.from(leaderboard.scores);
          final existingIndex = updatedScores.indexWhere(
            (s) => s.playerId == score.playerId,
          );

          if (existingIndex >= 0) {
            updatedScores[existingIndex] = score;
          } else {
            updatedScores.add(score);
          }

          final updatedLeaderboard = leaderboard.copyWith(
            scores: updatedScores,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateLeaderboard(updatedLeaderboard);
          return updateResult;
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(e.toFailure());
    }
  }

  /// Remove score from leaderboard
  Future<Result<LeaderboardModel>> removeScore(
    String sessionId,
    String playerId,
  ) async {
    try {
      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      return leaderboardResult.when(
        success: (leaderboard) async {
          final updatedScores = List<ScoreModel>.from(leaderboard.scores);
          updatedScores.removeWhere((s) => s.playerId == playerId);

          final updatedLeaderboard = leaderboard.copyWith(
            scores: updatedScores,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateLeaderboard(updatedLeaderboard);
          return updateResult;
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(e.toFailure());
    }
  }
}
