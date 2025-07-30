import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_session_entity.dart';
import '../entities/game_state.dart';
import '../repositories/game_session_repository.dart';
import '../../../quiz_creation/domain/repositories/quiz_repository.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';

/// Use case for advancing to the next question
/// Handles question progression and game completion
class NextQuestion {
  final GameSessionRepository _sessionRepository;
  final QuizRepository _quizRepository;

  const NextQuestion(this._sessionRepository, this._quizRepository);

  Future<Result<NextQuestionResult>> call({
    required String sessionId,
    required String hostId,
  }) async {
    try {
      // Get current session
      final sessionResult = await _sessionRepository.getGameSessionById(sessionId);

      if (sessionResult.isFailure) {
        return Result.failure(sessionResult.failureOrNull!);
      }

      final session = sessionResult.dataOrNull!;

      // Validate host permission
      if (!session.isHost(hostId)) {
        return Result.failure(
          const Failure.authFailure(
            message: 'Only the host can advance questions',
            code: 'NOT_HOST',
          ),
        );
      }

      // Validate session state
      if (!session.status.isActive) {
        return Result.failure(
          const Failure.sessionFailure(
            message: 'Game is not active',
            code: 'GAME_NOT_ACTIVE',
          ),
        );
      }

      // Get quiz data
      final quizResult = await _quizRepository.getQuizById(session.quizId);
      
      if (quizResult.isFailure) {
        return Result.failure(quizResult.failureOrNull!);
      }

      final quiz = quizResult.dataOrNull!;
      final nextIndex = session.currentQuestionIndex + 1;

      // Check if there are more questions
      if (nextIndex >= quiz.questions.length) {
        // Game is complete - update session status
        final completeResult = await _sessionRepository.completeGameSession(sessionId);
        
        if (completeResult.isFailure) {
          return Result.failure(completeResult.failureOrNull!);
        }

        return Result.success(
          NextQuestionResult(
            isGameComplete: true,
            nextQuestionIndex: null,
            totalQuestions: quiz.questions.length,
            updatedSession: completeResult.dataOrNull!,
          ),
        );
      }

      // Update to next question
      final updateResult = await _sessionRepository.updateCurrentQuestion(
        sessionId,
        nextIndex,
      );

      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(
        NextQuestionResult(
          isGameComplete: false,
          nextQuestionIndex: nextIndex,
          totalQuestions: quiz.questions.length,
          updatedSession: updateResult.dataOrNull!,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to advance to next question: ${e.toString()}',
          code: 'NEXT_QUESTION_ERROR',
        ),
      );
    }
  }
}

/// Result of advancing to next question
class NextQuestionResult {
  final bool isGameComplete;
  final int? nextQuestionIndex;
  final int totalQuestions;
  final GameSessionEntity updatedSession;

  const NextQuestionResult({
    required this.isGameComplete,
    required this.nextQuestionIndex,
    required this.totalQuestions,
    required this.updatedSession,
  });

  /// Get progress percentage
  double get progressPercentage {
    if (isGameComplete) return 100.0;
    if (nextQuestionIndex == null) return 0.0;
    return (nextQuestionIndex! / totalQuestions) * 100;
  }

  /// Get remaining questions count
  int get remainingQuestions {
    if (isGameComplete || nextQuestionIndex == null) return 0;
    return totalQuestions - nextQuestionIndex!;
  }

  /// Get progress message
  String get progressMessage {
    if (isGameComplete) {
      return 'Game Complete!';
    }
    return 'Question ${nextQuestionIndex! + 1} of $totalQuestions';
  }
}