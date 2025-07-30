import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/layout/responsive_layout.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../providers/ui_theme_providers.dart';

/// Theme settings page for customizing UI appearance and accessibility
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(uiThemeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(uiThemeNotifierProvider.notifier).resetToSystemTheme();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: themeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.spacingM),
              Text('Error loading theme settings'),
              const SizedBox(height: AppSpacing.spacingS),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(uiThemeNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (theme) => ResponsiveLayout(
          mobile: _buildMobileLayout(context, ref, theme),
          tablet: _buildTabletLayout(context, ref, theme),
          desktop: _buildDesktopLayout(context, ref, theme),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, theme) {
    return _buildSettingsContent(context, ref, theme);
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingXL),
      child: _buildSettingsContent(context, ref, theme),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, theme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(AppSpacing.spacingXL),
        child: _buildSettingsContent(context, ref, theme),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref, theme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: AppTextStyles.sectionHeader),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  'Customize the look and feel of the app',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingL),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildThemeSelection(context, ref, theme)),
        SliverToBoxAdapter(child: _buildAnimationSettings(context, ref, theme)),
        SliverToBoxAdapter(
          child: _buildAccessibilitySettings(context, ref, theme),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spacingXL)),
      ],
    );
  }

  Widget _buildThemeSelection(BuildContext context, WidgetRef ref, theme) {
    final availableThemes = ref.watch(availableThemesProvider);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme Selection', style: AppTextStyles.answerOption),
            const SizedBox(height: AppSpacing.spacingM),
            availableThemes.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Error loading themes: $error'),
              data: (themes) => Wrap(
                spacing: AppSpacing.spacingS,
                runSpacing: AppSpacing.spacingS,
                children: themes.map((themeId) {
                  final isSelected = theme.currentThemeId == themeId;
                  return FilterChip(
                    label: Text(_getThemeDisplayName(themeId)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(uiThemeNotifierProvider.notifier)
                            .setTheme(themeId);
                      }
                    },
                    backgroundColor: _getThemeColor(themeId).withOpacity(0.1),
                    selectedColor: _getThemeColor(themeId).withOpacity(0.3),
                    checkmarkColor: _getThemeColor(themeId),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: theme.isDarkMode,
              onChanged: (value) {
                ref.read(uiThemeNotifierProvider.notifier).toggleDarkMode();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationSettings(BuildContext context, WidgetRef ref, theme) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Animation Settings', style: AppTextStyles.answerOption),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              'Animation Speed: ${(theme.animationSpeed * 100).round()}%',
              style: AppTextStyles.bodyText,
            ),
            Slider(
              value: theme.animationSpeed,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              label: '${(theme.animationSpeed * 100).round()}%',
              onChanged: (value) {
                ref
                    .read(uiThemeNotifierProvider.notifier)
                    .updateAnimationSpeed(value);
              },
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preview', style: AppTextStyles.caption),
                      const SizedBox(height: AppSpacing.spacingS),
                      _AnimationPreview(speed: theme.animationSpeed),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilitySettings(
    BuildContext context,
    WidgetRef ref,
    theme,
  ) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accessibility', style: AppTextStyles.answerOption),
            const SizedBox(height: AppSpacing.spacingM),
            SwitchListTile(
              title: const Text('Reduce Motion'),
              subtitle: const Text(
                'Minimize animations for motion sensitivity',
              ),
              value: theme.reduceMotion,
              onChanged: (value) {
                ref.read(uiThemeNotifierProvider.notifier).toggleReduceMotion();
              },
            ),
            SwitchListTile(
              title: const Text('High Contrast'),
              subtitle: const Text('Increase contrast for better visibility'),
              value: theme.highContrast,
              onChanged: (value) {
                ref.read(uiThemeNotifierProvider.notifier).toggleHighContrast();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDisplayName(String themeId) {
    switch (themeId) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'spring':
        return 'Spring';
      case 'summer':
        return 'Summer';
      case 'autumn':
        return 'Autumn';
      case 'winter':
        return 'Winter';
      default:
        return themeId.toUpperCase();
    }
  }

  Color _getThemeColor(String themeId) {
    switch (themeId) {
      case 'light':
        return AppColors.warmYellow;
      case 'dark':
        return AppColors.charcoal;
      case 'spring':
        return Colors.pink;
      case 'summer':
        return Colors.blue;
      case 'autumn':
        return Colors.orange;
      case 'winter':
        return Colors.lightBlue;
      default:
        return AppColors.vibrantPurple;
    }
  }
}

/// Animation preview widget to demonstrate current speed settings
class _AnimationPreview extends StatefulWidget {
  final double speed;

  const _AnimationPreview({required this.speed});

  @override
  State<_AnimationPreview> createState() => _AnimationPreviewState();
}

class _AnimationPreviewState extends State<_AnimationPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (1000 * widget.speed).round()),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AnimationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = Duration(
        milliseconds: (1000 * widget.speed).round(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.vibrantPurple,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
