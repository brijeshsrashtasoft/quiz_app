import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/layout/responsive_layout.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../providers/ui_theme_providers.dart';

/// Main UI Showcase page - displays gallery of all UI components
/// This serves as the entry point for exploring all UI elements
class UIShowcasePage extends ConsumerWidget {
  const UIShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentUIThemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Component Showcase'),
        actions: [
          IconButton(
            icon: Icon(
              currentTheme?.isDarkMode == true
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(uiThemeNotifierProvider.notifier).toggleDarkMode();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/ui-showcase/themes'),
            tooltip: 'Theme Settings',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, ref),
        tablet: _buildTabletLayout(context, ref),
        desktop: _buildDesktopLayout(context, ref),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return _buildShowcaseGrid(context, ref, crossAxisCount: 2);
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return _buildShowcaseGrid(context, ref, crossAxisCount: 3);
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return _buildShowcaseGrid(context, ref, crossAxisCount: 4);
  }

  Widget _buildShowcaseGrid(
    BuildContext context,
    WidgetRef ref, {
    required int crossAxisCount,
  }) {
    final showcaseItems = _getShowcaseItems();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore UI Components',
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  'Interactive showcase of all Kahoot-style UI components with live preview and customization options.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingL),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              crossAxisSpacing: AppSpacing.spacingM,
              mainAxisSpacing: AppSpacing.spacingM,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = showcaseItems[index];
              return _ShowcaseCard(
                title: item.title,
                description: item.description,
                icon: item.icon,
                color: item.color,
                route: item.route,
              );
            }, childCount: showcaseItems.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spacingXL)),
      ],
    );
  }

  List<_ShowcaseItem> _getShowcaseItems() {
    return [
      _ShowcaseItem(
        title: 'Answer Buttons',
        description: 'Interactive answer buttons with shapes and animations',
        icon: Icons.radio_button_checked,
        color: AppColors.triangleRed,
        route: '/ui-showcase/buttons',
      ),
      _ShowcaseItem(
        title: 'Animations',
        description: 'Smooth transitions and micro-interactions',
        icon: Icons.animation,
        color: AppColors.vibrantPurple,
        route: '/ui-showcase/animations',
      ),
      _ShowcaseItem(
        title: 'Countdown Timer',
        description: 'Animated timer with progress indicators',
        icon: Icons.timer,
        color: AppColors.turquoise,
        route: '/ui-showcase/timers',
      ),
      _ShowcaseItem(
        title: 'Particle Effects',
        description: 'Celebration effects and visual feedback',
        icon: Icons.auto_awesome,
        color: AppColors.warmYellow,
        route: '/ui-showcase/effects',
      ),
      _ShowcaseItem(
        title: 'Lobby Screen',
        description: 'Waiting room with animated player avatars',
        icon: Icons.people,
        color: AppColors.mintGreen,
        route: '/ui-showcase/lobby',
      ),
      _ShowcaseItem(
        title: 'Theme Settings',
        description: 'Light/dark modes and accessibility options',
        icon: Icons.palette,
        color: AppColors.coralRed,
        route: '/ui-showcase/themes',
      ),
      _ShowcaseItem(
        title: 'Loading States',
        description: 'Engaging loading animations and spinners',
        icon: Icons.hourglass_empty,
        color: AppColors.vibrantPurple,
        route: '/ui-showcase/loading',
      ),
      _ShowcaseItem(
        title: 'Score Counter',
        description: 'Animated score displays and achievements',
        icon: Icons.emoji_events,
        color: AppColors.achievement,
        route: '/ui-showcase/scores',
      ),
    ];
  }
}

/// Individual showcase card component
class _ShowcaseCard extends ConsumerWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _ShowcaseCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: AppDimensions.cardElevation,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                title,
                style: AppTextStyles.answerOption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for showcase items
class _ShowcaseItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _ShowcaseItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
