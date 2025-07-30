import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/result.dart';
import '../../data/repositories/ui_theme_repository_impl.dart';
import '../../domain/entities/ui_theme_entity.dart';
import '../../domain/repositories/ui_theme_repository.dart';
import '../../domain/usecases/toggle_theme_usecase.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// Provider for UI theme repository
final uiThemeRepositoryProvider = Provider<UIThemeRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UIThemeRepositoryImpl(prefs);
});

/// Provider for theme use cases
final toggleThemeUseCaseProvider = Provider<ToggleThemeUseCase>((ref) {
  final repository = ref.watch(uiThemeRepositoryProvider);
  return ToggleThemeUseCase(repository);
});

final updateAnimationSpeedUseCaseProvider =
    Provider<UpdateAnimationSpeedUseCase>((ref) {
      final repository = ref.watch(uiThemeRepositoryProvider);
      return UpdateAnimationSpeedUseCase(repository);
    });

final setThemeUseCaseProvider = Provider<SetThemeUseCase>((ref) {
  final repository = ref.watch(uiThemeRepositoryProvider);
  return SetThemeUseCase(repository);
});

final toggleAccessibilityUseCaseProvider = Provider<ToggleAccessibilityUseCase>(
  (ref) {
    final repository = ref.watch(uiThemeRepositoryProvider);
    return ToggleAccessibilityUseCase(repository);
  },
);

final watchThemeChangesUseCaseProvider = Provider<WatchThemeChangesUseCase>((
  ref,
) {
  final repository = ref.watch(uiThemeRepositoryProvider);
  return WatchThemeChangesUseCase(repository);
});

/// State notifier for managing UI theme state
class UIThemeNotifier extends StateNotifier<AsyncValue<UIThemeEntity>> {
  final UIThemeRepository _repository;
  final ToggleThemeUseCase _toggleThemeUseCase;
  final UpdateAnimationSpeedUseCase _updateAnimationSpeedUseCase;
  final SetThemeUseCase _setThemeUseCase;
  final ToggleAccessibilityUseCase _toggleAccessibilityUseCase;

  UIThemeNotifier(
    this._repository,
    this._toggleThemeUseCase,
    this._updateAnimationSpeedUseCase,
    this._setThemeUseCase,
    this._toggleAccessibilityUseCase,
  ) : super(const AsyncValue.loading()) {
    _initialize();
  }

  /// Initialize theme state
  Future<void> _initialize() async {
    try {
      final result = await _repository.getCurrentTheme();
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }

      // Listen to theme changes
      _repository.watchThemeChanges().listen((theme) {
        if (mounted) {
          state = AsyncValue.data(theme);
        }
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleDarkMode() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final result = await _toggleThemeUseCase();
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Set specific theme by ID
  Future<void> setTheme(String themeId) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final result = await _setThemeUseCase(themeId);
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update animation speed
  Future<void> updateAnimationSpeed(double speed) async {
    if (state.isLoading) return;

    try {
      final result = await _updateAnimationSpeedUseCase(speed);
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Toggle reduce motion setting
  Future<void> toggleReduceMotion() async {
    if (state.isLoading) return;

    try {
      final result = await _toggleAccessibilityUseCase.toggleReduceMotion();
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Toggle high contrast setting
  Future<void> toggleHighContrast() async {
    if (state.isLoading) return;

    try {
      final result = await _toggleAccessibilityUseCase.toggleHighContrast();
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Reset theme to system default
  Future<void> resetToSystemTheme() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final result = await _repository.resetToSystemTheme();
      if (result.isSuccess) {
        state = AsyncValue.data(result.dataOrNull!);
      } else {
        state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// State notifier provider for UI theme management
final uiThemeNotifierProvider =
    StateNotifierProvider<UIThemeNotifier, AsyncValue<UIThemeEntity>>((ref) {
      final repository = ref.watch(uiThemeRepositoryProvider);
      final toggleThemeUseCase = ref.watch(toggleThemeUseCaseProvider);
      final updateAnimationSpeedUseCase = ref.watch(
        updateAnimationSpeedUseCaseProvider,
      );
      final setThemeUseCase = ref.watch(setThemeUseCaseProvider);
      final toggleAccessibilityUseCase = ref.watch(
        toggleAccessibilityUseCaseProvider,
      );

      return UIThemeNotifier(
        repository,
        toggleThemeUseCase,
        updateAnimationSpeedUseCase,
        setThemeUseCase,
        toggleAccessibilityUseCase,
      );
    });

/// Convenient provider for accessing current theme data
final currentUIThemeProvider = Provider<UIThemeEntity?>((ref) {
  final themeState = ref.watch(uiThemeNotifierProvider);
  return themeState.maybeWhen(data: (theme) => theme, orElse: () => null);
});

/// Provider for checking if dark mode is enabled
final isDarkModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(currentUIThemeProvider);
  return theme?.isDarkMode ?? false;
});

/// Provider for current animation speed
final animationSpeedProvider = Provider<double>((ref) {
  final theme = ref.watch(currentUIThemeProvider);
  return theme?.animationSpeed ?? 1.0;
});

/// Provider for accessibility settings
final accessibilitySettingsProvider =
    Provider<({bool reduceMotion, bool highContrast})>((ref) {
      final theme = ref.watch(currentUIThemeProvider);
      return (
        reduceMotion: theme?.reduceMotion ?? false,
        highContrast: theme?.highContrast ?? false,
      );
    });

/// Provider for available themes
final availableThemesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(uiThemeRepositoryProvider);
  final result = await repository.getAvailableThemes();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.failureOrNull!;
  }
});

/// Animation controller management provider
final animationControllerManagerProvider = Provider<AnimationControllerManager>(
  (ref) {
    final animationSpeed = ref.watch(animationSpeedProvider);
    final accessibilitySettings = ref.watch(accessibilitySettingsProvider);

    return AnimationControllerManager(
      speed: animationSpeed,
      reduceMotion: accessibilitySettings.reduceMotion,
    );
  },
);

/// Animation controller manager for centralized animation management
class AnimationControllerManager {
  final double speed;
  final bool reduceMotion;

  const AnimationControllerManager({
    required this.speed,
    required this.reduceMotion,
  });

  /// Get animation duration based on settings
  Duration getDuration(Duration baseDuration) {
    if (reduceMotion) {
      return Duration.zero;
    }
    return Duration(
      milliseconds: (baseDuration.inMilliseconds * speed).round(),
    );
  }

  /// Get curve based on accessibility settings
  Curve getCurve(Curve baseCurve) {
    if (reduceMotion) {
      return Curves.linear;
    }
    return baseCurve;
  }

  /// Check if animations should be disabled
  bool get shouldDisableAnimations => reduceMotion || speed <= 0.1;
}
