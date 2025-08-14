import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/score_entity.dart';
import '../entities/score_multiplier.dart';

class CalculateScore extends BaseUseCase<ScoreEntity, CalculateScoreParams> {
  CalculateScore();

  @override
  Future<Result<ScoreEntity>> call(CalculateScoreParams params) async {
    try {
      final multiplier =
          params.multiplier ??
          const ScoreMultiplier(
            speedMultiplier: 1.0,
            streakMultiplier: 1.0,
            accuracyMultiplier: 1.0,
            basePoints: ScoreMultiplier.baseQuestionPoints,
          );

      final totalScore = multiplier.calculateTotalScore(
        isCorrect: params.isCorrect,
        responseTime: params.responseTime,
        questionDuration: params.questionDuration,
        currentStreak: params.currentStreak,
      );

      final speedBonus = params.isCorrect
          ? multiplier.calculateSpeedBonus(
              params.responseTime,
              params.questionDuration,
            )
          : 0;

      final streakBonus = params.isCorrect
          ? multiplier.calculateStreakBonus(params.currentStreak)
          : 0;

      final score = ScoreEntity(
        playerId: params.playerId,
        playerName: params.playerName,
        basePoints: params.isCorrect ? multiplier.basePoints : 0,
        speedBonus: speedBonus,
        streakBonus: streakBonus,
        totalScore: totalScore,
        timestamp: DateTime.now(),
        questionIndex: params.questionIndex,
        responseTime: params.responseTime,
        isCorrect: params.isCorrect,
      );

      return Result.success(score);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }
}

class CalculateScoreParams extends BaseUseCaseParams {
  final String playerId;
  final String playerName;
  final bool isCorrect;
  final Duration responseTime;
  final Duration questionDuration;
  final int currentStreak;
  final int questionIndex;
  final ScoreMultiplier? multiplier;

  const CalculateScoreParams({
    required this.playerId,
    required this.playerName,
    required this.isCorrect,
    required this.responseTime,
    required this.questionDuration,
    required this.currentStreak,
    required this.questionIndex,
    this.multiplier,
  });

  List<Object?> get props => [
    playerId,
    playerName,
    isCorrect,
    responseTime,
    questionDuration,
    currentStreak,
    questionIndex,
    multiplier,
  ];
}
