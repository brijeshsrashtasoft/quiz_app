import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../../core/errors/failures.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_header.dart';

/// Forgot password page with Firebase Authentication integration
/// Following Kahoot-style engaging UI design
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      result.when(
        success: (_) {
          setState(() => _emailSent = true);
        },
        failure: (failure) {
          setState(() => _errorMessage = failure.userMessage);
        },
      );
    }
  }

  void _navigateToLogin() {
    context.go(RouteConstants.login);
  }

  void _resendEmail() {
    setState(() {
      _emailSent = false;
      _errorMessage = null;
    });
    _handleSendResetEmail();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
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
    if (_emailSent) {
      return _buildSuccessState();
    }

    return _buildFormState();
  }

  Widget _buildFormState() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacingXXL),

            // Auth Header
            const AuthHeader(
              title: 'Reset Password',
              subtitle: 'Enter your email to receive reset instructions',
              icon: Icons.lock_reset,
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Instructions
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: AppSpacing.spacingS),
                  Expanded(
                    child: Text(
                      'We\'ll send you a link to reset your password. Check your email after submitting.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Email Input
            CustomTextInput(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.coolGray),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSendResetEmail(),
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.spacingS),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.errorText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
            ],

            // Send Reset Email Button
            PrimaryButton(
              text: 'Send Reset Email',
              onPressed: _isLoading ? null : _handleSendResetEmail,
              isLoading: _isLoading,
              icon: Icons.email,
            ),

            const SizedBox(height: AppSpacing.spacingXL),

            // Back to Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Remember your password? ',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.coolGray,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Sign In',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.vibrantPurple,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSuccessState() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.spacingXXL * 2),

          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.email_rounded,
              size: 60,
              color: AppColors.success,
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Success Title
          Text(
            'Check Your Email!',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.charcoal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingM),

          // Success Message
          Text(
            'We\'ve sent password reset instructions to:\n${_emailController.text.trim()}',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Instructions
          Container(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.coolGray,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spacingS),
                    Expanded(
                      child: Text(
                        'Follow the link in your email to reset your password.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      color: AppColors.coolGray,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spacingS),
                    Expanded(
                      child: Text(
                        'Check your spam folder if you don\'t see the email.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Resend Email Button
          PrimaryButton(
            text: 'Resend Email',
            onPressed: _resendEmail,
            backgroundColor: AppColors.mintGreen,
            icon: Icons.refresh,
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Back to Login Button
          PrimaryButton(
            text: 'Back to Sign In',
            onPressed: _navigateToLogin,
            backgroundColor: AppColors.coolGray,
            icon: Icons.arrow_back,
          ),

          const SizedBox(height: AppSpacing.spacingXL),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
