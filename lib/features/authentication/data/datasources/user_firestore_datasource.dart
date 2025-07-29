import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../models/user_model.dart';

/// User Firestore data source implementation
/// Following CLAUDE.md patterns and Firestore integration
class UserFirestoreDataSource {
  static const String _collection = 'users';

  /// Get user by ID
  Future<Result<UserModel>> getUserById(String userId) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(_collection, userId).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get user by ID', duration);

      if (!doc.exists) {
        return Result.failure(
          DataException(message: 'User not found', code: 'user_not_found'),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final user = UserModel.fromFirestore(data);
      return Result.success(user);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get user by ID: $userId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get user: ${e.toString()}',
          code: 'get_user_error',
        ),
      );
    }
  }

  /// Get user by email
  Future<Result<UserModel>> getUserByEmail(String email) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get user by email', duration);

      if (query.docs.isEmpty) {
        return Result.failure(
          DataException(message: 'User not found', code: 'user_not_found'),
        );
      }

      final doc = query.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      final user = UserModel.fromFirestore(data);
      return Result.success(user);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get user by email: $email', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get user: ${e.toString()}',
          code: 'get_user_error',
        ),
      );
    }
  }

  /// Create new user
  Future<Result<UserModel>> createUser(UserModel user) async {
    try {
      final startTime = DateTime.now();

      final data = user.toFirestore();
      data.remove('id'); // Remove ID for creation

      final docRef = await FirestoreConfig.usersCollection.add(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Create user', duration);

      final createdUser = user.copyWith(id: docRef.id);

      AppLogger.firebase('UserDataSource', 'Created user: ${createdUser.id}');
      return Result.success(createdUser);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create user', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to create user: ${e.toString()}',
          code: 'create_user_error',
        ),
      );
    }
  }

  /// Update user
  Future<Result<UserModel>> updateUser(UserModel user) async {
    try {
      final startTime = DateTime.now();

      final data = user.toFirestore();
      data.remove('id'); // Remove ID for update
      data.remove('createdAt'); // Don't update creation timestamp

      await FirestoreConfig.getDocument(_collection, user.id).update(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update user', duration);

      AppLogger.firebase('UserDataSource', 'Updated user: ${user.id}');
      return Result.success(user);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update user: ${user.id}', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to update user: ${e.toString()}',
          code: 'update_user_error',
        ),
      );
    }
  }

  /// Delete user
  Future<Result<void>> deleteUser(String userId) async {
    try {
      final startTime = DateTime.now();

      await FirestoreConfig.getDocument(_collection, userId).delete();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete user', duration);

      AppLogger.firebase('UserDataSource', 'Deleted user: $userId');
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete user: $userId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to delete user: ${e.toString()}',
          code: 'delete_user_error',
        ),
      );
    }
  }

  /// Check if user exists
  Future<Result<bool>> userExists(String userId) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(_collection, userId).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Check user exists', duration);

      return Result.success(doc.exists);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check user existence: $userId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to check user existence: ${e.toString()}',
          code: 'check_user_error',
        ),
      );
    }
  }

  /// Get users created between dates
  Future<Result<List<UserModel>>> getUsersCreatedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.usersCollection
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get users by date range', duration);

      final users = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromFirestore(data);
      }).toList();

      return Result.success(users);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get users by date range', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get users: ${e.toString()}',
          code: 'get_users_error',
        ),
      );
    }
  }

  /// Search users by name
  Future<Result<List<UserModel>>> searchUsersByName(String query) async {
    try {
      final startTime = DateTime.now();

      // Firestore doesn't support full-text search, so we use array-contains
      // This is a simplified implementation - in production, consider using Algolia
      final firestoreQuery = await FirestoreConfig.usersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Search users by name', duration);

      final users = firestoreQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromFirestore(data);
      }).toList();

      return Result.success(users);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search users by name: $query', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to search users: ${e.toString()}',
          code: 'search_users_error',
        ),
      );
    }
  }

  /// Get top users by average score
  Future<Result<List<UserModel>>> getTopUsersByScore(int limit) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.usersCollection
          .where('stats.averageScore', isGreaterThan: 0)
          .orderBy('stats.averageScore', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get top users by score', duration);

      final users = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromFirestore(data);
      }).toList();

      return Result.success(users);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get top users by score', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get top users: ${e.toString()}',
          code: 'get_top_users_error',
        ),
      );
    }
  }

  /// Stream user data for real-time updates
  Stream<Result<UserModel>> watchUser(String userId) {
    try {
      return FirestoreConfig.getDocument(_collection, userId)
          .snapshots()
          .map<Result<UserModel>>((doc) {
            if (!doc.exists) {
              return Result.failure(
                DataException(
                  message: 'User not found',
                  code: 'user_not_found',
                ),
              );
            }

            final data = doc.data()!;
            data['id'] = doc.id;

            final user = UserModel.fromFirestore(data);
            return Result.success(user);
          })
          .handleError((error, stackTrace) {
            AppLogger.error('Error watching user: $userId', error, stackTrace);
          });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to setup user watch: $userId', e, stackTrace);
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup user watch: ${e.toString()}',
            code: 'watch_setup_error',
          ),
        ),
      );
    }
  }

  /// Batch update multiple users
  Future<Result<void>> batchUpdateUsers(List<UserModel> users) async {
    try {
      final startTime = DateTime.now();

      final batch = FirestoreConfig.getBatch();

      for (final user in users) {
        final data = user.toFirestore();
        data.remove('id');
        data.remove('createdAt');

        final docRef = FirestoreConfig.getDocument(_collection, user.id);
        batch.update(docRef, data);
      }

      await batch.commit();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Batch update users', duration);

      AppLogger.firebase(
        'UserDataSource',
        'Batch updated ${users.length} users',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to batch update users', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch update users: ${e.toString()}',
          code: 'batch_update_error',
        ),
      );
    }
  }
}
