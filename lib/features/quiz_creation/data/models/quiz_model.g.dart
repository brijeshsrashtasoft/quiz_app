// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuizModelImpl _$$QuizModelImplFromJson(Map<String, dynamic> json) =>
    _$QuizModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String?,
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$QuizModelImplToJson(_$QuizModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdBy': instance.createdBy,
      'questions': instance.questions,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'estimatedDuration': instance.estimatedDuration,
    };

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswer: (json['correctAnswer'] as num).toInt(),
      timeLimit: (json['timeLimit'] as num).toInt(),
      points: (json['points'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'question': instance.question,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'timeLimit': instance.timeLimit,
      'points': instance.points,
    };
