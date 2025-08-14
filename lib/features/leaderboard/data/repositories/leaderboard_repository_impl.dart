import 'dart:async';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
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
  Stream<Result<Leaderboard>> watchLeaderboard(String sessionId) async* {
    if (await networkInfo.isConnected) {
      try {
        await for (final leaderboardModel in remoteDataSource.watchLeaderboard(
          sessionId,
        )) {
          yield Result.success(leaderboardModel.toEntity());
        }
      } on ServerException catch (e) {
        yield Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        yield Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      yield Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<void>> updateScore(String sessionId, ScoreEntity score) async {
    if (await networkInfo.isConnected) {
      try {
        final scoreModel = ScoreModel.fromEntity(score);
        await remoteDataSource.updateScore(sessionId, scoreModel);
        return const Result.success(null);
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<Leaderboard>> getLeaderboard(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final leaderboardModel = await remoteDataSource.getLeaderboard(
          sessionId,
        );
        return Result.success(leaderboardModel.toEntity());
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<List<LeaderboardEntry>>> getHistoricalLeaderboard({
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
        return Result.success(entries.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<LeaderboardEntry>> getPlayerStats({
    required String playerId,
    required String sessionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final entry = await remoteDataSource.getPlayerStats(
          playerId: playerId,
          sessionId: sessionId,
        );
        return Result.success(entry.toEntity());
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<void>> recordFinalLeaderboard(Leaderboard leaderboard) async {
    if (await networkInfo.isConnected) {
      try {
        final leaderboardModel = LeaderboardModel.fromEntity(leaderboard);
        await remoteDataSource.recordFinalLeaderboard(leaderboardModel);
        return const Result.success(null);
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<List<Leaderboard>>> getPlayerHistory(String playerId) async {
    if (await networkInfo.isConnected) {
      try {
        final leaderboards = await remoteDataSource.getPlayerHistory(playerId);
        return Result.success(leaderboards.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Result<void>> clearLeaderboard(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.clearLeaderboard(sessionId);
        return const Result.success(null);
      } on ServerException catch (e) {
        return Result.failure(Failure.serverFailure(message: e.message));
      } catch (e) {
        return Result.failure(Failure.serverFailure(message: e.toString()));
      }
    } else {
      return Result.failure(
        const Failure.networkFailure(message: 'No internet connection'),
      );
    }
  }
}
