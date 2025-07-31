import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/widgets/buttons/answer_button.dart';

/// Answer submission interface with Kahoot-style buttons
/// Following design system from docs/ui_guideline.md
class AnswerSubmissionPanel extends ConsumerStatefulWidget {
  final Question question;
  final Function(int answerIndex) onAnswerSubmit;
  final bool isSubmitted;
  final int? selectedAnswer;
  final int? correctAnswer;
  final bool showCorrectAnswer;

  const AnswerSubmissionPanel({
    super.key,
    required this.question,
    required this.onAnswerSubmit,
    this.isSubmitted = false,
    this.selectedAnswer,
    this.correctAnswer,
    this.showCorrectAnswer = false,
  });

  @override
  ConsumerState<AnswerSubmissionPanel> createState() =>
      _AnswerSubmissionPanelState();
}

class _AnswerSubmissionPanelState extends ConsumerState<AnswerSubmissionPanel> {
  int? _hoveredIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedAnswer;
  }

  @override
  void didUpdateWidget(AnswerSubmissionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != oldWidget.selectedAnswer) {
      _selectedIndex = widget.selectedAnswer;
    }
  }

  void _handleAnswerTap(int index) {
    if (widget.isSubmitted) return;

    setState(() {
      _selectedIndex = index;
    });

    // Add haptic feedback on mobile
    HapticFeedback.lightImpact();

    // Submit answer
    widget.onAnswerSubmit(index);
  }

  @override
  Widget build(BuildContext context) {
    return widget.question.when(
      multipleChoice:
          (_, __, options, correctAnswerIndex, ___, ____, _____, ______) {
            return _buildMultipleChoiceGrid(options, correctAnswerIndex);
          },
      trueFalse: (_, __, correctAnswer, ___, ____, _____, ______) {
        return _buildTrueFalseOptions(correctAnswer);
      },
    );
  }

  Widget _buildMultipleChoiceGrid(
    List<String> options,
    int correctAnswerIndex,
  ) {
    // Define answer shapes and colors based on Kahoot style
    final answerConfigs = [
      (AnswerShape.triangle, AppColors.triangleRed),
      (AnswerShape.diamond, AppColors.diamondGreen),
      (AnswerShape.circle, AppColors.circleYellow),
      (AnswerShape.square, AppColors.squareTurquoise),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.spacingM,
        mainAxisSpacing: AppSpacing.spacingM,
        childAspectRatio: 2.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        if (index >= answerConfigs.length) return const SizedBox();

        final (shape, color) = answerConfigs[index];
        final isCorrect =
            widget.showCorrectAnswer && index == correctAnswerIndex;
        final isSelected = _selectedIndex == index;
        final isWrong =
            widget.showCorrectAnswer &&
            isSelected &&
            index != correctAnswerIndex;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child:
              AnswerButton(
                    text: options[index],
                    shape: shape,
                    color: _getButtonColor(index, color, isCorrect, isWrong),
                    onPressed: widget.isSubmitted
                        ? null
                        : () => _handleAnswerTap(index),
                    isSelected: isSelected,
                    isCorrect: isCorrect,
                    isWrong: isWrong,
                    isDisabled: widget.isSubmitted && !isSelected && !isCorrect,
                  )
                  .animate()
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    delay: Duration(milliseconds: 100 * index),
                    duration: AppAnimations.mediumAnimation,
                    curve: AppAnimations.easeOut,
                  )
                  .fadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    duration: AppAnimations.mediumAnimation,
                  )
                  .scale(
                    begin: _hoveredIndex == index && !widget.isSubmitted
                        ? 1.05
                        : 1.0,
                    end: 1.0,
                    duration: AppAnimations.shortAnimation,
                  )
                  .then()
                  .animate(
                    onPlay: (controller) {
                      if (isCorrect && widget.showCorrectAnswer) {
                        controller.repeat(reverse: true);
                      }
                    },
                  )
                  .scale(
                    begin: 1.0,
                    end: isCorrect ? 1.05 : 1.0,
                    duration: AppAnimations.correctAnswerDuration,
                    curve: AppAnimations.correctAnswerCurve,
                  )
                  .then()
                  .animate(
                    onPlay: (controller) {
                      if (isWrong && widget.showCorrectAnswer) {
                        controller.forward();
                      }
                    },
                  )
                  .shakeX(
                    amount: isWrong ? 8 : 0,
                    duration: AppAnimations.wrongAnswerDuration,
                    curve: AppAnimations.wrongAnswerCurve,
                  ),
        );
      },
    );
  }

  Widget _buildTrueFalseOptions(bool correctAnswer) {
    final options = ['True', 'False'];
    final correctIndex = correctAnswer ? 0 : 1;

    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            text: 'True',
            color: AppColors.turquoise,
            shape: AnswerShape.circle,
            index: 0,
            correctIndex: correctIndex,
          ),
        ),
        AppSpacing.horizontalSpacingM,
        Expanded(
          child: _buildTrueFalseButton(
            text: 'False',
            color: AppColors.coralRed,
            shape: AnswerShape.square,
            index: 1,
            correctIndex: correctIndex,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton({
    required String text,
    required Color color,
    required AnswerShape shape,
    required int index,
    required int correctIndex,
  }) {
    final isCorrect = widget.showCorrectAnswer && index == correctIndex;
    final isSelected = _selectedIndex == index;
    final isWrong =
        widget.showCorrectAnswer && isSelected && index != correctIndex;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child:
          AnswerButton(
                text: text,
                shape: shape,
                color: _getButtonColor(index, color, isCorrect, isWrong),
                onPressed: widget.isSubmitted
                    ? null
                    : () => _handleAnswerTap(index),
                isSelected: isSelected,
                isCorrect: isCorrect,
                isWrong: isWrong,
                isDisabled: widget.isSubmitted && !isSelected && !isCorrect,
                height: 100,
              )
              .animate()
              .scale(
                begin: 0.9,
                end: 1.0,
                duration: AppAnimations.mediumAnimation,
                curve: AppAnimations.easeOut,
              )
              .fadeIn(duration: AppAnimations.mediumAnimation),
    );
  }

  Color _getButtonColor(
    int index,
    Color defaultColor,
    bool isCorrect,
    bool isWrong,
  ) {
    if (widget.showCorrectAnswer) {
      if (isCorrect) return AppColors.correctAnswer;
      if (isWrong) return AppColors.incorrectAnswer;
      if (widget.isSubmitted) return defaultColor.withOpacity(0.3);
    }

    if (_selectedIndex == index) {
      return defaultColor.withOpacity(0.8);
    }

    return defaultColor;
  }
}

/// Feedback overlay for answer results
class AnswerFeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final int? points;
  final VoidCallback? onAnimationComplete;

  const AnswerFeedbackOverlay({
    super.key,
    required this.isCorrect,
    this.points,
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Container(
                padding: EdgeInsets.all(AppSpacing.spacingXL),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.correctAnswer
                      : AppColors.incorrectAnswer,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusL,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isCorrect
                                  ? AppColors.correctAnswer
                                  : AppColors.incorrectAnswer)
                              .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 80,
                      color: AppColors.pureWhite,
                    ).animate().scale(
                      begin: 0,
                      end: 1,
                      duration: AppAnimations.correctAnswerDuration,
                      curve: AppAnimations.correctAnswerCurve,
                    ),

                    AppSpacing.verticalSpacingM,

                    Text(
                      isCorrect ? 'Correct!' : 'Incorrect',
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 32,
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: AppAnimations.shortAnimation,
                    ),

                    if (isCorrect && points != null) ...[
                      AppSpacing.verticalSpacingS,
                      Text(
                            '+$points points',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: const Duration(milliseconds: 400),
                            duration: AppAnimations.shortAnimation,
                          )
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: const Duration(milliseconds: 400),
                            duration: AppAnimations.shortAnimation,
                          ),
                    ],
                  ],
                ),
              )
              .animate()
              .scale(
                begin: 0.8,
                end: 1.0,
                duration: AppAnimations.mediumAnimation,
                curve: AppAnimations.easeOut,
              )
              .fadeIn(duration: AppAnimations.shortAnimation)
              .then(delay: const Duration(seconds: 2))
              .fadeOut(
                duration: AppAnimations.shortAnimation,
                onComplete: (_) => onAnimationComplete?.call(),
              ),
    );
  }
}
