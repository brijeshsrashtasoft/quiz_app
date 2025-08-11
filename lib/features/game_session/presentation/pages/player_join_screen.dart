import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../widgets/pin_entry_widget.dart';
import '../widgets/nickname_input.dart';
import '../providers/session_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/utils/logger.dart';

class PlayerJoinScreen extends ConsumerStatefulWidget {
  const PlayerJoinScreen({super.key});

  @override
  ConsumerState<PlayerJoinScreen> createState() => _PlayerJoinScreenState();
}

class _PlayerJoinScreenState extends ConsumerState<PlayerJoinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _pinController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _showNicknameInput = false;
  bool _isJoining = false;
  String? _errorMessage;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handlePinSubmit() async {
    if (_pinController.text.length == 6) {
      final pin = _pinController.text.trim();

      setState(() {
        _isJoining = true;
        _errorMessage = null;
      });

      try {
        AppLogger.firebase('PlayerJoin', 'Looking up session for PIN: $pin');

        // Look up session by PIN
        final sessionId = await ref.read(
          optimizedPinLookupProvider(pin).future,
        );

        if (sessionId != null) {
          // PIN is valid, get session details to validate
          final session = await ref.read(gameSessionProvider(sessionId).future);

          if (session != null) {
            final currentUser = ref.read(currentUserProvider);
            if (currentUser == null) {
              setState(() {
                _isJoining = false;
                _errorMessage = 'Please sign in to join the game';
              });
              return;
            }

            // Validate if user can join
            if (!session.canUserJoin(currentUser.id)) {
              String errorMsg;
              if (session.isFull) {
                errorMsg =
                    'Game is full (${session.playerCount}/${session.settings?.maxPlayers ?? 50} players)';
              } else if (!session.status.canJoin) {
                errorMsg = 'Game is already in progress or completed';
              } else if (session.isPlayer(currentUser.id)) {
                errorMsg = 'You have already joined this game';
              } else {
                errorMsg = 'Cannot join this game';
              }

              setState(() {
                _isJoining = false;
                _errorMessage = errorMsg;
              });
              return;
            }

            // PIN is valid and user can join - store session ID and show nickname input
            _currentSessionId = sessionId;
            setState(() {
              _showNicknameInput = true;
              _isJoining = false;
              _errorMessage = null;
            });
            _animationController.reset();
            _animationController.forward();

            AppLogger.firebase('PlayerJoin', 'Valid session found: $sessionId');
          } else {
            setState(() {
              _isJoining = false;
              _errorMessage = 'Game session not found or expired';
            });
          }
        } else {
          setState(() {
            _isJoining = false;
            _errorMessage = 'Invalid game PIN. Please check and try again.';
          });
        }
      } catch (e) {
        AppLogger.error('PIN validation failed', e);
        setState(() {
          _isJoining = false;
          _errorMessage = 'Failed to validate PIN. Please try again.';
        });
      }
    }
  }

  void _handleJoinGame() async {
    if (_nicknameController.text.trim().isNotEmpty &&
        _currentSessionId != null) {
      final nickname = _nicknameController.text.trim();

      setState(() {
        _isJoining = true;
        _errorMessage = null;
      });

      try {
        AppLogger.firebase(
          'PlayerJoin',
          'Attempting to join session: $_currentSessionId with nickname: $nickname',
        );

        // Check authentication one more time
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null) {
          setState(() {
            _isJoining = false;
            _errorMessage = 'Please sign in to join the game';
          });
          return;
        }

        // Use the session state notifier to join the game
        final sessionNotifier = ref.read(
          sessionStateNotifierProvider(_currentSessionId!).notifier,
        );

        await sessionNotifier.joinSession(nickname);

        // Wait a moment for the state to update
        await Future.delayed(const Duration(milliseconds: 500));

        // Check the session state after joining
        final sessionState = ref.read(
          sessionStateNotifierProvider(_currentSessionId!),
        );

        if (sessionState.hasError) {
          setState(() {
            _isJoining = false;
            _errorMessage = sessionState.errorMessage ?? 'Failed to join game';
          });
          AppLogger.error('Join game failed', sessionState.errorMessage);
          return;
        }

        if (sessionState.isLoaded && sessionState.session != null) {
          final session = sessionState.session!;

          // Verify the user actually joined
          if (session.isPlayer(currentUser.id)) {
            AppLogger.firebase(
              'PlayerJoin',
              'Successfully joined session: $_currentSessionId',
            );

            // Navigate to the game session waiting lobby
            if (mounted) {
              context.go('/game/$_currentSessionId/waiting');
            }
          } else {
            setState(() {
              _isJoining = false;
              _errorMessage =
                  'Failed to join game - player not found in session';
            });
          }
        } else {
          setState(() {
            _isJoining = false;
            _errorMessage = 'Failed to join game - session state invalid';
          });
        }
      } catch (e) {
        AppLogger.error('Join game error', e);
        setState(() {
          _isJoining = false;
          _errorMessage = 'Failed to join game: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Join Game',
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.spacingXXL),

                  // Logo or icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.gamepad_rounded,
                      size: 60,
                      color: AppColors.pureWhite,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.spacingXL),

                  Text(
                    _showNicknameInput
                        ? 'Choose your nickname'
                        : 'Enter game PIN',
                    style: AppTextStyles.sectionHeader,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.spacingXL),

                  // Input section
                  AnimatedSwitcher(
                    duration: AppAnimations.mediumAnimation,
                    child: _showNicknameInput
                        ? NicknameInput(
                            key: const ValueKey('nickname'),
                            controller: _nicknameController,
                            onSubmitted: (_) => _handleJoinGame(),
                          )
                        : PinEntryWidget(
                            key: const ValueKey('pin'),
                            controller: _pinController,
                            onCompleted: _handlePinSubmit,
                          ),
                  ),

                  const SizedBox(height: AppSpacing.spacingXL),

                  // Action button
                  PrimaryButton(
                    onPressed: _isJoining
                        ? null
                        : (_showNicknameInput
                              ? _handleJoinGame
                              : _handlePinSubmit),
                    text: _isJoining
                        ? 'Joining...'
                        : (_showNicknameInput ? 'Join Game' : 'Enter'),
                    isLoading: _isJoining,
                    width: double.infinity,
                  ),

                  const SizedBox(height: AppSpacing.spacingM),

                  // Error message display
                  if (_errorMessage != null) ...[
                    Container(
                      margin: const EdgeInsets.only(top: AppSpacing.spacingM),
                      padding: AppSpacing.allM,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.spacingS),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingM),
                  ],

                  // Back button
                  if (_showNicknameInput && !_isJoining)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showNicknameInput = false;
                          _errorMessage = null;
                          _currentSessionId = null;
                          _pinController.clear();
                          _nicknameController.clear();
                        });
                        _animationController.reset();
                        _animationController.forward();
                      },
                      child: Text(
                        'Change PIN',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    )
                  else if (!_isJoining)
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Back to Home',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Help text
                  Container(
                    padding: AppSpacing.allM,
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.coolGray,
                        ),
                        const SizedBox(width: AppSpacing.spacingS),
                        Flexible(
                          child: Text(
                            'Ask your host for the game PIN',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.spacingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
