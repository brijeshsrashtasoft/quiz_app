import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Animated player avatar for lobby and leaderboard screens
/// Reference: docs/ui_guideline.md - Game States & Feedback
class LobbyAvatar extends StatefulWidget {
  final String playerName;
  final String? avatarUrl;
  final bool isOnline;
  final bool isReady;
  final bool isHost;
  final Color? customColor;
  final VoidCallback? onTap;

  const LobbyAvatar({
    super.key,
    required this.playerName,
    this.avatarUrl,
    this.isOnline = true,
    this.isReady = false,
    this.isHost = false,
    this.customColor,
    this.onTap,
  });

  @override
  State<LobbyAvatar> createState() => _LobbyAvatarState();
}

class _LobbyAvatarState extends State<LobbyAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation for online status
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Bounce animation for ready state
    _bounceController = AnimationController(
      duration: AppAnimations.achievementDuration,
      vsync: this,
    );

    _pulseAnimation =
        Tween<double>(
          begin: AppAnimations.pulseScaleMin,
          end: AppAnimations.pulseScaleMax,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: AppAnimations.easeInOut,
          ),
        );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: AppAnimations.bounce),
    );

    // Start pulse animation if online
    if (widget.isOnline) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LobbyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle online status change
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Handle ready state change
    if (widget.isReady && !oldWidget.isReady) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  Color get _avatarColor {
    if (widget.customColor != null) return widget.customColor!;
    if (!widget.isOnline) return AppColors.disabled;
    if (widget.isHost) return AppColors.achievement;
    if (widget.isReady) return AppColors.success;
    return AppColors.vibrantPurple;
  }

  String get _initials {
    final words = widget.playerName.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.playerName}${widget.isHost ? ', Host' : ''}',
      value: widget.isOnline
          ? (widget.isReady ? 'Ready' : 'Not ready')
          : 'Offline',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale:
                  _bounceAnimation.value *
                  (widget.isOnline ? _pulseAnimation.value : 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar circle
                  Stack(
                    children: [
                      // Main avatar
                      Container(
                        width: AppDimensions.avatarSizeLarge,
                        height: AppDimensions.avatarSizeLarge,
                        decoration: BoxDecoration(
                          color: _avatarColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isReady
                                ? AppColors.success
                                : AppColors.pureWhite,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _avatarColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: widget.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  widget.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildInitialsAvatar(),
                                ),
                              )
                            : _buildInitialsAvatar(),
                      ),

                      // Status indicators
                      if (widget.isHost)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.achievement,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.pureWhite,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: AppColors.pureWhite,
                              size: 12,
                            ),
                          ),
                        ),

                      // Online status
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: widget.isOnline
                                ? AppColors.success
                                : AppColors.disabled,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.pureWhite,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Ready checkmark
                      if (widget.isReady && widget.isOnline)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.pureWhite,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.pureWhite,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.spacingS),

                  // Player name
                  Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      widget.playerName,
                      style: AppTextStyles.caption.copyWith(
                        color: widget.isOnline
                            ? AppColors.charcoal
                            : AppColors.disabled,
                        fontWeight: widget.isHost
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Status text
                  if (!widget.isOnline || widget.isReady)
                    Text(
                      !widget.isOnline ? 'Offline' : 'Ready!',
                      style: AppTextStyles.caption.copyWith(
                        color: !widget.isOnline
                            ? AppColors.disabled
                            : AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _initials,
        style: AppTextStyles.sectionHeader.copyWith(
          color: AppColors.pureWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Compact avatar for smaller spaces
class CompactLobbyAvatar extends StatelessWidget {
  final String playerName;
  final bool isOnline;
  final bool isReady;
  final bool isHost;

  const CompactLobbyAvatar({
    super.key,
    required this.playerName,
    this.isOnline = true,
    this.isReady = false,
    this.isHost = false,
  });

  String get _initials {
    final words = playerName.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Color get _avatarColor {
    if (!isOnline) return AppColors.disabled;
    if (isHost) return AppColors.achievement;
    if (isReady) return AppColors.success;
    return AppColors.vibrantPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: AppDimensions.avatarSizeMedium,
              height: AppDimensions.avatarSizeMedium,
              decoration: BoxDecoration(
                color: _avatarColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isReady ? AppColors.success : AppColors.pureWhite,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Status indicator
            if (isHost || !isOnline)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isHost ? AppColors.achievement : AppColors.disabled,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pureWhite, width: 1),
                  ),
                  child: isHost
                      ? const Icon(
                          Icons.star,
                          color: AppColors.pureWhite,
                          size: 8,
                        )
                      : null,
                ),
              ),
          ],
        ),

        const SizedBox(width: AppSpacing.spacingS),

        // Name and status
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playerName,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: isHost ? FontWeight.w600 : FontWeight.w400,
                color: isOnline ? AppColors.charcoal : AppColors.disabled,
              ),
            ),
            if (isReady)
              Text(
                'Ready',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
