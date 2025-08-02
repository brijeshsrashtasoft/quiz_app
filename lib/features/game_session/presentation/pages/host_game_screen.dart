import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/feedback/loading_indicators.dart';
import '../widgets/pin_display.dart';
import '../widgets/host_control_panel.dart';
import '../providers/session_providers.dart';
import '../../domain/entities/game_session_entity.dart';

class HostGameScreen extends ConsumerStatefulWidget {
  const HostGameScreen({super.key});

  @override
  ConsumerState<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends ConsumerState<HostGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.elastic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _animationController.forward();

    // Create game session when screen loads
    // TODO: Replace with actual quiz selection - using test quiz for now
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(hostSessionStateNotifierProvider.notifier)
          .createSession(quizId: 'test-quiz-id');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostSessionState = ref.watch(hostSessionStateNotifierProvider);

    return PageLayout(
      title: 'Host Game',
      body: _buildContent(hostSessionState),
    );
  }

  Widget _buildContent(HostSessionState state) {
    if (state.isInitial || state.isCreating) {
      return const LoadingSpinner(message: 'Creating game session...');
    } else if (state.isCreated && state.session != null) {
      return _buildSessionWaitingScreen(state.session!);
    } else if (state.isStarting && state.session != null) {
      return const LoadingSpinner(message: 'Starting game...');
    } else if (state.isActive && state.session != null) {
      return _buildActiveGameScreen(state.session!);
    } else if (state.isCompleted && state.session != null) {
      return _buildCompletedGameScreen(state.session!);
    } else if (state.hasError) {
      return _buildErrorScreen(state.errorMessage ?? 'Unknown error occurred');
    } else {
      return const LoadingSpinner(message: 'Initializing...');
    }
  }

  Widget _buildSessionWaitingScreen(GameSessionEntity session) {
    final playerCount = session.playerCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacingXL),

          // Large PIN Display
          ScaleTransition(
            scale: _scaleAnimation,
            child: PinDisplay(pin: session.pin),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Instructions
          Text(
            'Players can join using this PIN at',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'quizapp.com/join',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.vibrantPurple,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Player count
          Container(
            padding: AppSpacing.allM,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
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
                  Icons.people_alt_rounded,
                  color: AppColors.vibrantPurple,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Text(
                  '$playerCount Players',
                  style: AppTextStyles.sectionHeader,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Host controls
          PrimaryButton(
            onPressed: playerCount > 0
                ? () {
                    ref
                        .read(hostSessionStateNotifierProvider.notifier)
                        .startSession();
                  }
                : null,
            text: 'Start Game',
            isDisabled: playerCount == 0,
            width: double.infinity,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          TextButton(
            onPressed: () {
              ref
                  .read(hostSessionStateNotifierProvider.notifier)
                  .cancelSession();
              context.pop();
            },
            child: Text(
              'Cancel Game',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),
        ],
      ),
    );
  }

  Widget _buildActiveGameScreen(GameSessionEntity session) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacingL),

          // Game Status
          Container(
            padding: AppSpacing.allM,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Text(
                  'Game in Progress',
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // PIN Display (smaller)
          Container(
            padding: AppSpacing.allM,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Game PIN',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.coolGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Text(
                  session.pin,
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.vibrantPurple,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Host Control Panel
          const Expanded(child: HostControlPanel()),

          const SizedBox(height: AppSpacing.spacingXL),
        ],
      ),
    );
  }

  Widget _buildCompletedGameScreen(GameSessionEntity session) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 80,
            color: AppColors.achievement,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Game Completed!',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Thanks for hosting a great game!',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: () => context.pop(),
            text: 'Back to Home',
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Error Creating Game',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            message,
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: () {
              // Try creating session again
              ref
                  .read(hostSessionStateNotifierProvider.notifier)
                  .createSession(quizId: 'test-quiz-id');
            },
            text: 'Try Again',
            width: double.infinity,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Go Back',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
          ),
        ],
      ),
    );
  }
}
