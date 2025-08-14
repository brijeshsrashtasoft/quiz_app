import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Answer button for quiz questions with shape and color coding
/// Reference: docs/ui_guideline.md - Answer Button Colors
enum AnswerShape { triangle, diamond, circle, square }

class AnswerButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AnswerShape shape;
  final Color? color;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isWrong;
  final bool showResult;
  final bool isDisabled;
  final double? height;

  const AnswerButton({
    super.key,
    required this.text,
    required this.shape,
    this.onPressed,
    this.color,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isWrong = false,
    this.showResult = false,
    this.isDisabled = false,
    this.height,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _resultController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _resultAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _resultController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: AppAnimations.bounce),
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _resultController,
        curve: AppAnimations.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showResult && !oldWidget.showResult) {
      _resultController.forward();
    } else if (!widget.showResult && oldWidget.showResult) {
      _resultController.reverse();
    }
  }

  Color get _backgroundColor {
    if (widget.showResult || widget.isCorrect || widget.isWrong) {
      if (widget.isCorrect) return AppColors.correctAnswer;
      if (widget.isIncorrect || widget.isWrong) {
        return AppColors.incorrectAnswer;
      }
    }

    if (widget.isSelected && !widget.showResult) {
      return (widget.color ?? _getShapeColor()).withValues(alpha: 0.8);
    }

    return widget.color ?? _getShapeColor();
  }

  Color _getShapeColor() {
    switch (widget.shape) {
      case AnswerShape.triangle:
        return AppColors.triangleRed;
      case AnswerShape.diamond:
        return AppColors.diamondGreen;
      case AnswerShape.circle:
        return AppColors.circleYellow;
      case AnswerShape.square:
        return AppColors.squareTurquoise;
    }
  }

  IconData _getShapeIcon() {
    switch (widget.shape) {
      case AnswerShape.triangle:
        return Icons.change_history; // Triangle
      case AnswerShape.diamond:
        return Icons.diamond; // Diamond
      case AnswerShape.circle:
        return Icons.circle; // Circle
      case AnswerShape.square:
        return Icons.square; // Square
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getAccessibleTextColor(_backgroundColor);

    return Semantics(
      button: true,
      enabled: !widget.isDisabled,
      selected: widget.isSelected,
      label: '${widget.shape.name} answer: ${widget.text}',
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _resultAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: !widget.isDisabled ? widget.onPressed : null,
              child: Container(
                width: double.infinity,
                height: widget.height ?? AppDimensions.answerButtonHeight,
                margin: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spacingXS,
                  horizontal: AppSpacing.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: widget.isSelected && !widget.showResult
                      ? Border.all(color: AppColors.pureWhite, width: 3)
                      : null,
                  boxShadow: !widget.isDisabled
                      ? [
                          BoxShadow(
                            color: AppColors.shadowButton,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Main content
                    Center(
                      child: Row(
                        children: [
                          const SizedBox(width: AppSpacing.spacingM),
                          // Shape icon
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getShapeIcon(),
                              color: textColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingM),
                          // Answer text
                          Expanded(
                            child: Text(
                              widget.text,
                              style: AppTextStyles.buttonText.copyWith(
                                color: textColor,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingM),
                        ],
                      ),
                    ),
                    // Result indicator
                    if (widget.showResult)
                      Positioned(
                        right: AppSpacing.spacingM,
                        top: 0,
                        bottom: 0,
                        child: AnimatedBuilder(
                          animation: _resultAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _resultAnimation.value,
                              child: Center(
                                child: Icon(
                                  widget.isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: textColor,
                                  size: 28,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
