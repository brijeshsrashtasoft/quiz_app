import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/answer_button.dart';
import '../../../../shared/widgets/quiz/countdown_timer.dart';
import '../../../../shared/widgets/quiz/particle_effects.dart';
import '../../../../shared/widgets/quiz/question_display.dart';
import '../../../../shared/widgets/quiz/loading_animations.dart';
import '../../../../shared/widgets/quiz/lobby_avatar.dart';
import '../../../../shared/widgets/quiz/score_counter.dart';
import '../../../../shared/widgets/primitives/shake_widget.dart';
import '../../../../shared/widgets/primitives/responsive_grid.dart';

/// Demo page showcasing all the quiz UI components
class UIComponentsDemoPage extends ConsumerStatefulWidget {
  const UIComponentsDemoPage({super.key});

  @override
  ConsumerState<UIComponentsDemoPage> createState() => _UIComponentsDemoPageState();
}

class _UIComponentsDemoPageState extends ConsumerState<UIComponentsDemoPage> {
  int _currentScore = 0;
  int _selectedAnswer = -1;
  bool _showResult = false;
  bool _isShaking = false;
  bool _showParticles = false;
  int _timerSeconds = 30;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _isDarkMode ? AppColors.darkBackground : AppColors.offWhite,
        appBar: AppBar(
          title: const Text('UI Components Demo'),
          backgroundColor: AppColors.vibrantPurple,
          foregroundColor: AppColors.pureWhite,
          actions: [
            Switch(
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
              activeColor: AppColors.turquoise,
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: AppSpacing.screenPaddingAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Question Display
                  _buildSectionHeader('Question Display'),
                  QuestionDisplay(
                    questionText: 'What is the capital of France?',
                    questionNumber: 1,
                    totalQuestions: 10,
                    isVisible: true,
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section: Answer Buttons
                  _buildSectionHeader('Answer Buttons'),
                  ShakeWidget(
                    isShaking: _isShaking,
                    onShakeComplete: () => setState(() => _isShaking = false),
                    child: ResponsiveGrid(
                      mobileColumns: 1,
                      tabletColumns: 2,
                      desktopColumns: 2,
                      children: [
                        AnswerButton(
                          text: 'Paris',
                          shape: AnswerShape.triangle,
                          isSelected: _selectedAnswer == 0,
                          isCorrect: _showResult && _selectedAnswer == 0,
                          showResult: _showResult,
                          onPressed: () => _handleAnswerSelection(0, true),
                        ),
                        AnswerButton(
                          text: 'London',
                          shape: AnswerShape.diamond,
                          isSelected: _selectedAnswer == 1,
                          isWrong: _showResult && _selectedAnswer == 1,
                          showResult: _showResult,
                          onPressed: () => _handleAnswerSelection(1, false),
                        ),
                        AnswerButton(
                          text: 'Berlin',
                          shape: AnswerShape.circle,
                          isSelected: _selectedAnswer == 2,
                          isWrong: _showResult && _selectedAnswer == 2,
                          showResult: _showResult,
                          onPressed: () => _handleAnswerSelection(2, false),
                        ),
                        AnswerButton(
                          text: 'Madrid',
                          shape: AnswerShape.square,
                          isSelected: _selectedAnswer == 3,
                          isWrong: _showResult && _selectedAnswer == 3,
                          showResult: _showResult,
                          onPressed: () => _handleAnswerSelection(3, false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section: Timer & Score
                  _buildSectionHeader('Timer & Score'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CountdownTimer(
                        totalSeconds: 30,
                        currentSeconds: _timerSeconds,
                        isWarning: _timerSeconds <= 5,
                      ),
                      ScoreCounter(
                        currentScore: _currentScore,
                        previousScore: _currentScore - 100,
                        showAnimation: true,
                        label: 'Score',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section: Lobby Avatars
                  _buildSectionHeader('Lobby Avatars'),
                  ResponsiveWrap(
                    spacing: AppSpacing.spacingXL,
                    runSpacing: AppSpacing.spacingXL,
                    children: [
                      LobbyAvatar(
                        playerName: 'John Doe',
                        isOnline: true,
                        isReady: true,
                        isHost: true,
                      ),
                      LobbyAvatar(
                        playerName: 'Jane Smith',
                        isOnline: true,
                        isReady: false,
                      ),
                      LobbyAvatar(
                        playerName: 'Bob Wilson',
                        isOnline: false,
                      ),
                      LobbyAvatar(
                        playerName: 'Alice Brown',
                        isOnline: true,
                        isReady: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section: Loading Animations
                  _buildSectionHeader('Loading Animations'),
                  ResponsiveWrap(
                    spacing: AppSpacing.spacingXL,
                    runSpacing: AppSpacing.spacingXL,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      LoadingAnimations(
                        type: LoadingType.spinner,
                        message: 'Loading...',
                        color: AppColors.vibrantPurple,
                      ),
                      LoadingAnimations(
                        type: LoadingType.pulse,
                        message: 'Pulse',
                        color: AppColors.turquoise,
                      ),
                      LoadingAnimations(
                        type: LoadingType.bounce,
                        message: 'Bounce',
                        color: AppColors.coralRed,
                      ),
                      LoadingAnimations(
                        type: LoadingType.wave,
                        message: 'Wave',
                        color: AppColors.mintGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section: Leaderboard Score Display
                  _buildSectionHeader('Leaderboard'),
                  Column(
                    children: [
                      LeaderboardScoreDisplay(
                        rank: 1,
                        score: 2500,
                        playerName: 'John Doe',
                        isCurrentPlayer: true,
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      LeaderboardScoreDisplay(
                        rank: 2,
                        score: 2300,
                        playerName: 'Jane Smith',
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      LeaderboardScoreDisplay(
                        rank: 3,
                        score: 2100,
                        playerName: 'Bob Wilson',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacingXXL),
                ],
              ),
            ),
            
            // Particle Effects Overlay
            if (_showParticles)
              ParticleEffects(
                isActive: _showParticles,
                type: ParticleType.confetti,
                onComplete: () => setState(() => _showParticles = false),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _resetDemo,
          backgroundColor: AppColors.vibrantPurple,
          child: const Icon(Icons.refresh, color: AppColors.pureWhite),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      child: Text(
        title,
        style: AppTextStyles.sectionHeader.copyWith(
          color: _isDarkMode ? AppColors.darkPrimaryText : AppColors.charcoal,
        ),
      ),
    );
  }

  void _handleAnswerSelection(int index, bool isCorrect) {
    if (_showResult) return;
    
    setState(() {
      _selectedAnswer = index;
      _showResult = true;
      
      if (isCorrect) {
        _currentScore += 100;
        _showParticles = true;
      } else {
        _isShaking = true;
      }
    });
    
    // Auto-reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _selectedAnswer = -1;
          _showResult = false;
        });
      }
    });
  }

  void _resetDemo() {
    setState(() {
      _currentScore = 0;
      _selectedAnswer = -1;
      _showResult = false;
      _isShaking = false;
      _showParticles = false;
      _timerSeconds = 30;
    });
  }
}