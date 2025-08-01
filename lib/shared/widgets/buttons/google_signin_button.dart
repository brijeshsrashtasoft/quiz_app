import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';
import '../../../core/navigation/route_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../features/authentication/presentation/providers/auth_providers.dart';

/// Reusable Google Sign-In button widget
/// Provides consistent Google Sign-In functionality across the app
class GoogleSignInButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool showIcon;
  final bool isCompact;

  const GoogleSignInButton({
    super.key,
    this.label = 'Continue with Google',
    this.onSuccess,
    this.onError,
    this.showIcon = true,
    this.isCompact = false,
  });

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
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

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();

      if (mounted) {
        result.when(
          success: (_) {
            widget.onSuccess?.call();
            // Navigate to home page on success
            context.go(RouteConstants.home);
          },
          failure: (failure) {
            widget.onError?.call();
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.userMessage),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(AppSpacing.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isLoading) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!_isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.isCompact ? 44.0 : AppDimensions.buttonHeight;
    
    return Semantics(
      button: true,
      enabled: !_isLoading,
      label: widget.label,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: _isLoading ? null : _handleGoogleSignIn,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: _isLoading ? AppColors.disabled : AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(
                    widget.isCompact ? 8 : AppDimensions.buttonRadius,
                  ),
                  border: Border.all(
                    color: _isLoading 
                        ? AppColors.lightGray 
                        : AppColors.lightGray.withOpacity(0.8),
                  ),
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.shadowButton,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.coolGray,
                          ),
                        ),
                      )
                    else if (widget.showIcon) ...[
                      // Google logo placeholder - in a real app, use Google logo asset
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.vibrantPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'G',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    
                    if (widget.showIcon && !_isLoading)
                      const SizedBox(width: AppSpacing.spacingM),
                    
                    if (!widget.isCompact || !widget.showIcon)
                      Text(
                        _isLoading ? 'Signing in...' : widget.label,
                        style: widget.isCompact 
                            ? AppTextStyles.caption.copyWith(
                                color: _isLoading 
                                    ? AppColors.coolGray 
                                    : AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              )
                            : AppTextStyles.buttonText.copyWith(
                                color: _isLoading 
                                    ? AppColors.coolGray 
                                    : AppColors.charcoal,
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

/// Compact Google Sign-In button for use in limited space
class CompactGoogleSignInButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const CompactGoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleSignInButton(
      label: 'Google',
      onSuccess: onSuccess,
      onError: onError,
      showIcon: true,
      isCompact: true,
    );
  }
}