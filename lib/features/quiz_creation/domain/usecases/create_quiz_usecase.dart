import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for creating a new quiz
/// Following Clean Architecture principles from CLAUDE.md
class CreateQuizUseCase {
  final QuizRepository _repository;

  CreateQuizUseCase(this._repository);

  /// Execute the use case
  Future<Result<Quiz>> call(CreateQuizParams params) async {
    // Validate quiz before creation
    if (!params.quiz.isValid) {
      return const Result.failure(
        ValidationFailure(
          message: 'Quiz validation failed. Please check all required fields.',
        ),
      );
    }

    // Ensure quiz has at least minimum questions
    if (params.quiz.questions.length < 3) {
      return const Result.failure(
        ValidationFailure(message: 'Quiz must have at least 3 questions.'),
      );
    }

    // Create quiz with draft status if not specified
    final quizToCreate = params.quiz.copyWith(
      createdAt: DateTime.now(),
      isDraft: params.quiz.isDraft,
      publishedAt: params.quiz.isDraft ? null : DateTime.now(),
    );

    return _repository.createQuiz(quizToCreate);
  }
}

/// Parameters for creating a quiz
class CreateQuizParams {
  final Quiz quiz;

  const CreateQuizParams({required this.quiz});
}
