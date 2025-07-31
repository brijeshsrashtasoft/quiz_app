import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_repository.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question_entities.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_firestore_datasource.dart';
import '../models/quiz_model.dart';

/// Quiz repository implementation for Clean Architecture
/// Following CLAUDE.md patterns and error handling
class QuizRepositoryImpl extends BaseRepository implements QuizRepository {
  final QuizFirestoreDataSource dataSource;

  QuizRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Quiz>> getQuizById(String quizId) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.getQuizById(quizId);

      return result.when(
        success: (quizModel) => Result.success(quizModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get quiz by ID: ${e.toString()}',
          code: 'get_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<Quiz>> createQuiz(Quiz quiz) async {
    try {
      final validationError = _validateQuiz(quiz);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final quizModel = QuizModel.fromEntity(quiz);
      final result = await dataSource.createQuiz(quizModel);

      return result.when(
        success: (createdModel) => Result.success(createdModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to create quiz: ${e.toString()}',
          code: 'create_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<Quiz>> updateQuiz(Quiz quiz) async {
    try {
      final validationError = _validateQuiz(quiz);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final quizModel = QuizModel.fromEntity(quiz);
      final result = await dataSource.updateQuiz(quizModel);

      return result.when(
        success: (updatedModel) => Result.success(updatedModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to update quiz: ${e.toString()}',
          code: 'update_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> deleteQuiz(String quizId) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.deleteQuiz(quizId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to delete quiz: ${e.toString()}',
          code: 'delete_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> getPublicQuizzes({
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getPublicQuizzes(limit: limit ?? 20);

      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get public quizzes: ${e.toString()}',
          code: 'get_public_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> getQuizzesByUser(
    String userId, {
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    try {
      if (userId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'User ID cannot be empty',
          ).toFailure(),
        );
      }

      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getQuizzesByUser(
        userId,
        limit: limit ?? 20,
      );

      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get quizzes by user: ${e.toString()}',
          code: 'get_user_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> getQuizzesByCategory(
    String category, {
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    try {
      if (category.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Category cannot be empty',
          ).toFailure(),
        );
      }

      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getQuizzesByCategory(
        category,
        limit: limit ?? 20,
      );

      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get quizzes by category: ${e.toString()}',
          code: 'get_category_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> searchQuizzesByTitle(String query) async {
    try {
      if (query.length < 2) {
        return Result.failure(
          const ValidationException(
            message: 'Search query must be at least 2 characters',
          ).toFailure(),
        );
      }

      // Sanitize search query to prevent injection attacks
      final sanitizedQuery = _sanitizeSearchQuery(query);

      final result = await dataSource.searchQuizzesByTitle(sanitizedQuery);

      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to search quizzes: ${e.toString()}',
          code: 'search_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> getPopularQuizzes(int limit) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getPopularQuizzes(limit: limit);

      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get popular quizzes: ${e.toString()}',
          code: 'get_popular_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> getRecentQuizzes(int limit) async {
    try {
      final validationError = _validatePaginationParams(limit);
      if (validationError != null) {
        return Result.failure(validationError.toFailure());
      }

      final result = await dataSource.getRecentQuizzes(limit: limit);

      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get recent quizzes: ${e.toString()}',
          code: 'get_recent_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<bool>> userOwnsQuiz(String userId, String quizId) async {
    try {
      if (userId.isEmpty || quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'User ID and Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.userOwnsQuiz(userId, quizId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to check quiz ownership: ${e.toString()}',
          code: 'check_ownership_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<String>>> getQuizCategories() async {
    try {
      return await dataSource.getQuizCategories();
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get quiz categories: ${e.toString()}',
          code: 'get_categories_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<QuizStats>> getQuizStats(String quizId) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      return await dataSource.getQuizStats(quizId);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get quiz stats: ${e.toString()}',
          code: 'get_quiz_stats_error',
        ).toFailure(),
      );
    }
  }

  @override
  Stream<Result<Quiz>> watchQuiz(String quizId) {
    try {
      if (quizId.isEmpty) {
        return Stream.value(
          Result.failure(
            const ValidationException(
              message: 'Quiz ID cannot be empty',
            ).toFailure(),
          ),
        );
      }

      return dataSource.watchQuiz(quizId).map((result) {
        return result.when(
          success: (quizModel) => Result.success(quizModel.toEntity()),
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch quiz: ${e.toString()}',
            code: 'watch_quiz_error',
          ).toFailure(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> batchCreateQuizzes(List<Quiz> quizzes) async {
    try {
      if (quizzes.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz list cannot be empty',
          ).toFailure(),
        );
      }

      if (quizzes.length > 500) {
        return Result.failure(
          const ValidationException(
            message: 'Batch size cannot exceed 500 quizzes',
          ).toFailure(),
        );
      }

      // Validate all quizzes before batch operation
      for (final quiz in quizzes) {
        final validationError = _validateQuiz(quiz);
        if (validationError != null) {
          return Result.failure(validationError.toFailure());
        }
      }

      final quizModels = quizzes
          .map((quiz) => QuizModel.fromEntity(quiz))
          .toList();

      return await dataSource.batchCreateQuizzes(quizModels);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to batch create quizzes: ${e.toString()}',
          code: 'batch_create_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> batchDeleteQuizzes(List<String> quizIds) async {
    try {
      if (quizIds.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID list cannot be empty',
          ).toFailure(),
        );
      }

      if (quizIds.length > 500) {
        return Result.failure(
          const ValidationException(
            message: 'Batch size cannot exceed 500 quiz IDs',
          ).toFailure(),
        );
      }

      return await dataSource.batchDeleteQuizzes(quizIds);
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to batch delete quizzes: ${e.toString()}',
          code: 'batch_delete_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<Quiz>> publishQuiz(String quizId) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      // First validate the quiz
      final validationResult = await validateQuiz(quizId);
      return validationResult.when(
        success: (validation) async {
          if (!validation.isValid) {
            return Result.failure(
              ValidationException(
                message:
                    'Quiz validation failed: ${validation.errors.join(', ')}',
              ).toFailure(),
            );
          }

          // If valid, publish the quiz
          final result = await dataSource.publishQuiz(quizId);
          return result.when(
            success: (quizModel) => Result.success(quizModel.toEntity()),
            failure: (error) => Result.failure(error),
          );
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to publish quiz: ${e.toString()}',
          code: 'publish_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<Quiz>> unpublishQuiz(String quizId) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.unpublishQuiz(quizId);
      return result.when(
        success: (quizModel) => Result.success(quizModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to unpublish quiz: ${e.toString()}',
          code: 'unpublish_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<Quiz>> cloneQuiz(String quizId, String newOwnerId) async {
    try {
      if (quizId.isEmpty || newOwnerId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID and new owner ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.cloneQuiz(quizId, newOwnerId);
      return result.when(
        success: (quizModel) => Result.success(quizModel.toEntity()),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to clone quiz: ${e.toString()}',
          code: 'clone_quiz_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<List<Quiz>>> getDraftQuizzes(String userId) async {
    try {
      if (userId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'User ID cannot be empty',
          ).toFailure(),
        );
      }

      final result = await dataSource.getDraftQuizzes(userId);
      return result.when(
        success: (quizModels) => Result.success(
          quizModels.map((model) => model.toEntity()).toList(),
        ),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get draft quizzes: ${e.toString()}',
          code: 'get_draft_quizzes_error',
        ).toFailure(),
      );
    }
  }

  @override
  Future<Result<QuizValidationResult>> validateQuiz(String quizId) async {
    try {
      if (quizId.isEmpty) {
        return Result.failure(
          const ValidationException(
            message: 'Quiz ID cannot be empty',
          ).toFailure(),
        );
      }

      // Get the quiz first
      final quizResult = await getQuizById(quizId);
      return quizResult.when(
        success: (quiz) {
          final errors = <String>[];
          final warnings = <String>[];

          // Validate quiz structure
          final validationError = _validateQuiz(quiz);
          if (validationError != null) {
            errors.add(validationError.message);
          }

          // Additional publishing requirements
          if (!quiz.isValid) {
            errors.add('Quiz does not meet basic validity requirements');
          }

          if (quiz.questions.length < 3) {
            warnings.add(
              'Quiz has less than 3 questions, may not be suitable for multiplayer',
            );
          }

          if (quiz.metadata.coverImageUrl == null ||
              quiz.metadata.coverImageUrl!.isEmpty) {
            warnings.add('Quiz does not have a cover image');
          }

          return Result.success(
            errors.isEmpty
                ? QuizValidationResult.valid()
                : QuizValidationResult.invalid(errors, warnings),
          );
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to validate quiz: ${e.toString()}',
          code: 'validate_quiz_error',
        ).toFailure(),
      );
    }
  }

  // ===========================
  // PRIVATE VALIDATION METHODS
  // ===========================

  /// Validate quiz entity
  ValidationException? _validateQuiz(Quiz quiz) {
    if (quiz.title.isEmpty) {
      return const ValidationException(message: 'Quiz title cannot be empty');
    }

    if (quiz.title.length > 200) {
      return const ValidationException(
        message: 'Quiz title cannot exceed 200 characters',
      );
    }

    if (quiz.description.isEmpty) {
      return const ValidationException(
        message: 'Quiz description cannot be empty',
      );
    }

    if (quiz.description.length > 1000) {
      return const ValidationException(
        message: 'Quiz description cannot exceed 1000 characters',
      );
    }

    if (quiz.createdBy.isEmpty) {
      return const ValidationException(message: 'Creator ID cannot be empty');
    }

    if (quiz.questions.isEmpty) {
      return const ValidationException(
        message: 'Quiz must have at least one question',
      );
    }

    if (quiz.questions.length > 100) {
      return const ValidationException(
        message: 'Quiz cannot have more than 100 questions',
      );
    }

    // Validate each question
    for (int i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      final questionError = _validateQuestion(question, i + 1);
      if (questionError != null) return questionError;
    }

    if (quiz.metadata.category.length > 100) {
      return const ValidationException(
        message: 'Category name cannot exceed 100 characters',
      );
    }

    if (quiz.metadata.estimatedDuration != null) {
      if (quiz.metadata.estimatedDuration! < 1 ||
          quiz.metadata.estimatedDuration! > 1440) {
        return const ValidationException(
          message: 'Estimated duration must be between 1 and 1440 minutes',
        );
      }
    }

    return null;
  }

  /// Validate question entity
  ValidationException? _validateQuestion(Question question, int index) {
    // Get question options for validation
    final options = question.options;

    if (question.questionText.isEmpty) {
      return ValidationException(
        message: 'Question $index text cannot be empty',
      );
    }

    if (question.questionText.length > 500) {
      return ValidationException(
        message: 'Question $index text cannot exceed 500 characters',
      );
    }

    if (options.length < 2) {
      return ValidationException(
        message: 'Question $index must have at least 2 options',
      );
    }

    if (options.length > 6) {
      return ValidationException(
        message: 'Question $index cannot have more than 6 options',
      );
    }

    for (int i = 0; i < options.length; i++) {
      if (options[i].isEmpty) {
        return ValidationException(
          message: 'Question $index option ${i + 1} cannot be empty',
        );
      }

      if (options[i].length > 200) {
        return ValidationException(
          message:
              'Question $index option ${i + 1} cannot exceed 200 characters',
        );
      }
    }

    if (question.correctAnswerIndex < 0 ||
        question.correctAnswerIndex >= options.length) {
      return ValidationException(
        message: 'Question $index has invalid correct answer index',
      );
    }

    if (question.questionTimeLimit < 5 || question.questionTimeLimit > 300) {
      return ValidationException(
        message: 'Question $index time limit must be between 5 and 300 seconds',
      );
    }

    if (question.questionPoints < 10 || question.questionPoints > 1000) {
      return ValidationException(
        message: 'Question $index points must be between 10 and 1000',
      );
    }

    return null;
  }

  /// Validate pagination parameters
  ValidationException? _validatePaginationParams(int? limit) {
    if (limit != null) {
      if (limit <= 0) {
        return const ValidationException(
          message: 'Limit must be greater than 0',
        );
      }

      if (limit > 100) {
        return const ValidationException(message: 'Limit cannot exceed 100');
      }
    }

    return null;
  }

  /// Sanitize search query to prevent injection attacks
  String _sanitizeSearchQuery(String query) {
    return query
        .replaceAll(
          RegExp(r'[<>"\\/]'),
          '',
        ) // Remove potentially dangerous characters
        .trim()
        .toLowerCase();
  }
}
