import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz.dart';
import 'question_model.dart';
import 'quiz_metadata_model.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

/// Quiz model for data layer with Firestore serialization
/// Following Clean Architecture patterns from CLAUDE.md
@freezed
class QuizModel with _$QuizModel {
  const QuizModel._();

  const factory QuizModel({
    required String id,
    required String title,
    required String description,
    required String createdBy,
    required List<QuestionModel> questions,
    required bool isPublic,
    required DateTime createdAt,
    required QuizMetadataModel metadata,
    DateTime? updatedAt,
    DateTime? publishedAt,
    @Default(false) bool isDraft,
    @Default(0) int playCount,
    @Default(0.0) double averageScore,
    @Default(0) int totalRatings,
    @Default(0.0) double rating,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  /// Convert from domain entity
  factory QuizModel.fromEntity(Quiz entity) {
    return QuizModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdBy: entity.createdBy,
      questions: entity.questions
          .map((q) => QuestionModel.fromEntity(q))
          .toList(),
      isPublic: entity.isPublic,
      createdAt: entity.createdAt,
      metadata: QuizMetadataModel.fromEntity(entity.metadata),
      updatedAt: entity.updatedAt,
      publishedAt: entity.publishedAt,
      isDraft: entity.isDraft,
      playCount: entity.playCount,
      averageScore: entity.averageScore,
      totalRatings: entity.totalRatings,
      rating: entity.rating,
    );
  }

  /// Convert to domain entity
  Quiz toEntity() {
    return Quiz(
      id: id,
      title: title,
      description: description,
      createdBy: createdBy,
      questions: questions.map((q) => q.toEntity()).toList(),
      isPublic: isPublic,
      createdAt: createdAt,
      metadata: metadata.toEntity(),
      updatedAt: updatedAt,
      publishedAt: publishedAt,
      isDraft: isDraft,
      playCount: playCount,
      averageScore: averageScore,
      totalRatings: totalRatings,
      rating: rating,
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'questions': questions.map((q) => q.toFirestore()).toList(),
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata.toFirestore(),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (publishedAt != null) 'publishedAt': Timestamp.fromDate(publishedAt!),
      'isDraft': isDraft,
      'playCount': playCount,
      'averageScore': averageScore,
      'totalRatings': totalRatings,
      'rating': rating,
    };
  }

  /// Create from Firestore document
  factory QuizModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return QuizModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      createdBy: data['createdBy'] as String,
      questions: (data['questions'] as List)
          .map((q) => QuestionModel.fromFirestore(q as Map<String, dynamic>))
          .toList(),
      isPublic: data['isPublic'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: QuizMetadataModel.fromFirestore(
        data['metadata'] as Map<String, dynamic>,
      ),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as Timestamp).toDate()
          : null,
      isDraft: data['isDraft'] as bool? ?? false,
      playCount: data['playCount'] as int? ?? 0,
      averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalRatings: data['totalRatings'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Create from Firestore data map (for subcollections)
  factory QuizModel.fromFirestoreData(String id, Map<String, dynamic> data) {
    return QuizModel(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String,
      createdBy: data['createdBy'] as String,
      questions: (data['questions'] as List)
          .map((q) => QuestionModel.fromFirestore(q as Map<String, dynamic>))
          .toList(),
      isPublic: data['isPublic'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: QuizMetadataModel.fromFirestore(
        data['metadata'] as Map<String, dynamic>,
      ),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as Timestamp).toDate()
          : null,
      isDraft: data['isDraft'] as bool? ?? false,
      playCount: data['playCount'] as int? ?? 0,
      averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalRatings: data['totalRatings'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
