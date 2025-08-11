import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../../core/errors/failures.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/form_validation_feedback.dart';

/// Login page with Firebase Authentication integration
/// Following Kahoot-style engaging UI design
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin, FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonBounceAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
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

    _buttonAnimationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppAnimations.bounce,
          ),
        );

    _buttonBounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: AppAnimations.elastic,
      ),
    );

    _animationController.forward();
    // Subtle continuous bounce for sign-in button
    _buttonAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      result.when(
        success: (_) {
          // Navigation handled by auth state listener
          context.go(RouteConstants.home);
        },
        failure: (failure) {
          setState(() => _errorMessage = failure.userMessage);
        },
      );
    }
  }

  void _navigateToRegister() {
    context.go(RouteConstants.register);
  }

  void _navigateToForgotPassword() {
    context.go(RouteConstants.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.charcoal),
          onPressed: () => context.go(RouteConstants.home),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.vibrantPurple.withValues(alpha: 0.05),
              AppColors.turquoise.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacingXXL),

            // Auth Header with animated icon
            const AuthHeader(
              title: 'Welcome Back!',
              subtitle: 'Sign in to join amazing quizzes',
              icon: Icons.quiz,
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Email Input
            CustomTextInput(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.coolGray),
              textInputAction: TextInputAction.next,
              validator: validateEmail,
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Password Input
            CustomTextInput(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              prefixIcon: Icon(Icons.lock_outlined, color: AppColors.coolGray),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.coolGray,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              validator: (value) => validatePassword(value, minLength: 6),
            ),

            const SizedBox(height: AppSpacing.spacingM),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _navigateToForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.vibrantPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Error Message with animation
            AnimatedSwitcher(
              duration: AppAnimations.shortAnimation,
              child: _errorMessage != null
                  ? Container(
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
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.spacingS),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.errorText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (_errorMessage != null)
              const SizedBox(height: AppSpacing.spacingL),

            PrimaryButton(
              text: 'Sign In',
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              icon: Icons.login,
              backgroundColor: AppColors.vibrantPurple,
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.lightGray)),
                Padding(
                  padding: AppSpacing.horizontalM,
                  child: Text(
                    'OR',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.lightGray)),
              ],
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Social Auth Buttons
            const SocialAuthButtons(),

            const SizedBox(height: AppSpacing.spacingXL),

            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.coolGray,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(
                    'Create account',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.vibrantPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacingXL),
          ],
        ),
      ),
    );
  }
}
