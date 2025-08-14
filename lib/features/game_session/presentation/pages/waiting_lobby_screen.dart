import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/feedback/loading_indicators.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/lobby_player_list.dart';
import '../providers/session_providers.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';
import '../../../../core/utils/performance/connection_manager.dart' as conn;

class WaitingLobbyScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final bool isHost;

  const WaitingLobbyScreen({
    super.key,
    required this.sessionId,
    this.isHost = false,
  });

  @override
  ConsumerState<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends ConsumerState<WaitingLobbyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _staggerController;
  late Animation<double> _pulseAnimation;

  GameSessionEntity? _currentSession;
  String? _quizTitle;
  bool _isStartingGame = false;

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

    AppLogger.firebase(
      'WaitingLobbyScreen',
      'Initialized for session: ${widget.sessionId}',
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch session stream for real-time updates
    final sessionAsyncValue = ref.watch(
      gameSessionStreamProvider(widget.sessionId),
    );
    final connectionState = ref.watch(connectionStateProvider);

    return PageLayout(
      title: 'Waiting for Players',
      actions: [
        connectionState.when(
          data: (state) => ConnectionStatusIndicator(
            isConnected: state == conn.ConnectionState.online,
            onReconnect: () {
              // Refresh session data
              ref.invalidate(gameSessionStreamProvider(widget.sessionId));
            },
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => ConnectionStatusIndicator(
            isConnected: false,
            onReconnect: () {
              ref.invalidate(gameSessionStreamProvider(widget.sessionId));
            },
          ),
        ),
      ],
      body: sessionAsyncValue.when(
        loading: () => const LoadingSpinner(message: 'Loading game session...'),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (session) {
          if (session == null) {
            return _buildErrorState('Game session not found');
          }

          _currentSession = session;

          // Handle session state changes
          if (session.status == GameSessionStatus.active) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleGameStarted(context);
            });
          } else if (session.status == GameSessionStatus.completed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleGameCompleted(context);
            });
          }

          return _buildWaitingContent(session);
        },
      ),
    );
  }

  Widget _buildWaitingContent(GameSessionEntity session) {
    // Get quiz data for display
    final quizAsyncValue = ref.watch(quizByIdProvider(session.quizId));

    return quizAsyncValue.when(
      loading: () => const LoadingSpinner(message: 'Loading quiz data...'),
      error: (error, _) => _buildSessionContent(session, 'Quiz'),
      data: (quiz) {
        _quizTitle = quiz?.title ?? 'Unknown Quiz';
        return _buildSessionContent(session, _quizTitle!);
      },
    );
  }

  Widget _buildSessionContent(GameSessionEntity session, String quizTitle) {
    return Column(
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
                color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                quizTitle,
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.pureWhite,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                'PIN: ${session.pin}',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.pureWhite.withValues(alpha: 0.9),
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
                  color: AppColors.warmYellow.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.warmYellow.withValues(alpha: 0.4),
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
                        child: Icon(
                          _isStartingGame
                              ? Icons.play_arrow_rounded
                              : Icons.hourglass_top_rounded,
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
          _isStartingGame
              ? 'Starting game...'
              : (widget.isHost
                    ? 'Waiting for players to join...'
                    : 'Waiting for host to start...'),
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
                '${session.playerCount} Players',
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
            players: session.players,
            hostId: session.hostId,
            staggerController: _staggerController,
            isCurrentUserHost: widget.isHost,
          ),
        ),

        // Host controls or player status
        if (widget.isHost)
          Container(
            padding: AppSpacing.allL,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: (session.playerCount >= 1 && !_isStartingGame)
                      ? () => _startGame()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isStartingGame
                        ? AppColors.coolGray
                        : AppColors.turquoise,
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
                  child: _isStartingGame
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.pureWhite,
                              ),
                            ),
                            SizedBox(width: AppSpacing.spacingM),
                            Text('Starting...'),
                          ],
                        )
                      : Text('Start Game', style: AppTextStyles.buttonLarge),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                Text(
                  session.playerCount == 0
                      ? 'Waiting for players to join...'
                      : 'Ready to start! ${session.playerCount} player(s) joined',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
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
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Session Error',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            errorMessage,
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantPurple,
              foregroundColor: AppColors.pureWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingXL,
                vertical: AppSpacing.spacingM,
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Future<void> _startGame() async {
    if (_currentSession == null || _isStartingGame) return;

    setState(() {
      _isStartingGame = true;
    });

    try {
      AppLogger.firebase(
        'WaitingLobbyScreen',
        'Starting game session: ${widget.sessionId}',
      );

      // Use the session state notifier to start the game
      await ref
          .read(sessionStateNotifierProvider(widget.sessionId).notifier)
          .startSession();

      // The navigation will be handled by session state change listener
    } catch (e) {
      AppLogger.error('Failed to start game', e);

      if (mounted) {
        setState(() {
          _isStartingGame = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start game: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleGameStarted(BuildContext context) {
    AppLogger.firebase(
      'WaitingLobbyScreen',
      'Game started, navigating to game session',
    );

    // Navigate to the active game session
    context.go('/game/${widget.sessionId}');
  }

  void _handleGameCompleted(BuildContext context) {
    AppLogger.firebase(
      'WaitingLobbyScreen',
      'Game completed, navigating to results',
    );

    // Navigate to game results
    context.go('/game/${widget.sessionId}/results');
  }
}
