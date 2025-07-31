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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual game session state from provider
    const isLoading = false;
    const gamePin = "123456";
    const joinedPlayers = 0;
    const isGameStarted = false;

    return PageLayout(
      title: 'Host Game',
      child: isLoading
          ? const LoadingIndicator(message: 'Creating game session...')
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.spacingXL),

                  // Large PIN Display
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const PinDisplay(pin: gamePin),
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
                          '$joinedPlayers Players',
                          style: AppTextStyles.sectionHeader,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Host controls
                  if (!isGameStarted) ...[
                    PrimaryButton(
                      onPressed: joinedPlayers > 0
                          ? () {
                              // TODO: Start game logic
                            }
                          : null,
                      text: 'Start Game',
                      isEnabled: joinedPlayers > 0,
                      width: double.infinity,
                    ),
                    const SizedBox(height: AppSpacing.spacingM),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Cancel Game',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    ),
                  ] else
                    const HostControlPanel(),

                  const SizedBox(height: AppSpacing.spacingXL),
                ],
              ),
            ),
    );
  }
}
