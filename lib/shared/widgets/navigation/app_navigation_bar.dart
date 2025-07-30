import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_dimensions.dart';
import '../../../core/navigation/route_constants.dart';
import '../../../features/authentication/presentation/providers/auth_providers.dart';

/// App navigation bar with dynamic state based on authentication
/// Following Material Design 3 navigation principles with Kahoot styling
class AppNavigationBar extends ConsumerWidget {
  final String currentRoute;
  final Function(String)? onDestinationSelected;

  const AppNavigationBar({
    super.key,
    required this.currentRoute,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.value?.isAuthenticated ?? false;

    if (!isAuthenticated) {
      // Don't show navigation bar for unauthenticated users
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    final items = [
      _NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        route: RouteConstants.home,
        isActive: _isActiveRoute(RouteConstants.home),
        onTap: () => _handleNavigation(context, RouteConstants.home),
      ),
      _NavigationItem(
        icon: Icons.quiz_outlined,
        activeIcon: Icons.quiz,
        label: 'Create',
        route: RouteConstants.quizCreation,
        isActive: _isActiveRoute(RouteConstants.quizCreation),
        onTap: () => _handleNavigation(context, RouteConstants.quizCreation),
      ),
      _NavigationItem(
        icon: Icons.sports_esports_outlined,
        activeIcon: Icons.sports_esports,
        label: 'Join',
        route: RouteConstants.gameJoin,
        isActive: _isActiveRoute(RouteConstants.gameJoin),
        onTap: () => _handleNavigation(context, RouteConstants.gameJoin),
      ),
      _NavigationItem(
        icon: Icons.leaderboard_outlined,
        activeIcon: Icons.leaderboard,
        label: 'Leaderboard',
        route: RouteConstants.leaderboard,
        isActive: _isActiveRoute(RouteConstants.leaderboard),
        onTap: () => _handleNavigation(context, RouteConstants.leaderboard),
      ),
      _NavigationItem(
        icon: Icons.person_outlined,
        activeIcon: Icons.person,
        label: 'Profile',
        route: RouteConstants.profile,
        isActive: _isActiveRoute(RouteConstants.profile),
        onTap: () => _handleNavigation(context, RouteConstants.profile),
      ),
    ];

    return items;
  }

  bool _isActiveRoute(String route) {
    return currentRoute.startsWith(route);
  }

  void _handleNavigation(BuildContext context, String route) {
    if (onDestinationSelected != null) {
      onDestinationSelected!(route);
    } else {
      context.go(route);
    }
  }
}

/// Individual navigation item with animation
class _NavigationItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.isActive,
      label: '${widget.label} tab',
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppAnimations.shortAnimation,
                curve: AppAnimations.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                  vertical: AppSpacing.spacingS,
                ),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.vibrantPurple.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with indicator
                    Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: AppAnimations.shortAnimation,
                          child: Icon(
                            widget.isActive ? widget.activeIcon : widget.icon,
                            key: ValueKey(widget.isActive),
                            color: widget.isActive
                                ? AppColors.vibrantPurple
                                : AppColors.coolGray,
                            size: 24,
                          ),
                        ),
                        if (widget.isActive)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.vibrantPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.spacingXS),

                    // Label
                    AnimatedDefaultTextStyle(
                      duration: AppAnimations.shortAnimation,
                      style: AppTextStyles.caption.copyWith(
                        color: widget.isActive
                            ? AppColors.vibrantPurple
                            : AppColors.coolGray,
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating action button for primary action (Host Game)
class AppFloatingActionButton extends ConsumerWidget {
  final VoidCallback? onPressed;

  const AppFloatingActionButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.value?.isAuthenticated ?? false;

    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: onPressed ?? () => context.go(RouteConstants.gameHost),
      backgroundColor: AppColors.vibrantPurple,
      foregroundColor: AppColors.pureWhite,
      elevation: 8,
      icon: const Icon(Icons.add),
      label: Text(
        'Host Quiz',
        style: AppTextStyles.buttonText.copyWith(color: AppColors.pureWhite),
      ),
    );
  }
}

/// Top app bar with user profile and navigation
class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.sectionHeader.copyWith(
          color: AppColors.charcoal,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.pureWhite,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: AppColors.shadowLight,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : null,
      actions: [
        // Notification button
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement notifications
          },
        ),

        // User profile button
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.spacingM),
            child: GestureDetector(
              onTap: () => context.go(RouteConstants.profile),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.vibrantPurple,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.pureWhite,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

        // Additional actions
        ...?actions,
      ],
    );
  }
}

/// Navigation drawer for larger screens
class AppNavigationDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppNavigationDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final isAuthenticated = authState.value?.isAuthenticated ?? false;

    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    return Drawer(
      backgroundColor: AppColors.pureWhite,
      child: Column(
        children: [
          // User header
          if (user != null)
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.purpleGradient,
              ),
              accountName: Text(
                user.name,
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.pureWhite,
                ),
              ),
              accountEmail: Text(
                user.email,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.pureWhite.withOpacity(0.8),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.pureWhite,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.vibrantPurple,
                  ),
                ),
              ),
            ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  route: RouteConstants.home,
                  isActive: _isActiveRoute(RouteConstants.home),
                  onTap: () =>
                      _handleDrawerNavigation(context, RouteConstants.home),
                ),
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: RouteConstants.dashboard,
                  isActive: _isActiveRoute(RouteConstants.dashboard),
                  onTap: () => _handleDrawerNavigation(
                    context,
                    RouteConstants.dashboard,
                  ),
                ),
                _DrawerItem(
                  icon: Icons.quiz_outlined,
                  title: 'Create Quiz',
                  route: RouteConstants.quizCreation,
                  isActive: _isActiveRoute(RouteConstants.quizCreation),
                  onTap: () => _handleDrawerNavigation(
                    context,
                    RouteConstants.quizCreation,
                  ),
                ),
                _DrawerItem(
                  icon: Icons.sports_esports_outlined,
                  title: 'Join Game',
                  route: RouteConstants.gameJoin,
                  isActive: _isActiveRoute(RouteConstants.gameJoin),
                  onTap: () =>
                      _handleDrawerNavigation(context, RouteConstants.gameJoin),
                ),
                _DrawerItem(
                  icon: Icons.person_outlined,
                  title: 'Host Game',
                  route: RouteConstants.gameHost,
                  isActive: _isActiveRoute(RouteConstants.gameHost),
                  onTap: () =>
                      _handleDrawerNavigation(context, RouteConstants.gameHost),
                ),
                _DrawerItem(
                  icon: Icons.leaderboard_outlined,
                  title: 'Leaderboard',
                  route: RouteConstants.leaderboard,
                  isActive: _isActiveRoute(RouteConstants.leaderboard),
                  onTap: () => _handleDrawerNavigation(
                    context,
                    RouteConstants.leaderboard,
                  ),
                ),

                const Divider(),

                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  route: RouteConstants.settings,
                  isActive: _isActiveRoute(RouteConstants.settings),
                  onTap: () =>
                      _handleDrawerNavigation(context, RouteConstants.settings),
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help',
                  route: RouteConstants.help,
                  isActive: _isActiveRoute(RouteConstants.help),
                  onTap: () =>
                      _handleDrawerNavigation(context, RouteConstants.help),
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  route: RouteConstants.about,
                  isActive: _isActiveRoute(RouteConstants.about),
                  onTap: () =>
                      _handleDrawerNavigation(context, RouteConstants.about),
                ),
              ],
            ),
          ),

          // Sign out button
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Sign Out',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.error),
            ),
            onTap: () => _handleSignOut(context, ref),
          ),
          const SizedBox(height: AppSpacing.spacingM),
        ],
      ),
    );
  }

  bool _isActiveRoute(String route) {
    return currentRoute.startsWith(route);
  }

  void _handleDrawerNavigation(BuildContext context, String route) {
    Navigator.of(context).pop(); // Close drawer
    context.go(route);
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // Close drawer
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    if (context.mounted) {
      context.go(RouteConstants.login);
    }
  }
}

/// Drawer item widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.vibrantPurple : AppColors.coolGray,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyText.copyWith(
          color: isActive ? AppColors.vibrantPurple : AppColors.charcoal,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.vibrantPurple.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
