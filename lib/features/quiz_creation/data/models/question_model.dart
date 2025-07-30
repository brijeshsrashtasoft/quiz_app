import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/question_entities.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

/// Question model for data layer with JSON serialization
/// Following Clean Architecture patterns from CLAUDE.md
@freezed
class QuestionModel with _$QuestionModel {
  const QuestionModel._();
  
  const factory QuestionModel({
    required String id,
    required String type,
    required String question,
    required Map<String, dynamic> data,
  }) = _QuestionModel;
  
  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
  
  /// Convert from domain entity
  factory QuestionModel.fromEntity(Question entity) {
    return entity.when(
      multipleChoice: (id, question, options, correctAnswer, timeLimit, points, imageUrl, explanation) {
        return QuestionModel(
          id: id,
          type: 'multiple_choice',
          question: question,
          data: {
            'options': options,
            'correctAnswer': correctAnswer,
            'timeLimit': timeLimit,
            'points': points,
            if (imageUrl != null) 'imageUrl': imageUrl,
            if (explanation != null) 'explanation': explanation,
          },
        );
      },
      trueFalse: (id, question, correctAnswer, timeLimit, points, imageUrl, explanation) {
        return QuestionModel(
          id: id,
          type: 'true_false',
          question: question,
          data: {
            'correctAnswer': correctAnswer,
            'timeLimit': timeLimit,
            'points': points,
            if (imageUrl != null) 'imageUrl': imageUrl,
            if (explanation != null) 'explanation': explanation,
          },
        );
      },
    );
  }
  
  /// Convert to domain entity
  Question toEntity() {
    switch (type) {
      case 'multiple_choice':
        return Question.multipleChoice(
          id: id,
          question: question,
          options: List<String>.from(data['options'] ?? []),
          correctAnswer: data['correctAnswer'] ?? 0,
          timeLimit: data['timeLimit'] ?? 30,
          points: data['points'] ?? 100,
          imageUrl: data['imageUrl'],
          explanation: data['explanation'],
        );
      case 'true_false':
        return Question.trueFalse(
          id: id,
          question: question,
          correctAnswer: data['correctAnswer'] ?? false,
          timeLimit: data['timeLimit'] ?? 30,
          points: data['points'] ?? 100,
          imageUrl: data['imageUrl'],
          explanation: data['explanation'],
        );
      default:
        throw Exception('Unknown question type: $type');
    }
  }
  
  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'question': question,
      ...data,
    };
  }
  
  /// Create from Firestore document
  factory QuestionModel.fromFirestore(Map<String, dynamic> data) {
    final type = data['type'] as String;
    final questionData = Map<String, dynamic>.from(data);
    
    // Remove base fields to get only question-specific data
    questionData.remove('id');
    questionData.remove('type');
    questionData.remove('question');
    
    return QuestionModel(
      id: data['id'] as String,
      type: type,
      question: data['question'] as String,
      data: questionData,
    );
  }
}