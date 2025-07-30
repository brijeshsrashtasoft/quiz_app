// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaderboardModel _$LeaderboardModelFromJson(Map<String, dynamic> json) {
  return _LeaderboardModel.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardModel {
  String get sessionId => throw _privateConstructorUsedError;
  List<ScoreModel> get scores => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get finalResults => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardModelCopyWith<LeaderboardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardModelCopyWith<$Res> {
  factory $LeaderboardModelCopyWith(
    LeaderboardModel value,
    $Res Function(LeaderboardModel) then,
  ) = _$LeaderboardModelCopyWithImpl<$Res, LeaderboardModel>;
  @useResult
  $Res call({
    String sessionId,
    List<ScoreModel> scores,
    DateTime updatedAt,
    bool finalResults,
  });
}

/// @nodoc
class _$LeaderboardModelCopyWithImpl<$Res, $Val extends LeaderboardModel>
    implements $LeaderboardModelCopyWith<$Res> {
  _$LeaderboardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? scores = null,
    Object? updatedAt = null,
    Object? finalResults = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            scores: null == scores
                ? _value.scores
                : scores // ignore: cast_nullable_to_non_nullable
                      as List<ScoreModel>,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            finalResults: null == finalResults
                ? _value.finalResults
                : finalResults // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardModelImplCopyWith<$Res>
    implements $LeaderboardModelCopyWith<$Res> {
  factory _$$LeaderboardModelImplCopyWith(
    _$LeaderboardModelImpl value,
    $Res Function(_$LeaderboardModelImpl) then,
  ) = __$$LeaderboardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    List<ScoreModel> scores,
    DateTime updatedAt,
    bool finalResults,
  });
}

/// @nodoc
class __$$LeaderboardModelImplCopyWithImpl<$Res>
    extends _$LeaderboardModelCopyWithImpl<$Res, _$LeaderboardModelImpl>
    implements _$$LeaderboardModelImplCopyWith<$Res> {
  __$$LeaderboardModelImplCopyWithImpl(
    _$LeaderboardModelImpl _value,
    $Res Function(_$LeaderboardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? scores = null,
    Object? updatedAt = null,
    Object? finalResults = null,
  }) {
    return _then(
      _$LeaderboardModelImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        scores: null == scores
            ? _value._scores
            : scores // ignore: cast_nullable_to_non_nullable
                  as List<ScoreModel>,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        finalResults: null == finalResults
            ? _value.finalResults
            : finalResults // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardModelImpl implements _LeaderboardModel {
  const _$LeaderboardModelImpl({
    required this.sessionId,
    required final List<ScoreModel> scores,
    required this.updatedAt,
    this.finalResults = false,
  }) : _scores = scores;

  factory _$LeaderboardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardModelImplFromJson(json);

  @override
  final String sessionId;
  final List<ScoreModel> _scores;
  @override
  List<ScoreModel> get scores {
    if (_scores is EqualUnmodifiableListView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scores);
  }

  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool finalResults;

  @override
  String toString() {
    return 'LeaderboardModel(sessionId: $sessionId, scores: $scores, updatedAt: $updatedAt, finalResults: $finalResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardModelImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.finalResults, finalResults) ||
                other.finalResults == finalResults));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    const DeepCollectionEquality().hash(_scores),
    updatedAt,
    finalResults,
  );

  /// Create a copy of LeaderboardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardModelImplCopyWith<_$LeaderboardModelImpl> get copyWith =>
      __$$LeaderboardModelImplCopyWithImpl<_$LeaderboardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardModelImplToJson(this);
  }
}

abstract class _LeaderboardModel implements LeaderboardModel {
  const factory _LeaderboardModel({
    required final String sessionId,
    required final List<ScoreModel> scores,
    required final DateTime updatedAt,
    final bool finalResults,
  }) = _$LeaderboardModelImpl;

  factory _LeaderboardModel.fromJson(Map<String, dynamic> json) =
      _$LeaderboardModelImpl.fromJson;

  @override
  String get sessionId;
  @override
  List<ScoreModel> get scores;
  @override
  DateTime get updatedAt;
  @override
  bool get finalResults;

  /// Create a copy of LeaderboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardModelImplCopyWith<_$LeaderboardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoreModel _$ScoreModelFromJson(Map<String, dynamic> json) {
  return _ScoreModel.fromJson(json);
}

/// @nodoc
mixin _$ScoreModel {
  String get playerId => throw _privateConstructorUsedError;
  String get playerName => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;
  int get totalAnswers => throw _privateConstructorUsedError;
  int? get rank => throw _privateConstructorUsedError;
  int? get timeTaken => throw _privateConstructorUsedError;

  /// Serializes this ScoreModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreModelCopyWith<ScoreModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreModelCopyWith<$Res> {
  factory $ScoreModelCopyWith(
    ScoreModel value,
    $Res Function(ScoreModel) then,
  ) = _$ScoreModelCopyWithImpl<$Res, ScoreModel>;
  @useResult
  $Res call({
    String playerId,
    String playerName,
    int score,
    int correctAnswers,
    int totalAnswers,
    int? rank,
    int? timeTaken,
  });
}

/// @nodoc
class _$ScoreModelCopyWithImpl<$Res, $Val extends ScoreModel>
    implements $ScoreModelCopyWith<$Res> {
  _$ScoreModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? playerName = null,
    Object? score = null,
    Object? correctAnswers = null,
    Object? totalAnswers = null,
    Object? rank = freezed,
    Object? timeTaken = freezed,
  }) {
    return _then(
      _value.copyWith(
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            playerName: null == playerName
                ? _value.playerName
                : playerName // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAnswers: null == totalAnswers
                ? _value.totalAnswers
                : totalAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: freezed == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int?,
            timeTaken: freezed == timeTaken
                ? _value.timeTaken
                : timeTaken // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScoreModelImplCopyWith<$Res>
    implements $ScoreModelCopyWith<$Res> {
  factory _$$ScoreModelImplCopyWith(
    _$ScoreModelImpl value,
    $Res Function(_$ScoreModelImpl) then,
  ) = __$$ScoreModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String playerId,
    String playerName,
    int score,
    int correctAnswers,
    int totalAnswers,
    int? rank,
    int? timeTaken,
  });
}

/// @nodoc
class __$$ScoreModelImplCopyWithImpl<$Res>
    extends _$ScoreModelCopyWithImpl<$Res, _$ScoreModelImpl>
    implements _$$ScoreModelImplCopyWith<$Res> {
  __$$ScoreModelImplCopyWithImpl(
    _$ScoreModelImpl _value,
    $Res Function(_$ScoreModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? playerName = null,
    Object? score = null,
    Object? correctAnswers = null,
    Object? totalAnswers = null,
    Object? rank = freezed,
    Object? timeTaken = freezed,
  }) {
    return _then(
      _$ScoreModelImpl(
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        playerName: null == playerName
            ? _value.playerName
            : playerName // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAnswers: null == totalAnswers
            ? _value.totalAnswers
            : totalAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: freezed == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int?,
        timeTaken: freezed == timeTaken
            ? _value.timeTaken
            : timeTaken // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreModelImpl implements _ScoreModel {
  const _$ScoreModelImpl({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.correctAnswers,
    required this.totalAnswers,
    this.rank,
    this.timeTaken,
  });

  factory _$ScoreModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreModelImplFromJson(json);

  @override
  final String playerId;
  @override
  final String playerName;
  @override
  final int score;
  @override
  final int correctAnswers;
  @override
  final int totalAnswers;
  @override
  final int? rank;
  @override
  final int? timeTaken;

  @override
  String toString() {
    return 'ScoreModel(playerId: $playerId, playerName: $playerName, score: $score, correctAnswers: $correctAnswers, totalAnswers: $totalAnswers, rank: $rank, timeTaken: $timeTaken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreModelImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.playerName, playerName) ||
                other.playerName == playerName) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.totalAnswers, totalAnswers) ||
                other.totalAnswers == totalAnswers) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.timeTaken, timeTaken) ||
                other.timeTaken == timeTaken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playerId,
    playerName,
    score,
    correctAnswers,
    totalAnswers,
    rank,
    timeTaken,
  );

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreModelImplCopyWith<_$ScoreModelImpl> get copyWith =>
      __$$ScoreModelImplCopyWithImpl<_$ScoreModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreModelImplToJson(this);
  }
}

abstract class _ScoreModel implements ScoreModel {
  const factory _ScoreModel({
    required final String playerId,
    required final String playerName,
    required final int score,
    required final int correctAnswers,
    required final int totalAnswers,
    final int? rank,
    final int? timeTaken,
  }) = _$ScoreModelImpl;

  factory _ScoreModel.fromJson(Map<String, dynamic> json) =
      _$ScoreModelImpl.fromJson;

  @override
  String get playerId;
  @override
  String get playerName;
  @override
  int get score;
  @override
  int get correctAnswers;
  @override
  int get totalAnswers;
  @override
  int? get rank;
  @override
  int? get timeTaken;

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreModelImplCopyWith<_$ScoreModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
