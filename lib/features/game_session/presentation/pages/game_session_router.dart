import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_providers.dart';
import '../../domain/entities/game_session_entity.dart';
import 'waiting_lobby_screen.dart';
import 'game_play_page.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
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

        return userRole.when(
          data: (role) {
            final isHost = role == UserSessionRole.host;

            // Route based on session status
            switch (session.status) {
              case GameSessionStatus.waiting:
                return WaitingLobbyScreen(sessionId: sessionId, isHost: isHost);
              case GameSessionStatus.active:
                return GamePlayPage(
                  sessionId: sessionId,
                  quizId: session.quizId,
                );
              case GameSessionStatus.completed:
                return _buildCompletedState(context, session);
            }
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) => _buildErrorState(context, error.toString()),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: LoadingOverlay(
            isLoading: true,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildCompletedState(BuildContext context, dynamic session) {
    return Scaffold(
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
            SizedBox(height: AppSpacing.spacingL),
            Text(
              'Game Completed!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.vibrantPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.spacingM),
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
