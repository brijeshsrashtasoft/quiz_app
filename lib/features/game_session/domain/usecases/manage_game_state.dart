import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_session_entity.dart';
import '../entities/game_state.dart';
import '../repositories/game_session_repository.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';

/// Use case for managing game state transitions
/// Handles phase changes and timing for game flow
class ManageGameState {
  final GameSessionRepository _repository;

  const ManageGameState(this._repository);

  /// Transition to a new game phase
  Future<Result<GameState>> transitionToPhase({
    required String sessionId,
    required GamePhase newPhase,
    required Question currentQuestion,
    required int currentQuestionIndex,
  }) async {
    try {
      // Create game state for new phase
      final phaseStartTime = DateTime.now();
      final phaseEndTime = _calculatePhaseEndTime(newPhase, currentQuestion);

      final gameState = GameState(
        sessionId: sessionId,
        currentQuestion: currentQuestion,
        currentQuestionIndex: currentQuestionIndex,
        questionStartTime: phaseStartTime,
        playerAnswers: {}, // Reset for new question
        phase: newPhase,
        phaseEndTime: phaseEndTime,
      );

      // Emit game event for phase change
      await _emitGameEvent(
        GameEvent.phaseChanged(
          newPhase: newPhase,
          timestamp: phaseStartTime,
        ),
      );

      return Result.success(gameState);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to transition game phase: ${e.toString()}',
          code: 'PHASE_TRANSITION_ERROR',
        ),
      );
    }
  }

  /// Handle player ready status
  Future<Result<void>> setPlayerReady({
    required String sessionId,
    required String playerId,
    required bool isReady,
  }) async {
    try {
      // Get current session
      final sessionResult = await _repository.getGameSessionById(sessionId);

      if (sessionResult.isFailure) {
        return Result.failure(sessionResult.failureOrNull!);
      }

      final session = sessionResult.dataOrNull!;
      final player = session.getPlayer(playerId);

      if (player == null) {
        return Result.failure(
          const Failure.sessionFailure(
            message: 'Player not found',
            code: 'PLAYER_NOT_FOUND',
          ),
        );
      }

      // Update player ready status
      final updatedPlayer = player.copyWith(isReady: isReady);
      
      final updateResult = await _repository.updatePlayerInSession(
        sessionId,
        playerId,
        updatedPlayer,
      );

      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to update player ready status: ${e.toString()}',
          code: 'UPDATE_READY_ERROR',
        ),
      );
    }
  }

  /// Handle player leaving the game
  Future<Result<void>> handlePlayerLeave({
    required String sessionId,
    required String playerId,
  }) async {
    try {
      final removeResult = await _repository.removePlayerFromSession(
        sessionId,
        playerId,
      );

      if (removeResult.isFailure) {
        return Result.failure(removeResult.failureOrNull!);
      }

      // Emit player left event
      await _emitGameEvent(
        GameEvent.playerLeft(
          playerId: playerId,
          timestamp: DateTime.now(),
        ),
      );

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to handle player leave: ${e.toString()}',
          code: 'PLAYER_LEAVE_ERROR',
        ),
      );
    }
  }

  /// Calculate phase end time based on phase type
  DateTime? _calculatePhaseEndTime(GamePhase phase, Question question) {
    final duration = phase == GamePhase.questionActive
        ? question.questionTimeLimit
        : phase.phaseDuration;

    if (duration == 0) return null; // Indefinite phases

    return DateTime.now().add(Duration(seconds: duration));
  }

  /// Emit game event (implementation would connect to event system)
  Future<void> _emitGameEvent(GameEvent event) async {
    // This would be implemented to emit events through
    // a proper event system or state management
  }
}

/// Game flow controller for orchestrating game phases
class GameFlowController {
  final ManageGameState _manageGameState;
  
  const GameFlowController(this._manageGameState);

  /// Get next phase in game flow
  GamePhase getNextPhase(GamePhase currentPhase, bool hasMoreQuestions) {
    switch (currentPhase) {
      case GamePhase.waitingToStart:
        return GamePhase.questionDisplay;
      case GamePhase.questionDisplay:
        return GamePhase.questionActive;
      case GamePhase.questionActive:
        return GamePhase.answerReveal;
      case GamePhase.answerReveal:
        return GamePhase.leaderboardDisplay;
      case GamePhase.leaderboardDisplay:
        return hasMoreQuestions 
            ? GamePhase.questionDisplay 
            : GamePhase.gameCompleted;
      case GamePhase.gameCompleted:
        return GamePhase.gameCompleted; // Terminal state
    }
  }

  /// Check if phase should auto-advance
  bool shouldAutoAdvance(GamePhase phase) {
    switch (phase) {
      case GamePhase.waitingToStart:
      case GamePhase.gameCompleted:
        return false; // Manual advance only
      default:
        return true; // Auto-advance after timer
    }
  }
}