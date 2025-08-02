import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
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

class _QuizCreationPageState extends ConsumerState<QuizCreationPage> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _saveAndPreview() async {
    final notifier = ref.read(quizCreationProvider.notifier);
    final state = ref.read(quizCreationProvider);
    
    // Show loading indicator
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving quiz...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    
    // Save the quiz
    final quizId = await notifier.saveQuiz();
    
    if (context.mounted) {
      if (quizId != null) {
        // Success - navigate to preview
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz saved successfully!'),
            backgroundColor: AppColors.vibrantPurple,
          ),
        );
        context.push('${RouteConstants.quizCreation}/preview?id=$quizId');
      } else {
        // Error - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error ?? 'Failed to save quiz'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('Create New Quiz', style: AppTextStyles.sectionHeader),
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              // Show confirmation dialog before closing
              _showExitConfirmation(context);
            },
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                color: AppColors.charcoal,
                size: 24,
              ),
            ),
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(quizCreationProvider);
              return TextButton(
                onPressed: state.isLoading ? null : _saveAndPreview,
                child: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.vibrantPurple,
                          ),
                        ),
                      )
                    : Text(
                        'Preview',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.vibrantPurple,
                        ),
                      ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.spacingM),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress stepper
            Container(
              color: AppColors.pureWhite,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? AppSpacing.spacingXXL
                    : isSmallScreen
                    ? AppSpacing.spacingM
                    : AppSpacing.spacingL,
                vertical: isSmallScreen
                    ? AppSpacing.spacingS
                    : AppSpacing.spacingM,
              ),
              child: QuizStepperWidget(
                currentStep: _currentStep,
                onStepTapped: (step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
              ),
            ),
            // Step content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.all(
                      isDesktop
                          ? AppSpacing.spacingXXL
                          : isTablet
                          ? AppSpacing.spacingXL
                          : isSmallScreen
                          ? AppSpacing.spacingM
                          : AppSpacing.spacingL,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 800 : double.infinity,
                          minHeight:
                              constraints.maxHeight -
                              (isDesktop
                                  ? AppSpacing.spacingXXL * 2
                                  : isTablet
                                  ? AppSpacing.spacingXL * 2
                                  : isSmallScreen
                                  ? AppSpacing.spacingM * 2
                                  : AppSpacing.spacingL * 2),
                        ),
                        child: _buildStepContent(),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Navigation buttons
            SafeArea(
              child: Container(
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
                      : isSmallScreen
                      ? AppSpacing.spacingM
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
                      const SizedBox.shrink(),
                    Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(quizCreationProvider);
                        return PrimaryButton(
                          onPressed: state.isLoading
                              ? null
                              : (_currentStep == 2 ? _saveAndPreview : _nextStep),
                          text: state.isLoading
                              ? 'Saving...'
                              : (_currentStep == 2 ? 'Save & Preview' : 'Next'),
                          icon: state.isLoading
                              ? null
                              : (_currentStep == 2
                                  ? Icons.visibility
                                  : Icons.arrow_forward),
                          backgroundColor: AppColors.vibrantPurple,
                          isLoading: state.isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget content;
        switch (_currentStep) {
          case 0:
            content = const QuizMetadataForm();
            break;
          case 1:
            content = const QuestionListWidget();
            break;
          case 2:
            content = _buildQuizSettings();
            break;
          default:
            content = const SizedBox.shrink();
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            minHeight: constraints.minHeight,
          ),
          child: content,
        );
      },
    );
  }

  Widget _buildQuizSettings() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final maxSettingsHeight = isSmallScreen
        ? screenHeight * 0.5
        : screenHeight * 0.6;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightGray, width: 1),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxSettingsHeight,
                maxWidth: constraints.maxWidth,
                minWidth: constraints.maxWidth,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(
                    isSmallScreen ? AppSpacing.spacingL : AppSpacing.spacingXL,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quiz Settings', style: AppTextStyles.sectionHeader),
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
                        value: ref.watch(quizCreationProvider).isPublic,
                        onChanged: (value) {
                          ref.read(quizCreationProvider.notifier).updateSettings(
                            isPublic: value,
                          );
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
                        value: ref.watch(quizCreationProvider).enableLeaderboard,
                        onChanged: (value) {
                          ref.read(quizCreationProvider.notifier).updateSettings(
                            enableLeaderboard: value,
                          );
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
                        value: ref.watch(quizCreationProvider).randomizeQuestions,
                        onChanged: (value) {
                          ref.read(quizCreationProvider.notifier).updateSettings(
                            randomizeQuestions: value,
                          );
                        },
                        activeColor: AppColors.vibrantPurple,
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

  void _showExitConfirmation(BuildContext context) {
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
                  'Leave quiz creation?',
                  style: AppTextStyles.sectionHeader,
                ),
                content: SingleChildScrollView(
                  child: Text(
                    'Your progress will be saved as a draft.',
                    style: AppTextStyles.bodyText,
                  ),
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
            ),
          );
        },
      ),
    );
  }
}
