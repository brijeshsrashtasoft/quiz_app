import '../../../../core/utils/result.dart';
import '../entities/game_session_entity.dart';

/// Game session repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore integration
abstract class GameSessionRepository {
  /// Get game session by ID
  Future<Result<GameSessionEntity>> getGameSessionById(String sessionId);

  /// Get game session by PIN
  Future<Result<GameSessionEntity>> getGameSessionByPin(String pin);

  /// Create new game session
  Future<Result<GameSessionEntity>> createGameSession(
    GameSessionEntity session,
  );

  /// Update game session
  Future<Result<GameSessionEntity>> updateGameSession(
    GameSessionEntity session,
  );

  /// Delete game session
  Future<Result<void>> deleteGameSession(String sessionId);

  /// Add player to game session
  Future<Result<GameSessionEntity>> addPlayerToSession(
    String sessionId,
    String playerId,
    PlayerEntity player,
  );

  /// Remove player from game session
  Future<Result<GameSessionEntity>> removePlayerFromSession(
    String sessionId,
    String playerId,
  );

  /// Update player in game session
  Future<Result<GameSessionEntity>> updatePlayerInSession(
    String sessionId,
    String playerId,
    PlayerEntity player,
  );

  /// Start game session
  Future<Result<GameSessionEntity>> startGameSession(String sessionId);

  /// Complete game session
  Future<Result<GameSessionEntity>> completeGameSession(String sessionId);

  /// Update current question index
  Future<Result<GameSessionEntity>> updateCurrentQuestion(
    String sessionId,
    int questionIndex,
  );

  /// Get active game sessions
  Future<Result<List<GameSessionEntity>>> getActiveGameSessions({int? limit});

  /// Get game sessions by host
  Future<Result<List<GameSessionEntity>>> getGameSessionsByHost(
    String hostId, {
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Get game sessions by quiz
  Future<Result<List<GameSessionEntity>>> getGameSessionsByQuiz(
    String quizId, {
    int? limit,
  });

  /// Get recent game sessions
  Future<Result<List<GameSessionEntity>>> getRecentGameSessions(int limit);

  /// Check if PIN is available
  Future<Result<bool>> isPinAvailable(String pin);

  /// Generate unique PIN
  Future<Result<String>> generateUniquePin();

  /// Get expired sessions for cleanup
  Future<Result<List<GameSessionEntity>>> getExpiredSessions();

  /// Cleanup expired sessions
  Future<Result<void>> cleanupExpiredSessions();

  /// Stream game session for real-time updates
  Stream<Result<GameSessionEntity>> watchGameSession(String sessionId);

  /// Stream active game sessions for monitoring
  Stream<Result<List<GameSessionEntity>>> watchActiveGameSessions();

  /// Batch operations
  Future<Result<void>> batchUpdateSessions(List<GameSessionEntity> sessions);
  Future<Result<void>> batchDeleteSessions(List<String> sessionIds);

  /// Analytics methods
  Future<Result<GameSessionAnalytics>> getSessionAnalytics(String sessionId);
  Future<Result<List<GameSessionAnalytics>>> getHostAnalytics(String hostId);
}

/// Game session analytics data model
class GameSessionAnalytics {
  final String sessionId;
  final int totalPlayers;
  final Duration sessionDuration;
  final double averageScore;
  final double completionRate;
  final Map<int, int> questionAccuracy; // questionIndex -> correctAnswers
  final DateTime sessionDate;

  const GameSessionAnalytics({
    required this.sessionId,
    required this.totalPlayers,
    required this.sessionDuration,
    required this.averageScore,
    required this.completionRate,
    required this.questionAccuracy,
    required this.sessionDate,
  });
}
