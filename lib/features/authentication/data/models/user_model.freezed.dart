// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  UserStatsModel? get stats => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  UserPreferencesModel? get preferences => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String email,
    DateTime createdAt,
    UserStatsModel? stats,
    String? profileImageUrl,
    UserPreferencesModel? preferences,
  });

  $UserStatsModelCopyWith<$Res>? get stats;
  $UserPreferencesModelCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? createdAt = null,
    Object? stats = freezed,
    Object? profileImageUrl = freezed,
    Object? preferences = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            stats: freezed == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as UserStatsModel?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            preferences: freezed == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as UserPreferencesModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserStatsModelCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $UserStatsModelCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesModelCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $UserPreferencesModelCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String email,
    DateTime createdAt,
    UserStatsModel? stats,
    String? profileImageUrl,
    UserPreferencesModel? preferences,
  });

  @override
  $UserStatsModelCopyWith<$Res>? get stats;
  @override
  $UserPreferencesModelCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? createdAt = null,
    Object? stats = freezed,
    Object? profileImageUrl = freezed,
    Object? preferences = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        stats: freezed == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as UserStatsModel?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferences: freezed == preferences
            ? _value.preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as UserPreferencesModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.stats,
    this.profileImageUrl,
    this.preferences,
  });

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final DateTime createdAt;
  @override
  final UserStatsModel? stats;
  @override
  final String? profileImageUrl;
  @override
  final UserPreferencesModel? preferences;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, createdAt: $createdAt, stats: $stats, profileImageUrl: $profileImageUrl, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    createdAt,
    stats,
    profileImageUrl,
    preferences,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String id,
    required final String name,
    required final String email,
    required final DateTime createdAt,
    final UserStatsModel? stats,
    final String? profileImageUrl,
    final UserPreferencesModel? preferences,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  DateTime get createdAt;
  @override
  UserStatsModel? get stats;
  @override
  String? get profileImageUrl;
  @override
  UserPreferencesModel? get preferences;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) {
  return _UserStatsModel.fromJson(json);
}

/// @nodoc
mixin _$UserStatsModel {
  int get totalQuizzes => throw _privateConstructorUsedError;
  int get totalGamesPlayed => throw _privateConstructorUsedError;
  int get totalGamesWon => throw _privateConstructorUsedError;
  double get averageScore => throw _privateConstructorUsedError;
  DateTime? get lastGameDate => throw _privateConstructorUsedError;

  /// Serializes this UserStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsModelCopyWith<UserStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsModelCopyWith<$Res> {
  factory $UserStatsModelCopyWith(
    UserStatsModel value,
    $Res Function(UserStatsModel) then,
  ) = _$UserStatsModelCopyWithImpl<$Res, UserStatsModel>;
  @useResult
  $Res call({
    int totalQuizzes,
    int totalGamesPlayed,
    int totalGamesWon,
    double averageScore,
    DateTime? lastGameDate,
  });
}

/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res, $Val extends UserStatsModel>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalQuizzes = null,
    Object? totalGamesPlayed = null,
    Object? totalGamesWon = null,
    Object? averageScore = null,
    Object? lastGameDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalQuizzes: null == totalQuizzes
                ? _value.totalQuizzes
                : totalQuizzes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalGamesPlayed: null == totalGamesPlayed
                ? _value.totalGamesPlayed
                : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalGamesWon: null == totalGamesWon
                ? _value.totalGamesWon
                : totalGamesWon // ignore: cast_nullable_to_non_nullable
                      as int,
            averageScore: null == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double,
            lastGameDate: freezed == lastGameDate
                ? _value.lastGameDate
                : lastGameDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserStatsModelImplCopyWith<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  factory _$$UserStatsModelImplCopyWith(
    _$UserStatsModelImpl value,
    $Res Function(_$UserStatsModelImpl) then,
  ) = __$$UserStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalQuizzes,
    int totalGamesPlayed,
    int totalGamesWon,
    double averageScore,
    DateTime? lastGameDate,
  });
}

/// @nodoc
class __$$UserStatsModelImplCopyWithImpl<$Res>
    extends _$UserStatsModelCopyWithImpl<$Res, _$UserStatsModelImpl>
    implements _$$UserStatsModelImplCopyWith<$Res> {
  __$$UserStatsModelImplCopyWithImpl(
    _$UserStatsModelImpl _value,
    $Res Function(_$UserStatsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalQuizzes = null,
    Object? totalGamesPlayed = null,
    Object? totalGamesWon = null,
    Object? averageScore = null,
    Object? lastGameDate = freezed,
  }) {
    return _then(
      _$UserStatsModelImpl(
        totalQuizzes: null == totalQuizzes
            ? _value.totalQuizzes
            : totalQuizzes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalGamesPlayed: null == totalGamesPlayed
            ? _value.totalGamesPlayed
            : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalGamesWon: null == totalGamesWon
            ? _value.totalGamesWon
            : totalGamesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        averageScore: null == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double,
        lastGameDate: freezed == lastGameDate
            ? _value.lastGameDate
            : lastGameDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsModelImpl implements _UserStatsModel {
  const _$UserStatsModelImpl({
    this.totalQuizzes = 0,
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.averageScore = 0.0,
    this.lastGameDate,
  });

  factory _$UserStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsModelImplFromJson(json);

  @override
  @JsonKey()
  final int totalQuizzes;
  @override
  @JsonKey()
  final int totalGamesPlayed;
  @override
  @JsonKey()
  final int totalGamesWon;
  @override
  @JsonKey()
  final double averageScore;
  @override
  final DateTime? lastGameDate;

  @override
  String toString() {
    return 'UserStatsModel(totalQuizzes: $totalQuizzes, totalGamesPlayed: $totalGamesPlayed, totalGamesWon: $totalGamesWon, averageScore: $averageScore, lastGameDate: $lastGameDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsModelImpl &&
            (identical(other.totalQuizzes, totalQuizzes) ||
                other.totalQuizzes == totalQuizzes) &&
            (identical(other.totalGamesPlayed, totalGamesPlayed) ||
                other.totalGamesPlayed == totalGamesPlayed) &&
            (identical(other.totalGamesWon, totalGamesWon) ||
                other.totalGamesWon == totalGamesWon) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.lastGameDate, lastGameDate) ||
                other.lastGameDate == lastGameDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalQuizzes,
    totalGamesPlayed,
    totalGamesWon,
    averageScore,
    lastGameDate,
  );

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      __$$UserStatsModelImplCopyWithImpl<_$UserStatsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsModelImplToJson(this);
  }
}

abstract class _UserStatsModel implements UserStatsModel {
  const factory _UserStatsModel({
    final int totalQuizzes,
    final int totalGamesPlayed,
    final int totalGamesWon,
    final double averageScore,
    final DateTime? lastGameDate,
  }) = _$UserStatsModelImpl;

  factory _UserStatsModel.fromJson(Map<String, dynamic> json) =
      _$UserStatsModelImpl.fromJson;

  @override
  int get totalQuizzes;
  @override
  int get totalGamesPlayed;
  @override
  int get totalGamesWon;
  @override
  double get averageScore;
  @override
  DateTime? get lastGameDate;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferencesModel _$UserPreferencesModelFromJson(Map<String, dynamic> json) {
  return _UserPreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$UserPreferencesModel {
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;

  /// Serializes this UserPreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesModelCopyWith<UserPreferencesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesModelCopyWith<$Res> {
  factory $UserPreferencesModelCopyWith(
    UserPreferencesModel value,
    $Res Function(UserPreferencesModel) then,
  ) = _$UserPreferencesModelCopyWithImpl<$Res, UserPreferencesModel>;
  @useResult
  $Res call({
    bool soundEnabled,
    bool notificationsEnabled,
    String theme,
    String language,
  });
}

/// @nodoc
class _$UserPreferencesModelCopyWithImpl<
  $Res,
  $Val extends UserPreferencesModel
>
    implements $UserPreferencesModelCopyWith<$Res> {
  _$UserPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soundEnabled = null,
    Object? notificationsEnabled = null,
    Object? theme = null,
    Object? language = null,
  }) {
    return _then(
      _value.copyWith(
            soundEnabled: null == soundEnabled
                ? _value.soundEnabled
                : soundEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPreferencesModelImplCopyWith<$Res>
    implements $UserPreferencesModelCopyWith<$Res> {
  factory _$$UserPreferencesModelImplCopyWith(
    _$UserPreferencesModelImpl value,
    $Res Function(_$UserPreferencesModelImpl) then,
  ) = __$$UserPreferencesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool soundEnabled,
    bool notificationsEnabled,
    String theme,
    String language,
  });
}

/// @nodoc
class __$$UserPreferencesModelImplCopyWithImpl<$Res>
    extends _$UserPreferencesModelCopyWithImpl<$Res, _$UserPreferencesModelImpl>
    implements _$$UserPreferencesModelImplCopyWith<$Res> {
  __$$UserPreferencesModelImplCopyWithImpl(
    _$UserPreferencesModelImpl _value,
    $Res Function(_$UserPreferencesModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soundEnabled = null,
    Object? notificationsEnabled = null,
    Object? theme = null,
    Object? language = null,
  }) {
    return _then(
      _$UserPreferencesModelImpl(
        soundEnabled: null == soundEnabled
            ? _value.soundEnabled
            : soundEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesModelImpl implements _UserPreferencesModel {
  const _$UserPreferencesModelImpl({
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.theme = 'light',
    this.language = 'en',
  });

  factory _$UserPreferencesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesModelImplFromJson(json);

  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final String theme;
  @override
  @JsonKey()
  final String language;

  @override
  String toString() {
    return 'UserPreferencesModel(soundEnabled: $soundEnabled, notificationsEnabled: $notificationsEnabled, theme: $theme, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesModelImpl &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    soundEnabled,
    notificationsEnabled,
    theme,
    language,
  );

  /// Create a copy of UserPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesModelImplCopyWith<_$UserPreferencesModelImpl>
  get copyWith =>
      __$$UserPreferencesModelImplCopyWithImpl<_$UserPreferencesModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesModelImplToJson(this);
  }
}

abstract class _UserPreferencesModel implements UserPreferencesModel {
  const factory _UserPreferencesModel({
    final bool soundEnabled,
    final bool notificationsEnabled,
    final String theme,
    final String language,
  }) = _$UserPreferencesModelImpl;

  factory _UserPreferencesModel.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesModelImpl.fromJson;

  @override
  bool get soundEnabled;
  @override
  bool get notificationsEnabled;
  @override
  String get theme;
  @override
  String get language;

  /// Create a copy of UserPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesModelImplCopyWith<_$UserPreferencesModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
