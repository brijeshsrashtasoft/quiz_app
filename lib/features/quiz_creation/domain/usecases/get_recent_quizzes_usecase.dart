import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for retrieving recent quizzes for home page
/// Following Clean Architecture principles from CLAUDE.md
class GetRecentQuizzesUseCase {
  final QuizRepository _repository;

  GetRecentQuizzesUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<Quiz>>> call(GetRecentQuizzesParams params) async {
    // Validate limit parameter
    if (params.limit <= 0 || params.limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100.'),
      );
    }

    // Get recent quizzes (sorted by creation date)
    return await _repository.getRecentQuizzes(params.limit);
  }
}

/// Parameters for getting recent quizzes
class GetRecentQuizzesParams {
  final int limit;

  const GetRecentQuizzesParams({
    this.limit = 20, // Default limit for home page
  });
}