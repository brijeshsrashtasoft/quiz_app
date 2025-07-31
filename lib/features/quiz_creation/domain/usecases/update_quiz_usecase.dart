import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for updating an existing quiz
/// Following Clean Architecture principles from CLAUDE.md
class UpdateQuizUseCase {
  final QuizRepository _repository;

  UpdateQuizUseCase(this._repository);

  /// Execute the use case
  Future<Result<Quiz>> call(UpdateQuizParams params) async {
    // Check if user owns the quiz
    final ownershipResult = await _repository.userOwnsQuiz(
      params.userId,
      params.quiz.id,
    );

    if (ownershipResult.isFailure) {
      return Result.failure(ownershipResult.failureOrNull!);
    }

    if (!ownershipResult.dataOrNull!) {
      return const Result.failure(
        Failure.authFailure(
          message: 'You do not have permission to update this quiz.',
          code: 'unauthorized',
        ),
      );
    }

    // Validate quiz
    if (!params.quiz.isValid) {
      return const Result.failure(
        ValidationFailure(
          message: 'Quiz validation failed. Please check all required fields.',
        ),
      );
    }

    // Check if quiz can be edited
    if (!params.quiz.canBeEditedBy(params.userId)) {
      return const Result.failure(
        ValidationFailure(
          message:
              'Published quizzes with plays cannot be edited. Clone it instead.',
        ),
      );
    }

    // Update quiz with modified timestamp
    final updatedQuiz = params.quiz.copyWith(updatedAt: DateTime.now());

    return _repository.updateQuiz(updatedQuiz);
  }
}

/// Parameters for updating a quiz
class UpdateQuizParams {
  final Quiz quiz;
  final String userId;

  const UpdateQuizParams({required this.quiz, required this.userId});
}
