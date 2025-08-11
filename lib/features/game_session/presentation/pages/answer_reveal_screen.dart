import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/quiz/particle_effects.dart';
import '../widgets/leaderboard_preview.dart';
import '../widgets/answer_statistics_chart.dart';

class AnswerRevealScreen extends ConsumerStatefulWidget {
  final bool isHost;
  final bool isCorrect;
  final int pointsEarned;
  final String correctAnswer;

  const AnswerRevealScreen({
    super.key,
    this.isHost = false,
    this.isCorrect = false,
    this.pointsEarned = 0,
    required this.correctAnswer,
  });

  @override
  ConsumerState<AnswerRevealScreen> createState() => _AnswerRevealScreenState();
}

class _AnswerRevealScreenState extends ConsumerState<AnswerRevealScreen>
    with TickerProviderStateMixin {
  late AnimationController _resultController;
  late AnimationController _leaderboardController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      duration: AppAnimations.achievementDuration,
      vsync: this,
    );

    _leaderboardController = AnimationController(
      duration: AppAnimations.leaderboardDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: AppAnimations.bounce),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: AppAnimations.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _leaderboardController,
        curve: AppAnimations.easeOut,
      ),
    );

    _resultController.forward().then((_) {
      if (widget.isCorrect && !widget.isHost) {
        setState(() => _showParticles = true);
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _leaderboardController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _resultController.dispose();
    _leaderboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Results',
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: AppSpacing.spacingXL),

              // Result icon and message
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildResultDisplay(),
                ),
              ),

              const SizedBox(height: AppSpacing.spacingXL),

              // Correct answer display
              Container(
                padding: AppSpacing.allL,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingL,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vibrantPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Correct Answer',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.pureWhite.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingS),
                    Text(
                      widget.correctAnswer,
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spacingXL),

              // Statistics or leaderboard
              Expanded(
                child: AnimatedBuilder(
                  animation: _leaderboardController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: FadeTransition(
                        opacity: _leaderboardController,
                        child: widget.isHost
                            ? const AnswerStatisticsChart()
                            : const LeaderboardPreview(entries: []),
                      ),
                    );
                  },
                ),
              ),

              // Next question countdown
              Container(
                padding: AppSpacing.allL,
                child: Column(
                  children: [
                    Text('Next question in', style: AppTextStyles.bodyText),
                    const SizedBox(height: AppSpacing.spacingS),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 5, end: 0),
                      duration: const Duration(seconds: 5),
                      builder: (context, value, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.vibrantPurple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.vibrantPurple.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$value',
                              style: AppTextStyles.timerDisplay.copyWith(
                                color: AppColors.pureWhite,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        // TODO: Navigate to next question
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Particle effects for correct answer
          if (_showParticles)
            ParticleEffects(
              isActive: _showParticles,
              type: ParticleType.confetti,
              duration: Duration(seconds: 3),
            ),
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    if (widget.isHost) {
      return Container(
        padding: AppSpacing.allXL,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.vibrantPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.vibrantPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                size: 50,
                color: AppColors.pureWhite,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Text('Answer Statistics', style: AppTextStyles.sectionHeader),
          ],
        ),
      );
    }

    final isCorrect = widget.isCorrect;
    final color = isCorrect ? AppColors.turquoise : AppColors.coralRed;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final message = isCorrect ? 'Correct!' : 'Incorrect';

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, size: 60, color: AppColors.pureWhite),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingL),
        Text(message, style: AppTextStyles.gameTitle.copyWith(color: color)),
        if (isCorrect) ...[
          const SizedBox(height: AppSpacing.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingL,
              vertical: AppSpacing.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.warmYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.warmYellow.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.warmYellow,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Text(
                  '+${widget.pointsEarned} points',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.warmYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
