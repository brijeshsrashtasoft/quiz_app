import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_entities.dart';

part 'quiz.freezed.dart';

/// Quiz entity with comprehensive metadata
/// Following Clean Architecture principles from CLAUDE.md
@freezed
class Quiz with _$Quiz {
  const Quiz._();
  
  const factory Quiz({
    required String id,
    required String title,
    required String description,
    required String createdBy,
    required List<Question> questions,
    required bool isPublic,
    required DateTime createdAt,
    required QuizMetadata metadata,
    DateTime? updatedAt,
    DateTime? publishedAt,
    @Default(false) bool isDraft,
    @Default(0) int playCount,
    @Default(0.0) double averageScore,
    @Default(0) int totalRatings,
    @Default(0.0) double rating,
  }) = _Quiz;
  
  /// Check if quiz is valid for gameplay
  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        questions.isNotEmpty &&
        questions.every((q) => q.isValid) &&
        metadata.isValid;
  }
  
  /// Get total points possible for this quiz
  int get totalPoints {
    return questions.fold(0, (sum, question) => sum + question.questionPoints);
  }
  
  /// Get estimated duration in minutes
  int get estimatedDurationMinutes {
    if (metadata.estimatedDuration != null) return metadata.estimatedDuration!;
    
    // Calculate based on question time limits
    final totalSeconds = questions.fold(0, (sum, q) => sum + q.questionTimeLimit);
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
    return questions.length >= 3 && 
           questions.length <= 50 &&
           !isDraft &&
           isValid;
  }
  
  /// Check if quiz is published
  bool get isPublished => publishedAt != null && !isDraft;
  
  /// Check if quiz can be edited
  bool canBeEditedBy(String userId) {
    return isOwnedBy(userId) && (isDraft || playCount == 0);
  }
  
  /// Get quiz status
  QuizStatus get status {
    if (isDraft) return QuizStatus.draft;
    if (publishedAt == null) return QuizStatus.private;
    if (isPublic) return QuizStatus.public;
    return QuizStatus.private;
  }
}

/// Quiz metadata for additional information
@freezed
class QuizMetadata with _$QuizMetadata {
  const QuizMetadata._();
  
  const factory QuizMetadata({
    required String category,
    required List<String> tags,
    required String difficulty,
    required String language,
    String? coverImageUrl,
    String? targetAudience,
    int? estimatedDuration,
    int? recommendedAge,
    Map<String, dynamic>? customProperties,
  }) = _QuizMetadata;
  
  /// Validate metadata
  bool get isValid {
    return category.isNotEmpty &&
           tags.isNotEmpty &&
           difficulty.isNotEmpty &&
           language.isNotEmpty;
  }
  
  /// Check if quiz is suitable for age
  bool isSuitableForAge(int age) {
    if (recommendedAge == null) return true;
    return age >= recommendedAge!;
  }
}

/// Quiz status enumeration
enum QuizStatus {
  draft,
  private,
  public;
  
  String get displayName {
    switch (this) {
      case QuizStatus.draft:
        return 'Draft';
      case QuizStatus.private:
        return 'Private';
      case QuizStatus.public:
        return 'Public';
    }
  }
  
  bool get canBePublished => this != QuizStatus.public;
  bool get canBeEdited => this == QuizStatus.draft;
}

/// Quiz category enumeration
enum QuizCategory {
  science,
  mathematics,
  history,
  geography,
  literature,
  art,
  music,
  sports,
  technology,
  generalKnowledge,
  custom;
  
  String get displayName {
    switch (this) {
      case QuizCategory.science:
        return 'Science';
      case QuizCategory.mathematics:
        return 'Mathematics';
      case QuizCategory.history:
        return 'History';
      case QuizCategory.geography:
        return 'Geography';
      case QuizCategory.literature:
        return 'Literature';
      case QuizCategory.art:
        return 'Art';
      case QuizCategory.music:
        return 'Music';
      case QuizCategory.sports:
        return 'Sports';
      case QuizCategory.technology:
        return 'Technology';
      case QuizCategory.generalKnowledge:
        return 'General Knowledge';
      case QuizCategory.custom:
        return 'Custom';
    }
  }
  
  String get icon {
    switch (this) {
      case QuizCategory.science:
        return '🔬';
      case QuizCategory.mathematics:
        return '🔢';
      case QuizCategory.history:
        return '📜';
      case QuizCategory.geography:
        return '🌍';
      case QuizCategory.literature:
        return '📚';
      case QuizCategory.art:
        return '🎨';
      case QuizCategory.music:
        return '🎵';
      case QuizCategory.sports:
        return '⚽';
      case QuizCategory.technology:
        return '💻';
      case QuizCategory.generalKnowledge:
        return '💡';
      case QuizCategory.custom:
        return '✏️';
    }
  }
}