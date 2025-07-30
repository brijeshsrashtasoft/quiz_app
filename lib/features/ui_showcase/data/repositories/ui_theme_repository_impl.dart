import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ui_theme_entity.dart';
import '../../domain/repositories/ui_theme_repository.dart';

/// Implementation of UIThemeRepository using shared preferences
/// Handles persistence and retrieval of theme configuration
class UIThemeRepositoryImpl implements UIThemeRepository {
  static const String _darkModeKey = 'is_dark_mode';
  static const String _themeIdKey = 'theme_id';
  static const String _animationSpeedKey = 'animation_speed';
  static const String _reduceMotionKey = 'reduce_motion';
  static const String _highContrastKey = 'high_contrast';

  final SharedPreferences _prefs;
  final StreamController<UIThemeEntity> _themeController;

  // Default theme configuration
  static const UIThemeEntity _defaultTheme = UIThemeEntity(
    isDarkMode: false,
    currentThemeId: 'light',
    animationSpeed: 1.0,
    reduceMotion: false,
    highContrast: false,
    brightness: ThemeBrightness.system,
    availableThemes: ['light', 'dark', 'spring', 'summer', 'autumn', 'winter'],
  );

  UIThemeRepositoryImpl(this._prefs)
    : _themeController = StreamController<UIThemeEntity>.broadcast();

  @override
  Future<Result<UIThemeEntity>> getCurrentTheme() async {
    try {
      final isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
      final themeId = _prefs.getString(_themeIdKey) ?? 'light';
      final animationSpeed = _prefs.getDouble(_animationSpeedKey) ?? 1.0;
      final reduceMotion = _prefs.getBool(_reduceMotionKey) ?? false;
      final highContrast = _prefs.getBool(_highContrastKey) ?? false;

      // Determine brightness based on system and user preference
      final brightness = _getBrightness(isDarkMode);

      final theme = UIThemeEntity(
        isDarkMode: isDarkMode,
        currentThemeId: themeId,
        animationSpeed: animationSpeed,
        reduceMotion: reduceMotion,
        highContrast: highContrast,
        brightness: brightness,
        availableThemes: _defaultTheme.availableThemes,
      );

      return Result.success(theme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to get current theme: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateTheme(UIThemeEntity theme) async {
    try {
      await _prefs.setBool(_darkModeKey, theme.isDarkMode);
      await _prefs.setString(_themeIdKey, theme.currentThemeId);
      await _prefs.setDouble(_animationSpeedKey, theme.animationSpeed);
      await _prefs.setBool(_reduceMotionKey, theme.reduceMotion);
      await _prefs.setBool(_highContrastKey, theme.highContrast);

      _themeController.add(theme);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to update theme: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<UIThemeEntity>> toggleDarkMode() async {
    try {
      final currentResult = await getCurrentTheme();

      if (currentResult.isFailure) {
        return Result.failure(currentResult.failureOrNull!);
      }

      final currentTheme = currentResult.dataOrNull!;
      final updatedTheme = currentTheme.copyWith(
        isDarkMode: !currentTheme.isDarkMode,
        currentThemeId: !currentTheme.isDarkMode ? 'dark' : 'light',
        brightness: _getBrightness(!currentTheme.isDarkMode),
      );

      final updateResult = await updateTheme(updatedTheme);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(updatedTheme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to toggle dark mode: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<UIThemeEntity>> setTheme(String themeId) async {
    try {
      final currentResult = await getCurrentTheme();

      if (currentResult.isFailure) {
        return Result.failure(currentResult.failureOrNull!);
      }

      final currentTheme = currentResult.dataOrNull!;
      final isDarkTheme =
          themeId == 'dark' || (themeId != 'light' && currentTheme.isDarkMode);

      final updatedTheme = currentTheme.copyWith(
        currentThemeId: themeId,
        isDarkMode: isDarkTheme,
        brightness: _getBrightness(isDarkTheme),
      );

      final updateResult = await updateTheme(updatedTheme);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(updatedTheme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(message: 'Failed to set theme: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UIThemeEntity>> updateAnimationSpeed(double speed) async {
    try {
      if (speed < 0.0 || speed > 2.0) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Animation speed must be between 0.0 and 2.0',
          ),
        );
      }

      final currentResult = await getCurrentTheme();

      if (currentResult.isFailure) {
        return Result.failure(currentResult.failureOrNull!);
      }

      final currentTheme = currentResult.dataOrNull!;
      final updatedTheme = currentTheme.copyWith(animationSpeed: speed);

      final updateResult = await updateTheme(updatedTheme);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(updatedTheme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to update animation speed: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<UIThemeEntity>> toggleReduceMotion() async {
    try {
      final currentResult = await getCurrentTheme();

      if (currentResult.isFailure) {
        return Result.failure(currentResult.failureOrNull!);
      }

      final currentTheme = currentResult.dataOrNull!;
      final updatedTheme = currentTheme.copyWith(
        reduceMotion: !currentTheme.reduceMotion,
      );

      final updateResult = await updateTheme(updatedTheme);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(updatedTheme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to toggle reduce motion: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<UIThemeEntity>> toggleHighContrast() async {
    try {
      final currentResult = await getCurrentTheme();

      if (currentResult.isFailure) {
        return Result.failure(currentResult.failureOrNull!);
      }

      final currentTheme = currentResult.dataOrNull!;
      final updatedTheme = currentTheme.copyWith(
        highContrast: !currentTheme.highContrast,
      );

      final updateResult = await updateTheme(updatedTheme);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(updatedTheme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to toggle high contrast: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<String>>> getAvailableThemes() async {
    try {
      return Result.success(_defaultTheme.availableThemes);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to get available themes: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<UIThemeEntity> watchThemeChanges() {
    return _themeController.stream;
  }

  @override
  Future<Result<UIThemeEntity>> resetToSystemTheme() async {
    try {
      // Clear all preferences
      await _prefs.remove(_darkModeKey);
      await _prefs.remove(_themeIdKey);
      await _prefs.remove(_animationSpeedKey);
      await _prefs.remove(_reduceMotionKey);
      await _prefs.remove(_highContrastKey);

      final systemTheme = _defaultTheme.copyWith(
        brightness: ThemeBrightness.system,
      );

      final updateResult = await updateTheme(systemTheme);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.failureOrNull!);
      }

      return Result.success(systemTheme);
    } catch (e) {
      return Result.failure(
        Failure.cacheFailure(
          message: 'Failed to reset to system theme: ${e.toString()}',
        ),
      );
    }
  }

  /// Determine brightness based on dark mode setting
  ThemeBrightness _getBrightness(bool isDarkMode) {
    return isDarkMode ? ThemeBrightness.dark : ThemeBrightness.light;
  }

  /// Dispose resources
  void dispose() {
    _themeController.close();
  }
}
