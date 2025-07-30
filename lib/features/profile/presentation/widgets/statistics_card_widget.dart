import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Statistics card widget for displaying user stats
/// Kahoot-style engaging design with animated counters and vibrant colors
class StatisticsCardWidget extends StatefulWidget {
  final List<StatisticItem> statistics;
  final String? title;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showAnimatedCounters;

  const StatisticsCardWidget({
    super.key,
    required this.statistics,
    this.title,
    this.backgroundColor,
    this.borderColor,
    this.showAnimatedCounters = true,
  });

  @override
  State<StatisticsCardWidget> createState() => _StatisticsCardWidgetState();
}

class _StatisticsCardWidgetState extends State<StatisticsCardWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<int>> _counterAnimations;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      widget.statistics.length,
      (index) => AnimationController(
        duration: Duration(
          milliseconds:
              AppAnimations.scoreUpdateDuration.inMilliseconds + (index * 100),
        ),
        vsync: this,
      ),
    );

    _counterAnimations = widget.statistics.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      return IntTween(begin: 0, end: stat.value).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: AppAnimations.easeOut,
        ),
      );
    }).toList();

    // Start animations after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() {
    if (!widget.showAnimatedCounters || _hasAnimated) return;

    _hasAnimated = true;
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * 200),
        () => _controllers[i].forward(),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.charcoal,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
            ],

            _buildStatisticsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    final itemsPerRow = widget.statistics.length > 4 ? 3 : 2;
    final rows = <Widget>[];

    for (int i = 0; i < widget.statistics.length; i += itemsPerRow) {
      final rowItems = widget.statistics.skip(i).take(itemsPerRow).toList();
      rows.add(_buildStatisticsRow(rowItems, i));

      if (i + itemsPerRow < widget.statistics.length) {
        rows.add(const SizedBox(height: AppSpacing.spacingL));
      }
    }

    return Column(children: rows);
  }

  Widget _buildStatisticsRow(List<StatisticItem> items, int startIndex) {
    return Row(
      children: items
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;
            final globalIndex = startIndex + index;

            return Expanded(child: _buildStatisticItem(item, globalIndex));
          })
          .expand(
            (widget) => [
              widget,
              if (items.length > 1) const SizedBox(width: AppSpacing.spacingM),
            ],
          )
          .take(items.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildStatisticItem(StatisticItem item, int index) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        final animatedValue = widget.showAnimatedCounters
            ? _counterAnimations[index].value
            : item.value;

        return _StatisticItemWidget(
          statistic: item.copyWith(value: animatedValue),
          animationProgress: _controllers[index].value,
        );
      },
    );
  }
}

/// Individual statistic item widget with engaging animations
class _StatisticItemWidget extends StatelessWidget {
  final StatisticItem statistic;
  final double animationProgress;

  const _StatisticItemWidget({
    required this.statistic,
    required this.animationProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8 + (animationProgress * 0.2),
      child: Container(
        padding: AppSpacing.allM,
        decoration: BoxDecoration(
          color: statistic.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statistic.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statistic.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: statistic.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(statistic.icon, color: AppColors.pureWhite, size: 24),
            ),

            const SizedBox(height: AppSpacing.spacingM),

            // Value
            Text(
              _formatValue(statistic.value),
              style: AppTextStyles.scoreDisplay.copyWith(
                fontSize: 28,
                color: statistic.color,
              ),
            ),

            const SizedBox(height: AppSpacing.spacingS),

            // Label
            Text(
              statistic.label,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),

            if (statistic.subtitle != null) ...[
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                statistic.subtitle!,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

/// Data model for statistic items
class StatisticItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final int value;
  final Color color;

  const StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  StatisticItem copyWith({
    IconData? icon,
    String? label,
    String? subtitle,
    int? value,
    Color? color,
  }) {
    return StatisticItem(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      value: value ?? this.value,
      color: color ?? this.color,
    );
  }
}

/// Pre-built statistics cards for common use cases

/// User achievements and game statistics
class GameStatisticsCard extends StatelessWidget {
  final int gamesPlayed;
  final int gamesWon;
  final int totalScore;
  final int currentStreak;
  final int bestStreak;
  final double winRate;

  const GameStatisticsCard({
    super.key,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.totalScore,
    required this.currentStreak,
    required this.bestStreak,
    required this.winRate,
  });

  @override
  Widget build(BuildContext context) {
    final statistics = [
      StatisticItem(
        icon: Icons.sports_esports,
        label: 'Games Played',
        value: gamesPlayed,
        color: AppColors.vibrantPurple,
      ),
      StatisticItem(
        icon: Icons.emoji_events,
        label: 'Games Won',
        value: gamesWon,
        color: AppColors.achievement,
      ),
      StatisticItem(
        icon: Icons.stars,
        label: 'Total Score',
        value: totalScore,
        color: AppColors.turquoise,
      ),
      StatisticItem(
        icon: Icons.local_fire_department,
        label: 'Current Streak',
        value: currentStreak,
        color: AppColors.coralRed,
      ),
    ];

    return StatisticsCardWidget(
      title: 'Game Statistics',
      statistics: statistics,
    );
  }
}

/// Quiz creation statistics
class QuizStatisticsCard extends StatelessWidget {
  final int quizzesCreated;
  final int totalPlays;
  final int averageRating;
  final int favoriteCount;

  const QuizStatisticsCard({
    super.key,
    required this.quizzesCreated,
    required this.totalPlays,
    required this.averageRating,
    required this.favoriteCount,
  });

  @override
  Widget build(BuildContext context) {
    final statistics = [
      StatisticItem(
        icon: Icons.quiz,
        label: 'Quizzes Created',
        value: quizzesCreated,
        color: AppColors.mintGreen,
      ),
      StatisticItem(
        icon: Icons.play_arrow,
        label: 'Total Plays',
        value: totalPlays,
        color: AppColors.vibrantPurple,
      ),
      StatisticItem(
        icon: Icons.star,
        label: 'Avg Rating',
        subtitle: 'out of 5',
        value: averageRating,
        color: AppColors.warmYellow,
      ),
      StatisticItem(
        icon: Icons.favorite,
        label: 'Favorites',
        value: favoriteCount,
        color: AppColors.coralRed,
      ),
    ];

    return StatisticsCardWidget(title: 'Quiz Creation', statistics: statistics);
  }
}

/// Achievement and milestone statistics
class AchievementStatisticsCard extends StatelessWidget {
  final int totalAchievements;
  final int unlockedAchievements;
  final int level;
  final int experiencePoints;

  const AchievementStatisticsCard({
    super.key,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.level,
    required this.experiencePoints,
  });

  @override
  Widget build(BuildContext context) {
    final completionRate = totalAchievements > 0
        ? ((unlockedAchievements / totalAchievements) * 100).round()
        : 0;

    final statistics = [
      StatisticItem(
        icon: Icons.military_tech,
        label: 'Level',
        value: level,
        color: AppColors.achievement,
      ),
      StatisticItem(
        icon: Icons.star,
        label: 'Experience',
        subtitle: 'points',
        value: experiencePoints,
        color: AppColors.vibrantPurple,
      ),
      StatisticItem(
        icon: Icons.emoji_events,
        label: 'Achievements',
        subtitle: '$unlockedAchievements/$totalAchievements',
        value: completionRate,
        color: AppColors.turquoise,
      ),
    ];

    return StatisticsCardWidget(title: 'Achievements', statistics: statistics);
  }
}
