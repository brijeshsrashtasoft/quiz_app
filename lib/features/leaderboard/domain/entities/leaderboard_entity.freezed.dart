// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LeaderboardEntity {
  String get sessionId => throw _privateConstructorUsedError;
  List<ScoreEntity> get scores => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get finalResults => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntityCopyWith<LeaderboardEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntityCopyWith<$Res> {
  factory $LeaderboardEntityCopyWith(
    LeaderboardEntity value,
    $Res Function(LeaderboardEntity) then,
  ) = _$LeaderboardEntityCopyWithImpl<$Res, LeaderboardEntity>;
  @useResult
  $Res call({
    String sessionId,
    List<ScoreEntity> scores,
    DateTime updatedAt,
    bool finalResults,
  });
}

/// @nodoc
class _$LeaderboardEntityCopyWithImpl<$Res, $Val extends LeaderboardEntity>
    implements $LeaderboardEntityCopyWith<$Res> {
  _$LeaderboardEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntity
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
                      as List<ScoreEntity>,
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
abstract class _$$LeaderboardEntityImplCopyWith<$Res>
    implements $LeaderboardEntityCopyWith<$Res> {
  factory _$$LeaderboardEntityImplCopyWith(
    _$LeaderboardEntityImpl value,
    $Res Function(_$LeaderboardEntityImpl) then,
  ) = __$$LeaderboardEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    List<ScoreEntity> scores,
    DateTime updatedAt,
    bool finalResults,
  });
}

/// @nodoc
class __$$LeaderboardEntityImplCopyWithImpl<$Res>
    extends _$LeaderboardEntityCopyWithImpl<$Res, _$LeaderboardEntityImpl>
    implements _$$LeaderboardEntityImplCopyWith<$Res> {
  __$$LeaderboardEntityImplCopyWithImpl(
    _$LeaderboardEntityImpl _value,
    $Res Function(_$LeaderboardEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntity
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
      _$LeaderboardEntityImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        scores: null == scores
            ? _value._scores
            : scores // ignore: cast_nullable_to_non_nullable
                  as List<ScoreEntity>,
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

class _$LeaderboardEntityImpl implements _LeaderboardEntity {
  const _$LeaderboardEntityImpl({
    required this.sessionId,
    required final List<ScoreEntity> scores,
    required this.updatedAt,
    this.finalResults = false,
  }) : _scores = scores;

  @override
  final String sessionId;
  final List<ScoreEntity> _scores;
  @override
  List<ScoreEntity> get scores {
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
    return 'LeaderboardEntity(sessionId: $sessionId, scores: $scores, updatedAt: $updatedAt, finalResults: $finalResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntityImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.finalResults, finalResults) ||
                other.finalResults == finalResults));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    const DeepCollectionEquality().hash(_scores),
    updatedAt,
    finalResults,
  );

  /// Create a copy of LeaderboardEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntityImplCopyWith<_$LeaderboardEntityImpl> get copyWith =>
      __$$LeaderboardEntityImplCopyWithImpl<_$LeaderboardEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _LeaderboardEntity implements LeaderboardEntity {
  const factory _LeaderboardEntity({
    required final String sessionId,
    required final List<ScoreEntity> scores,
    required final DateTime updatedAt,
    final bool finalResults,
  }) = _$LeaderboardEntityImpl;

  @override
  String get sessionId;
  @override
  List<ScoreEntity> get scores;
  @override
  DateTime get updatedAt;
  @override
  bool get finalResults;

  /// Create a copy of LeaderboardEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntityImplCopyWith<_$LeaderboardEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ScoreEntity {
  String get playerId => throw _privateConstructorUsedError;
  String get playerName => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;
  int get totalAnswers => throw _privateConstructorUsedError;
  int? get rank => throw _privateConstructorUsedError;
  int? get timeTaken => throw _privateConstructorUsedError;

  /// Create a copy of ScoreEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreEntityCopyWith<ScoreEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreEntityCopyWith<$Res> {
  factory $ScoreEntityCopyWith(
    ScoreEntity value,
    $Res Function(ScoreEntity) then,
  ) = _$ScoreEntityCopyWithImpl<$Res, ScoreEntity>;
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
class _$ScoreEntityCopyWithImpl<$Res, $Val extends ScoreEntity>
    implements $ScoreEntityCopyWith<$Res> {
  _$ScoreEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreEntity
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
abstract class _$$ScoreEntityImplCopyWith<$Res>
    implements $ScoreEntityCopyWith<$Res> {
  factory _$$ScoreEntityImplCopyWith(
    _$ScoreEntityImpl value,
    $Res Function(_$ScoreEntityImpl) then,
  ) = __$$ScoreEntityImplCopyWithImpl<$Res>;
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
class __$$ScoreEntityImplCopyWithImpl<$Res>
    extends _$ScoreEntityCopyWithImpl<$Res, _$ScoreEntityImpl>
    implements _$$ScoreEntityImplCopyWith<$Res> {
  __$$ScoreEntityImplCopyWithImpl(
    _$ScoreEntityImpl _value,
    $Res Function(_$ScoreEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScoreEntity
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
      _$ScoreEntityImpl(
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

class _$ScoreEntityImpl implements _ScoreEntity {
  const _$ScoreEntityImpl({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.correctAnswers,
    required this.totalAnswers,
    this.rank,
    this.timeTaken,
  });

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
    return 'ScoreEntity(playerId: $playerId, playerName: $playerName, score: $score, correctAnswers: $correctAnswers, totalAnswers: $totalAnswers, rank: $rank, timeTaken: $timeTaken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreEntityImpl &&
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

  /// Create a copy of ScoreEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreEntityImplCopyWith<_$ScoreEntityImpl> get copyWith =>
      __$$ScoreEntityImplCopyWithImpl<_$ScoreEntityImpl>(this, _$identity);
}

abstract class _ScoreEntity implements ScoreEntity {
  const factory _ScoreEntity({
    required final String playerId,
    required final String playerName,
    required final int score,
    required final int correctAnswers,
    required final int totalAnswers,
    final int? rank,
    final int? timeTaken,
  }) = _$ScoreEntityImpl;

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

  /// Create a copy of ScoreEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreEntityImplCopyWith<_$ScoreEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LeaderboardStats {
  int get totalParticipants => throw _privateConstructorUsedError;
  double get averageScore => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  int get perfectScores => throw _privateConstructorUsedError;
  int get averageTimeTaken => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardStatsCopyWith<LeaderboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardStatsCopyWith<$Res> {
  factory $LeaderboardStatsCopyWith(
    LeaderboardStats value,
    $Res Function(LeaderboardStats) then,
  ) = _$LeaderboardStatsCopyWithImpl<$Res, LeaderboardStats>;
  @useResult
  $Res call({
    int totalParticipants,
    double averageScore,
    double averageAccuracy,
    int perfectScores,
    int averageTimeTaken,
  });
}

/// @nodoc
class _$LeaderboardStatsCopyWithImpl<$Res, $Val extends LeaderboardStats>
    implements $LeaderboardStatsCopyWith<$Res> {
  _$LeaderboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalParticipants = null,
    Object? averageScore = null,
    Object? averageAccuracy = null,
    Object? perfectScores = null,
    Object? averageTimeTaken = null,
  }) {
    return _then(
      _value.copyWith(
            totalParticipants: null == totalParticipants
                ? _value.totalParticipants
                : totalParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            averageScore: null == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double,
            averageAccuracy: null == averageAccuracy
                ? _value.averageAccuracy
                : averageAccuracy // ignore: cast_nullable_to_non_nullable
                      as double,
            perfectScores: null == perfectScores
                ? _value.perfectScores
                : perfectScores // ignore: cast_nullable_to_non_nullable
                      as int,
            averageTimeTaken: null == averageTimeTaken
                ? _value.averageTimeTaken
                : averageTimeTaken // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardStatsImplCopyWith<$Res>
    implements $LeaderboardStatsCopyWith<$Res> {
  factory _$$LeaderboardStatsImplCopyWith(
    _$LeaderboardStatsImpl value,
    $Res Function(_$LeaderboardStatsImpl) then,
  ) = __$$LeaderboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalParticipants,
    double averageScore,
    double averageAccuracy,
    int perfectScores,
    int averageTimeTaken,
  });
}

/// @nodoc
class __$$LeaderboardStatsImplCopyWithImpl<$Res>
    extends _$LeaderboardStatsCopyWithImpl<$Res, _$LeaderboardStatsImpl>
    implements _$$LeaderboardStatsImplCopyWith<$Res> {
  __$$LeaderboardStatsImplCopyWithImpl(
    _$LeaderboardStatsImpl _value,
    $Res Function(_$LeaderboardStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalParticipants = null,
    Object? averageScore = null,
    Object? averageAccuracy = null,
    Object? perfectScores = null,
    Object? averageTimeTaken = null,
  }) {
    return _then(
      _$LeaderboardStatsImpl(
        totalParticipants: null == totalParticipants
            ? _value.totalParticipants
            : totalParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        averageScore: null == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double,
        averageAccuracy: null == averageAccuracy
            ? _value.averageAccuracy
            : averageAccuracy // ignore: cast_nullable_to_non_nullable
                  as double,
        perfectScores: null == perfectScores
            ? _value.perfectScores
            : perfectScores // ignore: cast_nullable_to_non_nullable
                  as int,
        averageTimeTaken: null == averageTimeTaken
            ? _value.averageTimeTaken
            : averageTimeTaken // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$LeaderboardStatsImpl implements _LeaderboardStats {
  const _$LeaderboardStatsImpl({
    required this.totalParticipants,
    required this.averageScore,
    required this.averageAccuracy,
    required this.perfectScores,
    required this.averageTimeTaken,
  });

  @override
  final int totalParticipants;
  @override
  final double averageScore;
  @override
  final double averageAccuracy;
  @override
  final int perfectScores;
  @override
  final int averageTimeTaken;

  @override
  String toString() {
    return 'LeaderboardStats(totalParticipants: $totalParticipants, averageScore: $averageScore, averageAccuracy: $averageAccuracy, perfectScores: $perfectScores, averageTimeTaken: $averageTimeTaken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardStatsImpl &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            (identical(other.perfectScores, perfectScores) ||
                other.perfectScores == perfectScores) &&
            (identical(other.averageTimeTaken, averageTimeTaken) ||
                other.averageTimeTaken == averageTimeTaken));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalParticipants,
    averageScore,
    averageAccuracy,
    perfectScores,
    averageTimeTaken,
  );

  /// Create a copy of LeaderboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardStatsImplCopyWith<_$LeaderboardStatsImpl> get copyWith =>
      __$$LeaderboardStatsImplCopyWithImpl<_$LeaderboardStatsImpl>(
        this,
        _$identity,
      );
}

abstract class _LeaderboardStats implements LeaderboardStats {
  const factory _LeaderboardStats({
    required final int totalParticipants,
    required final double averageScore,
    required final double averageAccuracy,
    required final int perfectScores,
    required final int averageTimeTaken,
  }) = _$LeaderboardStatsImpl;

  @override
  int get totalParticipants;
  @override
  double get averageScore;
  @override
  double get averageAccuracy;
  @override
  int get perfectScores;
  @override
  int get averageTimeTaken;

  /// Create a copy of LeaderboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardStatsImplCopyWith<_$LeaderboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
