/// Component dimensions following Kahoot-style design system
/// Reference: docs/ui_guideline.md - UI Components section
class AppDimensions {
  AppDimensions._();

  // Border Radius - consistent rounded corners
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;
  static const double borderRadiusFull = 100.0; // Circular elements

  // Component-specific border radius
  static const double cardBorderRadius = borderRadiusL; // 16dp - Question cards
  static const double cardRadius = cardBorderRadius; // Alias for compatibility
  static const double buttonBorderRadius =
      borderRadiusM; // 12dp - Answer buttons
  static const double buttonRadius =
      buttonBorderRadius; // Alias for compatibility
  static const double inputBorderRadius = borderRadiusS; // 8dp - Text inputs
  static const double inputRadius =
      inputBorderRadius; // Alias for compatibility
  static const double containerBorderRadius =
      borderRadiusM; // 12dp - General containers

  // Button Dimensions
  static const double answerButtonHeight =
      80.0; // Minimum height for answer buttons
  static const double buttonHeight = 56.0; // Standard button height
  static const double primaryButtonHeight =
      56.0; // Standard primary button height
  static const double secondaryButtonHeight = 48.0; // Secondary button height
  static const double fabSize = 56.0; // Floating action button size
  static const double iconButtonSize = 48.0; // Icon button touch target

  // Card Dimensions
  static const double questionCardMinHeight =
      200.0; // Minimum question card height
  static const double playerCardHeight = 80.0; // Player card in leaderboard
  static const double scoreCardHeight = 120.0; // Score display card
  static const double achievementCardHeight =
      100.0; // Achievement notification card

  // Timer Component
  static const double timerSize = 80.0; // 80x80dp circular timer
  static const double timerStrokeWidth = 6.0; // Progress ring width
  static const double miniTimerSize = 40.0; // Small timer variant
  static const double miniTimerStrokeWidth = 3.0; // Small timer stroke

  // Progress Components
  static const double progressBarHeight = 6.0; // Main progress bar height
  static const double progressBarMinHeight = 4.0; // Minimum progress bar height
  static const double progressIndicatorSize =
      24.0; // Circular progress indicator

  // Input Field Dimensions
  static const double inputHeight = 56.0; // Standard input field height
  static const double inputHeightSmall = 48.0; // Compact input field height
  static const double inputHeightLarge = 64.0; // Large input field height
  static const double pinCodeInputSize = 56.0; // PIN code input boxes
  static const double searchInputHeight = 48.0; // Search input height

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Game-specific icon sizes
  static const double answerIconSize = iconL; // Icons in answer buttons
  static const double statusIconSize = iconM; // Status indicators
  static const double navigationIconSize = iconM; // Navigation icons
  static const double achievementIconSize = iconXL; // Achievement icons

  // Elevation and Shadow
  static const double elevationLow = 2.0; // Subtle elevation
  static const double elevationMedium = 4.0; // Standard elevation
  static const double elevationHigh = 8.0; // Prominent elevation
  static const double elevationOverlay = 16.0; // Modal/overlay elevation

  // Component elevations
  static const double cardElevation = elevationMedium; // Question cards
  static const double buttonElevation = elevationLow; // Button elevation
  static const double fabElevation = elevationHigh; // FAB elevation
  static const double modalElevation = elevationOverlay; // Modal dialogs

  // Layout Dimensions
  static const double appBarHeight = 56.0; // Standard app bar height
  static const double tabBarHeight = 48.0; // Tab bar height
  static const double bottomNavHeight = 64.0; // Bottom navigation height
  static const double drawerWidth = 320.0; // Navigation drawer width

  // Screen Breakpoints
  static const double mobileBreakpoint = 600.0; // Mobile to tablet breakpoint
  static const double tabletBreakpoint = 900.0; // Tablet to desktop breakpoint
  static const double desktopBreakpoint = 1200.0; // Desktop breakpoint

  // Content Width Constraints
  static const double maxContentWidth =
      800.0; // Maximum content width for readability
  static const double maxFormWidth = 400.0; // Maximum form width
  static const double maxCardWidth = 600.0; // Maximum card width

  // Accessibility Dimensions
  static const double minTouchTarget = 48.0; // Minimum touch target (WCAG)
  static const double recommendedTouchTarget = 56.0; // Recommended touch target
  static const double accessibleButtonHeight = 56.0; // Accessible button height

  // Game Layout Dimensions
  static const double gameHeaderHeight = 120.0; // Game screen header
  static const double leaderboardItemHeight = 64.0; // Leaderboard item height
  static const double questionContainerMinHeight =
      240.0; // Question container minimum height
  static const double answerGridSpacing = 16.0; // Space between answer options

  // Loading & Empty State Dimensions
  static const double loadingIndicatorSize = 32.0; // Loading spinner size
  static const double emptyStateIconSize =
      96.0; // Empty state illustration size
  static const double avatarSizeSmall = 32.0; // Small user avatar
  static const double avatarSizeMedium = 48.0; // Medium user avatar
  static const double avatarSizeLarge = 64.0; // Large user avatar

  // Border Widths
  static const double borderWidthThin = 1.0; // Thin borders
  static const double borderWidthMedium = 2.0; // Medium borders
  static const double borderWidthThick = 4.0; // Thick borders (focus states)

  // Component border widths
  static const double inputBorderWidth = borderWidthThin;
  static const double buttonBorderWidth = borderWidthMedium;
  static const double activeBorderWidth = borderWidthThick;
  static const double dividerWidth = borderWidthThin;

  // Responsive dimension helpers
  static double responsiveWidth(
    double screenWidth, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    if (screenWidth < mobileBreakpoint) return screenWidth * mobile;
    if (screenWidth < desktopBreakpoint) return screenWidth * tablet;
    return screenWidth * desktop;
  }

  static double responsiveHeight(
    double screenHeight, {
    double mobile = 1.0,
    double tablet = 0.9,
    double desktop = 0.8,
  }) {
    if (screenHeight < 700) return screenHeight * mobile;
    if (screenHeight < 1000) return screenHeight * tablet;
    return screenHeight * desktop;
  }

  // Component sizing based on screen size
  static double getButtonHeight(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return primaryButtonHeight;
    return primaryButtonHeight + 8.0; // Slightly larger on tablets/desktop
  }

  static double getCardPadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return 16.0;
    if (screenWidth < desktopBreakpoint) return 24.0;
    return 32.0;
  }

  static double getIconSize(double screenWidth) {
    if (screenWidth < mobileBreakpoint) return iconM;
    return iconL;
  }

  // Animation dimensions
  static const double scaleAnimationFactor = 0.95; // Button press scale
  static const double slideAnimationDistance =
      300.0; // Slide transition distance
  static const double rotationAnimationAngle = 0.1; // Rotation animation angle

  // Layout constraints
  static const double minScreenPadding = 16.0; // Minimum screen edge padding
  static const double maxScreenPadding = 48.0; // Maximum screen edge padding
  static const double contentMargin = 24.0; // Content margin from edges
  static const double sectionSpacing = 32.0; // Space between major sections
}
