import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../../core/navigation/route_constants.dart';
import '../base/responsive_builder.dart';
import 'app_navigation_bar.dart';

/// Responsive navigation that adapts to screen size
/// Uses bottom navigation for mobile, drawer for larger screens
class ResponsiveNavigation extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveNavigation({
    super.key,
    required this.currentRoute,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        switch (info.screenSize) {
          case ScreenSize.small:
            return _buildMobileLayout(context);
          case ScreenSize.medium:
            return _buildTabletLayout(context);
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: title != null ? AppTopBar(title: title!, actions: actions) : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppTopBar(title: title ?? 'Quiz App', actions: actions),
      drawer: AppNavigationDrawer(currentRoute: currentRoute),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Row(
        children: [
          // Permanent navigation rail
          _DesktopNavigationRail(currentRoute: currentRoute),

          // Main content area
          Expanded(
            child: Column(
              children: [
                if (title != null)
                  _DesktopAppBar(title: title!, actions: actions),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Desktop navigation rail for larger screens
class _DesktopNavigationRail extends StatefulWidget {
  final String currentRoute;

  const _DesktopNavigationRail({required this.currentRoute});

  @override
  State<_DesktopNavigationRail> createState() => _DesktopNavigationRailState();
}

class _DesktopNavigationRailState extends State<_DesktopNavigationRail>
    with SingleTickerProviderStateMixin {
  bool _isExtended = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExtended() {
    setState(() {
      _isExtended = !_isExtended;
      if (_isExtended) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _NavigationDestination(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        route: RouteConstants.home,
      ),
      _NavigationDestination(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: RouteConstants.dashboard,
      ),
      _NavigationDestination(
        icon: Icons.quiz_outlined,
        activeIcon: Icons.quiz,
        label: 'Create Quiz',
        route: RouteConstants.quizCreation,
      ),
      _NavigationDestination(
        icon: Icons.sports_esports_outlined,
        activeIcon: Icons.sports_esports,
        label: 'Join Game',
        route: RouteConstants.gameJoin,
      ),
      _NavigationDestination(
        icon: Icons.leaderboard_outlined,
        activeIcon: Icons.leaderboard,
        label: 'Leaderboard',
        route: RouteConstants.leaderboard,
      ),
    ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _isExtended ? 256 : 80,
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with toggle button
              Container(
                height: AppDimensions.appBarHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                ),
                child: Row(
                  children: [
                    if (_isExtended) ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          color: AppColors.pureWhite,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacingS),
                      Expanded(
                        child: Text(
                          'Quiz App',
                          style: AppTextStyles.sectionHeader.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                    IconButton(
                      onPressed: _toggleExtended,
                      icon: Icon(
                        _isExtended ? Icons.menu_open : Icons.menu,
                        color: AppColors.charcoal,
                      ),
                      tooltip: _isExtended ? 'Collapse' : 'Expand',
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Navigation items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spacingM,
                  ),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    final isActive = widget.currentRoute.startsWith(
                      destination.route,
                    );

                    return _DesktopNavigationItem(
                      destination: destination,
                      isActive: isActive,
                      isExtended: _isExtended,
                      onTap: () => context.go(destination.route),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // Settings and profile
              _DesktopNavigationItem(
                destination: _NavigationDestination(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  route: RouteConstants.settings,
                ),
                isActive: widget.currentRoute.startsWith(
                  RouteConstants.settings,
                ),
                isExtended: _isExtended,
                onTap: () => context.go(RouteConstants.settings),
              ),

              const SizedBox(height: AppSpacing.spacingM),
            ],
          ),
        );
      },
    );
  }
}

/// Desktop navigation item
class _DesktopNavigationItem extends StatefulWidget {
  final _NavigationDestination destination;
  final bool isActive;
  final bool isExtended;
  final VoidCallback onTap;

  const _DesktopNavigationItem({
    required this.destination,
    required this.isActive,
    required this.isExtended,
    required this.onTap,
  });

  @override
  State<_DesktopNavigationItem> createState() => _DesktopNavigationItemState();
}

class _DesktopNavigationItemState extends State<_DesktopNavigationItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingS,
                vertical: AppSpacing.spacingXS,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingM,
                vertical: AppSpacing.spacingS,
              ),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? AppColors.vibrantPurple.withValues(alpha: 0.1)
                    : _isHovered
                    ? AppColors.lightGray.withValues(alpha: 0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: widget.isActive
                    ? Border.all(
                        color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isActive
                        ? widget.destination.activeIcon
                        : widget.destination.icon,
                    color: widget.isActive
                        ? AppColors.vibrantPurple
                        : AppColors.coolGray,
                    size: AppDimensions.navigationIconSize,
                  ),
                  if (widget.isExtended) ...[
                    const SizedBox(width: AppSpacing.spacingM),
                    Expanded(
                      child: Text(
                        widget.destination.label,
                        style: AppTextStyles.bodyText.copyWith(
                          color: widget.isActive
                              ? AppColors.vibrantPurple
                              : AppColors.charcoal,
                          fontWeight: widget.isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Desktop app bar for larger screens
class _DesktopAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const _DesktopAppBar({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

/// Navigation destination data class
class _NavigationDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavigationDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Responsive navigation utilities
class ResponsiveNavigationUtils {
  ResponsiveNavigationUtils._();

  /// Determine navigation type based on screen size
  static NavigationType getNavigationType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < AppDimensions.mobileBreakpoint) {
      return NavigationType.bottomNavigation;
    } else if (screenWidth < AppDimensions.desktopBreakpoint) {
      return NavigationType.drawer;
    } else {
      return NavigationType.rail;
    }
  }

  /// Check if floating action button should be shown
  static bool shouldShowFAB(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < AppDimensions.tabletBreakpoint;
  }

  /// Get navigation bar height based on platform
  static double getNavigationHeight(BuildContext context) {
    final navigationType = getNavigationType(context);
    switch (navigationType) {
      case NavigationType.bottomNavigation:
        return AppDimensions.bottomNavHeight;
      case NavigationType.drawer:
      case NavigationType.rail:
        return 0; // No bottom navigation
    }
  }
}

/// Navigation type enumeration
enum NavigationType { bottomNavigation, drawer, rail }
