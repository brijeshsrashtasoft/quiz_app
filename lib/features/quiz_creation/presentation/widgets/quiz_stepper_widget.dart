import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';

/// Custom stepper widget for quiz creation workflow
class QuizStepperWidget extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTapped;

  const QuizStepperWidget({
    super.key,
    required this.currentStep,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildStep(
                context,
                index: 0,
                title: isSmallScreen ? 'Details' : 'Quiz Details',
                icon: Icons.info_outline,
                isActive: currentStep >= 0,
                isCompleted: currentStep > 0,
              ),
            ),
            _buildConnector(isActive: currentStep >= 1, context: context),
            Expanded(
              child: _buildStep(
                context,
                index: 1,
                title: isSmallScreen ? 'Questions' : 'Add Questions',
                icon: Icons.quiz_outlined,
                isActive: currentStep >= 1,
                isCompleted: currentStep > 1,
              ),
            ),
            _buildConnector(isActive: currentStep >= 2, context: context),
            Expanded(
              child: _buildStep(
                context,
                index: 2,
                title: 'Settings',
                icon: Icons.settings_outlined,
                isActive: currentStep >= 2,
                isCompleted: currentStep > 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    final color = isActive ? AppColors.vibrantPurple : AppColors.coolGray;
    final backgroundColor = isActive
        ? AppColors.vibrantPurple
        : AppColors.lightGray;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;
    final stepSize = isSmallScreen ? 40.0 : 48.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return GestureDetector(
      onTap: () => onStepTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: stepSize,
            height: stepSize,
            decoration: BoxDecoration(
              color: isCompleted ? backgroundColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: isActive
                    ? (isSmallScreen ? 2 : 3)
                    : (isSmallScreen ? 1.5 : 2),
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: AppColors.pureWhite,
                      size: iconSize,
                    )
                  : Icon(
                      icon,
                      color: isActive ? color : AppColors.coolGray,
                      size: iconSize,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            title,
            style: isActive
                ? AppTextStyles.caption.copyWith(
                    color: AppColors.vibrantPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 10 : 12,
                  )
                : AppTextStyles.caption.copyWith(
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConnector({
    required bool isActive,
    required BuildContext context,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    return Expanded(
      child: Container(
        height: isSmallScreen ? 1.5 : 2,
        margin: EdgeInsets.only(
          bottom: isSmallScreen ? AppSpacing.spacingM : AppSpacing.spacingL,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.vibrantPurple : AppColors.lightGray,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
