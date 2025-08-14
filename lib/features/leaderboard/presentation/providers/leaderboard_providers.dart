import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
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
// NetworkInfoImpl is available via network_info.dart import

final leaderboardRemoteDataSourceProvider =
    Provider<LeaderboardRemoteDataSource>((ref) {
      return LeaderboardRemoteDataSourceImpl(
        firestore: FirebaseFirestore.instance,
      );
    });

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepositoryImpl(
    remoteDataSource: ref.watch(leaderboardRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final calculateScoreUseCaseProvider = Provider<CalculateScore>((ref) {
  return CalculateScore();
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

final getHistoricalLeaderboardUseCaseProvider =
    Provider<GetHistoricalLeaderboard>((ref) {
      return GetHistoricalLeaderboard(ref.watch(leaderboardRepositoryProvider));
    });

final currentPlayerIdProvider = StateProvider<String?>((ref) => null);

final currentPlayerStreakProvider = StateProvider<int>((ref) => 0);

final liveLeaderboardStreamProvider =
    StreamProvider.family<Result<Leaderboard>, String>((ref, sessionId) {
      final watchLeaderboard = ref.watch(watchLeaderboardUseCaseProvider);
      return watchLeaderboard(WatchLeaderboardParams(sessionId: sessionId));
    });

final finalLeaderboardProvider =
    FutureProvider.family<Result<Leaderboard>, String>((ref, sessionId) async {
      final getLeaderboard = ref.watch(getLeaderboardUseCaseProvider);
      return await getLeaderboard(GetLeaderboardParams(sessionId: sessionId));
    });

final historicalLeaderboardProvider =
    FutureProvider.family<Result<List<LeaderboardEntry>>, String>((
      ref,
      quizId,
    ) async {
      final getHistoricalLeaderboard = ref.watch(
        getHistoricalLeaderboardUseCaseProvider,
      );
      return await getHistoricalLeaderboard(
        GetHistoricalLeaderboardParams(quizId: quizId, limit: 100),
      );
    });

final calculateScoreProvider =
    Provider<Future<Result<ScoreEntity>> Function(CalculateScoreParams)>((ref) {
      final calculateScore = ref.watch(calculateScoreUseCaseProvider);
      return (params) => calculateScore(params);
    });

final updateScoreProvider =
    Provider<Future<Result<void>> Function(String, ScoreEntity)>((ref) {
      final updateRank = ref.watch(updateRankUseCaseProvider);
      return (sessionId, score) =>
          updateRank(UpdateRankParams(sessionId: sessionId, score: score));
    });

final playerRankProvider =
    Provider.family<int?, (String sessionId, String playerId)>((ref, params) {
      final leaderboardAsync = ref.watch(
        liveLeaderboardStreamProvider(params.$1),
      );

      return leaderboardAsync.when(
        data: (result) => result.when(
          success: (leaderboard) {
            try {
              final entry = leaderboard.getPlayerEntry(params.$2);
              return entry?.rank;
            } catch (_) {
              return null;
            }
          },
          failure: (_) => null,
        ),
        loading: () => null,
        error: (_, __) => null,
      );
    });

final topThreeProvider = Provider.family<List<LeaderboardEntry>, String>((
  ref,
  sessionId,
) {
  final leaderboardAsync = ref.watch(liveLeaderboardStreamProvider(sessionId));

  return leaderboardAsync.when(
    data: (result) => result.when(
      success: (leaderboard) => leaderboard.topThree,
      failure: (_) => <LeaderboardEntry>[],
    ),
    loading: () => <LeaderboardEntry>[],
    error: (_, __) => <LeaderboardEntry>[],
  );
});
