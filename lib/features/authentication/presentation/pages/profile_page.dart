import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/navigation/app_navigation_bar.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/auth_providers.dart';

/// User profile page with account management
/// Following Kahoot-style engaging UI design
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

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
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    final confirmed = await _showSignOutDialog();
    if (confirmed && mounted) {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (mounted) {
        context.go(RouteConstants.login);
      }
    }
  }

  Future<bool> _showSignOutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign Out', style: AppTextStyles.sectionHeader),
            content: Text(
              'Are you sure you want to sign out?',
              style: AppTextStyles.bodyText,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.coolGray,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return Scaffold(
      appBar: const AppTopBar(title: 'Profile', showBackButton: true),
      backgroundColor: AppColors.offWhite,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(user),
            ),
          );
        },
      ),
      bottomNavigationBar: AppNavigationBar(
        currentRoute: RouteConstants.profile,
      ),
    );
  }

  Widget _buildContent(dynamic user) {
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.spacingL),

          // Profile Header
          _buildProfileHeader(user),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Profile Actions
          _buildProfileActions(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Account Settings
          _buildAccountSettings(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // App Settings
          _buildAppSettings(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Sign Out Button
          PrimaryButton(
            text: 'Sign Out',
            onPressed: _handleSignOut,
            icon: Icons.logout,
            backgroundColor: AppColors.error,
          ),

          const SizedBox(height: AppSpacing.spacingXL),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.pureWhite, width: 3),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: AppTextStyles.gameTitle.copyWith(
                  color: AppColors.vibrantPurple,
                  fontSize: 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.spacingM),

          // User Name
          Text(
            user.name,
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.pureWhite,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingS),

          // User Email
          Text(
            user.email,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.pureWhite.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingM),

          // Member Since
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since ${_formatDate(user.createdAt)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.pureWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: AppSpacing.spacingM),

        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.quiz,
                title: 'Create Quiz',
                subtitle: 'Make a new quiz',
                color: AppColors.vibrantPurple,
                onTap: () => context.go(RouteConstants.quizCreation),
              ),
            ),

            const SizedBox(width: AppSpacing.spacingM),

            Expanded(
              child: _ActionCard(
                icon: Icons.sports_esports,
                title: 'Host Game',
                subtitle: 'Start a session',
                color: AppColors.mintGreen,
                onTap: () => context.go(RouteConstants.gameHost),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _SettingsSection(
      title: 'Account',
      items: [
        _SettingsItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your information',
          onTap: () {
            // TODO: Navigate to edit profile
          },
        ),
        _SettingsItem(
          icon: Icons.lock,
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () {
            // TODO: Navigate to change password
          },
        ),
        _SettingsItem(
          icon: Icons.email,
          title: 'Email Preferences',
          subtitle: 'Manage notifications',
          onTap: () {
            // TODO: Navigate to email preferences
          },
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _SettingsSection(
      title: 'App Settings',
      items: [
        _SettingsItem(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences',
          onTap: () => context.go(RouteConstants.settings),
        ),
        _SettingsItem(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and support',
          onTap: () => context.go(RouteConstants.help),
        ),
        _SettingsItem(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App information',
          onTap: () => context.go(RouteConstants.about),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}

/// Action card widget for quick actions
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),

              const SizedBox(height: AppSpacing.spacingS),

              Text(
                title,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.spacingXS),

              Text(
                subtitle,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings section widget
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: AppSpacing.spacingM),

        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(children: items.map((item) => item).toList()),
        ),
      ],
    );
  }
}

/// Settings item widget
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.coolGray, size: 20),
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
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.coolGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
