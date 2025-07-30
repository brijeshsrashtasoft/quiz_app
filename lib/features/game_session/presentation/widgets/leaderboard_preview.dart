import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class LeaderboardPreview extends StatefulWidget {
  const LeaderboardPreview({super.key});

  @override
  State<LeaderboardPreview> createState() => _LeaderboardPreviewState();
}

class _LeaderboardPreviewState extends State<LeaderboardPreview> 
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _slideAnimations;
  
  // Mock leaderboard data
  final List<Map<String, dynamic>> _topPlayers = [
    {'name': 'Quiz Master', 'score': 5200, 'position': 1, 'change': 0},
    {'name': 'Brain Storm', 'score': 4800, 'position': 2, 'change': 1},
    {'name': 'Smart Cookie', 'score': 4500, 'position': 3, 'change': -1},
    {'name': 'You', 'score': 4200, 'position': 4, 'change': 2, 'isCurrentPlayer': true},
    {'name': 'Quick Think', 'score': 3900, 'position': 5, 'change': 0},
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _topPlayers.length,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: AppAnimations.leaderboardStagger.inMilliseconds * (index + 1),
        ),
        vsync: this,
      ),
    );
    
    _slideAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 50,
        end: 0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: AppAnimations.easeOut,
      ));
    }).toList();
    
    // Start animations sequentially
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(
        AppAnimations.getLeaderboardStagger(i),
        () {
          if (mounted) {
            _animationControllers[i].forward();
          }
        },
      );
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
          Text(
            'Leaderboard',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          
          Expanded(
            child: ListView.builder(
              itemCount: _topPlayers.length,
              itemBuilder: (context, index) {
                final player = _topPlayers[index];
                return AnimatedBuilder(
                  animation: _animationControllers[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimations[index].value),
                      child: FadeTransition(
                        opacity: _animationControllers[index],
                        child: _LeaderboardItem(
                          player: player,
                          index: index,
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
  final Map<String, dynamic> player;
  final int index;

  const _LeaderboardItem({
    required this.player,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final position = player['position'] as int;
    final isTopThree = position <= 3;
    final isCurrentPlayer = player['isCurrentPlayer'] ?? false;
    final change = player['change'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        gradient: isTopThree
            ? _getGradientForPosition(position)
            : null,
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
            child: Text(
              player['name'] as String,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: isCurrentPlayer ? FontWeight.w700 : FontWeight.w500,
                color: isTopThree
                    ? AppColors.pureWhite
                    : AppColors.charcoal,
              ),
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
            '${player['score']}',
            style: AppTextStyles.scoreDisplay.copyWith(
              fontSize: 20,
              color: isTopThree
                  ? AppColors.pureWhite
                  : AppColors.vibrantPurple,
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