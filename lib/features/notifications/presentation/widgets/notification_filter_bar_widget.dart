import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';

/// Filter bar widget for notifications with category and read status filters
class NotificationFilterBarWidget extends ConsumerStatefulWidget {
  final String? selectedCategory;
  final bool showOnlyUnread;
  final List<String> availableCategories;
  final Function(String?)? onCategoryChanged;
  final Function(bool)? onUnreadFilterChanged;

  const NotificationFilterBarWidget({
    super.key,
    this.selectedCategory,
    this.showOnlyUnread = false,
    required this.availableCategories,
    this.onCategoryChanged,
    this.onUnreadFilterChanged,
  });

  @override
  ConsumerState<NotificationFilterBarWidget> createState() =>
      _NotificationFilterBarWidgetState();
}

class _NotificationFilterBarWidgetState
    extends ConsumerState<NotificationFilterBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.offWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildCategoryFilters(),
          const SizedBox(height: AppSpacing.sm),
          _buildStatusFilters(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All', null),
          const SizedBox(width: AppSpacing.sm),
          ...widget.availableCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _buildCategoryChip(
                _getCategoryDisplayName(category),
                category,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = widget.selectedCategory == category;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        widget.onCategoryChanged?.call(selected ? category : null);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.vibrantPurple.withValues(alpha: 0.2),
      checkmarkColor: AppColors.vibrantPurple,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? AppColors.vibrantPurple : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.vibrantPurple : AppColors.lightGray,
          width: 1,
        ),
      ),
      elevation: isSelected ? 2 : 0,
      shadowColor: AppColors.vibrantPurple.withValues(alpha: 0.3),
    );
  }

  Widget _buildStatusFilters() {
    return Row(
      children: [
        Icon(Icons.filter_list, size: 20, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Show:',
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildToggleButton(
          'All',
          !widget.showOnlyUnread,
          () => widget.onUnreadFilterChanged?.call(false),
        ),
        const SizedBox(width: AppSpacing.xs),
        _buildToggleButton(
          'Unread',
          widget.showOnlyUnread,
          () => widget.onUnreadFilterChanged?.call(true),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vibrantPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.vibrantPurple : AppColors.lightGray,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'invites':
        return 'Invites';
      case 'social':
        return 'Social';
      case 'achievements':
        return 'Achievements';
      case 'results':
        return 'Results';
      case 'updates':
        return 'Updates';
      default:
        return category.toUpperCase();
    }
  }
}
