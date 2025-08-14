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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Correct Answer', style: AppTextStyles.inputLabel),
          const SizedBox(height: AppSpacing.spacingM),
          IntrinsicHeight(
            child: Row(
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
          ),
          const SizedBox(height: AppSpacing.spacingM),
          // Visual indicator
          AnimatedContainer(
            duration: AppAnimations.shortAnimation,
            curve: AppAnimations.easeInOut,
            padding: EdgeInsets.all(
              isSmallScreen ? AppSpacing.spacingS : AppSpacing.spacingM,
            ),
            decoration: BoxDecoration(
              color: widget.correctAnswer == 0
                  ? AppColors.turquoise.withValues(alpha: 0.1)
                  : AppColors.coralRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.correctAnswer == 0
                    ? AppColors.turquoise
                    : AppColors.coralRed,
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Icon(
                    widget.correctAnswer == 0
                        ? Icons.info_outline
                        : Icons.info_outline,
                    color: widget.correctAnswer == 0
                        ? AppColors.turquoise
                        : AppColors.coralRed,
                    size: isSmallScreen ? 18 : 20,
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
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
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
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final iconSize = isSmallScreen ? 36.0 : 48.0;
    final borderWidth = isSelected ? (isSmallScreen ? 2.0 : 3.0) : 1.0;

    return GestureDetector(
      onTap: () {
        widget.onCorrectAnswerChanged(index);
        // Add haptic feedback
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: AppAnimations.shortAnimation,
        curve: AppAnimations.easeInOut,
        padding: EdgeInsets.all(
          isSmallScreen ? AppSpacing.spacingM : AppSpacing.spacingL,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.lightGray,
            width: borderWidth,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: isSmallScreen ? 8 : 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppAnimations.shortAnimation,
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                child: Icon(
                  icon,
                  color: isSelected ? color : AppColors.coolGray,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: isSelected ? color : AppColors.coolGray,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              AnimatedOpacity(
                duration: AppAnimations.shortAnimation,
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen
                        ? AppSpacing.spacingS
                        : AppSpacing.spacingM,
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
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
