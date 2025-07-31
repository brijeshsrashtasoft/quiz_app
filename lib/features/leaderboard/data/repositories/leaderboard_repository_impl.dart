import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/score_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';
import '../models/score_model.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const LeaderboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, Leaderboard>> watchLeaderboard(
    String sessionId,
  ) async* {
    if (await networkInfo.isConnected) {
      try {
        await for (final leaderboardModel in remoteDataSource.watchLeaderboard(
          sessionId,
        )) {
          yield Right(leaderboardModel.toEntity());
        }
      } on ServerException catch (e) {
        yield Left(ServerFailure(message: e.message));
      } catch (e) {
        yield Left(ServerFailure(message: e.toString()));
      }
    } else {
      yield const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateScore(
    String sessionId,
    ScoreEntity score,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final scoreModel = ScoreModel.fromEntity(score);
        await remoteDataSource.updateScore(sessionId, scoreModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Leaderboard>> getLeaderboard(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final leaderboardModel = await remoteDataSource.getLeaderboard(
          sessionId,
        );
        return Right(leaderboardModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getHistoricalLeaderboard({
    required String quizId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final entries = await remoteDataSource.getHistoricalLeaderboard(
          quizId: quizId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
        return Right(entries.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, LeaderboardEntry>> getPlayerStats({
    required String playerId,
    required String sessionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final entry = await remoteDataSource.getPlayerStats(
          playerId: playerId,
          sessionId: sessionId,
        );
        return Right(entry.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> recordFinalLeaderboard(
    Leaderboard leaderboard,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final leaderboardModel = LeaderboardModel.fromEntity(leaderboard);
        await remoteDataSource.recordFinalLeaderboard(leaderboardModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Leaderboard>>> getPlayerHistory(
    String playerId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final leaderboards = await remoteDataSource.getPlayerHistory(playerId);
        return Right(leaderboards.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearLeaderboard(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.clearLeaderboard(sessionId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
