import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';
import '../../domain/entities/game_session_entity.dart';
import '../providers/session_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../widgets/question_display.dart';
import '../widgets/answer_submission_panel.dart';
import '../widgets/answer_reveal_display.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/leaderboard_preview.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/loading/loading_overlay.dart';
import '../../../../shared/widgets/error/error_widget.dart';

/// Main game play page with responsive layout
/// Handles real-time question display and answer submission
class GamePlayPage extends ConsumerStatefulWidget {
  final String sessionId;
  final String quizId;

  const GamePlayPage({
    super.key,
    required this.sessionId,
    required this.quizId,
  });

  @override
  ConsumerState<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends ConsumerState<GamePlayPage> {
  int _currentQuestionIndex = 0;
  bool _showingAnswerReveal = false;
  Map<String, int> _currentAnswers = {};
  bool _hasAnsweredCurrentQuestion = false;

  @override
  void initState() {
    super.initState();
    // Quiz data is loaded via provider, no need for manual loading
    _syncWithSessionQuestion();
  }

  /// Sync local question index with session current question
  void _syncWithSessionQuestion() {
    final sessionAsync = ref.read(
      optimizedSessionStreamProvider(widget.sessionId),
    );

    sessionAsync.whenData((session) {
      if (session != null &&
          session.currentQuestionIndex != _currentQuestionIndex) {
        setState(() {
          _currentQuestionIndex = session.currentQuestionIndex;
          _showingAnswerReveal = false;
          _currentAnswers.clear();
          _hasAnsweredCurrentQuestion = false;
        });
      }
    });
  }

  void _handleAnswerSubmit(int answerIndex) {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null || _hasAnsweredCurrentQuestion) return;

    final quizAsync = ref.read(quizByIdProvider(widget.quizId));
    if (quizAsync.value == null) return;

    final quiz = quizAsync.value!;
    if (_currentQuestionIndex >= quiz.questions.length) return;

    final currentQuestion = quiz.questions[_currentQuestionIndex];

    // Calculate score based on correct answer
    int score = 0;
    if (currentQuestion is MultipleChoiceQuestion) {
      if (answerIndex == currentQuestion.correctAnswer) {
        score = currentQuestion.questionPoints;
      }
    } else if (currentQuestion is TrueFalseQuestion) {
      if ((answerIndex == 0 && currentQuestion.correctAnswer) ||
          (answerIndex == 1 && !currentQuestion.correctAnswer)) {
        score = currentQuestion.questionPoints;
      }
    }

    setState(() {
      _currentAnswers[userId] = answerIndex;
      _hasAnsweredCurrentQuestion = true;
    });

    // Submit answer to backend with calculated score
    ref
        .read(sessionStateNotifierProvider(widget.sessionId).notifier)
        .updatePlayerScore(score, [answerIndex]);
  }

  void _handleTimeUp() {
    setState(() {
      _showingAnswerReveal = true;
    });

    // Auto-advance after reveal for non-hosts
    final isHost =
        ref.read(userSessionRoleProvider(widget.sessionId)).value ==
        UserSessionRole.host;
    if (!isHost) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  void _nextQuestion() {
    final quizAsync = ref.read(quizByIdProvider(widget.quizId));
    if (quizAsync.value == null) return;

    final quiz = quizAsync.value!;
    final isHost =
        ref.read(userSessionRoleProvider(widget.sessionId)).value ==
        UserSessionRole.host;

    if (!isHost) return; // Only host can advance questions

    if (_currentQuestionIndex < quiz.questions.length - 1) {
      final nextQuestionIndex = _currentQuestionIndex + 1;

      // Update backend first - this will trigger real-time sync for all players
      ref
          .read(sessionStateNotifierProvider(widget.sessionId).notifier)
          .updateCurrentQuestion(nextQuestionIndex);

      // Local state will be updated via real-time listener
    } else {
      // Game finished - navigate to results
      context.go('/game/${widget.sessionId}/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      optimizedSessionStreamProvider(widget.sessionId),
    );
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final connectionState = ref.watch(connectionStateProvider);
    final userRole = ref.watch(userSessionRoleProvider(widget.sessionId));

    // Listen for session question changes for real-time sync
    ref.listen(optimizedSessionStreamProvider(widget.sessionId), (
      previous,
      next,
    ) {
      next.whenData((session) {
        if (session != null &&
            session.currentQuestionIndex != _currentQuestionIndex) {
          setState(() {
            _currentQuestionIndex = session.currentQuestionIndex;
            _showingAnswerReveal = false;
            _currentAnswers.clear();
            _hasAnsweredCurrentQuestion = false;
          });
        }
      });
    });

    return AppScaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: sessionAsync.when(
        data: (session) {
          return quizAsync.when(
            data: (quiz) {
              if (session == null || quiz == null) {
                return Center(
                  child: AppErrorWidget(
                    title: 'Game data not found',
                    message: 'The game session or quiz could not be loaded.',
                    onRetry: () {
                      ref.refresh(
                        optimizedSessionStreamProvider(widget.sessionId),
                      );
                      ref.refresh(quizByIdProvider(widget.quizId));
                    },
                  ),
                );
              }

              return Stack(
                children: [
                  _buildGameContent(
                    session,
                    quiz,
                    userRole.value ?? UserSessionRole.player,
                  ),

                  // Connection status overlay
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: ConnectionStatusIndicator(
                      isConnected:
                          connectionState.value == ConnectionState.active,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: LoadingOverlay(
                child: CircularProgressIndicator(),
                isLoading: true,
              ),
            ),
            error: (error, _) => Center(
              child: AppErrorWidget(
                title: 'Error loading quiz',
                message: error.toString(),
                onRetry: () => ref.refresh(quizByIdProvider(widget.quizId)),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: LoadingOverlay(
            child: CircularProgressIndicator(),
            isLoading: true,
          ),
        ),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Error loading session',
            message: error.toString(),
            onRetry: () =>
                ref.refresh(optimizedSessionStreamProvider(widget.sessionId)),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(
    GameSessionEntity session,
    Quiz quiz,
    UserSessionRole role,
  ) {
    if (_currentQuestionIndex >= quiz.questions.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = quiz.questions[_currentQuestionIndex];
    final isHost = role == UserSessionRole.host;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1200;

        if (isDesktop) {
          return _buildDesktopLayout(session, quiz, currentQuestion, isHost);
        } else if (isTablet) {
          return _buildTabletLayout(session, quiz, currentQuestion, isHost);
        } else {
          return _buildMobileLayout(session, quiz, currentQuestion, isHost);
        }
      },
    );
  }

  Widget _buildMobileLayout(
    GameSessionEntity session,
    Quiz quiz,
    Question currentQuestion,
    bool isHost,
  ) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          children: [
            // Question display
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: QuestionDisplay(
                  question: currentQuestion,
                  questionNumber: _currentQuestionIndex + 1,
                  totalQuestions: quiz.questions.length,
                  timeLimit: Duration(
                    seconds: currentQuestion.questionTimeLimit,
                  ),
                  onTimeUp: _handleTimeUp,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.spacingM),

            // Answer section
            Expanded(
              flex: 3,
              child: _showingAnswerReveal
                  ? AnswerRevealDisplay(
                      question: currentQuestion,
                      players: session.players,
                      playerAnswers: _currentAnswers,
                      onContinue: isHost ? _nextQuestion : null,
                      isHost: isHost,
                    )
                  : AnswerSubmissionPanel(
                      question: currentQuestion,
                      onAnswerSubmit: _hasAnsweredCurrentQuestion
                          ? null
                          : _handleAnswerSubmit,
                      isSubmitted: _hasAnsweredCurrentQuestion,
                      selectedAnswer:
                          _currentAnswers[ref.read(currentUserProvider)?.id ??
                              ''],
                      showCorrectAnswer: false,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    GameSessionEntity session,
    Quiz quiz,
    Question currentQuestion,
    bool isHost,
  ) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingL),
        child: Row(
          children: [
            // Left side - Question
            Expanded(
              flex: 1,
              child: QuestionDisplay(
                question: currentQuestion,
                questionNumber: _currentQuestionIndex + 1,
                totalQuestions: quiz.questions.length,
                timeLimit: Duration(seconds: currentQuestion.questionTimeLimit),
                onTimeUp: _handleTimeUp,
              ),
            ),

            SizedBox(width: AppSpacing.spacingL),

            // Right side - Answers
            Expanded(
              flex: 1,
              child: _showingAnswerReveal
                  ? SingleChildScrollView(
                      child: AnswerRevealDisplay(
                        question: currentQuestion,
                        players: session.players,
                        playerAnswers: _currentAnswers,
                        onContinue: isHost ? _nextQuestion : null,
                        isHost: isHost,
                      ),
                    )
                  : Center(
                      child: AnswerSubmissionPanel(
                        question: currentQuestion,
                        onAnswerSubmit: _hasAnsweredCurrentQuestion
                            ? null
                            : _handleAnswerSubmit,
                        isSubmitted: _hasAnsweredCurrentQuestion,
                        selectedAnswer:
                            _currentAnswers[ref.read(currentUserProvider)?.id ??
                                ''],
                        showCorrectAnswer: false,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    GameSessionEntity session,
    Quiz quiz,
    Question currentQuestion,
    bool isHost,
  ) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingXL),
        child: Row(
          children: [
            // Left sidebar - Leaderboard
            SizedBox(width: 300, child: const LeaderboardPreview(entries: [])),

            SizedBox(width: AppSpacing.spacingXL),

            // Center - Main game content
            Expanded(
              child: Column(
                children: [
                  // Question
                  Expanded(
                    flex: 2,
                    child: QuestionDisplay(
                      question: currentQuestion,
                      questionNumber: _currentQuestionIndex + 1,
                      totalQuestions: quiz.questions.length,
                      timeLimit: Duration(
                        seconds: currentQuestion.questionTimeLimit,
                      ),
                      onTimeUp: _handleTimeUp,
                    ),
                  ),

                  SizedBox(height: AppSpacing.spacingL),

                  // Answers
                  Expanded(
                    flex: 3,
                    child: _showingAnswerReveal
                        ? SingleChildScrollView(
                            child: AnswerRevealDisplay(
                              question: currentQuestion,
                              players: const <String, PlayerEntity>{},
                              playerAnswers: _currentAnswers,
                              onContinue: isHost ? _nextQuestion : null,
                              isHost: isHost,
                            ),
                          )
                        : AnswerSubmissionPanel(
                            question: currentQuestion,
                            onAnswerSubmit: _hasAnsweredCurrentQuestion
                                ? null
                                : _handleAnswerSubmit,
                            isSubmitted: _hasAnsweredCurrentQuestion,
                            selectedAnswer:
                                _currentAnswers[ref
                                        .read(currentUserProvider)
                                        ?.id ??
                                    ''],
                            showCorrectAnswer: false,
                          ),
                  ),
                ],
              ),
            ),

            // Right sidebar - Game info
            if (isHost) ...[
              SizedBox(width: AppSpacing.spacingXL),
              SizedBox(width: 250, child: _buildHostControls(session, quiz)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHostControls(GameSessionEntity session, Quiz quiz) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Host Controls', style: AppTextStyles.sectionSubheader),
            SizedBox(height: AppSpacing.spacingM),

            // Session info
            _buildInfoRow('PIN', session.pin),
            _buildInfoRow('Players', '${session.playerCount}'),
            _buildInfoRow(
              'Question',
              '${_currentQuestionIndex + 1}/${quiz.questions.length}',
            ),

            SizedBox(height: AppSpacing.spacingL),

            // Control buttons
            if (_showingAnswerReveal) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Next Question'),
                ),
              ),
            ],

            SizedBox(height: AppSpacing.spacingM),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // End game
                  context.go('/game/${widget.sessionId}/results');
                },
                icon: const Icon(Icons.stop_rounded),
                label: const Text('End Game'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coralRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
