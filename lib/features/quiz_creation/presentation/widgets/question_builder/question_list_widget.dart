import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_spacing.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/constants/app_animations.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import 'question_card_widget.dart';
import 'add_question_dialog.dart';
import '../../providers/quiz_creation_provider.dart';
import '../../../domain/entities/question_entities.dart';

/// Widget to display and manage list of questions with drag-and-drop
class QuestionListWidget extends ConsumerStatefulWidget {
  const QuestionListWidget({super.key});

  @override
  ConsumerState<QuestionListWidget> createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends ConsumerState<QuestionListWidget>
    with TickerProviderStateMixin {
  late final AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddQuestionDialog(
        onQuestionAdded: (questionData) {
          // Convert Map to Question entity
          final question = questionData['type'] == 'multiple_choice'
              ? Question.multipleChoice(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  question: questionData['question'],
                  options: List<String>.from(questionData['options']),
                  correctAnswer: questionData['correctAnswer'],
                  timeLimit: questionData['timeLimit'],
                  points: questionData['points'],
                )
              : Question.trueFalse(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  question: questionData['question'],
                  correctAnswer: questionData['correctAnswer'] == 0,
                  timeLimit: questionData['timeLimit'],
                  points: questionData['points'],
                );
          
          ref.read(quizCreationProvider.notifier).addQuestion(question);
        },
      ),
    );
  }

  void _editQuestion(int index) {
    final questions = ref.read(quizCreationProvider).questions;
    if (index < 0 || index >= questions.length) return;
    
    final existingQuestion = questions[index];
    
    // Convert Question entity to Map format for dialog
    final questionData = existingQuestion.when(
      multipleChoice: (id, question, options, correctAnswer, timeLimit, points, imageUrl, explanation) => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'timeLimit': timeLimit,
        'points': points,
        'type': 'multiple_choice',
      },
      trueFalse: (id, question, correctAnswer, timeLimit, points, imageUrl, explanation) => {
        'question': question,
        'options': ['True', 'False'],
        'correctAnswer': correctAnswer ? 0 : 1,
        'timeLimit': timeLimit,
        'points': points,
        'type': 'true_false',
      },
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddQuestionDialog(
        existingQuestion: questionData,
        onQuestionAdded: (updatedQuestionData) {
          // Convert Map to Question entity
          final question = updatedQuestionData['type'] == 'multiple_choice'
              ? Question.multipleChoice(
                  id: existingQuestion.when(
                    multipleChoice: (id, _, __, ___, ____, _____, ______, _______) => id,
                    trueFalse: (id, _, __, ___, ____, _____, ______) => id,
                  ),
                  question: updatedQuestionData['question'],
                  options: List<String>.from(updatedQuestionData['options']),
                  correctAnswer: updatedQuestionData['correctAnswer'],
                  timeLimit: updatedQuestionData['timeLimit'],
                  points: updatedQuestionData['points'],
                )
              : Question.trueFalse(
                  id: existingQuestion.when(
                    multipleChoice: (id, _, __, ___, ____, _____, ______, _______) => id,
                    trueFalse: (id, _, __, ___, ____, _____, ______) => id,
                  ),
                  question: updatedQuestionData['question'],
                  correctAnswer: updatedQuestionData['correctAnswer'] == 0,
                  timeLimit: updatedQuestionData['timeLimit'],
                  points: updatedQuestionData['points'],
                );
          
          ref.read(quizCreationProvider.notifier).updateQuestion(index, question);
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth * 0.9;
          final maxHeight = constraints.maxHeight * 0.8;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth.clamp(280.0, 400.0),
                maxHeight: maxHeight,
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Delete Question?',
                  style: AppTextStyles.sectionHeader,
                ),
                content: SingleChildScrollView(
                  child: Text(
                    'Are you sure you want to delete this question?',
                    style: AppTextStyles.bodyText,
                  ),
                ),
                actions: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.coolGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Flexible(
                    child: PrimaryButton(
                      onPressed: () {
                        ref.read(quizCreationProvider.notifier).removeQuestion(index);
                        Navigator.pop(context);
                      },
                      text: 'Delete',
                      backgroundColor: AppColors.coralRed,
                      width: 100, // Fixed width for dialog
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final availableHeight = isSmallScreen
        ? screenHeight * 0.5
        : screenHeight * 0.6;

    final state = ref.watch(quizCreationProvider);
    final questions = state.questions;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: SlideTransition(
            position: _listAnimationController.drive(
              Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).chain(CurveTween(curve: AppAnimations.easeOut)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Questions', style: AppTextStyles.sectionHeader),
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            '${questions.length} questions added',
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    PrimaryButton(
                      onPressed: _addQuestion,
                      text: isSmallScreen ? 'Add' : 'Add Question',
                      icon: Icons.add,
                      backgroundColor: AppColors.vibrantPurple,
                      width: isSmallScreen ? 80 : 140, // Fixed width for row
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacingL),
                if (questions.isEmpty)
                  _buildEmptyState(availableHeight, constraints)
                else
                  _buildQuestionList(availableHeight, constraints, questions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double availableHeight, BoxConstraints constraints) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final containerHeight = availableHeight.clamp(
      isSmallScreen ? 200.0 : 250.0,
      isSmallScreen ? 300.0 : 400.0,
    );

    return SizedBox(
      width: constraints.maxWidth,
      height: containerHeight,
      child: Container(
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightGray,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: isSmallScreen ? 60 : 80,
                  color: AppColors.lightGray,
                ),
                const SizedBox(height: AppSpacing.spacingL),
                Text(
                  'No questions yet',
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.coolGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  'Start building your quiz by adding questions',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.coolGray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.spacingXL),
                PrimaryButton(
                  onPressed: _addQuestion,
                  text: isSmallScreen
                      ? 'Add Question'
                      : 'Add Your First Question',
                  icon: Icons.add,
                  backgroundColor: AppColors.vibrantPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionList(
    double availableHeight,
    BoxConstraints constraints,
    List<Question> questions,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: availableHeight,
        maxWidth: constraints.maxWidth,
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: questions.length,
        onReorder: (oldIndex, newIndex) {
          ref.read(quizCreationProvider.notifier).reorderQuestions(oldIndex, newIndex);
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                shadowColor: AppColors.shadowLight,
                child: child,
              );
            },
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final question = questions[index];
          
          // Convert Question entity to Map format for QuestionCardWidget
          final questionData = question.when(
            multipleChoice: (id, questionText, options, correctAnswer, timeLimit, points, imageUrl, explanation) => {
              'question': questionText,
              'options': options,
              'correctAnswer': correctAnswer,
              'timeLimit': timeLimit,
              'points': points,
              'type': 'multiple_choice',
            },
            trueFalse: (id, questionText, correctAnswer, timeLimit, points, imageUrl, explanation) => {
              'question': questionText,
              'options': ['True', 'False'],
              'correctAnswer': correctAnswer ? 0 : 1,
              'timeLimit': timeLimit,
              'points': points,
              'type': 'true_false',
            },
          );
          
          return ConstrainedBox(
            key: ValueKey('question_$index'),
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: AnimatedContainer(
              duration: AppAnimations.shortAnimation,
              margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
              child: IntrinsicHeight(
                child: QuestionCardWidget(
                  index: index,
                  question: questionData,
                  onEdit: () => _editQuestion(index),
                  onDelete: () => _deleteQuestion(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
