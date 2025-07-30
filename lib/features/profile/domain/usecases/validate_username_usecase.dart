import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for validating username availability and format
/// Handles username validation rules and uniqueness checks
/// Following CLAUDE.md patterns and validation standards
class ValidateUsernameUseCase
    extends BaseUseCase<bool, ValidateUsernameParams> {
  final ProfileRepository profileRepository;

  ValidateUsernameUseCase({required this.profileRepository});

  @override
  Future<Result<bool>> call(ValidateUsernameParams params) async {
    try {
      AppLogger.info(
        'ValidateUsernameUseCase',
        'Validating username: ${params.username}',
      );

      // Validate username format
      final formatValidation = _validateUsernameFormat(params.username);
      if (!formatValidation.isSuccess) {
        return Result.failure(formatValidation.failureOrNull!);
      }

      final startTime = DateTime.now();

      // Check username availability
      final availabilityResult = await profileRepository.isUsernameAvailable(
        params.username,
      );

      if (!availabilityResult.isSuccess) {
        return Result.failure(availabilityResult.failureOrNull!);
      }

      final isAvailable = availabilityResult.dataOrNull ?? false;
      if (!isAvailable) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Username "${params.username}" is already taken',
          ),
        );
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Validate Username Use Case', duration);
      AppLogger.info(
        'ValidateUsernameUseCase',
        'Username validation successful: ${params.username}',
      );

      return Result.success(true);
    } catch (e) {
      AppLogger.error('Username validation failed', e);
      return Result.failure(
        Failure.validationFailure(
          message: 'Failed to validate username. Please try again.',
        ),
      );
    }
  }

  /// Validate username format according to business rules
  Result<void> _validateUsernameFormat(String username) {
    // Check length (3-20 characters)
    if (username.length < 3) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username must be at least 3 characters long',
        ),
      );
    }

    if (username.length > 20) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username must be no more than 20 characters long',
        ),
      );
    }

    // Check allowed characters (alphanumeric, underscore, hyphen)
    final validUsernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validUsernameRegex.hasMatch(username)) {
      return Result.failure(
        Failure.validationFailure(
          message:
              'Username can only contain letters, numbers, underscore, and hyphen',
        ),
      );
    }

    // Check must start with a letter or number (not underscore or hyphen)
    final startsWithAlphanumeric = RegExp(r'^[a-zA-Z0-9]');
    if (!startsWithAlphanumeric.hasMatch(username)) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username must start with a letter or number',
        ),
      );
    }

    // Check for reserved usernames
    const reservedUsernames = [
      'admin',
      'administrator',
      'root',
      'user',
      'guest',
      'test',
      'demo',
      'api',
      'www',
      'mail',
      'support',
      'help',
      'info',
      'contact',
      'quiz',
      'game',
      'player',
      'host',
      'moderator',
      'mod',
      'system',
      'bot',
      'null',
      'undefined',
    ];

    if (reservedUsernames.contains(username.toLowerCase())) {
      return Result.failure(
        Failure.validationFailure(
          message: 'This username is reserved and cannot be used',
        ),
      );
    }

    // Check for inappropriate content (basic check)
    const inappropriateTerms = [
      'fuck',
      'shit',
      'damn',
      'hell',
      'stupid',
      'idiot',
      'hate',
    ];

    if (inappropriateTerms.any(
      (term) => username.toLowerCase().contains(term),
    )) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Username contains inappropriate content',
        ),
      );
    }

    return Result.success(null);
  }
}

/// Parameters for ValidateUsernameUseCase
class ValidateUsernameParams extends BaseUseCaseParams {
  final String username;

  const ValidateUsernameParams({required this.username});

  @override
  String toString() => 'ValidateUsernameParams(username: $username)';
}
