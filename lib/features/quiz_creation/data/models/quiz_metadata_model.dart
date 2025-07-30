import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quiz.dart';

part 'quiz_metadata_model.freezed.dart';
part 'quiz_metadata_model.g.dart';

/// Quiz metadata model for data layer
/// Following Clean Architecture patterns from CLAUDE.md
@freezed
class QuizMetadataModel with _$QuizMetadataModel {
  const QuizMetadataModel._();
  
  const factory QuizMetadataModel({
    required String category,
    required List<String> tags,
    required String difficulty,
    required String language,
    String? coverImageUrl,
    String? targetAudience,
    int? estimatedDuration,
    int? recommendedAge,
    Map<String, dynamic>? customProperties,
  }) = _QuizMetadataModel;
  
  factory QuizMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$QuizMetadataModelFromJson(json);
  
  /// Convert from domain entity
  factory QuizMetadataModel.fromEntity(QuizMetadata entity) {
    return QuizMetadataModel(
      category: entity.category,
      tags: entity.tags,
      difficulty: entity.difficulty,
      language: entity.language,
      coverImageUrl: entity.coverImageUrl,
      targetAudience: entity.targetAudience,
      estimatedDuration: entity.estimatedDuration,
      recommendedAge: entity.recommendedAge,
      customProperties: entity.customProperties,
    );
  }
  
  /// Convert to domain entity
  QuizMetadata toEntity() {
    return QuizMetadata(
      category: category,
      tags: tags,
      difficulty: difficulty,
      language: language,
      coverImageUrl: coverImageUrl,
      targetAudience: targetAudience,
      estimatedDuration: estimatedDuration,
      recommendedAge: recommendedAge,
      customProperties: customProperties,
    );
  }
  
  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'tags': tags,
      'difficulty': difficulty,
      'language': language,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (targetAudience != null) 'targetAudience': targetAudience,
      if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
      if (recommendedAge != null) 'recommendedAge': recommendedAge,
      if (customProperties != null) 'customProperties': customProperties,
    };
  }
  
  /// Create from Firestore data
  factory QuizMetadataModel.fromFirestore(Map<String, dynamic> data) {
    return QuizMetadataModel(
      category: data['category'] as String? ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      difficulty: data['difficulty'] as String? ?? 'medium',
      language: data['language'] as String? ?? 'en',
      coverImageUrl: data['coverImageUrl'] as String?,
      targetAudience: data['targetAudience'] as String?,
      estimatedDuration: data['estimatedDuration'] as int?,
      recommendedAge: data['recommendedAge'] as int?,
      customProperties: data['customProperties'] as Map<String, dynamic>?,
    );
  }
}