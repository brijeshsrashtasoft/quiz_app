import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

part 'email.freezed.dart';

/// Email value object with validation for Clean Architecture domain layer
/// Following CLAUDE.md validation patterns and Result pattern
@freezed
class Email with _$Email {
  const factory Email._(String value) = _Email;

  /// Create Email with validation
  factory Email(String value) {
    final result = Email.validate(value);
    return result.when(
      success: (email) => email,
      failure: (failure) => throw ArgumentError(failure.userMessage),
    );
  }

  /// Validate email and return Result
  static Result<Email> validate(String input) {
    if (input.trim().isEmpty) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Email address is required',
          fieldErrors: {'email': 'Email address is required'},
        ),
      );
    }

    final trimmedInput = input.trim();

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedInput)) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Please enter a valid email address',
          fieldErrors: {'email': 'Please enter a valid email address'},
        ),
      );
    }

    // Email length validation
    if (trimmedInput.length > 254) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Email address is too long',
          fieldErrors: {'email': 'Email address is too long'},
        ),
      );
    }

    // Check for common invalid patterns
    if (trimmedInput.startsWith('.') ||
        trimmedInput.endsWith('.') ||
        trimmedInput.contains('..')) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Email format is invalid',
          fieldErrors: {'email': 'Email format is invalid'},
        ),
      );
    }

    return Result.success(Email._(trimmedInput.toLowerCase()));
  }

  /// Create Email safely, returning null if invalid
  static Email? tryCreate(String value) {
    final result = validate(value);
    return result.dataOrNull;
  }
}

/// Extension methods for Email value object
extension EmailX on Email {
  /// Get the domain part of the email
  String get domain {
    final atIndex = value.indexOf('@');
    return atIndex != -1 ? value.substring(atIndex + 1) : '';
  }

  /// Get the local part of the email (before @)
  String get localPart {
    final atIndex = value.indexOf('@');
    return atIndex != -1 ? value.substring(0, atIndex) : value;
  }

  /// Check if email is from a specific domain
  bool isFromDomain(String domain) {
    return this.domain.toLowerCase() == domain.toLowerCase();
  }

  /// Check if email is from admin domain (for admin privileges)
  bool get isAdminEmail {
    const adminDomains = ['quizapp.com', 'admin.quizapp.com'];
    return adminDomains.any((domain) => isFromDomain(domain));
  }

  /// Check if email is from a corporate domain
  bool get isCorporateEmail {
    const personalDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com',
      'aol.com',
      'protonmail.com',
    ];
    return !personalDomains.any((domain) => isFromDomain(domain));
  }
}
