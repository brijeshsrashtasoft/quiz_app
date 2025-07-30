import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

/// Use case for validating username and checking uniqueness
/// Following CLAUDE.md Clean Architecture patterns
class ValidateUsernameUseCase
    extends BaseUseCase<bool, ValidateUsernameParams> {
  final UserRepository userRepository;

  ValidateUsernameUseCase({required this.userRepository});

  @override
  Future<Result<bool>> call(ValidateUsernameParams params) async {
    try {
      AppLogger.firebase(
        'ValidateUsernameUseCase',
        'Validating username: ${params.username}',
      );
      final startTime = DateTime.now();

      // Step 1: Basic username validation
      final basicValidation = _validateUsernameFormat(params.username);
      if (basicValidation.isFailure) {
        return basicValidation;
      }

      // Step 2: Check uniqueness by searching for users with this name
      // Note: This is a simplified implementation. In production,
      // consider using a dedicated username field with unique constraints
      final searchResult = await userRepository.searchUsersByName(
        params.username,
      );

      if (searchResult.isFailure) {
        AppLogger.error(
          'Failed to search for existing usernames',
          searchResult.failureOrNull,
        );
        return Result.failure(searchResult.failureOrNull!);
      }

      final existingUsers = searchResult.dataOrNull!;

      // Check if any user has exactly this username (case-insensitive)
      final isUnique = !existingUsers.any(
        (user) => user.name.toLowerCase() == params.username.toLowerCase(),
      );

      if (!isUnique) {
        AppLogger.firebase(
          'ValidateUsernameUseCase',
          'Username already exists: ${params.username}',
        );
        return Result.failure(
          Failure.validationFailure(
            message:
                'This username is already taken. Please choose a different one.',
            fieldErrors: {'username': 'Username already exists'},
          ),
        );
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Validate Username Use Case', duration);
      AppLogger.firebase(
        'ValidateUsernameUseCase',
        'Username validation successful: ${params.username}',
      );

      return const Result.success(true);
    } catch (e, stackTrace) {
      AppLogger.error('Username validation failed', e, stackTrace);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Username validation failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Validate username format and requirements
  Result<bool> _validateUsernameFormat(String username) {
    final trimmedUsername = username.trim();

    // Check if empty
    if (trimmedUsername.isEmpty) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username cannot be empty',
          fieldErrors: {'username': 'Please enter a username'},
        ),
      );
    }

    // Check minimum length
    if (trimmedUsername.length < 3) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username must be at least 3 characters long',
          fieldErrors: {
            'username': 'Username too short (minimum 3 characters)',
          },
        ),
      );
    }

    // Check maximum length
    if (trimmedUsername.length > 30) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username cannot exceed 30 characters',
          fieldErrors: {
            'username': 'Username too long (maximum 30 characters)',
          },
        ),
      );
    }

    // Check allowed characters (alphanumeric, underscore, hyphen)
    final validUsernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validUsernameRegex.hasMatch(trimmedUsername)) {
      return Result.failure(
        Failure.validationFailure(
          message:
              'Username can only contain letters, numbers, underscores, and hyphens',
          fieldErrors: {'username': 'Invalid characters in username'},
        ),
      );
    }

    // Check that username doesn't start or end with special characters
    if (trimmedUsername.startsWith('_') ||
        trimmedUsername.startsWith('-') ||
        trimmedUsername.endsWith('_') ||
        trimmedUsername.endsWith('-')) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username cannot start or end with underscore or hyphen',
          fieldErrors: {'username': 'Username format is invalid'},
        ),
      );
    }

    // Check for reserved usernames
    const reservedUsernames = [
      'admin',
      'administrator',
      'root',
      'system',
      'user',
      'guest',
      'test',
      'null',
      'undefined',
      'api',
      'www',
      'ftp',
      'mail',
      'support',
      'help',
      'info',
      'contact',
      'about',
      'privacy',
      'terms',
      'service',
      'security',
      'moderator',
      'mod',
    ];

    if (reservedUsernames.contains(trimmedUsername.toLowerCase())) {
      return Result.failure(
        Failure.validationFailure(
          message: 'This username is reserved. Please choose a different one.',
          fieldErrors: {'username': 'Username is reserved'},
        ),
      );
    }

    // Check for inappropriate patterns
    final inappropriatePatterns = [
      'admin',
      'administrator',
      'moderator',
      'support',
      'official',
      'verified',
      'staff',
      'employee',
    ];

    for (final pattern in inappropriatePatterns) {
      if (trimmedUsername.toLowerCase().contains(pattern)) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Username cannot contain reserved words',
            fieldErrors: {'username': 'Contains restricted terms'},
          ),
        );
      }
    }

    AppLogger.firebase(
      'ValidateUsernameUseCase',
      'Username format validation passed: $trimmedUsername',
    );

    return const Result.success(true);
  }
}

/// Parameters for ValidateUsernameUseCase
class ValidateUsernameParams {
  final String username;

  const ValidateUsernameParams({required this.username});

  @override
  String toString() => 'ValidateUsernameParams(username: $username)';
}
