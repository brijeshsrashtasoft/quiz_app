import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// Dark theme configuration following Kahoot-style design system
/// Reference: docs/ui_guideline.md
class DarkTheme {
  DarkTheme._();

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Dark mode color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.vibrantPurple,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.turquoise,
        onSecondary: AppColors.pureWhite,
        tertiary: AppColors.mintGreen,
        onTertiary: AppColors.charcoal,
        error: AppColors.coralRed,
        onError: AppColors.pureWhite,
        surface: AppColors.darkGray,
        onSurface: AppColors.pureWhite,
        surfaceContainerLowest: AppColors.charcoal,
        outline: AppColors.mediumGray,
        outlineVariant: AppColors.darkGray,
        shadow: AppColors.shadowDark,
      ),

      // Scaffold configuration
      scaffoldBackgroundColor: AppColors.charcoal,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkGray,
        foregroundColor: AppColors.pureWhite,
        elevation: AppDimensions.elevationMedium,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.appBarTitle,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonLabel,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.caption,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantPurple,
          foregroundColor: AppColors.pureWhite,
          elevation: AppDimensions.elevationMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: AppTextStyles.buttonLabel,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vibrantPurple,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          textStyle: AppTextStyles.buttonLabel,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vibrantPurple,
          side: const BorderSide(color: AppColors.vibrantPurple, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: AppTextStyles.buttonLabel,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.darkGray,
        elevation: AppDimensions.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingSmall),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.vibrantPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.coralRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.coralRed, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightGray,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.mediumGray,
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.coralRed),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGray,
        selectedItemColor: AppColors.vibrantPurple,
        unselectedItemColor: AppColors.mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevationMedium,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.mediumGray,
        thickness: 1,
        space: AppDimensions.paddingMedium,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.pureWhite,
        size: AppDimensions.iconMedium,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGray,
        elevation: AppDimensions.elevationLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.pureWhite,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightGray,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGray,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.pureWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkGray,
        elevation: AppDimensions.elevationLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusLarge),
            topRight: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple;
          }
          return AppColors.mediumGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple.withValues(alpha: 0.5);
          }
          return AppColors.mediumGray.withValues(alpha: 0.5);
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.pureWhite),
        side: const BorderSide(color: AppColors.mediumGray, width: 2),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple;
          }
          return AppColors.mediumGray;
        }),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.vibrantPurple,
        linearTrackColor: AppColors.mediumGray,
        circularTrackColor: AppColors.mediumGray,
      ),
    );
  }
}
