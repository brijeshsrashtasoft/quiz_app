import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

class GetHistoricalLeaderboard
    extends
        BaseUseCase<List<LeaderboardEntry>, GetHistoricalLeaderboardParams> {
  final LeaderboardRepository repository;

  GetHistoricalLeaderboard(this.repository);

  @override
  Future<Result<List<LeaderboardEntry>>> call(
    GetHistoricalLeaderboardParams params,
  ) async {
    return await repository.getHistoricalLeaderboard(
      quizId: params.quizId,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetHistoricalLeaderboardParams extends BaseUseCaseParams {
  final String quizId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const GetHistoricalLeaderboardParams({
    required this.quizId,
    this.startDate,
    this.endDate,
    this.limit = 100,
  });

  List<Object?> get props => [quizId, startDate, endDate, limit];
}
