import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_spacing.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/constants/app_animations.dart';

/// Builder for true/false question options
class TrueFalseBuilder extends StatefulWidget {
  final int correctAnswer;
  final Function(int) onCorrectAnswerChanged;

  const TrueFalseBuilder({
    super.key,
    required this.correctAnswer,
    required this.onCorrectAnswerChanged,
  });

  @override
  State<TrueFalseBuilder> createState() => _TrueFalseBuilderState();
}

class _TrueFalseBuilderState extends State<TrueFalseBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.elastic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Correct Answer',
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildOption(
                  index: 0,
                  label: 'True',
                  icon: Icons.check_circle_outline,
                  color: AppColors.turquoise,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Expanded(
                child: _buildOption(
                  index: 1,
                  label: 'False',
                  icon: Icons.cancel_outlined,
                  color: AppColors.coralRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          // Visual indicator
          AnimatedContainer(
            duration: AppAnimations.shortAnimation,
            curve: AppAnimations.easeInOut,
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: widget.correctAnswer == 0
                  ? AppColors.turquoise.withOpacity(0.1)
                  : AppColors.coralRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.correctAnswer == 0
                    ? AppColors.turquoise
                    : AppColors.coralRed,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.correctAnswer == 0
                      ? Icons.info_outline
                      : Icons.info_outline,
                  color: widget.correctAnswer == 0
                      ? AppColors.turquoise
                      : AppColors.coralRed,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: Text(
                    widget.correctAnswer == 0
                        ? 'The correct answer is TRUE'
                        : 'The correct answer is FALSE',
                    style: AppTextStyles.caption.copyWith(
                      color: widget.correctAnswer == 0
                          ? AppColors.turquoise
                          : AppColors.coralRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = widget.correctAnswer == index;

    return GestureDetector(
      onTap: () {
        widget.onCorrectAnswerChanged(index);
        // Add haptic feedback
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: AppAnimations.shortAnimation,
        curve: AppAnimations.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.lightGray,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: AppAnimations.shortAnimation,
              transform: Matrix4.identity()
                ..scale(isSelected ? 1.1 : 1.0),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.coolGray,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              label,
              style: AppTextStyles.sectionHeader.copyWith(
                color: isSelected ? color : AppColors.coolGray,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            AnimatedOpacity(
              duration: AppAnimations.shortAnimation,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                  vertical: AppSpacing.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Correct',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}