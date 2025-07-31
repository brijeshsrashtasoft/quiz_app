import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../buttons/primary_button.dart';

/// Custom error widget for displaying error states
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool isConnected;
  final String? connectionState;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryButtonText,
    this.isConnected = true,
    this.connectionState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: 40,
              color: AppColors.error,
            ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Error Title
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacingM),
          ],

          // Error Message
          Text(
            message,
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),

          // Connection State Info
          if (!isConnected || connectionState != null) ...[
            const SizedBox(height: AppSpacing.spacingM),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    color: isConnected ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                  Text(
                    connectionState ??
                        (isConnected ? 'Connected' : 'Disconnected'),
                    style: AppTextStyles.caption.copyWith(
                      color: isConnected
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Retry Button
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.spacingXL),
            PrimaryButton(
              text: retryButtonText ?? 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh,
              backgroundColor: AppColors.vibrantPurple,
            ),
          ],
        ],
      ),
    );
  }
}
