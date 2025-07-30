import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Circular countdown timer with animated progress indicator
/// Reference: docs/ui_guideline.md - Timer Component
class CountdownTimer extends StatefulWidget {
  final int totalSeconds;
  final int currentSeconds;
  final bool isWarning;
  final bool isPaused;
  final VoidCallback? onFinished;
  final Color? customColor;
  final bool showNumbers;

  const CountdownTimer({
    super.key,
    required this.totalSeconds,
    required this.currentSeconds,
    this.isWarning = false,
    this.isPaused = false,
    this.onFinished,
    this.customColor,
    this.showNumbers = true,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation for warning state
    _pulseController = AnimationController(
      duration: AppAnimations.timerWarningDuration,
      vsync: this,
    );
    _pulseAnimation =
        Tween<double>(
          begin: AppAnimations.pulseScaleMin,
          end: AppAnimations.pulseScaleMax,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: AppAnimations.timerWarningCurve,
          ),
        );

    // Rotation animation for active state
    _rotationController = AnimationController(
      duration: AppAnimations.loadingRotationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: AppAnimations.loadingRotationCurve,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger warning animation when entering warning state
    if (widget.isWarning && !oldWidget.isWarning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isWarning && oldWidget.isWarning) {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Handle pause/resume animation
    if (widget.isPaused && !oldWidget.isPaused) {
      _rotationController.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _rotationController.repeat();
    }

    // Check if timer finished
    if (widget.currentSeconds <= 0 && oldWidget.currentSeconds > 0) {
      _pulseController.stop();
      _rotationController.stop();
      widget.onFinished?.call();
    }
  }

  Color get _primaryColor {
    if (widget.customColor != null) return widget.customColor!;
    if (widget.isWarning) return AppColors.coralRed;
    return AppColors.vibrantPurple;
  }

  Color get _backgroundColor {
    return _primaryColor.withOpacity(0.1);
  }

  double get _progress {
    if (widget.totalSeconds <= 0) return 0.0;
    return widget.currentSeconds / widget.totalSeconds;
  }

  String get _displayTime {
    final minutes = widget.currentSeconds ~/ 60;
    final seconds = widget.currentSeconds % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Timer: ${widget.currentSeconds} seconds remaining',
      value: '${((_progress) * 100).round()}% complete',
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isWarning ? _pulseAnimation.value : 1.0,
            child: Container(
              width: AppDimensions.timerSize,
              height: AppDimensions.timerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: AppDimensions.timerSize,
                    height: AppDimensions.timerSize,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: AppDimensions.timerStrokeWidth,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _primaryColor.withOpacity(0.2),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: AppDimensions.timerSize,
                    height: AppDimensions.timerSize,
                    child: Transform.rotate(
                      angle: -1.5708, // Start from top (-90 degrees)
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: AppDimensions.timerStrokeWidth,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _primaryColor,
                        ),
                        backgroundColor: Colors.transparent,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  // Time display
                  if (widget.showNumbers)
                    Text(
                      _displayTime,
                      style: widget.isWarning
                          ? AppTextStyles.timerDisplayWarning.copyWith(
                              fontSize: _getResponsiveFontSize(),
                            )
                          : AppTextStyles.timerDisplay.copyWith(
                              fontSize: _getResponsiveFontSize(),
                              color: _primaryColor,
                            ),
                      textAlign: TextAlign.center,
                    ),
                  // Pause indicator
                  if (widget.isPaused)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pause,
                        color: AppColors.pureWhite,
                        size: AppDimensions.iconS,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getResponsiveFontSize() {
    // Adjust font size based on timer size
    if (AppDimensions.timerSize < 60) return 16.0;
    if (AppDimensions.timerSize < 80) return 20.0;
    return 24.0;
  }
}

/// Mini countdown timer for compact layouts
class MiniCountdownTimer extends StatelessWidget {
  final int currentSeconds;
  final int totalSeconds;
  final bool isWarning;

  const MiniCountdownTimer({
    super.key,
    required this.currentSeconds,
    required this.totalSeconds,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return CountdownTimer(
      totalSeconds: totalSeconds,
      currentSeconds: currentSeconds,
      isWarning: isWarning,
      showNumbers: true,
      customColor: isWarning ? AppColors.coralRed : AppColors.vibrantPurple,
    );
  }
}
