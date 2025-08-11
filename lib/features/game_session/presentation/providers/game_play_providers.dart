import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/submit_answer.dart';
import '../../domain/usecases/submit_answer_realtime.dart';
import '../../domain/usecases/next_question.dart';
import '../../domain/usecases/start_game.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import 'session_providers.dart';

/// Game play providers for Phase 2C implementation
/// Manages real-time game state, question progression, and scoring

/// Submit answer use case provider
final submitAnswerUseCaseProvider = Provider<SubmitAnswer>((ref) {
  final repository = ref.read(gameSessionRepositoryProvider);
  return SubmitAnswer(repository);
});

/// Enhanced submit answer use case with real-time Firebase integration
final submitAnswerRealtimeUseCaseProvider = Provider<SubmitAnswerRealtime>((
  ref,
) {
  final repository = ref.read(gameSessionRepositoryProvider);
  return SubmitAnswerRealtime(repository);
});

/// Next question use case provider
final nextQuestionUseCaseProvider = Provider<NextQuestion>((ref) {
  final sessionRepository = ref.read(gameSessionRepositoryProvider);
  final quizRepository = ref.read(quizRepositoryProvider);
  return NextQuestion(sessionRepository, quizRepository);
});

/// Start game use case provider
final startGameUseCaseProvider = Provider<StartGame>((ref) {
  final repository = ref.read(gameSessionRepositoryProvider);
  return StartGame(repository);
});

/// Current game quiz provider - loads quiz data for active session
final currentGameQuizProvider = FutureProvider.family<Quiz?, String>((
  ref,
  sessionId,
) async {
  final session = await ref.read(gameSessionProvider(sessionId).future);

  if (session == null) {
    AppLogger.error('No session found for game quiz: $sessionId');
    return null;
  }

  AppLogger.firebase('GamePlayProvider', 'Loading quiz: ${session.quizId}');

  final quiz = await ref.read(quizByIdProvider(session.quizId).future);
  return quiz;
});

/// Current question provider - gets the current question being played
final currentQuestionProvider = FutureProvider.family<Question?, String>((
  ref,
  sessionId,
) async {
  final session = await ref.read(gameSessionProvider(sessionId).future);
  final quiz = await ref.read(currentGameQuizProvider(sessionId).future);

  if (session == null || quiz == null) {
    return null;
  }

  if (session.currentQuestionIndex >= quiz.questions.length) {
    return null; // Game completed
  }

  return quiz.questions[session.currentQuestionIndex];
});

/// Game state provider - tracks real-time game state
final gameStateProvider = FutureProvider.family<GameState?, String>((
  ref,
  sessionId,
) async {
  final session = await ref.read(gameSessionProvider(sessionId).future);

  if (session == null) {
    return null;
  }

  final quiz = await ref.read(currentGameQuizProvider(sessionId).future);
  if (quiz == null) {
    return null;
  }

  if (session.currentQuestionIndex >= quiz.questions.length) {
    // Game completed
    return null;
  }

  final currentQuestion = quiz.questions[session.currentQuestionIndex];

  return GameState(
    sessionId: sessionId,
    currentQuestion: currentQuestion,
    currentQuestionIndex: session.currentQuestionIndex,
    questionStartTime: DateTime.now(), // TODO: Store actual start time
    playerAnswers: {}, // TODO: Load current answers
    phase: _getGamePhase(session.status),
  );
});

/// Game state stream provider for real-time updates
final gameStateStreamProvider = StreamProvider.family<GameState?, String>((
  ref,
  sessionId,
) {
  // Watch the session stream and transform it
  ref.listen(gameSessionStreamProvider(sessionId), (previous, next) {
    // This will trigger rebuilds when session changes
  });

  return Stream.fromFuture(ref.watch(gameStateProvider(sessionId).future));
});

/// Helper function to map session status to game phase
GamePhase _getGamePhase(GameSessionStatus status) {
  switch (status) {
    case GameSessionStatus.waiting:
      return GamePhase.waitingToStart;
    case GameSessionStatus.active:
      return GamePhase.questionActive;
    case GameSessionStatus.completed:
      return GamePhase.gameCompleted;
  }
}

/// Game play state notifier for managing game flow
final gamePlayStateNotifierProvider =
    StateNotifierProvider.family<GamePlayStateNotifier, GamePlayState, String>(
      (ref, sessionId) => GamePlayStateNotifier(
        sessionId: sessionId,
        submitAnswerUseCase: ref.read(submitAnswerUseCaseProvider),
        nextQuestionUseCase: ref.read(nextQuestionUseCaseProvider),
        startGameUseCase: ref.read(startGameUseCaseProvider),
        ref: ref,
      ),
    );

/// Game play state notifier implementation
class GamePlayStateNotifier extends StateNotifier<GamePlayState> {
  final String sessionId;
  final SubmitAnswer submitAnswerUseCase;
  final NextQuestion nextQuestionUseCase;
  final StartGame startGameUseCase;
  final Ref ref;

  DateTime? _questionStartTime;
  Question? _currentQuestion;
  bool _hasSubmittedAnswer = false;

  GamePlayStateNotifier({
    required this.sessionId,
    required this.submitAnswerUseCase,
    required this.nextQuestionUseCase,
    required this.startGameUseCase,
    required this.ref,
  }) : super(const GamePlayState.loading()) {
    _initialize();
  }

  void _initialize() {
    // Listen to enhanced real-time game state changes
    ref.listen(realtimeGameStateStreamProvider(sessionId), (previous, next) {
      next.when(
        data: (gameState) {
          if (gameState == null) {
            state = const GamePlayState.gameEnded();
            return;
          }

          _currentQuestion = gameState.currentQuestion;
          _questionStartTime = gameState.questionStartTime;

          // Reset answer submission for new question
          if (previous?.value?.currentQuestionIndex !=
              gameState.currentQuestionIndex) {
            _hasSubmittedAnswer = false;
            AppLogger.firebase(
              'GamePlayNotifier',
              'New question ${gameState.currentQuestionIndex + 1}: ${gameState.currentQuestion.question}',
            );
          }

          state = GamePlayState.playing(gameState);
        },
        loading: () => state = const GamePlayState.loading(),
        error: (error, stack) => state = GamePlayState.error(error.toString()),
      );
    });
  }

  /// Submit answer for current question with real-time Firebase integration
  Future<void> submitAnswer(int selectedOption) async {
    if (_hasSubmittedAnswer) {
      AppLogger.warning('Answer already submitted for current question');
      return;
    }

    if (_currentQuestion == null || _questionStartTime == null) {
      AppLogger.error(
        'No current question data available for answer submission',
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const GamePlayState.error('User not authenticated');
      return;
    }

    state = const GamePlayState.submittingAnswer();

    try {
      // Use enhanced real-time submit answer use case
      final realtimeUseCase = ref.read(submitAnswerRealtimeUseCaseProvider);
      final session = await ref.read(gameSessionProvider(sessionId).future);

      if (session == null) {
        state = const GamePlayState.error('Session not found');
        return;
      }

      final result = await realtimeUseCase.call(
        sessionId: sessionId,
        playerId: currentUser.id,
        playerName: session.getPlayer(currentUser.id)?.name ?? 'Unknown',
        selectedOption: selectedOption,
        currentQuestion: _currentQuestion!,
        questionStartTime: _questionStartTime!,
        questionIndex: session.currentQuestionIndex,
      );

      result.when(
        success: (realtimeResult) {
          _hasSubmittedAnswer = true;

          // Convert to standard answer result for compatibility
          final answerResult = SubmitAnswerResult(
            isCorrect: realtimeResult.isCorrect,
            pointsEarned: realtimeResult.pointsEarned,
            responseTimeMs: realtimeResult.responseTimeMs,
            newTotalScore: realtimeResult.newTotalScore,
            correctAnswer: realtimeResult.correctAnswer,
            playerAnswer: realtimeResult.playerAnswer,
          );

          state = GamePlayState.answerSubmitted(answerResult);

          AppLogger.firebase(
            'GamePlayNotifier',
            'Real-time answer submitted: ${realtimeResult.isCorrect ? "Correct" : "Incorrect"} '
                '+${realtimeResult.pointsEarned} points (Rank #${realtimeResult.rank})',
          );
        },
        failure: (error) {
          AppLogger.error('Failed to submit real-time answer', error);
          state = GamePlayState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error submitting real-time answer', e);
      state = GamePlayState.error('Failed to submit answer: ${e.toString()}');
    }
  }

  /// Advance to next question (host only)
  Future<void> nextQuestion() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const GamePlayState.error('User not authenticated');
      return;
    }

    state = const GamePlayState.loading();

    try {
      final result = await nextQuestionUseCase.call(
        sessionId: sessionId,
        hostId: currentUser.id,
      );

      result.when(
        success: (nextResult) {
          if (nextResult.isGameComplete) {
            state = const GamePlayState.gameEnded();
            AppLogger.firebase('GamePlayNotifier', 'Game completed!');
          } else {
            AppLogger.firebase(
              'GamePlayNotifier',
              'Advanced to question ${nextResult.nextQuestionIndex! + 1}',
            );
            // State will be updated through game state stream
          }
        },
        failure: (error) {
          AppLogger.error('Failed to advance question', error);
          state = GamePlayState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error advancing question', e);
      state = GamePlayState.error(
        'Failed to advance question: ${e.toString()}',
      );
    }
  }

  /// Start the game (host only)
  Future<void> startGame() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const GamePlayState.error('User not authenticated');
      return;
    }

    state = const GamePlayState.loading();

    try {
      final result = await startGameUseCase.call(
        sessionId: sessionId,
        hostId: currentUser.id,
      );

      result.when(
        success: (session) {
          AppLogger.firebase('GamePlayNotifier', 'Game started successfully');
          // State will be updated through game state stream
        },
        failure: (error) {
          AppLogger.error('Failed to start game', error);
          state = GamePlayState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error starting game', e);
      state = GamePlayState.error('Failed to start game: ${e.toString()}');
    }
  }

  /// Check if current user is the host
  bool get isHost {
    final currentUser = ref.read(currentUserProvider);
    final session = ref.read(gameSessionProvider(sessionId)).value;

    if (currentUser == null || session == null) return false;
    return session.isHost(currentUser.id);
  }

  /// Check if user has submitted answer for current question
  bool get hasSubmittedAnswer => _hasSubmittedAnswer;
}

/// Game play state model
sealed class GamePlayState {
  const GamePlayState();

  const factory GamePlayState.loading() = _LoadingGamePlayState;
  const factory GamePlayState.playing(GameState gameState) = _PlayingState;
  const factory GamePlayState.submittingAnswer() = _SubmittingAnswerState;
  const factory GamePlayState.answerSubmitted(SubmitAnswerResult result) =
      _AnswerSubmittedState;
  const factory GamePlayState.gameEnded() = _GameEndedState;
  const factory GamePlayState.error(String message) = _ErrorGamePlayState;
}

class _LoadingGamePlayState extends GamePlayState {
  const _LoadingGamePlayState();
}

class _PlayingState extends GamePlayState {
  final GameState gameState;
  const _PlayingState(this.gameState);
}

class _SubmittingAnswerState extends GamePlayState {
  const _SubmittingAnswerState();
}

class _AnswerSubmittedState extends GamePlayState {
  final SubmitAnswerResult result;
  const _AnswerSubmittedState(this.result);
}

class _GameEndedState extends GamePlayState {
  const _GameEndedState();
}

class _ErrorGamePlayState extends GamePlayState {
  final String message;
  const _ErrorGamePlayState(this.message);
}

/// Extension for game play state
extension GamePlayStateX on GamePlayState {
  bool get isLoading => this is _LoadingGamePlayState;
  bool get isPlaying => this is _PlayingState;
  bool get isSubmittingAnswer => this is _SubmittingAnswerState;
  bool get hasSubmittedAnswer => this is _AnswerSubmittedState;
  bool get isGameEnded => this is _GameEndedState;
  bool get hasError => this is _ErrorGamePlayState;

  GameState? get gameState => switch (this) {
    _PlayingState(gameState: final gameState) => gameState,
    _ => null,
  };

  SubmitAnswerResult? get answerResult => switch (this) {
    _AnswerSubmittedState(result: final result) => result,
    _ => null,
  };

  String? get errorMessage => switch (this) {
    _ErrorGamePlayState(message: final message) => message,
    _ => null,
  };
}

// ===========================================
// REAL-TIME FIREBASE INTEGRATION PROVIDERS
// ===========================================

/// Stream provider for watching real-time question answers
final questionAnswersStreamProvider =
    StreamProvider.family<Map<String, dynamic>?, QuestionAnswersParams>((
      ref,
      params,
    ) {
      final repository = ref.read(gameSessionRepositoryProvider);

      return repository
          .watchQuestionAnswers(params.sessionId, params.questionIndex)
          .map(
            (result) => result.when(
              success: (data) => data,
              failure: (error) {
                AppLogger.error('Question answers stream error', error);
                return null;
              },
            ),
          );
    });

/// Parameters for question answers stream
class QuestionAnswersParams {
  final String sessionId;
  final int questionIndex;

  const QuestionAnswersParams({
    required this.sessionId,
    required this.questionIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAnswersParams &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          questionIndex == other.questionIndex;

  @override
  int get hashCode => sessionId.hashCode ^ questionIndex.hashCode;
}

/// Stream provider for watching game phase updates
final gamePhaseStreamProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, sessionId) {
      final repository = ref.read(gameSessionRepositoryProvider);

      return repository
          .watchGamePhase(sessionId)
          .map(
            (result) => result.when(
              success: (data) => data,
              failure: (error) {
                AppLogger.error('Game phase stream error', error);
                return null;
              },
            ),
          );
    });

/// Provider for getting question statistics
final questionStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>?, QuestionAnswersParams>((
      ref,
      params,
    ) async {
      final repository = ref.read(gameSessionRepositoryProvider);

      final result = await repository.getQuestionStatistics(
        sessionId: params.sessionId,
        questionIndex: params.questionIndex,
      );

      return result.when(
        success: (data) => data,
        failure: (error) {
          AppLogger.error('Failed to get question statistics', error);
          return null;
        },
      );
    });

/// Provider for getting session answers (final results)
final sessionAnswersProvider =
    FutureProvider.family<List<Map<String, dynamic>>?, String>((
      ref,
      sessionId,
    ) async {
      final repository = ref.read(gameSessionRepositoryProvider);

      final result = await repository.getSessionAnswers(sessionId);

      return result.when(
        success: (data) => data,
        failure: (error) {
          AppLogger.error('Failed to get session answers', error);
          return null;
        },
      );
    });

/// Enhanced real-time game state stream provider
final realtimeGameStateStreamProvider = StreamProvider.family<GameState?, String>((
  ref,
  sessionId,
) {
  // Combine session stream with phase stream for comprehensive real-time updates
  final sessionStream = ref.watch(gameSessionStreamProvider(sessionId));
  final phaseStream = ref.watch(gamePhaseStreamProvider(sessionId));

  // Return the game state based on session data
  return sessionStream
      .when(
        data: (session) async* {
          if (session == null) {
            yield null;
            return;
          }

          final quiz = await ref.read(
            currentGameQuizProvider(sessionId).future,
          );
          if (quiz == null ||
              session.currentQuestionIndex >= quiz.questions.length) {
            yield null;
            return;
          }

          final currentQuestion = quiz.questions[session.currentQuestionIndex];

          // Get real-time answer data for current question
          final answersStream = ref.watch(
            questionAnswersStreamProvider(
              QuestionAnswersParams(
                sessionId: sessionId,
                questionIndex: session.currentQuestionIndex,
              ),
            ),
          );

          await for (final answersData in answersStream.when(
            data: (data) => Stream.value(data),
            loading: () => Stream.value(null),
            error: (_, __) => Stream.value(null),
          )) {
            final playerAnswers = <String, PlayerAnswer>{};

            if (answersData?['answers'] != null) {
              final answers = answersData!['answers'] as Map<String, dynamic>;
              for (final entry in answers.entries) {
                final answerData = entry.value as Map<String, dynamic>;
                playerAnswers[entry.key] = PlayerAnswer(
                  playerId: answerData['playerId'] as String,
                  selectedOption: answerData['selectedOption'] as int,
                  answeredAt: (answerData['answeredAt'] as Timestamp).toDate(),
                  responseTimeMs: answerData['responseTimeMs'] as int,
                  isCorrect: answerData['isCorrect'] as bool,
                  pointsEarned: answerData['pointsEarned'] as int,
                );
              }
            }

            yield GameState(
              sessionId: sessionId,
              currentQuestion: currentQuestion,
              currentQuestionIndex: session.currentQuestionIndex,
              questionStartTime: DateTime.now(), // TODO: Get from phase data
              playerAnswers: playerAnswers,
              phase: _getGamePhase(session.status),
              answerCounts: answersData?['answerCounts'] as Map<String, int>?,
            );
          }
        },
        loading: () => const Stream.empty(),
        error: (error, _) => Stream.value(null),
      )
      .asyncExpand((stream) => stream);
});

/// Player score provider - tracks live scores
final playerScoreProvider = FutureProvider.family<int, PlayerScoreParams>((
  ref,
  params,
) async {
  final session = await ref.read(gameSessionProvider(params.sessionId).future);

  if (session == null) return 0;

  final player = session.getPlayer(params.playerId);
  return player?.score ?? 0;
});

/// Player score parameters
class PlayerScoreParams {
  final String sessionId;
  final String playerId;

  const PlayerScoreParams({required this.sessionId, required this.playerId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerScoreParams &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          playerId == other.playerId;

  @override
  int get hashCode => sessionId.hashCode ^ playerId.hashCode;
}

/// Current user score provider
final currentUserScoreProvider = FutureProvider.family<int, String>((
  ref,
  sessionId,
) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) return 0;

  return ref.read(
    playerScoreProvider(
      PlayerScoreParams(sessionId: sessionId, playerId: currentUser.id),
    ).future,
  );
});

/// Leaderboard provider - live ranking of players
final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((
      ref,
      sessionId,
    ) async {
      final session = await ref.read(gameSessionProvider(sessionId).future);

      if (session == null) return [];

      final leaderboard = session.leaderboard;
      return leaderboard.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final playerEntry = entry.value;

        return LeaderboardEntry(
          rank: rank,
          playerId: playerEntry.key,
          playerName: playerEntry.value.name,
          score: playerEntry.value.score,
          answersCorrect: _countCorrectAnswers(playerEntry.value, session),
        );
      }).toList();
    });

/// Helper function to count correct answers
int _countCorrectAnswers(PlayerEntity player, GameSessionEntity session) {
  // This would need quiz data to determine correct answers
  // For now, return 0 - implement fully when quiz data is integrated
  return 0;
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String playerId;
  final String playerName;
  final int score;
  final int answersCorrect;

  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.answersCorrect,
  });

  /// Check if this is the current user
  bool isCurrentUser(String? currentUserId) {
    return currentUserId != null && playerId == currentUserId;
  }

  /// Get rank suffix (1st, 2nd, 3rd, etc.)
  String get rankSuffix {
    if (rank % 100 >= 11 && rank % 100 <= 13) {
      return '${rank}th';
    }
    switch (rank % 10) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }
}
