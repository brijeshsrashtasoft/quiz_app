import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/answer_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/quiz_providers.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question_entities.dart';

/// Quiz preview page to see how the quiz will look with real Firebase data
class QuizPreviewPage extends ConsumerStatefulWidget {
  const QuizPreviewPage({super.key});

  @override
  ConsumerState<QuizPreviewPage> createState() => _QuizPreviewPageState();
}

class _QuizPreviewPageState extends ConsumerState<QuizPreviewPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.newQuestionDuration,
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextQuestion(List<Question> questions) {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showCorrectAnswer = false;
      });
      _slideController.forward(from: 0);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = null;
        _showCorrectAnswer = false;
      });
      _slideController.forward(from: 0);
    }
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _showCorrectAnswer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    // Get quiz ID from route parameters
    final routerState = GoRouterState.of(context);
    final quizId = routerState.uri.queryParameters['id'];

    // If no quiz ID, show error state
    if (quizId == null || quizId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.pureWhite,
          elevation: 0,
          title: Text('Quiz Preview', style: AppTextStyles.sectionHeader),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.coolGray),
              const SizedBox(height: AppSpacing.spacingL),
              Text('No quiz ID provided', style: AppTextStyles.sectionHeader),
              const SizedBox(height: AppSpacing.spacingM),
              PrimaryButton(
                onPressed: () => context.go(RouteConstants.quizCreation),
                text: 'Back to Quiz Creation',
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      );
    }

    // Watch the quiz data from Firebase
    final quizAsyncValue = ref.watch(quizByIdProvider(quizId));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('Preview Quiz', style: AppTextStyles.sectionHeader),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go('${RouteConstants.quizCreation}/form?id=$quizId');
            },
            icon: const Icon(Icons.edit, color: AppColors.vibrantPurple),
            label: Text(
              'Edit',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.vibrantPurple,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spacingM),
        ],
      ),
      body: quizAsyncValue.when(
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error),
        data: (quiz) {
          if (quiz == null) {
            return _buildNotFoundState();
          }
          return _buildQuizPreview(quiz, isTablet, isDesktop);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
          ),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Loading quiz preview...',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
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
          Icon(Icons.error_outline, size: 64, color: AppColors.timeWarning),
          const SizedBox(height: AppSpacing.spacingL),
          Text('Failed to load quiz', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Please check your connection and try again.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          PrimaryButton(
            onPressed: () {
              // Refresh the provider
              ref.invalidate(quizByIdProvider);
            },
            text: 'Retry',
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: AppColors.coolGray),
          const SizedBox(height: AppSpacing.spacingL),
          Text('Quiz not found', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'The quiz you\'re looking for doesn\'t exist or has been deleted.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          PrimaryButton(
            onPressed: () => context.go(RouteConstants.quizCreation),
            text: 'Back to Quiz Creation',
            icon: Icons.arrow_back,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizPreview(Quiz quiz, bool isTablet, bool isDesktop) {
    final questions = quiz.questions;

    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: AppColors.coolGray),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'No questions in this quiz',
              style: AppTextStyles.sectionHeader,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              'Add some questions to preview the quiz.',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            PrimaryButton(
              onPressed: () {
                context.go('${RouteConstants.quizCreation}/form?id=${quiz.id}');
              },
              text: 'Add Questions',
              icon: Icons.add,
            ),
          ],
        ),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];

    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Quiz info header
          Container(
            color: AppColors.pureWhite,
            padding: EdgeInsets.all(
              isDesktop ? AppSpacing.spacingXL : AppSpacing.spacingL,
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Text(
                      quiz.title,
                      style: AppTextStyles.gameTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spacingS),
                    Text(
                      quiz.description,
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.coolGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spacingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingM,
                        vertical: AppSpacing.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.vibrantPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        quiz.metadata.category,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.vibrantPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Progress indicator
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / questions.length,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.vibrantPurple,
              ),
            ),
          ),
          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop
                    ? AppSpacing.spacingXXL
                    : isTablet
                    ? AppSpacing.spacingXL
                    : AppSpacing.spacingL,
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // Question number and info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                            style: AppTextStyles.sectionHeader,
                          ),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.timer_outlined,
                                '${currentQuestion.questionTimeLimit}s',
                                AppColors.timeWarning,
                              ),
                              const SizedBox(width: AppSpacing.spacingM),
                              _buildInfoChip(
                                Icons.star_outline,
                                '${currentQuestion.questionPoints} pts',
                                AppColors.warmYellow,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacingXL),
                      // Question card
                      SlideTransition(
                        position: _slideController.drive(
                          Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(curve: AppAnimations.newQuestionCurve),
                          ),
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: AppColors.lightGray,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.spacingXL),
                            child: Column(
                              children: [
                                Text(
                                  currentQuestion.questionText,
                                  style: AppTextStyles.questionText,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.spacingXL),
                                // Answer options
                                _buildAnswerOptions(currentQuestion),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Navigation footer
          Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.all(
              isDesktop ? AppSpacing.spacingXL : AppSpacing.spacingL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  TextButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.coolGray,
                    ),
                    label: Text(
                      'Previous',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                if (_currentQuestionIndex == questions.length - 1)
                  PrimaryButton(
                    onPressed: () {
                      context.go(
                        '${RouteConstants.quizCreation}/publish?id=${quiz.id}',
                      );
                    },
                    text: 'Publish Quiz',
                    icon: Icons.publish,
                    backgroundColor: AppColors.success,
                    width: 140,
                  )
                else
                  PrimaryButton(
                    onPressed: () => _nextQuestion(questions),
                    text: 'Next',
                    icon: Icons.arrow_forward,
                    backgroundColor: AppColors.vibrantPurple,
                    width: 120,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    return question.when(
      multipleChoice:
          (
            id,
            questionText,
            options,
            correctAnswer,
            timeLimit,
            points,
            imageUrl,
            explanation,
          ) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.spacingM,
                crossAxisSpacing: AppSpacing.spacingM,
                childAspectRatio: 2.5,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                return AnswerButton(
                  text: options[index],
                  shape: _getShapeForIndex(index),
                  isSelected: _selectedAnswer == index,
                  isCorrect: _showCorrectAnswer && index == correctAnswer,
                  isIncorrect:
                      _showCorrectAnswer &&
                      _selectedAnswer == index &&
                      index != correctAnswer,
                  showResult: _showCorrectAnswer,
                  onPressed: () => _selectAnswer(index),
                );
              },
            );
          },
      trueFalse:
          (
            id,
            questionText,
            correctAnswer,
            timeLimit,
            points,
            imageUrl,
            explanation,
          ) {
            final options = ['True', 'False'];
            final correctIndex = correctAnswer ? 0 : 1;

            return Row(
              children: [
                Expanded(
                  child: AnswerButton(
                    text: options[0],
                    shape: AnswerShape.circle,
                    isSelected: _selectedAnswer == 0,
                    isCorrect: _showCorrectAnswer && 0 == correctIndex,
                    isIncorrect:
                        _showCorrectAnswer &&
                        _selectedAnswer == 0 &&
                        0 != correctIndex,
                    showResult: _showCorrectAnswer,
                    onPressed: () => _selectAnswer(0),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: AnswerButton(
                    text: options[1],
                    shape: AnswerShape.square,
                    isSelected: _selectedAnswer == 1,
                    isCorrect: _showCorrectAnswer && 1 == correctIndex,
                    isIncorrect:
                        _showCorrectAnswer &&
                        _selectedAnswer == 1 &&
                        1 != correctIndex,
                    showResult: _showCorrectAnswer,
                    onPressed: () => _selectAnswer(1),
                  ),
                ),
              ],
            );
          },
    );
  }

  AnswerShape _getShapeForIndex(int index) {
    switch (index % 4) {
      case 0:
        return AnswerShape.triangle;
      case 1:
        return AnswerShape.diamond;
      case 2:
        return AnswerShape.circle;
      case 3:
        return AnswerShape.square;
      default:
        return AnswerShape.square;
    }
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.spacingXS),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
