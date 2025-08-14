import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';
import 'device_management_widgets.dart';

/// Session list tile showing active session details with device information
/// Follows Kahoot-style design with security-focused UX patterns
/// Reference: docs/ui_guideline.md
class SessionListTile extends StatefulWidget {
  final SessionInfo sessionInfo;
  final bool isCurrentSession;
  final VoidCallback? onTerminate;
  final VoidCallback? onViewDetails;

  const SessionListTile({
    super.key,
    required this.sessionInfo,
    this.isCurrentSession = false,
    this.onTerminate,
    this.onViewDetails,
  });

  @override
  State<SessionListTile> createState() => _SessionListTileState();
}

class _SessionListTileState extends State<SessionListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleLongPress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onViewDetails?.call();
  }

  IconData _getDeviceIcon(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return Icons.smartphone;
      case DeviceType.tablet:
        return Icons.tablet;
      case DeviceType.desktop:
        return Icons.computer;
      case DeviceType.web:
        return Icons.web;
    }
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return AppColors.success;
      case SessionStatus.idle:
        return AppColors.warning;
      case SessionStatus.expired:
        return AppColors.error;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.idle:
        return 'Idle';
      case SessionStatus.expired:
        return 'Expired';
    }
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingS,
            ),
            elevation: widget.isCurrentSession ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              side: widget.isCurrentSession
                  ? BorderSide(color: AppColors.vibrantPurple, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: _handleTap,
              onLongPress: _handleLongPress,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: AnimatedContainer(
                duration: AppAnimations.mediumAnimation,
                curve: AppAnimations.easeInOut,
                padding: AppSpacing.allM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main session info
                    Row(
                      children: [
                        // Device icon with status indicator
                        Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.vibrantPurple.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              child: Icon(
                                _getDeviceIcon(widget.sessionInfo.deviceType),
                                color: AppColors.vibrantPurple,
                                size: 24,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getStatusColor(
                                    widget.sessionInfo.status,
                                  ),
                                  border: Border.all(
                                    color: AppColors.pureWhite,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: AppSpacing.spacingM),

                        // Device and location info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.sessionInfo.deviceName,
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: widget.isCurrentSession
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.isCurrentSession)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.spacingS,
                                        vertical: AppSpacing.spacingXS,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.vibrantPurple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Current',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.pureWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.spacingXS),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppSpacing.spacingXS),
                                  Expanded(
                                    child: Text(
                                      widget.sessionInfo.location,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Status and expand button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacingS,
                                vertical: AppSpacing.spacingXS,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  widget.sessionInfo.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(
                                    widget.sessionInfo.status,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(widget.sessionInfo.status),
                                style: AppTextStyles.caption.copyWith(
                                  color: _getStatusColor(
                                    widget.sessionInfo.status,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.spacingXS),
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: AppAnimations.shortAnimation,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Expanded details
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildExpandedDetails(),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: AppAnimations.mediumAnimation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails() {
    return Column(
      children: [
        SizedBox(height: AppSpacing.spacingM),
        Divider(color: AppColors.lightGray),
        SizedBox(height: AppSpacing.spacingM),

        // Session details
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Active',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.spacingXS),
                  Text(
                    _formatLastActive(widget.sessionInfo.lastActive),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IP Address',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.spacingXS),
                  Text(
                    widget.sessionInfo.ipAddress,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.spacingM),

        // Action buttons
        if (!widget.isCurrentSession)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onTerminate,
              icon: Icon(Icons.logout, size: 18),
              label: Text('Terminate Session'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Session timeout picker for setting automatic session expiration
class SessionTimeoutPicker extends StatefulWidget {
  final Duration currentTimeout;
  final ValueChanged<Duration> onTimeoutChanged;
  final List<Duration> presetOptions;

  const SessionTimeoutPicker({
    super.key,
    required this.currentTimeout,
    required this.onTimeoutChanged,
    this.presetOptions = const [
      Duration(minutes: 5),
      Duration(minutes: 15),
      Duration(minutes: 30),
      Duration(hours: 1),
      Duration(hours: 4),
      Duration(hours: 8),
      Duration(days: 1),
    ],
  });

  @override
  State<SessionTimeoutPicker> createState() => _SessionTimeoutPickerState();
}

class _SessionTimeoutPickerState extends State<SessionTimeoutPicker> {
  late Duration _selectedTimeout;

  @override
  void initState() {
    super.initState();
    _selectedTimeout = widget.currentTimeout;
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: AppSpacing.allL,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Session Timeout',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: AppSpacing.spacingS),
            Text(
              'Choose how long you want to stay signed in when inactive.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Timeout options
            ...widget.presetOptions.map(
              (duration) => _buildTimeoutOption(duration),
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTimeoutChanged(_selectedTimeout);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantPurple,
                      foregroundColor: AppColors.pureWhite,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text('Save', style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutOption(Duration duration) {
    final isSelected = _selectedTimeout == duration;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.spacingS),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTimeout = duration;
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          padding: AppSpacing.allM,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.vibrantPurple : AppColors.lightGray,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            color: isSelected
                ? AppColors.vibrantPurple.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Radio<Duration>(
                value: duration,
                groupValue: _selectedTimeout,
                onChanged: (value) {
                  setState(() {
                    _selectedTimeout = value!;
                  });
                },
                activeColor: AppColors.vibrantPurple,
              ),
              SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: Text(
                  _formatDuration(duration),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data models for session management
class SessionInfo {
  final String id;
  final String deviceName;
  final DeviceType deviceType;
  final String location;
  final String ipAddress;
  final DateTime lastActive;
  final DateTime createdAt;
  final SessionStatus status;

  const SessionInfo({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.location,
    required this.ipAddress,
    required this.lastActive,
    required this.createdAt,
    required this.status,
  });
}

// DeviceType enum moved to device_management_widgets.dart to avoid conflicts

enum SessionStatus { active, idle, expired }
