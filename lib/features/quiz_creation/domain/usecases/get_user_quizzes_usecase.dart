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
    // Validate user ID
    if (params.userId.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty.'),
      );
    }

    // Get user's quizzes
    final result = await _repository.getQuizzesByUser(
      params.userId,
      limit: params.limit,
      lastCreatedAt: params.lastCreatedAt,
    );

    if (result.isFailure) {
      return result;
    }

    final quizzes = result.dataOrNull!;

    // Filter based on parameters
    List<Quiz> filteredQuizzes = quizzes;

    // Filter by status if specified
    if (params.filterByStatus != null) {
      filteredQuizzes = filteredQuizzes
          .where((quiz) => quiz.status == params.filterByStatus)
          .toList();
    }

    // Filter by draft status if specified
    if (params.includeDrafts != null) {
      if (params.includeDrafts!) {
        // Include only drafts
        filteredQuizzes = filteredQuizzes
            .where((quiz) => quiz.isDraft)
            .toList();
      } else {
        // Exclude drafts
        filteredQuizzes = filteredQuizzes
            .where((quiz) => !quiz.isDraft)
            .toList();
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
