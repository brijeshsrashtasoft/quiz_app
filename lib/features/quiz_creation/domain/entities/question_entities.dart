import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_entities.freezed.dart';

/// Base Question entity for polymorphic question types
/// Following Clean Architecture principles from CLAUDE.md
@freezed
class Question with _$Question {
  const Question._();
  
  const factory Question.multipleChoice({
    required String id,
    required String question,
    required List<String> options,
    required int correctAnswer,
    required int timeLimit,
    @Default(100) int points,
    String? imageUrl,
    String? explanation,
  }) = MultipleChoiceQuestion;
  
  const factory Question.trueFalse({
    required String id,
    required String question,
    required bool correctAnswer,
    required int timeLimit,
    @Default(100) int points,
    String? imageUrl,
    String? explanation,
  }) = TrueFalseQuestion;
  
  /// Common getters for all question types
  String get questionText => when(
    multipleChoice: (_, question, _, _, _, _, _, _) => question,
    trueFalse: (_, question, _, _, _, _, _) => question,
  );
  
  int get questionTimeLimit => when(
    multipleChoice: (_, _, _, _, timeLimit, _, _, _) => timeLimit,
    trueFalse: (_, _, _, timeLimit, _, _, _) => timeLimit,
  );
  
  int get questionPoints => when(
    multipleChoice: (_, _, _, _, _, points, _, _) => points,
    trueFalse: (_, _, _, _, points, _, _) => points,
  );
  
  String? get questionImageUrl => when(
    multipleChoice: (_, _, _, _, _, _, imageUrl, _) => imageUrl,
    trueFalse: (_, _, _, _, _, imageUrl, _) => imageUrl,
  );
  
  String? get questionExplanation => when(
    multipleChoice: (_, _, _, _, _, _, _, explanation) => explanation,
    trueFalse: (_, _, _, _, _, _, explanation) => explanation,
  );
  
  /// Get options list (for validation purposes)
  List<String> get options => when(
    multipleChoice: (_, _, options, _, _, _, _, _) => options,
    trueFalse: (_, _, _, _, _, _, _) => ['True', 'False'],
  );
  
  /// Get correct answer index (for validation purposes)
  int get correctAnswerIndex => when(
    multipleChoice: (_, _, _, correctAnswer, _, _, _, _) => correctAnswer,
    trueFalse: (_, _, correctAnswer, _, _, _, _) => correctAnswer ? 0 : 1,
  );
}

/// Extension methods for Question validation
extension QuestionValidation on Question {
  /// Validate question based on type
  bool get isValid => when(
    multipleChoice: (_, question, options, correctAnswer, timeLimit, points, _, _) {
      return question.isNotEmpty &&
          options.length >= 2 &&
          options.length <= 6 &&
          options.every((option) => option.isNotEmpty) &&
          correctAnswer >= 0 &&
          correctAnswer < options.length &&
          timeLimit >= 5 &&
          timeLimit <= 300 &&
          points > 0 &&
          points <= 1000;
    },
    trueFalse: (_, question, _, timeLimit, points, _, _) {
      return question.isNotEmpty &&
          timeLimit >= 5 &&
          timeLimit <= 300 &&
          points > 0 &&
          points <= 1000;
    },
  );
  
  /// Get question type as string
  String get type => when(
    multipleChoice: (_, _, _, _, _, _, _, _) => 'multiple_choice',
    trueFalse: (_, _, _, _, _, _, _) => 'true_false',
  );
  
  /// Check if question has media
  bool get hasMedia => questionImageUrl != null && questionImageUrl!.isNotEmpty;
  
  /// Get difficulty based on time and points
  QuestionDifficulty get difficulty {
    final time = questionTimeLimit;
    final pts = questionPoints;
    
    if (time <= 15 && pts >= 200) return QuestionDifficulty.hard;
    if (time <= 25 && pts >= 150) return QuestionDifficulty.medium;
    return QuestionDifficulty.easy;
  }
}

/// Question difficulty levels
enum QuestionDifficulty {
  easy,
  medium,
  hard;
  
  String get displayName {
    switch (this) {
      case QuestionDifficulty.easy:
        return 'Easy';
      case QuestionDifficulty.medium:
        return 'Medium';
      case QuestionDifficulty.hard:
        return 'Hard';
    }
  }
  
  /// Get default time limit for difficulty
  int get defaultTimeLimit {
    switch (this) {
      case QuestionDifficulty.easy:
        return 30;
      case QuestionDifficulty.medium:
        return 20;
      case QuestionDifficulty.hard:
        return 15;
    }
  }
  
  /// Get default points for difficulty
  int get defaultPoints {
    switch (this) {
      case QuestionDifficulty.easy:
        return 100;
      case QuestionDifficulty.medium:
        return 150;
      case QuestionDifficulty.hard:
        return 200;
    }
  }
}