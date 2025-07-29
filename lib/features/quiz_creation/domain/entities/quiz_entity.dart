import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_entity.freezed.dart';

/// Quiz entity for Clean Architecture domain layer
/// Following CLAUDE.md patterns and Firestore structure
@freezed
class QuizEntity with _$QuizEntity {
  const factory QuizEntity({
    required String id,
    required String title,
    required String description,
    required String createdBy,
    required List<QuestionEntity> questions,
    required bool isPublic,
    required DateTime createdAt,
    String? category,
    int? estimatedDuration,
  }) = _QuizEntity;
}

/// Question entity matching Firestore schema
@freezed
class QuestionEntity with _$QuestionEntity {
  const factory QuestionEntity({
    required String question,
    required List<String> options,
    required int correctAnswer,
    required int timeLimit,
    @Default(100) int points,
  }) = _QuestionEntity;
}

/// Quiz entity extensions for business logic
extension QuizEntityX on QuizEntity {
  /// Check if quiz is valid for gameplay
  bool get isValid {
    return title.isNotEmpty &&
        questions.isNotEmpty &&
        questions.every((q) => q.isValid);
  }

  /// Get total points possible for this quiz
  int get totalPoints {
    return questions.fold(0, (sum, question) => sum + question.points);
  }

  /// Get estimated duration in minutes
  int get estimatedDurationMinutes {
    if (estimatedDuration != null) return estimatedDuration!;

    // Calculate based on question time limits
    final totalSeconds = questions.fold(0, (sum, q) => sum + q.timeLimit);
    return (totalSeconds / 60).ceil();
  }

  /// Check if quiz is owned by specific user
  bool isOwnedBy(String userId) {
    return createdBy == userId;
  }

  /// Get question count
  int get questionCount => questions.length;

  /// Check if quiz is suitable for multiplayer
  bool get isMultiplayerSuitable {
    return questions.length >= 3 && questions.length <= 50;
  }
}

/// Question entity extensions
extension QuestionEntityX on QuestionEntity {
  /// Check if question is valid
  bool get isValid {
    return question.isNotEmpty &&
        options.length >= 2 &&
        options.length <= 6 &&
        correctAnswer >= 0 &&
        correctAnswer < options.length &&
        timeLimit > 0 &&
        timeLimit <= 300 &&
        points > 0;
  }

  /// Check if question is multiple choice
  bool get isMultipleChoice => options.length > 2;

  /// Get difficulty based on time limit and points
  QuestionDifficulty get difficulty {
    if (timeLimit <= 15 && points >= 200) return QuestionDifficulty.hard;
    if (timeLimit <= 25 && points >= 150) return QuestionDifficulty.medium;
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
}
