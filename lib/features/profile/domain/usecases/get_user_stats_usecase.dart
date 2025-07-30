import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';
import '../entities/user_profile_entity.dart';
import '../../../../core/errors/failures.dart';

/// Use case for getting user statistics and achievements
/// Handles stats retrieval and calculation
/// Following CLAUDE.md patterns and performance optimization
class GetUserStatsUseCase extends BaseUseCase<UserStats, GetUserStatsParams> {
  final ProfileRepository profileRepository;

  GetUserStatsUseCase({required this.profileRepository});

  @override
  Future<Result<UserStats>> call(GetUserStatsParams params) async {
    try {
      AppLogger.info(
        'GetUserStatsUseCase',
        'Getting stats for user: ${params.userId}',
      );

      final startTime = DateTime.now();

      // Get user profile with stats
      final profileResult = await profileRepository.getProfile(params.userId);
      if (!profileResult.isSuccess) {
        return Result.failure(profileResult.failureOrNull!);
      }

      final profile = profileResult.dataOrNull!;
      final stats = profile.stats;

      if (stats == null) {
        // Return default stats if none exist
        const defaultStats = UserStats();
        AppLogger.info(
          'GetUserStatsUseCase',
          'No stats found for user: ${params.userId}, returning defaults',
        );
        return Result.success(defaultStats);
      }

      // Calculate enhanced stats if requested
      UserStats enhancedStats = stats;
      if (params.includeCalculatedStats) {
        enhancedStats = _calculateEnhancedStats(stats);
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get User Stats Use Case', duration);
      AppLogger.info(
        'GetUserStatsUseCase',
        'Stats retrieval successful for user: ${params.userId}',
      );

      return Result.success(enhancedStats);
    } catch (e) {
      AppLogger.error('Get user stats failed', e);
      return Result.failure(
        Failure.serverFailure(message: 'Failed to retrieve user statistics'),
      );
    }
  }

  /// Calculate enhanced statistics with derived values
  UserStats _calculateEnhancedStats(UserStats baseStats) {
    // Calculate win rate
    final winRate = baseStats.totalGamesPlayed > 0
        ? (baseStats.totalGamesWon / baseStats.totalGamesPlayed)
        : 0.0;

    // Calculate average points per game
    final avgPointsPerGame = baseStats.totalGamesPlayed > 0
        ? (baseStats.totalPoints / baseStats.totalGamesPlayed)
        : 0.0;

    // Estimate level based on total points
    final level = _calculateUserLevel(baseStats.totalPoints);

    // Calculate points needed for next level
    final nextLevelPoints = _getPointsForLevel(level + 1);
    final pointsToNextLevel = nextLevelPoints - baseStats.totalPoints;

    // Enhanced category stats
    final enhancedCategoryStats = Map<String, int>.from(
      baseStats.categoryStats ?? {},
    );

    // Add calculated fields to category stats for display purposes
    enhancedCategoryStats['win_rate_percentage'] = (winRate * 100).round();
    enhancedCategoryStats['avg_points_per_game'] = avgPointsPerGame.round();
    enhancedCategoryStats['current_level'] = level;
    enhancedCategoryStats['points_to_next_level'] = pointsToNextLevel.round();

    return baseStats.copyWith(
      averageScore: winRate,
      categoryStats: enhancedCategoryStats,
    );
  }

  /// Calculate user level based on total points
  int _calculateUserLevel(int totalPoints) {
    if (totalPoints < 100) return 1;
    if (totalPoints < 500) return 2;
    if (totalPoints < 1500) return 3;
    if (totalPoints < 3000) return 4;
    if (totalPoints < 5000) return 5;
    if (totalPoints < 8000) return 6;
    if (totalPoints < 12000) return 7;
    if (totalPoints < 18000) return 8;
    if (totalPoints < 25000) return 9;
    return 10; // Max level
  }

  /// Get points required for specific level
  int _getPointsForLevel(int level) {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 500;
      case 4:
        return 1500;
      case 5:
        return 3000;
      case 6:
        return 5000;
      case 7:
        return 8000;
      case 8:
        return 12000;
      case 9:
        return 18000;
      case 10:
        return 25000;
      default:
        return 25000; // Max level points
    }
  }
}

/// Parameters for GetUserStatsUseCase
class GetUserStatsParams extends BaseUseCaseParams {
  final String userId;
  final bool includeCalculatedStats;

  const GetUserStatsParams({
    required this.userId,
    this.includeCalculatedStats = false,
  });

  @override
  String toString() =>
      'GetUserStatsParams(userId: $userId, includeCalculatedStats: $includeCalculatedStats)';
}
