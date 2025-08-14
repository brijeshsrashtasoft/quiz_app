import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class AnswerStatisticsChart extends StatefulWidget {
  const AnswerStatisticsChart({super.key});

  @override
  State<AnswerStatisticsChart> createState() => _AnswerStatisticsChartState();
}

class _AnswerStatisticsChartState extends State<AnswerStatisticsChart>
    with TickerProviderStateMixin {
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;

  // Mock statistics data
  final List<Map<String, dynamic>> _statistics = [
    {'answer': 'Earth', 'count': 5, 'percentage': 25, 'isCorrect': false},
    {'answer': 'Jupiter', 'count': 10, 'percentage': 50, 'isCorrect': true},
    {'answer': 'Saturn', 'count': 3, 'percentage': 15, 'isCorrect': false},
    {'answer': 'Mars', 'count': 2, 'percentage': 10, 'isCorrect': false},
  ];

  @override
  void initState() {
    super.initState();
    _barControllers = List.generate(
      _statistics.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
        vsync: this,
      ),
    );

    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: AppAnimations.easeOut),
      );
    }).toList();

    // Start animations
    for (int i = 0; i < _barControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _barControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getBarColor(int index, bool isCorrect) {
    if (isCorrect) return AppColors.turquoise;

    switch (index) {
      case 0:
        return AppColors.triangleRed;
      case 1:
        return AppColors.diamondGreen;
      case 2:
        return AppColors.circleYellow;
      case 3:
        return AppColors.squareTurquoise;
      default:
        return AppColors.vibrantPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
      child: Column(
        children: [
          Text('Answer Distribution', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.spacingL),

          // Total responses
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingL,
              vertical: AppSpacing.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_rounded,
                  color: AppColors.vibrantPurple,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Text(
                  '${_statistics.fold(0, (sum, s) => sum + (s['count'] as int))} Total Responses',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacingXL),

          // Bar chart
          Expanded(
            child: ListView.builder(
              itemCount: _statistics.length,
              itemBuilder: (context, index) {
                final stat = _statistics[index];
                final percentage = stat['percentage'] as int;
                final isCorrect = stat['isCorrect'] as bool;

                return AnimatedBuilder(
                  animation: _barAnimations[index],
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppSpacing.spacingL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Answer text and count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      stat['answer'] as String,
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontWeight: isCorrect
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    if (isCorrect) ...[
                                      const SizedBox(
                                        width: AppSpacing.spacingS,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.spacingS,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.turquoise,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          'CORRECT',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.pureWhite,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '${stat['count']} players',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.spacingS),

                          // Progress bar
                          Stack(
                            children: [
                              // Background
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGray.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              // Filled bar
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 32,
                                width:
                                    MediaQuery.of(context).size.width *
                                    (percentage / 100) *
                                    _barAnimations[index].value *
                                    0.7, // Max 70% width
                                decoration: BoxDecoration(
                                  color: _getBarColor(index, isCorrect),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getBarColor(
                                        index,
                                        isCorrect,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$percentage%',
                                    style: AppTextStyles.bodyText.copyWith(
                                      color: AppColors.pureWhite,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
