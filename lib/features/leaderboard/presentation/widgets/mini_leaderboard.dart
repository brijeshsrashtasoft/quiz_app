import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../providers/leaderboard_providers.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';

class MiniLeaderboard extends ConsumerWidget {
  final String sessionId;

  const MiniLeaderboard({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topThree = ref.watch(topThreeProvider(sessionId));
    final currentPlayerId = ref.watch(currentPlayerIdProvider);
    final playerRank = currentPlayerId != null
        ? ref.watch(playerRankProvider((sessionId, currentPlayerId)))
        : null;

    if (topThree.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Players',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (playerRank != null && playerRank > 3)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You: #$playerRank',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...topThree
              .take(3)
              .map(
                (entry) => _buildMiniEntry(
                  entry,
                  isCurrentPlayer: entry.playerId == currentPlayerId,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMiniEntry(
    LeaderboardEntry entry, {
    bool isCurrentPlayer = false,
  }) {
    final rankColors = [
      AppColors.warning,
      AppColors.textSecondary,
      const Color(0xFFCD7F32),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: entry.rank <= 3
                  ? rankColors[entry.rank - 1]
                  : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.playerName,
              style: AppTextStyles.caption.copyWith(
                color: isCurrentPlayer
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: isCurrentPlayer
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.totalScore}',
            style: AppTextStyles.caption.copyWith(
              color: isCurrentPlayer
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
