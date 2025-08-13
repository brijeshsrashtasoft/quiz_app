import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Custom slider with labeled ticks for game setup
class LabeledSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final List<String> tickLabels;
  final ValueChanged<double> onChanged;
  final String? helperText;
  final String Function(double)? valueFormatter;

  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.tickLabels,
    required this.onChanged,
    this.helperText,
    this.valueFormatter,
  });

  @override
  State<LabeledSlider> createState() => _LabeledSliderState();
}

class _LabeledSliderState extends State<LabeledSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: AppColors.vibrantPurple,
      end: AppColors.turquoise,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    widget.onChanged(value);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: AppTextStyles.inputLabel),
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacingS,
                    vertical: AppSpacing.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _colorAnimation.value?.withValues(alpha: 0.1) ??
                        AppColors.vibrantPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _colorAnimation.value ?? AppColors.vibrantPurple,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.valueFormatter?.call(widget.value) ??
                        '${widget.value.toInt()}',
                    style: AppTextStyles.buttonText.copyWith(
                      color: _colorAnimation.value ?? AppColors.vibrantPurple,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingS),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.vibrantPurple,
            inactiveTrackColor: AppColors.lightGray,
            thumbColor: AppColors.vibrantPurple,
            overlayColor: AppColors.vibrantPurple.withValues(alpha: 0.1),
            valueIndicatorColor: AppColors.vibrantPurple,
            valueIndicatorTextStyle: AppTextStyles.caption.copyWith(
              color: AppColors.pureWhite,
            ),
            trackHeight: 6.0,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
          ),
          child: Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: _onSliderChanged,
          ),
        ),

        // Tick labels
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.tickLabels.map((label) {
              return Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ),

        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            widget.helperText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom number input with increment/decrement buttons
class NumberInput extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? helperText;
  final String? suffix;

  const NumberInput({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.helperText,
    this.suffix,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bounce,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value.toString();
    }
  }

  void _increment() {
    if (widget.value < widget.max) {
      widget.onChanged(widget.value + 1);
      _animateChange();
    }
  }

  void _decrement() {
    if (widget.value > widget.min) {
      widget.onChanged(widget.value - 1);
      _animateChange();
    }
  }

  void _animateChange() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _onTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue >= widget.min && intValue <= widget.max) {
      widget.onChanged(intValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.spacingS),

        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Decrement button
              _buildControlButton(
                icon: Icons.remove,
                onPressed: widget.value > widget.min ? _decrement : null,
                isEnabled: widget.value > widget.min,
              ),

              // Number display/input
              Expanded(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.spacingM,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.value.toString(),
                              style: AppTextStyles.sectionHeader.copyWith(
                                color: AppColors.vibrantPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.suffix != null) ...[
                              const SizedBox(width: AppSpacing.spacingXS),
                              Text(
                                widget.suffix!,
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Increment button
              _buildControlButton(
                icon: Icons.add,
                onPressed: widget.value < widget.max ? _increment : null,
                isEnabled: widget.value < widget.max,
              ),
            ],
          ),
        ),

        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            widget.helperText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.vibrantPurple.withValues(alpha: 0.1)
            : AppColors.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          onTap: onPressed,
          child: Icon(
            icon,
            color: isEnabled ? AppColors.vibrantPurple : AppColors.disabled,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Custom toggle switch with label and description
class SettingToggle extends StatefulWidget {
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? activeColor;

  const SettingToggle({
    super.key,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.icon,
    this.activeColor,
  });

  @override
  State<SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<SettingToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bounce,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onToggle(bool value) {
    widget.onChanged(value);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: AppSpacing.allM,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.value
                    ? (widget.activeColor ?? AppColors.vibrantPurple)
                          .withValues(alpha: 0.3)
                    : AppColors.borderLight,
                width: widget.value ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: widget.value ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onToggle(!widget.value),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      padding: EdgeInsets.all(AppSpacing.spacingS),
                      decoration: BoxDecoration(
                        color: widget.value
                            ? (widget.activeColor ?? AppColors.vibrantPurple)
                                  .withValues(alpha: 0.1)
                            : AppColors.lightGray.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: widget.value
                            ? (widget.activeColor ?? AppColors.vibrantPurple)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                  ],

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.value
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (widget.description != null) ...[
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            widget.description!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.spacingM),

                  // Custom toggle switch
                  GestureDetector(
                    onTap: () => _onToggle(!widget.value),
                    child: AnimatedContainer(
                      duration: AppAnimations.shortAnimation,
                      width: 52,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: widget.value
                            ? (widget.activeColor ?? AppColors.vibrantPurple)
                            : AppColors.lightGray,
                      ),
                      child: AnimatedAlign(
                        duration: AppAnimations.shortAnimation,
                        alignment: widget.value
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Dropdown selection with Kahoot-style design
class GameSettingDropdown extends StatefulWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? helperText;
  final IconData? prefixIcon;

  const GameSettingDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
    this.prefixIcon,
  });

  @override
  State<GameSettingDropdown> createState() => _GameSettingDropdownState();
}

class _GameSettingDropdownState extends State<GameSettingDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onExpansionChanged(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });
    if (expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.spacingS),

        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            border: Border.all(
              color: _isExpanded
                  ? AppColors.vibrantPurple
                  : AppColors.borderLight,
              width: _isExpanded ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: _isExpanded ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: widget.value,
            onChanged: (String? newValue) {
              if (newValue != null) {
                widget.onChanged(newValue);
              }
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingM,
                vertical: AppSpacing.spacingM,
              ),
              border: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColors.vibrantPurple)
                  : null,
            ),
            icon: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.vibrantPurple,
                  ),
                );
              },
            ),
            style: AppTextStyles.bodyText,
            dropdownColor: AppColors.pureWhite,
            items: widget.options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onTap: () => _onExpansionChanged(true),
          ),
        ),

        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            widget.helperText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
