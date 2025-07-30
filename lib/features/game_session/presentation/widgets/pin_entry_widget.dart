import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class PinEntryWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onCompleted;
  final int pinLength;

  const PinEntryWidget({
    super.key,
    required this.controller,
    this.onCompleted,
    this.pinLength = 6,
  });

  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.pinLength, (_) => FocusNode());
    _controllers = List.generate(widget.pinLength, (_) => TextEditingController());
    _animationControllers = [];
    _scaleAnimations = [];
    
    // Listen to main controller changes
    widget.controller.addListener(_updateIndividualControllers);
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var animController in _animationControllers) {
      animController.dispose();
    }
    widget.controller.removeListener(_updateIndividualControllers);
    super.dispose();
  }

  void _updateIndividualControllers() {
    final text = widget.controller.text;
    for (int i = 0; i < widget.pinLength; i++) {
      if (i < text.length) {
        _controllers[i].text = text[i];
      } else {
        _controllers[i].clear();
      }
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Update main controller
      String newPin = '';
      for (int i = 0; i < widget.pinLength; i++) {
        if (i == index) {
          newPin += value[value.length - 1];
        } else {
          newPin += _controllers[i].text;
        }
      }
      widget.controller.text = newPin;
      
      // Move to next field
      if (index < widget.pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // All fields filled
        _focusNodes[index].unfocus();
        widget.onCompleted?.call();
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.pinLength, (index) {
        return AnimatedContainer(
          duration: AppAnimations.shortAnimation,
          margin: EdgeInsets.symmetric(
            horizontal: index == widget.pinLength ~/ 2 
                ? AppSpacing.spacingM 
                : AppSpacing.spacingS,
          ),
          child: _PinDigitField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) => _onChanged(value, index),
            onKeyEvent: (event) => _handleKeyEvent(event, index),
            isActive: _focusNodes[index].hasFocus,
          ),
        );
      }),
    );
  }
}

class _PinDigitField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Function(RawKeyEvent) onKeyEvent;
  final bool isActive;

  const _PinDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.isActive,
  });

  @override
  State<_PinDigitField> createState() => _PinDigitFieldState();
}

class _PinDigitFieldState extends State<_PinDigitField> 
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
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.elastic,
    ));
    
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.controller.text.isNotEmpty) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              color: widget.isActive 
                  ? AppColors.vibrantPurple.withOpacity(0.1)
                  : AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isActive 
                    ? AppColors.vibrantPurple 
                    : AppColors.lightGray,
                width: widget.isActive ? 2 : 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: AppColors.vibrantPurple.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: widget.onKeyEvent,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onChanged: widget.onChanged,
                textAlign: TextAlign.center,
                style: AppTextStyles.timerDisplay.copyWith(
                  fontSize: 32,
                  color: AppColors.charcoal,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}