import '../../../../core/utils/result.dart';
import '../entities/quiz.dart';

/// Quiz repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore integration
abstract class QuizRepository {
  /// Get quiz by ID
  Future<Result<Quiz>> getQuizById(String quizId);

  /// Create new quiz
  Future<Result<Quiz>> createQuiz(Quiz quiz);

  /// Update existing quiz
  Future<Result<Quiz>> updateQuiz(Quiz quiz);

  /// Delete quiz
  Future<Result<void>> deleteQuiz(String quizId);

  /// Get all public quizzes
  Future<Result<List<Quiz>>> getPublicQuizzes({
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Get quizzes created by specific user
  Future<Result<List<Quiz>>> getQuizzesByUser(
    String userId, {
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Get quizzes by category
  Future<Result<List<Quiz>>> getQuizzesByCategory(
    String category, {
    int? limit,
    DateTime? lastCreatedAt,
  });

  /// Search quizzes by title
  Future<Result<List<Quiz>>> searchQuizzesByTitle(String query);

  /// Get popular quizzes (most played)
  Future<Result<List<Quiz>>> getPopularQuizzes(int limit);

  /// Get recent quizzes
  Future<Result<List<Quiz>>> getRecentQuizzes(int limit);

  /// Check if user owns quiz
  Future<Result<bool>> userOwnsQuiz(String userId, String quizId);

  /// Get quiz categories
  Future<Result<List<String>>> getQuizCategories();

  /// Get quiz statistics
  Future<Result<QuizStats>> getQuizStats(String quizId);

  /// Stream quiz data for real-time updates
  Stream<Result<Quiz>> watchQuiz(String quizId);

  /// Batch operations for quiz management
  Future<Result<void>> batchCreateQuizzes(List<Quiz> quizzes);
  Future<Result<void>> batchDeleteQuizzes(List<String> quizIds);
  
  /// Publish quiz (make it available for playing)
  Future<Result<Quiz>> publishQuiz(String quizId);
  
  /// Unpublish quiz
  Future<Result<Quiz>> unpublishQuiz(String quizId);
  
  /// Clone quiz
  Future<Result<Quiz>> cloneQuiz(String quizId, String newOwnerId);
  
  /// Get draft quizzes for user
  Future<Result<List<Quiz>>> getDraftQuizzes(String userId);
  
  /// Validate quiz before publishing
  Future<Result<QuizValidationResult>> validateQuiz(String quizId);
}

/// Quiz statistics data model
class QuizStats {
  final int totalPlays;
  final int totalPlayers;
  final double averageScore;
  final DateTime lastPlayed;
  final Map<String, dynamic>? additionalStats;

  const QuizStats({
    required this.totalPlays,
    required this.totalPlayers,
    required this.averageScore,
    required this.lastPlayed,
    this.additionalStats,
  });
  
  double get completionRate {
    if (totalPlays == 0) return 0;
    return (totalPlayers / totalPlays) * 100;
  }
}

/// Quiz validation result
class QuizValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const QuizValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  
  factory QuizValidationResult.valid() => const QuizValidationResult(
    isValid: true,
    errors: [],
    warnings: [],
  );
  
  factory QuizValidationResult.invalid(List<String> errors, [List<String>? warnings]) => QuizValidationResult(
    isValid: false,
    errors: errors,
    warnings: warnings ?? [],
  );
}
