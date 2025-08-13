import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/game_session_entity.dart';
import '../repositories/game_session_repository.dart';

/// Use case for setting player ready status
/// Follows Clean Architecture patterns from CLAUDE.md
class SetPlayerReady
    implements UseCase<GameSessionEntity, SetPlayerReadyParams> {
  final GameSessionRepository repository;

  const SetPlayerReady(this.repository);

  @override
  Future<Result<GameSessionEntity>> call(SetPlayerReadyParams params) async {
    return repository.setPlayerReady(
      params.sessionId,
      params.playerId,
      params.isReady,
    );
  }
}

/// Parameters for SetPlayerReady use case
class SetPlayerReadyParams {
  final String sessionId;
  final String playerId;
  final bool isReady;

  const SetPlayerReadyParams({
    required this.sessionId,
    required this.playerId,
    required this.isReady,
  });
}
