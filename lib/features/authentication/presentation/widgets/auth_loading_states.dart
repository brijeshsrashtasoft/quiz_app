import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Authentication-specific loading states with engaging animations
/// Following Kahoot-style visual design patterns
class AuthLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String message;
  final bool showProgress;
  final double? progress;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AuthLoadingOverlay({
    super.key,
    required this.isVisible,
    this.message = 'Loading...',
    this.showProgress = false,
    this.progress,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AuthLoadingOverlay> createState() => _AuthLoadingOverlayState();
}

class _AuthLoadingOverlayState extends State<AuthLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppAnimations.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isVisible) {
      _fadeController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AuthLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _fadeController.reverse();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Visibility(
          visible: _fadeAnimation.value > 0,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              color: (widget.backgroundColor ?? AppColors.charcoal).withValues(
                alpha: 0.8,
              ),
              child: Center(child: _buildLoadingContent()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated loading indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    shape: BoxShape.circle,
                  ),
                  child: widget.showProgress && widget.progress != null
                      ? CircularProgressIndicator(
                          value: widget.progress,
                          backgroundColor: AppColors.lightGray,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.pureWhite,
                          ),
                          strokeWidth: 4,
                        )
                      : const CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.pureWhite,
                          ),
                          strokeWidth: 4,
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Loading message
          Text(
            widget.message,
            style: AppTextStyles.bodyText.copyWith(
              color: widget.foregroundColor ?? AppColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          if (widget.showProgress && widget.progress != null) ...[
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              '${(widget.progress! * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.vibrantPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator for form elements
class InlineLoadingIndicator extends StatefulWidget {
  final bool isVisible;
  final String message;
  final Color? color;
  final double size;

  const InlineLoadingIndicator({
    super.key,
    required this.isVisible,
    this.message = 'Loading...',
    this.color,
    this.size = 20,
  });

  @override
  State<InlineLoadingIndicator> createState() => _InlineLoadingIndicatorState();
}

class _InlineLoadingIndicatorState extends State<InlineLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.isVisible) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(InlineLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2.0 * 3.14159,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? AppColors.vibrantPurple,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: AppSpacing.spacingS),
        Text(
          widget.message,
          style: AppTextStyles.caption.copyWith(
            color: widget.color ?? AppColors.coolGray,
          ),
        ),
      ],
    );
  }
}

/// Skeleton loading for authentication form elements
class AuthFormSkeleton extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final double itemSpacing;

  const AuthFormSkeleton({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 56,
    this.itemSpacing = 16,
  });

  @override
  State<AuthFormSkeleton> createState() => _AuthFormSkeletonState();
}

class _AuthFormSkeletonState extends State<AuthFormSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Container(
          margin: EdgeInsets.only(
            bottom: index < widget.itemCount - 1 ? widget.itemSpacing : 0,
          ),
          child: _buildSkeletonItem(),
        );
      }),
    );
  }

  Widget _buildSkeletonItem() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: widget.itemHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
                1.0,
              ],
              colors: [
                AppColors.lightGray.withValues(alpha: 0.3),
                AppColors.lightGray.withValues(alpha: 0.5),
                AppColors.pureWhite.withValues(alpha: 0.8),
                AppColors.lightGray.withValues(alpha: 0.5),
                AppColors.lightGray.withValues(alpha: 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Success animation for completed authentication actions
class AuthSuccessAnimation extends StatefulWidget {
  final bool isVisible;
  final String message;
  final VoidCallback? onComplete;
  final Duration duration;

  const AuthSuccessAnimation({
    super.key,
    required this.isVisible,
    this.message = 'Success!',
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AuthSuccessAnimation> createState() => _AuthSuccessAnimationState();
}

class _AuthSuccessAnimationState extends State<AuthSuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _checkController = AnimationController(
      duration: AppAnimations.longAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: AppAnimations.bounce),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: AppAnimations.easeOut),
    );

    if (widget.isVisible) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    await _scaleController.forward();
    await _checkController.forward();

    if (widget.onComplete != null) {
      await Future.delayed(widget.duration);
      widget.onComplete!();
    }
  }

  @override
  void didUpdateWidget(AuthSuccessAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _checkController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.spacingXL),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(60, 60),
                  painter: CheckmarkPainter(
                    progress: _checkAnimation.value,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                Text(
                  widget.message,
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Checkmark path
    final startX = size.width * 0.2;
    final startY = size.height * 0.5;
    final midX = size.width * 0.4;
    final midY = size.height * 0.7;
    final endX = size.width * 0.8;
    final endY = size.height * 0.3;

    path.moveTo(startX, startY);

    if (progress <= 0.5) {
      // First half: draw to middle point
      final currentProgress = progress * 2;
      final currentX = startX + (midX - startX) * currentProgress;
      final currentY = startY + (midY - startY) * currentProgress;
      path.lineTo(currentX, currentY);
    } else {
      // Second half: draw to end point
      path.lineTo(midX, midY);
      final currentProgress = (progress - 0.5) * 2;
      final currentX = midX + (endX - midX) * currentProgress;
      final currentY = midY + (endY - midY) * currentProgress;
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
