import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class PinDisplay extends StatefulWidget {
  final String pin;
  final bool isLarge;

  const PinDisplay({
    super.key,
    required this.pin,
    this.isLarge = true,
  });

  @override
  State<PinDisplay> createState() => _PinDisplayState();
}

class _PinDisplayState extends State<PinDisplay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.all(
              widget.isLarge ? AppSpacing.spacingXL : AppSpacing.spacingL,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Game PIN',
                  style: widget.isLarge
                      ? AppTextStyles.sectionHeader.copyWith(
                          color: AppColors.pureWhite.withOpacity(0.9),
                        )
                      : AppTextStyles.bodyText.copyWith(
                          color: AppColors.pureWhite.withOpacity(0.9),
                        ),
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  widget.pin,
                  style: TextStyle(
                    fontSize: widget.isLarge ? 64 : 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pureWhite,
                    fontFamily: 'monospace',
                    letterSpacing: widget.isLarge ? 12 : 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}