import 'package:flutter/material.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_spacing.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/constants/app_animations.dart';

/// Builder for multiple choice question options
class MultipleChoiceBuilder extends StatefulWidget {
  final List<String> options;
  final int correctAnswer;
  final Function(List<String>) onOptionsChanged;
  final Function(int) onCorrectAnswerChanged;

  const MultipleChoiceBuilder({
    super.key,
    required this.options,
    required this.correctAnswer,
    required this.onOptionsChanged,
    required this.onCorrectAnswerChanged,
  });

  @override
  State<MultipleChoiceBuilder> createState() => _MultipleChoiceBuilderState();
}

class _MultipleChoiceBuilderState extends State<MultipleChoiceBuilder>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<AnimationController> _animationControllers;
  final List<Color> _optionColors = [
    AppColors.triangleRed,
    AppColors.diamondGreen,
    AppColors.circleYellow,
    AppColors.squareTurquoise,
    AppColors.vibrantPurple,
    AppColors.mintGreen,
  ];

  final List<IconData> _optionIcons = [
    Icons.change_history, // Triangle
    Icons.diamond_outlined, // Diamond
    Icons.circle_outlined, // Circle
    Icons.square_outlined, // Square
    Icons.hexagon_outlined, // Pentagon
    Icons.star_outline, // Star
  ];

  @override
  void initState() {
    super.initState();
    _controllers = widget.options
        .map((option) => TextEditingController(text: option))
        .toList();
    _animationControllers = List.generate(
      widget.options.length,
      (index) => AnimationController(
        duration: AppAnimations.shortAnimation,
        vsync: this,
        value: 1.0,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var animController in _animationControllers) {
      animController.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (widget.options.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 6 options allowed'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      final newOptions = List<String>.from(widget.options)..add('');
      widget.onOptionsChanged(newOptions);
      _controllers.add(TextEditingController());
      _animationControllers.add(
        AnimationController(duration: AppAnimations.shortAnimation, vsync: this)
          ..forward(),
      );
    });
  }

  void _removeOption(int index) {
    if (widget.options.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum 2 options required'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    _animationControllers[index].reverse().then((_) {
      setState(() {
        final newOptions = List<String>.from(widget.options)..removeAt(index);
        widget.onOptionsChanged(newOptions);
        _controllers[index].dispose();
        _controllers.removeAt(index);
        _animationControllers[index].dispose();
        _animationControllers.removeAt(index);

        // Adjust correct answer if needed
        if (widget.correctAnswer >= index && widget.correctAnswer > 0) {
          widget.onCorrectAnswerChanged(widget.correctAnswer - 1);
        }
      });
    });
  }

  void _updateOption(int index, String value) {
    final newOptions = List<String>.from(widget.options);
    newOptions[index] = value;
    widget.onOptionsChanged(newOptions);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Answer Options',
                  style: AppTextStyles.inputLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Flexible(
                child: TextButton.icon(
                  onPressed: _addOption,
                  icon: Icon(
                    Icons.add,
                    color: AppColors.vibrantPurple,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  label: Text(
                    isSmallScreen ? 'Add' : 'Add Option',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.vibrantPurple,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Flexible(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.options.length, (index) {
                return ScaleTransition(
                  scale: _animationControllers[index],
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isSmallScreen
                          ? AppSpacing.spacingS
                          : AppSpacing.spacingM,
                    ),
                    child: _buildOptionRow(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow(int index) {
    final isCorrect = widget.correctAnswer == index;
    final color = _optionColors[index % _optionColors.length];
    final icon = _optionIcons[index % _optionIcons.length];
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final radioSize = isSmallScreen ? 28.0 : 32.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final checkIconSize = isSmallScreen ? 16.0 : 18.0;

    return IntrinsicHeight(
      child: Row(
        children: [
          // Radio button for correct answer
          GestureDetector(
            onTap: () => widget.onCorrectAnswerChanged(index),
            child: AnimatedContainer(
              duration: AppAnimations.shortAnimation,
              width: radioSize,
              height: radioSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect ? color : Colors.transparent,
                border: Border.all(
                  color: isCorrect ? color : AppColors.coolGray,
                  width: isCorrect
                      ? (isSmallScreen ? 2 : 3)
                      : (isSmallScreen ? 1.5 : 2),
                ),
              ),
              child: isCorrect
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: AppColors.pureWhite,
                        size: checkIconSize,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(
            width: isSmallScreen ? AppSpacing.spacingS : AppSpacing.spacingM,
          ),
          // Option shape icon
          Icon(icon, color: color, size: iconSize),
          SizedBox(
            width: isSmallScreen ? AppSpacing.spacingS : AppSpacing.spacingM,
          ),
          // Option input
          Expanded(
            child: TextFormField(
              controller: _controllers[index],
              decoration: InputDecoration(
                hintText: 'Option ${index + 1}',
                hintStyle: AppTextStyles.inputHint.copyWith(
                  fontSize: isSmallScreen ? 12 : 14,
                ),
                filled: true,
                fillColor: isCorrect
                    ? color.withOpacity(0.05)
                    : AppColors.offWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCorrect ? color : AppColors.lightGray,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCorrect ? color : AppColors.lightGray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen
                      ? AppSpacing.spacingS
                      : AppSpacing.spacingM,
                  vertical: isSmallScreen
                      ? AppSpacing.spacingS
                      : AppSpacing.spacingM,
                ),
                isDense: isSmallScreen,
              ),
              style: AppTextStyles.inputText.copyWith(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              onChanged: (value) => _updateOption(index, value),
            ),
          ),
          // Remove button
          if (widget.options.length > 2)
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 36 : 40,
                minHeight: isSmallScreen ? 36 : 40,
              ),
              child: Tooltip(
                message: 'Remove option',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _removeOption(index),
                    child: Container(
                      width: isSmallScreen ? 40 : 48,
                      height: isSmallScreen ? 40 : 48,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.coralRed,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
