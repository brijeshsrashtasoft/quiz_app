import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class HostControlPanel extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPause;
  final VoidCallback? onEnd;
  final bool isPaused;

  const HostControlPanel({
    super.key,
    this.onNext,
    this.onPause,
    this.onEnd,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allL,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: isPaused ? 'Resume' : 'Pause',
            color: AppColors.warmYellow,
            onPressed: onPause,
          ),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            label: 'Next',
            color: AppColors.turquoise,
            onPressed: onNext,
            isPrimary: true,
          ),
          _ControlButton(
            icon: Icons.stop_rounded,
            label: 'End',
            color: AppColors.coralRed,
            onPressed: onEnd,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonTapDuration,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: AppAnimations.buttonPressScale).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppAnimations.buttonTapCurve,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isPrimary ? 80.0 : 64.0;
    final iconSize = widget.isPrimary ? 36.0 : 28.0;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(
                      widget.onPressed != null ? 1.0 : 0.5,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: widget.onPressed != null && !_isPressed
                        ? [
                            BoxShadow(
                              color: widget.color.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    widget.icon,
                    size: iconSize,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  widget.label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: widget.isPrimary
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.onPressed != null
                        ? AppColors.charcoal
                        : AppColors.coolGray,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
