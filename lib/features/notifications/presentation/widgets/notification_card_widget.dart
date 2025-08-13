import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';

/// Beautiful notification card widget following Kahoot-style design
class NotificationCardWidget extends ConsumerWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final bool showActions;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsState = ref.watch(notificationActionsProvider);
    final isProcessing = actionsState.processingIds.contains(notification.id);

    return Card(
      elevation: notification.isRead ? 2 : 6,
      shadowColor: AppColors.shadowLight,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: notification.isRead
            ? BorderSide.none
            : const BorderSide(color: AppColors.vibrantPurple, width: 2),
      ),
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: notification.isRead
                ? null
                : LinearGradient(
                    colors: [
                      AppColors.vibrantPurple.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xs),
                    _buildMessage(),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMetadata(),
                    if (showActions) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildActions(ref, isProcessing),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getNotificationColor();
    final iconName = notification.iconName;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: notification.imageUrl != null
          ? ClipOval(
              child: Image.network(
                notification.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultIcon(iconName, Colors.white);
                },
              ),
            )
          : _buildDefaultIcon(iconName, Colors.white),
    );
  }

  Widget _buildDefaultIcon(String iconName, Color color) {
    IconData iconData;

    switch (iconName) {
      case 'quiz':
        iconData = Icons.quiz;
        break;
      case 'videogame_asset':
        iconData = Icons.videogame_asset;
        break;
      case 'person_add':
        iconData = Icons.person_add;
        break;
      case 'emoji_events':
        iconData = Icons.emoji_events;
        break;
      case 'leaderboard':
        iconData = Icons.leaderboard;
        break;
      case 'favorite':
        iconData = Icons.favorite;
        break;
      case 'trending_up':
        iconData = Icons.trending_up;
        break;
      case 'priority_high':
        iconData = Icons.priority_high;
        break;
      case 'info':
        iconData = Icons.info;
        break;
      case 'announcement':
        iconData = Icons.announcement;
        break;
      case 'message':
        iconData = Icons.message;
        break;
      default:
        iconData = Icons.notifications;
    }

    return Icon(iconData, color: color, size: 24);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: notification.isRead
                  ? FontWeight.w500
                  : FontWeight.w600,
              color: notification.isRead
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!notification.isRead) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.vibrantPurple,
              shape: BoxShape.circle,
            ),
          ),
        ],
        if (notification.isTimeSensitive) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.coralRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'URGENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      notification.message,
      style: AppTextStyles.bodyMedium.copyWith(
        color: notification.isRead
            ? AppColors.textTertiary
            : AppColors.textSecondary,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    final timeAgo = _getTimeAgo(notification.timestamp);
    final category = _getCategoryDisplayName(notification.category);

    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          timeAgo,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _getNotificationColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category,
            style: AppTextStyles.caption.copyWith(
              color: _getNotificationColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(WidgetRef ref, bool isProcessing) {
    if (isProcessing) {
      return const SizedBox(
        height: 20,
        child: LinearProgressIndicator(
          backgroundColor: AppColors.lightGray,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
        ),
      );
    }

    return Row(
      children: [
        if (!notification.isRead)
          TextButton.icon(
            onPressed: () {
              ref
                  .read(notificationActionsProvider.notifier)
                  .markAsRead(notification.id);
            },
            icon: const Icon(Icons.mark_email_read, size: 16),
            label: const Text('Mark Read'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.vibrantPurple,
              textStyle: AppTextStyles.caption,
            ),
          ),
        const Spacer(),
        IconButton(
          onPressed: () {
            ref
                .read(notificationActionsProvider.notifier)
                .deleteNotification(notification.id);
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          color: AppColors.textTertiary,
          tooltip: 'Delete notification',
        ),
      ],
    );
  }

  Color _getNotificationColor() {
    return notification.type.when(
      quizInvite: (quizId, fromUserId, fromUserName) => AppColors.vibrantPurple,
      gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) =>
          AppColors.coralRed,
      achievementUnlocked:
          (
            achievementId,
            achievementName,
            achievementDescription,
            pointsEarned,
          ) => AppColors.warmYellow,
      gameResult:
          (
            gameSessionId,
            finalScore,
            totalQuestions,
            correctAnswers,
            leaderboardPosition,
          ) => AppColors.turquoise,
      friendRequest: (fromUserId, fromUserName, fromUserAvatar) =>
          AppColors.mintGreen,
      quizLiked: (quizId, quizTitle, fromUserId, fromUserName) =>
          AppColors.warmYellow,
      leaderboardUpdate:
          (gameSessionId, oldPosition, newPosition, isImprovement) =>
              AppColors.turquoise,
      systemMessage: (category, priority) => switch (priority) {
        SystemMessagePriority.urgent => AppColors.coralRed,
        SystemMessagePriority.high => AppColors.warmYellow,
        SystemMessagePriority.medium => AppColors.vibrantPurple,
        SystemMessagePriority.low => AppColors.coolGray,
      },
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'invites':
        return 'Invites';
      case 'social':
        return 'Social';
      case 'achievements':
        return 'Achievements';
      case 'results':
        return 'Results';
      case 'updates':
        return 'Updates';
      default:
        return category.toUpperCase();
    }
  }
}
