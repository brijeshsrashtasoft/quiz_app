import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

/// Use case for publishing a quiz
/// Following Clean Architecture principles from CLAUDE.md
class PublishQuizUseCase {
  final QuizRepository _repository;
  
  PublishQuizUseCase(this._repository);
  
  /// Execute the use case
  Future<Result<Quiz>> call(PublishQuizParams params) async {
    // Check if user owns the quiz
    final ownershipResult = await _repository.userOwnsQuiz(
      params.userId,
      params.quizId,
    );
    
    if (ownershipResult.isFailure) {
      return Result.failure(ownershipResult.failureOrNull!);
    }
    
    if (!ownershipResult.dataOrNull!) {
      return const Result.failure(
        Failure.authFailure(
          message: 'You do not have permission to publish this quiz.',
          code: 'unauthorized',
        ),
      );
    }
    
    // Validate quiz before publishing
    final validationResult = await _repository.validateQuiz(params.quizId);
    
    if (validationResult.isFailure) {
      return Result.failure(validationResult.failureOrNull!);
    }
    
    final validation = validationResult.dataOrNull!;
    
    if (!validation.isValid) {
      return Result.failure(
        ValidationFailure(
          message: 'Quiz validation failed',
          fieldErrors: {
            'errors': validation.errors.join(', '),
            if (validation.warnings.isNotEmpty)
              'warnings': validation.warnings.join(', '),
          },
        ),
      );
    }
    
    // Get the quiz to check current status
    final quizResult = await _repository.getQuizById(params.quizId);
    if (quizResult.isFailure) {
      return Result.failure(quizResult.failureOrNull!);
    }
    
    final quiz = quizResult.dataOrNull!;
    
    // Check if already published
    if (quiz.isPublished) {
      return const Result.failure(
        ValidationFailure(
          message: 'Quiz is already published.',
        ),
      );
    }
    
    // Publish the quiz
    final publishResult = await _repository.publishQuiz(params.quizId);
    
    if (publishResult.isFailure) {
      return publishResult;
    }
    
    // Log analytics event (future implementation)
    // await _analyticsService.logQuizPublished(params.quizId);
    
    return publishResult;
  }
}

/// Parameters for publishing a quiz
class PublishQuizParams {
  final String quizId;
  final String userId;
  
  const PublishQuizParams({
    required this.quizId,
    required this.userId,
  });
}