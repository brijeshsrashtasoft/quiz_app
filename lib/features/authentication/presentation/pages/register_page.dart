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

/// Register page with Firebase Authentication integration
/// Following Kahoot-style engaging UI design
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with TickerProviderStateMixin, FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _formFieldAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formFieldStaggerAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Listen for password changes to update strength indicator
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _formFieldAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
            curve: AppAnimations.bounce,
          ),
        );

    _formFieldStaggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formFieldAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animationController.forward();
    _formFieldAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _formFieldAnimationController.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.mintGreen.withValues(alpha: 0.05),
              AppColors.warmYellow.withValues(alpha: 0.05),
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
            const SizedBox(height: AppSpacing.spacingXL),

            // Auth Header with celebration animation
            const AuthHeader(
              title: 'Join the Fun!',
              subtitle: 'Create your account to start quizzing',
              icon: Icons.celebration,
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Name Input with stagger animation
            _buildStaggeredFormField(
              delay: 0.0,
              child: CustomTextInput(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                keyboardType: TextInputType.name,
                prefixIcon: Icon(
                  Icons.person_outlined,
                  color: AppColors.vibrantPurple,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => validateName(value, minLength: 2),
              ),
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Email Input with stagger animation
            _buildStaggeredFormField(
              delay: 0.1,
              child: CustomTextInput(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.turquoise,
                ),
                textInputAction: TextInputAction.next,
                validator: validateEmail,
              ),
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Password Input with stagger animation
            _buildStaggeredFormField(
              delay: 0.2,
              child: CustomTextInput(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a strong password',
                obscureText: _obscurePassword,
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: AppColors.mintGreen,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.coolGray,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                textInputAction: TextInputAction.next,
                validator: validateStrongPassword,
              ),
            ),

            const SizedBox(height: AppSpacing.spacingM),

            // Password Strength Indicator
            PasswordStrengthIndicator(
              password: _passwordController.text,
              isVisible: _passwordController.text.isNotEmpty,
            ),

            const SizedBox(height: AppSpacing.spacingL),

            // Confirm Password Input with stagger animation
            _buildStaggeredFormField(
              delay: 0.3,
              child: CustomTextInput(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm your password',
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: AppColors.warmYellow,
                ),
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
                validator: (value) => validatePasswordConfirmation(
                  value,
                  _passwordController.text,
                ),
              ),
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

            // Register Button with pop animation
            _buildStaggeredFormField(
              delay: 0.4,
              child: PrimaryButton(
                text: 'Create Account',
                onPressed: _isLoading ? null : _handleRegister,
                isLoading: _isLoading,
                icon: Icons.person_add,
                backgroundColor: AppColors.mintGreen,
              ),
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

  Widget _buildStaggeredFormField({
    required double delay,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _formFieldStaggerAnimation,
      builder: (context, _) {
        final animationValue = Curves.easeOutBack.transform(
          (_formFieldStaggerAnimation.value - delay).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: child,
          ),
        );
      },
    );
  }
}
