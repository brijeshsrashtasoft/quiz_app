import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_animations.dart';

/// Quiz card component following Kahoot-style design system
/// Reference: docs/ui_guideline.md
class QuizCard extends StatefulWidget {
  final String title;
  final String description;
  final int questionCount;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? cardColor;

  const QuizCard({
    super.key,
    required this.title,
    required this.description,
    required this.questionCount,
    this.imageUrl,
    this.onTap,
    this.isSelected = false,
    this.cardColor,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.bounce,
    ));
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.cardColor ?? AppColors.pureWhite;
    final textColor = AppColors.getAccessibleTextColor(cardColor);

    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.description}. ${widget.questionCount} questions',
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                  vertical: AppSpacing.spacingS,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppColors.vibrantPurple,
                          width: 2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      offset: const Offset(0, 2),
                      blurRadius: _elevationAnimation.value,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with image or color bar
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.imageUrl == null
                            ? AppColors.vibrantPurple
                            : null,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.cardRadius),
                          topRight: Radius.circular(AppDimensions.cardRadius),
                        ),
                        image: widget.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.imageUrl == null
                          ? Center(
                              child: Icon(
                                Icons.quiz,
                                size: 48,
                                color: AppColors.pureWhite,
                              ),
                            )
                          : null,
                    ),
                    
                    // Content
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.title,
                            style: AppTextStyles.cardTitle.copyWith(
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: AppSpacing.spacingS),
                          
                          // Description
                          Text(
                            widget.description,
                            style: AppTextStyles.cardDescription.copyWith(
                              color: textColor.withOpacity(0.8),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: AppSpacing.spacingM),
                          
                          // Footer with question count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.spacingS,
                                  vertical: AppSpacing.spacingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.turquoise.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      size: 16,
                                      color: AppColors.turquoise,
                                    ),
                                    SizedBox(width: AppSpacing.spacingXS),
                                    Text(
                                      '${widget.questionCount} questions',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.turquoise,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              if (widget.isSelected)
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.spacingXS),
                                  decoration: BoxDecoration(
                                    color: AppColors.vibrantPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}