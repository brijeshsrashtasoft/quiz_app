import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../widgets/quiz_stepper_widget.dart';
import '../widgets/quiz_metadata_form.dart';
import '../widgets/question_builder/question_list_widget.dart';
import '../providers/quiz_creation_provider.dart';

/// Main quiz creation page with stepper workflow
class QuizCreationPage extends ConsumerStatefulWidget {
  const QuizCreationPage({super.key});

  @override
  ConsumerState<QuizCreationPage> createState() => _QuizCreationPageState();
}

class _QuizCreationPageState extends ConsumerState<QuizCreationPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  int _currentStep = 0;

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

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _slideController.forward(from: 0);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _slideController.forward(from: 0);
    }
  }

  void _saveAndPreview() {
    // Save quiz and navigate to preview
    context.push('${RouteConstants.quizCreation}/preview');
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
          'Create New Quiz',
          style: AppTextStyles.sectionHeader,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.charcoal),
          onPressed: () {
            // Show confirmation dialog before closing
            _showExitConfirmation(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveAndPreview,
            child: Text(
              'Preview',
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
            // Progress stepper
            Container(
              color: AppColors.pureWhite,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? AppSpacing.spacingXXL
                    : AppSpacing.spacingL,
                vertical: AppSpacing.spacingM,
              ),
              child: QuizStepperWidget(
                currentStep: _currentStep,
                onStepTapped: (step) {
                  setState(() {
                    _currentStep = step;
                  });
                  _slideController.forward(from: 0);
                },
              ),
            ),
            // Step content
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
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 800 : double.infinity,
                    ),
                    child: SlideTransition(
                      position: _slideController.drive(
                        Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: AppAnimations.newQuestionCurve)),
                      ),
                      child: _buildStepContent(),
                    ),
                  ),
                ),
              ),
            ),
            // Navigation buttons
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
                isDesktop
                    ? AppSpacing.spacingXL
                    : AppSpacing.spacingL,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: _previousStep,
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
                  PrimaryButton(
                    onPressed: _currentStep == 2 ? _saveAndPreview : _nextStep,
                    text: _currentStep == 2 ? 'Save & Preview' : 'Next',
                    icon: _currentStep == 2
                        ? Icons.visibility
                        : Icons.arrow_forward,
                    backgroundColor: AppColors.vibrantPurple,
                    
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return const QuizMetadataForm();
      case 1:
        return const QuestionListWidget();
      case 2:
        return _buildQuizSettings();
      default:
        return const SizedBox();
    }
  }

  Widget _buildQuizSettings() {
    return Card(
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
            Text(
              'Quiz Settings',
              style: AppTextStyles.sectionHeader,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            SwitchListTile(
              title: Text(
                'Make quiz public',
                style: AppTextStyles.bodyText,
              ),
              subtitle: Text(
                'Allow anyone to play this quiz',
                style: AppTextStyles.caption,
              ),
              value: true,
              onChanged: (value) {
                // Handle public toggle
              },
              activeColor: AppColors.vibrantPurple,
            ),
            const Divider(height: AppSpacing.spacingXL),
            SwitchListTile(
              title: Text(
                'Enable leaderboard',
                style: AppTextStyles.bodyText,
              ),
              subtitle: Text(
                'Show player rankings after each game',
                style: AppTextStyles.caption,
              ),
              value: true,
              onChanged: (value) {
                // Handle leaderboard toggle
              },
              activeColor: AppColors.vibrantPurple,
            ),
            const Divider(height: AppSpacing.spacingXL),
            SwitchListTile(
              title: Text(
                'Randomize questions',
                style: AppTextStyles.bodyText,
              ),
              subtitle: Text(
                'Questions appear in random order',
                style: AppTextStyles.caption,
              ),
              value: false,
              onChanged: (value) {
                // Handle randomize toggle
              },
              activeColor: AppColors.vibrantPurple,
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Leave quiz creation?',
          style: AppTextStyles.sectionHeader,
        ),
        content: Text(
          'Your progress will be saved as a draft.',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue Editing',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.coolGray,
              ),
            ),
          ),
          PrimaryButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            text: 'Save & Exit',
            backgroundColor: AppColors.vibrantPurple,
            
          ),
        ],
      ),
    );
  }
}