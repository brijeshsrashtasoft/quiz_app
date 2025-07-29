// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameSessionEntity {
  String get id => throw _privateConstructorUsedError;
  String get quizId => throw _privateConstructorUsedError;
  String get hostId => throw _privateConstructorUsedError;
  String get pin => throw _privateConstructorUsedError;
  GameSessionStatus get status => throw _privateConstructorUsedError;
  Map<String, PlayerEntity> get players => throw _privateConstructorUsedError;
  int get currentQuestionIndex => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  GameSessionSettings? get settings => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Create a copy of GameSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionEntityCopyWith<GameSessionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionEntityCopyWith<$Res> {
  factory $GameSessionEntityCopyWith(
    GameSessionEntity value,
    $Res Function(GameSessionEntity) then,
  ) = _$GameSessionEntityCopyWithImpl<$Res, GameSessionEntity>;
  @useResult
  $Res call({
    String id,
    String quizId,
    String hostId,
    String pin,
    GameSessionStatus status,
    Map<String, PlayerEntity> players,
    int currentQuestionIndex,
    DateTime createdAt,
    GameSessionSettings? settings,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  $GameSessionSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$GameSessionEntityCopyWithImpl<$Res, $Val extends GameSessionEntity>
    implements $GameSessionEntityCopyWith<$Res> {
  _$GameSessionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSessionEntity
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
                      as Map<String, PlayerEntity>,
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
                      as GameSessionSettings?,
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

  /// Create a copy of GameSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSessionSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $GameSessionSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameSessionEntityImplCopyWith<$Res>
    implements $GameSessionEntityCopyWith<$Res> {
  factory _$$GameSessionEntityImplCopyWith(
    _$GameSessionEntityImpl value,
    $Res Function(_$GameSessionEntityImpl) then,
  ) = __$$GameSessionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String quizId,
    String hostId,
    String pin,
    GameSessionStatus status,
    Map<String, PlayerEntity> players,
    int currentQuestionIndex,
    DateTime createdAt,
    GameSessionSettings? settings,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  @override
  $GameSessionSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$GameSessionEntityImplCopyWithImpl<$Res>
    extends _$GameSessionEntityCopyWithImpl<$Res, _$GameSessionEntityImpl>
    implements _$$GameSessionEntityImplCopyWith<$Res> {
  __$$GameSessionEntityImplCopyWithImpl(
    _$GameSessionEntityImpl _value,
    $Res Function(_$GameSessionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSessionEntity
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
      _$GameSessionEntityImpl(
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
                  as Map<String, PlayerEntity>,
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
                  as GameSessionSettings?,
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

class _$GameSessionEntityImpl implements _GameSessionEntity {
  const _$GameSessionEntityImpl({
    required this.id,
    required this.quizId,
    required this.hostId,
    required this.pin,
    required this.status,
    required final Map<String, PlayerEntity> players,
    required this.currentQuestionIndex,
    required this.createdAt,
    this.settings,
    this.startedAt,
    this.completedAt,
  }) : _players = players;

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
  final Map<String, PlayerEntity> _players;
  @override
  Map<String, PlayerEntity> get players {
    if (_players is EqualUnmodifiableMapView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_players);
  }

  @override
  final int currentQuestionIndex;
  @override
  final DateTime createdAt;
  @override
  final GameSessionSettings? settings;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'GameSessionEntity(id: $id, quizId: $quizId, hostId: $hostId, pin: $pin, status: $status, players: $players, currentQuestionIndex: $currentQuestionIndex, createdAt: $createdAt, settings: $settings, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionEntityImpl &&
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

  /// Create a copy of GameSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionEntityImplCopyWith<_$GameSessionEntityImpl> get copyWith =>
      __$$GameSessionEntityImplCopyWithImpl<_$GameSessionEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _GameSessionEntity implements GameSessionEntity {
  const factory _GameSessionEntity({
    required final String id,
    required final String quizId,
    required final String hostId,
    required final String pin,
    required final GameSessionStatus status,
    required final Map<String, PlayerEntity> players,
    required final int currentQuestionIndex,
    required final DateTime createdAt,
    final GameSessionSettings? settings,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) = _$GameSessionEntityImpl;

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
  Map<String, PlayerEntity> get players;
  @override
  int get currentQuestionIndex;
  @override
  DateTime get createdAt;
  @override
  GameSessionSettings? get settings;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of GameSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionEntityImplCopyWith<_$GameSessionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PlayerEntity {
  String get name => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  List<int> get answers => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;

  /// Create a copy of PlayerEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerEntityCopyWith<PlayerEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerEntityCopyWith<$Res> {
  factory $PlayerEntityCopyWith(
    PlayerEntity value,
    $Res Function(PlayerEntity) then,
  ) = _$PlayerEntityCopyWithImpl<$Res, PlayerEntity>;
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
class _$PlayerEntityCopyWithImpl<$Res, $Val extends PlayerEntity>
    implements $PlayerEntityCopyWith<$Res> {
  _$PlayerEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerEntity
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
abstract class _$$PlayerEntityImplCopyWith<$Res>
    implements $PlayerEntityCopyWith<$Res> {
  factory _$$PlayerEntityImplCopyWith(
    _$PlayerEntityImpl value,
    $Res Function(_$PlayerEntityImpl) then,
  ) = __$$PlayerEntityImplCopyWithImpl<$Res>;
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
class __$$PlayerEntityImplCopyWithImpl<$Res>
    extends _$PlayerEntityCopyWithImpl<$Res, _$PlayerEntityImpl>
    implements _$$PlayerEntityImplCopyWith<$Res> {
  __$$PlayerEntityImplCopyWithImpl(
    _$PlayerEntityImpl _value,
    $Res Function(_$PlayerEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerEntity
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
      _$PlayerEntityImpl(
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

class _$PlayerEntityImpl implements _PlayerEntity {
  const _$PlayerEntityImpl({
    required this.name,
    required this.joinedAt,
    this.score = 0,
    final List<int> answers = const [],
    this.isReady = false,
  }) : _answers = answers;

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
    return 'PlayerEntity(name: $name, joinedAt: $joinedAt, score: $score, answers: $answers, isReady: $isReady)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerEntityImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.isReady, isReady) || other.isReady == isReady));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    joinedAt,
    score,
    const DeepCollectionEquality().hash(_answers),
    isReady,
  );

  /// Create a copy of PlayerEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerEntityImplCopyWith<_$PlayerEntityImpl> get copyWith =>
      __$$PlayerEntityImplCopyWithImpl<_$PlayerEntityImpl>(this, _$identity);
}

abstract class _PlayerEntity implements PlayerEntity {
  const factory _PlayerEntity({
    required final String name,
    required final DateTime joinedAt,
    final int score,
    final List<int> answers,
    final bool isReady,
  }) = _$PlayerEntityImpl;

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

  /// Create a copy of PlayerEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerEntityImplCopyWith<_$PlayerEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GameSessionSettings {
  int get maxPlayers => throw _privateConstructorUsedError;
  bool get showCorrectAnswers => throw _privateConstructorUsedError;
  bool get shuffleQuestions => throw _privateConstructorUsedError;
  bool get allowReplay => throw _privateConstructorUsedError;

  /// Create a copy of GameSessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionSettingsCopyWith<GameSessionSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionSettingsCopyWith<$Res> {
  factory $GameSessionSettingsCopyWith(
    GameSessionSettings value,
    $Res Function(GameSessionSettings) then,
  ) = _$GameSessionSettingsCopyWithImpl<$Res, GameSessionSettings>;
  @useResult
  $Res call({
    int maxPlayers,
    bool showCorrectAnswers,
    bool shuffleQuestions,
    bool allowReplay,
  });
}

/// @nodoc
class _$GameSessionSettingsCopyWithImpl<$Res, $Val extends GameSessionSettings>
    implements $GameSessionSettingsCopyWith<$Res> {
  _$GameSessionSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSessionSettings
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
abstract class _$$GameSessionSettingsImplCopyWith<$Res>
    implements $GameSessionSettingsCopyWith<$Res> {
  factory _$$GameSessionSettingsImplCopyWith(
    _$GameSessionSettingsImpl value,
    $Res Function(_$GameSessionSettingsImpl) then,
  ) = __$$GameSessionSettingsImplCopyWithImpl<$Res>;
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
class __$$GameSessionSettingsImplCopyWithImpl<$Res>
    extends _$GameSessionSettingsCopyWithImpl<$Res, _$GameSessionSettingsImpl>
    implements _$$GameSessionSettingsImplCopyWith<$Res> {
  __$$GameSessionSettingsImplCopyWithImpl(
    _$GameSessionSettingsImpl _value,
    $Res Function(_$GameSessionSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSessionSettings
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
      _$GameSessionSettingsImpl(
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

class _$GameSessionSettingsImpl implements _GameSessionSettings {
  const _$GameSessionSettingsImpl({
    this.maxPlayers = 50,
    this.showCorrectAnswers = true,
    this.shuffleQuestions = false,
    this.allowReplay = true,
  });

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
    return 'GameSessionSettings(maxPlayers: $maxPlayers, showCorrectAnswers: $showCorrectAnswers, shuffleQuestions: $shuffleQuestions, allowReplay: $allowReplay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionSettingsImpl &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.showCorrectAnswers, showCorrectAnswers) ||
                other.showCorrectAnswers == showCorrectAnswers) &&
            (identical(other.shuffleQuestions, shuffleQuestions) ||
                other.shuffleQuestions == shuffleQuestions) &&
            (identical(other.allowReplay, allowReplay) ||
                other.allowReplay == allowReplay));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    maxPlayers,
    showCorrectAnswers,
    shuffleQuestions,
    allowReplay,
  );

  /// Create a copy of GameSessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionSettingsImplCopyWith<_$GameSessionSettingsImpl> get copyWith =>
      __$$GameSessionSettingsImplCopyWithImpl<_$GameSessionSettingsImpl>(
        this,
        _$identity,
      );
}

abstract class _GameSessionSettings implements GameSessionSettings {
  const factory _GameSessionSettings({
    final int maxPlayers,
    final bool showCorrectAnswers,
    final bool shuffleQuestions,
    final bool allowReplay,
  }) = _$GameSessionSettingsImpl;

  @override
  int get maxPlayers;
  @override
  bool get showCorrectAnswers;
  @override
  bool get shuffleQuestions;
  @override
  bool get allowReplay;

  /// Create a copy of GameSessionSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionSettingsImplCopyWith<_$GameSessionSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
