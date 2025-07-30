import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

part 'password.freezed.dart';

/// Password value object with validation for Clean Architecture domain layer
/// Following CLAUDE.md security patterns and Result pattern
@freezed
class Password with _$Password {
  const factory Password._(String value) = _Password;

  /// Create Password with validation
  factory Password(String value) {
    final result = Password.validate(value);
    return result.when(
      success: (password) => password,
      failure: (failure) => throw ArgumentError(failure.userMessage),
    );
  }

  /// Validate password and return Result
  static Result<Password> validate(String input) {
    if (input.isEmpty) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password is required',
          fieldErrors: {'password': 'Password is required'},
        ),
      );
    }

    // Password length validation
    if (input.length < 8) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password must be at least 8 characters long',
          fieldErrors: {
            'password': 'Password must be at least 8 characters long',
          },
        ),
      );
    }

    if (input.length > 128) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password is too long',
          fieldErrors: {'password': 'Password is too long'},
        ),
      );
    }

    // Password strength validation
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(input);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(input);
    final hasDigits = RegExp(r'[0-9]').hasMatch(input);
    // Note: Special characters are recommended but not required for basic validation

    if (!hasUppercase) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password must contain at least one uppercase letter',
          fieldErrors: {
            'password': 'Password must contain at least one uppercase letter',
          },
        ),
      );
    }

    if (!hasLowercase) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password must contain at least one lowercase letter',
          fieldErrors: {
            'password': 'Password must contain at least one lowercase letter',
          },
        ),
      );
    }

    if (!hasDigits) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password must contain at least one number',
          fieldErrors: {
            'password': 'Password must contain at least one number',
          },
        ),
      );
    }

    // Check for common weak passwords
    final commonPasswords = [
      'password',
      '12345678',
      'qwerty',
      'abc123',
      'password123',
      '123456789',
      'welcome',
      'admin',
      'letmein',
      'monkey',
    ];

    if (commonPasswords.contains(input.toLowerCase())) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Password is too common, please choose a stronger password',
          fieldErrors: {
            'password':
                'Password is too common, please choose a stronger password',
          },
        ),
      );
    }

    return Result.success(Password._(input));
  }

  /// Create Password safely, returning null if invalid
  static Password? tryCreate(String value) {
    final result = validate(value);
    return result.dataOrNull;
  }

  /// Validate password strength and return detailed feedback
  static PasswordStrength checkStrength(String input) {
    if (input.isEmpty) {
      return PasswordStrength.empty;
    }

    if (input.length < 8) {
      return PasswordStrength.tooShort;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(input);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(input);
    final hasDigits = RegExp(r'[0-9]').hasMatch(input);
    final hasSpecialCharacters = RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(input);

    final criteriaMet = [
      hasUppercase,
      hasLowercase,
      hasDigits,
      hasSpecialCharacters,
    ].where((criteria) => criteria).length;

    if (criteriaMet < 2) {
      return PasswordStrength.weak;
    } else if (criteriaMet < 3) {
      return PasswordStrength.fair;
    } else if (criteriaMet < 4) {
      return PasswordStrength.good;
    } else {
      return PasswordStrength.strong;
    }
  }
}

/// Password strength enumeration
enum PasswordStrength { empty, tooShort, weak, fair, good, strong }

/// Extension methods for Password value object
extension PasswordX on Password {
  /// Get the password strength
  PasswordStrength get strength => Password.checkStrength(value);

  /// Check if password is strong enough for sensitive operations
  bool get isStrongEnough =>
      strength == PasswordStrength.good || strength == PasswordStrength.strong;
}

/// Extension methods for PasswordStrength
extension PasswordStrengthX on PasswordStrength {
  /// Get user-friendly description of password strength
  String get description {
    switch (this) {
      case PasswordStrength.empty:
        return 'Password is required';
      case PasswordStrength.tooShort:
        return 'Password is too short';
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.fair:
        return 'Fair password';
      case PasswordStrength.good:
        return 'Good password';
      case PasswordStrength.strong:
        return 'Strong password';
    }
  }

  /// Get color indicator for UI display
  String get colorIndicator {
    switch (this) {
      case PasswordStrength.empty:
      case PasswordStrength.tooShort:
        return '#FF0000'; // Red
      case PasswordStrength.weak:
        return '#FF6600'; // Orange
      case PasswordStrength.fair:
        return '#FFCC00'; // Yellow
      case PasswordStrength.good:
        return '#66CC00'; // Light Green
      case PasswordStrength.strong:
        return '#00CC00'; // Green
    }
  }

  /// Check if password meets minimum requirements
  bool get meetsRequirements =>
      this != PasswordStrength.empty &&
      this != PasswordStrength.tooShort &&
      this != PasswordStrength.weak;
}
