import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/score_entity.dart';
import '../../domain/usecases/calculate_score.dart';
import '../../domain/usecases/get_leaderboard.dart';
import '../../domain/usecases/update_rank.dart';
import '../../domain/usecases/watch_leaderboard.dart';
import '../../domain/usecases/get_historical_leaderboard.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../data/datasources/leaderboard_remote_data_source.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';

final leaderboardRemoteDataSourceProvider = Provider<LeaderboardRemoteDataSource>((ref) {
  return LeaderboardRemoteDataSourceImpl(
    firestore: sl(),
  );
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepositoryImpl(
    remoteDataSource: ref.watch(leaderboardRemoteDataSourceProvider),
    networkInfo: sl(),
  );
});

final calculateScoreUseCaseProvider = Provider<CalculateScore>((ref) {
  return const CalculateScore();
});

final getLeaderboardUseCaseProvider = Provider<GetLeaderboard>((ref) {
  return GetLeaderboard(ref.watch(leaderboardRepositoryProvider));
});

final updateRankUseCaseProvider = Provider<UpdateRank>((ref) {
  return UpdateRank(ref.watch(leaderboardRepositoryProvider));
});

final watchLeaderboardUseCaseProvider = Provider<WatchLeaderboard>((ref) {
  return WatchLeaderboard(ref.watch(leaderboardRepositoryProvider));
});

final getHistoricalLeaderboardUseCaseProvider = Provider<GetHistoricalLeaderboard>((ref) {
  return GetHistoricalLeaderboard(ref.watch(leaderboardRepositoryProvider));
});

final currentPlayerIdProvider = StateProvider<String?>((ref) => null);

final currentPlayerStreakProvider = StateProvider<int>((ref) => 0);

final liveLeaderboardStreamProvider = StreamProvider.family<Either<Failure, Leaderboard>, String>(
  (ref, sessionId) {
    final watchLeaderboard = ref.watch(watchLeaderboardUseCaseProvider);
    return watchLeaderboard(WatchLeaderboardParams(sessionId: sessionId));
  },
);

final finalLeaderboardProvider = FutureProvider.family<Either<Failure, Leaderboard>, String>(
  (ref, sessionId) async {
    final getLeaderboard = ref.watch(getLeaderboardUseCaseProvider);
    return await getLeaderboard(GetLeaderboardParams(sessionId: sessionId));
  },
);

final historicalLeaderboardProvider = FutureProvider.family<Either<Failure, List<LeaderboardEntry>>, String>(
  (ref, quizId) async {
    final getHistoricalLeaderboard = ref.watch(getHistoricalLeaderboardUseCaseProvider);
    return await getHistoricalLeaderboard(
      GetHistoricalLeaderboardParams(
        quizId: quizId,
        limit: 100,
      ),
    );
  },
);

final calculateScoreProvider = Provider<Future<Either<Failure, ScoreEntity>> Function(CalculateScoreParams)>(
  (ref) {
    final calculateScore = ref.watch(calculateScoreUseCaseProvider);
    return (params) => calculateScore(params);
  },
);

final updateScoreProvider = Provider<Future<Either<Failure, void>> Function(String, ScoreEntity)>(
  (ref) {
    final updateRank = ref.watch(updateRankUseCaseProvider);
    return (sessionId, score) => updateRank(UpdateRankParams(sessionId: sessionId, score: score));
  },
);

final playerRankProvider = Provider.family<int?, (String sessionId, String playerId)>(
  (ref, params) {
    final leaderboardAsync = ref.watch(liveLeaderboardStreamProvider(params.$1));
    
    return leaderboardAsync.when(
      data: (either) => either.fold(
        (_) => null,
        (leaderboard) {
          try {
            final entry = leaderboard.getPlayerEntry(params.$2);
            return entry?.rank;
          } catch (_) {
            return null;
          }
        },
      ),
      loading: () => null,
      error: (_, __) => null,
    );
  },
);

final topThreeProvider = Provider.family<List<LeaderboardEntry>, String>(
  (ref, sessionId) {
    final leaderboardAsync = ref.watch(liveLeaderboardStreamProvider(sessionId));
    
    return leaderboardAsync.when(
      data: (either) => either.fold(
        (_) => [],
        (leaderboard) => leaderboard.topThree,
      ),
      loading: () => [],
      error: (_, __) => [],
    );
  },
);