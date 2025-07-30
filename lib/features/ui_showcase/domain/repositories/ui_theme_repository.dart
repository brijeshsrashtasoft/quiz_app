import '../../../../core/utils/result.dart';
import '../entities/ui_theme_entity.dart';

/// Repository contract for UI theme management
/// Defines the interface for theme-related operations
abstract class UIThemeRepository {
  /// Get current theme configuration
  Future<Result<UIThemeEntity>> getCurrentTheme();

  /// Update theme configuration
  Future<Result<void>> updateTheme(UIThemeEntity theme);

  /// Toggle between light and dark mode
  Future<Result<UIThemeEntity>> toggleDarkMode();

  /// Set theme by ID (light, dark, seasonal themes)
  Future<Result<UIThemeEntity>> setTheme(String themeId);

  /// Update animation speed (0.0 to 2.0)
  Future<Result<UIThemeEntity>> updateAnimationSpeed(double speed);

  /// Toggle motion reduction for accessibility
  Future<Result<UIThemeEntity>> toggleReduceMotion();

  /// Toggle high contrast mode for accessibility
  Future<Result<UIThemeEntity>> toggleHighContrast();

  /// Get available theme options
  Future<Result<List<String>>> getAvailableThemes();

  /// Watch theme changes stream
  Stream<UIThemeEntity> watchThemeChanges();

  /// Reset theme to system default
  Future<Result<UIThemeEntity>> resetToSystemTheme();
}
