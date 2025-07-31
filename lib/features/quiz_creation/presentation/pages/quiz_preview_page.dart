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
import '../providers/quiz_creation_provider.dart';

/// Quiz preview page to see how the quiz will look
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

  // Mock data for preview
  final _mockQuiz = {
    'title': 'World Geography Quiz',
    'description':
        'Test your knowledge of world geography with these challenging questions!',
    'category': 'Geography',
    'questions': [
      {
        'question': 'What is the capital of France?',
        'options': ['London', 'Berlin', 'Paris', 'Madrid'],
        'correctAnswer': 2,
        'timeLimit': 20,
        'points': 100,
        'type': 'multiple_choice',
      },
      {
        'question': 'Mount Everest is the tallest mountain in the world.',
        'options': ['True', 'False'],
        'correctAnswer': 0,
        'timeLimit': 10,
        'points': 50,
        'type': 'true_false',
      },
    ],
  };

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

  void _nextQuestion() {
    final questions = _mockQuiz['questions'] as List;
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
    final questions = _mockQuiz['questions'] as List;
    final currentQuestion =
        questions[_currentQuestionIndex] as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('Preview Quiz', style: AppTextStyles.sectionHeader),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go('${RouteConstants.quizCreation}/form');
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
      body: FadeTransition(
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
                        _mockQuiz['title'] as String,
                        style: AppTextStyles.gameTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      Text(
                        _mockQuiz['description'] as String,
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
                          color: AppColors.vibrantPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _mockQuiz['category'] as String,
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
            Container(
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
                                  '${currentQuestion['timeLimit']}s',
                                  AppColors.timeWarning,
                                ),
                                const SizedBox(width: AppSpacing.spacingM),
                                _buildInfoChip(
                                  Icons.star_outline,
                                  '${currentQuestion['points']} pts',
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
                              padding: const EdgeInsets.all(
                                AppSpacing.spacingXL,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    currentQuestion['question'],
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
                    color: AppColors.shadowLight.withOpacity(0.1),
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
                  Row(
                    children: [
                      if (_currentQuestionIndex == questions.length - 1)
                        PrimaryButton(
                          onPressed: () {
                            context.go(
                              '${RouteConstants.quizCreation}/publish',
                            );
                          },
                          text: 'Publish Quiz',
                          icon: Icons.publish,
                          backgroundColor: AppColors.success,
                        )
                      else
                        PrimaryButton(
                          onPressed: _nextQuestion,
                          text: 'Next',
                          icon: Icons.arrow_forward,
                          backgroundColor: AppColors.vibrantPurple,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(Map<String, dynamic> question) {
    final options = question['options'] as List;
    final correctAnswer = question['correctAnswer'] as int;
    final isMultipleChoice = question['type'] == 'multiple_choice';

    if (isMultipleChoice) {
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
    } else {
      // True/False layout
      return Row(
        children: [
          Expanded(
            child: AnswerButton(
              text: options[0],
              shape: AnswerShape.circle,
              isSelected: _selectedAnswer == 0,
              isCorrect: _showCorrectAnswer && 0 == correctAnswer,
              isIncorrect:
                  _showCorrectAnswer &&
                  _selectedAnswer == 0 &&
                  0 != correctAnswer,
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
              isCorrect: _showCorrectAnswer && 1 == correctAnswer,
              isIncorrect:
                  _showCorrectAnswer &&
                  _selectedAnswer == 1 &&
                  1 != correctAnswer,
              showResult: _showCorrectAnswer,
              onPressed: () => _selectAnswer(1),
            ),
          ),
        ],
      );
    }
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

  Color _getColorForIndex(int index) {
    switch (index % 4) {
      case 0:
        return AppColors.triangleRed;
      case 1:
        return AppColors.diamondGreen;
      case 2:
        return AppColors.circleYellow;
      case 3:
        return AppColors.squareTurquoise;
      default:
        return AppColors.vibrantPurple;
    }
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
