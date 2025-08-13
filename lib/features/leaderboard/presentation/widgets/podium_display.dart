import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';

class PodiumDisplay extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const PodiumDisplay({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    if (topThree.length < 3) {
      return const SizedBox.shrink();
    }

    final reorderedList = [
      if (topThree.length > 1) topThree[1],
      topThree[0],
      if (topThree.length > 2) topThree[2],
    ];

    final heights = [150.0, 180.0, 120.0];
    final delays = [300, 0, 600];

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(reorderedList.length, (index) {
          final entry = reorderedList[index];
          final height = heights[index];
          final delay = delays[index];

          return Expanded(
            child:
                _buildPodiumStep(
                      entry: entry,
                      height: height,
                      rank: entry!.rank,
                    )
                    .animate()
                    .slideY(
                      begin: 1,
                      end: 0,
                      duration: 800.ms,
                      delay: delay.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 600.ms, delay: delay.ms),
          );
        }),
      ),
    );
  }

  Widget _buildPodiumStep({
    required LeaderboardEntry? entry,
    required double height,
    required int rank,
  }) {
    if (entry == null) return const SizedBox.shrink();

    final colors = [
      AppColors.warning,
      AppColors.textSecondary,
      const Color(0xFFCD7F32),
    ];

    final color = colors[rank - 1];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPlayerAvatar(entry, rank),
        const SizedBox(height: AppSpacing.sm),
        Text(
          entry.playerName,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${entry.totalScore} pts',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: AppSpacing.md,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (rank == 1)
                Positioned(
                  top: -10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child:
                        Icon(
                              Icons.emoji_events,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 40,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .rotate(
                              begin: -0.05,
                              end: 0.05,
                              duration: 2.seconds,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .rotate(
                              begin: 0.05,
                              end: -0.05,
                              duration: 2.seconds,
                              curve: Curves.easeInOut,
                            ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerAvatar(LeaderboardEntry entry, int rank) {
    final colors = [
      AppColors.warning,
      AppColors.textSecondary,
      const Color(0xFFCD7F32),
    ];

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors[rank - 1], width: 3),
        boxShadow: [
          BoxShadow(
            color: colors[rank - 1].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.surface,
        backgroundImage: entry.avatarUrl != null
            ? NetworkImage(entry.avatarUrl!)
            : null,
        child: entry.avatarUrl == null
            ? Text(
                entry.playerName[0].toUpperCase(),
                style: AppTextStyles.h2.copyWith(color: colors[rank - 1]),
              )
            : null,
      ),
    );
  }
}
