import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_session_entity.freezed.dart';

/// Game session entity for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore structure
@freezed
class GameSessionEntity with _$GameSessionEntity {
  const factory GameSessionEntity({
    required String id,
    required String quizId,
    required String hostId,
    required String pin,
    required GameSessionStatus status,
    required Map<String, PlayerEntity> players,
    required int currentQuestionIndex,
    required DateTime createdAt,
    GameSessionSettings? settings,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _GameSessionEntity;
}

/// Player entity within game session
@freezed
class PlayerEntity with _$PlayerEntity {
  const factory PlayerEntity({
    required String name,
    required DateTime joinedAt,
    @Default(0) int score,
    @Default([]) List<int> answers,
    @Default(false) bool isReady,
  }) = _PlayerEntity;
}

/// Game session settings entity
@freezed
class GameSessionSettings with _$GameSessionSettings {
  const factory GameSessionSettings({
    @Default(50) int maxPlayers,
    @Default(true) bool showCorrectAnswers,
    @Default(false) bool shuffleQuestions,
    @Default(true) bool allowReplay,
  }) = _GameSessionSettings;
}

/// Game session status enum
enum GameSessionStatus {
  waiting,
  active,
  completed;

  String get displayName {
    switch (this) {
      case GameSessionStatus.waiting:
        return 'Waiting for Players';
      case GameSessionStatus.active:
        return 'Game in Progress';
      case GameSessionStatus.completed:
        return 'Game Completed';
    }
  }

  bool get canJoin => this == GameSessionStatus.waiting;
  bool get isActive => this == GameSessionStatus.active;
  bool get isCompleted => this == GameSessionStatus.completed;
}

/// Game session entity extensions for business logic
extension GameSessionEntityX on GameSessionEntity {
  /// Check if session is valid
  bool get isValid {
    return pin.length == 6 &&
        RegExp(r'^[0-9]{6}$').hasMatch(pin) &&
        players.length <= (settings?.maxPlayers ?? 50);
  }

  /// Get current player count
  int get playerCount => players.length;

  /// Check if session is full
  bool get isFull => playerCount >= (settings?.maxPlayers ?? 50);

  /// Check if user is host
  bool isHost(String userId) => hostId == userId;

  /// Check if user is player
  bool isPlayer(String userId) => players.containsKey(userId);

  /// Check if user can join
  bool canUserJoin(String userId) {
    return status.canJoin && !isFull && !isPlayer(userId);
  }

  /// Get player by ID
  PlayerEntity? getPlayer(String userId) => players[userId];

  /// Check if all players are ready
  bool get allPlayersReady {
    if (players.isEmpty) return false;
    return players.values.every((player) => player.isReady);
  }

  /// Get session duration
  Duration? get sessionDuration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  /// Check if session has expired (24 hours old)
  bool get hasExpired {
    final now = DateTime.now();
    final hoursSinceCreated = now.difference(createdAt).inHours;
    return hoursSinceCreated >= 24;
  }

  /// Get leaderboard (sorted players by score)
  List<MapEntry<String, PlayerEntity>> get leaderboard {
    final entries = players.entries.toList();
    entries.sort((a, b) => b.value.score.compareTo(a.value.score));
    return entries;
  }

  /// Get top player
  MapEntry<String, PlayerEntity>? get topPlayer {
    if (players.isEmpty) return null;
    return leaderboard.first;
  }
}

/// Player entity extensions
extension PlayerEntityX on PlayerEntity {
  /// Get player's accuracy rate
  double get accuracyRate {
    if (answers.isEmpty) return 0.0;
    // This would need to be calculated based on correct answers
    // which requires quiz data - implement in use case layer
    return 0.0;
  }

  /// Check if player has answered current question
  bool hasAnsweredQuestion(int questionIndex) {
    return answers.length > questionIndex;
  }

  /// Get player's rank based on score
  int getRank(List<PlayerEntity> allPlayers) {
    final sortedPlayers = List<PlayerEntity>.from(allPlayers);
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    return sortedPlayers.indexOf(this) + 1;
  }

  /// Check if player is new (joined recently)
  bool get isNewPlayer {
    final now = DateTime.now();
    final minutesSinceJoined = now.difference(joinedAt).inMinutes;
    return minutesSinceJoined <= 5;
  }
}
