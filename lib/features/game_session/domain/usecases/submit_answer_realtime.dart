import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_session_entity.dart';
import '../entities/game_state.dart';
import '../repositories/game_session_repository.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';

/// Enhanced use case for submitting answers with real-time Firebase integration
/// Handles answer validation, scoring, real-time persistence, and player updates
class SubmitAnswerRealtime {
  final GameSessionRepository _repository;

  const SubmitAnswerRealtime(this._repository);

  Future<Result<SubmitAnswerRealtimeResult>> call({
    required String sessionId,
    required String playerId,
    required String playerName,
    required int selectedOption,
    required Question currentQuestion,
    required DateTime questionStartTime,
    required int questionIndex,
  }) async {
    try {
      // Get current session for validation
      final sessionResult = await _repository.getGameSessionById(sessionId);

      if (sessionResult.isFailure) {
        return Result.failure(sessionResult.failureOrNull!);
      }

      final session = sessionResult.dataOrNull!;

      // Validate answer submission
      final validationResult = _validateSubmission(
        session,
        playerId,
        selectedOption,
        currentQuestion,
        questionIndex,
      );

      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Calculate answer details
      final answeredAt = DateTime.now();
      final responseTimeMs = answeredAt
          .difference(questionStartTime)
          .inMilliseconds;
      final isCorrect = selectedOption == currentQuestion.correctAnswerIndex;

      // Calculate points earned
      final pointsEarned = _calculatePoints(
        isCorrect: isCorrect,
        responseTimeMs: responseTimeMs,
        maxPoints: currentQuestion.questionPoints,
        timeLimit: currentQuestion.questionTimeLimit,
      );

      // Submit answer with real-time Firebase integration
      final submitResult = await _repository.submitPlayerAnswer(
        sessionId: sessionId,
        playerId: playerId,
        playerName: playerName,
        selectedOption: selectedOption,
        answeredAt: answeredAt,
        responseTimeMs: responseTimeMs,
        isCorrect: isCorrect,
        pointsEarned: pointsEarned,
        questionIndex: questionIndex,
      );

      if (submitResult.isFailure) {
        return Result.failure(submitResult.failureOrNull!);
      }

      final updatedSession = submitResult.dataOrNull!;
      final updatedPlayer = updatedSession.getPlayer(playerId);

      if (updatedPlayer == null) {
        return Result.failure(
          const Failure.serverFailure(
            message: 'Failed to retrieve updated player data',
            code: 'PLAYER_UPDATE_ERROR',
          ),
        );
      }

      // Create enhanced answer result
      final answerResult = SubmitAnswerRealtimeResult(
        isCorrect: isCorrect,
        pointsEarned: pointsEarned,
        responseTimeMs: responseTimeMs,
        newTotalScore: updatedPlayer.score,
        correctAnswer: currentQuestion.correctAnswerIndex,
        playerAnswer: PlayerAnswer(
          playerId: playerId,
          selectedOption: selectedOption,
          answeredAt: answeredAt,
          responseTimeMs: responseTimeMs,
          isCorrect: isCorrect,
          pointsEarned: pointsEarned,
        ),
        updatedSession: updatedSession,
        rank: _calculatePlayerRank(updatedSession, playerId),
      );

      return Result.success(answerResult);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to submit answer: ${e.toString()}',
          code: 'SUBMIT_ANSWER_REALTIME_ERROR',
        ),
      );
    }
  }

  /// Validate answer submission with enhanced checks
  Failure? _validateSubmission(
    GameSessionEntity session,
    String playerId,
    int selectedOption,
    Question question,
    int questionIndex,
  ) {
    // Check if session is active
    if (!session.status.isActive) {
      return const Failure.sessionFailure(
        message: 'Game is not active',
        code: 'GAME_NOT_ACTIVE',
      );
    }

    // Check if player is in session
    if (!session.isPlayer(playerId)) {
      return const Failure.sessionFailure(
        message: 'You are not in this game',
        code: 'NOT_IN_SESSION',
      );
    }

    // Check if answer is valid option
    if (selectedOption < 0 || selectedOption >= question.options.length) {
      return const Failure.validationFailure(message: 'Invalid answer option');
    }

    // Check if it's the correct question index
    if (session.currentQuestionIndex != questionIndex) {
      return const Failure.sessionFailure(
        message: 'Question index mismatch - game may have progressed',
        code: 'QUESTION_INDEX_MISMATCH',
      );
    }

    // Check if player has already answered this question
    final player = session.getPlayer(playerId);
    if (player != null && player.answers.length > questionIndex) {
      return const Failure.sessionFailure(
        message: 'You have already answered this question',
        code: 'ALREADY_ANSWERED',
      );
    }

    return null;
  }

  /// Calculate points based on correctness and speed with enhanced algorithm
  int _calculatePoints({
    required bool isCorrect,
    required int responseTimeMs,
    required int maxPoints,
    required int timeLimit,
  }) {
    if (!isCorrect) return 0;

    // Base points for correct answer (50%)
    const basePointsPercentage = 0.5;
    final basePoints = (maxPoints * basePointsPercentage).round();

    // Speed bonus (50% scaled by remaining time)
    final timeLimitMs = timeLimit * 1000;
    final speedRatio = 1 - (responseTimeMs / timeLimitMs).clamp(0.0, 1.0);

    // Apply speed bonus curve (faster answers get exponentially more points)
    final speedMultiplier = speedRatio * speedRatio; // Quadratic curve
    final speedBonus =
        (maxPoints * (1 - basePointsPercentage) * speedMultiplier).round();

    return basePoints + speedBonus;
  }

  /// Calculate player's current rank in the session
  int _calculatePlayerRank(GameSessionEntity session, String playerId) {
    final player = session.getPlayer(playerId);
    if (player == null) return session.players.length;

    final sortedPlayers = session.players.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    for (int i = 0; i < sortedPlayers.length; i++) {
      if (sortedPlayers[i].score == player.score) {
        // Find the first player with this score for consistent ranking
        int rank = i + 1;
        while (rank > 1 && sortedPlayers[rank - 2].score == player.score) {
          rank--;
        }
        return rank;
      }
    }

    return session.players.length;
  }
}

/// Enhanced result of submitting an answer with real-time updates
class SubmitAnswerRealtimeResult {
  final bool isCorrect;
  final int pointsEarned;
  final int responseTimeMs;
  final int newTotalScore;
  final int correctAnswer;
  final PlayerAnswer playerAnswer;
  final GameSessionEntity updatedSession;
  final int rank;

  const SubmitAnswerRealtimeResult({
    required this.isCorrect,
    required this.pointsEarned,
    required this.responseTimeMs,
    required this.newTotalScore,
    required this.correctAnswer,
    required this.playerAnswer,
    required this.updatedSession,
    required this.rank,
  });

  /// Get feedback message for player
  String get feedbackMessage {
    if (isCorrect) {
      if (playerAnswer.isFastAnswer) {
        return 'Correct! Lightning fast! +$pointsEarned points (Rank #$rank)';
      }
      return 'Correct! +$pointsEarned points (Rank #$rank)';
    }
    return 'Incorrect. Better luck next time! (Rank #$rank)';
  }

  /// Get response time in seconds
  double get responseTimeSeconds => responseTimeMs / 1000.0;

  /// Check if this was a perfect score
  bool get isPerfectScore => isCorrect && playerAnswer.isFastAnswer;

  /// Get score improvement from previous total
  int get scoreIncrease => pointsEarned;
}
