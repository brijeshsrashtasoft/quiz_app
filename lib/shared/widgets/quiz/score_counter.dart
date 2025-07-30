import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Animated score counter with celebration effects
/// Reference: docs/ui_guideline.md - Score Display
class ScoreCounter extends StatefulWidget {
  final int currentScore;
  final int previousScore;
  final bool showAnimation;
  final bool isHighScore;
  final String? label;
  final VoidCallback? onAnimationComplete;

  const ScoreCounter({
    super.key,
    required this.currentScore,
    this.previousScore = 0,
    this.showAnimation = true,
    this.isHighScore = false,
    this.label,
    this.onAnimationComplete,
  });

  @override
  State<ScoreCounter> createState() => _ScoreCounterState();
}

class _ScoreCounterState extends State<ScoreCounter>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _celebrationController;
  late AnimationController _pulseController;

  late Animation<int> _countAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Count-up animation
    _countController = AnimationController(
      duration: AppAnimations.scoreUpdateDuration,
      vsync: this,
    );

    // Celebration bounce animation
    _celebrationController = AnimationController(
      duration: AppAnimations.achievementDuration,
      vsync: this,
    );

    // Pulse animation for high scores
    _pulseController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _countAnimation =
        IntTween(begin: widget.previousScore, end: widget.currentScore).animate(
          CurvedAnimation(
            parent: _countController,
            curve: AppAnimations.scoreUpdateCurve,
          ),
        );

    _celebrationAnimation =
        Tween<double>(begin: 1.0, end: AppAnimations.achievementScale).animate(
          CurvedAnimation(
            parent: _celebrationController,
            curve: AppAnimations.achievementCurve,
          ),
        );

    _pulseAnimation =
        Tween<double>(
          begin: AppAnimations.pulseScaleMin,
          end: AppAnimations.pulseScaleMax,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: AppAnimations.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _countController.dispose();
    _celebrationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentScore != oldWidget.currentScore) {
      _animateScore();

      // Trigger celebration for score increases
      if (widget.currentScore > oldWidget.currentScore) {
        _celebrationController.forward().then((_) {
          _celebrationController.reverse();
          widget.onAnimationComplete?.call();
        });
      }
    }

    // Handle high score pulse
    if (widget.isHighScore && !oldWidget.isHighScore) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isHighScore && oldWidget.isHighScore) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _animateScore() {
    if (widget.showAnimation) {
      _countAnimation =
          IntTween(
            begin: widget.previousScore,
            end: widget.currentScore,
          ).animate(
            CurvedAnimation(
              parent: _countController,
              curve: AppAnimations.scoreUpdateCurve,
            ),
          );

      _countController.reset();
      _countController.forward();
    }
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label ?? 'Score',
      value: '${widget.currentScore} points',
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _countAnimation,
          _celebrationAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          final displayScore = widget.showAnimation
              ? _countAnimation.value
              : widget.currentScore;

          return Transform.scale(
            scale:
                _celebrationAnimation.value *
                (widget.isHighScore ? _pulseAnimation.value : 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingL,
                vertical: AppSpacing.spacingM,
              ),
              decoration: BoxDecoration(
                gradient: widget.isHighScore
                    ? AppColors.goldGradient
                    : LinearGradient(
                        colors: [
                          AppColors.vibrantPurple.withOpacity(0.1),
                          AppColors.vibrantPurple.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusL,
                ),
                border: Border.all(
                  color: widget.isHighScore
                      ? AppColors.achievement
                      : AppColors.vibrantPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: AppTextStyles.caption.copyWith(
                        color: widget.isHighScore
                            ? AppColors.charcoal
                            : AppColors.vibrantPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  if (widget.label != null)
                    const SizedBox(height: AppSpacing.spacingXS),

                  // Score display
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // High score icon
                      if (widget.isHighScore)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: AppSpacing.spacingS,
                          ),
                          child: Icon(
                            Icons.star,
                            color: AppColors.achievement,
                            size: AppDimensions.iconL,
                          ),
                        ),

                      // Score text
                      Text(
                        _formatScore(displayScore),
                        style: widget.isHighScore
                            ? AppTextStyles.scoreDisplayGold
                            : AppTextStyles.scoreDisplay,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compact score display for small spaces
class CompactScoreCounter extends StatelessWidget {
  final int score;
  final bool isHighScore;

  const CompactScoreCounter({
    super.key,
    required this.score,
    this.isHighScore = false,
  });

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      decoration: BoxDecoration(
        color: isHighScore
            ? AppColors.achievement.withOpacity(0.2)
            : AppColors.vibrantPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusFull),
        border: Border.all(
          color: isHighScore ? AppColors.achievement : AppColors.vibrantPurple,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighScore)
            Icon(
              Icons.star,
              color: AppColors.achievement,
              size: AppDimensions.iconS,
            ),
          if (isHighScore) const SizedBox(width: AppSpacing.spacingXS),
          Text(
            _formatScore(score),
            style: AppTextStyles.buttonSmall.copyWith(
              color: isHighScore
                  ? AppColors.achievement
                  : AppColors.vibrantPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Leaderboard score display with rank
class LeaderboardScoreDisplay extends StatelessWidget {
  final int rank;
  final int score;
  final String playerName;
  final bool isCurrentPlayer;

  const LeaderboardScoreDisplay({
    super.key,
    required this.rank,
    required this.score,
    required this.playerName,
    this.isCurrentPlayer = false,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppColors.achievement; // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.vibrantPurple;
    }
  }

  IconData get _rankIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.military_tech; // Medal
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? AppColors.vibrantPurple.withOpacity(0.1)
            : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        border: Border.all(
          color: isCurrentPlayer
              ? AppColors.vibrantPurple
              : AppColors.lightGray,
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      _rankIcon,
                      color: AppColors.pureWhite,
                      size: AppDimensions.iconM,
                    )
                  : Text(
                      rank.toString(),
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppSpacing.spacingM),

          // Player name
          Expanded(
            child: Text(
              playerName,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: isCurrentPlayer ? FontWeight.w600 : FontWeight.w400,
                color: isCurrentPlayer
                    ? AppColors.vibrantPurple
                    : AppColors.charcoal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Score
          ScoreCounter(
            currentScore: score,
            showAnimation: false,
            isHighScore: rank <= 3,
          ),
        ],
      ),
    );
  }
}
