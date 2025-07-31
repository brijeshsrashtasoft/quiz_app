import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';
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
  Quiz? _quiz;
  int _currentQuestionIndex = 0;
  bool _showingAnswerReveal = false;
  Map<String, int> _currentAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    // TODO: Load quiz data from repository
    // For now, using placeholder data
    setState(() {
      _quiz = Quiz(
        id: widget.quizId,
        title: 'Sample Quiz',
        description: 'Test quiz for game play',
        category: 'General',
        createdBy: 'system',
        questions: [
          Question.multipleChoice(
            id: '1',
            question: 'What is the capital of France?',
            options: ['London', 'Berlin', 'Paris', 'Madrid'],
            correctAnswer: 2,
            timeLimit: 20,
            points: 100,
          ),
          Question.multipleChoice(
            id: '2',
            question: 'Which planet is known as the Red Planet?',
            options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
            correctAnswer: 1,
            timeLimit: 15,
            points: 150,
          ),
        ],
        createdAt: DateTime.now(),
        settings: const GameSessionSettings(),
      );
    });
  }

  void _handleAnswerSubmit(int answerIndex) {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() {
      _currentAnswers[userId] = answerIndex;
    });

    // Submit answer to backend
    ref
        .read(sessionStateNotifierProvider(widget.sessionId).notifier)
        .updatePlayerScore(100, [answerIndex]); // TODO: Calculate actual score
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
    if (_quiz == null) return;

    setState(() {
      if (_currentQuestionIndex < _quiz!.questions.length - 1) {
        _currentQuestionIndex++;
        _showingAnswerReveal = false;
        _currentAnswers.clear();
      } else {
        // Game finished
        context.go('/game/${widget.sessionId}/results');
      }
    });

    // Update backend
    final isHost =
        ref.read(userSessionRoleProvider(widget.sessionId)).value ==
        UserSessionRole.host;
    if (isHost) {
      ref
          .read(sessionStateNotifierProvider(widget.sessionId).notifier)
          .updateCurrentQuestion(_currentQuestionIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      optimizedSessionStreamProvider(widget.sessionId),
    );
    final connectionState = ref.watch(connectionStateProvider);
    final userRole = ref.watch(userSessionRoleProvider(widget.sessionId));

    return AppScaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: sessionAsync.when(
        data: (session) {
          if (session == null || _quiz == null) {
            return Center(
              child: AppErrorWidget(
                title: 'Session not found',
                message: 'The game session could not be loaded.',
                onRetry: () => context.go('/'),
              ),
            );
          }

          return Stack(
            children: [
              _buildGameContent(
                session,
                userRole.value ?? UserSessionRole.player,
              ),

              // Connection status overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: ConnectionStatusIndicator(
                  connectionState:
                      connectionState.value ?? ConnectionState.disconnected,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingOverlay()),
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

  Widget _buildGameContent(GameSessionEntity session, UserSessionRole role) {
    if (_quiz == null || _currentQuestionIndex >= _quiz!.questions.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];
    final isHost = role == UserSessionRole.host;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1200;

        if (isDesktop) {
          return _buildDesktopLayout(session, currentQuestion, isHost);
        } else if (isTablet) {
          return _buildTabletLayout(session, currentQuestion, isHost);
        } else {
          return _buildMobileLayout(session, currentQuestion, isHost);
        }
      },
    );
  }

  Widget _buildMobileLayout(
    GameSessionEntity session,
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
                  totalQuestions: _quiz!.questions.length,
                  timeLimit: Duration(
                    seconds: currentQuestion.questionTimeLimit,
                  ),
                  onTimeUp: _handleTimeUp,
                ),
              ),
            ),

            AppSpacing.verticalSpacingM,

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
                      onAnswerSubmit: _handleAnswerSubmit,
                      isSubmitted: _currentAnswers.containsKey(
                        ref.read(currentUserProvider)?.id,
                      ),
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
                totalQuestions: _quiz!.questions.length,
                timeLimit: Duration(seconds: currentQuestion.questionTimeLimit),
                onTimeUp: _handleTimeUp,
              ),
            ),

            AppSpacing.horizontalSpacingL,

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
                        onAnswerSubmit: _handleAnswerSubmit,
                        isSubmitted: _currentAnswers.containsKey(
                          ref.read(currentUserProvider)?.id,
                        ),
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
    Question currentQuestion,
    bool isHost,
  ) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingXL),
        child: Row(
          children: [
            // Left sidebar - Leaderboard
            SizedBox(
              width: 300,
              child: LeaderboardPreview(
                players: session.players,
                maxPlayersToShow: 10,
              ),
            ),

            AppSpacing.horizontalSpacingXL,

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
                      totalQuestions: _quiz!.questions.length,
                      timeLimit: Duration(
                        seconds: currentQuestion.questionTimeLimit,
                      ),
                      onTimeUp: _handleTimeUp,
                    ),
                  ),

                  AppSpacing.verticalSpacingL,

                  // Answers
                  Expanded(
                    flex: 3,
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
                        : AnswerSubmissionPanel(
                            question: currentQuestion,
                            onAnswerSubmit: _handleAnswerSubmit,
                            isSubmitted: _currentAnswers.containsKey(
                              ref.read(currentUserProvider)?.id,
                            ),
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
              AppSpacing.horizontalSpacingXL,
              SizedBox(width: 250, child: _buildHostControls(session)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHostControls(GameSessionEntity session) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Host Controls', style: AppTextStyles.sectionSubheader),
            AppSpacing.verticalSpacingM,

            // Session info
            _buildInfoRow('PIN', session.pin),
            _buildInfoRow('Players', '${session.playerCount}'),
            _buildInfoRow(
              'Question',
              '${_currentQuestionIndex + 1}/${_quiz!.questions.length}',
            ),

            AppSpacing.verticalSpacingL,

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

            AppSpacing.verticalSpacingM,

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
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.coolGray,
            ),
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
