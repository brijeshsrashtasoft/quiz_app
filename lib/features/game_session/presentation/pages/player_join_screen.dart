import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../widgets/pin_entry_widget.dart';
import '../widgets/nickname_input.dart';

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

  void _handlePinSubmit() {
    if (_pinController.text.length == 6) {
      setState(() {
        _showNicknameInput = true;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _handleJoinGame() {
    if (_nicknameController.text.trim().isNotEmpty) {
      setState(() {
        _isJoining = true;
      });

      // TODO: Implement actual join logic
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.push('/game/lobby');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Join Game',
      child: AnimatedBuilder(
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
                          color: AppColors.vibrantPurple.withOpacity(0.3),
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

                  // Back button
                  if (_showNicknameInput && !_isJoining)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showNicknameInput = false;
                          _pinController.clear();
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
