import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_theme_entity.freezed.dart';

/// Entity representing UI theme state and configuration
/// This defines the business logic for theme management
@freezed
class UIThemeEntity with _$UIThemeEntity {
  const factory UIThemeEntity({
    required bool isDarkMode,
    required String currentThemeId,
    required double animationSpeed,
    required bool reduceMotion,
    required bool highContrast,
    required ThemeBrightness brightness,
    @Default([]) List<String> availableThemes,
  }) = _UIThemeEntity;

  const UIThemeEntity._();

  /// Get readable theme name
  String get themeName {
    switch (currentThemeId) {
      case 'light':
        return 'Light Theme';
      case 'dark':
        return 'Dark Theme';
      case 'spring':
        return 'Spring Theme';
      case 'summer':
        return 'Summer Theme';
      case 'autumn':
        return 'Autumn Theme';
      case 'winter':
        return 'Winter Theme';
      default:
        return 'Default Theme';
    }
  }

  /// Check if current theme is seasonal
  bool get isSeasonalTheme {
    return ['spring', 'summer', 'autumn', 'winter'].contains(currentThemeId);
  }

  /// Get animation duration based on speed setting
  Duration get animationDuration {
    return Duration(milliseconds: (300 * animationSpeed).round());
  }

  /// Check if animations should be reduced
  bool get shouldReduceAnimations {
    return reduceMotion || animationSpeed < 0.5;
  }
}

/// Theme brightness enumeration
enum ThemeBrightness { light, dark, system }
