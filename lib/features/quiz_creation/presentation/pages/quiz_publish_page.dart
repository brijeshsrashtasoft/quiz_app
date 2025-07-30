import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';

/// Quiz publish confirmation page
class QuizPublishPage extends ConsumerStatefulWidget {
  const QuizPublishPage({super.key});

  @override
  ConsumerState<QuizPublishPage> createState() => _QuizPublishPageState();
}

class _QuizPublishPageState extends ConsumerState<QuizPublishPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isPublishing = false;
  bool _isPublished = false;

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
    setState(() {
      _isPublishing = true;
    });

    // Simulate publishing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isPublishing = false;
      _isPublished = true;
    });

    // Show success animation
    _animationController.repeat(count: 2);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text(
          _isPublished ? 'Quiz Published!' : 'Publish Quiz',
          style: AppTextStyles.sectionHeader,
        ),
      ),
      body: Center(
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
            child: _isPublished
                ? _buildSuccessState()
                : _buildPublishState(),
          ),
        ),
      ),
    );
  }

  Widget _buildPublishState() {
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
                  color: AppColors.vibrantPurple.withOpacity(0.1),
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
              // Quiz summary
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Quiz Title', 'World Geography Quiz'),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Category', 'Geography'),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Questions', '15'),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Total Points', '1500'),
                    const Divider(height: AppSpacing.spacingL),
                    _buildSummaryRow('Visibility', 'Public'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXXL),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isPublishing
                          ? null
                          : () => context.go('${RouteConstants.quizCreation}/preview'),
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
                      onPressed: _isPublishing ? null : _publishQuiz,
                      text: _isPublishing ? 'Publishing...' : 'Publish Quiz',
                      backgroundColor: AppColors.success,
                      isLoading: _isPublishing,
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

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _animationController.drive(
            Tween(begin: 0.0, end: 1.0),
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingXL),
        Text(
          'Quiz Published Successfully!',
          style: AppTextStyles.gameTitle.copyWith(
            color: AppColors.success,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Text(
          'Your quiz is now live and ready for players.',
          style: AppTextStyles.bodyText.copyWith(
            color: AppColors.coolGray,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spacingXXL),
        // Share options
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacingL),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Share Quiz PIN',
                style: AppTextStyles.sectionHeader,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '1234567',
                      style: AppTextStyles.gameTitle.copyWith(
                        color: AppColors.vibrantPurple,
                        fontFamily: 'monospace',
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PIN copied to clipboard!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: Icon(Icons.copy, color: AppColors.vibrantPurple),
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
                onPressed: () => context.go(RouteConstants.gameHost),
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
          style: AppTextStyles.bodyText.copyWith(
            color: AppColors.coolGray,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}