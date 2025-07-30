import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_session_entity.dart';
import '../entities/game_pin.dart';
import '../repositories/game_session_repository.dart';

/// Use case for joining an existing game session
/// Handles PIN validation and player registration
class JoinGameSession {
  final GameSessionRepository _repository;

  const JoinGameSession(this._repository);

  Future<Result<GameSessionEntity>> call({
    required String pin,
    required String playerId,
    required String playerName,
  }) async {
    try {
      // Validate PIN format
      if (!GamePin.isValidPin(pin)) {
        return Result.failure(
          Failure.validationFailure(
            message: PinValidationError.invalidCharacters.message,
          ),
        );
      }

      // Get session by PIN
      final sessionResult = await _repository.getGameSessionByPin(pin);

      if (sessionResult.isFailure) {
        return Result.failure(
          Failure.sessionFailure(
            message: PinValidationError.notFound.message,
            code: 'SESSION_NOT_FOUND',
          ),
        );
      }

      final session = sessionResult.dataOrNull!;

      // Validate session state
      final validationResult = _validateSession(session, playerId);
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // Create player entity
      final player = PlayerEntity(
        name: playerName.trim(),
        joinedAt: DateTime.now(),
        score: 0,
        answers: [],
        isReady: false,
      );

      // Add player to session
      final updateResult = await _repository.addPlayerToSession(
        session.id,
        playerId,
        player,
      );

      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(updateResult.dataOrNull!);
    } catch (e) {
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to join game session: ${e.toString()}',
          code: 'JOIN_SESSION_ERROR',
        ),
      );
    }
  }

  /// Validate if player can join the session
  Failure? _validateSession(GameSessionEntity session, String playerId) {
    // Check if session is in waiting state
    if (!session.status.canJoin) {
      final error = session.status == GameSessionStatus.active
          ? PinValidationError.sessionInProgress
          : PinValidationError.sessionCompleted;
      
      return Failure.sessionFailure(
        message: error.message,
        code: 'INVALID_SESSION_STATE',
      );
    }

    // Check if session is full
    if (session.isFull) {
      return Failure.sessionFailure(
        message: PinValidationError.sessionFull.message,
        code: 'SESSION_FULL',
      );
    }

    // Check if player is already in session
    if (session.isPlayer(playerId)) {
      return const Failure.sessionFailure(
        message: 'You are already in this game',
        code: 'PLAYER_ALREADY_JOINED',
      );
    }

    // Check if session has expired
    if (session.hasExpired) {
      return const Failure.sessionFailure(
        message: 'This game session has expired',
        code: 'SESSION_EXPIRED',
      );
    }

    return null;
  }
}

/// Parameters for joining a game session
class JoinGameSessionParams {
  final String pin;
  final String playerId;
  final String playerName;

  const JoinGameSessionParams({
    required this.pin,
    required this.playerId,
    required this.playerName,
  });

  /// Validate player name
  String? validatePlayerName() {
    final trimmed = playerName.trim();
    
    if (trimmed.isEmpty) {
      return 'Please enter your name';
    }
    
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (trimmed.length > 20) {
      return 'Name must be less than 20 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(trimmed)) {
      return 'Name can only contain letters, numbers, and spaces';
    }
    
    return null;
  }
}