import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/widgets/primitives/app_card.dart';
import '../../../../shared/widgets/primitives/app_image.dart';

/// Real-time question display widget with animations
/// Following Kahoot-style design from docs/ui_guideline.md
class QuestionDisplay extends ConsumerWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final Duration timeLimit;
  final VoidCallback? onTimeUp;

  const QuestionDisplay({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.timeLimit,
    this.onTimeUp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),
        AppSpacing.verticalSpacingM,

        // Question card with animation
        _buildQuestionCard(context)
            .animate()
            .slideY(
              begin: 0.2,
              end: 0,
              duration: AppAnimations.newQuestionDuration,
              curve: AppAnimations.newQuestionCurve,
            )
            .fadeIn(duration: AppAnimations.newQuestionDuration),

        AppSpacing.verticalSpacingM,

        // Timer display
        _buildTimerDisplay(context),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = questionNumber / totalQuestions;

    return Container(
      height: AppDimensions.progressBarHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDimensions.progressBarHeight / 2,
        ),
        color: AppColors.lightGray,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child:
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppDimensions.progressBarHeight / 2,
                ),
                gradient: AppColors.purpleGradient,
              ),
            ).animate().scaleX(
              begin: 0.8,
              end: 1.0,
              duration: AppAnimations.mediumAnimation,
              curve: AppAnimations.easeOut,
            ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.spacingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question number badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.vibrantPurple,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
            child: Text(
              'Question $questionNumber of $totalQuestions',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          AppSpacing.verticalSpacingL,

          // Question image if available
          if (question.questionImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
              child: AppImage(
                imageUrl: question.questionImageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            AppSpacing.verticalSpacingM,
          ],

          // Question text
          Text(
            question.questionText,
            style: AppTextStyles.questionText,
            textAlign: TextAlign.center,
          ),

          // Points indicator
          AppSpacing.verticalSpacingM,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: AppColors.warmYellow, size: 20),
              AppSpacing.horizontalSpacingXS,
              Text(
                '${question.questionPoints} points',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.coolGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context) {
    return TimerDisplay(duration: timeLimit, onComplete: onTimeUp, size: 80);
  }
}

/// Animated timer display component
class TimerDisplay extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final double size;

  const TimerDisplay({
    super.key,
    required this.duration,
    this.onComplete,
    this.size = 80,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _remainingSeconds;
  bool _isWarning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.addListener(() {
      final newSeconds = (widget.duration.inSeconds * _animation.value).round();
      if (newSeconds != _remainingSeconds) {
        setState(() {
          _remainingSeconds = newSeconds;
          _isWarning = _remainingSeconds <= 5;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularProgressPainter(
                  progress: _animation.value,
                  color: _isWarning
                      ? AppColors.coralRed
                      : AppColors.vibrantPurple,
                  backgroundColor: AppColors.lightGray,
                ),
              );
            },
          ),

          // Timer text
          AnimatedDefaultTextStyle(
                duration: AppAnimations.shortAnimation,
                style: AppTextStyles.timerDisplay.copyWith(
                  color: _isWarning ? AppColors.coralRed : AppColors.charcoal,
                  fontSize: widget.size * 0.4,
                ),
                child: Text(_remainingSeconds.toString()),
              )
              .animate(
                onPlay: (controller) {
                  if (_isWarning) {
                    controller.repeat();
                  }
                },
              )
              .scale(
                begin: 1.0,
                end: _isWarning ? 1.1 : 1.0,
                duration: AppAnimations.timerWarningDuration,
                curve: AppAnimations.timerWarningCurve,
              ),
        ],
      ),
    );
  }
}

/// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 3, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      -90 * (3.14159 / 180),
      progress * 2 * 3.14159,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
