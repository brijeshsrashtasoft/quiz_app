import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Reusable authentication header widget
/// Provides consistent branding and messaging across auth screens
class AuthHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.longAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bounce,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.elastic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated Icon with pulse
        AnimatedBuilder(
          animation: Listenable.merge([_animationController, _pulseController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (widget.iconColor ?? AppColors.vibrantPurple)
                            .withValues(alpha: 0.2),
                        (widget.iconColor ?? AppColors.vibrantPurple)
                            .withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.iconColor ?? AppColors.vibrantPurple,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.iconColor ?? AppColors.vibrantPurple)
                            .withValues(alpha: 0.3 * _scaleAnimation.value),
                        blurRadius: 30 * _scaleAnimation.value,
                        spreadRadius: 10 * _scaleAnimation.value,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 50,
                    color: widget.iconColor ?? AppColors.vibrantPurple,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.spacingL),

        // Title with fade animation
        FadeTransition(
          opacity: _scaleAnimation,
          child: Text(
            widget.title,
            style: AppTextStyles.gameTitle.copyWith(color: AppColors.charcoal),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSpacing.spacingS),

        // Subtitle with delayed fade
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
          ),
          child: Text(
            widget.subtitle,
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Quiz-themed auth header with app branding
class QuizAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const QuizAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo/Brand
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.quiz, size: 60, color: AppColors.pureWhite),
        ),

        const SizedBox(height: AppSpacing.spacingL),

        // App Name
        Text(
          'Quiz Master',
          style: AppTextStyles.gameTitle.copyWith(
            color: AppColors.vibrantPurple,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.spacingS),

        // Title
        Text(
          title,
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.spacingXS),

        // Subtitle
        Text(
          subtitle,
          style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Minimalist auth header for focused experiences
class MinimalAuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const MinimalAuthHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.gameTitle.copyWith(
            color: AppColors.charcoal,
            fontSize: 32,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            subtitle!,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
              fontSize: 18,
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.spacingL),

        // Accent Line
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
