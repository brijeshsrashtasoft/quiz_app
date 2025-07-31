import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboard implements UseCase<Leaderboard, GetLeaderboardParams> {
  final LeaderboardRepository repository;

  const GetLeaderboard(this.repository);

  @override
  Future<Either<Failure, Leaderboard>> call(GetLeaderboardParams params) async {
    return await repository.getLeaderboard(params.sessionId);
  }
}

class GetLeaderboardParams extends Equatable {
  final String sessionId;

  const GetLeaderboardParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
