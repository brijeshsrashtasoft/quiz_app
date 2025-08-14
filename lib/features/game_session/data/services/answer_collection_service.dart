import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../datasources/game_session_firestore_datasource.dart';
import '../models/game_session_model.dart';
import '../../domain/entities/game_session_entity.dart';

/// Real-time answer collection service for live quiz responses
/// Handles player answer submission and live statistics
class AnswerCollectionService {
  final GameSessionFirestoreDataSource _dataSource;
  final Map<String, StreamController<AnswerUpdate>> _answerControllers = {};
  final Map<String, Timer> _answerDeadlines = {};

  AnswerCollectionService({required GameSessionFirestoreDataSource dataSource})
    : _dataSource = dataSource;

  /// Submit player answer with real-time processing
  Future<Result<AnswerSubmissionResult>> submitAnswer({
    required String sessionId,
    required String playerId,
    required String playerName,
    required int questionIndex,
    required int selectedOption,
    required bool isCorrect,
    required int responseTimeMs,
    int? pointsEarned,
  }) async {
    try {
      final answeredAt = DateTime.now();
      final points =
          pointsEarned ?? _calculatePoints(responseTimeMs, isCorrect);

      AppLogger.firebase(
        'AnswerCollectionService',
        'Submitting answer: $sessionId, player: $playerName, '
            'q$questionIndex, option: $selectedOption, correct: $isCorrect',
      );

      // Submit answer to Firestore with transaction
      final result = await _dataSource.submitPlayerAnswer(
        sessionId: sessionId,
        playerId: playerId,
        playerName: playerName,
        selectedOption: selectedOption,
        answeredAt: answeredAt,
        responseTimeMs: responseTimeMs,
        isCorrect: isCorrect,
        pointsEarned: points,
        questionIndex: questionIndex,
      );

      return result.when(
        success: (session) {
          // Create submission result
          final submissionResult = AnswerSubmissionResult(
            sessionId: sessionId,
            playerId: playerId,
            questionIndex: questionIndex,
            selectedOption: selectedOption,
            isCorrect: isCorrect,
            pointsEarned: points,
            responseTimeMs: responseTimeMs,
            newTotalScore: session.players[playerId]?.score ?? 0,
            rank: _calculatePlayerRank(session.toEntity(), playerId),
            answeredAt: answeredAt,
          );

          // Broadcast answer update to watchers
          _broadcastAnswerUpdate(
            sessionId,
            questionIndex,
            playerId,
            submissionResult,
          );

          AppLogger.firebase(
            'AnswerCollectionService',
            'Answer submitted successfully: +$points points, '
                'total: ${submissionResult.newTotalScore}',
          );

          return Result.success(submissionResult);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit answer: $sessionId', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to submit answer: ${e.toString()}',
          code: 'submit_answer_error',
        ).toFailure(),
      );
    }
  }

  /// Watch real-time answers for a specific question
  Stream<Result<QuestionAnswerStats>> watchQuestionAnswers({
    required String sessionId,
    required int questionIndex,
  }) {
    try {
      return _dataSource.watchQuestionAnswers(sessionId, questionIndex).map<
        Result<QuestionAnswerStats>
      >((result) {
        return result.when(
          success: (data) {
            final stats = QuestionAnswerStats(
              sessionId: sessionId,
              questionIndex: questionIndex,
              totalAnswers: data['totalAnswers'] ?? 0,
              correctAnswers: data['correctAnswers'] ?? 0,
              answerCounts: Map<int, int>.from(data['answerCounts'] ?? {}),
              averageResponseTime: (data['accuracy'] ?? 0.0).toDouble(),
              participationRate: (data['participationRate'] ?? 0.0).toDouble(),
              playerAnswers: Map<String, dynamic>.from(data['answers'] ?? {}),
              lastUpdated: DateTime.now(),
            );

            return Result.success(stats);
          },
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to watch question answers: $sessionId q$questionIndex',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch question answers: ${e.toString()}',
            code: 'watch_answers_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Get live answer statistics for host dashboard
  Stream<Result<LiveAnswerStats>> watchLiveAnswerStats({
    required String sessionId,
    required int questionIndex,
  }) {
    try {
      return watchQuestionAnswers(
        sessionId: sessionId,
        questionIndex: questionIndex,
      ).asyncMap<Result<LiveAnswerStats>>((result) async {
        return await result.when(
          success: (questionStats) async {
            // Get session data for total players
            final sessionResult = await _dataSource.getGameSessionById(
              sessionId,
            );

            return sessionResult.when(
              success: (session) {
                final liveStats = LiveAnswerStats(
                  sessionId: sessionId,
                  questionIndex: questionIndex,
                  totalPlayers: session.players.length,
                  answeredCount: questionStats.totalAnswers,
                  correctCount: questionStats.correctAnswers,
                  answerDistribution: questionStats.answerCounts,
                  fastestAnswer: _getFastestAnswer(questionStats.playerAnswers),
                  slowestAnswer: _getSlowestAnswer(questionStats.playerAnswers),
                  averageTime: questionStats.averageResponseTime,
                  accuracyRate: questionStats.totalAnswers > 0
                      ? questionStats.correctAnswers /
                            questionStats.totalAnswers
                      : 0.0,
                  completionRate: session.players.isNotEmpty
                      ? questionStats.totalAnswers / session.players.length
                      : 0.0,
                  lastUpdated: DateTime.now(),
                );

                return Result.success(liveStats);
              },
              failure: (error) => Result.failure(error),
            );
          },
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to watch live answer stats: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch live stats: ${e.toString()}',
            code: 'watch_live_stats_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Set answer deadline timer
  void setAnswerDeadline({
    required String sessionId,
    required int questionIndex,
    required Duration timeLimit,
    required VoidCallback onDeadline,
  }) {
    final key = '${sessionId}_q$questionIndex';

    // Cancel existing timer if any
    _answerDeadlines[key]?.cancel();

    // Set new deadline timer
    _answerDeadlines[key] = Timer(timeLimit, () {
      AppLogger.firebase(
        'AnswerCollectionService',
        'Answer deadline reached for $sessionId q$questionIndex',
      );

      onDeadline();
      _answerDeadlines.remove(key);
    });

    AppLogger.firebase(
      'AnswerCollectionService',
      'Set answer deadline: $key for ${timeLimit.inSeconds}s',
    );
  }

  /// Cancel answer deadline
  void cancelAnswerDeadline({
    required String sessionId,
    required int questionIndex,
  }) {
    final key = '${sessionId}_q$questionIndex';
    _answerDeadlines[key]?.cancel();
    _answerDeadlines.remove(key);

    AppLogger.firebase(
      'AnswerCollectionService',
      'Cancelled answer deadline: $key',
    );
  }

  /// Get question summary after answering phase
  Future<Result<QuestionSummary>> getQuestionSummary({
    required String sessionId,
    required int questionIndex,
  }) async {
    try {
      final statsResult = await _dataSource.getQuestionStatistics(
        sessionId: sessionId,
        questionIndex: questionIndex,
      );

      return statsResult.when(
        success: (stats) async {
          // Get session for player details
          final sessionResult = await _dataSource.getGameSessionById(sessionId);

          return sessionResult.when(
            success: (session) {
              final summary = QuestionSummary(
                sessionId: sessionId,
                questionIndex: questionIndex,
                totalPlayers: stats['totalPlayers'] ?? 0,
                totalAnswers: stats['totalAnswers'] ?? 0,
                correctAnswers: stats['correctAnswers'] ?? 0,
                accuracy: stats['accuracy'] ?? 0.0,
                averageResponseTime: stats['averageResponseTime'] ?? 0.0,
                participationRate: stats['participationRate'] ?? 0.0,
                answerDistribution: Map<int, int>.from(
                  stats['answerCounts'] ?? {},
                ),
                fastestCorrectTime:
                    0, // Would need to calculate from player answers
                topPerformers: _getTopPerformersForQuestion(session.toEntity()),
                timestamp: DateTime.now(),
              );

              return Result.success(summary);
            },
            failure: (error) => Result.failure(error),
          );
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get question summary: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        ServerException(
          message: 'Failed to get question summary: ${e.toString()}',
          code: 'get_summary_error',
        ).toFailure(),
      );
    }
  }

  /// Export all answers for analysis
  Future<Result<List<AnswerRecord>>> exportSessionAnswers(
    String sessionId,
  ) async {
    try {
      final result = await _dataSource.getSessionAnswers(sessionId);

      return result.when(
        success: (answersData) {
          final records = answersData.map((data) {
            return AnswerRecord(
              sessionId: data['sessionId'] ?? '',
              playerId: data['playerId'] ?? '',
              playerName: data['playerName'] ?? '',
              questionIndex: data['questionIndex'] ?? 0,
              selectedOption: data['selectedOption'] ?? 0,
              isCorrect: data['isCorrect'] ?? false,
              responseTimeMs: data['responseTimeMs'] ?? 0,
              pointsEarned: data['pointsEarned'] ?? 0,
              answeredAt: data['answeredAt'] != null
                  ? (data['answeredAt'] as Timestamp).toDate()
                  : DateTime.now(),
            );
          }).toList();

          return Result.success(records);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to export session answers: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        ServerException(
          message: 'Failed to export answers: ${e.toString()}',
          code: 'export_answers_error',
        ).toFailure(),
      );
    }
  }

  /// Calculate points based on response time and correctness
  int _calculatePoints(int responseTimeMs, bool isCorrect) {
    if (!isCorrect) return 0;

    const basePoints = 1000;
    const timeBonus = 500;
    const maxTimeMs = 30000; // 30 seconds

    // Time bonus decreases linearly from max time
    final timeRatio =
        (maxTimeMs - responseTimeMs.clamp(0, maxTimeMs)) / maxTimeMs;
    final bonus = (timeBonus * timeRatio).round();

    return basePoints + bonus;
  }

  /// Calculate player rank in session
  int _calculatePlayerRank(GameSessionEntity session, String playerId) {
    final sortedPlayers = session.players.entries.toList();
    sortedPlayers.sort((a, b) => b.value.score.compareTo(a.value.score));

    final playerIndex = sortedPlayers.indexWhere(
      (entry) => entry.key == playerId,
    );
    return playerIndex >= 0 ? playerIndex + 1 : 0;
  }

  /// Broadcast answer update to active watchers
  void _broadcastAnswerUpdate(
    String sessionId,
    int questionIndex,
    String playerId,
    AnswerSubmissionResult result,
  ) {
    final key = '${sessionId}_q$questionIndex';
    final controller = _answerControllers[key];

    if (controller != null) {
      final update = AnswerUpdate(
        sessionId: sessionId,
        questionIndex: questionIndex,
        playerId: playerId,
        submissionResult: result,
        timestamp: DateTime.now(),
      );

      controller.add(update);
    }
  }

  /// Get fastest answer from player answers
  PlayerAnswerSummary? _getFastestAnswer(Map<String, dynamic> playerAnswers) {
    if (playerAnswers.isEmpty) return null;

    PlayerAnswerSummary? fastest;
    int fastestTime = double.maxFinite.toInt();

    for (final entry in playerAnswers.entries) {
      final data = entry.value as Map<String, dynamic>;
      final responseTime = data['responseTimeMs'] as int;

      if (responseTime < fastestTime) {
        fastestTime = responseTime;
        fastest = PlayerAnswerSummary(
          playerId: entry.key,
          playerName: data['playerName'] ?? '',
          selectedOption: data['selectedOption'] ?? 0,
          isCorrect: data['isCorrect'] ?? false,
          responseTimeMs: responseTime,
          pointsEarned: data['pointsEarned'] ?? 0,
        );
      }
    }

    return fastest;
  }

  /// Get slowest answer from player answers
  PlayerAnswerSummary? _getSlowestAnswer(Map<String, dynamic> playerAnswers) {
    if (playerAnswers.isEmpty) return null;

    PlayerAnswerSummary? slowest;
    int slowestTime = 0;

    for (final entry in playerAnswers.entries) {
      final data = entry.value as Map<String, dynamic>;
      final responseTime = data['responseTimeMs'] as int;

      if (responseTime > slowestTime) {
        slowestTime = responseTime;
        slowest = PlayerAnswerSummary(
          playerId: entry.key,
          playerName: data['playerName'] ?? '',
          selectedOption: data['selectedOption'] ?? 0,
          isCorrect: data['isCorrect'] ?? false,
          responseTimeMs: responseTime,
          pointsEarned: data['pointsEarned'] ?? 0,
        );
      }
    }

    return slowest;
  }

  /// Get top performers for a question
  List<PlayerPerformance> _getTopPerformersForQuestion(
    GameSessionEntity session,
  ) {
    final performers = session.players.entries
        .map(
          (entry) => PlayerPerformance(
            playerId: entry.key,
            playerName: entry.value.name,
            score: entry.value.score,
            answersCount: entry.value.answers.length,
          ),
        )
        .toList();

    performers.sort((a, b) => b.score.compareTo(a.score));
    return performers.take(5).toList();
  }

  /// Cleanup resources
  void dispose() {
    // Cancel all deadline timers
    for (final timer in _answerDeadlines.values) {
      timer.cancel();
    }
    _answerDeadlines.clear();

    // Close all answer controllers
    for (final controller in _answerControllers.values) {
      controller.close();
    }
    _answerControllers.clear();

    AppLogger.firebase(
      'AnswerCollectionService',
      'Disposed all answer resources',
    );
  }
}

/// Answer submission result data model
class AnswerSubmissionResult {
  final String sessionId;
  final String playerId;
  final int questionIndex;
  final int selectedOption;
  final bool isCorrect;
  final int pointsEarned;
  final int responseTimeMs;
  final int newTotalScore;
  final int rank;
  final DateTime answeredAt;

  const AnswerSubmissionResult({
    required this.sessionId,
    required this.playerId,
    required this.questionIndex,
    required this.selectedOption,
    required this.isCorrect,
    required this.pointsEarned,
    required this.responseTimeMs,
    required this.newTotalScore,
    required this.rank,
    required this.answeredAt,
  });
}

/// Question answer statistics data model
class QuestionAnswerStats {
  final String sessionId;
  final int questionIndex;
  final int totalAnswers;
  final int correctAnswers;
  final Map<int, int> answerCounts;
  final double averageResponseTime;
  final double participationRate;
  final Map<String, dynamic> playerAnswers;
  final DateTime lastUpdated;

  const QuestionAnswerStats({
    required this.sessionId,
    required this.questionIndex,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.answerCounts,
    required this.averageResponseTime,
    required this.participationRate,
    required this.playerAnswers,
    required this.lastUpdated,
  });

  double get accuracy => totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
}

/// Live answer statistics for host dashboard
class LiveAnswerStats {
  final String sessionId;
  final int questionIndex;
  final int totalPlayers;
  final int answeredCount;
  final int correctCount;
  final Map<int, int> answerDistribution;
  final PlayerAnswerSummary? fastestAnswer;
  final PlayerAnswerSummary? slowestAnswer;
  final double averageTime;
  final double accuracyRate;
  final double completionRate;
  final DateTime lastUpdated;

  const LiveAnswerStats({
    required this.sessionId,
    required this.questionIndex,
    required this.totalPlayers,
    required this.answeredCount,
    required this.correctCount,
    required this.answerDistribution,
    this.fastestAnswer,
    this.slowestAnswer,
    required this.averageTime,
    required this.accuracyRate,
    required this.completionRate,
    required this.lastUpdated,
  });

  int get pendingAnswers => totalPlayers - answeredCount;
  bool get allAnswered => answeredCount >= totalPlayers;
}

/// Question summary after completion
class QuestionSummary {
  final String sessionId;
  final int questionIndex;
  final int totalPlayers;
  final int totalAnswers;
  final int correctAnswers;
  final double accuracy;
  final double averageResponseTime;
  final double participationRate;
  final Map<int, int> answerDistribution;
  final double fastestCorrectTime;
  final List<PlayerPerformance> topPerformers;
  final DateTime timestamp;

  const QuestionSummary({
    required this.sessionId,
    required this.questionIndex,
    required this.totalPlayers,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.accuracy,
    required this.averageResponseTime,
    required this.participationRate,
    required this.answerDistribution,
    required this.fastestCorrectTime,
    required this.topPerformers,
    required this.timestamp,
  });
}

/// Player answer summary
class PlayerAnswerSummary {
  final String playerId;
  final String playerName;
  final int selectedOption;
  final bool isCorrect;
  final int responseTimeMs;
  final int pointsEarned;

  const PlayerAnswerSummary({
    required this.playerId,
    required this.playerName,
    required this.selectedOption,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.pointsEarned,
  });
}

/// Player performance data
class PlayerPerformance {
  final String playerId;
  final String playerName;
  final int score;
  final int answersCount;

  const PlayerPerformance({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.answersCount,
  });
}

/// Answer record for export
class AnswerRecord {
  final String sessionId;
  final String playerId;
  final String playerName;
  final int questionIndex;
  final int selectedOption;
  final bool isCorrect;
  final int responseTimeMs;
  final int pointsEarned;
  final DateTime answeredAt;

  const AnswerRecord({
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.questionIndex,
    required this.selectedOption,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.pointsEarned,
    required this.answeredAt,
  });
}

/// Answer update for real-time broadcasting
class AnswerUpdate {
  final String sessionId;
  final int questionIndex;
  final String playerId;
  final AnswerSubmissionResult submissionResult;
  final DateTime timestamp;

  const AnswerUpdate({
    required this.sessionId,
    required this.questionIndex,
    required this.playerId,
    required this.submissionResult,
    required this.timestamp,
  });
}
