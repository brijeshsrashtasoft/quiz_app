import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

class GetHistoricalLeaderboard implements UseCase<List<LeaderboardEntry>, GetHistoricalLeaderboardParams> {
  final LeaderboardRepository repository;

  const GetHistoricalLeaderboard(this.repository);

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> call(GetHistoricalLeaderboardParams params) async {
    return await repository.getHistoricalLeaderboard(
      quizId: params.quizId,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetHistoricalLeaderboardParams extends Equatable {
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

  @override
  List<Object?> get props => [quizId, startDate, endDate, limit];
}