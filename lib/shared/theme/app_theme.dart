import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// Material theme configuration following Kahoot-style design system
/// Reference: docs/ui_guideline.md
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.vibrantPurple,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.turquoise,
        onSecondary: AppColors.pureWhite,
        tertiary: AppColors.mintGreen,
        onTertiary: AppColors.charcoal,
        error: AppColors.coralRed,
        onError: AppColors.pureWhite,
        surface: AppColors.pureWhite,
        onSurface: AppColors.charcoal,
        background: AppColors.offWhite,
        onBackground: AppColors.charcoal,
        outline: AppColors.lightGray,
        outlineVariant: AppColors.lightGray,
        shadow: AppColors.shadowLight,
      ),

      // Scaffold configuration
      scaffoldBackgroundColor: AppColors.offWhite,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.vibrantPurple,
        foregroundColor: AppColors.pureWhite,
        elevation: AppDimensions.elevationMedium,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.sectionHeader,
        toolbarHeight: AppDimensions.appBarHeight,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        margin: const EdgeInsets.all(8.0),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantPurple,
          foregroundColor: AppColors.pureWhite,
          elevation: AppDimensions.buttonElevation,
          shadowColor: AppColors.shadowButton,
          minimumSize: const Size(120, AppDimensions.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vibrantPurple,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(120, AppDimensions.secondaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          side: const BorderSide(
            color: AppColors.vibrantPurple,
            width: AppDimensions.buttonBorderWidth,
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.vibrantPurple,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vibrantPurple,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(80, AppDimensions.secondaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.vibrantPurple,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),

      // FAB theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.vibrantPurple,
        foregroundColor: AppColors.pureWhite,
        elevation: AppDimensions.fabElevation,
        shape: CircleBorder(),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.all(16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.lightGray,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.lightGray,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.vibrantPurple,
            width: AppDimensions.activeBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.coralRed,
            width: AppDimensions.activeBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.coralRed,
            width: AppDimensions.activeBorderWidth,
          ),
        ),
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputHint,
        errorStyle: AppTextStyles.errorText,
        helperStyle: AppTextStyles.caption,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.gameTitle,
        displayMedium: AppTextStyles.sectionHeader,
        displaySmall: AppTextStyles.questionText,
        headlineLarge: AppTextStyles.sectionHeader,
        headlineMedium: AppTextStyles.questionText,
        headlineSmall: AppTextStyles.answerOption,
        titleLarge: AppTextStyles.questionText,
        titleMedium: AppTextStyles.answerOption,
        titleSmall: AppTextStyles.bodyText,
        bodyLarge: AppTextStyles.bodyText,
        bodyMedium: AppTextStyles.bodyText,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
        labelSmall: AppTextStyles.buttonSmall,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.charcoal,
        size: AppDimensions.iconM,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.vibrantPurple,
        linearTrackColor: AppColors.lightGray,
        circularTrackColor: AppColors.lightGray,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: AppDimensions.dividerWidth,
        space: 16.0,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGray,
        selectedColor: AppColors.vibrantPurple,
        secondarySelectedColor: AppColors.turquoise,
        labelStyle: AppTextStyles.caption,
        secondaryLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.pureWhite,
        ),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        ),
      ),

      // Bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.vibrantPurple,
        unselectedItemColor: AppColors.coolGray,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevationMedium,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.vibrantPurple,
        unselectedLabelColor: AppColors.coolGray,
        labelStyle: AppTextStyles.buttonMedium,
        unselectedLabelStyle: AppTextStyles.buttonMedium,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.vibrantPurple, width: 3.0),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        splashFactory: InkRipple.splashFactory,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.pureWhite,
        elevation: AppDimensions.modalElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        ),
        titleTextStyle: AppTextStyles.sectionHeader,
        contentTextStyle: AppTextStyles.bodyText,
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: AppTextStyles.bodyText.copyWith(
          color: AppColors.pureWhite,
        ),
        actionTextColor: AppColors.turquoise,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        ),
        elevation: AppDimensions.elevationHigh,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple;
          }
          return AppColors.coolGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple.withOpacity(0.5);
          }
          return AppColors.lightGray;
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
        side: const BorderSide(color: AppColors.lightGray, width: 2.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vibrantPurple;
          }
          return AppColors.coolGray;
        }),
      ),

      // Slider theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.vibrantPurple,
        inactiveTrackColor: AppColors.lightGray,
        thumbColor: AppColors.vibrantPurple,
        overlayColor: AppColors.vibrantPurple,
        valueIndicatorColor: AppColors.vibrantPurple,
        valueIndicatorTextStyle: AppTextStyles.caption,
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        titleTextStyle: AppTextStyles.bodyText,
        subtitleTextStyle: AppTextStyles.caption,
        leadingAndTrailingTextStyle: AppTextStyles.caption,
        iconColor: AppColors.coolGray,
        textColor: AppColors.charcoal,
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.vibrantPurple,
        selectedColor: AppColors.pureWhite,
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusS),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.pureWhite),
        preferBelow: false,
        verticalOffset: 24.0,
      ),

      // Material ripple configuration
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,

      // Dark color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.vibrantPurple,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.turquoise,
        onSecondary: AppColors.charcoal,
        tertiary: AppColors.mintGreen,
        onTertiary: AppColors.charcoal,
        error: AppColors.coralRed,
        onError: AppColors.pureWhite,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkPrimaryText,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkPrimaryText,
        outline: AppColors.darkDividers,
        outlineVariant: AppColors.darkDividers,
        shadow: AppColors.shadowDark,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      // Dark app bar theme
      appBarTheme: lightTheme.appBarTheme!.copyWith(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkPrimaryText,
        titleTextStyle: AppTextStyles.sectionHeaderDark,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Dark card theme
      cardTheme: lightTheme.cardTheme!.copyWith(
        color: AppColors.darkSurface,
        shadowColor: AppColors.shadowDark,
      ),

      // Dark text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.gameTitleDark,
        displayMedium: AppTextStyles.sectionHeaderDark,
        displaySmall: AppTextStyles.questionTextDark,
        headlineLarge: AppTextStyles.sectionHeaderDark,
        headlineMedium: AppTextStyles.questionTextDark,
        headlineSmall: AppTextStyles.answerOptionDark,
        titleLarge: AppTextStyles.questionTextDark,
        titleMedium: AppTextStyles.answerOptionDark,
        titleSmall: AppTextStyles.bodyTextDark,
        bodyLarge: AppTextStyles.bodyTextDark,
        bodyMedium: AppTextStyles.bodyTextDark,
        bodySmall: AppTextStyles.captionDark,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
        labelSmall: AppTextStyles.buttonSmall,
      ),

      // Dark input decoration theme
      inputDecorationTheme: lightTheme.inputDecorationTheme!.copyWith(
        fillColor: AppColors.darkSurface,
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: AppColors.darkSecondaryText,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.darkDividers,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
      ),

      // Dark icon theme
      iconTheme: const IconThemeData(
        color: AppColors.darkPrimaryText,
        size: AppDimensions.iconM,
      ),

      // Dark divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDividers,
        thickness: AppDimensions.dividerWidth,
        space: 16.0,
      ),

      // Dark bottom navigation theme
      bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme!.copyWith(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.vibrantPurple,
        unselectedItemColor: AppColors.darkSecondaryText,
      ),

      // Dark dialog theme
      dialogTheme: lightTheme.dialogTheme!.copyWith(
        backgroundColor: AppColors.darkSurface,
        titleTextStyle: AppTextStyles.sectionHeaderDark,
        contentTextStyle: AppTextStyles.bodyTextDark,
      ),

      // Dark list tile theme
      listTileTheme: lightTheme.listTileTheme!.copyWith(
        titleTextStyle: AppTextStyles.bodyTextDark,
        subtitleTextStyle: AppTextStyles.captionDark,
        iconColor: AppColors.darkSecondaryText,
        textColor: AppColors.darkPrimaryText,
      ),
    );
  }

  /// System theme that follows device settings
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }
}
