import '../../../../core/utils/result.dart';
import '../entities/quiz_entity.dart';

/// Quiz repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore integration
abstract class QuizRepository {
  /// Get quiz by ID
  Future<Result<QuizEntity>> getQuizById(String quizId);

  /// Create new quiz
  Future<Result<QuizEntity>> createQuiz(QuizEntity quiz);

  /// Update existing quiz
  Future<Result<QuizEntity>> updateQuiz(QuizEntity quiz);

  /// Delete quiz
  Future<Result<void>> deleteQuiz(String quizId);

  /// Get all public quizzes
  Future<Result<List<QuizEntity>>> getPublicQuizzes({
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Get quizzes created by specific user
  Future<Result<List<QuizEntity>>> getQuizzesByUser(
    String userId, {
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Get quizzes by category
  Future<Result<List<QuizEntity>>> getQuizzesByCategory(
    String category, {
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Search quizzes by title
  Future<Result<List<QuizEntity>>> searchQuizzesByTitle(String query);

  /// Get popular quizzes (most played)
  Future<Result<List<QuizEntity>>> getPopularQuizzes(int limit);

  /// Get recent quizzes
  Future<Result<List<QuizEntity>>> getRecentQuizzes(int limit);

  /// Check if user owns quiz
  Future<Result<bool>> userOwnsQuiz(String userId, String quizId);

  /// Get quiz categories
  Future<Result<List<String>>> getQuizCategories();

  /// Get quiz statistics
  Future<Result<QuizStats>> getQuizStats(String quizId);

  /// Stream quiz data for real-time updates
  Stream<Result<QuizEntity>> watchQuiz(String quizId);

  /// Batch operations for quiz management
  Future<Result<void>> batchCreateQuizzes(List<QuizEntity> quizzes);
  Future<Result<void>> batchDeleteQuizzes(List<String> quizIds);
}

/// Quiz statistics data model
class QuizStats {
  final int totalPlays;
  final int totalPlayers;
  final double averageScore;
  final DateTime lastPlayed;

  const QuizStats({
    required this.totalPlays,
    required this.totalPlayers,
    required this.averageScore,
    required this.lastPlayed,
  });
}
