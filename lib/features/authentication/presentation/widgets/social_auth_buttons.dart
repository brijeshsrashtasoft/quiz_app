import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/auth_providers.dart';

/// Social authentication buttons widget with integrated auth functionality
/// Provides consistent UI for social login options
class SocialAuthButtons extends ConsumerStatefulWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool isLoading;

  const SocialAuthButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
    this.isLoading = false,
  });

  @override
  ConsumerState<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends ConsumerState<SocialAuthButtons> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (widget.onGooglePressed != null) {
      widget.onGooglePressed!();
      return;
    }

    setState(() => _isGoogleLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();

      if (mounted) {
        result.when(
          success: (_) {
            // Navigation handled by auth state listener
            context.go(RouteConstants.home);
          },
          failure: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.userMessage),
                backgroundColor: AppColors.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading || _isGoogleLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google Sign In
        _SocialAuthButton(
          text: _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
          icon: Icons.g_mobiledata, // Placeholder - would use Google logo
          backgroundColor: AppColors.pureWhite,
          textColor: AppColors.charcoal,
          borderColor: AppColors.lightGray,
          onPressed: isLoading ? null : _handleGoogleSignIn,
          isEnabled: !isLoading,
          isLoading: _isGoogleLoading,
        ),

        const SizedBox(height: AppSpacing.spacingM),

        // Apple Sign In (iOS specific)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          _SocialAuthButton(
            text: 'Continue with Apple',
            icon: Icons.apple, // Placeholder - would use Apple logo
            backgroundColor: AppColors.charcoal,
            textColor: AppColors.pureWhite,
            onPressed: isLoading ? null : widget.onApplePressed,
            isEnabled: widget.onApplePressed != null && !isLoading,
            isLoading: false, // Apple sign-in loading state not implemented yet
          ),

          const SizedBox(height: AppSpacing.spacingM),
        ],

        // Facebook Sign In
        _SocialAuthButton(
          text: 'Continue with Facebook',
          icon: Icons.facebook, // Placeholder - would use Facebook logo
          backgroundColor: const Color(0xFF1877F2), // Facebook Blue
          textColor: AppColors.pureWhite,
          onPressed: isLoading ? null : widget.onFacebookPressed,
          isEnabled: widget.onFacebookPressed != null && !isLoading,
          isLoading:
              false, // Facebook sign-in loading state not implemented yet
        ),
      ],
    );
  }
}

/// Individual social authentication button
class _SocialAuthButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  const _SocialAuthButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  State<_SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<_SocialAuthButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.isEnabled && widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: widget.text,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: isInteractive ? widget.onPressed : null,
              child: Container(
                height: AppDimensions.buttonHeight,
                decoration: BoxDecoration(
                  color: widget.isEnabled
                      ? widget.backgroundColor
                      : AppColors.disabled,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                  border: widget.borderColor != null
                      ? Border.all(color: widget.borderColor!)
                      : null,
                  boxShadow: isInteractive
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.textColor,
                          ),
                        ),
                      )
                    else
                      Icon(
                        widget.icon,
                        color: widget.isEnabled
                            ? widget.textColor
                            : AppColors.coolGray,
                        size: 24,
                      ),
                    const SizedBox(width: AppSpacing.spacingM),
                    Text(
                      widget.text,
                      style: AppTextStyles.buttonText.copyWith(
                        color: widget.isEnabled
                            ? widget.textColor
                            : AppColors.coolGray,
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

/// Compact social auth buttons for limited space
class CompactSocialAuthButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool isLoading;

  const CompactSocialAuthButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      // Google
      if (onGooglePressed != null)
        _CompactSocialButton(
          icon: Icons.g_mobiledata,
          backgroundColor: AppColors.pureWhite,
          iconColor: AppColors.charcoal,
          borderColor: AppColors.lightGray,
          onPressed: isLoading ? null : onGooglePressed,
          tooltip: 'Sign in with Google',
        ),

      // Apple (iOS only)
      if (onApplePressed != null &&
          Theme.of(context).platform == TargetPlatform.iOS)
        _CompactSocialButton(
          icon: Icons.apple,
          backgroundColor: AppColors.charcoal,
          iconColor: AppColors.pureWhite,
          onPressed: isLoading ? null : onApplePressed,
          tooltip: 'Sign in with Apple',
        ),

      // Facebook
      if (onFacebookPressed != null)
        _CompactSocialButton(
          icon: Icons.facebook,
          backgroundColor: const Color(0xFF1877F2),
          iconColor: AppColors.pureWhite,
          onPressed: isLoading ? null : onFacebookPressed,
          tooltip: 'Sign in with Facebook',
        ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

/// Compact circular social button
class _CompactSocialButton extends StatefulWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final String tooltip;

  const _CompactSocialButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.borderColor,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_CompactSocialButton> createState() => _CompactSocialButtonState();
}

class _CompactSocialButtonState extends State<_CompactSocialButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: widget.onPressed,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  shape: BoxShape.circle,
                  border: widget.borderColor != null
                      ? Border.all(color: widget.borderColor!)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowButton,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 24),
              ),
            ),
          );
        },
      ),
    );
  }
}
