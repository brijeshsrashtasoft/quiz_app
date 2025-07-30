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

  void _saveQuestion() {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a question'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    final question = {
      'question': _questionController.text,
      'type': _questionType,
      'options': _options.where((o) => o.isNotEmpty).toList(),
      'correctAnswer': _correctAnswer,
      'timeLimit': int.tryParse(_timeLimitController.text) ?? 20,
      'points': int.tryParse(_pointsController.text) ?? 100,
      'imageUrl': _imageUrl,
    };

    widget.onQuestionAdded(question);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleController.drive(
        CurveTween(curve: AppAnimations.elastic),
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
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
                    Text(
                      widget.existingQuestion != null
                          ? 'Edit Question'
                          : 'Add New Question',
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.spacingL),
                  child: SlideTransition(
                    position: _slideController.drive(
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: AppAnimations.easeOut)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question type selector
                        _buildQuestionTypeSelector(),
                        const SizedBox(height: AppSpacing.spacingL),
                        // Question input
                        CustomTextInput(
                          controller: _questionController,
                          label: 'Question',
                          hint: 'Enter your question here',
                          maxLines: 2,
                          maxLength: 200,
                          prefixIcon: Icon(Icons.help_outline),
                        ),
                        const SizedBox(height: AppSpacing.spacingL),
                        // Image upload
                        _buildImageUpload(),
                        const SizedBox(height: AppSpacing.spacingL),
                        // Question builder based on type
                        AnimatedSwitcher(
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
                        const SizedBox(height: AppSpacing.spacingL),
                        // Time and points
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextInput(
                                controller: _timeLimitController,
                                label: 'Time Limit (seconds)',
                                hint: '20',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icon(Icons.timer_outlined),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spacingM),
                            Expanded(
                              child: CustomTextInput(
                                controller: _pointsController,
                                label: 'Points',
                                hint: '100',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icon(Icons.star_outline),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    PrimaryButton(
                      onPressed: _saveQuestion,
                      text: widget.existingQuestion != null
                          ? 'Update Question'
                          : 'Add Question',
                      backgroundColor: AppColors.vibrantPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Type',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: AppSpacing.spacingS),
        Row(
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
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.coolGray,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Text(
              label,
              style: AppTextStyles.buttonMedium.copyWith(
                color: isSelected ? color : AppColors.coolGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGray,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image_outlined,
            color: AppColors.coolGray,
          ),
          const SizedBox(width: AppSpacing.spacingM),
          Expanded(
            child: Text(
              _imageUrl != null
                  ? 'Image uploaded'
                  : 'Add image (optional)',
              style: AppTextStyles.bodyText.copyWith(
                color: _imageUrl != null
                    ? AppColors.vibrantPurple
                    : AppColors.coolGray,
              ),
            ),
          ),
          TextButton(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}