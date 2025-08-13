import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../../core/navigation/route_constants.dart';

/// Breadcrumb navigation for complex navigation hierarchies
/// Provides contextual navigation and user orientation
class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final bool showHomeIcon;
  final Color? textColor;
  final Color? activeColor;
  final double? fontSize;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.showHomeIcon = true,
    this.textColor,
    this.activeColor,
    this.fontSize,
  });

  /// Create breadcrumbs from current route
  factory BreadcrumbNavigation.fromRoute(
    String currentRoute, {
    bool showHomeIcon = true,
    Color? textColor,
    Color? activeColor,
    double? fontSize,
  }) {
    final items = _buildBreadcrumbsFromRoute(currentRoute);
    return BreadcrumbNavigation(
      items: items,
      showHomeIcon: showHomeIcon,
      textColor: textColor,
      activeColor: activeColor,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Home icon
            if (showHomeIcon) ...[
              GestureDetector(
                onTap: () => context.go(RouteConstants.home),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.home,
                    size: 16,
                    color: textColor ?? AppColors.coolGray,
                  ),
                ),
              ),
              _buildSeparator(),
            ],

            // Breadcrumb items
            ...items.asMap().entries.expand((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return [
                _buildBreadcrumbItem(context, item, isLast),
                if (!isLast) _buildSeparator(),
              ];
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    BreadcrumbItem item,
    bool isLast,
  ) {
    final itemTextColor = isLast
        ? (activeColor ?? AppColors.vibrantPurple)
        : (textColor ?? AppColors.coolGray);

    final itemStyle = AppTextStyles.caption.copyWith(
      color: itemTextColor,
      fontSize: fontSize ?? 14,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
    );

    Widget child = Text(item.title, style: itemStyle);

    // Add icon if provided
    if (item.icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: itemTextColor),
          const SizedBox(width: AppSpacing.spacingXS),
          child,
        ],
      );
    }

    // Make clickable if not the last item and has a route
    if (!isLast && item.route != null) {
      child = GestureDetector(
        onTap: () => context.go(item.route!),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingS,
            vertical: AppSpacing.spacingXS,
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: child,
        ),
      );
    } else if (isLast) {
      child = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: AppSpacing.spacingXS,
        ),
        decoration: BoxDecoration(
          color: (activeColor ?? AppColors.vibrantPurple).withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: (activeColor ?? AppColors.vibrantPurple).withValues(
              alpha: 0.3,
            ),
          ),
        ),
        child: child,
      );
    }

    return child;
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingS),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: textColor ?? AppColors.lightGray,
      ),
    );
  }

  /// Build breadcrumbs from route path
  static List<BreadcrumbItem> _buildBreadcrumbsFromRoute(String route) {
    final items = <BreadcrumbItem>[];

    // Route mapping for breadcrumbs
    const routeMapping = {
      RouteConstants.home: BreadcrumbItem(
        title: 'Home',
        route: RouteConstants.home,
      ),
      RouteConstants.dashboard: BreadcrumbItem(
        title: 'Dashboard',
        route: RouteConstants.dashboard,
        icon: Icons.dashboard_outlined,
      ),
      RouteConstants.quizCreation: BreadcrumbItem(
        title: 'Create Quiz',
        route: RouteConstants.quizCreation,
        icon: Icons.quiz_outlined,
      ),
      RouteConstants.quizCreationForm: BreadcrumbItem(
        title: 'Quiz Form',
        route: RouteConstants.quizCreationForm,
      ),
      RouteConstants.quizCreationPreview: BreadcrumbItem(
        title: 'Preview',
        route: RouteConstants.quizCreationPreview,
      ),
      RouteConstants.quizCreationPublish: BreadcrumbItem(
        title: 'Publish',
        route: RouteConstants.quizCreationPublish,
      ),
      RouteConstants.gameJoin: BreadcrumbItem(
        title: 'Join Game',
        route: RouteConstants.gameJoin,
        icon: Icons.sports_esports_outlined,
      ),
      RouteConstants.gameHost: BreadcrumbItem(
        title: 'Host Game',
        route: RouteConstants.gameHost,
        icon: Icons.person_outlined,
      ),
      RouteConstants.gameHostSetup: BreadcrumbItem(
        title: 'Setup',
        route: RouteConstants.gameHostSetup,
      ),
      RouteConstants.leaderboard: BreadcrumbItem(
        title: 'Leaderboard',
        route: RouteConstants.leaderboard,
        icon: Icons.leaderboard_outlined,
      ),
      RouteConstants.leaderboardGlobal: BreadcrumbItem(
        title: 'Global',
        route: RouteConstants.leaderboardGlobal,
      ),
      RouteConstants.profile: BreadcrumbItem(
        title: 'Profile',
        route: RouteConstants.profile,
        icon: Icons.person_outlined,
      ),
      RouteConstants.settings: BreadcrumbItem(
        title: 'Settings',
        route: RouteConstants.settings,
        icon: Icons.settings_outlined,
      ),
      RouteConstants.help: BreadcrumbItem(
        title: 'Help',
        route: RouteConstants.help,
        icon: Icons.help_outline,
      ),
      RouteConstants.about: BreadcrumbItem(
        title: 'About',
        route: RouteConstants.about,
        icon: Icons.info_outline,
      ),
    };

    // Split route into segments
    final segments = route.split('/').where((s) => s.isNotEmpty).toList();
    String currentPath = '';

    for (final segment in segments) {
      currentPath += '/$segment';

      // Check for exact match first
      if (routeMapping.containsKey(currentPath)) {
        items.add(routeMapping[currentPath]!);
        continue;
      }

      // Handle dynamic routes
      if (segment.contains(':')) {
        // Skip parameter segments for now
        continue;
      }

      // Handle special cases
      if (currentPath.contains('/quiz/') && currentPath.contains('/edit')) {
        items.add(const BreadcrumbItem(title: 'Edit Quiz'));
      } else if (currentPath.contains('/game/') &&
          currentPath.contains('/waiting')) {
        items.add(const BreadcrumbItem(title: 'Waiting Room'));
      } else if (currentPath.contains('/game/') &&
          currentPath.contains('/question/')) {
        items.add(const BreadcrumbItem(title: 'Question'));
      } else if (currentPath.contains('/game/') &&
          currentPath.contains('/results')) {
        items.add(const BreadcrumbItem(title: 'Results'));
      } else if (currentPath.contains('/leaderboard/session/')) {
        items.add(const BreadcrumbItem(title: 'Session Leaderboard'));
      } else {
        // Fallback: create title from segment
        final title = segment
            .split('-')
            .map(
              (word) =>
                  word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
            )
            .join(' ');
        items.add(BreadcrumbItem(title: title));
      }
    }

    return items;
  }
}

/// Individual breadcrumb item data class
class BreadcrumbItem {
  final String title;
  final String? route;
  final IconData? icon;

  const BreadcrumbItem({required this.title, this.route, this.icon});
}

/// Compact breadcrumb for mobile layouts
class CompactBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final VoidCallback? onBackPressed;

  const CompactBreadcrumb({super.key, required this.items, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final currentItem = items.last;
    final hasParent = items.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      child: Row(
        children: [
          // Back button
          if (hasParent)
            GestureDetector(
              onTap:
                  onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else if (items.length > 1) {
                      final parentRoute = items[items.length - 2].route;
                      if (parentRoute != null) {
                        context.go(parentRoute);
                      }
                    }
                  },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: AppColors.charcoal,
                ),
              ),
            ),

          if (hasParent) const SizedBox(width: AppSpacing.spacingM),

          // Current page title
          Expanded(
            child: Row(
              children: [
                if (currentItem.icon != null) ...[
                  Icon(
                    currentItem.icon,
                    size: 20,
                    color: AppColors.vibrantPurple,
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                ],
                Expanded(
                  child: Text(
                    currentItem.title,
                    style: AppTextStyles.sectionHeader.copyWith(
                      fontSize: 18,
                      color: AppColors.charcoal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Parent indicator
          if (hasParent && items.length > 1)
            Text(
              '${items.length - 1}+',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.coolGray,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

/// Breadcrumb navigation provider for automatic route tracking
class BreadcrumbProvider extends InheritedWidget {
  final List<BreadcrumbItem> breadcrumbs;
  final Function(List<BreadcrumbItem>) onBreadcrumbsChanged;

  const BreadcrumbProvider({
    super.key,
    required this.breadcrumbs,
    required this.onBreadcrumbsChanged,
    required super.child,
  });

  static BreadcrumbProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BreadcrumbProvider>();
  }

  @override
  bool updateShouldNotify(BreadcrumbProvider oldWidget) {
    return breadcrumbs != oldWidget.breadcrumbs;
  }

  /// Add breadcrumb to current navigation
  void addBreadcrumb(BreadcrumbItem item) {
    final updatedBreadcrumbs = [...breadcrumbs, item];
    onBreadcrumbsChanged(updatedBreadcrumbs);
  }

  /// Remove last breadcrumb
  void popBreadcrumb() {
    if (breadcrumbs.isNotEmpty) {
      final updatedBreadcrumbs = breadcrumbs.sublist(0, breadcrumbs.length - 1);
      onBreadcrumbsChanged(updatedBreadcrumbs);
    }
  }

  /// Clear all breadcrumbs
  void clearBreadcrumbs() {
    onBreadcrumbsChanged([]);
  }

  /// Replace breadcrumbs
  void setBreadcrumbs(List<BreadcrumbItem> newBreadcrumbs) {
    onBreadcrumbsChanged(newBreadcrumbs);
  }
}
