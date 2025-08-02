import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../providers/quiz_creation_provider.dart';

/// Quiz metadata form for title, description, and category
class QuizMetadataForm extends ConsumerStatefulWidget {
  const QuizMetadataForm({super.key});

  @override
  ConsumerState<QuizMetadataForm> createState() => _QuizMetadataFormState();
}

class _QuizMetadataFormState extends ConsumerState<QuizMetadataForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'General Knowledge';

  @override
  void initState() {
    super.initState();
    // Add listeners to update provider state when text changes
    _titleController.addListener(_updateProviderState);
    _descriptionController.addListener(_updateProviderState);
  }

  final List<String> _categories = [
    'General Knowledge',
    'Science',
    'History',
    'Geography',
    'Literature',
    'Entertainment',
    'Sports',
    'Technology',
    'Art & Culture',
    'Mathematics',
  ];

  @override
  void dispose() {
    _titleController.removeListener(_updateProviderState);
    _descriptionController.removeListener(_updateProviderState);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Update provider state when form fields change
  void _updateProviderState() {
    ref.read(quizCreationProvider.notifier).updateMetadata(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final maxFormHeight = isSmallScreen
        ? screenHeight * 0.6
        : screenHeight * 0.7;

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
                maxHeight: maxFormHeight,
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
                      Text(
                        'Quiz Information',
                        style: AppTextStyles.sectionHeader,
                      ),
                      const SizedBox(height: AppSpacing.spacingL),
                      // Title input
                      CustomTextInput(
                        controller: _titleController,
                        label: 'Quiz Title',
                        hint: 'Enter an engaging title for your quiz',
                        maxLength: 100,
                        prefixIcon: const Icon(Icons.title),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.spacingL),
                      // Description input
                      CustomTextInput(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe what your quiz is about',
                        maxLines: isSmallScreen ? 2 : 3,
                        maxLength: 300,
                        prefixIcon: const Icon(Icons.description_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.spacingL),
                      // Category dropdown
                      _buildCategoryDropdown(),
                      const SizedBox(height: AppSpacing.spacingXL),
                      // Quiz preview card
                      _buildPreviewCard(),
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

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.spacingS),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingM,
                vertical: AppSpacing.spacingM,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.category_outlined,
                color: AppColors.coolGray,
              ),
            ),
            style: AppTextStyles.inputText,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.coolGray),
            items: _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
              _updateProviderState(); // Update provider when category changes
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(AppSpacing.spacingL),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: AppColors.vibrantPurple,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                  Expanded(
                    child: Text(
                      'Preview',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.vibrantPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                _titleController.text.isEmpty
                    ? 'Your quiz title will appear here'
                    : _titleController.text,
                style: _titleController.text.isEmpty
                    ? AppTextStyles.cardTitle.copyWith(
                        color: AppColors.coolGray,
                        fontStyle: FontStyle.italic,
                      )
                    : AppTextStyles.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                _descriptionController.text.isEmpty
                    ? 'Your quiz description will appear here'
                    : _descriptionController.text,
                style: _descriptionController.text.isEmpty
                    ? AppTextStyles.cardDescription.copyWith(
                        fontStyle: FontStyle.italic,
                      )
                    : AppTextStyles.cardDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacingM,
                      vertical: AppSpacing.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.vibrantPurple,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
