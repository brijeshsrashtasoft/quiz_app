import '../../../../core/utils/result.dart';
import '../entities/question_entities.dart';

/// Question repository interface for Clean Architecture domain layer
/// Following CLAUDE.md patterns for managing individual questions
abstract class QuestionRepository {
  /// Get question by ID
  Future<Result<Question>> getQuestionById(String questionId);

  /// Create a new question
  Future<Result<Question>> createQuestion(Question question);

  /// Update an existing question
  Future<Result<Question>> updateQuestion(Question question);

  /// Delete a question
  Future<Result<void>> deleteQuestion(String questionId);

  /// Get questions for a specific quiz
  Future<Result<List<Question>>> getQuestionsByQuizId(String quizId);

  /// Batch create questions
  Future<Result<List<Question>>> batchCreateQuestions(List<Question> questions);

  /// Batch update questions
  Future<Result<List<Question>>> batchUpdateQuestions(List<Question> questions);

  /// Batch delete questions
  Future<Result<void>> batchDeleteQuestions(List<String> questionIds);

  /// Reorder questions in a quiz
  Future<Result<void>> reorderQuestions(
    String quizId,
    List<String> questionIds,
  );

  /// Upload question image
  Future<Result<String>> uploadQuestionImage(
    String questionId,
    String imagePath,
  );

  /// Delete question image
  Future<Result<void>> deleteQuestionImage(String imageUrl);

  /// Validate question uniqueness (check for duplicates)
  Future<Result<bool>> isQuestionUnique(String questionText, String quizId);

  /// Get question statistics
  Future<Result<QuestionStats>> getQuestionStats(String questionId);

  /// Import questions from CSV/JSON
  Future<Result<List<Question>>> importQuestions(
    String data,
    QuestionImportFormat format,
  );

  /// Export questions to CSV/JSON
  Future<Result<String>> exportQuestions(
    List<Question> questions,
    QuestionExportFormat format,
  );
}

/// Question statistics
class QuestionStats {
  final int timesAnswered;
  final int correctAnswers;
  final double averageTimeToAnswer;
  final Map<int, int> answerDistribution; // For multiple choice

  const QuestionStats({
    required this.timesAnswered,
    required this.correctAnswers,
    required this.averageTimeToAnswer,
    required this.answerDistribution,
  });

  double get correctPercentage {
    if (timesAnswered == 0) return 0;
    return (correctAnswers / timesAnswered) * 100;
  }

  bool get isTooEasy => correctPercentage > 90;
  bool get isTooHard => correctPercentage < 20;
}

/// Question import format
enum QuestionImportFormat {
  csv,
  json,
  xlsx;

  String get extension {
    switch (this) {
      case QuestionImportFormat.csv:
        return '.csv';
      case QuestionImportFormat.json:
        return '.json';
      case QuestionImportFormat.xlsx:
        return '.xlsx';
    }
  }
}

/// Question export format
enum QuestionExportFormat {
  csv,
  json,
  pdf;

  String get extension {
    switch (this) {
      case QuestionExportFormat.csv:
        return '.csv';
      case QuestionExportFormat.json:
        return '.json';
      case QuestionExportFormat.pdf:
        return '.pdf';
    }
  }
}
