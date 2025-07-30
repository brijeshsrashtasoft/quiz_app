import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Animated button with press effects and customizable styling
/// Reference: docs/ui_guideline.md - Button interactions
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isDisabled;
  final bool isLoading;
  final IconData? icon;
  final bool iconOnRight;
  final ButtonSize size;
  final ButtonVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isDisabled = false,
    this.isLoading = false,
    this.icon,
    this.iconOnRight = false,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.padding,
    this.borderRadius,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: AppAnimations.buttonTapDuration,
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: AppAnimations.loadingRotationDuration,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: AppAnimations.buttonPressScale).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: AppAnimations.buttonTapCurve,
          ),
        );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: AppAnimations.loadingRotationCurve,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !oldWidget.isLoading) {
      _loadingController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _loadingController.stop();
      _loadingController.reset();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    if (widget.isDisabled) {
      return AppColors.disabled;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.vibrantPurple;
      case ButtonVariant.secondary:
        return AppColors.pureWhite;
      case ButtonVariant.success:
        return AppColors.success;
      case ButtonVariant.danger:
        return AppColors.error;
      case ButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (widget.textColor != null) return widget.textColor!;

    if (widget.isDisabled) {
      return AppColors.pureWhite;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.success:
      case ButtonVariant.danger:
        return AppColors.pureWhite;
      case ButtonVariant.secondary:
        return AppColors.charcoal;
      case ButtonVariant.outline:
        return _backgroundColor == Colors.transparent
            ? AppColors.vibrantPurple
            : AppColors.pureWhite;
    }
  }

  Color? get _borderColor {
    if (widget.borderColor != null) return widget.borderColor!;

    switch (widget.variant) {
      case ButtonVariant.secondary:
        return AppColors.lightGray;
      case ButtonVariant.outline:
        return AppColors.vibrantPurple;
      default:
        return null;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return AppDimensions.secondaryButtonHeight;
      case ButtonSize.medium:
        return AppDimensions.buttonHeight;
      case ButtonSize.large:
        return AppDimensions.primaryButtonHeight + 8;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return AppDimensions.iconS;
      case ButtonSize.medium:
        return AppDimensions.iconM;
      case ButtonSize.large:
        return AppDimensions.iconL;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !widget.isDisabled && !widget.isLoading,
      label: widget.text,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _loadingAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: (!widget.isDisabled && !widget.isLoading)
                  ? widget.onPressed
                  : null,
              child: Container(
                height: _height,
                padding:
                    widget.padding ??
                    EdgeInsets.symmetric(horizontal: AppSpacing.buttonPadding),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? AppDimensions.buttonRadius,
                  ),
                  border: _borderColor != null
                      ? Border.all(color: _borderColor!, width: 2)
                      : null,
                  boxShadow: !widget.isDisabled && !_isPressed
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Leading icon
                    if (widget.icon != null &&
                        !widget.iconOnRight &&
                        !widget.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.spacingS,
                        ),
                        child: Icon(
                          widget.icon,
                          color: _textColor,
                          size: _iconSize,
                        ),
                      ),

                    // Loading indicator
                    if (widget.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.spacingS,
                        ),
                        child: Transform.rotate(
                          angle: _loadingAnimation.value * 2 * 3.14159,
                          child: SizedBox(
                            width: _iconSize,
                            height: _iconSize,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _textColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Button text
                    Flexible(
                      child: Text(
                        widget.text,
                        style: _textStyle.copyWith(color: _textColor),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Trailing icon
                    if (widget.icon != null &&
                        widget.iconOnRight &&
                        !widget.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.spacingS,
                        ),
                        child: Icon(
                          widget.icon,
                          color: _textColor,
                          size: _iconSize,
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

/// Button size variants
enum ButtonSize { small, medium, large }

/// Button style variants
enum ButtonVariant { primary, secondary, success, danger, outline }

/// Floating animated button for special actions
class AnimatedFloatingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isDisabled;
  final String? tooltip;

  const AnimatedFloatingButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.isDisabled = false,
    this.tooltip,
  });

  @override
  State<AnimatedFloatingButton> createState() => _AnimatedFloatingButtonState();
}

class _AnimatedFloatingButtonState extends State<AnimatedFloatingButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: AppAnimations.buttonPressScale).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: AppAnimations.bounce,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: AppAnimations.easeInOut),
    );

    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isDisabled) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !widget.isDisabled,
      label: widget.tooltip,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * _pulseAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: AppDimensions.fabSize,
                height: AppDimensions.fabSize,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.vibrantPurple,
                  shape: BoxShape.circle,
                  boxShadow: !widget.isDisabled
                      ? [
                          BoxShadow(
                            color:
                                (widget.backgroundColor ??
                                        AppColors.vibrantPurple)
                                    .withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? AppColors.pureWhite,
                  size: AppDimensions.iconL,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
