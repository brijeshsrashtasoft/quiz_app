import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/quiz/lobby_avatar.dart';
import '../../domain/entities/game_session_entity.dart';

class LobbyPlayerList extends StatelessWidget {
  final Map<String, PlayerEntity> players;
  final String? hostId;
  final AnimationController? staggerController;
  final bool isCurrentUserHost;

  const LobbyPlayerList({
    super.key,
    required this.players,
    this.hostId,
    this.staggerController,
    this.isCurrentUserHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final playersList = players.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
      itemCount: playersList.length,
      itemBuilder: (context, index) {
        final playerEntry = playersList[index];
        final playerId = playerEntry.key;
        final player = playerEntry.value;

        if (staggerController != null) {
          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: staggerController!,
              curve: Interval(
                (index / players.length) * 0.5,
                0.5 + (index / players.length) * 0.5,
                curve: AppAnimations.easeOut,
              ),
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: _PlayerCard(
                playerId: playerId,
                player: player,
                isPlayerHost: hostId == playerId,
                isCurrentUserHost: isCurrentUserHost,
              ),
            ),
          );
        } else {
          return _PlayerCard(
            playerId: playerId,
            player: player,
            isPlayerHost: hostId == playerId,
            isCurrentUserHost: isCurrentUserHost,
          );
        }
      },
    );
  }
}

class _PlayerCard extends StatefulWidget {
  final String playerId;
  final PlayerEntity player;
  final bool isPlayerHost;
  final bool isCurrentUserHost;

  const _PlayerCard({
    required this.playerId,
    required this.player,
    required this.isPlayerHost,
    required this.isCurrentUserHost,
  });

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: AppAnimations.achievementDuration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: AppAnimations.bounce),
    );

    // Bounce animation on join - delay based on hash of playerId for consistent ordering
    final delay = widget.playerId.hashCode.abs() % 500;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = widget.player.isReady;
    final name = widget.player.name;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
            padding: AppSpacing.allM,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isReady
                    ? AppColors.turquoise.withOpacity(0.3)
                    : AppColors.lightGray,
                width: isReady ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isReady
                      ? AppColors.turquoise.withOpacity(0.1)
                      : AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                CompactLobbyAvatar(playerName: name, isReady: isReady),

                const SizedBox(width: AppSpacing.spacingM),

                // Name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isReady
                                  ? AppColors.turquoise
                                  : AppColors.coolGray,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingS),
                          Text(
                            isReady ? 'Ready' : 'Joining...',
                            style: AppTextStyles.caption.copyWith(
                              color: isReady
                                  ? AppColors.turquoise
                                  : AppColors.coolGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Host badge or kick button
                if (widget.isPlayerHost)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacingM,
                      vertical: AppSpacing.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warmYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.pureWhite,
                        ),
                        const SizedBox(width: AppSpacing.spacingXS),
                        Text(
                          'HOST',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.isCurrentUserHost && !widget.isPlayerHost)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.coolGray,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: Kick player
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
