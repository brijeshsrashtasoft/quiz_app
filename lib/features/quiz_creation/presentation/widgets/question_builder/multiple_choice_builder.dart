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
        AnimationController(
          duration: AppAnimations.shortAnimation,
          vsync: this,
        )..forward(),
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
        final newOptions = List<String>.from(widget.options)
          ..removeAt(index);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Answer Options',
              style: AppTextStyles.inputLabel,
            ),
            TextButton.icon(
              onPressed: _addOption,
              icon: Icon(
                Icons.add,
                color: AppColors.vibrantPurple,
                size: 20,
              ),
              label: Text(
                'Add Option',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: AppColors.vibrantPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingM),
        ...List.generate(widget.options.length, (index) {
          return ScaleTransition(
            scale: _animationControllers[index],
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spacingM),
              child: _buildOptionRow(index),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionRow(int index) {
    final isCorrect = widget.correctAnswer == index;
    final color = _optionColors[index % _optionColors.length];
    final icon = _optionIcons[index % _optionIcons.length];

    return Row(
      children: [
        // Radio button for correct answer
        GestureDetector(
          onTap: () => widget.onCorrectAnswerChanged(index),
          child: AnimatedContainer(
            duration: AppAnimations.shortAnimation,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect ? color : Colors.transparent,
              border: Border.all(
                color: isCorrect ? color : AppColors.coolGray,
                width: isCorrect ? 3 : 2,
              ),
            ),
            child: isCorrect
                ? Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.pureWhite,
                      size: 18,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.spacingM),
        // Option shape icon
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: AppSpacing.spacingM),
        // Option input
        Expanded(
          child: TextFormField(
            controller: _controllers[index],
            decoration: InputDecoration(
              hintText: 'Enter option ${index + 1}',
              hintStyle: AppTextStyles.inputHint,
              filled: true,
              fillColor: isCorrect ? color.withOpacity(0.05) : AppColors.offWhite,
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
                borderSide: BorderSide(
                  color: color,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingM,
                vertical: AppSpacing.spacingM,
              ),
            ),
            style: AppTextStyles.inputText,
            onChanged: (value) => _updateOption(index, value),
          ),
        ),
        // Remove button
        if (widget.options.length > 2)
          IconButton(
            onPressed: () => _removeOption(index),
            icon: Icon(
              Icons.remove_circle_outline,
              color: AppColors.coralRed,
            ),
            tooltip: 'Remove option',
          ),
      ],
    );
  }
}