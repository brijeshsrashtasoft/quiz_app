import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/quiz/lobby_avatar.dart';

class LobbyPlayerList extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final AnimationController staggerController;
  final bool isHost;

  const LobbyPlayerList({
    super.key,
    required this.players,
    required this.staggerController,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: staggerController,
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
              player: player,
              isHost: isHost,
              index: index,
            ),
          ),
        );
      },
    );
  }
}

class _PlayerCard extends StatefulWidget {
  final Map<String, dynamic> player;
  final bool isHost;
  final int index;

  const _PlayerCard({
    required this.player,
    required this.isHost,
    required this.index,
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
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: AppAnimations.bounce,
    ));
    
    // Bounce animation on join
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
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
    final isReady = widget.player['isReady'] as bool;
    final name = widget.player['name'] as String;
    
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
                CompactLobbyAvatar(
                  playerName: name,
                  isReady: isReady,
                ),
                
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
                if (widget.index == 0)
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
                else if (widget.isHost)
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