import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_list_widget.dart';
import '../widgets/notification_filter_bar_widget.dart';

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
      body: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(unreadCountAsync),
          _buildFilterBar(categoriesAsync),
          if (actionsState.error != null)
            _buildErrorBanner(actionsState.error!),
          _buildNotificationContent(),
        ],
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
            ),
          ),
        ),
        error: (error, _) => Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          child: NotificationFilterBarWidget(
            selectedCategory: _selectedCategory,
            showOnlyUnread: _showOnlyUnread,
            availableCategories: const ['invites', 'social', 'achievements', 'results', 'updates'],
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
    return SliverFillRemaining(
      child: NotificationListWidget(
        categoryFilter: _selectedCategory,
        showOnlyUnread: _showOnlyUnread,
        onNotificationTap: _handleNotificationTap,
      ),
    );
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

  void _refreshNotifications() {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadCountProvider);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifications refreshed'),
        backgroundColor: AppColors.vibrantPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
