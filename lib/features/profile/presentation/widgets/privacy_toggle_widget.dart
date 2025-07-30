import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Privacy toggle widget for settings with Kahoot-style design
/// Includes smooth animations and engaging visual feedback
class PrivacyToggleWidget extends StatefulWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? iconColor;
  final bool isEnabled;

  const PrivacyToggleWidget({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconColor,
    this.isEnabled = true,
  });

  @override
  State<PrivacyToggleWidget> createState() => _PrivacyToggleWidgetState();
}

class _PrivacyToggleWidgetState extends State<PrivacyToggleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _colorAnimation =
        ColorTween(
          begin: AppColors.pureWhite,
          end: AppColors.vibrantPurple.withValues(alpha: 0.05),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppAnimations.easeInOut,
          ),
        );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PrivacyToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!widget.isEnabled) return;

    final newValue = !widget.value;
    widget.onChanged(newValue);

    // Trigger press animation
    _animationController.forward().then((_) {
      if (mounted && !newValue) {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildToggleContainer(),
        );
      },
    );
  }

  Widget _buildToggleContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
      decoration: BoxDecoration(
        color: _colorAnimation.value,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.value
              ? AppColors.vibrantPurple.withValues(alpha: 0.3)
              : AppColors.lightGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.value
                ? AppColors.vibrantPurple.withValues(alpha: 0.1)
                : AppColors.shadowLight,
            blurRadius: widget.value ? 12 : 8,
            spreadRadius: widget.value ? 2 : 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: AppSpacing.allM,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (widget.iconColor ?? AppColors.vibrantPurple)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon!,
                      color: widget.iconColor ?? AppColors.vibrantPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingM),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isEnabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        widget.description,
                        style: AppTextStyles.caption.copyWith(
                          color: widget.isEnabled
                              ? AppColors.textSecondary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.spacingM),

                _AnimatedToggleSwitch(
                  value: widget.value,
                  onChanged: widget.isEnabled ? _handleToggle : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated toggle switch with smooth transitions
class _AnimatedToggleSwitch extends StatefulWidget {
  final bool value;
  final VoidCallback? onChanged;

  const _AnimatedToggleSwitch({required this.value, this.onChanged});

  @override
  State<_AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<_AnimatedToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _positionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: AppColors.lightGray,
          end: AppColors.vibrantPurple,
        ).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.easeInOut),
        );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const switchWidth = 52.0;
    const switchHeight = 28.0;
    const thumbSize = 24.0;
    const thumbPadding = 2.0;

    return GestureDetector(
      onTap: widget.onChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: switchWidth,
            height: switchHeight,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(switchHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: (_colorAnimation.value ?? AppColors.lightGray)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: AppAnimations.shortAnimation,
                  curve: AppAnimations.easeInOut,
                  left:
                      thumbPadding +
                      (switchWidth - thumbSize - 2 * thumbPadding) *
                          _positionAnimation.value,
                  top: thumbPadding,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowDark,
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: widget.value
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.vibrantPurple,
                          )
                        : const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.lightGray,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Pre-built privacy toggle widgets for common settings

/// Profile visibility toggle
class ProfileVisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const ProfileVisibilityToggle({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PrivacyToggleWidget(
      title: 'Public Profile',
      description: 'Allow others to view your profile and statistics',
      value: isPublic,
      onChanged: onChanged,
      icon: Icons.public,
      iconColor: AppColors.turquoise,
    );
  }
}

/// Game history visibility toggle
class GameHistoryVisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final ValueChanged<bool> onChanged;

  const GameHistoryVisibilityToggle({
    super.key,
    required this.isVisible,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PrivacyToggleWidget(
      title: 'Show Game History',
      description: 'Allow others to see your recent games and scores',
      value: isVisible,
      onChanged: onChanged,
      icon: Icons.history,
      iconColor: AppColors.mintGreen,
    );
  }
}

/// Online status visibility toggle
class OnlineStatusToggle extends StatelessWidget {
  final bool showOnlineStatus;
  final ValueChanged<bool> onChanged;

  const OnlineStatusToggle({
    super.key,
    required this.showOnlineStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PrivacyToggleWidget(
      title: 'Show Online Status',
      description: 'Let others know when you\'re available to play',
      value: showOnlineStatus,
      onChanged: onChanged,
      icon: Icons.circle,
      iconColor: AppColors.achievement,
    );
  }
}

/// Notification preferences toggle
class NotificationToggle extends StatelessWidget {
  final String title;
  final String description;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const NotificationToggle({
    super.key,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PrivacyToggleWidget(
      title: title,
      description: description,
      value: isEnabled,
      onChanged: onChanged,
      icon: icon,
      iconColor: AppColors.vibrantPurple,
    );
  }
}

/// Email notifications toggle
class EmailNotificationsToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const EmailNotificationsToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationToggle(
      title: 'Email Notifications',
      description: 'Receive game invites and updates via email',
      isEnabled: isEnabled,
      onChanged: onChanged,
      icon: Icons.email_outlined,
    );
  }
}

/// Push notifications toggle
class PushNotificationsToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const PushNotificationsToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationToggle(
      title: 'Push Notifications',
      description: 'Receive notifications on your device',
      isEnabled: isEnabled,
      onChanged: onChanged,
      icon: Icons.notifications_outlined,
    );
  }
}

/// Game invites toggle
class GameInvitesToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const GameInvitesToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationToggle(
      title: 'Game Invitations',
      description: 'Allow others to invite you to games',
      isEnabled: isEnabled,
      onChanged: onChanged,
      icon: Icons.sports_esports,
    );
  }
}
