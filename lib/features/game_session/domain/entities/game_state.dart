import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';

part 'game_state.freezed.dart';

/// Game state entity for tracking current game progress
/// Represents the real-time state of a game session
@freezed
class GameState with _$GameState {
  const factory GameState({
    required String sessionId,
    required Question currentQuestion,
    required int currentQuestionIndex,
    required DateTime questionStartTime,
    required Map<String, PlayerAnswer> playerAnswers,
    required GamePhase phase,
    DateTime? phaseEndTime,
    Map<String, int>? answerCounts, // For answer distribution display
  }) = _GameState;

  const GameState._();

  /// Check if time is up for current question
  bool get isTimeUp {
    if (phaseEndTime == null) return false;
    return DateTime.now().isAfter(phaseEndTime!);
  }

  /// Get remaining time in seconds
  int get remainingSeconds {
    if (phaseEndTime == null) return 0;
    final remaining = phaseEndTime!.difference(DateTime.now());
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  /// Check if all players have answered
  bool hasAllPlayersAnswered(int totalPlayers) {
    return playerAnswers.length >= totalPlayers;
  }

  /// Get player's answer for current question
  PlayerAnswer? getPlayerAnswer(String playerId) {
    return playerAnswers[playerId];
  }

  /// Check if player has answered
  bool hasPlayerAnswered(String playerId) {
    return playerAnswers.containsKey(playerId);
  }

  /// Calculate answer distribution percentages
  Map<int, double> getAnswerDistribution() {
    if (playerAnswers.isEmpty) return {};
    
    final distribution = <int, int>{};
    for (final answer in playerAnswers.values) {
      distribution[answer.selectedOption] = 
          (distribution[answer.selectedOption] ?? 0) + 1;
    }

    final total = playerAnswers.length;
    return distribution.map(
      (option, count) => MapEntry(option, (count / total) * 100),
    );
  }
}

/// Player answer entity for tracking individual responses
@freezed
class PlayerAnswer with _$PlayerAnswer {
  const factory PlayerAnswer({
    required String playerId,
    required int selectedOption,
    required DateTime answeredAt,
    required int responseTimeMs,
    required bool isCorrect,
    required int pointsEarned,
  }) = _PlayerAnswer;

  const PlayerAnswer._();

  /// Check if answer was fast (within first 25% of time limit)
  bool get isFastAnswer {
    final quarterTime = (responseTimeMs / 4).round();
    return responseTimeMs <= quarterTime;
  }

  /// Calculate speed bonus percentage (0-100)
  double get speedBonus {
    // Linear decrease from 100% at 0ms to 0% at time limit
    return (1 - (responseTimeMs / 1000 / 30)) * 100; // Assuming 30s max
  }
}

/// Game phase enum for state management
enum GamePhase {
  waitingToStart,
  questionDisplay,
  questionActive,
  answerReveal,
  leaderboardDisplay,
  gameCompleted;

  String get displayName {
    switch (this) {
      case GamePhase.waitingToStart:
        return 'Waiting to Start';
      case GamePhase.questionDisplay:
        return 'Get Ready!';
      case GamePhase.questionActive:
        return 'Answer Now!';
      case GamePhase.answerReveal:
        return 'Answer Reveal';
      case GamePhase.leaderboardDisplay:
        return 'Leaderboard';
      case GamePhase.gameCompleted:
        return 'Game Over';
    }
  }

  /// Duration for each phase in seconds
  int get phaseDuration {
    switch (this) {
      case GamePhase.waitingToStart:
        return 0; // Indefinite
      case GamePhase.questionDisplay:
        return 5; // 5 seconds to read question
      case GamePhase.questionActive:
        return 30; // Configured per question
      case GamePhase.answerReveal:
        return 7; // 7 seconds to show correct answer
      case GamePhase.leaderboardDisplay:
        return 10; // 10 seconds for leaderboard
      case GamePhase.gameCompleted:
        return 0; // Indefinite
    }
  }

  bool get allowsAnswerSubmission => this == GamePhase.questionActive;
  bool get showsResults => this == GamePhase.answerReveal || this == GamePhase.leaderboardDisplay;
}

/// Game event entity for tracking game progression
@freezed
class GameEvent with _$GameEvent {
  const factory GameEvent.phaseChanged({
    required GamePhase newPhase,
    required DateTime timestamp,
  }) = PhaseChangedEvent;

  const factory GameEvent.playerAnswered({
    required String playerId,
    required int selectedOption,
    required DateTime timestamp,
  }) = PlayerAnsweredEvent;

  const factory GameEvent.playerJoined({
    required String playerId,
    required String playerName,
    required DateTime timestamp,
  }) = PlayerJoinedEvent;

  const factory GameEvent.playerLeft({
    required String playerId,
    required DateTime timestamp,
  }) = PlayerLeftEvent;

  const factory GameEvent.gameStarted({
    required DateTime timestamp,
  }) = GameStartedEvent;

  const factory GameEvent.gameCompleted({
    required DateTime timestamp,
  }) = GameCompletedEvent;
}