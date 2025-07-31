import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for retrieving a quiz by ID
/// Following Clean Architecture principles from CLAUDE.md
class GetQuizByIdUseCase {
  final QuizRepository _repository;

  GetQuizByIdUseCase(this._repository);

  /// Execute the use case
  Future<Result<Quiz>> call(GetQuizByIdParams params) async {
    // Validate quiz ID
    if (params.quizId.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Quiz ID cannot be empty.'),
      );
    }

    // Get the quiz
    final quizResult = await _repository.getQuizById(params.quizId);

    if (quizResult.isFailure) {
      return quizResult;
    }

    final quiz = quizResult.dataOrNull!;

    // Check access permissions
    if (!quiz.isPublic && !quiz.isDraft) {
      // For private quizzes, check if user is the owner
      if (params.userId != null && quiz.isOwnedBy(params.userId!)) {
        return quizResult;
      } else {
        return const Result.failure(
          Failure.authFailure(
            message: 'You do not have permission to view this quiz.',
            code: 'access_denied',
          ),
        );
      }
    }

    return quizResult;
  }

  /// Get quiz stream for real-time updates
  Stream<Result<Quiz>> watchQuiz(String quizId) {
    return _repository.watchQuiz(quizId);
  }
}

/// Parameters for getting a quiz by ID
class GetQuizByIdParams {
  final String quizId;
  final String? userId; // Optional, used for permission checking

  const GetQuizByIdParams({required this.quizId, this.userId});
}
