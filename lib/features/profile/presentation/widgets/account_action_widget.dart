import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Account action widget for dangerous actions like account deletion
/// Includes confirmation dialogs and security measures with Kahoot-style design
class AccountActionWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? warningText;
  final IconData icon;
  final Color actionColor;
  final VoidCallback onAction;
  final bool requiresConfirmation;
  final String? confirmationTitle;
  final String? confirmationMessage;
  final String? confirmationButtonText;
  final bool isDestructive;

  const AccountActionWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionColor,
    required this.onAction,
    this.warningText,
    this.requiresConfirmation = true,
    this.confirmationTitle,
    this.confirmationMessage,
    this.confirmationButtonText,
    this.isDestructive = false,
  });

  @override
  State<AccountActionWidget> createState() => _AccountActionWidgetState();
}

class _AccountActionWidgetState extends State<AccountActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _isPressed = false;

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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.spring,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    // Trigger press animation
    setState(() {
      _isPressed = true;
    });
    
    await _animationController.forward();
    await _animationController.reverse();
    
    if (mounted) {
      setState(() {
        _isPressed = false;
      });
    }

    if (widget.requiresConfirmation) {
      final confirmed = await _showConfirmationDialog();
      if (confirmed && mounted) {
        widget.onAction();
      }
    } else {
      widget.onAction();
    }
  }

  Future<bool> _showConfirmationDialog() async {
    if (widget.isDestructive) {
      return await _showDestructiveConfirmationDialog();
    } else {
      return await _showStandardConfirmationDialog();
    }
  }

  Future<bool> _showStandardConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          widget.confirmationTitle ?? 'Confirm Action',
          style: AppTextStyles.sectionHeader,
        ),
        content: Text(
          widget.confirmationMessage ?? 'Are you sure you want to continue?',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.coolGray,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              widget.confirmationButtonText ?? 'Confirm',
              style: AppTextStyles.buttonText.copyWith(
                color: widget.actionColor,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDestructiveConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DestructiveActionDialog(
        title: widget.confirmationTitle ?? 'Delete Account',
        message: widget.confirmationMessage ??
            'This action cannot be undone. All your data will be permanently deleted.',
        actionText: widget.confirmationButtonText ?? 'Delete Account',
        actionColor: widget.actionColor,
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(
              widget.isDestructive 
                  ? _shakeAnimation.value * 2 * (1 - 2 * (_animationController.value % 1))
                  : 0,
              0,
            ),
            child: _buildActionContainer(),
          ),
        );
      },
    );
  }

  Widget _buildActionContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
      decoration: BoxDecoration(
        color: widget.isDestructive
            ? AppColors.coralRed.withValues(alpha: 0.05)
            : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.actionColor.withValues(alpha: 0.3),
          width: widget.isDestructive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.actionColor.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleAction,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: AppSpacing.allL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.actionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.actionColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.actionColor,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: AppSpacing.spacingM),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.actionColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            widget.description,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: widget.actionColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                
                if (widget.warningText != null) ...[
                  const SizedBox(height: AppSpacing.spacingM),
                  Container(
                    padding: AppSpacing.allS,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.spacingS),
                        Expanded(
                          child: Text(
                            widget.warningText!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Specialized destructive action dialog with enhanced security
class _DestructiveActionDialog extends StatefulWidget {
  final String title;
  final String message;
  final String actionText;
  final Color actionColor;

  const _DestructiveActionDialog({
    required this.title,
    required this.message,
    required this.actionText,
    required this.actionColor,
  });

  @override
  State<_DestructiveActionDialog> createState() => _DestructiveActionDialogState();
}

class _DestructiveActionDialogState extends State<_DestructiveActionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  static const String _confirmationText = 'DELETE';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _confirmationController.addListener(_validateConfirmation);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bounce,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid = _confirmationController.text.trim() == _confirmationText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            title: Container(
              padding: AppSpacing.allL,
              decoration: BoxDecoration(
                color: widget.actionColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: widget.actionColor,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.spacingM),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: widget.actionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Padding(
              padding: AppSpacing.allL,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message,
                    style: AppTextStyles.bodyText,
                  ),
                  
                  const SizedBox(height: AppSpacing.spacingL),
                  
                  Text(
                    'Type "$_confirmationText" to confirm:',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.spacingM),
                  
                  TextField(
                    controller: _confirmationController,
                    decoration: InputDecoration(
                      hintText: 'Type $_confirmationText here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.actionColor, width: 2),
                      ),
                      contentPadding: AppSpacing.allM,
                    ),
                    style: AppTextStyles.bodyText,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                padding: AppSpacing.allL,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.buttonText.copyWith(
                            color: AppColors.coolGray,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppSpacing.spacingM),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isConfirmationValid
                            ? () => Navigator.of(context).pop(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.actionColor,
                          foregroundColor: AppColors.pureWhite,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _isConfirmationValid ? 4 : 0,
                        ),
                        child: Text(
                          widget.actionText,
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pre-built account action widgets for common use cases

/// Delete account action
class DeleteAccountActionWidget extends StatelessWidget {
  final VoidCallback onDeleteAccount;

  const DeleteAccountActionWidget({
    super.key,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return AccountActionWidget(
      title: 'Delete Account',
      description: 'Permanently delete your account and all associated data',
      warningText: 'This action cannot be undone. All your quizzes, scores, and profile data will be lost forever.',
      icon: Icons.delete_forever,
      actionColor: AppColors.coralRed,
      onAction: onDeleteAccount,
      isDestructive: true,
      confirmationTitle: 'Delete Account',
      confirmationMessage: 'Are you absolutely sure you want to delete your account? This will permanently remove all your data, including:\n\n• Your profile and statistics\n• All created quizzes\n• Game history and scores\n• Account settings and preferences\n\nThis action cannot be undone.',
      confirmationButtonText: 'Delete Account',
    );
  }
}

/// Export data action
class ExportDataActionWidget extends StatelessWidget {
  final VoidCallback onExportData;

  const ExportDataActionWidget({
    super.key,
    required this.onExportData,
  });

  @override
  Widget build(BuildContext context) {
    return AccountActionWidget(
      title: 'Export Data',
      description: 'Download a copy of your account data',
      icon: Icons.download,
      actionColor: AppColors.turquoise,
      onAction: onExportData,
      requiresConfirmation: false,
    );
  }
}

/// Deactivate account action
class DeactivateAccountActionWidget extends StatelessWidget {
  final VoidCallback onDeactivateAccount;

  const DeactivateAccountActionWidget({
    super.key,
    required this.onDeactivateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return AccountActionWidget(
      title: 'Deactivate Account',
      description: 'Temporarily disable your account',
      warningText: 'Your account will be hidden from other users until you reactivate it.',
      icon: Icons.pause_circle,
      actionColor: AppColors.warning,
      onAction: onDeactivateAccount,
      confirmationTitle: 'Deactivate Account',
      confirmationMessage: 'Your account will be temporarily disabled. You can reactivate it by signing in again.',
      confirmationButtonText: 'Deactivate',
    );
  }
}

/// Clear data action
class ClearDataActionWidget extends StatelessWidget {
  final VoidCallback onClearData;

  const ClearDataActionWidget({
    super.key,
    required this.onClearData,
  });

  @override
  Widget build(BuildContext context) {
    return AccountActionWidget(
      title: 'Clear Game Data',
      description: 'Reset your game statistics and history',
      warningText: 'This will permanently delete your game history, scores, and statistics.',
      icon: Icons.refresh,
      actionColor: AppColors.warning,
      onAction: onClearData,
      isDestructive: true,
      confirmationTitle: 'Clear Game Data',
      confirmationMessage: 'Are you sure you want to clear all your game data? This includes:\n\n• Game history\n• Scores and statistics\n• Achievements and streaks\n\nYour profile and created quizzes will not be affected.',
      confirmationButtonText: 'Clear Data',
    );
  }
}