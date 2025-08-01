import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/navigation/app_navigation_bar.dart';
import '../../../../shared/widgets/cards/quiz_card.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../authentication/domain/entities/auth_state.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Main home page with dashboard and navigation
/// Following Kahoot-style engaging UI design
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
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
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Quiz Master',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      backgroundColor: AppColors.offWhite,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: _buildContent(user),
          );
        },
      ),
      bottomNavigationBar: AppNavigationBar(currentRoute: RouteConstants.home),
      floatingActionButton: const AppFloatingActionButton(),
    );
  }

  Widget _buildContent(dynamic user) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Header
          _buildWelcomeHeader(user),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Featured Quizzes
          _buildFeaturedQuizzes(),

          const SizedBox(height: AppSpacing.sectionSpacing),

          // Recent Activity
          _buildRecentActivity(),

          const SizedBox(height: AppSpacing.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(dynamic user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.pureWhite.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingXS),
                    Text(
                      user?.name ?? 'Quiz Master',
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.quiz,
                  size: 30,
                  color: AppColors.pureWhite,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spacingM),

          Text(
            'Ready to challenge minds and have fun with interactive quizzes?',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.pureWhite.withOpacity(0.9),
            ),
          ),

          // Show Sign Up button for unauthenticated users
          if (user == null) ...[
            const SizedBox(height: AppSpacing.spacingL),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go(RouteConstants.register),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pureWhite,
                  foregroundColor: AppColors.vibrantPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, size: 20),
                    const SizedBox(width: AppSpacing.spacingS),
                    Text(
                      'Sign Up',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.vibrantPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: AppSpacing.spacingM),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.spacingM,
          mainAxisSpacing: AppSpacing.spacingM,
          childAspectRatio: 1.2,
          children: [
            _QuickActionCard(
              icon: Icons.add_circle_outline,
              title: 'Create Quiz',
              subtitle: 'Build your quiz',
              color: AppColors.vibrantPurple,
              onTap: () => context.go(RouteConstants.quizCreation),
            ),
            _QuickActionCard(
              icon: Icons.sports_esports_outlined,
              title: 'Join Game',
              subtitle: 'Enter game PIN',
              color: AppColors.mintGreen,
              onTap: () => context.go(RouteConstants.gameJoin),
            ),
            _QuickActionCard(
              icon: Icons.person_outline,
              title: 'Host Game',
              subtitle: 'Start a session',
              color: AppColors.coralRed,
              onTap: () => context.go(RouteConstants.gameHost),
            ),
            _QuickActionCard(
              icon: Icons.leaderboard_outlined,
              title: 'Leaderboard',
              subtitle: 'View rankings',
              color: AppColors.warmYellow,
              onTap: () => context.go(RouteConstants.leaderboard),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedQuizzes() {
    // Mock featured quizzes data
    final featuredQuizzes = [
      {
        'title': 'Science Trivia',
        'description': 'Test your knowledge of basic science concepts',
        'questions': 15,
        'difficulty': 'Medium',
        'category': 'Science',
      },
      {
        'title': 'World Geography',
        'description': 'Explore countries, capitals, and landmarks',
        'questions': 20,
        'difficulty': 'Hard',
        'category': 'Geography',
      },
      {
        'title': 'Pop Culture Quiz',
        'description': 'Movies, music, and trends from the 2020s',
        'questions': 12,
        'difficulty': 'Easy',
        'category': 'Entertainment',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Quizzes',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.charcoal,
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to browse all quizzes
              },
              child: Text(
                'View All',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.vibrantPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.spacingM),

        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = featuredQuizzes[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < featuredQuizzes.length - 1
                      ? AppSpacing.spacingM
                      : 0,
                ),
                child: QuizCard(
                  title: quiz['title'] as String,
                  description: quiz['description'] as String,
                  questionCount: quiz['questions'] as int,
                  difficulty: quiz['difficulty'] as String,
                  category: quiz['category'] as String,
                  onTap: () {
                    // TODO: Navigate to quiz details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    // Mock recent activity data
    final recentActivities = [
      {
        'type': 'created',
        'title': 'History Quiz',
        'time': '2 hours ago',
        'icon': Icons.quiz,
      },
      {
        'type': 'played',
        'title': 'Math Challenge',
        'time': '1 day ago',
        'icon': Icons.sports_esports,
      },
      {
        'type': 'hosted',
        'title': 'Science Trivia',
        'time': '3 days ago',
        'icon': Icons.person,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: AppSpacing.spacingM),

        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: recentActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final isLast = index == recentActivities.length - 1;

              return _RecentActivityItem(
                type: activity['type'] as String,
                title: activity['title'] as String,
                time: activity['time'] as String,
                icon: activity['icon'] as IconData,
                showDivider: !isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            elevation: 4,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),

                    const SizedBox(height: AppSpacing.spacingS),

                    Text(
                      widget.title,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.spacingXS),

                    Text(
                      widget.subtitle,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
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
}

/// Recent activity item widget
class _RecentActivityItem extends StatelessWidget {
  final String type;
  final String title;
  final String time;
  final IconData icon;
  final bool showDivider;

  const _RecentActivityItem({
    required this.type,
    required this.title,
    required this.time,
    required this.icon,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    Color getTypeColor() {
      switch (type) {
        case 'created':
          return AppColors.vibrantPurple;
        case 'played':
          return AppColors.mintGreen;
        case 'hosted':
          return AppColors.coralRed;
        default:
          return AppColors.coolGray;
      }
    }

    String getTypeText() {
      switch (type) {
        case 'created':
          return 'Created';
        case 'played':
          return 'Played';
        case 'hosted':
          return 'Hosted';
        default:
          return 'Activity';
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: getTypeColor(), size: 20),
              ),

              const SizedBox(width: AppSpacing.spacingM),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getTypeText()} $title',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(time, style: AppTextStyles.caption),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.coolGray,
              ),
            ],
          ),
        ),

        if (showDivider)
          const Divider(
            height: 1,
            color: AppColors.lightGray,
            indent: AppSpacing.spacingM,
            endIndent: AppSpacing.spacingM,
          ),
      ],
    );
  }
}
