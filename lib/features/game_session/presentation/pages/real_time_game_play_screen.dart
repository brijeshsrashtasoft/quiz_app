import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/feedback/loading_indicators.dart';
import '../../../../shared/widgets/primitives/app_card.dart';
import '../widgets/question_display.dart';
import '../widgets/answer_selection_grid.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/score_display.dart';
import '../widgets/leaderboard_preview.dart';
import '../providers/game_play_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/submit_answer.dart';

/// Real-time game play screen with live quiz data and synchronization
/// Implements Phase 2C game mechanics using Clean Architecture
class RealTimeGamePlayScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const RealTimeGamePlayScreen({super.key, required this.sessionId});

  @override
  ConsumerState<RealTimeGamePlayScreen> createState() =>
      _RealTimeGamePlayScreenState();
}

class _RealTimeGamePlayScreenState extends ConsumerState<RealTimeGamePlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _questionTransitionController;
  late AnimationController _answerRevealController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _questionTransitionController = AnimationController(
      duration: AppAnimations.newQuestionDuration,
      vsync: this,
    );

    _answerRevealController = AnimationController(
      duration: AppAnimations.correctAnswerDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _questionTransitionController,
        curve: AppAnimations.newQuestionCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionTransitionController,
        curve: AppAnimations.easeIn,
      ),
    );

    _questionTransitionController.forward();
  }

  @override
  void dispose() {
    _questionTransitionController.dispose();
    _answerRevealController.dispose();
    super.dispose();
  }

  Future<void> _handleAnswerSelected(int selectedOption) async {
    final notifier = ref.read(
      gamePlayStateNotifierProvider(widget.sessionId).notifier,
    );

    if (!notifier.hasSubmittedAnswer) {
      await notifier.submitAnswer(selectedOption);
      _answerRevealController.forward();
    }
  }

  Future<void> _handleNextQuestion() async {
    final notifier = ref.read(
      gamePlayStateNotifierProvider(widget.sessionId).notifier,
    );

    _questionTransitionController.reset();
    _answerRevealController.reset();

    await notifier.nextQuestion();
    _questionTransitionController.forward();
  }

  // Removed unused _handleStartGame method

  @override
  Widget build(BuildContext context) {
    final gamePlayState = ref.watch(
      gamePlayStateNotifierProvider(widget.sessionId),
    );
    final currentUser = ref.watch(currentUserProvider);
    final currentUserScore = ref.watch(
      currentUserScoreProvider(widget.sessionId),
    );

    return PageLayout(
      title: _getPageTitle(gamePlayState),
      actions: [
        // Score display
        currentUserScore.when(
          data: (score) => ScoreDisplay(score: score),
          loading: () => const LoadingSpinner(),
          error: (_, __) => ScoreDisplay(score: 0),
        ),
        const SizedBox(width: AppSpacing.spacingM),
        // Connection status
        ConnectionStatusIndicator(isConnected: true, onReconnect: () {}),
      ],
      body: gamePlayState.isLoading
          ? _buildLoadingView()
          : gamePlayState.isPlaying
          ? _buildGamePlayView(gamePlayState.gameState!, currentUser?.id)
          : gamePlayState.isSubmittingAnswer
          ? _buildSubmittingView()
          : gamePlayState.hasSubmittedAnswer
          ? _buildAnswerResultView(gamePlayState.answerResult!)
          : gamePlayState.isGameEnded
          ? _buildGameEndedView()
          : gamePlayState.hasError
          ? _buildErrorView(gamePlayState.errorMessage!)
          : _buildLoadingView(),
    );
  }

  String _getPageTitle(GamePlayState state) {
    final notifier = ref.read(
      gamePlayStateNotifierProvider(widget.sessionId).notifier,
    );

    if (notifier.isHost) {
      return 'Hosting Game';
    }

    if (state.isLoading) return 'Loading Game...';
    if (state.isPlaying) return 'Playing Quiz';
    if (state.isSubmittingAnswer) return 'Submitting Answer...';
    if (state.hasSubmittedAnswer) return 'Answer Submitted';
    if (state.isGameEnded) return 'Game Complete';
    if (state.hasError) return 'Game Error';
    return 'Unknown State';
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingSpinner(),
          SizedBox(height: AppSpacing.spacingL),
          Text('Loading game data...', style: AppTextStyles.bodyText),
        ],
      ),
    );
  }

  Widget _buildGamePlayView(GameState gameState, String? currentUserId) {
    final notifier = ref.read(
      gamePlayStateNotifierProvider(widget.sessionId).notifier,
    );
    final isHost = notifier.isHost;

    return AnimatedBuilder(
      animation: _questionTransitionController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Timer and progress
                _buildTimerSection(gameState),

                const SizedBox(height: AppSpacing.spacingL),

                // Question display
                Expanded(
                  flex: 3,
                  child: QuestionDisplay(
                    question: gameState.currentQuestion,
                    questionNumber: gameState.currentQuestionIndex + 1,
                    totalQuestions: 10, // TODO: Get from quiz
                    timeLimit: Duration(
                      seconds: gameState.currentQuestion.questionTimeLimit,
                    ),
                    onTimeUp: () {
                      if (!notifier.hasSubmittedAnswer && !isHost) {
                        _handleAnswerSelected(-1); // No answer submitted
                      }
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingL),

                // Answer grid or host controls
                Expanded(
                  flex: 2,
                  child: isHost
                      ? _buildHostControls(gameState)
                      : _buildPlayerAnswerGrid(gameState),
                ),

                const SizedBox(height: AppSpacing.spacingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerSection(GameState gameState) {
    return Container(
      padding: AppSpacing.allM,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Phase indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.vibrantPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusS),
            ),
            child: Text(
              gameState.phase.displayName,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.vibrantPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Question progress
          Text(
            'Question ${gameState.currentQuestionIndex + 1}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAnswerGrid(GameState gameState) {
    final notifier = ref.read(
      gamePlayStateNotifierProvider(widget.sessionId).notifier,
    );

    if (notifier.hasSubmittedAnswer) {
      return _buildWaitingForOthers();
    }

    return AnswerSelectionGrid(
      answers: gameState.currentQuestion.options,
      selectedIndex: null,
      showResults: false,
      correctIndex: null,
      onAnswerSelected: _handleAnswerSelected,
      revealController: _answerRevealController,
    );
  }

  Widget _buildHostControls(GameState gameState) {
    return Column(
      children: [
        // Player progress indicator
        _buildPlayerProgressIndicator(gameState),

        const SizedBox(height: AppSpacing.spacingL),

        // Answer statistics
        Expanded(child: _buildAnswerStatistics(gameState)),

        const SizedBox(height: AppSpacing.spacingL),

        // Next question button
        ElevatedButton(
          onPressed: _handleNextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vibrantPurple,
            foregroundColor: AppColors.pureWhite,
            padding: AppSpacing.allM,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
          ),
          child: const Text('Next Question'),
        ),
      ],
    );
  }

  Widget _buildPlayerProgressIndicator(GameState gameState) {
    return AppCard(
      padding: AppSpacing.allM,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Players Answered:', style: AppTextStyles.bodyMedium),
          Text(
            '${gameState.playerAnswers.length}', // TODO: Get total players
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.turquoise,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerStatistics(GameState gameState) {
    final distribution = gameState.getAnswerDistribution();

    if (distribution.isEmpty) {
      return const Center(
        child: Text('Waiting for answers...', style: AppTextStyles.bodyText),
      );
    }

    return ListView.builder(
      itemCount: gameState.currentQuestion.options.length,
      itemBuilder: (context, index) {
        final option = gameState.currentQuestion.options[index];
        final percentage = distribution[index] ?? 0;
        final isCorrect = index == gameState.currentQuestion.correctAnswerIndex;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
          padding: AppSpacing.allM,
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.turquoise.withValues(alpha: 0.1)
                : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            border: Border.all(
              color: isCorrect ? AppColors.turquoise : AppColors.lightGray,
              width: isCorrect ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? AppColors.turquoise : AppColors.charcoal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaitingForOthers() {
    return AppCard(
      padding: AppSpacing.allXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingSpinner(),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Answer Submitted!',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.turquoise,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Waiting for other players...',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingSpinner(),
          SizedBox(height: AppSpacing.spacingL),
          Text('Submitting your answer...', style: AppTextStyles.bodyText),
        ],
      ),
    );
  }

  Widget _buildAnswerResultView(SubmitAnswerResult result) {
    return Center(
      child: AppCard(
        padding: AppSpacing.allXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.isCorrect ? Icons.check_circle : Icons.cancel,
              color: result.isCorrect
                  ? AppColors.turquoise
                  : AppColors.coralRed,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              result.isCorrect ? 'Correct!' : 'Incorrect',
              style: AppTextStyles.sectionHeader.copyWith(
                color: result.isCorrect
                    ? AppColors.turquoise
                    : AppColors.coralRed,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            if (result.isCorrect) ...[
              Text(
                '+${result.pointsEarned} points',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.turquoise,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
            ],
            Text(
              'Response time: ${result.responseTimeSeconds.toStringAsFixed(1)}s',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameEndedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Final leaderboard
          Expanded(
            child: ref
                .watch(leaderboardProvider(widget.sessionId))
                .when(
                  data: (leaderboard) => LeaderboardPreview(
                    entries: leaderboard,
                    maxVisible: 10,
                    showFinalResults: true,
                  ),
                  loading: () => const LoadingSpinner(),
                  error: (_, __) => Container(
                    padding: AppSpacing.allL,
                    child: const Text(
                      'Failed to load final results',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to detailed results
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantPurple,
                  foregroundColor: AppColors.pureWhite,
                ),
                child: const Text('View Results'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.coralRed, size: 64),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Error',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.coralRed,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            message,
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement retry logic
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
