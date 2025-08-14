import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_spacing.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/constants/app_animations.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/inputs/text_input.dart';
import 'multiple_choice_builder.dart';
import 'true_false_builder.dart';

/// Dialog for adding or editing a question
class AddQuestionDialog extends StatefulWidget {
  final Map<String, dynamic>? existingQuestion;
  final Function(Map<String, dynamic>) onQuestionAdded;

  const AddQuestionDialog({
    super.key,
    this.existingQuestion,
    required this.onQuestionAdded,
  });

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _slideController;

  final _questionController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '20');
  final _pointsController = TextEditingController(text: '100');

  String _questionType = 'multiple_choice';
  List<String> _options = ['', '', '', ''];
  int _correctAnswer = 0;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _scaleController.forward();
    _slideController.forward();

    // Load existing question if editing
    if (widget.existingQuestion != null) {
      _loadExistingQuestion();
    }
  }

  void _loadExistingQuestion() {
    final question = widget.existingQuestion!;
    _questionController.text = question['question'];
    _questionType = question['type'];
    _options = List<String>.from(question['options']);
    _correctAnswer = question['correctAnswer'];
    _timeLimitController.text = question['timeLimit'].toString();
    _pointsController.text = question['points'].toString();
    _imageUrl = question['imageUrl'];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _questionController.dispose();
    _timeLimitController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  bool _validateQuestion() {
    // Clear any previous errors

    // Validate question text
    if (_questionController.text.trim().isEmpty) {
      _showValidationError('Please enter a question');
      return false;
    }

    if (_questionController.text.trim().length < 5) {
      _showValidationError('Question must be at least 5 characters long');
      return false;
    }

    // Validate options for multiple choice
    if (_questionType == 'multiple_choice') {
      final validOptions = _options.where((o) => o.trim().isNotEmpty).toList();
      if (validOptions.length < 2) {
        _showValidationError('Please provide at least 2 answer options');
        return false;
      }

      // Check if correct answer is valid
      if (_correctAnswer >= validOptions.length) {
        _showValidationError('Please select a valid correct answer');
        return false;
      }
    }

    // Validate time limit
    final timeLimit = int.tryParse(_timeLimitController.text);
    if (timeLimit == null || timeLimit < 5 || timeLimit > 300) {
      _showValidationError('Time limit must be between 5 and 300 seconds');
      return false;
    }

    // Validate points
    final points = int.tryParse(_pointsController.text);
    if (points == null || points < 10 || points > 10000) {
      _showValidationError('Points must be between 10 and 10,000');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    // Also show snackbar for immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.coralRed,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _saveQuestion() {
    if (!_validateQuestion()) return;

    // Show loading state briefly for better UX

    // Simulate brief processing time
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        final question = {
          'question': _questionController.text.trim(),
          'type': _questionType,
          'options': _options.where((o) => o.trim().isNotEmpty).toList(),
          'correctAnswer': _correctAnswer,
          'timeLimit': int.parse(_timeLimitController.text),
          'points': int.parse(_pointsController.text),
          'imageUrl': _imageUrl,
        };

        widget.onQuestionAdded(question);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenHeight < 700;
        final dialogWidth = (screenWidth * 0.9).clamp(320.0, 600.0);
        final dialogHeight = (screenHeight * 0.9).clamp(
          400.0,
          screenHeight * 0.95,
        );

        return ScaleTransition(
          scale: _scaleController.drive(
            CurveTween(curve: AppAnimations.elastic),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: dialogHeight,
              ),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with fixed height
                    Container(
                      padding: EdgeInsets.all(
                        isSmallScreen
                            ? AppSpacing.spacingM
                            : AppSpacing.spacingL,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.vibrantPurple,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.existingQuestion != null
                                  ? 'Edit Question'
                                  : 'Add New Question',
                              style: AppTextStyles.sectionHeader.copyWith(
                                color: AppColors.pureWhite,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.pureWhite,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content with flexible scrolling
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.all(
                          isSmallScreen
                              ? AppSpacing.spacingM
                              : AppSpacing.spacingL,
                        ),
                        child: SlideTransition(
                          position: _slideController.drive(
                            Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: AppAnimations.easeOut)),
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Question type selector
                                _buildQuestionTypeSelector(),
                                const SizedBox(height: AppSpacing.spacingL),
                                // Question input
                                CustomTextInput(
                                  controller: _questionController,
                                  label: 'Question',
                                  hint: 'Enter your question here',
                                  maxLines: isSmallScreen ? 2 : 3,
                                  maxLength: 200,
                                  prefixIcon: Icon(Icons.help_outline),
                                ),
                                const SizedBox(height: AppSpacing.spacingL),
                                // Image upload
                                _buildImageUpload(),
                                const SizedBox(height: AppSpacing.spacingL),
                                // Question builder based on type
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: isSmallScreen ? 200 : 300,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: AppAnimations.shortAnimation,
                                    child: _questionType == 'multiple_choice'
                                        ? MultipleChoiceBuilder(
                                            options: _options,
                                            correctAnswer: _correctAnswer,
                                            onOptionsChanged: (options) {
                                              setState(() {
                                                _options = options;
                                              });
                                            },
                                            onCorrectAnswerChanged: (index) {
                                              setState(() {
                                                _correctAnswer = index;
                                              });
                                            },
                                          )
                                        : TrueFalseBuilder(
                                            correctAnswer: _correctAnswer,
                                            onCorrectAnswerChanged: (index) {
                                              setState(() {
                                                _correctAnswer = index;
                                                _options = ['True', 'False'];
                                              });
                                            },
                                          ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.spacingL),
                                // Time and points with proper flex
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextInput(
                                          controller: _timeLimitController,
                                          label: 'Time (sec)',
                                          hint: '20',
                                          keyboardType: TextInputType.number,
                                          prefixIcon: Icon(
                                            Icons.timer_outlined,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AppSpacing.spacingM,
                                      ),
                                      Expanded(
                                        child: CustomTextInput(
                                          controller: _pointsController,
                                          label: 'Points',
                                          hint: '100',
                                          keyboardType: TextInputType.number,
                                          prefixIcon: Icon(Icons.star_outline),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(4),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Footer with fixed height
                    Container(
                      padding: EdgeInsets.all(
                        isSmallScreen
                            ? AppSpacing.spacingM
                            : AppSpacing.spacingL,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                            const SizedBox(width: AppSpacing.spacingM),
                            Flexible(
                              child: PrimaryButton(
                                onPressed: _saveQuestion,
                                text: widget.existingQuestion != null
                                    ? 'Update'
                                    : 'Add Question',
                                backgroundColor: AppColors.vibrantPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionTypeSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question Type', style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.spacingS),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  'multiple_choice',
                  'Multiple Choice',
                  Icons.radio_button_checked,
                  AppColors.vibrantPurple,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Expanded(
                child: _buildTypeOption(
                  'true_false',
                  'True/False',
                  Icons.toggle_on,
                  AppColors.turquoise,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _questionType == value;
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return GestureDetector(
      onTap: () {
        setState(() {
          _questionType = value;
          if (value == 'true_false') {
            _options = ['True', 'False'];
            if (_correctAnswer > 1) _correctAnswer = 0;
          } else {
            _options = ['', '', '', ''];
          }
        });
      },
      child: AnimatedContainer(
        duration: AppAnimations.shortAnimation,
        padding: EdgeInsets.all(
          isSmallScreen ? AppSpacing.spacingS : AppSpacing.spacingM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.coolGray,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: isSelected ? color : AppColors.coolGray,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return Container(
      padding: EdgeInsets.all(
        isSmallScreen ? AppSpacing.spacingS : AppSpacing.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.coolGray,
              size: isSmallScreen ? 20 : 24,
            ),
            const SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: Text(
                _imageUrl != null ? 'Image uploaded' : 'Add image (optional)',
                style: AppTextStyles.bodyText.copyWith(
                  color: _imageUrl != null
                      ? AppColors.vibrantPurple
                      : AppColors.coolGray,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Flexible(
              child: TextButton(
                onPressed: () {
                  // Handle image upload
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Image upload will be implemented'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                child: Text(
                  _imageUrl != null ? 'Change' : 'Upload',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.vibrantPurple,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
