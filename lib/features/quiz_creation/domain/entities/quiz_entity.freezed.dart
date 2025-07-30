// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QuizEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  List<QuestionEntity> get questions => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  int? get estimatedDuration => throw _privateConstructorUsedError;

  /// Create a copy of QuizEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizEntityCopyWith<QuizEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizEntityCopyWith<$Res> {
  factory $QuizEntityCopyWith(
    QuizEntity value,
    $Res Function(QuizEntity) then,
  ) = _$QuizEntityCopyWithImpl<$Res, QuizEntity>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String createdBy,
    List<QuestionEntity> questions,
    bool isPublic,
    DateTime createdAt,
    String? category,
    int? estimatedDuration,
  });
}

/// @nodoc
class _$QuizEntityCopyWithImpl<$Res, $Val extends QuizEntity>
    implements $QuizEntityCopyWith<$Res> {
  _$QuizEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? createdBy = null,
    Object? questions = null,
    Object? isPublic = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? estimatedDuration = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<QuestionEntity>,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            estimatedDuration: freezed == estimatedDuration
                ? _value.estimatedDuration
                : estimatedDuration // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuizEntityImplCopyWith<$Res>
    implements $QuizEntityCopyWith<$Res> {
  factory _$$QuizEntityImplCopyWith(
    _$QuizEntityImpl value,
    $Res Function(_$QuizEntityImpl) then,
  ) = __$$QuizEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String createdBy,
    List<QuestionEntity> questions,
    bool isPublic,
    DateTime createdAt,
    String? category,
    int? estimatedDuration,
  });
}

/// @nodoc
class __$$QuizEntityImplCopyWithImpl<$Res>
    extends _$QuizEntityCopyWithImpl<$Res, _$QuizEntityImpl>
    implements _$$QuizEntityImplCopyWith<$Res> {
  __$$QuizEntityImplCopyWithImpl(
    _$QuizEntityImpl _value,
    $Res Function(_$QuizEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuizEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? createdBy = null,
    Object? questions = null,
    Object? isPublic = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? estimatedDuration = freezed,
  }) {
    return _then(
      _$QuizEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<QuestionEntity>,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        estimatedDuration: freezed == estimatedDuration
            ? _value.estimatedDuration
            : estimatedDuration // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$QuizEntityImpl implements _QuizEntity {
  const _$QuizEntityImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required final List<QuestionEntity> questions,
    required this.isPublic,
    required this.createdAt,
    this.category,
    this.estimatedDuration,
  }) : _questions = questions;

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String createdBy;
  final List<QuestionEntity> _questions;
  @override
  List<QuestionEntity> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final bool isPublic;
  @override
  final DateTime createdAt;
  @override
  final String? category;
  @override
  final int? estimatedDuration;

  @override
  String toString() {
    return 'QuizEntity(id: $id, title: $title, description: $description, createdBy: $createdBy, questions: $questions, isPublic: $isPublic, createdAt: $createdAt, category: $category, estimatedDuration: $estimatedDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    createdBy,
    const DeepCollectionEquality().hash(_questions),
    isPublic,
    createdAt,
    category,
    estimatedDuration,
  );

  /// Create a copy of QuizEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizEntityImplCopyWith<_$QuizEntityImpl> get copyWith =>
      __$$QuizEntityImplCopyWithImpl<_$QuizEntityImpl>(this, _$identity);
}

abstract class _QuizEntity implements QuizEntity {
  const factory _QuizEntity({
    required final String id,
    required final String title,
    required final String description,
    required final String createdBy,
    required final List<QuestionEntity> questions,
    required final bool isPublic,
    required final DateTime createdAt,
    final String? category,
    final int? estimatedDuration,
  }) = _$QuizEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get createdBy;
  @override
  List<QuestionEntity> get questions;
  @override
  bool get isPublic;
  @override
  DateTime get createdAt;
  @override
  String? get category;
  @override
  int? get estimatedDuration;

  /// Create a copy of QuizEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizEntityImplCopyWith<_$QuizEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QuestionEntity {
  String get question => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int get correctAnswer => throw _privateConstructorUsedError;
  int get timeLimit => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Create a copy of QuestionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionEntityCopyWith<QuestionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionEntityCopyWith<$Res> {
  factory $QuestionEntityCopyWith(
    QuestionEntity value,
    $Res Function(QuestionEntity) then,
  ) = _$QuestionEntityCopyWithImpl<$Res, QuestionEntity>;
  @useResult
  $Res call({
    String question,
    List<String> options,
    int correctAnswer,
    int timeLimit,
    int points,
    String? imageUrl,
  });
}

/// @nodoc
class _$QuestionEntityCopyWithImpl<$Res, $Val extends QuestionEntity>
    implements $QuestionEntityCopyWith<$Res> {
  _$QuestionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? timeLimit = null,
    Object? points = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as int,
            timeLimit: null == timeLimit
                ? _value.timeLimit
                : timeLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionEntityImplCopyWith<$Res>
    implements $QuestionEntityCopyWith<$Res> {
  factory _$$QuestionEntityImplCopyWith(
    _$QuestionEntityImpl value,
    $Res Function(_$QuestionEntityImpl) then,
  ) = __$$QuestionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String question,
    List<String> options,
    int correctAnswer,
    int timeLimit,
    int points,
    String? imageUrl,
  });
}

/// @nodoc
class __$$QuestionEntityImplCopyWithImpl<$Res>
    extends _$QuestionEntityCopyWithImpl<$Res, _$QuestionEntityImpl>
    implements _$$QuestionEntityImplCopyWith<$Res> {
  __$$QuestionEntityImplCopyWithImpl(
    _$QuestionEntityImpl _value,
    $Res Function(_$QuestionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? timeLimit = null,
    Object? points = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$QuestionEntityImpl(
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as int,
        timeLimit: null == timeLimit
            ? _value.timeLimit
            : timeLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$QuestionEntityImpl implements _QuestionEntity {
  const _$QuestionEntityImpl({
    required this.question,
    required final List<String> options,
    required this.correctAnswer,
    required this.timeLimit,
    this.points = 100,
    this.imageUrl,
  }) : _options = options;

  @override
  final String question;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctAnswer;
  @override
  final int timeLimit;
  @override
  @JsonKey()
  final int points;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'QuestionEntity(question: $question, options: $options, correctAnswer: $correctAnswer, timeLimit: $timeLimit, points: $points, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionEntityImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    question,
    const DeepCollectionEquality().hash(_options),
    correctAnswer,
    timeLimit,
    points,
    imageUrl,
  );

  /// Create a copy of QuestionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionEntityImplCopyWith<_$QuestionEntityImpl> get copyWith =>
      __$$QuestionEntityImplCopyWithImpl<_$QuestionEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _QuestionEntity implements QuestionEntity {
  const factory _QuestionEntity({
    required final String question,
    required final List<String> options,
    required final int correctAnswer,
    required final int timeLimit,
    final int points,
    final String? imageUrl,
  }) = _$QuestionEntityImpl;

  @override
  String get question;
  @override
  List<String> get options;
  @override
  int get correctAnswer;
  @override
  int get timeLimit;
  @override
  int get points;
  @override
  String? get imageUrl;

  /// Create a copy of QuestionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionEntityImplCopyWith<_$QuestionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
