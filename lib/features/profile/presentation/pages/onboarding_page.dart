import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../widgets/avatar_upload_widget.dart';
import '../widgets/profile_field_widget.dart';

/// User onboarding flow with profile setup
/// Kahoot-style engaging multi-step process with smooth animations
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form controllers
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _avatarImage;

  // Preferences
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _publicProfile = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: AppAnimations.easeOut,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < _totalSteps - 1) {
      await _slideController.reverse();
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: AppAnimations.mediumAnimation,
        curve: AppAnimations.easeInOut,
      );
      await _slideController.forward();
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      await _slideController.reverse();
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: AppAnimations.mediumAnimation,
        curve: AppAnimations.easeInOut,
      );
      await _slideController.forward();
    }
  }

  Future<void> _completeOnboarding() async {
    // TODO: Save onboarding data to backend
    // This would typically involve:
    // 1. Upload avatar image
    // 2. Save profile information
    // 3. Save user preferences
    // 4. Mark onboarding as complete

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    if (mounted) {
      context.go(RouteConstants.home);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Welcome step, always can proceed
      case 1:
        return _displayNameController.text.isNotEmpty &&
               _usernameController.text.isNotEmpty;
      case 2:
        return true; // Avatar step, optional
      case 3:
        return true; // Preferences step, always can proceed
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Progress Header
                  _buildProgressHeader(),
                  
                  // Page Content
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildWelcomeStep(),
                              _buildProfileInfoStep(),
                              _buildAvatarStep(),
                              _buildPreferencesStep(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Navigation Footer
                  _buildNavigationFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: AppSpacing.allL,
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: AppColors.coolGray,
                ),
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.spacingM),
          
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 60,
              color: AppColors.pureWhite,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sectionSpacing),
          
          Text(
            'Welcome to Quiz Master!',
            style: AppTextStyles.gameTitle.copyWith(
              color: AppColors.vibrantPurple,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.spacingL),
          
          Text(
            'Let\'s set up your profile and get you ready to play amazing quizzes with friends!',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.sectionSpacing),
          
          // Features Preview
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.quiz, 'text': 'Play interactive quizzes'},
      {'icon': Icons.create, 'text': 'Create your own quizzes'},
      {'icon': Icons.group, 'text': 'Challenge friends'},
      {'icon': Icons.leaderboard, 'text': 'Climb the leaderboards'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.turquoise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.turquoise,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Expanded(
                child: Text(
                  feature['text'] as String,
                  style: AppTextStyles.bodyText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfileInfoStep() {
    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.spacingL),
          
          Text(
            'Tell us about yourself',
            style: AppTextStyles.gameTitle.copyWith(
              fontSize: 28,
              color: AppColors.charcoal,
            ),
          ),
          
          const SizedBox(height: AppSpacing.spacingM),
          
          Text(
            'This information will help other players identify you in games.',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sectionSpacing),
          
          DisplayNameFieldWidget(
            controller: _displayNameController,
          ),
          
          const SizedBox(height: AppSpacing.spacingL),
          
          UsernameFieldWidget(
            controller: _usernameController,
          ),
          
          const SizedBox(height: AppSpacing.spacingL),
          
          BioFieldWidget(
            controller: _bioController,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStep() {
    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacingL),
          
          Text(
            'Choose your avatar',
            style: AppTextStyles.gameTitle.copyWith(
              fontSize: 28,
              color: AppColors.charcoal,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.spacingM),
          
          Text(
            'Add a profile photo to personalize your account. You can always change this later.',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.sectionSpacing),
          
          AvatarUploadWidget(
            onImageSelected: (image) {
              setState(() {
                _avatarImage = image;
              });
            },
            size: 150,
            fallbackText: _displayNameController.text.isNotEmpty
                ? _displayNameController.text[0].toUpperCase()
                : 'U',
          ),
          
          const SizedBox(height: AppSpacing.spacingL),
          
          if (_avatarImage == null)
            Text(
              'Tap the avatar to add a photo',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Great! Tap again to change your photo',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.spacingL),
          
          Text(
            'Set your preferences',
            style: AppTextStyles.gameTitle.copyWith(
              fontSize: 28,
              color: AppColors.charcoal,
            ),
          ),
          
          const SizedBox(height: AppSpacing.spacingM),
          
          Text(
            'Customize your experience with these settings. You can change them anytime in settings.',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sectionSpacing),
          
          _buildPreferenceToggle(
            'Email Notifications',
            'Get notified about game invites and updates',
            Icons.email_outlined,
            AppColors.turquoise,
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          
          _buildPreferenceToggle(
            'Push Notifications',
            'Receive notifications on your device',
            Icons.notifications_outlined,
            AppColors.vibrantPurple,
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          
          _buildPreferenceToggle(
            'Public Profile',
            'Allow others to view your profile and stats',
            Icons.public,
            AppColors.mintGreen,
            _publicProfile,
            (value) => setState(() => _publicProfile = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceToggle(
    String title,
    String description,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? iconColor.withValues(alpha: 0.3)
              : AppColors.lightGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
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
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Text(
                  description,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.spacingL,
        right: AppSpacing.spacingL,
        top: AppSpacing.spacingM,
        bottom: AppSpacing.spacingL + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                  side: BorderSide(color: AppColors.coolGray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.coolGray,
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: AppSpacing.spacingM),

          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: PrimaryButton(
              text: _currentStep == _totalSteps - 1 ? 'Get Started!' : 'Continue',
              onPressed: _canProceed() ? _nextStep : null,
              backgroundColor: _canProceed()
                  ? AppColors.vibrantPurple
                  : AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}