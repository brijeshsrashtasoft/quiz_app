import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/score_entity.dart';
import '../repositories/leaderboard_repository.dart';

class UpdateRank implements UseCase<void, UpdateRankParams> {
  final LeaderboardRepository repository;

  const UpdateRank(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateRankParams params) async {
    return await repository.updateScore(params.sessionId, params.score);
  }
}

class UpdateRankParams extends Equatable {
  final String sessionId;
  final ScoreEntity score;

  const UpdateRankParams({required this.sessionId, required this.score});

  @override
  List<Object> get props => [sessionId, score];
}