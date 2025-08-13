import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import '../../../quiz_creation/domain/entities/question_entities.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/widgets/primitives/app_card.dart';
import 'answer_statistics_chart.dart';

/// Answer reveal display with animations and statistics
/// Following Kahoot-style design from docs/ui_guideline.md
class AnswerRevealDisplay extends ConsumerWidget {
  final Question question;
  final Map<String, PlayerEntity> players;
  final Map<String, int> playerAnswers;
  final VoidCallback? onContinue;
  final bool isHost;

  const AnswerRevealDisplay({
    super.key,
    required this.question,
    required this.players,
    required this.playerAnswers,
    this.onContinue,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answerStats = _calculateAnswerStatistics();

    return Column(
      children: [
        // Correct answer reveal
        _buildCorrectAnswerCard(context)
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: AppAnimations.mediumAnimation,
              curve: AppAnimations.elastic,
            )
            .fadeIn(duration: AppAnimations.mediumAnimation),

        SizedBox(height: AppSpacing.spacingL),

        // Answer statistics
        _buildStatisticsSection(answerStats)
            .animate()
            .slideY(
              begin: 0.1,
              end: 0,
              delay: AppAnimations.staggerDelay,
              duration: AppAnimations.mediumAnimation,
              curve: AppAnimations.easeOut,
            )
            .fadeIn(
              delay: AppAnimations.staggerDelay,
              duration: AppAnimations.mediumAnimation,
            ),

        SizedBox(height: AppSpacing.spacingL),

        // Top scorers
        _buildTopScorersSection()
            .animate()
            .slideY(
              begin: 0.1,
              end: 0,
              delay: AppAnimations.staggerDelay * 2,
              duration: AppAnimations.mediumAnimation,
              curve: AppAnimations.easeOut,
            )
            .fadeIn(
              delay: AppAnimations.staggerDelay * 2,
              duration: AppAnimations.mediumAnimation,
            ),

        if (isHost && onContinue != null) ...[
          SizedBox(height: AppSpacing.spacingXL),
          _buildContinueButton().animate().scale(
            begin: const Offset(0.0, 0.0),
            end: const Offset(1.0, 1.0),
            delay: const Duration(seconds: 2),
            duration: AppAnimations.mediumAnimation,
            curve: AppAnimations.bounce,
          ),
        ],
      ],
    );
  }

  Widget _buildCorrectAnswerCard(BuildContext context) {
    final correctAnswerText = question.when(
      multipleChoice:
          (_, __, options, correctIndex, ___, ____, _____, ______) =>
              options[correctIndex],
      trueFalse: (_, __, correctAnswer, ___, ____, _____, ______) =>
          correctAnswer ? 'True' : 'False',
    );

    return AppCard(
      backgroundColor: AppColors.turquoise,
      padding: EdgeInsets.all(AppSpacing.spacingXL),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.pureWhite,
                    size: 32,
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
                    duration: AppAnimations.longAnimation,
                    curve: AppAnimations.easeInOut,
                  ),
              SizedBox(width: AppSpacing.spacingM),
              Text(
                'Correct Answer',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.pureWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.spacingM),
          Text(
            correctAnswerText,
            style: AppTextStyles.questionText.copyWith(
              color: AppColors.pureWhite,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          if (question.questionExplanation != null) ...[
            SizedBox(height: AppSpacing.spacingM),
            Container(
              padding: EdgeInsets.all(AppSpacing.spacingM),
              decoration: BoxDecoration(
                color: AppColors.pureWhite.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusM,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.pureWhite,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.spacingS),
                  Expanded(
                    child: Text(
                      question.questionExplanation!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(Map<int, int> answerStats) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Answer Distribution', style: AppTextStyles.sectionSubheader),
          SizedBox(height: AppSpacing.spacingM),
          const AnswerStatisticsChart(),
        ],
      ),
    );
  }

  Widget _buildTopScorersSection() {
    // Get players who answered correctly
    final correctAnswerIndex = question.correctAnswerIndex;
    final correctPlayers = playerAnswers.entries
        .where((entry) => entry.value == correctAnswerIndex)
        .map((entry) => MapEntry(entry.key, players[entry.key]))
        .where((entry) => entry.value != null)
        .toList();

    if (correctPlayers.isEmpty) {
      return AppCard(
        padding: EdgeInsets.all(AppSpacing.spacingL),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 48,
                color: AppColors.coolGray,
              ),
              SizedBox(height: AppSpacing.spacingM),
              Text(
                'No one got it right!',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort by score (those who answered fastest get more points)
    correctPlayers.sort(
      (a, b) => (b.value?.score ?? 0).compareTo(a.value?.score ?? 0),
    );

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: AppColors.warmYellow,
                size: 24,
              ),
              SizedBox(width: AppSpacing.spacingS),
              Text(
                'Fastest Correct Answers',
                style: AppTextStyles.sectionSubheader,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.spacingM),
          ...correctPlayers.take(5).mapIndexed((index, entry) {
            final player = entry.value!;
            final delay = Duration(milliseconds: 100 * index);

            return _buildTopScorerItem(
                  rank: index + 1,
                  playerName: player.name,
                  points: question.questionPoints,
                )
                .animate()
                .slideX(
                  begin: 0.2,
                  end: 0,
                  delay: delay,
                  duration: AppAnimations.mediumAnimation,
                  curve: AppAnimations.easeOut,
                )
                .fadeIn(delay: delay, duration: AppAnimations.mediumAnimation);
          }),
        ],
      ),
    );
  }

  Widget _buildTopScorerItem({
    required int rank,
    required String playerName,
    required int points,
  }) {
    final medalColors = [
      AppColors.achievement,
      AppColors.coolGray,
      AppColors.coralRed.withValues(alpha: 0.7),
    ];

    final showMedal = rank <= 3;
    final medalColor = showMedal ? medalColors[rank - 1] : AppColors.coolGray;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.spacingS),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingS,
      ),
      decoration: BoxDecoration(
        color: rank == 1
            ? AppColors.achievement.withValues(alpha: 0.1)
            : AppColors.offWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        border: rank == 1
            ? Border.all(
                color: AppColors.achievement.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          if (showMedal)
            Icon(Icons.military_tech_rounded, color: medalColor, size: 24)
          else
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGray,
              ),
              child: Text(
                rank.toString(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(width: AppSpacing.spacingM),
          Expanded(
            child: Text(
              playerName,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: rank == 1 ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '+$points',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.correctAnswer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: onContinue,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vibrantPurple,
        foregroundColor: AppColors.pureWhite,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingXL,
          vertical: AppSpacing.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Next Question', style: AppTextStyles.buttonLarge),
          SizedBox(width: AppSpacing.spacingS),
          Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }

  Map<int, int> _calculateAnswerStatistics() {
    final stats = <int, int>{};

    // Initialize with all possible answers
    final optionCount = question.options.length;
    for (int i = 0; i < optionCount; i++) {
      stats[i] = 0;
    }

    // Count actual answers
    for (final answer in playerAnswers.values) {
      if (answer >= 0 && answer < optionCount) {
        stats[answer] = (stats[answer] ?? 0) + 1;
      }
    }

    return stats;
  }
}
