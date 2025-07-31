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
  String get quizId => throw _privateConstructorUsedError;
  List<LeaderboardEntryModel> get entries => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get totalPlayers => throw _privateConstructorUsedError;

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
    String quizId,
    List<LeaderboardEntryModel> entries,
    DateTime lastUpdated,
    String type,
    int totalPlayers,
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
    Object? quizId = null,
    Object? entries = null,
    Object? lastUpdated = null,
    Object? type = null,
    Object? totalPlayers = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            quizId: null == quizId
                ? _value.quizId
                : quizId // ignore: cast_nullable_to_non_nullable
                      as String,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<LeaderboardEntryModel>,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            totalPlayers: null == totalPlayers
                ? _value.totalPlayers
                : totalPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
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
    String quizId,
    List<LeaderboardEntryModel> entries,
    DateTime lastUpdated,
    String type,
    int totalPlayers,
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
    Object? quizId = null,
    Object? entries = null,
    Object? lastUpdated = null,
    Object? type = null,
    Object? totalPlayers = null,
  }) {
    return _then(
      _$LeaderboardModelImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        quizId: null == quizId
            ? _value.quizId
            : quizId // ignore: cast_nullable_to_non_nullable
                  as String,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<LeaderboardEntryModel>,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        totalPlayers: null == totalPlayers
            ? _value.totalPlayers
            : totalPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardModelImpl extends _LeaderboardModel {
  const _$LeaderboardModelImpl({
    required this.sessionId,
    required this.quizId,
    required final List<LeaderboardEntryModel> entries,
    required this.lastUpdated,
    required this.type,
    required this.totalPlayers,
  }) : _entries = entries,
       super._();

  factory _$LeaderboardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardModelImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String quizId;
  final List<LeaderboardEntryModel> _entries;
  @override
  List<LeaderboardEntryModel> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final DateTime lastUpdated;
  @override
  final String type;
  @override
  final int totalPlayers;

  @override
  String toString() {
    return 'LeaderboardModel(sessionId: $sessionId, quizId: $quizId, entries: $entries, lastUpdated: $lastUpdated, type: $type, totalPlayers: $totalPlayers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardModelImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.totalPlayers, totalPlayers) ||
                other.totalPlayers == totalPlayers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    quizId,
    const DeepCollectionEquality().hash(_entries),
    lastUpdated,
    type,
    totalPlayers,
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

abstract class _LeaderboardModel extends LeaderboardModel {
  const factory _LeaderboardModel({
    required final String sessionId,
    required final String quizId,
    required final List<LeaderboardEntryModel> entries,
    required final DateTime lastUpdated,
    required final String type,
    required final int totalPlayers,
  }) = _$LeaderboardModelImpl;
  const _LeaderboardModel._() : super._();

  factory _LeaderboardModel.fromJson(Map<String, dynamic> json) =
      _$LeaderboardModelImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get quizId;
  @override
  List<LeaderboardEntryModel> get entries;
  @override
  DateTime get lastUpdated;
  @override
  String get type;
  @override
  int get totalPlayers;

  /// Create a copy of LeaderboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardModelImplCopyWith<_$LeaderboardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
