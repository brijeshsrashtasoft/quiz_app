import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboard extends BaseUseCase<Leaderboard, GetLeaderboardParams> {
  final LeaderboardRepository repository;

  GetLeaderboard(this.repository);

  @override
  Future<Result<Leaderboard>> call(GetLeaderboardParams params) async {
    return await repository.getLeaderboard(params.sessionId);
  }
}

class GetLeaderboardParams extends BaseUseCaseParams {
  final String sessionId;

  const GetLeaderboardParams({required this.sessionId});

  List<Object> get props => [sessionId];
}
