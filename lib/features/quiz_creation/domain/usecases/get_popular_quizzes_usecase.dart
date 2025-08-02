import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for retrieving popular quizzes for home page
/// Following Clean Architecture principles from CLAUDE.md
class GetPopularQuizzesUseCase {
  final QuizRepository _repository;

  GetPopularQuizzesUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<Quiz>>> call(GetPopularQuizzesParams params) async {
    // Validate limit parameter
    if (params.limit <= 0 || params.limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100.'),
      );
    }

    // Get popular quizzes (sorted by play count and rating)
    return await _repository.getPopularQuizzes(params.limit);
  }
}

/// Parameters for getting popular quizzes
class GetPopularQuizzesParams {
  final int limit;

  const GetPopularQuizzesParams({
    this.limit = 20, // Default limit for home page
  });
}