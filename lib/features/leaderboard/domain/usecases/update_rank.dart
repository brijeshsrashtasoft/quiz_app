import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/score_entity.dart';
import '../repositories/leaderboard_repository.dart';

class UpdateRank extends BaseUseCase<void, UpdateRankParams> {
  final LeaderboardRepository repository;

  UpdateRank(this.repository);

  @override
  Future<Result<void>> call(UpdateRankParams params) async {
    return await repository.updateScore(params.sessionId, params.score);
  }
}

class UpdateRankParams extends BaseUseCaseParams {
  final String sessionId;
  final ScoreEntity score;

  const UpdateRankParams({required this.sessionId, required this.score});

  List<Object> get props => [sessionId, score];
}
