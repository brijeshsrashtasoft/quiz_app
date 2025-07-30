import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quiz_entity.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

/// Quiz model for data layer
/// Following CLAUDE.md patterns and Firestore integration
@freezed
class QuizModel with _$QuizModel {
  const factory QuizModel({
    required String id,
    required String title,
    required String description,
    required String createdBy,
    required List<QuestionModel> questions,
    required bool isPublic,
    required DateTime createdAt,
    String? category,
    int? estimatedDuration,
  }) = _QuizModel;

  /// Create from Firestore document data
  factory QuizModel.fromFirestore(Map<String, dynamic> data) {
    return QuizModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      createdBy: data['createdBy'] as String,
      questions: (data['questions'] as List<dynamic>)
          .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
          .toList(),
      isPublic: data['isPublic'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      category: data['category'] as String?,
      estimatedDuration: data['estimatedDuration'] as int?,
    );
  }

  /// Create from JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}

/// Question model for data layer
@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String question,
    required List<String> options,
    required int correctAnswer,
    required int timeLimit,
    @Default(100) int points,
  }) = _QuestionModel;

  /// Create from Firestore map
  factory QuestionModel.fromMap(Map<String, dynamic> data) {
    return QuestionModel(
      question: data['question'] as String,
      options: List<String>.from(data['options'] as List<dynamic>),
      correctAnswer: data['correctAnswer'] as int,
      timeLimit: data['timeLimit'] as int,
      points: data['points'] as int? ?? 100,
    );
  }

  /// Create from JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

/// Extensions for model conversions
extension QuizModelX on QuizModel {
  /// Convert to domain entity
  QuizEntity toEntity() {
    return QuizEntity(
      id: id,
      title: title,
      description: description,
      createdBy: createdBy,
      questions: questions.map((q) => q.toEntity()).toList(),
      isPublic: isPublic,
      createdAt: createdAt,
      category: category,
      estimatedDuration: estimatedDuration,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'questions': questions.map((q) => q.toFirestore()).toList(),
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (category != null) {
      data['category'] = category;
    }

    if (estimatedDuration != null) {
      data['estimatedDuration'] = estimatedDuration;
    }

    return data;
  }
}

extension QuestionModelX on QuestionModel {
  /// Convert to domain entity
  QuestionEntity toEntity() {
    return QuestionEntity(
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      timeLimit: timeLimit,
      points: points,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'timeLimit': timeLimit,
      'points': points,
    };
  }
}

/// Factory extensions for entity to model conversion
extension QuizEntityX on QuizEntity {
  /// Convert to data model
  QuizModel toModel() {
    return QuizModel(
      id: id,
      title: title,
      description: description,
      createdBy: createdBy,
      questions: questions.map((q) => q.toModel()).toList(),
      isPublic: isPublic,
      createdAt: createdAt,
      category: category,
      estimatedDuration: estimatedDuration,
    );
  }
}

extension QuestionEntityX on QuestionEntity {
  /// Convert to data model
  QuestionModel toModel() {
    return QuestionModel(
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      timeLimit: timeLimit,
      points: points,
    );
  }
}
