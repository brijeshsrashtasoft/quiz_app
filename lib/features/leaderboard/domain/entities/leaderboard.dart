import 'package:freezed_annotation/freezed_annotation.dart';
import 'leaderboard_entry.dart';

part 'leaderboard.freezed.dart';

@freezed
class Leaderboard with _$Leaderboard {
  const factory Leaderboard({
    required String sessionId,
    required String quizId,
    required List<LeaderboardEntry> entries,
    required DateTime lastUpdated,
    required LeaderboardType type,
    required int totalPlayers,
  }) = _Leaderboard;

  const Leaderboard._();

  List<LeaderboardEntry> get topThree => entries.take(3).toList();

  LeaderboardEntry? getPlayerEntry(String playerId) => entries.firstWhere(
    (entry) => entry.playerId == playerId,
    orElse: () => throw StateError('Player not found'),
  );
}

enum LeaderboardType { live, finalResult, historical }
