import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/buttons/answer_button.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/quiz/countdown_timer.dart';
import '../../../../shared/widgets/quiz/particle_effects.dart';
import '../../../../shared/widgets/quiz/score_counter.dart';
import '../../../../shared/widgets/quiz/lobby_avatar.dart';
import '../../../../shared/widgets/quiz/question_display.dart';
import '../../../../shared/widgets/quiz/loading_animations.dart';
import '../../../../shared/widgets/primitives/shake_widget.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../providers/ui_theme_providers.dart';

/// Comprehensive UI Components Demo Page
/// Showcases all Kahoot-style components in one scrollable view
class AllComponentsDemoPage extends ConsumerStatefulWidget {
  const AllComponentsDemoPage({super.key});

  @override
  ConsumerState<AllComponentsDemoPage> createState() =>
      _AllComponentsDemoPageState();
}

class _AllComponentsDemoPageState extends ConsumerState<AllComponentsDemoPage> {
  bool _showParticles = false;
  bool _shakeWidget = false;
  int _countdownSeconds = 30;
  int _score = 0;
  bool _isHighScore = false;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(currentUIThemeProvider);
    final isDarkMode = currentTheme?.isDarkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Components Demo'),
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              ref.read(uiThemeNotifierProvider.notifier).toggleDarkMode();
            },
          ),
          const SizedBox(width: AppSpacing.spacingM),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Answer Buttons'),
                _buildAnswerButtonsSection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Animations & Effects'),
                _buildAnimationsSection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Timer Components'),
                _buildTimerSection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Score Display'),
                _buildScoreSection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Question Display'),
                _buildQuestionSection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Lobby & Avatars'),
                _buildLobbySection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Loading Animations'),
                _buildLoadingSection(),

                const SizedBox(height: AppSpacing.spacingXL),
                _buildSectionTitle('Primary Buttons'),
                _buildPrimaryButtonsSection(),
              ],
            ),
          ),

          // Particle effects overlay
          if (_showParticles)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiParticles(
                  isActive: _showParticles,
                  onComplete: () {
                    setState(() {
                      _showParticles = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.sectionHeader);
  }

  Widget _buildAnswerButtonsSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        AnswerButton(
          text: 'Triangle Answer - Coral Red',
          shape: AnswerShape.triangle,
          onPressed: () {},
        ),
        AnswerButton(
          text: 'Diamond Answer - Mint Green',
          shape: AnswerShape.diamond,
          onPressed: () {},
        ),
        AnswerButton(
          text: 'Circle Answer - Warm Yellow',
          shape: AnswerShape.circle,
          onPressed: () {},
        ),
        AnswerButton(
          text: 'Square Answer - Turquoise',
          shape: AnswerShape.square,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.spacingL),
        Text('Selected State:', style: AppTextStyles.bodyText),
        AnswerButton(
          text: 'Selected Answer',
          shape: AnswerShape.triangle,
          isSelected: true,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.spacingL),
        Text('Result States:', style: AppTextStyles.bodyText),
        AnswerButton(
          text: 'Correct Answer',
          shape: AnswerShape.circle,
          isCorrect: true,
          showResult: true,
          onPressed: null,
        ),
        AnswerButton(
          text: 'Incorrect Answer',
          shape: AnswerShape.square,
          isIncorrect: true,
          showResult: true,
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildAnimationsSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        ShakeWidget(
          isShaking: _shakeWidget,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            decoration: BoxDecoration(
              color: AppColors.coralRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Shake Animation Demo',
              style: AppTextStyles.buttonText.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _shakeWidget = true;
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    _shakeWidget = false;
                  });
                });
              },
              child: const Text('Trigger Shake'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showParticles = true;
                });
              },
              child: const Text('Show Confetti'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CountdownTimer(
              totalSeconds: 30,
              currentSeconds: _countdownSeconds,
              isWarning: _countdownSeconds <= 5,
            ),
            MiniCountdownTimer(
              totalSeconds: 30,
              currentSeconds: _countdownSeconds,
              isWarning: _countdownSeconds <= 5,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (_countdownSeconds > 0) _countdownSeconds--;
                });
              },
              icon: const Icon(Icons.remove),
            ),
            Text('$_countdownSeconds seconds', style: AppTextStyles.bodyText),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_countdownSeconds < 30) _countdownSeconds++;
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        ScoreCounter(
          currentScore: _score,
          previousScore: _score > 0 ? _score - 100 : 0,
          isHighScore: _isHighScore,
          label: 'Your Score',
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CompactScoreCounter(score: _score, isHighScore: _isHighScore),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _score += 100;
                });
              },
              child: const Text('+100 Points'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isHighScore = !_isHighScore;
                });
              },
              child: Text(_isHighScore ? 'Normal Score' : 'High Score'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingL),
        LeaderboardScoreDisplay(
          rank: 1,
          score: 2500,
          playerName: 'Player One',
          isCurrentPlayer: true,
        ),
        const SizedBox(height: AppSpacing.spacingS),
        const LeaderboardScoreDisplay(
          rank: 2,
          score: 2000,
          playerName: 'Player Two',
        ),
        const SizedBox(height: AppSpacing.spacingS),
        const LeaderboardScoreDisplay(
          rank: 3,
          score: 1500,
          playerName: 'Player Three',
        ),
      ],
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        const QuestionDisplay(
          questionText: 'What is the capital of France?',
          questionNumber: 1,
          totalQuestions: 10,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        const QuestionDisplay(
          questionText: 'Which planet is known as the Red Planet?',
          questionNumber: 5,
          totalQuestions: 10,
          imageUrl: null,
        ),
      ],
    );
  }

  Widget _buildLobbySection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        Wrap(
          spacing: AppSpacing.spacingM,
          runSpacing: AppSpacing.spacingM,
          children: const [
            LobbyAvatar(
              playerName: 'Alice',
              customColor: AppColors.vibrantPurple,
              isReady: true,
            ),
            LobbyAvatar(
              playerName: 'Bob',
              customColor: AppColors.turquoise,
              isReady: false,
            ),
            LobbyAvatar(
              playerName: 'Charlie',
              customColor: AppColors.mintGreen,
              isReady: true,
            ),
            LobbyAvatar(
              playerName: 'Diana',
              customColor: AppColors.warmYellow,
              isReady: false,
              isHost: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LoadingAnimations(type: LoadingType.spinner, size: 48),
            LoadingAnimations(type: LoadingType.bounce, size: 48),
            LoadingAnimations(type: LoadingType.pulse, size: 48),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingL),
        const LoadingAnimations(
          type: LoadingType.wave,
          message: 'Preparing your quiz...',
        ),
        const SizedBox(height: AppSpacing.spacingL),
        const QuizLoadingOverlay(
          isVisible: true,
          message: 'Loading next question...',
        ),
      ],
    );
  }

  Widget _buildPrimaryButtonsSection() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        PrimaryButton(
          text: 'Start Game',
          onPressed: () {},
          icon: Icons.play_arrow,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        PrimaryButton(
          text: 'Join Quiz',
          onPressed: () {},
          backgroundColor: AppColors.turquoise,
          icon: Icons.group_add,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        PrimaryButton(
          text: 'Create Quiz',
          onPressed: () {},
          backgroundColor: AppColors.mintGreen,
          icon: Icons.add_circle,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        const PrimaryButton(
          text: 'Loading...',
          onPressed: null,
          isLoading: true,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        const PrimaryButton(text: 'Disabled', onPressed: null),
      ],
    );
  }
}
