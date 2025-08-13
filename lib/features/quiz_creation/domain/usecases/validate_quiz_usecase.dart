import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for validating a quiz before publishing or playing
/// Following Clean Architecture principles from CLAUDE.md
class ValidateQuizUseCase {
  final QuizRepository _repository;

  ValidateQuizUseCase(this._repository);

  /// Execute the use case
  Future<Result<QuizValidationResult>> call(ValidateQuizParams params) async {
    // Get the quiz
    final quizResult = await _repository.getQuizById(params.quizId);

    if (quizResult.isFailure) {
      return Result.failure(quizResult.failureOrNull!);
    }

    final quiz = quizResult.dataOrNull!;

    // Perform validation
    final errors = <String>[];
    final warnings = <String>[];

    // Basic validation
    if (quiz.title.isEmpty) {
      errors.add('Quiz title is required');
    } else if (quiz.title.length < 3) {
      errors.add('Quiz title must be at least 3 characters');
    }

    if (quiz.description.isEmpty) {
      errors.add('Quiz description is required');
    } else if (quiz.description.length < 10) {
      warnings.add('Quiz description is very short');
    }

    // Question validation
    if (quiz.questions.isEmpty) {
      errors.add('Quiz must have at least one question');
    } else if (quiz.questions.length < 3) {
      warnings.add('Quiz has fewer than 3 questions');
    } else if (quiz.questions.length > 50) {
      warnings.add('Quiz has more than 50 questions, which may be too long');
    }

    // Validate each question
    for (int i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];

      if (!question.isValid) {
        errors.add('Question ${i + 1} is invalid');
      }

      // Check for duplicate questions
      final duplicates = quiz.questions
          .where((q) => q.questionText == question.questionText)
          .length;
      if (duplicates > 1) {
        warnings.add('Question ${i + 1} appears to be duplicated');
      }

      // Validate time limits
      if (question.questionTimeLimit < 5) {
        warnings.add('Question ${i + 1} has very short time limit');
      }
    }

    // Metadata validation
    if (!quiz.metadata.isValid) {
      errors.add('Quiz metadata is incomplete');
    }

    // Category validation
    if (quiz.metadata.category.isEmpty) {
      errors.add('Quiz category is required');
    }

    // Tags validation
    if (quiz.metadata.tags.isEmpty) {
      warnings.add('Adding tags helps players find your quiz');
    }

    // Language validation
    if (quiz.metadata.language.isEmpty) {
      errors.add('Quiz language is required');
    }

    // Difficulty validation
    if (quiz.metadata.difficulty.isEmpty) {
      errors.add('Quiz difficulty is required');
    }

    // Age appropriateness
    if (quiz.metadata.recommendedAge != null) {
      if (quiz.metadata.recommendedAge! < 3) {
        warnings.add('Recommended age seems too low');
      }
    }

    // Time estimation
    final estimatedMinutes = quiz.estimatedDurationMinutes;
    if (estimatedMinutes < 1) {
      warnings.add('Quiz duration is very short');
    } else if (estimatedMinutes > 30) {
      warnings.add('Quiz duration exceeds 30 minutes');
    }

    // Point distribution
    final totalPoints = quiz.totalPoints;
    if (totalPoints == 0) {
      errors.add('Quiz has no points assigned');
    }

    // Create validation result
    final isValid = errors.isEmpty;
    final validationResult = isValid
        ? QuizValidationResult.valid()
        : QuizValidationResult.invalid(errors, warnings);

    // Store validation result if needed
    if (params.storeResult) {
      return _repository.validateQuiz(params.quizId);
    }

    return Result.success(validationResult);
  }
}

/// Parameters for validating a quiz
class ValidateQuizParams {
  final String quizId;
  final bool storeResult;

  const ValidateQuizParams({required this.quizId, this.storeResult = false});
}
