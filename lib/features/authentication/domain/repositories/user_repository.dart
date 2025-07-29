import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// User repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore integration
abstract class UserRepository {
  /// Get user by ID
  Future<Result<UserEntity>> getUserById(String userId);

  /// Get user by email
  Future<Result<UserEntity>> getUserByEmail(String email);

  /// Create new user
  Future<Result<UserEntity>> createUser(UserEntity user);

  /// Update user information
  Future<Result<UserEntity>> updateUser(UserEntity user);

  /// Update user statistics
  Future<Result<UserEntity>> updateUserStats(String userId, UserStats stats);

  /// Delete user account
  Future<Result<void>> deleteUser(String userId);

  /// Check if user exists
  Future<Result<bool>> userExists(String userId);

  /// Get users created in date range
  Future<Result<List<UserEntity>>> getUsersCreatedBetween(
    DateTime startDate,
    DateTime endDate,
  );

  /// Search users by name
  Future<Result<List<UserEntity>>> searchUsersByName(String query);

  /// Get top users by average score
  Future<Result<List<UserEntity>>> getTopUsersByScore(int limit);

  /// Get user's quiz creation count
  Future<Result<int>> getUserQuizCount(String userId);

  /// Stream user data for real-time updates
  Stream<Result<UserEntity>> watchUser(String userId);

  /// Batch update multiple users (for admin operations)
  Future<Result<void>> batchUpdateUsers(List<UserEntity> users);
}
