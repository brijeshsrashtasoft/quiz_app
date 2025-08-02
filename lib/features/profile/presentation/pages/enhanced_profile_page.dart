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
import '../widgets/statistics_card_widget.dart';
import '../widgets/account_action_widget.dart';
import '../../../authentication/domain/entities/auth_state.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Enhanced profile page with comprehensive user information display
/// Kahoot-style engaging design with statistics, achievements, and management options
class EnhancedProfilePage extends ConsumerStatefulWidget {
  const EnhancedProfilePage({super.key});

  @override
  ConsumerState<EnhancedProfilePage> createState() =>
      _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends ConsumerState<EnhancedProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
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

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isCollapsed = _scrollController.offset > 200;
      if (isCollapsed != _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = isCollapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    final confirmed = await _showSignOutDialog();
    if (confirmed && mounted) {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (mounted) {
        context.go(RouteConstants.home);
      }
    }
  }

  Future<bool> _showSignOutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Collapsible Header
        _buildSliverAppBar(user),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacingL),

              // Quick Actions
              _buildQuickActions(),

              const SizedBox(height: AppSpacing.sectionSpacing),

              // Game Statistics
              _buildGameStatistics(),

              const SizedBox(height: AppSpacing.sectionSpacing),

              // Quiz Creation Statistics
              _buildQuizStatistics(),

              const SizedBox(height: AppSpacing.sectionSpacing),

              // Achievements
              _buildAchievements(),

              const SizedBox(height: AppSpacing.sectionSpacing),

              // Account Management
              _buildAccountManagement(),

              const SizedBox(height: AppSpacing.spacingXL),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(dynamic user) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.vibrantPurple,
      foregroundColor: AppColors.pureWhite,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          opacity: _isHeaderCollapsed ? 1.0 : 0.0,
          duration: AppAnimations.shortAnimation,
          child: Text(
            user.displayName ?? user.name,
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.pureWhite,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.allL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.spacingXL),

                  // Profile Avatar
                  AvatarUploadWidget(
                    currentImageUrl: user.photoURL,
                    onImageSelected: (image) {
                      // TODO: Handle avatar update
                    },
                    size: 100,
                    isEditable: false,
                    fallbackText: user.displayName?.isNotEmpty == true
                        ? user.displayName[0].toUpperCase()
                        : user.email[0].toUpperCase(),
                  ),

                  const SizedBox(height: AppSpacing.spacingM),

                  // User Name
                  Text(
                    user.displayName ?? user.name,
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.pureWhite,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.spacingS),

                  // Username and Email
                  if (user.username?.isNotEmpty == true)
                    Text(
                      '@${user.username}',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.pureWhite.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: AppSpacing.spacingXS),

                  Text(
                    user.email,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.pureWhite.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.spacingM),

                  // Edit Profile Button
                  OutlinedButton.icon(
                    onPressed: () => context.go(RouteConstants.editProfile),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pureWhite,
                      side: const BorderSide(color: AppColors.pureWhite),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                context.go(RouteConstants.settings);
                break;
              case 'help':
                context.go(RouteConstants.help);
                break;
              case 'signout':
                _handleSignOut();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('Help & Support'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'signout',
              child: ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: AppSpacing.horizontalL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
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

              const SizedBox(width: AppSpacing.spacingM),

              Expanded(
                child: _ActionCard(
                  icon: Icons.group_add,
                  title: 'Join Game',
                  subtitle: 'Enter PIN',
                  color: AppColors.turquoise,
                  onTap: () => context.go(RouteConstants.gameJoin),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatistics() {
    return Padding(
      padding: AppSpacing.horizontalL,
      child: GameStatisticsCard(
        gamesPlayed: 45,
        gamesWon: 28,
        totalScore: 125670,
        currentStreak: 5,
        bestStreak: 12,
        winRate: 62.2,
      ),
    );
  }

  Widget _buildQuizStatistics() {
    return Padding(
      padding: AppSpacing.horizontalL,
      child: QuizStatisticsCard(
        quizzesCreated: 8,
        totalPlays: 234,
        averageRating: 4, // Out of 5
        favoriteCount: 67,
      ),
    );
  }

  Widget _buildAchievements() {
    return Padding(
      padding: AppSpacing.horizontalL,
      child: AchievementStatisticsCard(
        totalAchievements: 24,
        unlockedAchievements: 16,
        level: 7,
        experiencePoints: 3450,
      ),
    );
  }

  Widget _buildAccountManagement() {
    return Padding(
      padding: AppSpacing.horizontalL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Management',
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
          ),

          const SizedBox(height: AppSpacing.spacingM),

          ExportDataActionWidget(
            onExportData: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data export started. You will receive an email when ready.',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                  backgroundColor: AppColors.turquoise,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),

          ClearDataActionWidget(
            onClearData: () {
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
            },
          ),

          DeleteAccountActionWidget(
            onDeleteAccount: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account deletion initiated.',
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
              context.go(RouteConstants.login);
            },
          ),
        ],
      ),
    );
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
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: AppColors.shadowLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.allM,
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
