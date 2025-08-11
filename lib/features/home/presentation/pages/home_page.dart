import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/navigation/app_navigation_bar.dart';
import '../../../../shared/widgets/cards/quiz_card.dart';
import '../../../../shared/widgets/buttons/google_signin_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../authentication/domain/entities/auth_state.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';

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
        showBackButton: false, // Home screen shouldn't have back button
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push(RouteConstants.quizManagement);
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

          // Show authentication options for unauthenticated users
          if (user == null) ...[
            const SizedBox(height: AppSpacing.spacingL),

            // Google Sign-In Button
            GoogleSignInButton(
              label: 'Sign in with Google',
              onSuccess: () {
                // Google Sign-In handles navigation automatically
              },
            ),

            const SizedBox(height: AppSpacing.spacingM),

            // OR Divider
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.lightGray)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacingM,
                  ),
                  child: Text(
                    'OR',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.lightGray)),
              ],
            ),

            const SizedBox(height: AppSpacing.spacingM),

            // Email Authentication Buttons
            Row(
              children: [
                // Login Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.go(RouteConstants.login),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.pureWhite,
                        side: const BorderSide(
                          color: AppColors.pureWhite,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.login, size: 20),
                          const SizedBox(width: AppSpacing.spacingS),
                          Text(
                            'Login',
                            style: AppTextStyles.buttonText.copyWith(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.spacingM),

                // Sign Up Button
                Expanded(
                  child: SizedBox(
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
                ),
              ],
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
              onTap: () => context.push(RouteConstants.quizCreation),
            ),
            _QuickActionCard(
              icon: Icons.sports_esports_outlined,
              title: 'Join Game',
              subtitle: 'Enter game PIN',
              color: AppColors.mintGreen,
              onTap: () {
                // Show a PIN input dialog for now
                _showJoinGameDialog(context);
              },
            ),
            _QuickActionCard(
              icon: Icons.person_outline,
              title: 'Host Game',
              subtitle: 'Start a session',
              color: AppColors.coralRed,
              onTap: () {
                // Navigate to quiz selection page first
                context.push(RouteConstants.quizSelection);
              },
            ),
            _QuickActionCard(
              icon: Icons.leaderboard_outlined,
              title: 'Browse Quizzes',
              subtitle: 'Explore quizzes',
              color: AppColors.warmYellow,
              onTap: () => context.push('/quiz-management'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedQuizzes() {
    final popularQuizzes = ref.watch(popularQuizzesProvider);

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
                context.push(RouteConstants.quizManagement);
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
          child: popularQuizzes.when(
            loading: () => _buildLoadingSkeleton(),
            error: (error, stack) => _buildErrorWidget(error),
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < quizzes.length - 1
                          ? AppSpacing.spacingM
                          : 0,
                    ),
                    child: QuizCard(
                      title: quiz.title,
                      description: quiz.description,
                      questionCount: quiz.questions.length,
                      difficulty: _getDifficultyFromQuiz(quiz),
                      category: quiz.metadata.category,
                      onTap: () {
                        context.push(RouteConstants.quizDetailsPath(quiz.id));
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Helper method to calculate difficulty from quiz questions
  String _getDifficultyFromQuiz(Quiz quiz) {
    if (quiz.questions.isEmpty) return 'Easy';

    // Calculate average time limit
    final avgTimeLimit =
        quiz.questions.fold(0, (sum, q) => sum + q.questionTimeLimit) /
        quiz.questions.length;

    if (avgTimeLimit <= 10) return 'Hard'; // Quick questions = harder
    if (avgTimeLimit <= 20) return 'Medium';
    return 'Easy'; // More time = easier
  }

  /// Loading skeleton for quiz cards
  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 280,
          margin: EdgeInsets.only(right: index < 2 ? AppSpacing.spacingM : 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.vibrantPurple,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                Text(
                  'Loading quizzes...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.coolGray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Error widget for failed quiz loading
  Widget _buildErrorWidget(Object error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.coralRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.coralRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.coralRed),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Failed to load quizzes',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coralRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'Please check your connection and try again',
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Empty state when no quizzes are available
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 48, color: AppColors.coolGray),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'No quizzes available',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'Be the first to create a quiz!',
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
          ),
        ],
      ),
    );
  }

  /// Show join game dialog with PIN input
  void _showJoinGameDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Join Game',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the game PIN to join a live quiz session',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            TextField(
              controller: pinController,
              decoration: InputDecoration(
                hintText: 'Enter PIN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.vibrantPurple),
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionHeader,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text.trim();
              Navigator.of(context).pop();

              if (pin.isNotEmpty) {
                // Navigate to game join page with PIN
                if (pin.length == 6 && RegExp(r'^\d+$').hasMatch(pin)) {
                  context.push('${RouteConstants.gameJoin}?pin=$pin');
                } else {
                  // Navigate to game join page without PIN for validation
                  context.push(RouteConstants.gameJoin);
                }
              } else {
                // Navigate to game join page for PIN entry
                context.push(RouteConstants.gameJoin);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Join',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
          ),
        ],
      ),
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
