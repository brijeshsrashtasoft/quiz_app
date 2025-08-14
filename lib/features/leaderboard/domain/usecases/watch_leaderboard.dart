import 'dart:async';
import '../../../../core/usecases/stream_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';

class WatchLeaderboard
    implements StreamUseCase<Leaderboard, WatchLeaderboardParams> {
  final LeaderboardRepository repository;

  const WatchLeaderboard(this.repository);

  @override
  Stream<Result<Leaderboard>> call(WatchLeaderboardParams params) {
    return repository.watchLeaderboard(params.sessionId);
  }
}

class WatchLeaderboardParams {
  final String sessionId;

  const WatchLeaderboardParams({required this.sessionId});
}
