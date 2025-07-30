import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_datasource.dart';
import '../models/quiz_model.dart';

/// Quiz Firestore data source implementation
/// Following CLAUDE.md patterns and Firestore integration
class QuizFirestoreDataSource extends BaseFirebaseDataSource {
  static const String _collection = 'quizzes';

  /// Create new quiz
  Future<Result<QuizModel>> createQuiz(QuizModel quiz) async {
    try {
      final startTime = DateTime.now();

      final data = quiz.toFirestore();
      data.remove('id'); // Remove ID for creation

      final docRef = await FirestoreConfig.quizzesCollection.add(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Create quiz', duration);

      final createdQuiz = quiz.copyWith(id: docRef.id);

      AppLogger.firebase('QuizDataSource', 'Created quiz: ${createdQuiz.id}');
      return Result.success(createdQuiz);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create quiz', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to create quiz: ${e.toString()}',
          code: 'create_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Get quiz by ID
  Future<Result<QuizModel>> getQuizById(String quizId) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(_collection, quizId).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get quiz by ID', duration);

      if (!doc.exists) {
        return Result.failure(
          const FirestoreException(
            message: 'Quiz not found',
            code: 'quiz_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final quiz = QuizModel.fromFirestore(data);
      return Result.success(quiz);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get quiz by ID: $quizId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get quiz: ${e.toString()}',
          code: 'get_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Update quiz
  Future<Result<QuizModel>> updateQuiz(QuizModel quiz) async {
    try {
      final startTime = DateTime.now();

      final data = quiz.toFirestore();
      data.remove('id'); // Remove ID for update
      data.remove('createdAt'); // Don't update creation timestamp
      data.remove('createdBy'); // Don't change creator

      await FirestoreConfig.getDocument(_collection, quiz.id).update(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update quiz', duration);

      AppLogger.firebase('QuizDataSource', 'Updated quiz: ${quiz.id}');
      return Result.success(quiz);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update quiz: ${quiz.id}', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to update quiz: ${e.toString()}',
          code: 'update_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Delete quiz
  Future<Result<void>> deleteQuiz(String quizId) async {
    try {
      final startTime = DateTime.now();

      await FirestoreConfig.getDocument(_collection, quizId).delete();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete quiz', duration);

      AppLogger.firebase('QuizDataSource', 'Deleted quiz: $quizId');
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete quiz: $quizId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to delete quiz: ${e.toString()}',
          code: 'delete_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Get public quizzes
  Future<Result<List<QuizModel>>> getPublicQuizzes({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final startTime = DateTime.now();

      Query<Map<String, dynamic>> query = FirestoreConfig.quizzesCollection
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get public quizzes', duration);

      final quizzes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestore(data);
      }).toList();

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get public quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get public quizzes: ${e.toString()}',
          code: 'get_public_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Get quizzes by user
  Future<Result<List<QuizModel>>> getQuizzesByUser(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.quizzesCollection
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get quizzes by user', duration);

      final quizzes = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestore(data);
      }).toList();

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get quizzes by user: $userId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get user quizzes: ${e.toString()}',
          code: 'get_user_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Get quizzes by category
  Future<Result<List<QuizModel>>> getQuizzesByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.quizzesCollection
          .where('category', isEqualTo: category)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get quizzes by category', duration);

      final quizzes = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestore(data);
      }).toList();

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get quizzes by category: $category',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to get category quizzes: ${e.toString()}',
          code: 'get_category_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Search quizzes by title
  Future<Result<List<QuizModel>>> searchQuizzesByTitle(
    String searchQuery, {
    int limit = 20,
  }) async {
    try {
      final startTime = DateTime.now();

      // Firestore doesn't support full-text search, so we use prefix matching
      // In production, consider using Algolia or similar service for better search
      final query = await FirestoreConfig.quizzesCollection
          .where('isPublic', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .orderBy('title')
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Search quizzes by title', duration);

      final quizzes = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestore(data);
      }).toList();

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search quizzes: $searchQuery', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to search quizzes: ${e.toString()}',
          code: 'search_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Get popular quizzes (based on play count or recent activity)
  Future<Result<List<QuizModel>>> getPopularQuizzes({int limit = 20}) async {
    try {
      final startTime = DateTime.now();

      // For now, order by creation date - in production, add analytics
      final query = await FirestoreConfig.quizzesCollection
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get popular quizzes', duration);

      final quizzes = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestore(data);
      }).toList();

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get popular quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get popular quizzes: ${e.toString()}',
          code: 'get_popular_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Get recent quizzes
  Future<Result<List<QuizModel>>> getRecentQuizzes({
    int limit = 20,
    int daysBack = 7,
  }) async {
    try {
      final startTime = DateTime.now();

      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));

      final query = await FirestoreConfig.quizzesCollection
          .where('isPublic', isEqualTo: true)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get recent quizzes', duration);

      final quizzes = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestore(data);
      }).toList();

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get recent quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get recent quizzes: ${e.toString()}',
          code: 'get_recent_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Stream quiz data for real-time updates
  Stream<Result<QuizModel>> watchQuiz(String quizId) {
    try {
      return FirestoreConfig.getDocument(_collection, quizId)
          .snapshots()
          .map<Result<QuizModel>>((doc) {
            if (!doc.exists) {
              return Result.failure(
                const FirestoreException(
                  message: 'Quiz not found',
                  code: 'quiz_not_found',
                ).toFailure(),
              );
            }

            final data = doc.data()!;
            data['id'] = doc.id;

            final quiz = QuizModel.fromFirestore(data);
            return Result.success(quiz);
          })
          .handleError((error, stackTrace) {
            AppLogger.error('Error watching quiz: $quizId', error, stackTrace);
          });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to setup quiz watch: $quizId', e, stackTrace);
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup quiz watch: ${e.toString()}',
            code: 'watch_setup_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Batch update multiple quizzes
  Future<Result<void>> batchUpdateQuizzes(List<QuizModel> quizzes) async {
    try {
      final startTime = DateTime.now();

      final batch = FirestoreConfig.getBatch();

      for (final quiz in quizzes) {
        final data = quiz.toFirestore();
        data.remove('id');
        data.remove('createdAt');
        data.remove('createdBy');

        final docRef = FirestoreConfig.getDocument(_collection, quiz.id);
        batch.update(docRef, data);
      }

      await batch.commit();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Batch update quizzes', duration);

      AppLogger.firebase(
        'QuizDataSource',
        'Batch updated ${quizzes.length} quizzes',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to batch update quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch update quizzes: ${e.toString()}',
          code: 'batch_update_error',
        ).toFailure(),
      );
    }
  }

  /// Check if quiz exists
  Future<Result<bool>> quizExists(String quizId) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(_collection, quizId).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Check quiz exists', duration);

      return Result.success(doc.exists);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check quiz existence: $quizId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to check quiz existence: ${e.toString()}',
          code: 'check_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Get quiz count by user
  Future<Result<int>> getQuizCountByUser(String userId) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.quizzesCollection
          .where('createdBy', isEqualTo: userId)
          .count()
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get quiz count by user', duration);

      return Result.success(query.count);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get quiz count for user: $userId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to get quiz count: ${e.toString()}',
          code: 'get_quiz_count_error',
        ).toFailure(),
      );
    }
  }

  /// Get available categories
  Future<Result<List<String>>> getAvailableCategories() async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.quizzesCollection
          .where('isPublic', isEqualTo: true)
          .where('category', isNotEqualTo: null)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get available categories', duration);

      final categories = <String>{};
      for (final doc in query.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return Result.success(categories.toList()..sort());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get available categories', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get categories: ${e.toString()}',
          code: 'get_categories_error',
        ).toFailure(),
      );
    }
  }
}
