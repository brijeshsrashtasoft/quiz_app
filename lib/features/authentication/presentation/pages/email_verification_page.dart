import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/auth_providers.dart';
import '../widgets/form_validation_feedback.dart';

/// Email verification page with Firebase Authentication integration
/// Following Kahoot-style engaging UI design
class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _isCheckingVerification = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startPeriodicVerificationCheck();
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  void _startPeriodicVerificationCheck() {
    // Check verification status every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkEmailVerification();
        _startPeriodicVerificationCheck();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.sendEmailVerification();

    if (mounted) {
      setState(() => _isLoading = false);

      result.when(
        success: (_) {
          setState(
            () => _successMessage = 'Verification email sent successfully!',
          );
        },
        failure: (failure) {
          setState(() => _errorMessage = failure.userMessage);
        },
      );
    }
  }

  Future<void> _checkEmailVerification() async {
    if (_isCheckingVerification) return;

    setState(() => _isCheckingVerification = true);

    final authService = ref.read(authServiceProvider);

    // First reload user data to get latest verification status
    final reloadResult = await authService.reloadUser();

    if (mounted) {
      setState(() => _isCheckingVerification = false);

      reloadResult.when(
        success: (_) {
          // Check if email is now verified
          final isVerified = authService.isEmailVerified;

          if (isVerified) {
            setState(() => _successMessage = 'Email verified successfully!');
            context.go(RouteConstants.home);
          } else {
            setState(
              () => _errorMessage =
                  'Email not yet verified. Please check your email.',
            );
          }
        },
        failure: (failure) {
          setState(() => _errorMessage = failure.userMessage);
        },
      );
    }
  }

  void _signOut() {
    ref.read(authServiceProvider).signOut();
    context.go(RouteConstants.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _signOut,
            child: Text(
              'Sign Out',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.vibrantPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.spacingXXL),

          // Animated Email Icon
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
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
                    child: const Icon(
                      Icons.email_rounded,
                      size: 60,
                      color: AppColors.pureWhite,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Title
          Text(
            'Verify Your Email',
            style: AppTextStyles.gameTitle.copyWith(color: AppColors.charcoal),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingM),

          // Subtitle
          Text(
            'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Status Indicator
          Container(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: _isCheckingVerification
                  ? AppColors.vibrantPurple.withValues(alpha: 0.1)
                  : AppColors.lightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isCheckingVerification
                    ? AppColors.vibrantPurple.withValues(alpha: 0.3)
                    : AppColors.lightGray,
              ),
            ),
            child: Row(
              children: [
                if (_isCheckingVerification)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.vibrantPurple,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.coolGray,
                    size: 20,
                  ),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: Text(
                    _isCheckingVerification
                        ? 'Checking verification status...'
                        : 'We\'re automatically checking your verification status.',
                    style: AppTextStyles.caption.copyWith(
                      color: _isCheckingVerification
                          ? AppColors.vibrantPurple
                          : AppColors.coolGray,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Success/Error Messages
          if (_successMessage != null) ...[
            FormValidationFeedback(
              successMessage: _successMessage,
              isVisible: true,
            ),
            const SizedBox(height: AppSpacing.spacingL),
          ],

          if (_errorMessage != null) ...[
            FormValidationFeedback(
              errorMessage: _errorMessage,
              isVisible: true,
            ),
            const SizedBox(height: AppSpacing.spacingL),
          ],

          // Check Verification Button
          PrimaryButton(
            text: 'Check Verification Status',
            onPressed: _isCheckingVerification ? null : _checkEmailVerification,
            isLoading: _isCheckingVerification,
            icon: Icons.refresh,
          ),

          const SizedBox(height: AppSpacing.spacingM),

          // Resend Email Button
          PrimaryButton(
            text: 'Resend Verification Email',
            onPressed: _isLoading ? null : _resendVerificationEmail,
            isLoading: _isLoading,
            backgroundColor: AppColors.mintGreen,
            icon: Icons.email,
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Instructions Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGray),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What to do next:',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                _buildInstructionStep(
                  icon: Icons.email_outlined,
                  title: 'Check your email',
                  description:
                      'Look for an email from Quiz Master in your inbox',
                ),
                const SizedBox(height: AppSpacing.spacingM),
                _buildInstructionStep(
                  icon: Icons.folder_outlined,
                  title: 'Check spam folder',
                  description: 'Sometimes emails end up in spam or promotions',
                ),
                const SizedBox(height: AppSpacing.spacingM),
                _buildInstructionStep(
                  icon: Icons.link,
                  title: 'Click the link',
                  description: 'Click the verification link in the email',
                ),
                const SizedBox(height: AppSpacing.spacingM),
                _buildInstructionStep(
                  icon: Icons.check_circle_outline,
                  title: 'You\'re all set!',
                  description:
                      'Return here and you\'ll be automatically signed in',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Help Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spacingS),
                    Expanded(
                      child: Text(
                        'Need help?',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  'If you\'re having trouble with email verification, try signing out and signing in again, or contact support.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.vibrantPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.vibrantPurple),
        ),
        const SizedBox(width: AppSpacing.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
