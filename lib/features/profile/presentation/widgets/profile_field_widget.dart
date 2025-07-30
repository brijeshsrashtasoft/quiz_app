import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/inputs/text_input.dart';

/// Profile field widget for form inputs with Kahoot-style design
/// Includes validation, animations, and engaging visual feedback
class ProfileFieldWidget extends StatefulWidget {
  final String label;
  final String? value;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isRequired;
  final bool isEditable;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixIconTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const ProfileFieldWidget({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.isRequired = false,
    this.isEditable = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSuffixIconTap,
    this.controller,
    this.focusNode,
  });

  @override
  State<ProfileFieldWidget> createState() => _ProfileFieldWidgetState();
}

class _ProfileFieldWidgetState extends State<ProfileFieldWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _setupAnimations();
    _focusNode.addListener(_onFocusChange);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _colorAnimation =
        ColorTween(
          begin: AppColors.lightGray,
          end: AppColors.vibrantPurple,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppAnimations.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
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
      _validateInput();
    }
  }

  void _validateInput() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  void _onChanged(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildField(),
        );
      },
    );
  }

  Widget _buildField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.vibrantPurple.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with required indicator
          _buildLabel(),

          const SizedBox(height: AppSpacing.spacingXS),

          // Input field
          _buildInput(),

          // Helper text or error
          if (widget.helperText != null || _errorText != null)
            _buildHelperText(),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.label,
            style: AppTextStyles.inputLabel.copyWith(
              color: _errorText != null
                  ? AppColors.error
                  : _isFocused
                  ? AppColors.vibrantPurple
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: AppTextStyles.inputLabel.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return CustomTextInput(
      controller: _controller,
      focusNode: _focusNode,
      hint: widget.hint,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      enabled: widget.isEditable,
      readOnly: !widget.isEditable,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      onChanged: _onChanged,
      onTap: widget.onTap,
      errorText: _errorText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon!,
              color: _isFocused ? AppColors.vibrantPurple : AppColors.coolGray,
            )
          : null,
      suffixIcon: widget.suffixIcon != null
          ? GestureDetector(
              onTap: widget.onSuffixIconTap,
              child: Icon(
                widget.suffixIcon!,
                color: _isFocused
                    ? AppColors.vibrantPurple
                    : AppColors.coolGray,
              ),
            )
          : null,
      fillColor: widget.isEditable
          ? AppColors.pureWhite
          : AppColors.lightGray.withValues(alpha: 0.3),
      borderColor: _colorAnimation.value ?? AppColors.lightGray,
      focusedBorderColor: AppColors.vibrantPurple,
      errorBorderColor: AppColors.error,
    );
  }

  Widget _buildHelperText() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.spacingXS,
        left: AppSpacing.spacingS,
      ),
      child: AnimatedSwitcher(
        duration: AppAnimations.shortAnimation,
        child: Text(
          _errorText ?? widget.helperText ?? '',
          key: ValueKey(_errorText ?? widget.helperText),
          style: AppTextStyles.caption.copyWith(
            color: _errorText != null
                ? AppColors.error
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Specialized profile field widgets for common use cases

/// Username field with validation
class UsernameFieldWidget extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isEditable;

  const UsernameFieldWidget({
    super.key,
    this.value,
    this.onChanged,
    this.controller,
    this.isEditable = true,
  });

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldWidget(
      label: 'Username',
      value: value,
      hint: 'Enter your username',
      helperText: 'Used to identify you in games',
      prefixIcon: Icons.alternate_email,
      isRequired: true,
      isEditable: isEditable,
      maxLength: 20,
      validator: _validateUsername,
      onChanged: onChanged,
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
      ],
    );
  }
}

/// Email field with validation
class EmailFieldWidget extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isEditable;

  const EmailFieldWidget({
    super.key,
    this.value,
    this.onChanged,
    this.controller,
    this.isEditable = true,
  });

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldWidget(
      label: 'Email',
      value: value,
      hint: 'Enter your email address',
      helperText: 'Used for account recovery and notifications',
      prefixIcon: Icons.email_outlined,
      isRequired: true,
      isEditable: isEditable,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      onChanged: onChanged,
      controller: controller,
    );
  }
}

/// Display name field
class DisplayNameFieldWidget extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isEditable;

  const DisplayNameFieldWidget({
    super.key,
    this.value,
    this.onChanged,
    this.controller,
    this.isEditable = true,
  });

  String? _validateDisplayName(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 2) {
        return 'Display name must be at least 2 characters';
      }
      if (value.length > 50) {
        return 'Display name must be less than 50 characters';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldWidget(
      label: 'Display Name',
      value: value,
      hint: 'Enter your display name',
      helperText: 'How others see your name in games',
      prefixIcon: Icons.person_outline,
      isEditable: isEditable,
      maxLength: 50,
      validator: _validateDisplayName,
      onChanged: onChanged,
      controller: controller,
    );
  }
}

/// Bio field with character counter
class BioFieldWidget extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isEditable;

  const BioFieldWidget({
    super.key,
    this.value,
    this.onChanged,
    this.controller,
    this.isEditable = true,
  });

  String? _validateBio(String? value) {
    if (value != null && value.length > 200) {
      return 'Bio must be less than 200 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldWidget(
      label: 'Bio',
      value: value,
      hint: 'Tell others about yourself...',
      helperText: 'Share something interesting about yourself',
      prefixIcon: Icons.info_outline,
      isEditable: isEditable,
      maxLength: 200,
      maxLines: 3,
      validator: _validateBio,
      onChanged: onChanged,
      controller: controller,
    );
  }
}

/// Password field with visibility toggle
class PasswordFieldWidget extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isRequired;

  const PasswordFieldWidget({
    super.key,
    this.label = 'Password',
    this.hint,
    this.helperText,
    this.onChanged,
    this.controller,
    this.isRequired = true,
  });

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  bool _isObscured = true;

  String? _validatePassword(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'Password is required';
    }
    if (value != null && value.isNotEmpty) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
        return 'Password must contain uppercase, lowercase, and number';
      }
    }
    return null;
  }

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldWidget(
      label: widget.label,
      hint: widget.hint ?? 'Enter your password',
      helperText:
          widget.helperText ??
          'Must be at least 8 characters with mixed case and numbers',
      prefixIcon: Icons.lock_outline,
      suffixIcon: _isObscured ? Icons.visibility : Icons.visibility_off,
      isRequired: widget.isRequired,
      obscureText: _isObscured,
      validator: _validatePassword,
      onChanged: widget.onChanged,
      onSuffixIconTap: _toggleVisibility,
      controller: widget.controller,
    );
  }
}
