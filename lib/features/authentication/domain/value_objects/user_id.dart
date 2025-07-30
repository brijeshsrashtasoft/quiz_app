import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

part 'user_id.freezed.dart';

/// User ID value object with validation for Clean Architecture domain layer
/// Following CLAUDE.md identification patterns and Result pattern
@freezed
class UserId with _$UserId {
  const factory UserId._(String value) = _UserId;

  /// Create UserId with validation
  factory UserId(String value) {
    final result = UserId.validate(value);
    return result.when(
      success: (userId) => userId,
      failure: (failure) => throw ArgumentError(failure.userMessage),
    );
  }

  /// Validate user ID and return Result
  static Result<UserId> validate(String input) {
    if (input.trim().isEmpty) {
      return Result.failure(
        Failure.validationFailure(
          message: 'User ID is required',
          fieldErrors: {'userId': 'User ID is required'},
        ),
      );
    }

    final trimmedInput = input.trim();

    // User ID length validation (Firebase UID is typically 28 characters)
    if (trimmedInput.length < 3) {
      return Result.failure(
        Failure.validationFailure(
          message: 'User ID is too short',
          fieldErrors: {'userId': 'User ID is too short'},
        ),
      );
    }

    if (trimmedInput.length > 128) {
      return Result.failure(
        Failure.validationFailure(
          message: 'User ID is too long',
          fieldErrors: {'userId': 'User ID is too long'},
        ),
      );
    }

    // User ID format validation (alphanumeric and some special characters)
    final userIdRegex = RegExp(r'^[a-zA-Z0-9_\-\.]+$');
    if (!userIdRegex.hasMatch(trimmedInput)) {
      return Result.failure(
        Failure.validationFailure(
          message: 'User ID contains invalid characters',
          fieldErrors: {
            'userId':
                'User ID can only contain letters, numbers, hyphens, underscores, and dots',
          },
        ),
      );
    }

    // Check for reserved user IDs
    const reservedIds = [
      'admin',
      'root',
      'system',
      'anonymous',
      'guest',
      'user',
      'moderator',
      'support',
      'help',
      'api',
      'bot',
      'test',
    ];

    if (reservedIds.contains(trimmedInput.toLowerCase())) {
      return Result.failure(
        Failure.validationFailure(
          message: 'User ID is reserved',
          fieldErrors: {
            'userId': 'This user ID is reserved, please choose another',
          },
        ),
      );
    }

    return Result.success(UserId._(trimmedInput));
  }

  /// Create UserId safely, returning null if invalid
  static UserId? tryCreate(String value) {
    final result = validate(value);
    return result.dataOrNull;
  }

  /// Generate a new UUID-based UserId (for internal use)
  /// Note: In production, Firebase Auth generates these automatically
  static UserId generate() {
    // This is a simplified UUID generator for testing purposes
    // In production, Firebase Auth handles this automatically
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 31) % 1000000;
    final id = 'user_${timestamp}_$random';
    return UserId._(id);
  }
}

/// Extension methods for UserId value object
extension UserIdX on UserId {
  /// Check if this is a Firebase-generated UID (28 characters)
  bool get isFirebaseUid =>
      value.length == 28 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);

  /// Check if this is a custom user ID
  bool get isCustomId => !isFirebaseUid;

  /// Check if this is an admin user ID
  bool get isAdminId =>
      value.toLowerCase().startsWith('admin_') ||
      value.toLowerCase() == 'admin';

  /// Check if this is a system user ID
  bool get isSystemId =>
      value.toLowerCase().startsWith('system_') ||
      ['system', 'root', 'api'].contains(value.toLowerCase());

  /// Check if this is a test user ID
  bool get isTestId =>
      value.toLowerCase().startsWith('test_') ||
      value.toLowerCase().contains('test');

  /// Get a masked version for logging (security)
  String get masked {
    if (value.length <= 6) {
      return '*' * value.length;
    }
    return '${value.substring(0, 3)}${'*' * (value.length - 6)}${value.substring(value.length - 3)}';
  }

  /// Get short display version (first 8 characters)
  String get shortDisplay {
    return value.length > 8 ? '${value.substring(0, 8)}...' : value;
  }
}
