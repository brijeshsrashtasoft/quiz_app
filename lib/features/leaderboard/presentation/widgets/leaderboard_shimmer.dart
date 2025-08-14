import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';

class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 10,
        itemBuilder: (context, index) => _buildShimmerItem(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 16,
                  child: Container(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: 80,
                  height: 12,
                  child: Container(color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 60,
                height: 20,
                child: Container(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: 40,
                height: 12,
                child: Container(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
