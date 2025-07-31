import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class ConnectionStatusIndicator extends StatefulWidget {
  final bool isConnected;
  final VoidCallback? onReconnect;

  const ConnectionStatusIndicator({
    super.key,
    required this.isConnected,
    this.onReconnect,
  });

  @override
  State<ConnectionStatusIndicator> createState() =>
      _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (!widget.isConnected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (!widget.isConnected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !widget.isConnected ? widget.onReconnect : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingS,
          ),
          decoration: BoxDecoration(
            color: widget.isConnected
                ? AppColors.turquoise.withOpacity(0.1)
                : AppColors.coralRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isConnected
                  ? AppColors.turquoise.withOpacity(0.3)
                  : AppColors.coralRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: widget.isConnected ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isConnected
                            ? AppColors.turquoise
                            : AppColors.coralRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                widget.isConnected ? 'Connected' : 'Reconnecting...',
                style: AppTextStyles.caption.copyWith(
                  color: widget.isConnected
                      ? AppColors.turquoise
                      : AppColors.coralRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!widget.isConnected) ...[
                const SizedBox(width: AppSpacing.spacingS),
                Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: AppColors.coralRed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
