import 'dart:math';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_repository.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../datasources/game_session_firestore_datasource.dart';
import '../models/game_session_model.dart';

/// Game session repository implementation for Clean Architecture
/// Following CLAUDE.md patterns and error handling
class GameSessionRepositoryImpl extends BaseRepository
    implements GameSessionRepository {
  final GameSessionFirestoreDataSource dataSource;
  final Random _random = Random();

  GameSessionRepositoryImpl({required this.dataSource});

  @override
  Future<Result<GameSessionEntity>> getGameSessionById(String sessionId) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.getGameSessionById(sessionId);

      return result.when(
        success: (sessionModel) => Result.success(sessionModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get game session by ID: ${e.toString()}',
          code: 'get_session_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> getGameSessionByPin(String pin) async {
    try {
      if (!_isValidPin(pin)) {
        return Result.failure(
          const ValidationException(
            message: 'Invalid PIN format - must be 6 digits',
          ).toFailure(),
        );
      }

      final result = await dataSource.getGameSessionByPin(pin);

      return result.when(
        success: (sessionModel) => Result.success(sessionModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get game session by PIN: ${e.toString()}',
          code: 'get_session_by_pin_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> createGameSession(
    GameSessionEntity session,
  ) async {
    try {
      final validationError = _validateGameSession(session);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final sessionModel = session.toModel();
      final result = await dataSource.createGameSession(sessionModel);

      return result.when(
        success: (createdModel) => Result.success(createdModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to create game session: ${e.toString()}',
          code: 'create_session_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> updateGameSession(
    GameSessionEntity session,
  ) async {
    try {
      final validationError = _validateGameSession(session);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final sessionModel = session.toModel();
      final result = await dataSource.updateGameSession(sessionModel);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update game session: ${e.toString()}',
          code: 'update_session_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> deleteGameSession(String sessionId) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.deleteGameSession(sessionId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to delete game session: ${e.toString()}',
          code: 'delete_session_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> addPlayerToSession(
    String sessionId,
    String playerId,
    PlayerEntity player,
  ) async {
    try {
      if (sessionId.isEmpty || playerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID and Player ID cannot be empty',
          ).toFailure(),
        );
      }

      final playerValidationError = _validatePlayer(player);
      if (playerValidationError != null) {
        return Result.failure(playerValidationError.toFailure());
      }

      final playerModel = player.toModel();
      final result = await dataSource.addPlayerToSession(
        sessionId,
        playerId,
        playerModel,
      );

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to add player to session: ${e.toString()}',
          code: 'add_player_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> removePlayerFromSession(
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

      final result = await dataSource.removePlayerFromSession(
        sessionId,
        playerId,
      );

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to remove player from session: ${e.toString()}',
          code: 'remove_player_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> updatePlayerInSession(
    String sessionId,
    String playerId,
    PlayerEntity player,
  ) async {
    try {
      if (sessionId.isEmpty || playerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID and Player ID cannot be empty',
          ).toFailure(),
        );
      }

      final playerValidationError = _validatePlayer(player);
      if (playerValidationError != null) {
        return Result.failure(playerValidationError.toFailure());
      }

      final playerModel = player.toModel();
      final result = await dataSource.updatePlayerInSession(
        sessionId,
        playerId,
        playerModel,
      );

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update player in session: ${e.toString()}',
          code: 'update_player_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> setPlayerReady(
    String sessionId,
    String playerId,
    bool isReady,
  ) async {
    try {
      if (sessionId.isEmpty || playerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID and Player ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.setPlayerReady(
        sessionId,
        playerId,
        isReady,
      );

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to set player ready status: ${e.toString()}',
          code: 'set_player_ready_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> startGameSession(String sessionId) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.startGameSession(sessionId);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to start game session: ${e.toString()}',
          code: 'start_session_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> completeGameSession(
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

      final result = await dataSource.completeGameSession(sessionId);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to complete game session: ${e.toString()}',
          code: 'complete_session_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> updateCurrentQuestion(
    String sessionId,
    int questionIndex,
  ) async {
    try {
      if (sessionId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session ID cannot be empty',
          ).toFailure(),
        );
      }

      if (questionIndex < 0) {
        return Result.failure(
          const ValidationException(
            message: 'Question index cannot be negative',
          ).toFailure(),
        );
      }

      final result = await dataSource.updateCurrentQuestion(
        sessionId,
        questionIndex,
      );

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update current question: ${e.toString()}',
          code: 'update_question_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<GameSessionEntity>>> getActiveGameSessions({
    int? limit,
  }) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getActiveGameSessions(limit: limit ?? 50);

      return result.when(
        success: (sessionModels) => Result.success(
          sessionModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get active game sessions: ${e.toString()}',
          code: 'get_active_sessions_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<GameSessionEntity>>> getGameSessionsByHost(
    String hostId, {
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    try {
      if (hostId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Host ID cannot be empty',
          ).toFailure(),
        );
      }

      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getGameSessionsByHost(
        hostId,
        limit: limit ?? 50,
      );

      return result.when(
        success: (sessionModels) => Result.success(
          sessionModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get sessions by host: ${e.toString()}',
          code: 'get_host_sessions_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<GameSessionEntity>>> getGameSessionsByQuiz(
    String quizId, {
    int? limit,
  }) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getGameSessionsByQuiz(
        quizId,
        limit: limit ?? 50,
      );

      return result.when(
        success: (sessionModels) => Result.success(
          sessionModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get sessions by quiz: ${e.toString()}',
          code: 'get_quiz_sessions_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<GameSessionEntity>>> getRecentGameSessions(
    int limit,
  ) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getRecentGameSessions(limit: limit);

      return result.when(
        success: (sessionModels) => Result.success(
          sessionModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get recent sessions: ${e.toString()}',
          code: 'get_recent_sessions_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<bool>> isPinAvailable(String pin) async {
    try {
      if (!_isValidPin(pin)) {
        return Result.failure(
          const ValidationException(
            message: 'Invalid PIN format - must be 6 digits',
          ).toFailure(),
        );
      }

      return await dataSource.isPinAvailable(pin);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to check PIN availability: ${e.toString()}',
          code: 'check_pin_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<String>> generateUniquePin() async {
    try {
      // Try up to 10 times to generate a unique PIN
      for (int attempt = 0; attempt < 10; attempt++) {
        final pin = _generateRandomPin();
        final isAvailableResult = await dataSource.isPinAvailable(pin);

        if (isAvailableResult.isSuccess && isAvailableResult.data == true) {
          return Result.success(pin);
        }
      }

      return Result.failure(
        const ServerException(
          message: 'Unable to generate unique PIN after 10 attempts',
          code: 'pin_generation_failed',
        ).toFailure(),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to generate unique PIN: ${e.toString()}',
          code: 'generate_pin_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<GameSessionEntity>>> getExpiredSessions() async {
    try {
      final result = await dataSource.getExpiredSessions();

      return result.when(
        success: (sessionModels) => Result.success(
          sessionModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get expired sessions: ${e.toString()}',
          code: 'get_expired_sessions_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> cleanupExpiredSessions() async {
    try {
      return await dataSource.cleanupExpiredSessions();
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to cleanup expired sessions: ${e.toString()}',
          code: 'cleanup_sessions_error',
        ).toFailure(),
      );
    }
  }

  @override
  Stream<Result<GameSessionEntity>> watchGameSession(String sessionId) {
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

      return dataSource.watchGameSession(sessionId).map((result) {
        return result.when(
          success: (sessionModel) => Result.success(sessionModel.toEntity()),
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch game session: ${e.toString()}',
            code: 'watch_session_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Stream<Result<List<GameSessionEntity>>> watchActiveGameSessions() {
    try {
      return dataSource.watchActiveGameSessions().map((result) {
        return result.when(
          success: (sessionModels) => Result.success(
            sessionModels.map((model) => model.toEntity()).toList(),
          ),
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch active sessions: ${e.toString()}',
            code: 'watch_active_sessions_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> batchUpdateSessions(
    List<GameSessionEntity> sessions,
  ) async {
    try {
      if (sessions.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Session list cannot be empty',
          ).toFailure(),
        );
      }

      if (sessions.length > 500) {
        return Result.failure(
          const ValidationException(
            message: 'Batch size cannot exceed 500 sessions',
          ).toFailure(),
        );
      }

      // Validate all sessions before batch operation
      for (final session in sessions) {
        final validationError = _validateGameSession(session);
        if (validationError != null) {
          return Result.failure(validationError.toFailure());
        }
      }

      final sessionModels = sessions
          .map((session) => session.toModel())
          .toList();

      return await dataSource.batchUpdateSessions(sessionModels);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to batch update sessions: ${e.toString()}',
          code: 'batch_update_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> batchDeleteSessions(List<String> sessionIds) async {
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

      return await dataSource.batchDeleteSessions(sessionIds);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to batch delete sessions: ${e.toString()}',
          code: 'batch_delete_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionAnalytics>> getSessionAnalytics(
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

      final result = await dataSource.getSessionAnalytics(sessionId);
      return result.when(
        success: (data) => Result.success(
          GameSessionAnalytics(
            sessionId: sessionId,
            totalPlayers: data['totalPlayers'] as int,
            averageScore: data['averageScore'] as double,
            completionRate: data['completionRate'] as double,
            sessionDuration: Duration(minutes: data['sessionDuration'] as int),
            questionAccuracy: {}, // TODO: Calculate from session data
            sessionDate: DateTime.now(), // TODO: Get from session data
          ),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get session analytics: ${e.toString()}',
          code: 'get_analytics_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<GameSessionAnalytics>>> getHostAnalytics(
    String hostId,
  ) async {
    try {
      if (hostId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Host ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.getHostAnalytics(hostId);
      return result.when(
        success: (data) {
          // Convert the host analytics data to a list of GameSessionAnalytics
          // For now, return an empty list as we need proper session data
          return Result.success(<GameSessionAnalytics>[]);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get host analytics: ${e.toString()}',
          code: 'get_host_analytics_error',
        ).toFailure(),
      );
    }
  }

  // ===========================
  // PRIVATE VALIDATION METHODS
  // ===========================

  /// Validate game session entity
  ValidationException? _validateGameSession(GameSessionEntity session) {
    if (session.quizId.isEmpty) {
      return const ValidationException(message: 'Quiz ID cannot be empty');
    }

    if (session.hostId.isEmpty) {
      return const ValidationException(message: 'Host ID cannot be empty');
    }

    if (!_isValidPin(session.pin)) {
      return const ValidationException(message: 'PIN must be exactly 6 digits');
    }

    if (session.currentQuestionIndex < 0) {
      return const ValidationException(
        message: 'Current question index cannot be negative',
      );
    }

    if (session.players.length > (session.settings?.maxPlayers ?? 50)) {
      return const ValidationException(
        message: 'Player count exceeds maximum allowed',
      );
    }

    // Validate each player
    for (final entry in session.players.entries) {
      final playerError = _validatePlayer(entry.value);
      if (playerError != null) return playerError;
    }

    return null;
  }

  /// Validate player entity
  ValidationException? _validatePlayer(PlayerEntity player) {
    if (player.name.isEmpty) {
      return const ValidationException(message: 'Player name cannot be empty');
    }

    if (player.name.length > 50) {
      return const ValidationException(
        message: 'Player name cannot exceed 50 characters',
      );
    }

    if (player.score < 0) {
      return const ValidationException(
        message: 'Player score cannot be negative',
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

      if (limit > 100) {
        return const ValidationException(message: 'Limit cannot exceed 100');
      }
    }

    return null;
  }

  /// Validate PIN format
  bool _isValidPin(String pin) {
    return pin.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(pin);
  }

  /// Generate random 6-digit PIN
  String _generateRandomPin() {
    return List.generate(6, (_) => _random.nextInt(10)).join();
  }

  // ===========================================
  // REAL-TIME ANSWER INTEGRATION METHODS
  // ===========================================

  @override
  Future<Result<GameSessionEntity>> submitPlayerAnswer({
    required String sessionId,
    required String playerId,
    required String playerName,
    required int selectedOption,
    required DateTime answeredAt,
    required int responseTimeMs,
    required bool isCorrect,
    required int pointsEarned,
    required int questionIndex,
  }) async {
    try {
      final result = await dataSource.submitPlayerAnswer(
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

      return result.when(
        success: (sessionModel) => Result.success(sessionModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to submit player answer: ${e.toString()}',
          code: 'submit_player_answer_error',
        ).toFailure(),
      );
    }
  }

  @override
  Stream<Result<Map<String, dynamic>>> watchQuestionAnswers(
    String sessionId,
    int questionIndex,
  ) {
    try {
      return dataSource.watchQuestionAnswers(sessionId, questionIndex);
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch question answers: ${e.toString()}',
            code: 'watch_question_answers_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getQuestionStatistics({
    required String sessionId,
    required int questionIndex,
  }) async {
    try {
      return await dataSource.getQuestionStatistics(
        sessionId: sessionId,
        questionIndex: questionIndex,
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get question statistics: ${e.toString()}',
          code: 'get_question_statistics_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<GameSessionEntity>> updateQuestionPhase({
    required String sessionId,
    required int questionIndex,
    required String phase,
    required DateTime phaseStartTime,
    required int phaseDurationSeconds,
  }) async {
    try {
      final result = await dataSource.updateQuestionPhase(
        sessionId: sessionId,
        questionIndex: questionIndex,
        phase: phase,
        phaseStartTime: phaseStartTime,
        phaseDurationSeconds: phaseDurationSeconds,
      );

      return result.when(
        success: (sessionModel) => Result.success(sessionModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update question phase: ${e.toString()}',
          code: 'update_question_phase_error',
        ).toFailure(),
      );
    }
  }

  @override
  Stream<Result<Map<String, dynamic>>> watchGamePhase(String sessionId) {
    try {
      return dataSource.watchGamePhase(sessionId);
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch game phase: ${e.toString()}',
            code: 'watch_game_phase_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getSessionAnswers(
    String sessionId,
  ) async {
    try {
      return await dataSource.getSessionAnswers(sessionId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get session answers: ${e.toString()}',
          code: 'get_session_answers_error',
        ).toFailure(),
      );
    }
  }
}
