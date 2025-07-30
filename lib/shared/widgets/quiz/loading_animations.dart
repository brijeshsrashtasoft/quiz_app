import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Loading animations for engaging user experience
/// Reference: docs/ui_guideline.md - Loading States
class LoadingAnimations extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double size;

  const LoadingAnimations({
    super.key,
    this.type = LoadingType.spinner,
    this.message,
    this.color,
    this.size = AppDimensions.loadingIndicatorSize,
  });

  @override
  State<LoadingAnimations> createState() => _LoadingAnimationsState();
}

class _LoadingAnimationsState extends State<LoadingAnimations>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _controller.repeat();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: _getAnimationDuration(),
      vsync: this,
    );

    switch (widget.type) {
      case LoadingType.spinner:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.linear),
        );
        break;
      case LoadingType.pulse:
        _animation =
            Tween<double>(
              begin: AppAnimations.pulseScaleMin,
              end: AppAnimations.pulseScaleMax,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: AppAnimations.easeInOut,
              ),
            );
        break;
      case LoadingType.bounce:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.bounce),
        );
        break;
      case LoadingType.wave:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.easeInOut),
        );
        break;
    }
  }

  Duration _getAnimationDuration() {
    switch (widget.type) {
      case LoadingType.spinner:
        return AppAnimations.loadingRotationDuration;
      case LoadingType.pulse:
        return const Duration(milliseconds: 1200);
      case LoadingType.bounce:
        return const Duration(milliseconds: 1000);
      case LoadingType.wave:
        return const Duration(milliseconds: 1500);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color => widget.color ?? AppColors.vibrantPurple;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildLoadingWidget(),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            widget.message!,
            style: AppTextStyles.bodyText.copyWith(color: _color),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    switch (widget.type) {
      case LoadingType.spinner:
        return _buildSpinner();
      case LoadingType.pulse:
        return _buildPulse();
      case LoadingType.bounce:
        return _buildBounce();
      case LoadingType.wave:
        return _buildWave();
    }
  }

  Widget _buildSpinner() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _color.withOpacity(0.2), width: 3),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(_color),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulse() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.4),
                  blurRadius: 8 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                ),
              ],
            ),
            child: Icon(
              Icons.quiz,
              color: AppColors.pureWhite,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBounce() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
            child: Icon(
              Icons.quiz,
              color: AppColors.pureWhite,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.3;
            final animationValue = (_animation.value + delay) % 1.0;
            final scale = 1.0 + 0.5 * (1.0 - (animationValue - 0.5).abs() * 2);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size / 4,
                height: widget.size / 4,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Loading overlay that covers the entire screen
class QuizLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;
  final LoadingType type;

  const QuizLoadingOverlay({
    super.key,
    required this.isVisible,
    this.message = 'Loading...',
    this.type = LoadingType.spinner,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: AppColors.charcoal.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spacingXL),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: LoadingAnimations(type: type, message: message, size: 48),
        ),
      ),
    );
  }
}

/// Compact loading indicator for buttons
class ButtonLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const ButtonLoadingIndicator({super.key, this.color, this.size = 16});

  @override
  State<ButtonLoadingIndicator> createState() => _ButtonLoadingIndicatorState();
}

class _ButtonLoadingIndicatorState extends State<ButtonLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.loadingRotationDuration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.color ?? AppColors.pureWhite,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loading for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppDimensions.borderRadiusS),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.lightGray,
                AppColors.offWhite,
                AppColors.lightGray,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Quiz-specific loading states
class QuizSkeletonCard extends StatelessWidget {
  const QuizSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.spacingM),

          // Content skeletons
          SkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          SkeletonLoader(
            width: 200,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// Loading type enum
enum LoadingType { spinner, pulse, bounce, wave }
