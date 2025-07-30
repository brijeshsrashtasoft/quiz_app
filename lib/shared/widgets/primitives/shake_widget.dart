import 'package:flutter/material.dart';
import '../../constants/app_animations.dart';

/// Shake animation widget for wrong answers and error states
/// Reference: docs/ui_guideline.md - Wrong Answer Animation
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final Duration duration;
  final double distance;
  final VoidCallback? onShakeComplete;

  const ShakeWidget({
    super.key,
    required this.child,
    this.isShaking = false,
    this.duration = const Duration(milliseconds: 500),
    this.distance = AppAnimations.microSlideDistance,
    this.onShakeComplete,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Create shake animation with multiple steps
    _animation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: widget.distance, end: -widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -widget.distance, end: widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: widget.distance, end: -widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -widget.distance, end: 0.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.linear),
        );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShakeComplete?.call();
        if (mounted) {
          _controller.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward();
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _controller.reset();
    }

    // Update animation if duration or distance changed
    if (widget.duration != oldWidget.duration ||
        widget.distance != oldWidget.distance) {
      _controller.dispose();
      _setupAnimation();
      if (widget.isShaking) {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Vertical shake animation
class VerticalShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final Duration duration;
  final double distance;
  final VoidCallback? onShakeComplete;

  const VerticalShakeWidget({
    super.key,
    required this.child,
    this.isShaking = false,
    this.duration = const Duration(milliseconds: 500),
    this.distance = AppAnimations.microSlideDistance,
    this.onShakeComplete,
  });

  @override
  State<VerticalShakeWidget> createState() => _VerticalShakeWidgetState();
}

class _VerticalShakeWidgetState extends State<VerticalShakeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: -widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -widget.distance, end: widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: widget.distance, end: -widget.distance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -widget.distance, end: 0.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.linear),
        );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShakeComplete?.call();
        if (mounted) {
          _controller.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VerticalShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Rotational shake animation
class RotationShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final Duration duration;
  final double angle;
  final VoidCallback? onShakeComplete;

  const RotationShakeWidget({
    super.key,
    required this.child,
    this.isShaking = false,
    this.duration = const Duration(milliseconds: 500),
    this.angle = AppAnimations.shakeRotation,
    this.onShakeComplete,
  });

  @override
  State<RotationShakeWidget> createState() => _RotationShakeWidgetState();
}

class _RotationShakeWidgetState extends State<RotationShakeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Convert degrees to radians
    final radians = widget.angle * (3.14159 / 180);

    _animation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: radians),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: radians, end: -radians),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -radians, end: radians),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: radians, end: 0.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.linear),
        );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShakeComplete?.call();
        if (mounted) {
          _controller.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RotationShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(angle: _animation.value, child: widget.child);
      },
    );
  }
}
