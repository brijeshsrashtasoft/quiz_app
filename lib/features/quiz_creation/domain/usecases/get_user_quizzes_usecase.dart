import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for retrieving quizzes created by a specific user
/// Following Clean Architecture principles from CLAUDE.md
class GetUserQuizzesUseCase {
  final QuizRepository _repository;

  GetUserQuizzesUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<Quiz>>> call(GetUserQuizzesParams params) async {
    debugPrint(
      '🔍 [GetUserQuizzesUseCase] Starting with params: userId=${params.userId}, limit=${params.limit}, includeDrafts=${params.includeDrafts}',
    );

    // Validate user ID
    if (params.userId.isEmpty) {
      debugPrint('❌ [GetUserQuizzesUseCase] User ID is empty');
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty.'),
      );
    }

    debugPrint('✅ [GetUserQuizzesUseCase] User ID validated: ${params.userId}');

    // Get user's quizzes
    debugPrint(
      '🔍 [GetUserQuizzesUseCase] Calling repository.getQuizzesByUser...',
    );
    final result = await _repository.getQuizzesByUser(
      params.userId,
      limit: params.limit,
      lastCreatedAt: params.lastCreatedAt,
    );

    debugPrint(
      '🔍 [GetUserQuizzesUseCase] Repository result: ${result.isSuccess ? "SUCCESS" : "FAILURE"}',
    );

    if (result.isFailure) {
      debugPrint(
        '❌ [GetUserQuizzesUseCase] Repository call failed: ${result.failureOrNull}',
      );
      return result;
    }

    final quizzes = result.dataOrNull!;
    debugPrint(
      '✅ [GetUserQuizzesUseCase] Repository returned ${quizzes.length} quizzes',
    );

    // Filter based on parameters
    List<Quiz> filteredQuizzes = quizzes;
    debugPrint(
      '🔍 [GetUserQuizzesUseCase] Starting filtering with ${filteredQuizzes.length} quizzes',
    );

    // Filter by status if specified
    if (params.filterByStatus != null) {
      debugPrint(
        '🔍 [GetUserQuizzesUseCase] Filtering by status: ${params.filterByStatus}',
      );
      filteredQuizzes = filteredQuizzes
          .where((quiz) => quiz.status == params.filterByStatus)
          .toList();
      debugPrint(
        '🔍 [GetUserQuizzesUseCase] After status filter: ${filteredQuizzes.length} quizzes',
      );
    }

    // Filter by draft status if specified
    if (params.includeDrafts != null) {
      debugPrint(
        '🔍 [GetUserQuizzesUseCase] Filtering by draft status: includeDrafts=${params.includeDrafts}',
      );
      if (params.includeDrafts!) {
        // Include only drafts
        debugPrint('🔍 [GetUserQuizzesUseCase] Including only drafts');
        filteredQuizzes = filteredQuizzes
            .where((quiz) => quiz.isDraft)
            .toList();
        debugPrint(
          '🔍 [GetUserQuizzesUseCase] Draft quizzes found: ${filteredQuizzes.length}',
        );
      } else {
        // Exclude drafts
        debugPrint('🔍 [GetUserQuizzesUseCase] Excluding drafts');
        filteredQuizzes = filteredQuizzes
            .where((quiz) => !quiz.isDraft)
            .toList();
        debugPrint(
          '🔍 [GetUserQuizzesUseCase] Non-draft quizzes found: ${filteredQuizzes.length}',
        );
      }
    }

    // Sort based on preference
    switch (params.sortBy) {
      case QuizSortOption.createdAt:
        filteredQuizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case QuizSortOption.updatedAt:
        filteredQuizzes.sort((a, b) {
          final aUpdated = a.updatedAt ?? a.createdAt;
          final bUpdated = b.updatedAt ?? b.createdAt;
          return bUpdated.compareTo(aUpdated);
        });
        break;
      case QuizSortOption.title:
        filteredQuizzes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case QuizSortOption.playCount:
        filteredQuizzes.sort((a, b) => b.playCount.compareTo(a.playCount));
        break;
      case QuizSortOption.rating:
        filteredQuizzes.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    debugPrint(
      '✅ [GetUserQuizzesUseCase] Final result: ${filteredQuizzes.length} quizzes after filtering and sorting',
    );
    debugPrint(
      '🔍 [GetUserQuizzesUseCase] Final quiz titles: ${filteredQuizzes.map((q) => "${q.title} (isDraft: ${q.isDraft})").toList()}',
    );

    return Result.success(filteredQuizzes);
  }

  /// Get user's draft quizzes
  Future<Result<List<Quiz>>> getDrafts(String userId) async {
    return _repository.getDraftQuizzes(userId);
  }
}

/// Parameters for getting user quizzes
class GetUserQuizzesParams {
  final String userId;
  final int? limit;
  final DateTime? lastCreatedAt;
  final QuizStatus? filterByStatus;
  final bool? includeDrafts;
  final QuizSortOption sortBy;

  const GetUserQuizzesParams({
    required this.userId,
    this.limit,
    this.lastCreatedAt,
    this.filterByStatus,
    this.includeDrafts,
    this.sortBy = QuizSortOption.createdAt,
  });
}

/// Options for sorting quizzes
enum QuizSortOption { createdAt, updatedAt, title, playCount, rating }
