import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_providers.dart';
import '../widgets/pin_display.dart';
import '../widgets/pin_entry_widget.dart';
import '../widgets/host_control_panel.dart';
import '../widgets/lobby_player_list.dart';
import '../widgets/connection_status_indicator.dart';
import 'game_play_page.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/widgets/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading/loading_overlay.dart';
import '../../../../shared/widgets/error/error_widget.dart';

/// Main router page for game sessions
/// Handles routing between different game states
class GameSessionRouter extends ConsumerWidget {
  final String sessionId;

  const GameSessionRouter({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(optimizedSessionStreamProvider(sessionId));
    final userRole = ref.watch(userSessionRoleProvider(sessionId));

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return _buildErrorState(context, 'Session not found');
        }

        // Route based on session status
        switch (session.status) {
          case GameSessionStatus.waiting:
            return _buildWaitingLobby(context, ref, session);
          case GameSessionStatus.active:
            return GamePlayPage(sessionId: sessionId, quizId: session.quizId);
          case GameSessionStatus.completed:
            return _buildCompletedState(context, session);
        }
      },
      loading: () => const Scaffold(body: Center(child: LoadingOverlay())),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildWaitingLobby(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
  ) {
    final userRole = ref.watch(userSessionRoleProvider(sessionId)).value;
    final isHost = userRole == UserSessionRole.host;

    return AppScaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Waiting Lobby'),
        backgroundColor: AppColors.vibrantPurple,
        foregroundColor: AppColors.pureWhite,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.spacingL),
          child: Column(
            children: [
              // PIN Display
              PinDisplay(pin: session.pin),

              AppSpacing.verticalSpacingXL,

              // Player List
              Expanded(
                child: LobbyPlayerList(
                  players: session.players,
                  hostId: session.hostId,
                ),
              ),

              // Host Controls
              if (isHost) ...[
                AppSpacing.verticalSpacingL,
                HostControlPanel(
                  sessionId: sessionId,
                  canStart: session.playerCount >= 2,
                  onStart: () {
                    ref
                        .read(sessionStateNotifierProvider(sessionId).notifier)
                        .startSession();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context, dynamic session) {
    return AppScaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 100,
              color: AppColors.warmYellow,
            ),
            AppSpacing.verticalSpacingL,
            Text(
              'Game Completed!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.vibrantPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpacingM,
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: AppErrorWidget(
          title: 'Error',
          message: error,
          onRetry: () => context.go('/'),
        ),
      ),
    );
  }
}
