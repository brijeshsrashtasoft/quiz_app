import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/leaderboard.dart';
import 'leaderboard_entry_model.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

@freezed
class LeaderboardModel with _$LeaderboardModel {
  const factory LeaderboardModel({
    required String sessionId,
    required String quizId,
    required List<LeaderboardEntryModel> entries,
    required DateTime lastUpdated,
    required String type,
    required int totalPlayers,
  }) = _LeaderboardModel;

  const LeaderboardModel._();

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardModelFromJson(json);

  factory LeaderboardModel.fromEntity(Leaderboard entity) => LeaderboardModel(
    sessionId: entity.sessionId,
    quizId: entity.quizId,
    entries: entity.entries
        .map((e) => LeaderboardEntryModel.fromEntity(e))
        .toList(),
    lastUpdated: entity.lastUpdated,
    type: entity.type.name,
    totalPlayers: entity.totalPlayers,
  );

  Leaderboard toEntity() => Leaderboard(
    sessionId: sessionId,
    quizId: quizId,
    entries: entries.map((e) => e.toEntity()).toList(),
    lastUpdated: lastUpdated,
    type: LeaderboardType.values.firstWhere((e) => e.name == type),
    totalPlayers: totalPlayers,
  );

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() => {
    'sessionId': sessionId,
    'quizId': quizId,
    'entries': entries.map((e) => e.toJson()).toList(),
    'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    'type': type,
    'totalPlayers': totalPlayers,
  };

  /// Create from Firestore document
  factory LeaderboardModel.fromFirestore(Map<String, dynamic> data) {
    return LeaderboardModel(
      sessionId: data['sessionId'] ?? '',
      quizId: data['quizId'] ?? '',
      entries: (data['entries'] as List<dynamic>? ?? [])
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        data['lastUpdated'] ?? 0,
      ),
      type: data['type'] ?? 'session',
      totalPlayers: data['totalPlayers'] ?? 0,
    );
  }
}
