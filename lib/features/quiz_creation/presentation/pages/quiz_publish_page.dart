import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/quiz_providers.dart';

/// Quiz publish confirmation page
class QuizPublishPage extends ConsumerStatefulWidget {
  const QuizPublishPage({super.key});

  @override
  ConsumerState<QuizPublishPage> createState() => _QuizPublishPageState();
}

class _QuizPublishPageState extends ConsumerState<QuizPublishPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.longAnimation,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _publishQuiz() async {
    // Get quiz ID from route parameters
    final routerState = GoRouterState.of(context);
    final quizId = routerState.uri.queryParameters['id'];

    if (quizId == null || quizId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No quiz ID provided'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
      return;
    }

    // Get the publish notifier and trigger publish
    final publishNotifier = ref.read(quizPublishProvider(quizId).notifier);
    final success = await publishNotifier.publishQuiz();

    if (success) {
      // Show success animation
      _animationController.repeat(count: 2);
    } else {
      // Error will be shown by watching the provider state
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    // Get quiz ID from route parameters
    final routerState = GoRouterState.of(context);
    final quizId = routerState.uri.queryParameters['id'];

    if (quizId == null || quizId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.pureWhite,
          elevation: 0,
          title: Text('Publish Quiz', style: AppTextStyles.sectionHeader),
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

    // Watch quiz data and publish state
    final quizAsyncValue = ref.watch(quizByIdProvider(quizId));
    final publishState = ref.watch(quizPublishProvider(quizId));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text(
          publishState.isPublished ? 'Quiz Published!' : 'Publish Quiz',
          style: AppTextStyles.sectionHeader,
        ),
      ),
      body: quizAsyncValue.when(
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error),
        data: (quiz) {
          if (quiz == null) {
            return _buildNotFoundState();
          }

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(
                isDesktop
                    ? AppSpacing.spacingXXL
                    : isTablet
                    ? AppSpacing.spacingXL
                    : AppSpacing.spacingL,
              ),
              child: AnimatedSwitcher(
                duration: AppAnimations.mediumAnimation,
                child: publishState.isPublished
                    ? _buildSuccessState(quiz)
                    : _buildPublishState(quiz, publishState),
              ),
            ),
          );
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
            'Loading quiz data...',
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
            onPressed: () => context.go(RouteConstants.quizCreation),
            text: 'Back to Quiz Creation',
            icon: Icons.arrow_back,
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
            'The quiz you\'re trying to publish doesn\'t exist.',
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

  Widget _buildPublishState(quiz, publishState) {
    return ScaleTransition(
      scale: _animationController.drive(
        CurveTween(curve: AppAnimations.elastic),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.lightGray),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.vibrantPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.publish,
                  size: 40,
                  color: AppColors.vibrantPurple,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXL),
              Text(
                'Ready to Publish?',
                style: AppTextStyles.gameTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                'Your quiz will be available for players to join and play.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingXL),
              // Show error if publishing failed
              if (publishState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.coralRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.coralRed),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.coralRed),
                      const SizedBox(width: AppSpacing.spacingM),
                      Expanded(
                        child: Text(
                          publishState.error!,
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.coralRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingL),
              ],
              // Quiz summary
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Quiz Title', quiz.title),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Category', quiz.metadata.category),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Questions', '${quiz.questions.length}'),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Total Points', '${quiz.totalPoints}'),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow(
                      'Visibility',
                      quiz.isPublic ? 'Public' : 'Private',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXXL),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: publishState.isPublishing
                          ? null
                          : () => context.go(
                              '${RouteConstants.quizCreationPreview}?id=${quiz.id}',
                            ),
                      child: Text(
                        'Back to Preview',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingM),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: publishState.isPublishing
                          ? null
                          : _publishQuiz,
                      text: publishState.isPublishing
                          ? 'Publishing...'
                          : 'Publish Quiz',
                      backgroundColor: AppColors.success,
                      isLoading: publishState.isPublishing,
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

  Widget _buildSuccessState(quiz) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 60, color: AppColors.success),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingXL),
        Text(
          'Quiz Published Successfully!',
          style: AppTextStyles.gameTitle.copyWith(color: AppColors.success),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Text(
          'Your quiz is now live and ready for players.',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spacingXXL),
        // Quiz published info
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacingL),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text('Quiz Details', style: AppTextStyles.sectionHeader),
              const SizedBox(height: AppSpacing.spacingM),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Column(
                  children: [
                    Text(
                      quiz.title,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spacingS),
                    Text(
                      '${quiz.questions.length} questions • ${quiz.totalPoints} points',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingM,
                        vertical: AppSpacing.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PUBLISHED',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacingXXL),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                onPressed: () => context.go(RouteConstants.home),
                text: 'Go to Dashboard',
                backgroundColor: AppColors.vibrantPurple,
                icon: Icons.dashboard,
              ),
            ),
            const SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: PrimaryButton(
                onPressed: () =>
                    context.go('${RouteConstants.gameHost}?quizId=${quiz.id}'),
                text: 'Host Game',
                backgroundColor: AppColors.turquoise,
                icon: Icons.play_arrow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
        ),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
