import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ui_theme_entity.dart';
import '../repositories/ui_theme_repository.dart';

/// Use case for toggling between light and dark themes
/// Encapsulates the business logic for theme switching
class ToggleThemeUseCase {
  final UIThemeRepository _repository;

  const ToggleThemeUseCase(this._repository);

  /// Execute theme toggle operation
  Future<Result<UIThemeEntity>> call() async {
    try {
      // Get current theme first
      final currentThemeResult = await _repository.getCurrentTheme();

      if (currentThemeResult.isFailure) {
        return Result.failure(currentThemeResult.failureOrNull!);
      }

      // Toggle the theme
      return await _repository.toggleDarkMode();
    } catch (e) {
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to toggle theme: ${e.toString()}',
        ),
      );
    }
  }
}

/// Use case for updating animation speed
class UpdateAnimationSpeedUseCase {
  final UIThemeRepository _repository;

  const UpdateAnimationSpeedUseCase(this._repository);

  /// Execute animation speed update
  Future<Result<UIThemeEntity>> call(double speed) async {
    // Validate speed range
    if (speed < 0.0 || speed > 2.0) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Animation speed must be between 0.0 and 2.0',
        ),
      );
    }

    try {
      return await _repository.updateAnimationSpeed(speed);
    } catch (e) {
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to update animation speed: ${e.toString()}',
        ),
      );
    }
  }
}

/// Use case for setting specific theme
class SetThemeUseCase {
  final UIThemeRepository _repository;

  const SetThemeUseCase(this._repository);

  /// Execute theme setting operation
  Future<Result<UIThemeEntity>> call(String themeId) async {
    // Validate theme ID
    if (themeId.isEmpty) {
      return Result.failure(
        Failure.validationFailure(message: 'Theme ID cannot be empty'),
      );
    }

    try {
      // Get available themes first to validate
      final availableThemesResult = await _repository.getAvailableThemes();

      if (availableThemesResult.isFailure) {
        return Result.failure(availableThemesResult.failureOrNull!);
      }

      final availableThemes = availableThemesResult.dataOrNull!;
      if (!availableThemes.contains(themeId)) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Theme "$themeId" is not available',
          ),
        );
      }

      return await _repository.setTheme(themeId);
    } catch (e) {
      return Result.failure(
        Failure.unknownFailure(message: 'Failed to set theme: ${e.toString()}'),
      );
    }
  }
}

/// Use case for toggling accessibility features
class ToggleAccessibilityUseCase {
  final UIThemeRepository _repository;

  const ToggleAccessibilityUseCase(this._repository);

  /// Toggle reduce motion setting
  Future<Result<UIThemeEntity>> toggleReduceMotion() async {
    try {
      return await _repository.toggleReduceMotion();
    } catch (e) {
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to toggle reduce motion: ${e.toString()}',
        ),
      );
    }
  }

  /// Toggle high contrast setting
  Future<Result<UIThemeEntity>> toggleHighContrast() async {
    try {
      return await _repository.toggleHighContrast();
    } catch (e) {
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to toggle high contrast: ${e.toString()}',
        ),
      );
    }
  }
}

/// Use case for watching theme changes
class WatchThemeChangesUseCase {
  final UIThemeRepository _repository;

  const WatchThemeChangesUseCase(this._repository);

  /// Execute theme watching operation
  Stream<UIThemeEntity> call() {
    return _repository.watchThemeChanges();
  }
}
