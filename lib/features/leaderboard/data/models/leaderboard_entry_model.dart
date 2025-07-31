import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/leaderboard_entry.dart';

part 'leaderboard_entry_model.freezed.dart';
part 'leaderboard_entry_model.g.dart';

@freezed
class LeaderboardEntryModel with _$LeaderboardEntryModel {
  const factory LeaderboardEntryModel({
    required String playerId,
    required String playerName,
    required int rank,
    required int previousRank,
    required int totalScore,
    required int correctAnswers,
    required int totalQuestions,
    required double averageResponseTime,
    required int currentStreak,
    required int maxStreak,
    required DateTime lastUpdated,
    String? avatarUrl,
  }) = _LeaderboardEntryModel;

  const LeaderboardEntryModel._();

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);

  factory LeaderboardEntryModel.fromEntity(LeaderboardEntry entity) =>
      LeaderboardEntryModel(
        playerId: entity.playerId,
        playerName: entity.playerName,
        rank: entity.rank,
        previousRank: entity.previousRank,
        totalScore: entity.totalScore,
        correctAnswers: entity.correctAnswers,
        totalQuestions: entity.totalQuestions,
        averageResponseTime: entity.averageResponseTime,
        currentStreak: entity.currentStreak,
        maxStreak: entity.maxStreak,
        lastUpdated: entity.lastUpdated,
        avatarUrl: entity.avatarUrl,
      );

  LeaderboardEntry toEntity() => LeaderboardEntry(
    playerId: playerId,
    playerName: playerName,
    rank: rank,
    previousRank: previousRank,
    totalScore: totalScore,
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    averageResponseTime: averageResponseTime,
    currentStreak: currentStreak,
    maxStreak: maxStreak,
    lastUpdated: lastUpdated,
    avatarUrl: avatarUrl,
  );
}
