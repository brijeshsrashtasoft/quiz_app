import '../../../../core/utils/result.dart';
import '../entities/game_session_entity.dart';
import '../repositories/game_session_repository.dart';

/// Use case for watching real-time game session updates
/// Provides stream of session changes for live gameplay
class WatchGameSession {
  final GameSessionRepository _repository;

  const WatchGameSession(this._repository);

  /// Watch game session for real-time updates
  Stream<Result<GameSessionEntity>> call(String sessionId) {
    return _repository.watchGameSession(sessionId);
  }

  /// Watch active game sessions (for lobby/discovery)
  Stream<Result<List<GameSessionEntity>>> watchActiveSessions() {
    return _repository.watchActiveGameSessions();
  }
}

/// Extended functionality for game session watching
extension WatchGameSessionExtensions on Stream<Result<GameSessionEntity>> {
  /// Transform to player count updates only
  Stream<int> get playerCountStream => where(
    (result) => result.isSuccess,
  ).map((result) => result.dataOrThrow.playerCount).distinct();

  /// Transform to game status updates only
  Stream<GameSessionStatus> get statusStream => where(
    (result) => result.isSuccess,
  ).map((result) => result.dataOrThrow.status).distinct();

  /// Transform to current question index updates
  Stream<int> get questionIndexStream => where(
    (result) => result.isSuccess,
  ).map((result) => result.dataOrThrow.currentQuestionIndex).distinct();

  /// Filter for specific player updates
  Stream<PlayerEntity?> playerStream(String playerId) => where(
    (result) => result.isSuccess,
  ).map((result) => result.dataOrThrow.getPlayer(playerId)).distinct();

  /// Transform to leaderboard updates
  Stream<List<MapEntry<String, PlayerEntity>>> get leaderboardStream => where(
    (result) => result.isSuccess,
  ).map((result) => result.dataOrThrow.leaderboard);
}
