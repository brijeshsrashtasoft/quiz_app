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
  final String? difficulty;
  final String? category;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? cardColor;

  // Additional properties for quiz management
  final bool? isDraft;
  final bool? isPublic;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const QuizCard({
    super.key,
    required this.title,
    required this.description,
    required this.questionCount,
    this.difficulty,
    this.category,
    this.imageUrl,
    this.onTap,
    this.isSelected = false,
    this.cardColor,
    this.isDraft,
    this.isPublic,
    this.onEdit,
    this.onDelete,
    this.onShare,
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.bounce,
      ),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );
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

  Color _getDifficultyColor() {
    switch (widget.difficulty?.toLowerCase()) {
      case 'easy':
        return AppColors.mintGreen;
      case 'medium':
        return AppColors.warmYellow;
      case 'hard':
        return AppColors.coralRed;
      default:
        return AppColors.coolGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.cardColor ?? AppColors.pureWhite;
    final textColor = AppColors.getAccessibleTextColor(cardColor);

    return Semantics(
      button: true,
      label:
          '${widget.title}. ${widget.description}. ${widget.questionCount} questions',
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
                constraints: const BoxConstraints(
                  minHeight: 160,
                  maxHeight: 200, // Prevent excessive height
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                  vertical: AppSpacing.spacingS,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: widget.isSelected
                      ? Border.all(color: AppColors.vibrantPurple, width: 2)
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
                    // Header with image or color bar - flexible height
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
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
                                  size: 32, // Reduced from 48
                                  color: AppColors.pureWhite,
                                ),
                              )
                            : null,
                      ),
                    ),

                    // Content - flexible height
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(
                          AppSpacing.spacingS,
                        ), // Reduced from spacingM
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Flexible(
                              child: Text(
                                widget.title,
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: textColor,
                                  fontSize: 14, // Slightly smaller
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            SizedBox(height: AppSpacing.spacingXS),

                            // Description
                            Flexible(
                              child: Text(
                                widget.description,
                                style: AppTextStyles.cardDescription.copyWith(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 12, // Smaller text
                                ),
                                maxLines: 2, // Reduced from 3
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const Spacer(), // Push footer to bottom
                            // Draft/Public status badge
                            if (widget.isDraft == true ||
                                widget.isPublic != null)
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: AppSpacing.spacingXS,
                                ),
                                child: Row(
                                  children: [
                                    if (widget.isDraft == true)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.spacingXS,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warmYellow
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.warmYellow,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'DRAFT',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.warmYellow,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    else if (widget.isPublic == true)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.spacingXS,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.mintGreen
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.public,
                                              size: 10,
                                              color: AppColors.mintGreen,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              'PUBLIC',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: AppColors.mintGreen,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (widget.isPublic == false)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.spacingXS,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.coolGray.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.lock,
                                              size: 10,
                                              color: AppColors.coolGray,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              'PRIVATE',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: AppColors.coolGray,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            // Footer with metadata and actions
                            Row(
                              children: [
                                // Question count - compact version
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacingXS,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.turquoise.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.help_outline,
                                        size: 12,
                                        color: AppColors.turquoise,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '${widget.questionCount}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.turquoise,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: AppSpacing.spacingXS),

                                // Difficulty badge - compact
                                if (widget.difficulty != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.spacingXS,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor().withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.difficulty!,
                                      style: AppTextStyles.caption.copyWith(
                                        color: _getDifficultyColor(),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),

                                const Spacer(),

                                // Action buttons for management
                                if (widget.onEdit != null ||
                                    widget.onDelete != null ||
                                    widget.onShare != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.onEdit != null)
                                        GestureDetector(
                                          onTap: widget.onEdit,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.vibrantPurple
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 12,
                                              color: AppColors.vibrantPurple,
                                            ),
                                          ),
                                        ),
                                      if (widget.onEdit != null &&
                                          (widget.onDelete != null ||
                                              widget.onShare != null))
                                        SizedBox(width: 4),
                                      if (widget.onShare != null)
                                        GestureDetector(
                                          onTap: widget.onShare,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.mintGreen
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.share,
                                              size: 12,
                                              color: AppColors.mintGreen,
                                            ),
                                          ),
                                        ),
                                      if (widget.onShare != null &&
                                          widget.onDelete != null)
                                        SizedBox(width: 4),
                                      if (widget.onDelete != null)
                                        GestureDetector(
                                          onTap: widget.onDelete,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.coralRed
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.delete,
                                              size: 12,
                                              color: AppColors.coralRed,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                else
                                // Selected indicator - compact (only if no action buttons)
                                if (widget.isSelected)
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.vibrantPurple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 12,
                                      color: AppColors.pureWhite,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
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
