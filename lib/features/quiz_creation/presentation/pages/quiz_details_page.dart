import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/quiz_providers.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question_entities.dart';

/// Quiz details page to display quiz information and provide editing access
class QuizDetailsPage extends ConsumerWidget {
  final String quizId;

  const QuizDetailsPage({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    // Watch the quiz data from Firebase
    final quizAsyncValue = ref.watch(quizByIdProvider(quizId));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('Quiz Details', style: AppTextStyles.sectionHeader),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go(RouteConstants.quizEditPath(quizId));
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
        error: (error, stackTrace) => _buildErrorState(error, context, ref),
        data: (quiz) {
          if (quiz == null) {
            return _buildNotFoundState(context);
          }
          return _buildQuizDetails(quiz, isTablet, isDesktop, context);
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
            'Loading quiz details...',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, BuildContext context, WidgetRef ref) {
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

  Widget _buildNotFoundState(BuildContext context) {
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
            onPressed: () => context.go(RouteConstants.home),
            text: 'Back to Home',
            icon: Icons.home,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizDetails(
    Quiz quiz,
    bool isTablet,
    bool isDesktop,
    BuildContext context,
  ) {
    return SingleChildScrollView(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quiz header card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.lightGray, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.spacingXL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title, style: AppTextStyles.gameTitle),
                      const SizedBox(height: AppSpacing.spacingM),
                      Text(
                        quiz.description,
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingL),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.category_outlined,
                            quiz.metadata.category,
                            AppColors.vibrantPurple,
                          ),
                          const SizedBox(width: AppSpacing.spacingM),
                          _buildInfoChip(
                            Icons.help_outline,
                            '${quiz.questions.length} Questions',
                            AppColors.mintGreen,
                          ),
                          const SizedBox(width: AppSpacing.spacingM),
                          _buildInfoChip(
                            Icons.schedule,
                            '${quiz.metadata.estimatedDuration} min',
                            AppColors.timeWarning,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacingL),
                      Row(
                        children: [
                          Icon(
                            quiz.isPublic ? Icons.public : Icons.lock_outline,
                            color: quiz.isPublic
                                ? AppColors.mintGreen
                                : AppColors.coolGray,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.spacingS),
                          Text(
                            quiz.isPublic ? 'Public Quiz' : 'Private Quiz',
                            style: AppTextStyles.bodyText.copyWith(
                              color: quiz.isPublic
                                  ? AppColors.mintGreen
                                  : AppColors.coolGray,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacingM,
                              vertical: AppSpacing.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: quiz.isDraft
                                  ? AppColors.timeWarning.withValues(alpha: 0.1)
                                  : AppColors.mintGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              quiz.isDraft ? 'Draft' : 'Published',
                              style: AppTextStyles.caption.copyWith(
                                color: quiz.isDraft
                                    ? AppColors.timeWarning
                                    : AppColors.mintGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (quiz.questions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.spacingXL),
                // Questions preview card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.lightGray,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spacingXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Questions Preview',
                              style: AppTextStyles.sectionHeader,
                            ),
                            const Spacer(),
                            Text(
                              '${quiz.questions.length} total',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.coolGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spacingL),
                        ...quiz.questions.take(3).toList().asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final question = entry.value;
                          return _buildQuestionPreview(question, index + 1);
                        }),
                        if (quiz.questions.length > 3) ...[
                          const SizedBox(height: AppSpacing.spacingM),
                          Center(
                            child: Text(
                              '+ ${quiz.questions.length - 3} more questions',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.coolGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.spacingXXL),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        context.go(RouteConstants.quizEditPath(quizId));
                      },
                      text: 'Edit Quiz',
                      icon: Icons.edit,
                      backgroundColor: AppColors.vibrantPurple,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingM),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        // Navigate to game hosting with this quiz selected
                        context.go('${RouteConstants.gameHost}?quizId=$quizId');
                      },
                      text: 'Host Game',
                      icon: Icons.play_arrow,
                      backgroundColor: AppColors.mintGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildQuestionPreview(Question question, int questionNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.vibrantPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: Text(
                  question.questionText,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Row(
            children: [
              _buildInfoChip(
                Icons.timer_outlined,
                '${question.questionTimeLimit}s',
                AppColors.timeWarning,
              ),
              const SizedBox(width: AppSpacing.spacingM),
              _buildInfoChip(
                Icons.star_outline,
                '${question.questionPoints} pts',
                AppColors.warmYellow,
              ),
              const SizedBox(width: AppSpacing.spacingM),
              _buildInfoChip(
                Icons.help_outline,
                question.when(
                  multipleChoice:
                      (_, __, options, ___, ____, _____, ______, _______) =>
                          '${options.length} choices',
                  trueFalse: (_, __, ___, ____, _____, ______, _______) =>
                      'True/False',
                ),
                AppColors.coolGray,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
