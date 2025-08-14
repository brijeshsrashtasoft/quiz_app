import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_datasource.dart';
import '../models/leaderboard_model.dart';
import '../models/score_model.dart';
import '../models/leaderboard_entry_model.dart';

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
          // Convert ScoreModel to LeaderboardEntryModel for proper structure
          final entry = LeaderboardEntryModel(
            playerId: score.playerId,
            playerName: score.playerName,
            rank: 1,
            previousRank: 1,
            totalScore: score.totalScore,
            correctAnswers: score.isCorrect ? 1 : 0,
            totalQuestions: 1,
            averageResponseTime: score.responseTimeMs.toDouble(),
            currentStreak: score.isCorrect ? 1 : 0,
            maxStreak: score.isCorrect ? 1 : 0,
            lastUpdated: DateTime.now(),
          );
          leaderboard = LeaderboardModel(
            sessionId: sessionId,
            quizId: '', // Will be set when quiz info is available
            entries: [entry],
            lastUpdated: DateTime.now(),
            type: 'session',
            totalPlayers: 1,
          );
        } else {
          // Update existing leaderboard
          final data = doc.data()!;
          leaderboard = LeaderboardModel.fromFirestore(data);

          // Find and update existing entry or add new one
          final updatedEntries = List<LeaderboardEntryModel>.from(
            leaderboard.entries,
          );
          final existingIndex = updatedEntries.indexWhere(
            (e) => e.playerId == score.playerId,
          );

          if (existingIndex != -1) {
            // Update existing entry with new score data
            final existingEntry = updatedEntries[existingIndex];
            updatedEntries[existingIndex] = existingEntry.copyWith(
              totalScore: existingEntry.totalScore + score.totalScore,
              correctAnswers:
                  existingEntry.correctAnswers + (score.isCorrect ? 1 : 0),
              totalQuestions: existingEntry.totalQuestions + 1,
              averageResponseTime:
                  (existingEntry.averageResponseTime + score.responseTimeMs) /
                  2,
              currentStreak: score.isCorrect
                  ? existingEntry.currentStreak + 1
                  : 0,
              maxStreak: score.isCorrect
                  ? (existingEntry.currentStreak + 1 > existingEntry.maxStreak
                        ? existingEntry.currentStreak + 1
                        : existingEntry.maxStreak)
                  : existingEntry.maxStreak,
              lastUpdated: DateTime.now(),
            );
          } else {
            // Create new entry from score
            final newEntry = LeaderboardEntryModel(
              playerId: score.playerId,
              playerName: score.playerName,
              rank: updatedEntries.length + 1,
              previousRank: updatedEntries.length + 1,
              totalScore: score.totalScore,
              correctAnswers: score.isCorrect ? 1 : 0,
              totalQuestions: 1,
              averageResponseTime: score.responseTimeMs.toDouble(),
              currentStreak: score.isCorrect ? 1 : 0,
              maxStreak: score.isCorrect ? 1 : 0,
              lastUpdated: DateTime.now(),
            );
            updatedEntries.add(newEntry);
          }

          leaderboard = leaderboard.copyWith(
            entries: updatedEntries,
            lastUpdated: DateTime.now(),
            totalPlayers: updatedEntries.length,
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

  /// Get top entries for a session
  Future<Result<List<LeaderboardEntryModel>>> getTopEntries(
    String sessionId, {
    int limit = 10,
  }) async {
    try {
      final startTime = DateTime.now();

      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      final failure = leaderboardResult.failureOrNull;
      if (failure != null) {
        return Result.failure(failure);
      }

      final leaderboard = leaderboardResult.dataOrNull!;
      final sortedEntries = List<LeaderboardEntryModel>.from(
        leaderboard.entries,
      );

      // Sort by total score (descending), then by accuracy, then by average response time
      sortedEntries.sort((a, b) {
        // Primary sort: by total score (descending)
        final scoreComparison = b.totalScore.compareTo(a.totalScore);
        if (scoreComparison != 0) return scoreComparison;

        // Secondary sort: by accuracy (descending)
        final accuracyA = a.totalQuestions > 0
            ? a.correctAnswers / a.totalQuestions
            : 0.0;
        final accuracyB = b.totalQuestions > 0
            ? b.correctAnswers / b.totalQuestions
            : 0.0;
        final accuracyComparison = accuracyB.compareTo(accuracyA);
        if (accuracyComparison != 0) return accuracyComparison;

        // Tertiary sort: by average response time (ascending - faster is better)
        return a.averageResponseTime.compareTo(b.averageResponseTime);
      });

      final topEntries = sortedEntries.take(limit).toList();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get top entries', duration);

      return Result.success(topEntries);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get top entries: $sessionId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get top entries: ${e.toString()}',
          code: 'get_top_entries_error',
        ).toFailure(),
      );
    }
  }

  /// Get player rank in leaderboard
  Future<Result<int?>> getPlayerRank(String sessionId, String playerId) async {
    try {
      final startTime = DateTime.now();

      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      final failure = leaderboardResult.failureOrNull;
      if (failure != null) {
        return Result.failure(failure);
      }

      final leaderboard = leaderboardResult.dataOrNull!;
      final sortedEntries = List<LeaderboardEntryModel>.from(
        leaderboard.entries,
      );

      // Sort by total score (descending), then by accuracy, then by average response time
      sortedEntries.sort((a, b) {
        final scoreComparison = b.totalScore.compareTo(a.totalScore);
        if (scoreComparison != 0) return scoreComparison;

        final accuracyA = a.totalQuestions > 0
            ? a.correctAnswers / a.totalQuestions
            : 0.0;
        final accuracyB = b.totalQuestions > 0
            ? b.correctAnswers / b.totalQuestions
            : 0.0;
        final accuracyComparison = accuracyB.compareTo(accuracyA);
        if (accuracyComparison != 0) return accuracyComparison;

        return a.averageResponseTime.compareTo(b.averageResponseTime);
      });

      final index = sortedEntries.indexWhere(
        (entry) => entry.playerId == playerId,
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
                  quizId: '',
                  entries: [],
                  lastUpdated: DateTime.now(),
                  type: 'session',
                  totalPlayers: 0,
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
          type: 'finalResult',
          lastUpdated: DateTime.now(),
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

  /// Get leaderboard statistics
  Future<Result<Map<String, dynamic>>> getLeaderboardStats(
    String sessionId,
  ) async {
    try {
      final startTime = DateTime.now();

      final leaderboardResult = await getLeaderboardBySessionId(sessionId);

      final failure = leaderboardResult.failureOrNull;
      if (failure != null) {
        return Result.failure(failure);
      }

      final leaderboard = leaderboardResult.dataOrNull!;
      final entries = leaderboard.entries;

      if (entries.isEmpty) {
        return Result.success(<String, dynamic>{
          'totalParticipants': 0,
          'averageScore': 0.0,
          'averageAccuracy': 0.0,
          'highestScore': 0,
          'lowestScore': 0,
          'perfectScores': 0,
        });
      }

      final totalScore = entries.fold(0, (sum, e) => sum + e.totalScore);
      final averageScore = totalScore / entries.length;

      final totalAccuracy = entries.fold(0.0, (sum, e) {
        return sum +
            (e.totalQuestions > 0 ? e.correctAnswers / e.totalQuestions : 0.0);
      });
      final averageAccuracy = (totalAccuracy / entries.length) * 100;

      final highestScore = entries
          .map((e) => e.totalScore)
          .reduce((a, b) => a > b ? a : b);
      final lowestScore = entries
          .map((e) => e.totalScore)
          .reduce((a, b) => a < b ? a : b);

      final perfectScores = entries.where((e) {
        return e.totalQuestions > 0 && e.correctAnswers == e.totalQuestions;
      }).length;

      final stats = <String, dynamic>{
        'totalParticipants': entries.length,
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
}
