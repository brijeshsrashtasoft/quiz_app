import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/quiz/score_counter.dart';

class ScoreDisplay extends StatefulWidget {
  final int score;
  final bool showAnimation;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.showAnimation = true,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.score;
    _animationController = AnimationController(
      duration: AppAnimations.scoreUpdateDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.elastic,
    ));
  }

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score && widget.showAnimation) {
      _previousScore = oldWidget.score;
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingS,
            ),
            decoration: BoxDecoration(
              gradient: widget.score >= 10000 
                  ? AppColors.goldGradient 
                  : AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (widget.score >= 10000 
                      ? AppColors.achievement 
                      : AppColors.vibrantPurple).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.score >= 10000 
                      ? Icons.emoji_events_rounded 
                      : Icons.star_rounded,
                  color: AppColors.pureWhite,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spacingS),
                CompactScoreCounter(
                  score: widget.score,
                  isHighScore: widget.score >= 10000,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}