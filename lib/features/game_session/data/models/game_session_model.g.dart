// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSessionModelImpl _$$GameSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameSessionModelImpl(
  id: json['id'] as String,
  quizId: json['quizId'] as String,
  hostId: json['hostId'] as String,
  pin: json['pin'] as String,
  status: $enumDecode(_$GameSessionStatusEnumMap, json['status']),
  players: (json['players'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, PlayerModel.fromJson(e as Map<String, dynamic>)),
  ),
  currentQuestionIndex: (json['currentQuestionIndex'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  settings: json['settings'] == null
      ? null
      : GameSessionSettingsModel.fromJson(
          json['settings'] as Map<String, dynamic>,
        ),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$GameSessionModelImplToJson(
  _$GameSessionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'quizId': instance.quizId,
  'hostId': instance.hostId,
  'pin': instance.pin,
  'status': _$GameSessionStatusEnumMap[instance.status]!,
  'players': instance.players,
  'currentQuestionIndex': instance.currentQuestionIndex,
  'createdAt': instance.createdAt.toIso8601String(),
  'settings': instance.settings,
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$GameSessionStatusEnumMap = {
  GameSessionStatus.waiting: 'waiting',
  GameSessionStatus.active: 'active',
  GameSessionStatus.completed: 'completed',
};

_$PlayerModelImpl _$$PlayerModelImplFromJson(Map<String, dynamic> json) =>
    _$PlayerModelImpl(
      name: json['name'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      score: (json['score'] as num?)?.toInt() ?? 0,
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      isReady: json['isReady'] as bool? ?? false,
    );

Map<String, dynamic> _$$PlayerModelImplToJson(_$PlayerModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'score': instance.score,
      'answers': instance.answers,
      'isReady': instance.isReady,
    };

_$GameSessionSettingsModelImpl _$$GameSessionSettingsModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameSessionSettingsModelImpl(
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 50,
  showCorrectAnswers: json['showCorrectAnswers'] as bool? ?? true,
  shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
  allowReplay: json['allowReplay'] as bool? ?? true,
);

Map<String, dynamic> _$$GameSessionSettingsModelImplToJson(
  _$GameSessionSettingsModelImpl instance,
) => <String, dynamic>{
  'maxPlayers': instance.maxPlayers,
  'showCorrectAnswers': instance.showCorrectAnswers,
  'shuffleQuestions': instance.shuffleQuestions,
  'allowReplay': instance.allowReplay,
};
