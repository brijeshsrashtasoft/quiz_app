// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameSessionModel _$GameSessionModelFromJson(Map<String, dynamic> json) {
  return _GameSessionModel.fromJson(json);
}

/// @nodoc
mixin _$GameSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get quizId => throw _privateConstructorUsedError;
  String get hostId => throw _privateConstructorUsedError;
  String get pin => throw _privateConstructorUsedError;
  GameSessionStatus get status => throw _privateConstructorUsedError;
  Map<String, PlayerModel> get players => throw _privateConstructorUsedError;
  int get currentQuestionIndex => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  GameSessionSettingsModel? get settings => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this GameSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionModelCopyWith<GameSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionModelCopyWith<$Res> {
  factory $GameSessionModelCopyWith(
    GameSessionModel value,
    $Res Function(GameSessionModel) then,
  ) = _$GameSessionModelCopyWithImpl<$Res, GameSessionModel>;
  @useResult
  $Res call({
    String id,
    String quizId,
    String hostId,
    String pin,
    GameSessionStatus status,
    Map<String, PlayerModel> players,
    int currentQuestionIndex,
    DateTime createdAt,
    GameSessionSettingsModel? settings,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  $GameSessionSettingsModelCopyWith<$Res>? get settings;
}

/// @nodoc
class _$GameSessionModelCopyWithImpl<$Res, $Val extends GameSessionModel>
    implements $GameSessionModelCopyWith<$Res> {
  _$GameSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quizId = null,
    Object? hostId = null,
    Object? pin = null,
    Object? status = null,
    Object? players = null,
    Object? currentQuestionIndex = null,
    Object? createdAt = null,
    Object? settings = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            quizId: null == quizId
                ? _value.quizId
                : quizId // ignore: cast_nullable_to_non_nullable
                      as String,
            hostId: null == hostId
                ? _value.hostId
                : hostId // ignore: cast_nullable_to_non_nullable
                      as String,
            pin: null == pin
                ? _value.pin
                : pin // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GameSessionStatus,
            players: null == players
                ? _value.players
                : players // ignore: cast_nullable_to_non_nullable
                      as Map<String, PlayerModel>,
            currentQuestionIndex: null == currentQuestionIndex
                ? _value.currentQuestionIndex
                : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as GameSessionSettingsModel?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSessionSettingsModelCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $GameSessionSettingsModelCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameSessionModelImplCopyWith<$Res>
    implements $GameSessionModelCopyWith<$Res> {
  factory _$$GameSessionModelImplCopyWith(
    _$GameSessionModelImpl value,
    $Res Function(_$GameSessionModelImpl) then,
  ) = __$$GameSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String quizId,
    String hostId,
    String pin,
    GameSessionStatus status,
    Map<String, PlayerModel> players,
    int currentQuestionIndex,
    DateTime createdAt,
    GameSessionSettingsModel? settings,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  @override
  $GameSessionSettingsModelCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$GameSessionModelImplCopyWithImpl<$Res>
    extends _$GameSessionModelCopyWithImpl<$Res, _$GameSessionModelImpl>
    implements _$$GameSessionModelImplCopyWith<$Res> {
  __$$GameSessionModelImplCopyWithImpl(
    _$GameSessionModelImpl _value,
    $Res Function(_$GameSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quizId = null,
    Object? hostId = null,
    Object? pin = null,
    Object? status = null,
    Object? players = null,
    Object? currentQuestionIndex = null,
    Object? createdAt = null,
    Object? settings = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$GameSessionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        quizId: null == quizId
            ? _value.quizId
            : quizId // ignore: cast_nullable_to_non_nullable
                  as String,
        hostId: null == hostId
            ? _value.hostId
            : hostId // ignore: cast_nullable_to_non_nullable
                  as String,
        pin: null == pin
            ? _value.pin
            : pin // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GameSessionStatus,
        players: null == players
            ? _value._players
            : players // ignore: cast_nullable_to_non_nullable
                  as Map<String, PlayerModel>,
        currentQuestionIndex: null == currentQuestionIndex
            ? _value.currentQuestionIndex
            : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as GameSessionSettingsModel?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSessionModelImpl implements _GameSessionModel {
  const _$GameSessionModelImpl({
    required this.id,
    required this.quizId,
    required this.hostId,
    required this.pin,
    required this.status,
    required final Map<String, PlayerModel> players,
    required this.currentQuestionIndex,
    required this.createdAt,
    this.settings,
    this.startedAt,
    this.completedAt,
  }) : _players = players;

  factory _$GameSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String quizId;
  @override
  final String hostId;
  @override
  final String pin;
  @override
  final GameSessionStatus status;
  final Map<String, PlayerModel> _players;
  @override
  Map<String, PlayerModel> get players {
    if (_players is EqualUnmodifiableMapView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_players);
  }

  @override
  final int currentQuestionIndex;
  @override
  final DateTime createdAt;
  @override
  final GameSessionSettingsModel? settings;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'GameSessionModel(id: $id, quizId: $quizId, hostId: $hostId, pin: $pin, status: $status, players: $players, currentQuestionIndex: $currentQuestionIndex, createdAt: $createdAt, settings: $settings, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.hostId, hostId) || other.hostId == hostId) &&
            (identical(other.pin, pin) || other.pin == pin) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    quizId,
    hostId,
    pin,
    status,
    const DeepCollectionEquality().hash(_players),
    currentQuestionIndex,
    createdAt,
    settings,
    startedAt,
    completedAt,
  );

  /// Create a copy of GameSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionModelImplCopyWith<_$GameSessionModelImpl> get copyWith =>
      __$$GameSessionModelImplCopyWithImpl<_$GameSessionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSessionModelImplToJson(this);
  }
}

abstract class _GameSessionModel implements GameSessionModel {
  const factory _GameSessionModel({
    required final String id,
    required final String quizId,
    required final String hostId,
    required final String pin,
    required final GameSessionStatus status,
    required final Map<String, PlayerModel> players,
    required final int currentQuestionIndex,
    required final DateTime createdAt,
    final GameSessionSettingsModel? settings,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) = _$GameSessionModelImpl;

  factory _GameSessionModel.fromJson(Map<String, dynamic> json) =
      _$GameSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get quizId;
  @override
  String get hostId;
  @override
  String get pin;
  @override
  GameSessionStatus get status;
  @override
  Map<String, PlayerModel> get players;
  @override
  int get currentQuestionIndex;
  @override
  DateTime get createdAt;
  @override
  GameSessionSettingsModel? get settings;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of GameSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionModelImplCopyWith<_$GameSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) {
  return _PlayerModel.fromJson(json);
}

/// @nodoc
mixin _$PlayerModel {
  String get name => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  List<int> get answers => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;

  /// Serializes this PlayerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerModelCopyWith<PlayerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerModelCopyWith<$Res> {
  factory $PlayerModelCopyWith(
    PlayerModel value,
    $Res Function(PlayerModel) then,
  ) = _$PlayerModelCopyWithImpl<$Res, PlayerModel>;
  @useResult
  $Res call({
    String name,
    DateTime joinedAt,
    int score,
    List<int> answers,
    bool isReady,
  });
}

/// @nodoc
class _$PlayerModelCopyWithImpl<$Res, $Val extends PlayerModel>
    implements $PlayerModelCopyWith<$Res> {
  _$PlayerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? joinedAt = null,
    Object? score = null,
    Object? answers = null,
    Object? isReady = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            isReady: null == isReady
                ? _value.isReady
                : isReady // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerModelImplCopyWith<$Res>
    implements $PlayerModelCopyWith<$Res> {
  factory _$$PlayerModelImplCopyWith(
    _$PlayerModelImpl value,
    $Res Function(_$PlayerModelImpl) then,
  ) = __$$PlayerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    DateTime joinedAt,
    int score,
    List<int> answers,
    bool isReady,
  });
}

/// @nodoc
class __$$PlayerModelImplCopyWithImpl<$Res>
    extends _$PlayerModelCopyWithImpl<$Res, _$PlayerModelImpl>
    implements _$$PlayerModelImplCopyWith<$Res> {
  __$$PlayerModelImplCopyWithImpl(
    _$PlayerModelImpl _value,
    $Res Function(_$PlayerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? joinedAt = null,
    Object? score = null,
    Object? answers = null,
    Object? isReady = null,
  }) {
    return _then(
      _$PlayerModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        answers: null == answers
            ? _value._answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        isReady: null == isReady
            ? _value.isReady
            : isReady // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerModelImpl implements _PlayerModel {
  const _$PlayerModelImpl({
    required this.name,
    required this.joinedAt,
    this.score = 0,
    final List<int> answers = const [],
    this.isReady = false,
  }) : _answers = answers;

  factory _$PlayerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerModelImplFromJson(json);

  @override
  final String name;
  @override
  final DateTime joinedAt;
  @override
  @JsonKey()
  final int score;
  final List<int> _answers;
  @override
  @JsonKey()
  List<int> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @override
  @JsonKey()
  final bool isReady;

  @override
  String toString() {
    return 'PlayerModel(name: $name, joinedAt: $joinedAt, score: $score, answers: $answers, isReady: $isReady)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.isReady, isReady) || other.isReady == isReady));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    joinedAt,
    score,
    const DeepCollectionEquality().hash(_answers),
    isReady,
  );

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      __$$PlayerModelImplCopyWithImpl<_$PlayerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerModelImplToJson(this);
  }
}

abstract class _PlayerModel implements PlayerModel {
  const factory _PlayerModel({
    required final String name,
    required final DateTime joinedAt,
    final int score,
    final List<int> answers,
    final bool isReady,
  }) = _$PlayerModelImpl;

  factory _PlayerModel.fromJson(Map<String, dynamic> json) =
      _$PlayerModelImpl.fromJson;

  @override
  String get name;
  @override
  DateTime get joinedAt;
  @override
  int get score;
  @override
  List<int> get answers;
  @override
  bool get isReady;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameSessionSettingsModel _$GameSessionSettingsModelFromJson(
  Map<String, dynamic> json,
) {
  return _GameSessionSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$GameSessionSettingsModel {
  int get maxPlayers => throw _privateConstructorUsedError;
  bool get showCorrectAnswers => throw _privateConstructorUsedError;
  bool get shuffleQuestions => throw _privateConstructorUsedError;
  bool get allowReplay => throw _privateConstructorUsedError;

  /// Serializes this GameSessionSettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSessionSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionSettingsModelCopyWith<GameSessionSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionSettingsModelCopyWith<$Res> {
  factory $GameSessionSettingsModelCopyWith(
    GameSessionSettingsModel value,
    $Res Function(GameSessionSettingsModel) then,
  ) = _$GameSessionSettingsModelCopyWithImpl<$Res, GameSessionSettingsModel>;
  @useResult
  $Res call({
    int maxPlayers,
    bool showCorrectAnswers,
    bool shuffleQuestions,
    bool allowReplay,
  });
}

/// @nodoc
class _$GameSessionSettingsModelCopyWithImpl<
  $Res,
  $Val extends GameSessionSettingsModel
>
    implements $GameSessionSettingsModelCopyWith<$Res> {
  _$GameSessionSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSessionSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxPlayers = null,
    Object? showCorrectAnswers = null,
    Object? shuffleQuestions = null,
    Object? allowReplay = null,
  }) {
    return _then(
      _value.copyWith(
            maxPlayers: null == maxPlayers
                ? _value.maxPlayers
                : maxPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
            showCorrectAnswers: null == showCorrectAnswers
                ? _value.showCorrectAnswers
                : showCorrectAnswers // ignore: cast_nullable_to_non_nullable
                      as bool,
            shuffleQuestions: null == shuffleQuestions
                ? _value.shuffleQuestions
                : shuffleQuestions // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowReplay: null == allowReplay
                ? _value.allowReplay
                : allowReplay // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSessionSettingsModelImplCopyWith<$Res>
    implements $GameSessionSettingsModelCopyWith<$Res> {
  factory _$$GameSessionSettingsModelImplCopyWith(
    _$GameSessionSettingsModelImpl value,
    $Res Function(_$GameSessionSettingsModelImpl) then,
  ) = __$$GameSessionSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int maxPlayers,
    bool showCorrectAnswers,
    bool shuffleQuestions,
    bool allowReplay,
  });
}

/// @nodoc
class __$$GameSessionSettingsModelImplCopyWithImpl<$Res>
    extends
        _$GameSessionSettingsModelCopyWithImpl<
          $Res,
          _$GameSessionSettingsModelImpl
        >
    implements _$$GameSessionSettingsModelImplCopyWith<$Res> {
  __$$GameSessionSettingsModelImplCopyWithImpl(
    _$GameSessionSettingsModelImpl _value,
    $Res Function(_$GameSessionSettingsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSessionSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxPlayers = null,
    Object? showCorrectAnswers = null,
    Object? shuffleQuestions = null,
    Object? allowReplay = null,
  }) {
    return _then(
      _$GameSessionSettingsModelImpl(
        maxPlayers: null == maxPlayers
            ? _value.maxPlayers
            : maxPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
        showCorrectAnswers: null == showCorrectAnswers
            ? _value.showCorrectAnswers
            : showCorrectAnswers // ignore: cast_nullable_to_non_nullable
                  as bool,
        shuffleQuestions: null == shuffleQuestions
            ? _value.shuffleQuestions
            : shuffleQuestions // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowReplay: null == allowReplay
            ? _value.allowReplay
            : allowReplay // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSessionSettingsModelImpl implements _GameSessionSettingsModel {
  const _$GameSessionSettingsModelImpl({
    this.maxPlayers = 50,
    this.showCorrectAnswers = true,
    this.shuffleQuestions = false,
    this.allowReplay = true,
  });

  factory _$GameSessionSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSessionSettingsModelImplFromJson(json);

  @override
  @JsonKey()
  final int maxPlayers;
  @override
  @JsonKey()
  final bool showCorrectAnswers;
  @override
  @JsonKey()
  final bool shuffleQuestions;
  @override
  @JsonKey()
  final bool allowReplay;

  @override
  String toString() {
    return 'GameSessionSettingsModel(maxPlayers: $maxPlayers, showCorrectAnswers: $showCorrectAnswers, shuffleQuestions: $shuffleQuestions, allowReplay: $allowReplay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionSettingsModelImpl &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.showCorrectAnswers, showCorrectAnswers) ||
                other.showCorrectAnswers == showCorrectAnswers) &&
            (identical(other.shuffleQuestions, shuffleQuestions) ||
                other.shuffleQuestions == shuffleQuestions) &&
            (identical(other.allowReplay, allowReplay) ||
                other.allowReplay == allowReplay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    maxPlayers,
    showCorrectAnswers,
    shuffleQuestions,
    allowReplay,
  );

  /// Create a copy of GameSessionSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionSettingsModelImplCopyWith<_$GameSessionSettingsModelImpl>
  get copyWith =>
      __$$GameSessionSettingsModelImplCopyWithImpl<
        _$GameSessionSettingsModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSessionSettingsModelImplToJson(this);
  }
}

abstract class _GameSessionSettingsModel implements GameSessionSettingsModel {
  const factory _GameSessionSettingsModel({
    final int maxPlayers,
    final bool showCorrectAnswers,
    final bool shuffleQuestions,
    final bool allowReplay,
  }) = _$GameSessionSettingsModelImpl;

  factory _GameSessionSettingsModel.fromJson(Map<String, dynamic> json) =
      _$GameSessionSettingsModelImpl.fromJson;

  @override
  int get maxPlayers;
  @override
  bool get showCorrectAnswers;
  @override
  bool get shuffleQuestions;
  @override
  bool get allowReplay;

  /// Create a copy of GameSessionSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionSettingsModelImplCopyWith<_$GameSessionSettingsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
