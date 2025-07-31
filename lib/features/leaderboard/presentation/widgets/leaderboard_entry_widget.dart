import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';

class LeaderboardEntryWidget extends StatefulWidget {
  final LeaderboardEntry entry;
  final bool isCurrentPlayer;
  final bool showAnimation;

  const LeaderboardEntryWidget({
    super.key,
    required this.entry,
    this.isCurrentPlayer = false,
    this.showAnimation = true,
  });

  @override
  State<LeaderboardEntryWidget> createState() => _LeaderboardEntryWidgetState();
}

class _LeaderboardEntryWidgetState extends State<LeaderboardEntryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rankChangeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rankChangeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    if (widget.showAnimation && widget.entry.rankChange != RankChange.same) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(LeaderboardEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry.rank != oldWidget.entry.rank && widget.showAnimation) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: widget.isCurrentPlayer
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: widget.isCurrentPlayer
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _buildRank(),
            const SizedBox(width: AppSpacing.md),
            _buildPlayerInfo(),
            const Spacer(),
            _buildScore(),
            if (widget.showAnimation) _buildRankChangeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildRank() {
    final isTop3 = widget.entry.rank <= 3;
    final colors = [
      AppColors.warning,
      AppColors.textSecondary,
      const Color(0xFFCD7F32),
    ];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isTop3 ? colors[widget.entry.rank - 1] : AppColors.surface,
        shape: BoxShape.circle,
        border: !isTop3 ? Border.all(color: AppColors.divider, width: 2) : null,
      ),
      child: Center(
        child: isTop3
            ? Icon(Icons.emoji_events, color: Colors.white, size: 24)
            : Text(
                '${widget.entry.rank}',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.entry.playerName,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isCurrentPlayer
                  ? AppColors.primary
                  : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: AppColors.success),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${widget.entry.correctAnswers}/${widget.entry.totalQuestions}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (widget.entry.currentStreak > 2) ...[
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${widget.entry.currentStreak}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.entry.totalScore}',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.isCurrentPlayer
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
        Text(
          'points',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRankChangeIndicator() {
    if (widget.entry.rankChange == RankChange.same ||
        widget.entry.rankChange == RankChange.new_) {
      return const SizedBox(width: 32);
    }

    final isUp = widget.entry.rankChange == RankChange.up;
    final rankDifference = (widget.entry.previousRank - widget.entry.rank)
        .abs();

    return AnimatedBuilder(
      animation: _rankChangeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _rankChangeAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isUp ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 2),
                Text(
                  '$rankDifference',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
