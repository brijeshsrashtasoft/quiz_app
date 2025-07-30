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

/// Widget to display and manage list of questions with drag-and-drop
class QuestionListWidget extends ConsumerStatefulWidget {
  const QuestionListWidget({super.key});

  @override
  ConsumerState<QuestionListWidget> createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends ConsumerState<QuestionListWidget>
    with TickerProviderStateMixin {
  late final AnimationController _listAnimationController;
  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _listAnimationController.forward();
    
    // Add sample questions for demo
    _questions.addAll([
      {
        'question': 'What is the capital of France?',
        'options': ['London', 'Berlin', 'Paris', 'Madrid'],
        'correctAnswer': 2,
        'timeLimit': 20,
        'points': 100,
        'type': 'multiple_choice',
      },
      {
        'question': 'The Earth is flat.',
        'options': ['True', 'False'],
        'correctAnswer': 1,
        'timeLimit': 10,
        'points': 50,
        'type': 'true_false',
      },
    ]);
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
        onQuestionAdded: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  void _editQuestion(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddQuestionDialog(
        existingQuestion: _questions[index],
        onQuestionAdded: (question) {
          setState(() {
            _questions[index] = question;
          });
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Question?',
          style: AppTextStyles.sectionHeader,
        ),
        content: Text(
          'Are you sure you want to delete this question?',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.coolGray,
              ),
            ),
          ),
          PrimaryButton(
            onPressed: () {
              setState(() {
                _questions.removeAt(index);
              });
              Navigator.pop(context);
            },
            text: 'Delete',
            backgroundColor: AppColors.coralRed,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _listAnimationController.drive(
        Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: AppAnimations.easeOut)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions',
                    style: AppTextStyles.sectionHeader,
                  ),
                  const SizedBox(height: AppSpacing.spacingXS),
                  Text(
                    '${_questions.length} questions added',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              PrimaryButton(
                onPressed: _addQuestion,
                text: 'Add Question',
                icon: Icons.add,
                backgroundColor: AppColors.vibrantPurple,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingL),
          if (_questions.isEmpty)
            _buildEmptyState()
          else
            _buildQuestionList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: AppColors.lightGray,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'No questions yet',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.coolGray,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Text(
              'Start building your quiz by adding questions',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.coolGray,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXL),
            PrimaryButton(
              onPressed: _addQuestion,
              text: 'Add Your First Question',
              icon: Icons.add,
              backgroundColor: AppColors.vibrantPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _questions.removeAt(oldIndex);
          _questions.insert(newIndex, item);
        });
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
        final question = _questions[index];
        return AnimatedContainer(
          key: ValueKey('question_$index'),
          duration: AppAnimations.shortAnimation,
          margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
          child: QuestionCardWidget(
            index: index,
            question: question,
            onEdit: () => _editQuestion(index),
            onDelete: () => _deleteQuestion(index),
          ),
        );
      },
    );
  }
}