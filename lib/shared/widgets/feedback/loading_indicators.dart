import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_animations.dart';

/// Loading spinner with optional message
class LoadingSpinner extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingSpinner({
    super.key,
    this.message,
    this.size = 32,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.longAnimation,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: widget.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? AppColors.vibrantPurple,
            ),
          ),
        ),
        if (widget.message != null) ...[
          SizedBox(height: AppSpacing.spacingM),
          Text(
            widget.message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Pulsing dot indicator
class PulsingDots extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color? color;
  final Duration duration;

  const PulsingDots({
    super.key,
    this.dotCount = 3,
    this.dotSize = 8.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * 200),
        () => _controllers[i].repeat(reverse: true),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.dotSize,
              height: widget.dotSize,
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.25),
              decoration: BoxDecoration(
                color: (widget.color ?? AppColors.vibrantPurple).withOpacity(
                  _animations[index].value,
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Shimmer loading effect for content placeholders
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? AppColors.backgroundLight;
    final highlightColor = widget.highlightColor ?? AppColors.pureWhite;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Content placeholder for shimmer loading
class ContentPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ContentPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// List item shimmer placeholder
class ListItemPlaceholder extends StatelessWidget {
  final bool showAvatar;
  final int lineCount;

  const ListItemPlaceholder({
    super.key,
    this.showAvatar = true,
    this.lineCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.spacingM),
      child: Row(
        children: [
          if (showAvatar) ...[
            const ContentPlaceholder(width: 48, height: 48, borderRadius: 24),
            SizedBox(width: AppSpacing.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lineCount, (index) {
                final width = index == 0 ? double.infinity : 150.0;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < lineCount - 1 ? AppSpacing.spacingS : 0,
                  ),
                  child: ContentPlaceholder(width: width, height: 16),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card shimmer placeholder
class CardPlaceholder extends StatelessWidget {
  final double height;
  final bool showImage;

  const CardPlaceholder({super.key, this.height = 200, this.showImage = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.all(AppSpacing.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage) ...[
            Expanded(
              flex: 3,
              child: const ContentPlaceholder(
                width: double.infinity,
                borderRadius: 8,
              ),
            ),
            SizedBox(height: AppSpacing.spacingM),
          ],
          Expanded(
            flex: showImage ? 2 : 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentPlaceholder(width: double.infinity, height: 20),
                SizedBox(height: AppSpacing.spacingS),
                const ContentPlaceholder(width: 200, height: 16),
                SizedBox(height: AppSpacing.spacingS),
                const ContentPlaceholder(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
