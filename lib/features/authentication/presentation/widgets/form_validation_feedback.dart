import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Enhanced form validation feedback widget for authentication forms
/// Provides visual feedback for form validation with Kahoot-style animations
class FormValidationFeedback extends StatefulWidget {
  final String? errorMessage;
  final String? successMessage;
  final bool isVisible;
  final Widget? child;

  const FormValidationFeedback({
    super.key,
    this.errorMessage,
    this.successMessage,
    this.isVisible = true,
    this.child,
  });

  @override
  State<FormValidationFeedback> createState() => _FormValidationFeedbackState();
}

class _FormValidationFeedbackState extends State<FormValidationFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppAnimations.easeOut,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bounce,
      ),
    );
  }

  @override
  void didUpdateWidget(FormValidationFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible &&
        (widget.errorMessage != null || widget.successMessage != null)) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible &&
        widget.errorMessage == null &&
        widget.successMessage == null) {
      return widget.child ?? const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.child != null) ...[
          widget.child!,
          const SizedBox(height: AppSpacing.spacingS),
        ],
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildFeedbackContent(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackContent() {
    if (widget.errorMessage != null) {
      return _buildErrorFeedback(widget.errorMessage!);
    }

    if (widget.successMessage != null) {
      return _buildSuccessFeedback(widget.successMessage!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorFeedback(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(child: Text(message, style: AppTextStyles.errorText)),
        ],
      ),
    );
  }

  Widget _buildSuccessFeedback(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Password strength indicator widget
class PasswordStrengthIndicator extends StatefulWidget {
  final String password;
  final bool isVisible;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.isVisible = true,
  });

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.password != oldWidget.password) {
      final strength = _calculatePasswordStrength(widget.password);
      _animationController.animateTo(strength / 4.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.mintGreen;
      case 4:
      default:
        return AppColors.success;
    }
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Too weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
      default:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _calculatePasswordStrength(widget.password);
    final strengthColor = _getStrengthColor(strength);
    final strengthText = _getStrengthText(strength);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: strengthColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: strengthColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                strengthText,
                style: AppTextStyles.caption.copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingS),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              );
            },
          ),
          const SizedBox(height: AppSpacing.spacingS),
          _buildRequirements(),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    final requirements = [
      ('At least 8 characters', widget.password.length >= 8),
      ('Contains lowercase letter', widget.password.contains(RegExp(r'[a-z]'))),
      ('Contains uppercase letter', widget.password.contains(RegExp(r'[A-Z]'))),
      ('Contains number', widget.password.contains(RegExp(r'[0-9]'))),
      (
        'Contains special character',
        widget.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];

    return Column(
      children: requirements.map((req) {
        final (text, isMet) = req;
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isMet ? AppColors.success : AppColors.coolGray,
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                text,
                style: AppTextStyles.caption.copyWith(
                  color: isMet ? AppColors.success : AppColors.coolGray,
                  fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Email validation indicator widget
class EmailValidationIndicator extends StatelessWidget {
  final String email;
  final bool isVisible;

  const EmailValidationIndicator({
    super.key,
    required this.email,
    this.isVisible = true,
  });

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible || email.isEmpty) {
      return const SizedBox.shrink();
    }

    final isValid = _isValidEmail(email);
    final color = isValid ? AppColors.success : AppColors.error;
    final icon = isValid ? Icons.check_circle : Icons.error_outline;
    final text = isValid ? 'Valid email address' : 'Invalid email format';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.spacingXS),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Real-time form validation mixin
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate strong password
  String? validateStrongPassword(String? value) {
    final basicValidation = validatePassword(value);
    if (basicValidation != null) return basicValidation;

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value!)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  /// Validate password confirmation
  String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate name
  String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    return null;
  }

  /// Validate required field
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
