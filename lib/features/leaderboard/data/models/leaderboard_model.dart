import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/leaderboard_entity.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

/// Leaderboard model for data layer
/// Following CLAUDE.md patterns and Firestore integration
@freezed
class LeaderboardModel with _$LeaderboardModel {
  const factory LeaderboardModel({
    required String sessionId,
    required List<ScoreModel> scores,
    required DateTime updatedAt,
    @Default(false) bool finalResults,
  }) = _LeaderboardModel;

  /// Create from Firestore document data
  factory LeaderboardModel.fromFirestore(Map<String, dynamic> data) {
    return LeaderboardModel(
      sessionId: data['sessionId'] as String,
      scores: (data['scores'] as List<dynamic>)
          .map((s) => ScoreModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      finalResults: data['finalResults'] as bool? ?? false,
    );
  }

  /// Create from JSON
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardModelFromJson(json);
}

/// Score model for data layer
@freezed
class ScoreModel with _$ScoreModel {
  const factory ScoreModel({
    required String playerId,
    required String playerName,
    required int score,
    required int correctAnswers,
    required int totalAnswers,
    int? rank,
    int? timeTaken,
  }) = _ScoreModel;

  /// Create from Firestore map
  factory ScoreModel.fromMap(Map<String, dynamic> data) {
    return ScoreModel(
      playerId: data['playerId'] as String,
      playerName: data['playerName'] as String,
      score: data['score'] as int,
      correctAnswers: data['correctAnswers'] as int,
      totalAnswers: data['totalAnswers'] as int,
      rank: data['rank'] as int?,
      timeTaken: data['timeTaken'] as int?,
    );
  }

  /// Create from JSON
  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);
}

/// Extensions for model conversions
extension LeaderboardModelX on LeaderboardModel {
  /// Convert to domain entity
  LeaderboardEntity toEntity() {
    return LeaderboardEntity(
      sessionId: sessionId,
      scores: scores.map((s) => s.toEntity()).toList(),
      updatedAt: updatedAt,
      finalResults: finalResults,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'scores': scores.map((s) => s.toFirestore()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'finalResults': finalResults,
    };
  }
}

extension ScoreModelX on ScoreModel {
  /// Convert to domain entity
  ScoreEntity toEntity() {
    return ScoreEntity(
      playerId: playerId,
      playerName: playerName,
      score: score,
      correctAnswers: correctAnswers,
      totalAnswers: totalAnswers,
      rank: rank,
      timeTaken: timeTaken,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'playerId': playerId,
      'playerName': playerName,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
    };

    if (rank != null) {
      data['rank'] = rank;
    }

    if (timeTaken != null) {
      data['timeTaken'] = timeTaken;
    }

    return data;
  }
}

/// Factory extensions for entity to model conversion
extension LeaderboardEntityX on LeaderboardEntity {
  /// Convert to data model
  LeaderboardModel toModel() {
    return LeaderboardModel(
      sessionId: sessionId,
      scores: scores.map((s) => s.toModel()).toList(),
      updatedAt: updatedAt,
      finalResults: finalResults,
    );
  }
}

extension ScoreEntityX on ScoreEntity {
  /// Convert to data model
  ScoreModel toModel() {
    return ScoreModel(
      playerId: playerId,
      playerName: playerName,
      score: score,
      correctAnswers: correctAnswers,
      totalAnswers: totalAnswers,
      rank: rank,
      timeTaken: timeTaken,
    );
  }
}
