/// Central export file for all UI constants
/// This file provides a single import point for all design system constants
library;

///
/// Usage:
/// ```dart
/// import 'package:quiz_app/shared/constants/app_constants.dart';
///
/// // Now you can use:
/// AppColors.vibrantPurple
/// AppTextStyles.gameTitle
/// AppSpacing.spacingM
/// AppDimensions.cardBorderRadius
/// AppAnimations.shortAnimation
/// ```

// Export all constant files
export 'app_colors.dart';
export 'app_text_styles.dart';
export 'app_spacing.dart';
export 'app_dimensions.dart';
export 'app_animations.dart';

// Also export theme for convenience
export '../theme/app_theme.dart';
