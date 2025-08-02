import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_filter_bar_widget.dart';
import '../widgets/notification_card_widget.dart';

/// Main notifications page with beautiful Kahoot-style design
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with TickerProviderStateMixin {
  String? _selectedCategory;
  bool _showOnlyUnread = false;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadCountProvider);
    final categoriesAsync = ref.watch(notificationCategoriesProvider);
    final actionsState = ref.watch(notificationActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: AppColors.vibrantPurple,
        child: CustomScrollView(
          slivers: [
            _buildAnimatedAppBar(unreadCountAsync),
            _buildFilterBar(categoriesAsync),
            if (actionsState.error != null)
              _buildErrorBanner(actionsState.error!),
            _buildNotificationContent(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAnimatedAppBar(AsyncValue<dynamic> unreadCountAsync) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.vibrantPurple,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new),
        tooltip: 'Back',
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.vibrantPurple, Color(0xFF9B59B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: Opacity(
                    opacity: _headerFadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notifications',
                                      style: AppTextStyles.gameTitle.copyWith(
                                        color: Colors.white,
                                        fontSize: 28,
                                      ),
                                    ),
                                    unreadCountAsync.when(
                                      loading: () => const SizedBox(height: 20),
                                      error: (_, __) =>
                                          const SizedBox(height: 20),
                                      data: (result) => result.when(
                                        success: (count) => Text(
                                          count > 0
                                              ? '$count unread notification${count == 1 ? '' : 's'}'
                                              : 'All caught up!',
                                          style: AppTextStyles.bodyText
                                              .copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 14,
                                              ),
                                        ),
                                        failure: (_) => Text(
                                          'Stay updated with your activities',
                                          style: AppTextStyles.bodyText
                                              .copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 14,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  Icon(Icons.mark_email_read, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.sm),
                  Text('Mark All Read'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete_all',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, color: AppColors.coralRed),
                  SizedBox(width: AppSpacing.sm),
                  Text('Delete All'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar(AsyncValue<List<String>> categoriesAsync) {
    return SliverToBoxAdapter(
      child: categoriesAsync.when(
        loading: () => Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          height: 60,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.vibrantPurple,
              ),
            ),
          ),
        ),
        error: (error, _) => Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          child: NotificationFilterBarWidget(
            selectedCategory: _selectedCategory,
            showOnlyUnread: _showOnlyUnread,
            availableCategories: const [
              'invites',
              'social',
              'achievements',
              'results',
              'updates',
            ],
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            onUnreadFilterChanged: (showOnlyUnread) {
              setState(() {
                _showOnlyUnread = showOnlyUnread;
              });
            },
          ),
        ),
        data: (categories) => NotificationFilterBarWidget(
          selectedCategory: _selectedCategory,
          showOnlyUnread: _showOnlyUnread,
          availableCategories: categories,
          onCategoryChanged: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
          onUnreadFilterChanged: (showOnlyUnread) {
            setState(() {
              _showOnlyUnread = showOnlyUnread;
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.coralRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.coralRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.coralRed, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                error,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coralRed,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(notificationActionsProvider.notifier).clearError();
              },
              icon: const Icon(Icons.close),
              iconSize: 18,
              color: AppColors.coralRed,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationContent() {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.vibrantPurple,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text('Loading notifications...', style: AppTextStyles.bodyText),
            ],
          ),
        ),
      ),
      error: (error, _) => SliverFillRemaining(
        child: Center(
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
                  error.toString(),
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(notificationsProvider);
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
        ),
      ),
      data: (result) => result.when(
        success: (notifications) => _buildNotificationSlivers(notifications),
        failure: (failure) => SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.coralRed,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Failed to load notifications',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.coralRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Please try again later',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSlivers(List<NotificationEntity> notifications) {
    // Apply filters
    var filteredNotifications = notifications;

    if (_selectedCategory != null) {
      filteredNotifications = filteredNotifications
          .where((n) => n.category == _selectedCategory)
          .toList();
    }

    if (_showOnlyUnread) {
      filteredNotifications = filteredNotifications
          .where((n) => !n.isRead)
          .toList();
    }

    if (filteredNotifications.isEmpty) {
      return _buildEmptySliver();
    }

    // Group notifications by category for better organization
    final groupedNotifications = _groupNotificationsByCategory(
      filteredNotifications,
    );

    return SliverMainAxisGroup(
      slivers: [
        if (_selectedCategory == null) ...[
          // Show grouped notifications
          ...groupedNotifications.entries.map((entry) {
            return _buildNotificationGroup(entry.key, entry.value);
          }).toList(),
        ] else ...[
          // Show flat list for specific category
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final notification = filteredNotifications[index];
              return NotificationCardWidget(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
              );
            }, childCount: filteredNotifications.length),
          ),
        ],

        // Add some bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
      ],
    );
  }

  Widget _buildEmptySliver() {
    String title;
    String message;
    IconData icon;

    if (_showOnlyUnread) {
      title = 'All caught up!';
      message = 'You have no unread notifications.';
      icon = Icons.check_circle_outline;
    } else if (_selectedCategory != null) {
      title = 'No ${_getCategoryDisplayName(_selectedCategory!)} yet';
      message = 'We\'ll notify you when something happens in this category.';
      icon = Icons.inbox;
    } else {
      title = 'No notifications yet';
      message = 'When you get notifications, they\'ll appear here.';
      icon = Icons.notifications_none;
    }

    return SliverFillRemaining(
      child: Center(
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
      ),
    );
  }

  Widget _buildNotificationGroup(
    String category,
    List<NotificationEntity> notifications,
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
              onTap: () => _handleNotificationTap(notification),
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _refreshNotifications,
      backgroundColor: AppColors.vibrantPurple,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _handleMenuAction(String action) {
    final notifier = ref.read(notificationActionsProvider.notifier);

    switch (action) {
      case 'mark_all_read':
        _showConfirmationDialog(
          title: 'Mark All as Read',
          message: 'Are you sure you want to mark all notifications as read?',
          confirmText: 'Mark All Read',
          onConfirm: () => notifier.markAllAsRead(),
        );
        break;
      case 'delete_all':
        _showConfirmationDialog(
          title: 'Delete All Notifications',
          message:
              'Are you sure you want to delete all notifications? This action cannot be undone.',
          confirmText: 'Delete All',
          isDestructive: true,
          onConfirm: () => notifier.deleteAllNotifications(),
        );
        break;
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
        ),
        content: Text(message, style: AppTextStyles.bodyText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? AppColors.coralRed
                  : AppColors.vibrantPurple,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      ref
          .read(notificationActionsProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type and action URL
    if (notification.actionUrl != null) {
      context.push(notification.actionUrl!);
    } else {
      // Handle navigation based on notification type
      notification.type.when(
        quizInvite: (quizId, fromUserId, fromUserName) {
          context.push('/quiz/$quizId');
        },
        gameInvite: (gameSessionId, gamePin, fromUserId, fromUserName) {
          context.push('/game/join?pin=$gamePin');
        },
        achievementUnlocked:
            (
              achievementId,
              achievementName,
              achievementDescription,
              pointsEarned,
            ) {
              // Navigate to achievements/profile page
              context.push(RouteConstants.profile);
            },
        gameResult:
            (
              gameSessionId,
              finalScore,
              totalQuestions,
              correctAnswers,
              leaderboardPosition,
            ) {
              context.push('/leaderboard/session/$gameSessionId');
            },
        friendRequest: (fromUserId, fromUserName, fromUserAvatar) {
          context.push(RouteConstants.profile);
        },
        quizLiked: (quizId, quizTitle, fromUserId, fromUserName) {
          context.push('/quiz/$quizId');
        },
        leaderboardUpdate:
            (gameSessionId, oldPosition, newPosition, isImprovement) {
              context.push('/leaderboard/session/$gameSessionId');
            },
        systemMessage: (category, priority) {
          // Stay on notifications page for system messages
        },
      );
    }
  }

  Future<void> _refreshNotifications() async {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadCountProvider);

    // Wait a bit for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifications refreshed'),
          backgroundColor: AppColors.vibrantPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
