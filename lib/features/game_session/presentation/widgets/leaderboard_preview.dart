import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../providers/game_play_providers.dart';

class LeaderboardPreview extends StatefulWidget {
  final List<LeaderboardEntry> entries;
  final int maxVisible;
  final bool showFinalResults;
  final String? currentUserId;

  const LeaderboardPreview({
    super.key,
    required this.entries,
    this.maxVisible = 5,
    this.showFinalResults = false,
    this.currentUserId,
  });

  @override
  State<LeaderboardPreview> createState() => _LeaderboardPreviewState();
}

class _LeaderboardPreviewState extends State<LeaderboardPreview>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _slideAnimations;

  List<LeaderboardEntry> get _displayEntries {
    final entries = widget.entries.take(widget.maxVisible).toList();
    return entries;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _displayEntries.length,
      (index) => AnimationController(
        duration: Duration(
          milliseconds:
              AppAnimations.leaderboardStagger.inMilliseconds * (index + 1),
        ),
        vsync: this,
      ),
    );

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 50, end: 0).animate(
        CurvedAnimation(parent: controller, curve: AppAnimations.easeOut),
      );
    }).toList();

    // Start animations sequentially
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(AppAnimations.getLeaderboardStagger(i), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(LeaderboardPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries.length != widget.entries.length) {
      // Dispose old controllers
      for (var controller in _animationControllers) {
        controller.dispose();
      }
      // Reinitialize with new data
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
      child: Column(
        children: [
          Text('Leaderboard', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.spacingL),

          Expanded(
            child: _displayEntries.isEmpty
                ? Center(
                    child: Text(
                      'No players yet',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _displayEntries[index];
                      return AnimatedBuilder(
                        animation: _animationControllers[index],
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimations[index].value),
                            child: FadeTransition(
                              opacity: _animationControllers[index],
                              child: _LeaderboardItem(
                                entry: entry,
                                index: index,
                                currentUserId: widget.currentUserId,
                                showFinalResults: widget.showFinalResults,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int index;
  final String? currentUserId;
  final bool showFinalResults;

  const _LeaderboardItem({
    required this.entry,
    required this.index,
    this.currentUserId,
    this.showFinalResults = false,
  });

  @override
  Widget build(BuildContext context) {
    final position = entry.rank;
    final isTopThree = position <= 3;
    final isCurrentPlayer = entry.isCurrentUser(currentUserId);
    final change = 0; // TODO: Implement position change tracking

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        gradient: isTopThree ? _getGradientForPosition(position) : null,
        color: isTopThree
            ? null
            : (isCurrentPlayer
                  ? AppColors.vibrantPurple.withOpacity(0.1)
                  : AppColors.pureWhite),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer
              ? AppColors.vibrantPurple
              : (isTopThree ? Colors.transparent : AppColors.lightGray),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isTopThree
                ? _getColorForPosition(position).withOpacity(0.3)
                : AppColors.shadowLight,
            blurRadius: isTopThree ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree
                  ? AppColors.pureWhite.withOpacity(0.2)
                  : AppColors.offWhite,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: AppTextStyles.leaderboardRank.copyWith(
                  color: isTopThree
                      ? AppColors.pureWhite
                      : AppTextStyles.getRankStyle(position).color,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.spacingM),

          // Player name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.playerName,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: isCurrentPlayer ? FontWeight.w700 : FontWeight.w500,
                    color: isTopThree ? AppColors.pureWhite : AppColors.charcoal,
                  ),
                ),
                if (showFinalResults && entry.answersCorrect > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${entry.answersCorrect} correct',
                    style: AppTextStyles.caption.copyWith(
                      color: isTopThree ? AppColors.pureWhite.withValues(alpha: 0.8) : AppColors.coolGray,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Position change indicator
          if (change != 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingS,
                vertical: AppSpacing.spacingXS,
              ),
              decoration: BoxDecoration(
                color: change > 0
                    ? AppColors.turquoise.withOpacity(0.2)
                    : AppColors.coralRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    change > 0
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: change > 0
                        ? AppColors.turquoise
                        : AppColors.coralRed,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${change.abs()}',
                    style: AppTextStyles.caption.copyWith(
                      color: change > 0
                          ? AppColors.turquoise
                          : AppColors.coralRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: AppSpacing.spacingM),

          // Score
          Text(
            '${entry.score}',
            style: AppTextStyles.scoreDisplay.copyWith(
              fontSize: 20,
              color: isTopThree ? AppColors.pureWhite : AppColors.vibrantPurple,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient? _getGradientForPosition(int position) {
    switch (position) {
      case 1:
        return AppColors.goldGradient;
      case 2:
        return AppColors.silverGradient;
      case 3:
        return AppColors.bronzeGradient;
      default:
        return null;
    }
  }

  Color _getColorForPosition(int position) {
    switch (position) {
      case 1:
        return AppColors.achievement;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.vibrantPurple;
    }
  }
}
