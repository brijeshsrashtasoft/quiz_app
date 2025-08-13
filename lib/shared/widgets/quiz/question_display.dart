import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Question display with slide transitions and animations
/// Reference: docs/ui_guideline.md - Question Cards
class QuestionDisplay extends StatefulWidget {
  final String questionText;
  final int questionNumber;
  final int totalQuestions;
  final String? imageUrl;
  final bool isVisible;
  final VoidCallback? onAnimationComplete;

  const QuestionDisplay({
    super.key,
    required this.questionText,
    required this.questionNumber,
    required this.totalQuestions,
    this.imageUrl,
    this.isVisible = true,
    this.onAnimationComplete,
  });

  @override
  State<QuestionDisplay> createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends State<QuestionDisplay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _triggerEntryAnimation();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.newQuestionDuration,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.0), // Start from bottom
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: AppAnimations.newQuestionCurve,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppAnimations.easeInOut),
    );
  }

  void _triggerEntryAnimation() {
    if (widget.isVisible) {
      _slideController.forward();
      _fadeController.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuestionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _triggerEntryAnimation();
      } else {
        _slideController.reverse();
        _fadeController.reverse();
      }
    }

    // Animate in new question
    if (widget.questionNumber != oldWidget.questionNumber) {
      _slideController.reset();
      _fadeController.reset();
      _triggerEntryAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.mobileBreakpoint;

    return Semantics(
      header: true,
      label: 'Question ${widget.questionNumber} of ${widget.totalQuestions}',
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: AppDimensions.questionCardMinHeight,
                  maxWidth: isTablet
                      ? AppDimensions.maxCardWidth
                      : double.infinity,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: AppSpacing.responsivePadding(screenWidth),
                  vertical: AppSpacing.spacingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.vibrantPurple.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Question header with progress
                    _buildQuestionHeader(),

                    // Question image (if provided)
                    if (widget.imageUrl != null) _buildQuestionImage(),

                    // Question text
                    _buildQuestionText(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.vibrantPurple.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.cardRadius),
          topRight: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Question number
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.vibrantPurple,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusFull,
              ),
            ),
            child: Text(
              '${widget.questionNumber}',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Progress indicator
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: AppSpacing.spacingM),
              child: LinearProgressIndicator(
                value: widget.questionNumber / widget.totalQuestions,
                backgroundColor: AppColors.lightGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.vibrantPurple,
                ),
                minHeight: AppDimensions.progressBarHeight,
              ),
            ),
          ),

          // Question counter text
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.spacingM),
            child: Text(
              '${widget.questionNumber}/${widget.totalQuestions}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.vibrantPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionImage() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        color: AppColors.lightGray,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        child: widget.imageUrl!.startsWith('http')
            ? Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.vibrantPurple,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: AppDimensions.iconXL,
                      color: AppColors.coolGray,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.image,
                  size: AppDimensions.iconXL,
                  color: AppColors.coolGray,
                ),
              ),
      ),
    );
  }

  Widget _buildQuestionText() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      child: Text(
        widget.questionText,
        style: AppTextStyles.questionText,
        textAlign: TextAlign.center,
        semanticsLabel: 'Question: ${widget.questionText}',
      ),
    );
  }
}

/// Compact question display for small screens
class CompactQuestionDisplay extends StatelessWidget {
  final String questionText;
  final int questionNumber;
  final int totalQuestions;

  const CompactQuestionDisplay({
    super.key,
    required this.questionText,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        border: Border.all(
          color: AppColors.vibrantPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: questionNumber / totalQuestions,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.vibrantPurple,
            ),
            minHeight: 4,
          ),
          const SizedBox(height: AppSpacing.spacingM),

          // Question text
          Text(
            questionText,
            style: AppTextStyles.questionText.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.spacingS),

          // Question counter
          Text(
            'Question $questionNumber of $totalQuestions',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
