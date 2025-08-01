import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Custom text input following Kahoot-style design system
/// Reference: docs/ui_guideline.md
class CustomTextInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsets? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const CustomTextInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextInput> createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<double> _errorShakeAnimation;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _errorShakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(CustomTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadError = _hasError;
    _hasError = widget.errorText != null;

    if (_hasError && !hadError) {
      // Trigger shake animation on new error
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? (widget.errorBorderColor ?? AppColors.error)
        : _isFocused
        ? (widget.focusedBorderColor ?? AppColors.vibrantPurple)
        : (widget.borderColor ?? AppColors.borderLight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.inputLabel.copyWith(
              color: hasError ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.spacingXS),
        ],

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: hasError
                  ? Offset(
                      _errorShakeAnimation.value *
                          (1 - _animationController.value),
                      0,
                    )
                  : Offset.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.fillColor ?? AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? AppDimensions.inputRadius,
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: _isFocused ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (_isFocused)
                      BoxShadow(
                        color: borderColor.withOpacity(
                          0.2 * _focusAnimation.value,
                        ),
                        offset: Offset(0, 4 * _focusAnimation.value),
                        blurRadius: 12 * _focusAnimation.value,
                        spreadRadius: 2 * _focusAnimation.value,
                      ),
                  ],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onSubmitted,
                  onTap: widget.onTap,
                  validator: widget.validator,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  autofocus: widget.autofocus,
                  textCapitalization: widget.textCapitalization,
                  style: widget.textStyle ?? AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: widget.hintStyle ?? AppTextStyles.inputHint,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.suffixIcon,
                    prefixText: widget.prefixText,
                    suffixText: widget.suffixText,
                    contentPadding:
                        widget.contentPadding ??
                        EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacingM,
                          vertical: AppSpacing.spacingM,
                        ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            );
          },
        ),

        if (widget.errorText != null) ...[
          SizedBox(height: AppSpacing.spacingXS),
          Text(
            widget.errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: AppSpacing.spacingXS),
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

/// Search input with search icon and clear functionality
class SearchInput extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchInput({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextInput(
      controller: _controller,
      hint: widget.hint ?? 'Search...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      autofocus: widget.autofocus,
      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
      suffixIcon: _hasText
          ? IconButton(
              onPressed: _onClear,
              icon: Icon(Icons.clear, color: AppColors.textSecondary),
            )
          : null,
    );
  }
}

/// PIN input for game session codes
class PinInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  const PinInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _values = List.filled(widget.length, '');

    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() => _onChanged(i));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index) {
    final value = _controllers[index].text;
    _values[index] = value;

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final pin = _values.join();
    widget.onChanged?.call(pin);

    if (pin.length == widget.length) {
      widget.onCompleted?.call(pin);
    }
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].selection = TextSelection.fromPosition(
          TextPosition(offset: _controllers[index - 1].text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyDown(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              maxLength: 1,
              autofocus: index == 0 && widget.autofocus,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.inputRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.inputRadius,
                  ),
                  borderSide: BorderSide(
                    color: AppColors.vibrantPurple,
                    width: 2,
                  ),
                ),
                fillColor: AppColors.pureWhite,
                filled: true,
              ),
            ),
          ),
        );
      }),
    );
  }
}
