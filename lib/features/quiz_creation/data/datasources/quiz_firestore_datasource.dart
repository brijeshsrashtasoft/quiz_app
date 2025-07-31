import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/firebase/storage_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_datasource.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/quiz_metadata_model.dart';
import '../../domain/repositories/quiz_repository.dart' show QuizStats;

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

      final quiz = QuizModel.fromFirestore(doc);
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
        return QuizModel.fromFirestore(doc);
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
        return QuizModel.fromFirestore(doc);
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
        return QuizModel.fromFirestore(doc);
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
        return QuizModel.fromFirestore(doc);
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
        return QuizModel.fromFirestore(doc);
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
        return QuizModel.fromFirestore(doc);
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

            final quiz = QuizModel.fromFirestore(doc);
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

      return Result.success(query.count ?? 0);
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

  // ============================
  // REAL-TIME AUTO-SAVE FEATURES
  // ============================

  /// Stream for real-time quiz auto-save
  /// Emits quiz data every time it's updated in Firestore
  Stream<Result<QuizModel>> watchQuizForAutoSave(String quizId) {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Setting up auto-save watch for quiz: $quizId',
      );

      return FirestoreConfig.getDocument(_collection, quizId)
          .snapshots()
          .map<Result<QuizModel>>((doc) {
            if (!doc.exists) {
              return Result.failure(
                const FirestoreException(
                  message: 'Quiz not found for auto-save',
                  code: 'quiz_not_found',
                ).toFailure(),
              );
            }

            final quiz = QuizModel.fromFirestore(doc);
            AppLogger.firebase(
              'QuizDataSource',
              'Auto-save data received for quiz: ${quiz.id}',
            );
            return Result.success(quiz);
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'Error in auto-save watch for quiz: $quizId',
              error,
              stackTrace,
            );
            return Result.failure(
              FirestoreException(
                message: 'Auto-save watch error: ${error.toString()}',
                code: 'auto_save_watch_error',
              ).toFailure(),
            );
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to setup auto-save watch for quiz: $quizId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup auto-save: ${e.toString()}',
            code: 'auto_save_setup_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Auto-save quiz with debouncing support
  /// This method should be called with a debounce timer to avoid excessive writes
  Future<Result<void>> autoSaveQuiz(QuizModel quiz) async {
    try {
      AppLogger.firebase('QuizDataSource', 'Auto-saving quiz: ${quiz.id}');

      final data = quiz.toFirestore();
      data.remove('id');
      data.remove('createdAt');
      data.remove('createdBy');

      // Add last modified timestamp
      data['lastModified'] = FieldValue.serverTimestamp();

      await FirestoreConfig.getDocument(_collection, quiz.id).update(data);

      AppLogger.firebase(
        'QuizDataSource',
        'Auto-save completed for quiz: ${quiz.id}',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to auto-save quiz: ${quiz.id}', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to auto-save quiz: ${e.toString()}',
          code: 'auto_save_error',
        ).toFailure(),
      );
    }
  }

  /// Create draft quiz for real-time editing
  Future<Result<QuizModel>> createDraftQuiz(QuizModel quiz) async {
    try {
      final startTime = DateTime.now();

      final draftQuiz = quiz.copyWith(
        isPublic: false, // Drafts are always private
      );

      final data = draftQuiz.toFirestore();
      data.remove('id');
      data['isDraft'] = true;
      data['lastModified'] = FieldValue.serverTimestamp();

      final docRef = await FirestoreConfig.quizzesCollection.add(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Create draft quiz', duration);

      final createdQuiz = draftQuiz.copyWith(id: docRef.id);

      AppLogger.firebase(
        'QuizDataSource',
        'Created draft quiz: ${createdQuiz.id}',
      );
      return Result.success(createdQuiz);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create draft quiz', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to create draft: ${e.toString()}',
          code: 'create_draft_error',
        ).toFailure(),
      );
    }
  }

  // ============================
  // FIREBASE STORAGE INTEGRATION
  // ============================

  /// Upload question image to Firebase Storage
  Future<Result<String>> uploadQuestionImage({
    required String quizId,
    required String questionId,
    required List<int> imageBytes,
    required String contentType,
  }) async {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Uploading question image for quiz: $quizId',
      );

      final imageUrl = await StorageConfig.uploadQuizImage(
        quizId: quizId,
        imageId: questionId,
        imageBytes: imageBytes,
        contentType: contentType,
      );

      return Result.success(imageUrl);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to upload question image', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to upload image: ${e.toString()}',
          code: 'upload_image_error',
        ).toFailure(),
      );
    }
  }

  /// Delete question image from Firebase Storage
  Future<Result<void>> deleteQuestionImage({
    required String quizId,
    required String questionId,
  }) async {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Deleting question image for quiz: $quizId',
      );

      await StorageConfig.deleteQuizImage(quizId: quizId, imageId: questionId);

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete question image', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to delete image: ${e.toString()}',
          code: 'delete_image_error',
        ).toFailure(),
      );
    }
  }

  /// Delete all images for a quiz
  Future<Result<void>> deleteAllQuizImages(String quizId) async {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Deleting all images for quiz: $quizId',
      );

      await StorageConfig.deleteAllQuizImages(quizId);

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete all quiz images', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to delete images: ${e.toString()}',
          code: 'delete_all_images_error',
        ).toFailure(),
      );
    }
  }

  // ============================
  // REAL-TIME COLLABORATION
  // ============================

  /// Stream quiz collaboration updates
  /// Allows multiple users to edit the same quiz in real-time
  Stream<Result<Map<String, dynamic>>> watchQuizCollaboration(String quizId) {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Setting up collaboration watch for quiz: $quizId',
      );

      // Watch a subcollection for active editors
      return FirestoreConfig.instance
          .collection(_collection)
          .doc(quizId)
          .collection('active_editors')
          .snapshots()
          .map<Result<Map<String, dynamic>>>((snapshot) {
            final editors = <String, dynamic>{};

            for (final doc in snapshot.docs) {
              editors[doc.id] = doc.data();
            }

            return Result.success({
              'editors': editors,
              'count': editors.length,
              'lastUpdate': DateTime.now().toIso8601String(),
            });
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'Error watching quiz collaboration: $quizId',
              error,
              stackTrace,
            );
            return Result.failure(
              FirestoreException(
                message: 'Collaboration watch error: ${error.toString()}',
                code: 'collaboration_watch_error',
              ).toFailure(),
            );
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to setup collaboration watch for quiz: $quizId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup collaboration: ${e.toString()}',
            code: 'collaboration_setup_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Register as active editor for a quiz
  Future<Result<void>> registerActiveEditor({
    required String quizId,
    required String userId,
    required String userName,
  }) async {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Registering active editor for quiz: $quizId',
      );

      await FirestoreConfig.instance
          .collection(_collection)
          .doc(quizId)
          .collection('active_editors')
          .doc(userId)
          .set({
            'userId': userId,
            'userName': userName,
            'joinedAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
          });

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to register active editor', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to register editor: ${e.toString()}',
          code: 'register_editor_error',
        ).toFailure(),
      );
    }
  }

  /// Unregister as active editor for a quiz
  Future<Result<void>> unregisterActiveEditor({
    required String quizId,
    required String userId,
  }) async {
    try {
      AppLogger.firebase(
        'QuizDataSource',
        'Unregistering active editor for quiz: $quizId',
      );

      await FirestoreConfig.instance
          .collection(_collection)
          .doc(quizId)
          .collection('active_editors')
          .doc(userId)
          .delete();

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to unregister active editor', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to unregister editor: ${e.toString()}',
          code: 'unregister_editor_error',
        ).toFailure(),
      );
    }
  }

  /// Update editor activity timestamp
  Future<Result<void>> updateEditorActivity({
    required String quizId,
    required String userId,
  }) async {
    try {
      await FirestoreConfig.instance
          .collection(_collection)
          .doc(quizId)
          .collection('active_editors')
          .doc(userId)
          .update({'lastActiveAt': FieldValue.serverTimestamp()});

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update editor activity', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to update activity: ${e.toString()}',
          code: 'update_activity_error',
        ).toFailure(),
      );
    }
  }

  /// Publish quiz
  Future<Result<QuizModel>> publishQuiz(String quizId) async {
    try {
      final timestamp = FieldValue.serverTimestamp();

      await FirestoreConfig.quizzesCollection.doc(quizId).update({
        'publishedAt': timestamp,
        'isDraft': false,
        'isPublic': true,
      });

      // Get updated quiz
      final doc = await FirestoreConfig.quizzesCollection.doc(quizId).get();

      if (!doc.exists) {
        return Result.failure(
          FirestoreException(
            message: 'Quiz not found after publishing',
            code: 'quiz_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return Result.success(QuizModel.fromFirestoreData(doc.id, data));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to publish quiz', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to publish quiz: ${e.toString()}',
          code: 'publish_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Unpublish quiz
  Future<Result<QuizModel>> unpublishQuiz(String quizId) async {
    try {
      await FirestoreConfig.quizzesCollection.doc(quizId).update({
        'publishedAt': null,
        'isDraft': true,
        'isPublic': false,
      });

      // Get updated quiz
      final doc = await FirestoreConfig.quizzesCollection.doc(quizId).get();

      if (!doc.exists) {
        return Result.failure(
          FirestoreException(
            message: 'Quiz not found after unpublishing',
            code: 'quiz_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return Result.success(QuizModel.fromFirestoreData(doc.id, data));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to unpublish quiz', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to unpublish quiz: ${e.toString()}',
          code: 'unpublish_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Clone quiz
  Future<Result<QuizModel>> cloneQuiz(String quizId, String newOwnerId) async {
    try {
      // Get original quiz
      final doc = await FirestoreConfig.quizzesCollection.doc(quizId).get();

      if (!doc.exists) {
        return Result.failure(
          FirestoreException(
            message: 'Original quiz not found',
            code: 'quiz_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final originalQuiz = QuizModel.fromFirestoreData(doc.id, data);

      // Create cloned quiz
      final clonedQuiz = originalQuiz.copyWith(
        id: '', // Will be assigned by Firestore
        title: '${originalQuiz.title} (Copy)',
        createdBy: newOwnerId,
        createdAt: DateTime.now(),
        updatedAt: null,
        publishedAt: null,
        isDraft: true,
        isPublic: false,
        playCount: 0,
        averageScore: 0.0,
        totalRatings: 0,
        rating: 0.0,
      );

      return createQuiz(clonedQuiz);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clone quiz', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to clone quiz: ${e.toString()}',
          code: 'clone_quiz_error',
        ).toFailure(),
      );
    }
  }

  /// Get draft quizzes for user
  Future<Result<List<QuizModel>>> getDraftQuizzes(String userId) async {
    try {
      final snapshot = await FirestoreConfig.quizzesCollection
          .where('createdBy', isEqualTo: userId)
          .where('isDraft', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .get();

      final quizzes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizModel.fromFirestoreData(doc.id, data);
      }).toList();

      AppLogger.firebase(
        'QuizDataSource',
        'Retrieved ${quizzes.length} draft quizzes for user $userId',
      );

      return Result.success(quizzes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get draft quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get draft quizzes: ${e.toString()}',
          code: 'get_draft_quizzes_error',
        ).toFailure(),
      );
    }
  }

  /// Check if user owns quiz
  Future<Result<bool>> userOwnsQuiz(String userId, String quizId) async {
    try {
      final doc = await FirestoreConfig.quizzesCollection.doc(quizId).get();

      if (!doc.exists) {
        return const Result.success(false);
      }

      final data = doc.data()!;
      final ownerId = data['createdBy'] as String;

      return Result.success(ownerId == userId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check quiz ownership', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to check ownership: ${e.toString()}',
          code: 'check_ownership_error',
        ).toFailure(),
      );
    }
  }

  /// Get quiz categories
  Future<Result<List<String>>> getQuizCategories() async {
    try {
      // In a real app, this might come from a separate collection
      // For now, return predefined categories
      const categories = [
        'Science',
        'Mathematics',
        'History',
        'Geography',
        'Literature',
        'Art',
        'Music',
        'Sports',
        'Technology',
        'General Knowledge',
      ];

      return const Result.success(categories);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get quiz categories', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get categories: ${e.toString()}',
          code: 'get_categories_error',
        ).toFailure(),
      );
    }
  }

  /// Get quiz statistics
  Future<Result<QuizStats>> getQuizStats(String quizId) async {
    try {
      final doc = await FirestoreConfig.quizzesCollection.doc(quizId).get();

      if (!doc.exists) {
        return Result.failure(
          FirestoreException(
            message: 'Quiz not found',
            code: 'quiz_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;

      return Result.success(
        QuizStats(
          totalPlays: data['playCount'] as int? ?? 0,
          totalPlayers: data['totalPlayers'] as int? ?? 0,
          averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
          lastPlayed: data['lastPlayed'] != null
              ? (data['lastPlayed'] as Timestamp).toDate()
              : DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get quiz stats', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get stats: ${e.toString()}',
          code: 'get_stats_error',
        ).toFailure(),
      );
    }
  }

  /// Batch create quizzes
  Future<Result<void>> batchCreateQuizzes(List<QuizModel> quizzes) async {
    try {
      final batch = FirestoreConfig.getBatch();

      for (final quiz in quizzes) {
        final docRef = FirestoreConfig.quizzesCollection.doc();
        final data = quiz.toFirestore();
        data.remove('id');
        batch.set(docRef, data);
      }

      await batch.commit();

      AppLogger.firebase(
        'QuizDataSource',
        'Batch created ${quizzes.length} quizzes',
      );

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to batch create quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch create: ${e.toString()}',
          code: 'batch_create_error',
        ).toFailure(),
      );
    }
  }

  /// Batch delete quizzes
  Future<Result<void>> batchDeleteQuizzes(List<String> quizIds) async {
    try {
      final batch = FirestoreConfig.getBatch();

      for (final quizId in quizIds) {
        batch.delete(FirestoreConfig.quizzesCollection.doc(quizId));
      }

      await batch.commit();

      AppLogger.firebase(
        'QuizDataSource',
        'Batch deleted ${quizIds.length} quizzes',
      );

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to batch delete quizzes', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch delete: ${e.toString()}',
          code: 'batch_delete_error',
        ).toFailure(),
      );
    }
  }
}
