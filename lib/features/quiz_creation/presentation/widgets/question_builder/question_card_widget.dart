import 'package:flutter/material.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_spacing.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/constants/app_animations.dart';

/// Individual question card with drag handle
class QuestionCardWidget extends StatefulWidget {
  final int index;
  final Map<String, dynamic> question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionCardWidget({
    super.key,
    required this.index,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<QuestionCardWidget> createState() => _QuestionCardWidgetState();
}

class _QuestionCardWidgetState extends State<QuestionCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.buttonTapDuration,
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getQuestionTypeColor() {
    switch (widget.question['type']) {
      case 'multiple_choice':
        return AppColors.vibrantPurple;
      case 'true_false':
        return AppColors.turquoise;
      default:
        return AppColors.coolGray;
    }
  }

  IconData _getQuestionTypeIcon() {
    switch (widget.question['type']) {
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'true_false':
        return Icons.toggle_on;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleController,
        child: AnimatedContainer(
          duration: AppAnimations.shortAnimation,
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? _getQuestionTypeColor().withOpacity(0.3)
                  : AppColors.lightGray,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _getQuestionTypeColor().withOpacity(0.1)
                    : AppColors.shadowLight.withOpacity(0.05),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onEdit,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                child: Row(
                  children: [
                    // Drag handle
                    Icon(
                      Icons.drag_indicator,
                      color: AppColors.coolGray,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    // Question number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getQuestionTypeColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: _getQuestionTypeColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    // Question content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getQuestionTypeIcon(),
                                size: 16,
                                color: _getQuestionTypeColor(),
                              ),
                              const SizedBox(width: AppSpacing.spacingXS),
                              Text(
                                widget.question['type'] == 'multiple_choice'
                                    ? 'Multiple Choice'
                                    : 'True/False',
                                style: AppTextStyles.caption.copyWith(
                                  color: _getQuestionTypeColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            widget.question['question'],
                            style: AppTextStyles.bodyText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.spacingS),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.timer_outlined,
                                '${widget.question['timeLimit']}s',
                                AppColors.timeWarning,
                              ),
                              const SizedBox(width: AppSpacing.spacingS),
                              _buildInfoChip(
                                Icons.star_outline,
                                '${widget.question['points']} pts',
                                AppColors.warmYellow,
                              ),
                              const SizedBox(width: AppSpacing.spacingS),
                              _buildInfoChip(
                                Icons.format_list_numbered,
                                '${widget.question['options'].length} options',
                                AppColors.mintGreen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.coolGray,
                          tooltip: 'Edit question',
                        ),
                        IconButton(
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.coralRed,
                          tooltip: 'Delete question',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingS,
        vertical: AppSpacing.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.spacingXS),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}