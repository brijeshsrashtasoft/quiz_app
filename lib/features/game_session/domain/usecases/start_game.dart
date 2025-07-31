import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_session_entity.dart';
import '../repositories/game_session_repository.dart';

/// Use case for starting a game session
/// Transitions session from waiting to active state
class StartGame {
  final GameSessionRepository _repository;

  const StartGame(this._repository);

  Future<Result<GameSessionEntity>> call({
    required String sessionId,
    required String hostId,
  }) async {
    try {
      // Get current session
      final sessionResult = await _repository.getGameSessionById(sessionId);

      if (sessionResult.isFailure) {
        return Result.failure(sessionResult.failureOrNull!);
      }

      final session = sessionResult.dataOrNull!;

      // Validate start conditions
      final validationResult = _validateStartConditions(session, hostId);
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Start the game session
      final startResult = await _repository.startGameSession(sessionId);

      if (startResult.isFailure) {
        return Result.failure(startResult.failureOrNull!);
      }

      return Result.success(startResult.dataOrNull!);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to start game: ${e.toString()}',
          code: 'START_GAME_ERROR',
        ),
      );
    }
  }

  /// Validate if game can be started
  Failure? _validateStartConditions(GameSessionEntity session, String hostId) {
    // Check if user is the host
    if (!session.isHost(hostId)) {
      return const Failure.authFailure(
        message: 'Only the host can start the game',
        code: 'NOT_HOST',
      );
    }

    // Check if session is in waiting state
    if (session.status != GameSessionStatus.waiting) {
      return Failure.sessionFailure(
        message: 'Game is already ${session.status.displayName.toLowerCase()}',
        code: 'INVALID_SESSION_STATE',
      );
    }

    // Check minimum players (at least 1 player besides host)
    if (session.playerCount < 1) {
      return const Failure.sessionFailure(
        message: 'Need at least 1 player to start',
        code: 'INSUFFICIENT_PLAYERS',
      );
    }

    // Check if all players are ready (optional based on settings)
    if (session.settings?.requireAllReady ?? false) {
      if (!session.allPlayersReady) {
        return const Failure.sessionFailure(
          message: 'All players must be ready to start',
          code: 'PLAYERS_NOT_READY',
        );
      }
    }

    return null;
  }
}

/// Extended game session settings for start conditions
extension GameSessionSettingsX on GameSessionSettings {
  /// Whether all players must be ready before starting
  bool get requireAllReady => false; // Can be added to settings if needed

  /// Minimum players required to start
  int get minPlayers => 1;
}
