import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_session_entity.dart';
import '../entities/game_state.dart';
import '../repositories/game_session_repository.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';

/// Use case for submitting an answer to current question
/// Handles answer validation, scoring, and player updates
class SubmitAnswer {
  final GameSessionRepository _repository;

  const SubmitAnswer(this._repository);

  Future<Result<SubmitAnswerResult>> call({
    required String sessionId,
    required String playerId,
    required int selectedOption,
    required Question currentQuestion,
    required DateTime questionStartTime,
  }) async {
    try {
      // Get current session
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
      );
      
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Calculate answer details
      final answeredAt = DateTime.now();
      final responseTimeMs = answeredAt.difference(questionStartTime).inMilliseconds;
      final isCorrect = selectedOption == currentQuestion.correctAnswerIndex;
      
      // Calculate points earned
      final pointsEarned = _calculatePoints(
        isCorrect: isCorrect,
        responseTimeMs: responseTimeMs,
        maxPoints: currentQuestion.questionPoints,
        timeLimit: currentQuestion.questionTimeLimit,
      );

      // Get current player
      final player = session.getPlayer(playerId);
      if (player == null) {
        return Result.failure(
          const Failure.sessionFailure(
            message: 'Player not found in session',
            code: 'PLAYER_NOT_FOUND',
          ),
        );
      }

      // Update player with new answer and score
      final updatedAnswers = [...player.answers, selectedOption];
      final updatedScore = player.score + pointsEarned;
      
      final updatedPlayer = player.copyWith(
        answers: updatedAnswers,
        score: updatedScore,
      );

      // Update player in session
      final updateResult = await _repository.updatePlayerInSession(
        sessionId,
        playerId,
        updatedPlayer,
      );

      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      // Create answer result
      final answerResult = SubmitAnswerResult(
        isCorrect: isCorrect,
        pointsEarned: pointsEarned,
        responseTimeMs: responseTimeMs,
        newTotalScore: updatedScore,
        correctAnswer: currentQuestion.correctAnswerIndex,
        playerAnswer: PlayerAnswer(
          playerId: playerId,
          selectedOption: selectedOption,
          answeredAt: answeredAt,
          responseTimeMs: responseTimeMs,
          isCorrect: isCorrect,
          pointsEarned: pointsEarned,
        ),
      );

      return Result.success(answerResult);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to submit answer: ${e.toString()}',
          code: 'SUBMIT_ANSWER_ERROR',
        ),
      );
    }
  }

  /// Validate answer submission
  Failure? _validateSubmission(
    GameSessionEntity session,
    String playerId,
    int selectedOption,
    Question question,
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
      return const Failure.validationFailure(
        message: 'Invalid answer option',
      );
    }

    // Check if player has already answered this question
    final player = session.getPlayer(playerId);
    if (player != null && player.answers.length > session.currentQuestionIndex) {
      return const Failure.sessionFailure(
        message: 'You have already answered this question',
        code: 'ALREADY_ANSWERED',
      );
    }

    return null;
  }

  /// Calculate points based on correctness and speed
  int _calculatePoints({
    required bool isCorrect,
    required int responseTimeMs,
    required int maxPoints,
    required int timeLimit,
  }) {
    if (!isCorrect) return 0;

    // Base points for correct answer
    const basePointsPercentage = 0.5; // 50% for being correct
    final basePoints = (maxPoints * basePointsPercentage).round();

    // Speed bonus (remaining 50%)
    final timeLimitMs = timeLimit * 1000;
    final speedRatio = 1 - (responseTimeMs / timeLimitMs).clamp(0.0, 1.0);
    final speedBonus = (maxPoints * (1 - basePointsPercentage) * speedRatio).round();

    return basePoints + speedBonus;
  }
}

/// Result of submitting an answer
class SubmitAnswerResult {
  final bool isCorrect;
  final int pointsEarned;
  final int responseTimeMs;
  final int newTotalScore;
  final int correctAnswer;
  final PlayerAnswer playerAnswer;

  const SubmitAnswerResult({
    required this.isCorrect,
    required this.pointsEarned,
    required this.responseTimeMs,
    required this.newTotalScore,
    required this.correctAnswer,
    required this.playerAnswer,
  });

  /// Get feedback message for player
  String get feedbackMessage {
    if (isCorrect) {
      if (playerAnswer.isFastAnswer) {
        return 'Correct! Lightning fast! +$pointsEarned points';
      }
      return 'Correct! +$pointsEarned points';
    }
    return 'Incorrect. Better luck next time!';
  }

  /// Get response time in seconds
  double get responseTimeSeconds => responseTimeMs / 1000.0;
}