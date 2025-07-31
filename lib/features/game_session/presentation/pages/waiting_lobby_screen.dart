import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/quiz/lobby_avatar.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/lobby_player_list.dart';

class WaitingLobbyScreen extends ConsumerStatefulWidget {
  final bool isHost;

  const WaitingLobbyScreen({super.key, this.isHost = false});

  @override
  ConsumerState<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends ConsumerState<WaitingLobbyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _staggerController;
  late Animation<double> _pulseAnimation;

  // Mock data - replace with actual provider data
  final List<Map<String, dynamic>> _players = [
    {
      'id': '1',
      'name': 'Quiz Master',
      'isReady': true,
      'joinedAt': DateTime.now(),
    },
    {
      'id': '2',
      'name': 'Brain Storm',
      'isReady': true,
      'joinedAt': DateTime.now().subtract(const Duration(seconds: 5)),
    },
    {
      'id': '3',
      'name': 'Smart Cookie',
      'isReady': false,
      'joinedAt': DateTime.now().subtract(const Duration(seconds: 10)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _staggerController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Waiting for Players',
      actions: [
        ConnectionStatusIndicator(isConnected: true, onReconnect: () {}),
      ],
      child: Column(
        children: [
          // Game info header
          Container(
            padding: AppSpacing.allL,
            margin: const EdgeInsets.only(bottom: AppSpacing.spacingL),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Science Quiz Challenge',
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.pureWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  'PIN: 123456',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.pureWhite.withOpacity(0.9),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // Waiting animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.warmYellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.warmYellow.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.warmYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: AppColors.pureWhite,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Status text
          Text(
            widget.isHost
                ? 'Waiting for players to join...'
                : 'Waiting for host to start...',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Player count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingL,
              vertical: AppSpacing.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_rounded,
                  color: AppColors.vibrantPurple,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Text(
                  '${_players.length} Players',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Player list
          Expanded(
            child: LobbyPlayerList(
              players: _players,
              staggerController: _staggerController,
              isHost: widget.isHost,
            ),
          ),

          // Host controls or player status
          if (widget.isHost)
            Container(
              padding: AppSpacing.allL,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _players.length >= 2
                        ? () {
                            // TODO: Start game
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.turquoise,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingXL,
                        vertical: AppSpacing.spacingL,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text('Start Game', style: AppTextStyles.buttonLarge),
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  Text(
                    'Need at least 2 players to start',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: AppSpacing.allL,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.turquoise,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                  Text(
                    'You\'re in! Get ready...',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.turquoise,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
