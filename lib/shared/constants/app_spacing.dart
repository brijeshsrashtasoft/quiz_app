import 'package:flutter/material.dart';

/// Spacing constants following 8dp grid system
/// Reference: docs/ui_guideline.md - Best Practices section
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (8dp) - foundation of Material Design

  // Spacing constants following 8dp grid
  static const double spacingXS = 4.0; // _baseUnit * 0.5
  static const double spacingS = 8.0; // _baseUnit * 1
  static const double spacingM = 16.0; // _baseUnit * 2
  static const double spacingL = 24.0; // _baseUnit * 3
  static const double spacingXL = 32.0; // _baseUnit * 4
  static const double spacingXXL = 48.0; // _baseUnit * 6

  // Component-specific spacing
  static const double cardPadding = 24.0; // Question cards, content cards
  static const double cardMargin = spacingM; // Space between cards
  static const double buttonPadding = spacingM; // Internal button padding
  static const double buttonSpacing = spacingS; // Space between buttons
  static const double inputPadding = spacingM; // Text field internal padding
  static const double screenPadding = spacingL; // Screen edge padding
  static const double sectionSpacing = spacingXL; // Between major sections

  // Layout spacing for different screen densities
  static const double listItemSpacing = spacingS; // Between list items
  static const double headerSpacing = spacingL; // Below headers
  static const double paragraphSpacing = spacingM; // Between paragraphs
  static const double iconTextSpacing = spacingS; // Icon to text spacing
  static const double tabletSpacing = spacingXL; // Extra spacing for tablets
  static const double desktopSpacing = spacingXXL; // Extra spacing for desktop

  // Game-specific spacing
  static const double answerButtonSpacing = spacingM; // Between answer buttons
  static const double timerSpacing = spacingL; // Around timer component
  static const double scoreSpacing = spacingM; // Around score displays
  static const double leaderboardItemSpacing =
      spacingS; // Between leaderboard items
  static const double questionSpacing = spacingXL; // Between questions
  static const double gameControlSpacing = spacingL; // Game control elements

  // Responsive spacing helpers
  static double responsiveSpacing(double screenWidth) {
    if (screenWidth < 600) return spacingM; // Mobile
    if (screenWidth < 1200) return spacingL; // Tablet
    return spacingXL; // Desktop
  }

  static double responsivePadding(double screenWidth) {
    if (screenWidth < 600) return spacingM; // Mobile
    if (screenWidth < 900) return spacingL; // Small tablet
    if (screenWidth < 1200) return spacingXL; // Large tablet
    return spacingXXL; // Desktop
  }

  // Container spacing for different layouts
  static const double containerPaddingSmall = spacingM;
  static const double containerPaddingMedium = spacingL;
  static const double containerPaddingLarge = spacingXL;

  // Animation and interaction spacing
  static const double rippleRadius = 28.0; // Material ripple effect
  static const double fabSpacing = spacingL; // FAB positioning
  static const double snackbarSpacing = spacingM; // Snackbar margins
  static const double dialogPadding = spacingL; // Dialog content padding
  static const double bottomSheetPadding = spacingL; // Bottom sheet padding

  // Accessibility spacing (larger touch targets)
  static const double minTouchTarget = 48.0; // Minimum touch target size
  static const double accessibleSpacing =
      spacingL; // Enhanced spacing for accessibility
  static const double accessiblePadding =
      spacingXL; // Larger padding for accessibility mode

  // Border and divider spacing
  static const double dividerSpacing = spacingM; // Space around dividers
  static const double borderSpacing = spacingXS; // Small spacing for borders

  // Grid and layout spacing
  static const double gridSpacing = spacingM; // Grid item spacing
  static const double columnSpacing = spacingL; // Column spacing in layouts
  static const double rowSpacing = spacingM; // Row spacing in layouts

  // Form and input spacing
  static const double formFieldSpacing = spacingL; // Between form fields
  static const double formSectionSpacing = spacingXL; // Between form sections
  static const double labelSpacing = spacingS; // Label to input spacing
  static const double errorSpacing = spacingXS; // Error message spacing

  // Navigation spacing
  static const double navBarPadding = spacingM; // Navigation bar padding
  static const double tabSpacing = spacingL; // Tab spacing
  static const double drawerPadding = spacingM; // Navigation drawer padding

  // Content spacing for readability
  static const double contentMaxWidth =
      800.0; // Maximum content width for readability
  static const double contentSpacing =
      spacingL; // Spacing within content blocks

  // Safe area and status bar spacing
  static const double statusBarHeight = 24.0; // Typical status bar height
  static const double safeAreaPadding =
      spacingM; // Additional safe area padding

  // Convenience methods for common spacing combinations
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets buttonPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: buttonPadding,
  );
  static const EdgeInsets inputPaddingAll = EdgeInsets.all(inputPadding);

  // Symmetric spacing helpers
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(
    horizontal: spacingM,
  );
  static const EdgeInsets verticalM = EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets horizontalL = EdgeInsets.symmetric(
    horizontal: spacingL,
  );
  static const EdgeInsets verticalL = EdgeInsets.symmetric(vertical: spacingL);

  // Combined spacing helpers
  static const EdgeInsets allM = EdgeInsets.all(spacingM);
  static const EdgeInsets allL = EdgeInsets.all(spacingL);
  static const EdgeInsets allXL = EdgeInsets.all(spacingXL);

  // Missing spacing properties used throughout the codebase
  static const double horizontalSpacingXS = spacingXS;
  static const double horizontalSpacingS = spacingS;
  static const double horizontalSpacingM = spacingM;
  static const double horizontalSpacingL = spacingL;
  static const double horizontalSpacingXL = spacingXL;
  static const double horizontalSpacingXXL = spacingXXL;

  static const double verticalSpacingXS = spacingXS;
  static const double verticalSpacingS = spacingS;
  static const double verticalSpacingM = spacingM;
  static const double verticalSpacingL = spacingL;
  static const double verticalSpacingXL = spacingXL;
  static const double verticalSpacingXXL = spacingXXL;

  static const double allS = spacingS;

  // Additional aliases for consistency
  static const double xs = spacingXS;
  static const double sm = spacingS;
  static const double md = spacingM;
  static const double lg = spacingL;
  static const double xl = spacingXL;
}
