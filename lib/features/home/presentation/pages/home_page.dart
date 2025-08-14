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
import '../../../game_session/presentation/providers/session_providers.dart';
import '../../../game_session/domain/entities/game_session_entity.dart';

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

          // My Quizzes Section (only for authenticated users)
          if (user != null) ...[
            _buildMyQuizzes(),
            const SizedBox(height: AppSpacing.sectionSpacing),
          ],

          // Game Statistics (for authenticated users)
          if (user != null) ...[
            _buildGameStatistics(),
            const SizedBox(height: AppSpacing.sectionSpacing),
          ],

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
                        color: AppColors.pureWhite.withValues(alpha: 0.8),
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
                  color: AppColors.pureWhite.withValues(alpha: 0.2),
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
              color: AppColors.pureWhite.withValues(alpha: 0.9),
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
                // Show enhanced PIN input dialog
                _showEnhancedJoinGameDialog(context);
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
              onTap: () => context.push(RouteConstants.quizManagement),
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
              color: AppColors.lightGray.withValues(alpha: 0.3),
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
        color: AppColors.coralRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.coralRed.withValues(alpha: 0.3),
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

  /// Show enhanced join game dialog with improved PIN input
  void _showEnhancedJoinGameDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.spacingL),
          title: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_esports,
                  color: AppColors.pureWhite,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                'Join Live Game',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.charcoal,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the 6-digit game PIN to join an active quiz session',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingL),

              // Enhanced PIN input field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lightGray.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: pinController,
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: 'XXXXXX',
                    hintStyle: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.coolGray.withValues(alpha: 0.5),
                      fontSize: 28,
                      letterSpacing: 8,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacingL,
                      vertical: AppSpacing.spacingL,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionHeader.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: AppColors.vibrantPurple,
                  ),
                  maxLength: 6,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  onChanged: (value) {
                    // Auto-format PIN input
                    if (value.length == 6 &&
                        RegExp(r'^\d{6}$').hasMatch(value)) {
                      // Automatically attempt to join when 6 digits are entered
                      _handleJoinGame(context, pinController, setState);
                    }
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.spacingM),

              // PIN format hint
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.mintGreen,
                    ),
                    const SizedBox(width: AppSpacing.spacingS),
                    Expanded(
                      child: Text(
                        'PIN is a 6-digit number shown on the host\'s screen',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mintGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
            ),

            // Join button
            ElevatedButton(
              onPressed: () =>
                  _handleJoinGame(context, pinController, setState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintGreen,
                foregroundColor: AppColors.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingL,
                  vertical: AppSpacing.spacingM,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, size: 18),
                  const SizedBox(width: AppSpacing.spacingS),
                  Text(
                    'Join Game',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJoinGame(
    BuildContext context,
    TextEditingController pinController,
    StateSetter setState,
  ) async {
    final pin = pinController.text.trim();

    if (pin.isEmpty) {
      return;
    }

    setState(() {
      // Update loading state within the dialog
    });

    Navigator.of(context).pop();

    if (pin.length == 6 && RegExp(r'^\d+$').hasMatch(pin)) {
      context.push('${RouteConstants.gameJoin}?pin=$pin');
    } else {
      // Navigate to game join page for PIN validation
      context.push(RouteConstants.gameJoin);
    }
  }

  Widget _buildRecentActivity() {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return _buildGuestActivitySection();
    }

    final userHostedSessions = ref.watch(userHostedSessionsProvider);

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

        userHostedSessions.when(
          loading: () => _buildActivityLoadingSkeleton(),
          error: (error, stack) => _buildActivityErrorWidget(error),
          data: (sessions) {
            if (sessions.isEmpty) {
              return _buildEmptyActivityState();
            }

            // Take the 3 most recent sessions for activity display
            final recentSessions = sessions.take(3).toList();

            return Container(
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
                children: recentSessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;
                  final isLast = index == recentSessions.length - 1;

                  return _RecentActivityItem(
                    type: _getActivityType(session),
                    title: 'Game Session ${session.pin}',
                    time: _getTimeAgo(session.createdAt),
                    icon: _getActivityIcon(session),
                    showDivider: !isLast,
                    onTap: () {
                      // Navigate to session details or results
                      if (session.status == GameSessionStatus.completed) {
                        context.push(
                          RouteConstants.gameResultsPath(session.id),
                        );
                      } else {
                        context.push(
                          RouteConstants.gameSessionPath(session.id),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMyQuizzes() {
    final userQuizzes = ref.watch(userQuizzesProvider);
    final userDraftQuizzes = ref.watch(userDraftQuizzesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Quizzes',
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
                'Manage All',
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
          child: userQuizzes.when(
            loading: () => _buildLoadingSkeleton(),
            error: (error, stack) => _buildErrorWidget(error),
            data: (publishedQuizzes) {
              return userDraftQuizzes.when(
                loading: () => _buildLoadingSkeleton(),
                error: (error, stack) => _buildErrorWidget(error),
                data: (draftQuizzes) {
                  final allUserQuizzes = [...publishedQuizzes, ...draftQuizzes];

                  if (allUserQuizzes.isEmpty) {
                    return _buildMyQuizzesEmptyState();
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allUserQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = allUserQuizzes[index];
                      return Container(
                        width: 280,
                        margin: EdgeInsets.only(
                          right: index < allUserQuizzes.length - 1
                              ? AppSpacing.spacingM
                              : 0,
                        ),
                        child: _MyQuizCard(
                          quiz: quiz,
                          onTap: () {
                            if (quiz.isDraft) {
                              // Navigate to edit draft
                              context.push(
                                RouteConstants.quizEditPath(quiz.id),
                              );
                            } else {
                              // Navigate to quiz details
                              context.push(
                                RouteConstants.quizDetailsPath(quiz.id),
                              );
                            }
                          },
                          onHost: quiz.isDraft
                              ? null
                              : () {
                                  // Navigate to host game screen with this quiz
                                  context.push(
                                    '${RouteConstants.gameHost}?quizId=${quiz.id}',
                                  );
                                },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Statistics',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Row(
          children: [
            // Games Hosted
            Expanded(
              child: _StatisticCard(
                icon: Icons.sports_esports,
                color: AppColors.vibrantPurple,
                value: '12',
                label: 'Games Hosted',
                onTap: () => context.push(RouteConstants.leaderboard),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingM),

            // Quizzes Created
            Expanded(
              child: _StatisticCard(
                icon: Icons.quiz,
                color: AppColors.mintGreen,
                value: '8',
                label: 'Quizzes Created',
                onTap: () => context.push(RouteConstants.quizManagement),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Row(
          children: [
            // Total Players
            Expanded(
              child: _StatisticCard(
                icon: Icons.people,
                color: AppColors.coralRed,
                value: '245',
                label: 'Total Players',
                onTap: () => context.push(RouteConstants.leaderboard),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingM),

            // Best Score
            Expanded(
              child: _StatisticCard(
                icon: Icons.star,
                color: AppColors.warmYellow,
                value: '98%',
                label: 'Best Score',
                onTap: () => context.push(RouteConstants.profile),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestActivitySection() {
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
          padding: const EdgeInsets.all(AppSpacing.spacingL),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 48, color: AppColors.coolGray),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                'Sign in to see your activity',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                'Track your quiz creations, game sessions, and performance',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLoadingSkeleton() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Loading activity...',
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityErrorWidget(Object error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.coralRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.coralRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.coralRed),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Failed to load activity',
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

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 48, color: AppColors.coolGray),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'No recent activity',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'Start hosting quiz games to see your activity here',
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMyQuizzesEmptyState() {
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
            'No quizzes created yet',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.coolGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'Create your first quiz to get started!',
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          ElevatedButton(
            onPressed: () => context.push(RouteConstants.quizCreation),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantPurple,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Quiz',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityType(GameSessionEntity session) {
    switch (session.status) {
      case GameSessionStatus.completed:
        return 'completed';
      case GameSessionStatus.active:
        return 'hosted';
      case GameSessionStatus.waiting:
        return 'created';
    }
  }

  IconData _getActivityIcon(GameSessionEntity session) {
    switch (session.status) {
      case GameSessionStatus.completed:
        return Icons.check_circle;
      case GameSessionStatus.active:
        return Icons.play_circle;
      case GameSessionStatus.waiting:
        return Icons.group_add;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
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
                        color: widget.color.withValues(alpha: 0.1),
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
  final VoidCallback? onTap;

  const _RecentActivityItem({
    required this.type,
    required this.title,
    required this.time,
    required this.icon,
    required this.showDivider,
    this.onTap,
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
          return 'Created session';
        case 'hosted':
          return 'Hosted game';
        case 'completed':
          return 'Completed game';
        default:
          return 'Activity';
      }
    }

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: getTypeColor().withValues(alpha: 0.1),
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

                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.coolGray,
                    ),
                ],
              ),
            ),
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

/// My Quiz card widget for user's created quizzes
class _MyQuizCard extends StatefulWidget {
  final Quiz quiz;
  final VoidCallback onTap;
  final VoidCallback? onHost;

  const _MyQuizCard({required this.quiz, required this.onTap, this.onHost});

  @override
  State<_MyQuizCard> createState() => _MyQuizCardState();
}

class _MyQuizCardState extends State<_MyQuizCard>
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
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
              border: widget.quiz.isDraft
                  ? Border.all(
                      color: AppColors.warmYellow.withValues(alpha: 0.5),
                      width: 2,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with status badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.quiz.title,
                              style: AppTextStyles.bodyText.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.quiz.isDraft)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacingS,
                                vertical: AppSpacing.spacingXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warmYellow.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.warmYellow,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'DRAFT',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warmYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.spacingS),

                      // Description
                      Text(
                        widget.quiz.description,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.coolGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Quiz stats
                      Row(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 16,
                            color: AppColors.coolGray,
                          ),
                          const SizedBox(width: AppSpacing.spacingXS),
                          Text(
                            '${widget.quiz.questions.length} questions',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.coolGray,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingM),
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: AppColors.coolGray,
                          ),
                          const SizedBox(width: AppSpacing.spacingXS),
                          Expanded(
                            child: Text(
                              widget.quiz.metadata.category,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.coolGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.spacingM),

                      // Action buttons
                      if (!widget.quiz.isDraft && widget.onHost != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onHost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mintGreen,
                              foregroundColor: AppColors.pureWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.spacingS,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow, size: 18),
                                const SizedBox(width: AppSpacing.spacingXS),
                                Text(
                                  'Host Game',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.pureWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: widget.onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.vibrantPurple,
                              side: BorderSide(
                                color: widget.quiz.isDraft
                                    ? AppColors.warmYellow
                                    : AppColors.vibrantPurple,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.spacingS,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.quiz.isDraft
                                      ? Icons.edit
                                      : Icons.visibility,
                                  size: 18,
                                  color: widget.quiz.isDraft
                                      ? AppColors.warmYellow
                                      : AppColors.vibrantPurple,
                                ),
                                const SizedBox(width: AppSpacing.spacingXS),
                                Text(
                                  widget.quiz.isDraft ? 'Continue' : 'View',
                                  style: AppTextStyles.caption.copyWith(
                                    color: widget.quiz.isDraft
                                        ? AppColors.warmYellow
                                        : AppColors.vibrantPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Statistic card widget for game statistics display
class _StatisticCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatisticCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  State<_StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<_StatisticCard>
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
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.spacingS),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with background
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 24),
                      ),

                      const SizedBox(height: AppSpacing.spacingM),

                      // Value
                      Text(
                        widget.value,
                        style: AppTextStyles.sectionHeader.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.spacingXS),

                      // Label
                      Text(
                        widget.label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.coolGray,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
