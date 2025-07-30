import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/quiz_repository.dart';

/// Use case for deleting a quiz
/// Following Clean Architecture principles from CLAUDE.md
class DeleteQuizUseCase {
  final QuizRepository _repository;
  
  DeleteQuizUseCase(this._repository);
  
  /// Execute the use case
  Future<Result<void>> call(DeleteQuizParams params) async {
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
          message: 'You do not have permission to delete this quiz.',
          code: 'unauthorized',
        ),
      );
    }
    
    // Get quiz to check if it can be deleted
    final quizResult = await _repository.getQuizById(params.quizId);
    if (quizResult.isFailure) {
      return Result.failure(quizResult.failureOrNull!);
    }
    
    final quiz = quizResult.dataOrNull!;
    
    // Only allow deletion of drafts or quizzes with no plays
    if (!quiz.isDraft && quiz.playCount > 0) {
      return const Result.failure(
        ValidationFailure(
          message: 'Cannot delete published quizzes that have been played. Unpublish it instead.',
        ),
      );
    }
    
    return _repository.deleteQuiz(params.quizId);
  }
}

/// Parameters for deleting a quiz
class DeleteQuizParams {
  final String quizId;
  final String userId;
  
  const DeleteQuizParams({
    required this.quizId,
    required this.userId,
  });
}