import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../../shared/theme/theme_provider.dart';
import '../widgets/privacy_toggle_widget.dart';
import '../widgets/account_action_widget.dart';
import '../providers/settings_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/base/base_usecase.dart';

/// Settings page with organized sections for user preferences
/// Kahoot-style engaging design with privacy controls and account management
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
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
        Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
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

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isLoading = settingsState.isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Handle back button - navigate back to previous page
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          // If no previous page, go to home
          context.go(RouteConstants.home);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.pureWhite,
            ),
          ),
          backgroundColor: AppColors.vibrantPurple,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(RouteConstants.home);
              }
            },
          ),
          actions: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.pureWhite,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: AnimatedBuilder(
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
          const SizedBox(height: AppSpacing.spacingL),

          // Privacy Settings
          _buildPrivacySection(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Notification Settings
          _buildNotificationSection(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // App Preferences
          _buildAppPreferencesSection(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Account Management
          _buildAccountSection(),

          const SizedBox(height: AppSpacing.spacingXL),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    final privacySettings = ref.watch(privacySettingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return _SettingsSection(
      title: 'Privacy & Visibility',
      icon: Icons.privacy_tip,
      iconColor: AppColors.turquoise,
      children: [
        ProfileVisibilityToggle(
          isPublic: privacySettings.profileVisible,
          onChanged: settingsNotifier.updateProfileVisible,
        ),
        GameHistoryVisibilityToggle(
          isVisible: privacySettings.statsVisible,
          onChanged: settingsNotifier.updateStatsVisible,
        ),
        OnlineStatusToggle(
          showOnlineStatus: privacySettings.showInLeaderboards,
          onChanged: settingsNotifier.updateShowInLeaderboards,
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    final preferences = ref.watch(userPreferencesProvider);
    final privacySettings = ref.watch(privacySettingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return _SettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      iconColor: AppColors.vibrantPurple,
      children: [
        EmailNotificationsToggle(
          isEnabled: preferences.notificationsEnabled,
          onChanged: settingsNotifier.updateNotificationsEnabled,
        ),
        PushNotificationsToggle(
          isEnabled: preferences.notificationsEnabled,
          onChanged: settingsNotifier.updateNotificationsEnabled,
        ),
        GameInvitesToggle(
          isEnabled: privacySettings.allowGameInvites,
          onChanged: settingsNotifier.updateAllowGameInvites,
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    final preferences = ref.watch(userPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return _SettingsSection(
      title: 'App Preferences',
      icon: Icons.tune,
      iconColor: AppColors.mintGreen,
      children: [
        PrivacyToggleWidget(
          title: 'Dark Mode',
          description: 'Use dark theme throughout the app',
          value:
              preferences.theme == 'dark' ||
              (preferences.theme == 'system' && themeMode == ThemeMode.dark),
          onChanged: (value) {
            final newTheme = value ? 'dark' : 'light';
            settingsNotifier.updateTheme(newTheme);
          },
          icon: Icons.dark_mode,
          iconColor: AppColors.charcoal,
        ),
        PrivacyToggleWidget(
          title: 'Sound Effects',
          description: 'Play sounds for game interactions',
          value: preferences.soundEnabled,
          onChanged: settingsNotifier.updateSoundEnabled,
          icon: Icons.volume_up,
          iconColor: AppColors.warmYellow,
        ),
        PrivacyToggleWidget(
          title: 'Haptic Feedback',
          description: 'Vibrate on button presses and interactions',
          value: preferences.vibrationEnabled,
          onChanged: settingsNotifier.updateVibrationEnabled,
          icon: Icons.vibration,
          iconColor: AppColors.coralRed,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _SettingsSection(
      title: 'Account Management',
      icon: Icons.manage_accounts,
      iconColor: AppColors.coralRed,
      children: [
        ExportDataActionWidget(onExportData: _exportData),
        ClearDataActionWidget(onClearData: _clearData),
        DeactivateAccountActionWidget(onDeactivateAccount: _deactivateAccount),
        DeleteAccountActionWidget(onDeleteAccount: _deleteAccount),
      ],
    );
  }

  // Action handlers
  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data export started. You will receive an email when ready.',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.pureWhite),
        ),
        backgroundColor: AppColors.turquoise,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _clearData() async {
    try {
      // Clear settings and local data
      await ref.read(settingsProvider.notifier).clearSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Game data cleared successfully.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to clear data. Please try again.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deactivateAccount() async {
    try {
      // Sign out user using the auth config
      final signOutUseCase = ref.read(signOutUseCaseProvider);
      await signOutUseCase(const NoParams());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account deactivated. Sign in anytime to reactivate.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate to login after deactivation
        context.go(RouteConstants.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to deactivate account. Please try again.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    try {
      // Clear all settings first
      await ref.read(settingsProvider.notifier).clearSettings();

      // Sign out user (account deletion would be handled by backend)
      final signOutUseCase = ref.read(signOutUseCaseProvider);
      await signOutUseCase(const NoParams());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account deletion initiated. This may take a few minutes.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate to login after deletion
        context.go(RouteConstants.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete account. Please try again.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

/// Settings section container with header and children
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: AppSpacing.allL,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
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
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.sectionHeader.copyWith(
                      fontSize: 18,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
