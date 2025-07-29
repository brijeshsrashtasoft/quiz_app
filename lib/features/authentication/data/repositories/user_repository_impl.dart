import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_firestore_datasource.dart';
import '../models/user_model.dart';

/// User repository implementation for Clean Architecture
/// Following CLAUDE.md patterns and error handling
class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDataSource dataSource;

  const UserRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Result<UserEntity>> getUserById(String userId) async {
    try {
      if (userId.isEmpty) {
        return const Result.failure(
          ValidationException(
            message: 'User ID cannot be empty',
            code: 'invalid_user_id',
          ),
        );
      }

      final result = await dataSource.getUserById(userId);
      
      return result.when(
        success: (userModel) => Result.success(userModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to get user by ID: ${e.toString()}',
          code: 'get_user_error',
        ),
      );
    }
  }

  @override
  Future<Result<UserEntity>> getUserByEmail(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return const Result.failure(
          ValidationException(
            message: 'Invalid email format',
            code: 'invalid_email',
          ),
        );
      }

      final result = await dataSource.getUserByEmail(email);
      
      return result.when(
        success: (userModel) => Result.success(userModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to get user by email: ${e.toString()}',
          code: 'get_user_error',
        ),
      );
    }
  }

  @override
  Future<Result<UserEntity>> createUser(UserEntity user) async {
    try {
      final validationError = _validateUser(user);
      if (validationError != null) {
        return Result.failure(validationError);
      }

      final userModel = user.toModel();
      final result = await dataSource.createUser(userModel);
      
      return result.when(
        success: (createdModel) => Result.success(createdModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to create user: ${e.toString()}',
          code: 'create_user_error',
        ),
      );
    }
  }

  @override
  Future<Result<UserEntity>> updateUser(UserEntity user) async {
    try {
      final validationError = _validateUser(user);
      if (validationError != null) {
        return Result.failure(validationError);
      }

      final userModel = user.toModel();
      final result = await dataSource.updateUser(userModel);
      
      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to update user: ${e.toString()}',
          code: 'update_user_error',
        ),
      );
    }
  }

  @override
  Future<Result<UserEntity>> updateUserStats(String userId, UserStats stats) async {
    try {
      if (userId.isEmpty) {
        return const Result.failure(
          ValidationException(
            message: 'User ID cannot be empty',
            code: 'invalid_user_id',
          ),
        );
      }

      final validationError = _validateUserStats(stats);
      if (validationError != null) {
        return Result.failure(validationError);
      }

      // Get existing user first
      final getUserResult = await dataSource.getUserById(userId);
      if (getUserResult.isFailure) {
        return Result.failure(getUserResult.error);
      }

      final existingUser = getUserResult.data!;
      final updatedUser = existingUser.copyWith(stats: stats.toModel());
      
      final result = await dataSource.updateUser(updatedUser);
      
      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to update user stats: ${e.toString()}',
          code: 'update_stats_error',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteUser(String userId) async {
    try {
      if (userId.isEmpty) {
        return const Result.failure(
          ValidationException(
            message: 'User ID cannot be empty',
            code: 'invalid_user_id',
          ),
        );
      }

      return await dataSource.deleteUser(userId);
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to delete user: ${e.toString()}',
          code: 'delete_user_error',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> userExists(String userId) async {
    try {
      if (userId.isEmpty) {
        return const Result.failure(
          ValidationException(
            message: 'User ID cannot be empty',
            code: 'invalid_user_id',
          ),
        );
      }

      return await dataSource.userExists(userId);
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to check user existence: ${e.toString()}',
          code: 'check_user_error',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserEntity>>> getUsersCreatedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (startDate.isAfter(endDate)) {
        return const Result.failure(
          ValidationException(
            message: 'Start date must be before end date',
            code: 'invalid_date_range',
          ),
        );
      }

      final result = await dataSource.getUsersCreatedBetween(startDate, endDate);
      
      return result.when(
        success: (userModels) => Result.success(
          userModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to get users by date range: ${e.toString()}',
          code: 'get_users_error',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserEntity>>> searchUsersByName(String query) async {
    try {
      if (query.length < 2) {
        return const Result.failure(
          ValidationException(
            message: 'Search query must be at least 2 characters',
            code: 'invalid_query_length',
          ),
        );
      }

      // Sanitize search query to prevent injection attacks
      final sanitizedQuery = _sanitizeSearchQuery(query);
      
      final result = await dataSource.searchUsersByName(sanitizedQuery);
      
      return result.when(
        success: (userModels) => Result.success(
          userModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to search users: ${e.toString()}',
          code: 'search_users_error',
        ),
      );
    }
  }

  @override
  Future<Result<List<UserEntity>>> getTopUsersByScore(int limit) async {
    try {
      if (limit <= 0) {
        return const Result.failure(
          ValidationException(
            message: 'Limit must be greater than 0',
            code: 'invalid_limit',
          ),
        );
      }

      // Enforce maximum limit to prevent excessive data retrieval
      final clampedLimit = limit > 100 ? 100 : limit;
      
      final result = await dataSource.getTopUsersByScore(clampedLimit);
      
      return result.when(
        success: (userModels) => Result.success(
          userModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to get top users: ${e.toString()}',
          code: 'get_top_users_error',
        ),
      );
    }
  }

  @override
  Future<Result<int>> getUserQuizCount(String userId) async {
    try {
      if (userId.isEmpty) {
        return const Result.failure(
          ValidationException(
            message: 'User ID cannot be empty',
            code: 'invalid_user_id',
          ),
        );
      }

      final getUserResult = await dataSource.getUserById(userId);
      
      return getUserResult.when(
        success: (userModel) => Result.success(
          userModel.stats?.totalQuizzes ?? 0,
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to get user quiz count: ${e.toString()}',
          code: 'get_quiz_count_error',
        ),
      );
    }
  }

  @override
  Stream<Result<UserEntity>> watchUser(String userId) {
    try {
      if (userId.isEmpty) {
        return Stream.value(
          const Result.failure(
            ValidationException(
              message: 'User ID cannot be empty',
              code: 'invalid_user_id',
            ),
          ),
        );
      }

      return dataSource.watchUser(userId).map((result) {
        return result.when(
          success: (userModel) => Result.success(userModel.toEntity()),
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          DataException(
            message: 'Failed to watch user: ${e.toString()}',
            code: 'watch_user_error',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<void>> batchUpdateUsers(List<UserEntity> users) async {
    try {
      if (users.isEmpty) {
        return const Result.failure(
          ValidationException(
            message: 'User list cannot be empty',
            code: 'empty_user_list',
          ),
        );
      }

      if (users.length > 500) {
        return const Result.failure(
          ValidationException(
            message: 'Batch size cannot exceed 500 users',
            code: 'batch_size_exceeded',
          ),
        );
      }

      // Validate all users before batch operation
      for (final user in users) {
        final validationError = _validateUser(user);
        if (validationError != null) {
          return Result.failure(validationError);
        }
      }

      final userModels = users.map((user) => user.toModel()).toList();
      
      return await dataSource.batchUpdateUsers(userModels);
    } catch (e) {
      return Result.failure(
        DataException(
          message: 'Failed to batch update users: ${e.toString()}',
          code: 'batch_update_error',
        ),
      );
    }
  }

  // ===========================
  // PRIVATE VALIDATION METHODS
  // ===========================

  /// Validate user entity
  ValidationException? _validateUser(UserEntity user) {
    if (user.name.isEmpty) {
      return const ValidationException(
        message: 'User name cannot be empty',
        code: 'invalid_user_name',
      );
    }

    if (user.name.length > 100) {
      return const ValidationException(
        message: 'User name cannot exceed 100 characters',
        code: 'invalid_user_name_length',
      );
    }

    if (!_isValidEmail(user.email)) {
      return const ValidationException(
        message: 'Invalid email format',
        code: 'invalid_email',
      );
    }

    if (user.stats != null) {
      final statsError = _validateUserStats(user.stats!);
      if (statsError != null) return statsError;
    }

    return null;
  }

  /// Validate user statistics
  ValidationException? _validateUserStats(UserStats stats) {
    if (stats.totalQuizzes < 0) {
      return const ValidationException(
        message: 'Total quizzes cannot be negative',
        code: 'invalid_total_quizzes',
      );
    }

    if (stats.totalGamesPlayed < 0) {
      return const ValidationException(
        message: 'Total games played cannot be negative',
        code: 'invalid_total_games_played',
      );
    }

    if (stats.totalGamesWon < 0) {
      return const ValidationException(
        message: 'Total games won cannot be negative',
        code: 'invalid_total_games_won',
      );
    }

    if (stats.totalGamesWon > stats.totalGamesPlayed) {
      return const ValidationException(
        message: 'Games won cannot exceed games played',
        code: 'invalid_games_won_count',
      );
    }

    if (stats.averageScore < 0 || stats.averageScore > 100) {
      return const ValidationException(
        message: 'Average score must be between 0 and 100',
        code: 'invalid_average_score',
      );
    }

    return null;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email) && 
           email.length <= 254;
  }

  /// Sanitize search query to prevent injection attacks
  String _sanitizeSearchQuery(String query) {
    return query
        .replaceAll(RegExp(r'[<>"\\/]'), '') // Remove potentially dangerous characters
        .trim()
        .toLowerCase();
  }
}