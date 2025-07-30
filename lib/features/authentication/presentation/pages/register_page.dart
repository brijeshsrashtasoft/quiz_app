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
import '../widgets/social_auth_buttons.dart';

/// Register page with Firebase Authentication integration
/// Following Kahoot-style engaging UI design
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      setState(() => _errorMessage = 'Please accept the Terms of Service');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
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

  void _navigateToLogin() {
    context.go(RouteConstants.login);
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacingXL),

            // Auth Header
            const AuthHeader(
              title: 'Join the Fun!',
              subtitle: 'Create your account to start quizzing',
              icon: Icons.celebration,
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Name Input
            CustomTextInput(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              keyboardType: TextInputType.name,
              prefixIcon: Icon(
                Icons.person_outlined,
                color: AppColors.coolGray,
              ),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Email Input
            CustomTextInput(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.coolGray),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Password Input
            CustomTextInput(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a strong password',
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
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Confirm Password Input
            CustomTextInput(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icon(Icons.lock_outlined, color: AppColors.coolGray),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.coolGray,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleRegister(),
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Terms and Conditions Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) =>
                      setState(() => _acceptTerms = value ?? false),
                  activeColor: AppColors.vibrantPurple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coolGray,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.vibrantPurple,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.vibrantPurple,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

            // Register Button
            PrimaryButton(
              text: 'Create Account',
              onPressed: _isLoading ? null : _handleRegister,
              isLoading: _isLoading,
              icon: Icons.person_add,
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

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
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

            const SizedBox(height: AppSpacing.spacingXL),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
