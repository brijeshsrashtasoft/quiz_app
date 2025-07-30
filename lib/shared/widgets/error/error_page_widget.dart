import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_animations.dart';
import '../buttons/primary_button.dart';
import '../layout/page_layout.dart';
import '../../../core/navigation/route_constants.dart';

/// Comprehensive error page widget for handling various error states
/// Provides user-friendly error messages and recovery options
class ErrorPageWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final String? errorCode;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool showHomeButton;
  final bool showBackButton;
  final List<Widget>? additionalActions;

  const ErrorPageWidget({
    super.key,
    this.title,
    this.message,
    this.errorCode,
    this.icon,
    this.onRetry,
    this.retryButtonText,
    this.showHomeButton = true,
    this.showBackButton = true,
    this.additionalActions,
  });

  @override
  State<ErrorPageWidget> createState() => _ErrorPageWidgetState();
}

class _ErrorPageWidgetState extends State<ErrorPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
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

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(context),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.spacingXXL * 2),

          // Error Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.icon ?? Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Error Title
          Text(
            widget.title ?? 'Oops! Something went wrong',
            style: AppTextStyles.gameTitle.copyWith(
              color: AppColors.charcoal,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingM),

          // Error Message
          Text(
            widget.message ??
                'We encountered an unexpected error. Please try again.',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          // Error Code (if provided)
          if (widget.errorCode != null) ...[
            const SizedBox(height: AppSpacing.spacingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingM,
                vertical: AppSpacing.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Error Code: ${widget.errorCode}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.spacingXXL),

          // Action Buttons
          _buildActionButtons(context),

          const SizedBox(height: AppSpacing.spacingXL),

          // Additional Actions
          if (widget.additionalActions != null) ...[
            ...widget.additionalActions!,
            const SizedBox(height: AppSpacing.spacingL),
          ],

          // Help Text
          _buildHelpSection(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Retry Button
        if (widget.onRetry != null)
          PrimaryButton(
            text: widget.retryButtonText ?? 'Try Again',
            onPressed: widget.onRetry,
            icon: Icons.refresh,
            backgroundColor: AppColors.vibrantPurple,
          ),

        if (widget.onRetry != null &&
            (widget.showHomeButton || widget.showBackButton))
          const SizedBox(height: AppSpacing.spacingM),

        // Home and Back Buttons
        Row(
          children: [
            // Back Button
            if (widget.showBackButton && context.canPop())
              Expanded(
                child: PrimaryButton(
                  text: 'Go Back',
                  onPressed: () => context.pop(),
                  icon: Icons.arrow_back,
                  backgroundColor: AppColors.coolGray,
                ),
              ),

            if (widget.showBackButton &&
                widget.showHomeButton &&
                context.canPop())
              const SizedBox(width: AppSpacing.spacingM),

            // Home Button
            if (widget.showHomeButton)
              Expanded(
                child: PrimaryButton(
                  text: 'Go Home',
                  onPressed: () => context.go(RouteConstants.home),
                  icon: Icons.home,
                  backgroundColor: AppColors.mintGreen,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.coolGray, size: 20),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                'Need Help?',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'If this problem persists, please contact support or check our help section for troubleshooting tips.',
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => context.go(RouteConstants.help),
                icon: Icon(
                  Icons.help,
                  size: 16,
                  color: AppColors.vibrantPurple,
                ),
                label: Text(
                  'Help Center',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.vibrantPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingM),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement support contact
                },
                icon: Icon(
                  Icons.email,
                  size: 16,
                  color: AppColors.vibrantPurple,
                ),
                label: Text(
                  'Contact Support',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.vibrantPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 404 Not Found error page
class NotFoundErrorWidget extends StatelessWidget {
  const NotFoundErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorPageWidget(
      title: '404 - Page Not Found',
      message: 'The page you\'re looking for doesn\'t exist or has been moved.',
      icon: Icons.search_off,
      errorCode: '404',
      showBackButton: true,
      showHomeButton: true,
      additionalActions: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.info, size: 24),
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                'Quick Navigation',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              Wrap(
                spacing: AppSpacing.spacingS,
                runSpacing: AppSpacing.spacingS,
                alignment: WrapAlignment.center,
                children: [
                  _QuickNavChip(
                    label: 'Create Quiz',
                    route: RouteConstants.quizCreation,
                  ),
                  _QuickNavChip(
                    label: 'Join Game',
                    route: RouteConstants.gameJoin,
                  ),
                  _QuickNavChip(
                    label: 'Leaderboard',
                    route: RouteConstants.leaderboard,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Network error page
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorPageWidget(
      title: 'Connection Problem',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      errorCode: 'NETWORK_ERROR',
      onRetry: onRetry,
      retryButtonText: 'Retry Connection',
      showBackButton: false,
      showHomeButton: true,
    );
  }
}

/// Authentication error page
class AuthErrorWidget extends StatelessWidget {
  final String? message;

  const AuthErrorWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return ErrorPageWidget(
      title: 'Authentication Error',
      message: message ?? 'Please sign in again to continue.',
      icon: Icons.lock_outline,
      errorCode: 'AUTH_ERROR',
      showBackButton: false,
      showHomeButton: false,
      additionalActions: [
        PrimaryButton(
          text: 'Sign In',
          onPressed: () => context.go(RouteConstants.login),
          icon: Icons.login,
          backgroundColor: AppColors.vibrantPurple,
        ),
      ],
    );
  }
}

/// Quick navigation chip for error pages
class _QuickNavChip extends StatelessWidget {
  final String label;
  final String route;

  const _QuickNavChip({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.vibrantPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.vibrantPurple.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.vibrantPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
