import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../value_objects/password.dart';

/// Use case for validating password strength and requirements
/// Following CLAUDE.md validation patterns and Result pattern
class ValidatePasswordUseCase
    extends BaseUseCase<PasswordValidationResult, ValidatePasswordParams> {
  ValidatePasswordUseCase();

  @override
  Future<Result<PasswordValidationResult>> call(
    ValidatePasswordParams params,
  ) async {
    try {
      // Validate password using value object
      final passwordResult = Password.validate(params.password);

      return passwordResult.when(
        success: (password) {
          final strength = Password.checkStrength(params.password);
          final isValid = strength.meetsRequirements;

          return Result.success(
            PasswordValidationResult(
              isValid: isValid,
              strength: strength,
              password: password,
              suggestions: _getPasswordSuggestions(params.password, strength),
            ),
          );
        },
        failure: (failure) {
          // Convert validation failure to password validation result
          return Result.success(
            PasswordValidationResult(
              isValid: false,
              strength: Password.checkStrength(params.password),
              password: null,
              suggestions: _getPasswordSuggestions(
                params.password,
                Password.checkStrength(params.password),
              ),
              validationFailure: failure,
            ),
          );
        },
      );
    } catch (e) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password validation failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Generate password improvement suggestions
  List<String> _getPasswordSuggestions(
    String password,
    PasswordStrength strength,
  ) {
    final suggestions = <String>[];

    if (password.isEmpty) {
      suggestions.add('Enter a password');
      return suggestions;
    }

    if (password.length < 8) {
      suggestions.add('Use at least 8 characters');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      suggestions.add('Add at least one uppercase letter');
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      suggestions.add('Add at least one lowercase letter');
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      suggestions.add('Add at least one number');
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      suggestions.add('Add at least one special character (!@#\$%^&*...)');
    }

    // Check for common patterns
    if (password.toLowerCase().contains('password')) {
      suggestions.add('Avoid using "password" in your password');
    }

    if (RegExp(r'123|abc|qwe').hasMatch(password.toLowerCase())) {
      suggestions.add('Avoid common sequences like "123" or "abc"');
    }

    if (password.isNotEmpty &&
        password == password.substring(0, 1) * password.length) {
      suggestions.add('Avoid repeating the same character');
    }

    // Positive suggestions based on strength
    switch (strength) {
      case PasswordStrength.empty:
      case PasswordStrength.tooShort:
        break;
      case PasswordStrength.weak:
        suggestions.add(
          'Consider making your password longer for better security',
        );
        break;
      case PasswordStrength.fair:
        suggestions.add('Good start! Add more variety to make it stronger');
        break;
      case PasswordStrength.good:
        suggestions.add(
          'Strong password! Consider adding more characters for extra security',
        );
        break;
      case PasswordStrength.strong:
        suggestions.add('Excellent! Your password is very strong');
        break;
    }

    return suggestions;
  }
}

/// Parameters for ValidatePasswordUseCase
class ValidatePasswordParams {
  final String password;
  final bool checkCommonPasswords;
  final bool requireSpecialCharacters;

  const ValidatePasswordParams({
    required this.password,
    this.checkCommonPasswords = true,
    this.requireSpecialCharacters = true,
  });

  @override
  String toString() =>
      'ValidatePasswordParams(password: [HIDDEN], checkCommonPasswords: $checkCommonPasswords)';
}

/// Result of password validation
class PasswordValidationResult {
  final bool isValid;
  final PasswordStrength strength;
  final Password? password;
  final List<String> suggestions;
  final Failure? validationFailure;

  const PasswordValidationResult({
    required this.isValid,
    required this.strength,
    required this.suggestions,
    this.password,
    this.validationFailure,
  });

  /// Check if password meets minimum requirements for registration
  bool get meetsRegistrationRequirements =>
      isValid &&
      (strength == PasswordStrength.good ||
          strength == PasswordStrength.strong);

  /// Check if password needs improvement
  bool get needsImprovement =>
      strength == PasswordStrength.weak || strength == PasswordStrength.fair;

  /// Get color indicator for UI display
  String get strengthColor => strength.colorIndicator;

  /// Get strength description for UI display
  String get strengthDescription => strength.description;

  /// Get primary validation message
  String get primaryMessage {
    if (validationFailure != null) {
      return validationFailure!.userMessage;
    }

    if (isValid) {
      return strengthDescription;
    }

    return suggestions.isNotEmpty ? suggestions.first : 'Password is invalid';
  }

  @override
  String toString() =>
      'PasswordValidationResult(isValid: $isValid, strength: $strength)';
}
