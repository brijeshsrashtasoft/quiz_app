import 'package:freezed_annotation/freezed_annotation.dart';

part 'rank_entity.freezed.dart';

/// Rank entity representing a player's position in the leaderboard
/// Following Clean Architecture principles from CLAUDE.md
@freezed
class RankEntity with _$RankEntity {
  const factory RankEntity({
    required String playerId,
    required String playerName,
    required int position,
    required int score,
    required double accuracy,
    @Default(0) int previousPosition,
    @Default(RankChange.none) RankChange change,
    @Default(0) int streakBonus,
    @Default(0) int speedBonus,
    @Default(0) int totalBonus,
  }) = _RankEntity;

  /// Create from map
  factory RankEntity.fromMap(Map<String, dynamic> map) {
    return RankEntity(
      playerId: map['playerId'] ?? '',
      playerName: map['playerName'] ?? '',
      position: map['position'] ?? 0,
      score: map['score'] ?? 0,
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      previousPosition: map['previousPosition'] ?? 0,
      change: RankChange.fromString(map['change'] ?? 'none'),
      streakBonus: map['streakBonus'] ?? 0,
      speedBonus: map['speedBonus'] ?? 0,
      totalBonus: map['totalBonus'] ?? 0,
    );
  }
}

/// Rank change indicator
enum RankChange {
  up,
  down,
  none,
  new_;

  static RankChange fromString(String value) {
    switch (value) {
      case 'up':
        return RankChange.up;
      case 'down':
        return RankChange.down;
      case 'new':
        return RankChange.new_;
      default:
        return RankChange.none;
    }
  }

  String get displayName {
    switch (this) {
      case RankChange.up:
        return 'Up';
      case RankChange.down:
        return 'Down';
      case RankChange.none:
        return 'Same';
      case RankChange.new_:
        return 'New';
    }
  }
}

/// Rank entity extensions
extension RankEntityX on RankEntity {
  /// Check if rank is valid
  bool get isValid {
    return playerId.isNotEmpty &&
        playerName.isNotEmpty &&
        position > 0 &&
        score >= 0 &&
        accuracy >= 0 && 
        accuracy <= 100;
  }

  /// Get rank change value
  int get rankChangeValue {
    if (previousPosition == 0) return 0;
    return previousPosition - position;
  }

  /// Check if player improved position
  bool get improvedPosition => rankChangeValue > 0;

  /// Check if player dropped position
  bool get droppedPosition => rankChangeValue < 0;

  /// Get display position (with suffix)
  String get displayPosition {
    final suffix = _getOrdinalSuffix(position);
    return '$position$suffix';
  }

  /// Get ordinal suffix for position
  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Check if player is in top 3
  bool get isPodiumPosition => position <= 3;

  /// Get total score including bonuses
  int get totalScore => score + totalBonus;

  /// Get formatted accuracy
  String get formattedAccuracy => '${accuracy.toStringAsFixed(1)}%';
}