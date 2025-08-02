import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for retrieving public quizzes for home page
/// Following Clean Architecture principles from CLAUDE.md
class GetPublicQuizzesUseCase {
  final QuizRepository _repository;

  GetPublicQuizzesUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<Quiz>>> call(GetPublicQuizzesParams params) async {
    // Validate limit parameter
    if (params.limit <= 0 || params.limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100.'),
      );
    }

    // Get public quizzes
    return await _repository.getPublicQuizzes(limit: params.limit);
  }
}

/// Parameters for getting public quizzes
class GetPublicQuizzesParams {
  final int limit;

  const GetPublicQuizzesParams({
    this.limit = 20, // Default limit for home page
  });
}