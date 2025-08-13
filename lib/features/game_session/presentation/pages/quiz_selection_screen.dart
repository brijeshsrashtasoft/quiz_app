import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/loading_indicators.dart';
import '../../../../shared/widgets/cards/quiz_card.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Quiz selection screen for hosting games
/// Allows hosts to select which quiz they want to host from their created quizzes
/// Following Kahoot-style engaging UI design patterns
class QuizSelectionScreen extends ConsumerStatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  ConsumerState<QuizSelectionScreen> createState() =>
      _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends ConsumerState<QuizSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  Quiz? _selectedQuiz;

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

  void _selectQuiz(Quiz quiz) {
    setState(() {
      _selectedQuiz = _selectedQuiz == quiz ? null : quiz;
    });
  }

  void _hostGame() {
    if (_selectedQuiz != null) {
      // Navigate to game setup screen with the selected quiz ID as query parameter
      context.push('${RouteConstants.gameHostSetup}?quizId=${_selectedQuiz!.id}');
    }
  }

  void _navigateToQuizCreation() {
    context.push(RouteConstants.quizCreation);
  }

  /// Helper method to calculate difficulty from quiz
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

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final userQuizzes = ref.watch(userQuizzesProvider);

    return PageLayout(
      title: 'Select Quiz to Host',
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: _buildContent(isAuthenticated, userQuizzes),
      ),
    );
  }

  Widget _buildContent(
    bool isAuthenticated,
    AsyncValue<List<Quiz>> userQuizzes,
  ) {
    // Check authentication first
    if (!isAuthenticated) {
      return _buildUnauthenticatedState();
    }

    // Handle quiz loading states
    return userQuizzes.when(
      loading: () => const LoadingSpinner(message: 'Loading your quizzes...'),
      error: (error, stack) => _buildErrorState(error),
      data: (quizzes) => _buildQuizSelectionContent(quizzes),
    );
  }

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: AppColors.coolGray),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Sign In Required',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Please sign in to view and host your quizzes',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: () => context.go(RouteConstants.login),
            text: 'Sign In',
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Error Loading Quizzes',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Failed to load your quizzes. Please try again.',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: () => ref.refresh(userQuizzesProvider),
            text: 'Retry',
            width: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSelectionContent(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header with instructions
        Container(
          width: double.infinity,
          padding: AppSpacing.allM,
          margin: EdgeInsets.only(bottom: AppSpacing.spacingL),
          decoration: BoxDecoration(
            color: AppColors.vibrantPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.vibrantPurple.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.vibrantPurple,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                  Text(
                    'Select a quiz to host',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.vibrantPurple,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                'Choose from your published quizzes with 3+ questions. Draft quizzes cannot be hosted.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Quiz list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final isSelected = _selectedQuiz?.id == quiz.id;

              return Container(
                margin: EdgeInsets.only(bottom: AppSpacing.spacingM),
                child: QuizCard(
                  title: quiz.title,
                  description: quiz.description,
                  questionCount: quiz.questions.length,
                  difficulty: _getDifficultyFromQuiz(quiz),
                  category: quiz.metadata.category,
                  isSelected: isSelected,
                  onTap: () => _selectQuiz(quiz),
                ),
              );
            },
          ),
        ),

        // Action buttons
        Padding(
          padding: AppSpacing.allM,
          child: Column(
            children: [
              // Host Game button (primary action)
              PrimaryButton(
                onPressed: _selectedQuiz != null ? _hostGame : null,
                text: _selectedQuiz != null
                    ? 'Setup Game for "${_selectedQuiz!.title}"'
                    : 'Select a Quiz First',
                width: double.infinity,
                isDisabled: _selectedQuiz == null,
              ),

              const SizedBox(height: AppSpacing.spacingM),

              // Create New Quiz button (secondary action)
              OutlinedButton(
                onPressed: _navigateToQuizCreation,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(
                    color: AppColors.vibrantPurple,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.vibrantPurple,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spacingS),
                    Text(
                      'Create New Quiz',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.vibrantPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppSpacing.allXL,
            decoration: BoxDecoration(
              color: AppColors.mintGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 60,
              color: AppColors.mintGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'No Quizzes Available',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Padding(
            padding: AppSpacing.horizontalL,
            child: Text(
              'You need at least one published quiz with 3+ questions to host a game. Create your first quiz to get started!',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: _navigateToQuizCreation,
            text: 'Create Your First Quiz',
            width: 250,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Go Back',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
          ),
        ],
      ),
    );
  }
}
