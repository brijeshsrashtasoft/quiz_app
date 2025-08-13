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
import '../providers/quiz_providers.dart';

/// Main quiz creation page with stepper workflow
/// Supports both creation (quizId = null) and editing (quizId provided) modes
class QuizCreationPage extends ConsumerStatefulWidget {
  final String? quizId;

  const QuizCreationPage({super.key, this.quizId});

  /// Check if this is edit mode
  bool get isEditMode => quizId != null;

  @override
  ConsumerState<QuizCreationPage> createState() => _QuizCreationPageState();
}

class _QuizCreationPageState extends ConsumerState<QuizCreationPage> {
  int _currentStep = 0;
  bool _isLoadingQuiz = false;

  @override
  void initState() {
    super.initState();
    // Initialize based on mode (create vs edit)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditMode && widget.quizId != null) {
        _loadExistingQuiz(widget.quizId!);
      } else {
        ref.read(quizCreationProvider.notifier).updateMetadata();
      }
    });
  }

  /// Load existing quiz data for editing
  Future<void> _loadExistingQuiz(String quizId) async {
    setState(() {
      _isLoadingQuiz = true;
    });

    try {
      // Fetch quiz data using the provider
      final quiz = await ref.read(quizByIdProvider(quizId).future);

      if (quiz != null && mounted) {
        // Pre-populate the creation state with existing quiz data
        final notifier = ref.read(quizCreationProvider.notifier);
        notifier.loadExistingQuiz(quiz);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load quiz: $e'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQuiz = false;
        });
      }
    }
  }

  void _nextStep() {
    final notifier = ref.read(quizCreationProvider.notifier);

    // Check if user can proceed to next step
    if (!notifier.canProceedToStep(_currentStep + 1)) {
      // Show validation error
      final state = ref.read(quizCreationProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.validation.nextRequirement),
          backgroundColor: AppColors.coralRed,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

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

    // Check if quiz can be saved
    if (!notifier.canSaveQuiz()) {
      // Show detailed validation error
      _showValidationDialog(state.validation);
      return;
    }

    // Show loading indicator
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Saving quiz...'),
            ],
          ),
          backgroundColor: AppColors.vibrantPurple,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Save the quiz (pass existing quiz ID if in edit mode)
    final quizId = await notifier.saveQuiz(existingQuizId: state.editingQuizId);

    if (context.mounted) {
      if (quizId != null) {
        // Success - navigate to preview
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Quiz saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.mintGreen,
            duration: Duration(seconds: 2),
          ),
        );
        // Use go instead of push for nested routes, and use the proper route constant
        context.go('${RouteConstants.quizCreationPreview}?id=$quizId');
      } else {
        // Error - show detailed error message
        _showErrorDialog(state.error ?? 'Failed to save quiz');
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
        title: Text(
          widget.isEditMode ? 'Edit Quiz' : 'Create New Quiz',
          style: AppTextStyles.sectionHeader,
        ),
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
              final canSave = ref
                  .read(quizCreationProvider.notifier)
                  .canSaveQuiz();

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
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!canSave) ...[
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.coralRed,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            canSave ? 'Preview' : 'Incomplete',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: canSave
                                  ? AppColors.vibrantPurple
                                  : AppColors.coralRed,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.spacingM),
        ],
      ),
      body: _isLoadingQuiz
          ? _buildQuizLoadingState()
          : SafeArea(
              child: Column(
                children: [
                  // Progress stepper with validation status
                  Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(quizCreationProvider);

                      return Container(
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
                        child: Column(
                          children: [
                            QuizStepperWidget(
                              currentStep: _currentStep,
                              onStepTapped: (step) {
                                final notifier = ref.read(
                                  quizCreationProvider.notifier,
                                );
                                if (step <= _currentStep ||
                                    notifier.canProceedToStep(step)) {
                                  setState(() {
                                    _currentStep = step;
                                  });
                                } else {
                                  // Show validation message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        state.validation.nextRequirement,
                                      ),
                                      backgroundColor: AppColors.coralRed,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                            // Add overall progress indicator
                            if (!isSmallScreen) ...[
                              const SizedBox(height: AppSpacing.spacingS),
                              _buildProgressIndicator(state.validation),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  // Step content - simplified layout
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        isDesktop
                            ? AppSpacing.spacingXXL
                            : isTablet
                            ? AppSpacing.spacingXL
                            : isSmallScreen
                            ? AppSpacing.spacingM
                            : AppSpacing.spacingL,
                      ),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 800 : double.infinity,
                            ),
                            child: _buildStepContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Navigation buttons
                  SafeArea(
                    child: Container(
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
                          Flexible(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final state = ref.watch(quizCreationProvider);
                                final notifier = ref.read(
                                  quizCreationProvider.notifier,
                                );

                                bool canProceed;
                                String buttonText;
                                IconData? buttonIcon;
                                Color buttonColor;

                                if (_currentStep == 2) {
                                  // Final step - save button
                                  canProceed =
                                      notifier.canSaveQuiz() &&
                                      !state.isLoading;
                                  buttonText = state.isLoading
                                      ? 'Saving...'
                                      : canProceed
                                      ? (widget.isEditMode
                                            ? 'Update & Preview'
                                            : 'Save & Preview')
                                      : 'Add Questions First';
                                  buttonIcon = state.isLoading
                                      ? null
                                      : canProceed
                                      ? Icons.visibility
                                      : Icons.error_outline;
                                  buttonColor = canProceed
                                      ? AppColors.vibrantPurple
                                      : AppColors.coolGray;
                                } else {
                                  // Navigation steps
                                  canProceed =
                                      notifier.canProceedToStep(
                                        _currentStep + 1,
                                      ) &&
                                      !state.isLoading;
                                  buttonText = canProceed
                                      ? 'Next'
                                      : 'Complete This Step';
                                  buttonIcon = canProceed
                                      ? Icons.arrow_forward
                                      : Icons.warning;
                                  buttonColor = canProceed
                                      ? AppColors.vibrantPurple
                                      : AppColors.coolGray;
                                }

                                return PrimaryButton(
                                  onPressed: canProceed
                                      ? (_currentStep == 2
                                            ? _saveAndPreview
                                            : _nextStep)
                                      : () => _showValidationDialog(
                                          state.validation,
                                        ),
                                  text: buttonText,
                                  icon: buttonIcon,
                                  backgroundColor: buttonColor,
                                  isLoading: state.isLoading,
                                  width: 160, // Slightly wider for better text
                                );
                              },
                            ),
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
    return Consumer(
      builder: (context, ref, child) {
        // Check provider state for any errors
        final providerState = ref.watch(quizCreationProvider);

        return LayoutBuilder(
          builder: (context, constraints) {
            final Widget content;

            try {
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
                  content = Container(
                    padding: const EdgeInsets.all(AppSpacing.spacingL),
                    child: Center(
                      child: Text(
                        'Invalid step: $_currentStep',
                        style: AppTextStyles.bodyText,
                      ),
                    ),
                  );
              }
            } catch (e) {
              // Error fallback
              return Container(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.coralRed,
                      ),
                      const SizedBox(height: AppSpacing.spacingM),
                      Text(
                        'Error loading step content',
                        style: AppTextStyles.sectionHeader,
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      Text(
                        e.toString(),
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use simplified container without complex constraints
            return content;
          },
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
                          ref
                              .read(quizCreationProvider.notifier)
                              .updateSettings(isPublic: value);
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
                        value: ref
                            .watch(quizCreationProvider)
                            .enableLeaderboard,
                        onChanged: (value) {
                          ref
                              .read(quizCreationProvider.notifier)
                              .updateSettings(enableLeaderboard: value);
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
                        value: ref
                            .watch(quizCreationProvider)
                            .randomizeQuestions,
                        onChanged: (value) {
                          ref
                              .read(quizCreationProvider.notifier)
                              .updateSettings(randomizeQuestions: value);
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
                    width: 120, // Fixed width for dialog
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build overall progress indicator
  Widget _buildProgressIndicator(validation) {
    final completed = [
      validation.isTitleValid,
      validation.isDescriptionValid,
      validation.hasQuestions,
    ].where((item) => item).length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, size: 16, color: AppColors.vibrantPurple),
          const SizedBox(width: AppSpacing.spacingS),
          Text(
            'Progress: $completed/3 requirements',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.vibrantPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: LinearProgressIndicator(
              value: completed / 3.0,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation(
                completed == 3 ? AppColors.mintGreen : AppColors.vibrantPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show validation dialog with detailed requirements
  void _showValidationDialog(validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.checklist, color: AppColors.vibrantPurple, size: 24),
            const SizedBox(width: 8),
            Text('Quiz Requirements', style: AppTextStyles.sectionHeader),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete these requirements to save your quiz:',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            _buildDialogRequirement(
              'Quiz title (3+ characters)',
              validation.isTitleValid,
            ),
            _buildDialogRequirement(
              'Description (10+ characters)',
              validation.isDescriptionValid,
            ),
            _buildDialogRequirement(
              'At least 1 question',
              validation.hasQuestions,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGray),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.vibrantPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validation.nextRequirement,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.vibrantPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            text: 'Got it',
            backgroundColor: AppColors.vibrantPurple,
            width: 80,
          ),
        ],
      ),
    );
  }

  /// Build requirement item for dialog
  Widget _buildDialogRequirement(String text, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingXS),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isComplete ? AppColors.mintGreen : AppColors.coolGray,
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyText.copyWith(
                color: isComplete ? AppColors.charcoal : AppColors.coolGray,
                decoration: isComplete ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog for save failures
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.coralRed, size: 24),
            const SizedBox(width: 8),
            Text('Save Failed', style: AppTextStyles.sectionHeader),
          ],
        ),
        content: Text(errorMessage, style: AppTextStyles.bodyText),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            text: 'Try Again',
            backgroundColor: AppColors.coralRed,
            width: 100,
          ),
        ],
      ),
    );
  }

  /// Build loading state while fetching quiz data for editing
  Widget _buildQuizLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('Loading Quiz...', style: AppTextStyles.sectionHeader),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.vibrantPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'Loading quiz data for editing...',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
          ],
        ),
      ),
    );
  }
}
