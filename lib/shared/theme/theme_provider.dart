import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'dark_theme.dart';

/// Theme mode state provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

/// Theme mode notifier for managing theme switching
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    state = ThemeMode.values[themeIndex];
  }

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light
        ? ThemeMode.dark
        : state == ThemeMode.dark
        ? ThemeMode.system
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if dark mode is active
  bool isDarkMode(BuildContext context) {
    switch (state) {
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
    }
  }
}

/// Theme data provider for getting current theme
final themeDataProvider = Provider.family<ThemeData, Brightness>((
  ref,
  brightness,
) {
  return brightness == Brightness.light
      ? AppTheme.lightTheme
      : DarkTheme.darkTheme;
});

/// Current theme provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return AppTheme.lightTheme;
    case ThemeMode.dark:
      return DarkTheme.darkTheme;
    case ThemeMode.system:
      // This will be resolved by MaterialApp
      return AppTheme.lightTheme;
  }
});
