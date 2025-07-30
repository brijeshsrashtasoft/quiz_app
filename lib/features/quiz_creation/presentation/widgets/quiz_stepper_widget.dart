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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStep(
          context,
          index: 0,
          title: 'Quiz Details',
          icon: Icons.info_outline,
          isActive: currentStep >= 0,
          isCompleted: currentStep > 0,
        ),
        _buildConnector(isActive: currentStep >= 1),
        _buildStep(
          context,
          index: 1,
          title: 'Add Questions',
          icon: Icons.quiz_outlined,
          isActive: currentStep >= 1,
          isCompleted: currentStep > 1,
        ),
        _buildConnector(isActive: currentStep >= 2),
        _buildStep(
          context,
          index: 2,
          title: 'Settings',
          icon: Icons.settings_outlined,
          isActive: currentStep >= 2,
          isCompleted: currentStep > 2,
        ),
      ],
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
    final backgroundColor = isActive ? AppColors.vibrantPurple : AppColors.lightGray;

    return GestureDetector(
      onTap: () => onStepTapped(index),
      child: AnimatedContainer(
        duration: AppAnimations.shortAnimation,
        curve: AppAnimations.easeInOut,
        child: Column(
          children: [
            AnimatedContainer(
              duration: AppAnimations.shortAnimation,
              curve: AppAnimations.elastic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? backgroundColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: isActive ? 3 : 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: AppColors.pureWhite,
                        size: 24,
                      )
                    : Icon(
                        icon,
                        color: isActive ? color : AppColors.coolGray,
                        size: 24,
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
                    )
                  : AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: AppSpacing.spacingL),
        decoration: BoxDecoration(
          color: isActive ? AppColors.vibrantPurple : AppColors.lightGray,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}