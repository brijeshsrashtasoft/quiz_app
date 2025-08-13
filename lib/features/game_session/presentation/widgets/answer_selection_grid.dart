import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/primitives/shake_widget.dart';

class AnswerSelectionGrid extends StatefulWidget {
  final List<String> answers;
  final int? selectedIndex;
  final bool showResults;
  final int? correctIndex;
  final ValueChanged<int> onAnswerSelected;
  final AnimationController? revealController;

  const AnswerSelectionGrid({
    super.key,
    required this.answers,
    this.selectedIndex,
    this.showResults = false,
    this.correctIndex,
    required this.onAnswerSelected,
    this.revealController,
  });

  @override
  State<AnswerSelectionGrid> createState() => _AnswerSelectionGridState();
}

class _AnswerSelectionGridState extends State<AnswerSelectionGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _tapControllers;
  late List<AnimationController> _resultControllers;
  final Map<int, GlobalKey<ShakeWidgetState>> _shakeKeys = {};

  @override
  void initState() {
    super.initState();
    _tapControllers = List.generate(
      widget.answers.length,
      (_) => AnimationController(
        duration: AppAnimations.buttonTapDuration,
        vsync: this,
      ),
    );

    _resultControllers = List.generate(
      widget.answers.length,
      (_) => AnimationController(
        duration: AppAnimations.correctAnswerDuration,
        vsync: this,
      ),
    );

    for (int i = 0; i < widget.answers.length; i++) {
      _shakeKeys[i] = GlobalKey<ShakeWidgetState>();
    }
  }

  @override
  void didUpdateWidget(AnswerSelectionGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showResults && !oldWidget.showResults) {
      _playResultAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _tapControllers) {
      controller.dispose();
    }
    for (var controller in _resultControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _playResultAnimations() {
    if (widget.correctIndex != null) {
      // Animate correct answer
      _resultControllers[widget.correctIndex!].forward();

      // Shake wrong answer if selected
      if (widget.selectedIndex != null &&
          widget.selectedIndex != widget.correctIndex) {
        _shakeKeys[widget.selectedIndex!]?.currentState?.shake();
      }
    }
  }

  Color _getButtonColor(int index) {
    if (!widget.showResults) {
      // Before results - show selection state
      if (widget.selectedIndex == index) {
        return AppColors.vibrantPurple;
      }
      // Default button colors
      switch (index) {
        case 0:
          return AppColors.triangleRed;
        case 1:
          return AppColors.diamondGreen;
        case 2:
          return AppColors.circleYellow;
        case 3:
          return AppColors.squareTurquoise;
        default:
          return AppColors.vibrantPurple;
      }
    } else {
      // After results - show correct/incorrect
      if (index == widget.correctIndex) {
        return AppColors.turquoise;
      } else if (index == widget.selectedIndex) {
        return AppColors.coralRed;
      } else {
        return AppColors.coolGray.withValues(alpha: 0.5);
      }
    }
  }

  IconData _getButtonShape(int index) {
    switch (index) {
      case 0:
        return Icons.change_history; // Triangle
      case 1:
        return Icons.diamond_outlined; // Diamond
      case 2:
        return Icons.circle_outlined; // Circle
      case 3:
        return Icons.square_outlined; // Square
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.answerButtonSpacing,
          mainAxisSpacing: AppSpacing.answerButtonSpacing,
          childAspectRatio: 1.8,
        ),
        itemCount: widget.answers.length,
        itemBuilder: (context, index) {
          final isCorrect = widget.showResults && index == widget.correctIndex;
          final isWrong =
              widget.showResults &&
              index == widget.selectedIndex &&
              index != widget.correctIndex;

          return ShakeWidget(
            key: _shakeKeys[index],
            child: AnimatedBuilder(
              animation: _resultControllers[index],
              builder: (context, child) {
                final scale = isCorrect
                    ? Tween<double>(begin: 1.0, end: 1.05)
                          .animate(
                            CurvedAnimation(
                              parent: _resultControllers[index],
                              curve: AppAnimations.correctAnswerCurve,
                            ),
                          )
                          .value
                    : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: _AnswerButton(
                    text: widget.answers[index],
                    color: _getButtonColor(index),
                    shape: _getButtonShape(index),
                    onPressed: widget.showResults
                        ? null
                        : () => widget.onAnswerSelected(index),
                    isSelected: widget.selectedIndex == index,
                    isCorrect: isCorrect,
                    isWrong: isWrong,
                    showResult: widget.showResults,
                    tapController: _tapControllers[index],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData shape;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;
  final AnimationController tapController;

  const _AnswerButton({
    required this.text,
    required this.color,
    required this.shape,
    this.onPressed,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
    required this.tapController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onPressed != null ? (_) => tapController.forward() : null,
      onTapUp: onPressed != null ? (_) => tapController.reverse() : null,
      onTapCancel: onPressed != null ? () => tapController.reverse() : null,
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: tapController,
        builder: (context, child) {
          final scale =
              Tween<double>(begin: 1.0, end: AppAnimations.buttonPressScale)
                  .animate(
                    CurvedAnimation(
                      parent: tapController,
                      curve: AppAnimations.buttonTapCurve,
                    ),
                  )
                  .value;

          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: isSelected && !showResult
                    ? Border.all(color: AppColors.pureWhite, width: 3)
                    : null,
              ),
              child: Stack(
                children: [
                  // Background shape icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      shape,
                      size: 32,
                      color: AppColors.pureWhite.withValues(alpha: 0.2),
                    ),
                  ),

                  // Main content
                  Center(
                    child: Padding(
                      padding: AppSpacing.allM,
                      child: Text(
                        text,
                        style: AppTextStyles.answerOption.copyWith(
                          color: AppColors.pureWhite,
                          fontWeight: isSelected || isCorrect
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Result indicator
                  if (showResult && (isCorrect || isWrong))
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCorrect ? Icons.check_rounded : Icons.close_rounded,
                          size: 20,
                          color: isCorrect
                              ? AppColors.turquoise
                              : AppColors.coralRed,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
