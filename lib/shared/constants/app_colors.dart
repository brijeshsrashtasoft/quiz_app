import 'package:flutter/material.dart';

/// App color palette following Kahoot-style design system
/// Reference: docs/ui_guideline.md
class AppColors {
  AppColors._();

  // Primary Brand Colors - vibrant and engaging
  static const Color vibrantPurple = Color(0xFF6C5CE7);
  static const Color turquoise = Color(0xFF00D2D3);
  static const Color coralRed = Color(0xFFFF6B6B);
  static const Color mintGreen = Color(0xFF4ECDC4);
  static const Color warmYellow = Color(0xFFFFE66D);

  // Answer Button Colors - each shape has unique color psychology
  static const Color triangleRed = Color(0xFFFF6B6B); // Sharp, decisive, bold
  static const Color diamondGreen = Color(
    0xFF4ECDC4,
  ); // Balanced, valuable, unique
  static const Color circleYellow = Color(
    0xFFFFE66D,
  ); // Complete, unified, friendly
  static const Color squareTurquoise = Color(
    0xFF00D2D3,
  ); // Stable, trustworthy, solid

  // Neutral Colors - balanced and accessible
  static const Color charcoal = Color(0xFF2D3436);
  static const Color coolGray = Color(0xFF636E72);
  static const Color offWhite = Color(0xFFF5F3F4);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFDFE6E9);
  static const Color borderLight = Color(0xFFDFE6E9); // Border color for inputs

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkGray = Color(0xFF2D2D2D); // Alias for dark surface
  static const Color darkPrimaryText = Color(0xFFF5F3F4);
  static const Color darkSecondaryText = Color(0xFFB2BEC3);
  static const Color darkDividers = Color(0xFF3D3D3D);

  // Game State Colors
  static const Color correctAnswer = turquoise;
  static const Color incorrectAnswer = coralRed;
  static const Color timeWarning = Color(0xFFFFA500); // Orange
  static const Color achievement = Color(0xFFFFD700); // Gold
  static const Color newHighScore = vibrantPurple;

  // Power-up Colors
  static const Color doublePoints = Color(0xFFFFD700); // Gold
  static const Color timeFreeze = Color(0xFF74B9FF); // Ice Blue
  static const Color fiftyFifty = Color(0xFFA29BFE); // Purple
  static const Color skipQuestion = Color(0xFFFFA502); // Orange

  // Semantic Colors
  static const Color success = turquoise;
  static const Color error = coralRed;
  static const Color warning = timeWarning;
  static const Color info = vibrantPurple;
  static const Color disabled = Color(0xFF95A5A6);

  // Text Colors (aliases for consistency)
  static const Color textPrimary = charcoal;
  static const Color textSecondary = coolGray;
  static const Color textTertiary = Color(0xFF95A5A6);

  // Background Colors (aliases for consistency)
  static const Color backgroundPrimary = offWhite;
  static const Color background = offWhite; // Alias for theme compatibility
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = pureWhite;

  // Additional missing getters for theme compatibility
  static const Color mediumGray = Color(0xFF95A5A6);
  static const Color primary = vibrantPurple; // Primary brand color alias
  static const Color surface = pureWhite; // Surface color alias
  static const Color divider = lightGray; // Divider color alias

  // Gradient Colors for special effects
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [vibrantPurple, Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFC0C0C0), Color(0xFF95A5A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    colors: [Color(0xFFCD7F32), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Seasonal Theme Colors (Optional)
  static const Map<String, List<Color>> seasonalThemes = {
    'spring': [Color(0xFFFF69B4), Color(0xFF90EE90), Color(0xFFF0FFFF)],
    'summer': [Color(0xFF1E90FF), warmYellow, Color(0xFFE0F6FF)],
    'autumn': [Color(0xFFFFA500), Color(0xFFA0522D), Color(0xFFFAF0E6)],
    'winter': [Color(0xFF87CEEB), Color(0xFFC0C0C0), Color(0xFFF5F5F5)],
  };

  // Difficulty Theme Colors
  static const Map<String, Color> difficultyThemes = {
    'easy': Color(0xFF90EE90), // Soft Green
    'medium': vibrantPurple, // Balanced Purple
    'hard': Color(0xFFDC143C), // Intense Red
    'expert': Color(0xFF000000), // Deep Black
  };

  // Shadow Colors with opacity
  static const Color shadowLight = Color(0x266C5CE7); // Purple tint 15% opacity
  static const Color shadowDark = Color(0x40000000); // Black 25% opacity
  static const Color shadowButton = Color(0x26000000); // Black 15% opacity

  // Accessibility compliant color pairs (4.5:1 contrast ratio minimum)
  // Note: Using getters instead of const map due to Color comparison limitations
  static Color getAccessibleTextColor(Color backgroundColor) {
    if (backgroundColor == vibrantPurple) return pureWhite;
    if (backgroundColor == turquoise) return pureWhite;
    if (backgroundColor == coralRed) return pureWhite;
    if (backgroundColor == mintGreen) return charcoal;
    if (backgroundColor == warmYellow) return charcoal;
    if (backgroundColor == charcoal) return pureWhite;
    if (backgroundColor == coolGray) return pureWhite;
    if (backgroundColor == pureWhite) return charcoal;
    return charcoal; // Default to charcoal for unknown colors
  }
}
