import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Device management card showing trusted device information with trust level indicators
/// Follows Kahoot-style design with security-focused UX patterns
/// Reference: docs/ui_guideline.md
class DeviceManagementCard extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final bool isCurrentDevice;
  final VoidCallback? onRevokeTrust;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEditName;

  const DeviceManagementCard({
    super.key,
    required this.deviceInfo,
    this.isCurrentDevice = false,
    this.onRevokeTrust,
    this.onViewDetails,
    this.onEditName,
  });

  @override
  State<DeviceManagementCard> createState() => _DeviceManagementCardState();
}

class _DeviceManagementCardState extends State<DeviceManagementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
      _showActions = !_showActions;
    });
  }

  void _handleLongPress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onViewDetails?.call();
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
            elevation: widget.isCurrentDevice ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              side: widget.isCurrentDevice
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
                    // Main device info
                    Row(
                      children: [
                        // Device icon with trust level indicator
                        Stack(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.vibrantPurple.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              child: Icon(
                                _getDeviceIcon(widget.deviceInfo.deviceType),
                                color: AppColors.vibrantPurple,
                                size: 28,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: TrustLevelIndicator(
                                trustLevel: widget.deviceInfo.trustLevel,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: AppSpacing.spacingM),

                        // Device details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.deviceInfo.name,
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: widget.isCurrentDevice
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.isCurrentDevice)
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
                                        'This Device',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.pureWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.spacingXS),
                              Text(
                                '${widget.deviceInfo.platform} • ${_formatLastSeen(widget.deviceInfo.lastSeen)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.spacingXS),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppSpacing.spacingXS),
                                  Expanded(
                                    child: Text(
                                      widget.deviceInfo.location,
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

                        // More actions indicator
                        AnimatedRotation(
                          turns: _showActions ? 0.5 : 0,
                          duration: AppAnimations.shortAnimation,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    // Trust level details
                    SizedBox(height: AppSpacing.spacingM),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.spacingS),
                      decoration: BoxDecoration(
                        color: _getTrustLevelColor(
                          widget.deviceInfo.trustLevel,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getTrustLevelColor(
                            widget.deviceInfo.trustLevel,
                          ).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getTrustLevelIcon(widget.deviceInfo.trustLevel),
                            size: 16,
                            color: _getTrustLevelColor(
                              widget.deviceInfo.trustLevel,
                            ),
                          ),
                          SizedBox(width: AppSpacing.spacingS),
                          Text(
                            _getTrustLevelText(widget.deviceInfo.trustLevel),
                            style: AppTextStyles.caption.copyWith(
                              color: _getTrustLevelColor(
                                widget.deviceInfo.trustLevel,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expanded actions
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildActionButtons(),
                      crossFadeState: _showActions
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(height: AppSpacing.spacingM),
        Divider(color: AppColors.lightGray),
        SizedBox(height: AppSpacing.spacingM),

        Row(
          children: [
            if (widget.onEditName != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onEditName,
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Rename'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.vibrantPurple,
                    side: BorderSide(color: AppColors.vibrantPurple),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.spacingS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.buttonRadius,
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.onEditName != null && !widget.isCurrentDevice)
              SizedBox(width: AppSpacing.spacingS),
            if (!widget.isCurrentDevice && widget.onRevokeTrust != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRevokeTrust,
                  icon: Icon(Icons.security, size: 16),
                  label: Text('Revoke Trust'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.spacingS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.buttonRadius,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
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

  Color _getTrustLevelColor(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.trusted:
        return AppColors.success;
      case TrustLevel.recognized:
        return AppColors.warning;
      case TrustLevel.untrusted:
        return AppColors.error;
    }
  }

  IconData _getTrustLevelIcon(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.trusted:
        return Icons.verified;
      case TrustLevel.recognized:
        return Icons.info;
      case TrustLevel.untrusted:
        return Icons.warning;
    }
  }

  String _getTrustLevelText(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.trusted:
        return 'Trusted Device';
      case TrustLevel.recognized:
        return 'Recognized Device';
      case TrustLevel.untrusted:
        return 'Untrusted Device';
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }
}

/// Trust level indicator widget with color-coded security status
class TrustLevelIndicator extends StatelessWidget {
  final TrustLevel trustLevel;
  final double size;
  final bool showText;

  const TrustLevelIndicator({
    super.key,
    required this.trustLevel,
    this.size = 24,
    this.showText = false,
  });

  Color _getTrustLevelColor(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.trusted:
        return AppColors.success;
      case TrustLevel.recognized:
        return AppColors.warning;
      case TrustLevel.untrusted:
        return AppColors.error;
    }
  }

  IconData _getTrustLevelIcon(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.trusted:
        return Icons.verified;
      case TrustLevel.recognized:
        return Icons.info;
      case TrustLevel.untrusted:
        return Icons.warning;
    }
  }

  String _getTrustLevelText(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.trusted:
        return 'Trusted';
      case TrustLevel.recognized:
        return 'Recognized';
      case TrustLevel.untrusted:
        return 'Untrusted';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTrustLevelColor(trustLevel);

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: AppColors.pureWhite, width: 2),
            ),
            child: Icon(
              _getTrustLevelIcon(trustLevel),
              color: AppColors.pureWhite,
              size: size * 0.6,
            ),
          ),
          SizedBox(width: AppSpacing.spacingS),
          Text(
            _getTrustLevelText(trustLevel),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.pureWhite, width: 2),
      ),
      child: Icon(
        _getTrustLevelIcon(trustLevel),
        color: AppColors.pureWhite,
        size: size * 0.6,
      ),
    );
  }
}

/// New device approval flow widget
class NewDeviceApprovalFlow extends StatefulWidget {
  final DeviceInfo newDevice;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onViewDetails;

  const NewDeviceApprovalFlow({
    super.key,
    required this.newDevice,
    this.onApprove,
    this.onDeny,
    this.onViewDetails,
  });

  @override
  State<NewDeviceApprovalFlow> createState() => _NewDeviceApprovalFlowState();
}

class _NewDeviceApprovalFlowState extends State<NewDeviceApprovalFlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
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
                  children: [
                    // Security alert icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warning.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.security,
                        color: AppColors.warning,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacingL),

                    // Header
                    Text(
                      'New Device Login',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.spacingS),
                    Text(
                      'A new device is trying to access your account. Do you recognize this device?',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.spacingXL),

                    // Device info card
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.allM,
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getDeviceIcon(widget.newDevice.deviceType),
                                color: AppColors.vibrantPurple,
                                size: 24,
                              ),
                              SizedBox(width: AppSpacing.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.newDevice.name,
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      widget.newDevice.platform,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.spacingM),
                          _buildDetailRow(
                            Icons.location_on,
                            'Location',
                            widget.newDevice.location,
                          ),
                          SizedBox(height: AppSpacing.spacingS),
                          _buildDetailRow(
                            Icons.access_time,
                            'Time',
                            _formatDateTime(DateTime.now()),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacingXL),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onDeny,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error),
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
                              'Deny Access',
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onApprove,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
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
                            child: Text(
                              'Approve',
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.spacingM),

                    // View details link
                    TextButton(
                      onPressed: widget.onViewDetails,
                      child: Text(
                        'View More Details',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.vibrantPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: AppSpacing.spacingS),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Data models for device management
class DeviceInfo {
  final String id;
  final String name;
  final DeviceType deviceType;
  final String platform;
  final String location;
  final DateTime lastSeen;
  final TrustLevel trustLevel;
  final bool isCurrentDevice;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.platform,
    required this.location,
    required this.lastSeen,
    required this.trustLevel,
    this.isCurrentDevice = false,
  });
}

enum DeviceType { mobile, tablet, desktop, web }

enum TrustLevel { trusted, recognized, untrusted }
