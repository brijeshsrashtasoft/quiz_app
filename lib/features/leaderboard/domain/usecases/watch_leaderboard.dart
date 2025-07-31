import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/stream_usecase.dart';
import '../entities/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';

class WatchLeaderboard
    implements StreamUseCase<Leaderboard, WatchLeaderboardParams> {
  final LeaderboardRepository repository;

  const WatchLeaderboard(this.repository);

  @override
  Stream<Either<Failure, Leaderboard>> call(WatchLeaderboardParams params) {
    return repository.watchLeaderboard(params.sessionId);
  }
}

class WatchLeaderboardParams extends Equatable {
  final String sessionId;

  const WatchLeaderboardParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
