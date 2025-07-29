import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system following Kahoot-style design hierarchy
/// Reference: docs/ui_guideline.md
class AppTextStyles {
  AppTextStyles._();

  // Base font family - Inter or system font with fallbacks
  static const String _fontFamily = 'Inter';
  static const List<String> _fontFamilyFallback = ['Roboto', 'SF Pro Display'];

  // Game Title - Main screen headers
  static const TextStyle gameTitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2,
    color: AppColors.charcoal,
    letterSpacing: -0.5,
  );

  static const TextStyle gameTitleDark = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.darkPrimaryText,
    letterSpacing: -0.5,
  );

  // Section Headers - Category titles
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.3,
    color: AppColors.charcoal,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionHeaderDark = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.darkPrimaryText,
    letterSpacing: -0.3,
  );

  // Question Text - Quiz questions
  static const TextStyle questionText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w500, // Medium
    height: 1.4,
    color: AppColors.charcoal,
    letterSpacing: -0.2,
  );

  static const TextStyle questionTextDark = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.darkPrimaryText,
    letterSpacing: -0.2,
  );

  // Answer Options - Multiple choice text
  static const TextStyle answerOption = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.charcoal,
    letterSpacing: -0.1,
  );

  static const TextStyle answerOptionDark = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.darkPrimaryText,
    letterSpacing: -0.1,
  );

  // Body Text - Instructions, descriptions
  static const TextStyle bodyText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.charcoal,
    letterSpacing: 0,
  );

  static const TextStyle bodyTextDark = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.darkPrimaryText,
    letterSpacing: 0,
  );

  // Caption/Hints - Secondary information
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.coolGray,
    letterSpacing: 0.1,
  );

  static const TextStyle captionDark = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.darkSecondaryText,
    letterSpacing: 0.1,
  );

  // Timer Display - Countdown numbers
  static const TextStyle timerDisplay = TextStyle(
    fontFamily: 'monospace',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.vibrantPurple,
    letterSpacing: -1.0,
  );

  static const TextStyle timerDisplayWarning = TextStyle(
    fontFamily: 'monospace',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.coralRed,
    letterSpacing: -1.0,
  );

  // Score Display - Points, rankings
  static const TextStyle scoreDisplay = TextStyle(
    fontFamily: 'monospace',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.vibrantPurple,
    letterSpacing: -0.8,
  );

  static const TextStyle scoreDisplayGold = TextStyle(
    fontFamily: 'monospace',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.achievement,
    letterSpacing: -0.8,
  );

  // Button Text Styles
  static const TextStyle buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.pureWhite,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.pureWhite,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.pureWhite,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.pureWhite,
    letterSpacing: 0.1,
  );

  // Input Field Text Styles
  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.charcoal,
    letterSpacing: 0,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.coolGray,
    letterSpacing: 0,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.charcoal,
    letterSpacing: 0.1,
  );

  // Special Text Styles
  static const TextStyle leaderboardRank = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.vibrantPurple,
    letterSpacing: -0.2,
  );

  static const TextStyle achievementText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.achievement,
    letterSpacing: 0.1,
  );

  static const TextStyle errorText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.error,
    letterSpacing: 0.1,
  );

  static const TextStyle successText = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.success,
    letterSpacing: 0.1,
  );

  // Accessibility enhanced text styles (larger sizes)
  static const TextStyle gameTitle_Accessible = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.charcoal,
    letterSpacing: -0.6,
  );

  static const TextStyle bodyText_Accessible = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.charcoal,
    letterSpacing: 0,
  );

  // Card Text Styles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.charcoal,
    letterSpacing: -0.2,
  );

  static const TextStyle cardDescription = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.coolGray,
    letterSpacing: 0,
  );

  // Context-specific text styles with semantic meaning
  static TextStyle getScoreStyle(int score) {
    if (score >= 10000) return scoreDisplayGold;
    return scoreDisplay;
  }

  static TextStyle getTimerStyle(int timeLeft) {
    if (timeLeft <= 5) return timerDisplayWarning;
    return timerDisplay;
  }

  static TextStyle getRankStyle(int rank) {
    switch (rank) {
      case 1:
        return leaderboardRank.copyWith(color: AppColors.achievement);
      case 2:
        return leaderboardRank.copyWith(color: const Color(0xFFC0C0C0));
      case 3:
        return leaderboardRank.copyWith(color: const Color(0xFFCD7F32));
      default:
        return leaderboardRank;
    }
  }
}
