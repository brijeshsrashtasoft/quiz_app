import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';
import 'notification_card_widget.dart';

/// Notification list widget with filtering and grouping capabilities
class NotificationListWidget extends ConsumerWidget {
  final String? categoryFilter;
  final bool showOnlyUnread;
  final Function(NotificationEntity)? onNotificationTap;

  const NotificationListWidget({
    super.key,
    this.categoryFilter,
    this.showOnlyUnread = false,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (result) => result.when(
        success: (notifications) => _buildNotificationList(notifications, ref),
        failure: (failure) => _buildErrorState(failure.userMessage),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
          ),
          SizedBox(height: AppSpacing.md),
          Text('Loading notifications...', style: AppTextStyles.bodyText),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.coralRed),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.coralRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh notifications
                // ref.refresh(notificationsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationEntity> notifications,
    WidgetRef ref,
  ) {
    // Apply filters
    var filteredNotifications = notifications;

    if (categoryFilter != null) {
      filteredNotifications = filteredNotifications
          .where((n) => n.category == categoryFilter)
          .toList();
    }

    if (showOnlyUnread) {
      filteredNotifications = filteredNotifications
          .where((n) => !n.isRead)
          .toList();
    }

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    // Group notifications by category for better organization
    final groupedNotifications = _groupNotificationsByCategory(
      filteredNotifications,
    );

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh notifications
        ref.invalidate(notificationsProvider);
      },
      color: AppColors.vibrantPurple,
      child: CustomScrollView(
        slivers: [
          if (categoryFilter == null) ...[
            // Show grouped notifications
            ...groupedNotifications.entries.map((entry) {
              return _buildNotificationGroup(entry.key, entry.value, ref);
            }),
          ] else ...[
            // Show flat list for specific category
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final notification = filteredNotifications[index];
                return NotificationCardWidget(
                  notification: notification,
                  onTap: () => onNotificationTap?.call(notification),
                );
              }, childCount: filteredNotifications.length),
            ),
          ],

          // Add some bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String message;
    IconData icon;

    if (showOnlyUnread) {
      title = 'All caught up!';
      message = 'You have no unread notifications.';
      icon = Icons.check_circle_outline;
    } else if (categoryFilter != null) {
      title = 'No ${_getCategoryDisplayName(categoryFilter!)} yet';
      message = 'We\'ll notify you when something happens in this category.';
      icon = Icons.inbox;
    } else {
      title = 'No notifications yet';
      message = 'When you get notifications, they\'ll appear here.';
      icon = Icons.notifications_none;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 96, color: AppColors.coolGray),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationGroup(
    String category,
    List<NotificationEntity> notifications,
    WidgetRef ref,
  ) {
    final categoryDisplayName = _getCategoryDisplayName(category);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return SliverMainAxisGroup(
      slivers: [
        // Category header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGray, width: 1),
            ),
            child: Row(
              children: [
                Text(
                  categoryDisplayName,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Notifications in this category
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final notification = notifications[index];
            return NotificationCardWidget(
              notification: notification,
              onTap: () => onNotificationTap?.call(notification),
            );
          }, childCount: notifications.length),
        ),
      ],
    );
  }

  Map<String, List<NotificationEntity>> _groupNotificationsByCategory(
    List<NotificationEntity> notifications,
  ) {
    final grouped = <String, List<NotificationEntity>>{};

    for (final notification in notifications) {
      final category = notification.category;
      grouped.putIfAbsent(category, () => []).add(notification);
    }

    // Sort categories by priority and unread count
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        // First, prioritize categories with unread notifications
        final aUnreadCount = a.value.where((n) => !n.isRead).length;
        final bUnreadCount = b.value.where((n) => !n.isRead).length;

        if (aUnreadCount > 0 && bUnreadCount == 0) return -1;
        if (bUnreadCount > 0 && aUnreadCount == 0) return 1;

        // Then sort by category priority
        final categoryPriority = {
          'invites': 1,
          'achievements': 2,
          'results': 3,
          'social': 4,
          'updates': 5,
        };

        final aPriority = categoryPriority[a.key] ?? 10;
        final bPriority = categoryPriority[b.key] ?? 10;

        return aPriority.compareTo(bPriority);
      });

    return Map.fromEntries(sortedEntries);
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'invites':
        return 'Invitations';
      case 'social':
        return 'Social';
      case 'achievements':
        return 'Achievements';
      case 'results':
        return 'Game Results';
      case 'updates':
        return 'System Updates';
      default:
        return category.toUpperCase();
    }
  }
}
