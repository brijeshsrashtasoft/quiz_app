import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';

/// Individual quiz item in the management list
class QuizListItem extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const QuizListItem({
    super.key,
    required this.quiz,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  State<QuizListItem> createState() => _QuizListItemState();
}

class _QuizListItemState extends State<QuizListItem>
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _scaleController.animateTo(0.98),
        onTapUp: (_) => _scaleController.animateTo(1.0),
        onTapCancel: () => _scaleController.animateTo(1.0),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleController,
          child: AnimatedContainer(
            duration: AppAnimations.shortAnimation,
            margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? AppColors.vibrantPurple.withValues(alpha: 0.3)
                    : AppColors.lightGray,
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.vibrantPurple.withValues(alpha: 0.1)
                      : AppColors.shadowLight.withValues(alpha: 0.05),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingL),
              child: Column(
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quiz info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.quiz['title'],
                                  style: AppTextStyles.cardTitle,
                                ),
                                const SizedBox(width: AppSpacing.spacingS),
                                if (!(widget.quiz['isPublic'] as bool))
                                  Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: AppColors.coolGray,
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.spacingXS),
                            Text(
                              widget.quiz['description'],
                              style: AppTextStyles.cardDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.spacingM),
                            // Tags row
                            Wrap(
                              spacing: AppSpacing.spacingS,
                              runSpacing: AppSpacing.spacingS,
                              children: [
                                _buildTag(
                                  widget.quiz['category'],
                                  AppColors.vibrantPurple,
                                  Icons.category_outlined,
                                ),
                                _buildTag(
                                  '${widget.quiz['questions']} questions',
                                  AppColors.mintGreen,
                                  Icons.quiz_outlined,
                                ),
                                _buildTag(
                                  _formatDate(widget.quiz['createdAt']),
                                  AppColors.coolGray,
                                  Icons.access_time,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Actions menu
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: AppColors.coolGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              widget.onEdit();
                              break;
                            case 'share':
                              widget.onShare();
                              break;
                            case 'delete':
                              widget.onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.charcoal,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.spacingM),
                                Text('Edit', style: AppTextStyles.bodyText),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.share_outlined,
                                  color: AppColors.charcoal,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.spacingM),
                                Text('Share', style: AppTextStyles.bodyText),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: AppColors.coralRed,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.spacingM),
                                Text(
                                  'Delete',
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: AppColors.coralRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.spacingM),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        Icons.play_circle_outline,
                        widget.quiz['plays'].toString(),
                        'Plays',
                        AppColors.turquoise,
                      ),
                      _buildStat(
                        Icons.star_outline,
                        widget.quiz['rating'].toString(),
                        'Rating',
                        AppColors.warmYellow,
                      ),
                      _buildStat(
                        Icons.timer_outlined,
                        '${(widget.quiz['questions'] as int) * 20}s',
                        'Duration',
                        AppColors.timeWarning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.spacingXS),
            Text(
              value,
              style: AppTextStyles.cardTitle.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingXS),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
