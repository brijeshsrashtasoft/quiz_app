import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Biometric authentication prompt widget with fingerprint and face ID support
/// Follows Kahoot-style design with security-focused UX patterns
/// Reference: docs/ui_guideline.md
class BiometricPromptWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final BiometricType biometricType;
  final VoidCallback? onAuthenticate;
  final VoidCallback? onCancel;
  final VoidCallback? onFallback;
  final bool showFallbackOption;
  final String? fallbackButtonText;

  const BiometricPromptWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.biometricType,
    this.onAuthenticate,
    this.onCancel,
    this.onFallback,
    this.showFallbackOption = true,
    this.fallbackButtonText,
  });

  @override
  State<BiometricPromptWidget> createState() => _BiometricPromptWidgetState();
}

class _BiometricPromptWidgetState extends State<BiometricPromptWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPulseAnimation();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: AppAnimations.timerWarningDuration,
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: AppAnimations.wrongAnswerDuration,
      vsync: this,
    );

    _pulseAnimation =
        Tween<double>(
          begin: AppAnimations.pulseScaleMin,
          end: AppAnimations.pulseScaleMax,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: AppAnimations.easeInOut,
          ),
        );

    _shakeAnimation =
        Tween<double>(
          begin: -AppAnimations.microSlideDistance,
          end: AppAnimations.microSlideDistance,
        ).animate(
          CurvedAnimation(
            parent: _shakeController,
            curve: AppAnimations.spring,
          ),
        );
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _showErrorShake() {
    _shakeController.reset();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleAuthenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    // Simulate authentication delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // In real implementation, this would call the actual biometric API
      widget.onAuthenticate?.call();
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed. Please try again.';
        _isAuthenticating = false;
      });
      _showErrorShake();
      HapticFeedback.heavyImpact();
    }
  }

  IconData _getBiometricIcon() {
    switch (widget.biometricType) {
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.face:
        return Icons.face;
      case BiometricType.iris:
        return Icons.visibility;
    }
  }

  String _getBiometricLabel() {
    switch (widget.biometricType) {
      case BiometricType.fingerprint:
        return 'Touch sensor';
      case BiometricType.face:
        return 'Look at camera';
      case BiometricType.iris:
        return 'Look at camera';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: AppSpacing.allL,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              widget.title,
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spacingS),
            Text(
              widget.subtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Biometric Icon with Animation
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _shakeAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: GestureDetector(
                      onTap: _handleAuthenticate,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _errorMessage != null
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.vibrantPurple.withOpacity(0.1),
                          border: Border.all(
                            color: _errorMessage != null
                                ? AppColors.error
                                : AppColors.vibrantPurple,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: _isAuthenticating
                              ? SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.vibrantPurple,
                                    ),
                                  ),
                                )
                              : Icon(
                                  _getBiometricIcon(),
                                  size: 48,
                                  color: _errorMessage != null
                                      ? AppColors.error
                                      : AppColors.vibrantPurple,
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.spacingL),

            // Instruction Text
            Text(
              _errorMessage ?? _getBiometricLabel(),
              style: AppTextStyles.body.copyWith(
                color: _errorMessage != null
                    ? AppColors.error
                    : AppColors.textSecondary,
                fontWeight: _errorMessage != null ? FontWeight.w600 : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Action Buttons
            Column(
              children: [
                if (widget.showFallbackOption) ...[
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onFallback,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.spacingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.buttonRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.fallbackButtonText ?? 'Use PIN/Password',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.vibrantPurple,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.spacingM),
                ],
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Biometric authentication setup wizard for first-time setup
class BiometricSetupWizard extends StatefulWidget {
  final List<BiometricType> availableBiometrics;
  final Function(BiometricType) onBiometricSelected;
  final VoidCallback? onSkip;

  const BiometricSetupWizard({
    super.key,
    required this.availableBiometrics,
    required this.onBiometricSelected,
    this.onSkip,
  });

  @override
  State<BiometricSetupWizard> createState() => _BiometricSetupWizardState();
}

class _BiometricSetupWizardState extends State<BiometricSetupWizard> {
  BiometricType? _selectedBiometric;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: AppSpacing.allL,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Secure Your Account',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: AppSpacing.spacingS),
            Text(
              'Choose a biometric authentication method to quickly and securely access your account.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Biometric Options
            ...widget.availableBiometrics.map(
              (biometric) => _buildBiometricOption(biometric),
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onSkip,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedBiometric != null
                        ? () => widget.onBiometricSelected(_selectedBiometric!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantPurple,
                      foregroundColor: AppColors.pureWhite,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text('Continue', style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricOption(BiometricType biometric) {
    final isSelected = _selectedBiometric == biometric;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.spacingM),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBiometric = biometric;
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          padding: AppSpacing.allM,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.vibrantPurple : AppColors.lightGray,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            color: isSelected
                ? AppColors.vibrantPurple.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.vibrantPurple.withOpacity(0.1)
                      : AppColors.lightGray.withOpacity(0.3),
                ),
                child: Icon(
                  _getBiometricIcon(biometric),
                  color: isSelected
                      ? AppColors.vibrantPurple
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getBiometricTitle(biometric),
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacingXS),
                    Text(
                      _getBiometricDescription(biometric),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.vibrantPurple,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(BiometricType biometric) {
    switch (biometric) {
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.face:
        return Icons.face;
      case BiometricType.iris:
        return Icons.visibility;
    }
  }

  String _getBiometricTitle(BiometricType biometric) {
    switch (biometric) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris Scan';
    }
  }

  String _getBiometricDescription(BiometricType biometric) {
    switch (biometric) {
      case BiometricType.fingerprint:
        return 'Use your fingerprint to unlock';
      case BiometricType.face:
        return 'Use facial recognition to unlock';
      case BiometricType.iris:
        return 'Use iris scanning to unlock';
    }
  }
}

/// Enum for different biometric authentication types
enum BiometricType { fingerprint, face, iris }
