// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
    _$ServerFailureImpl value,
    $Res Function(_$ServerFailureImpl) then,
  ) = __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
    _$ServerFailureImpl _value,
    $Res Function(_$ServerFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$ServerFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.serverFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return serverFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return serverFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (serverFailure != null) {
      return serverFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return serverFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return serverFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (serverFailure != null) {
      return serverFailure(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements Failure {
  const factory ServerFailure({
    required final String message,
    final String? code,
  }) = _$ServerFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$NetworkFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.networkFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return networkFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return networkFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (networkFailure != null) {
      return networkFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return networkFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return networkFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (networkFailure != null) {
      return networkFailure(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure({required final String message}) =
      _$NetworkFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$AuthFailureImplCopyWith(
    _$AuthFailureImpl value,
    $Res Function(_$AuthFailureImpl) then,
  ) = __$$AuthFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$AuthFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$AuthFailureImpl>
    implements _$$AuthFailureImplCopyWith<$Res> {
  __$$AuthFailureImplCopyWithImpl(
    _$AuthFailureImpl _value,
    $Res Function(_$AuthFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$AuthFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AuthFailureImpl implements AuthFailure {
  const _$AuthFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.authFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthFailureImplCopyWith<_$AuthFailureImpl> get copyWith =>
      __$$AuthFailureImplCopyWithImpl<_$AuthFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return authFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return authFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (authFailure != null) {
      return authFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return authFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return authFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (authFailure != null) {
      return authFailure(this);
    }
    return orElse();
  }
}

abstract class AuthFailure implements Failure {
  const factory AuthFailure({
    required final String message,
    final String? code,
  }) = _$AuthFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthFailureImplCopyWith<_$AuthFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FirestoreFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$FirestoreFailureImplCopyWith(
    _$FirestoreFailureImpl value,
    $Res Function(_$FirestoreFailureImpl) then,
  ) = __$$FirestoreFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$FirestoreFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$FirestoreFailureImpl>
    implements _$$FirestoreFailureImplCopyWith<$Res> {
  __$$FirestoreFailureImplCopyWithImpl(
    _$FirestoreFailureImpl _value,
    $Res Function(_$FirestoreFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$FirestoreFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FirestoreFailureImpl implements FirestoreFailure {
  const _$FirestoreFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.firestoreFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirestoreFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirestoreFailureImplCopyWith<_$FirestoreFailureImpl> get copyWith =>
      __$$FirestoreFailureImplCopyWithImpl<_$FirestoreFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return firestoreFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return firestoreFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (firestoreFailure != null) {
      return firestoreFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return firestoreFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return firestoreFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (firestoreFailure != null) {
      return firestoreFailure(this);
    }
    return orElse();
  }
}

abstract class FirestoreFailure implements Failure {
  const factory FirestoreFailure({
    required final String message,
    final String? code,
  }) = _$FirestoreFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirestoreFailureImplCopyWith<_$FirestoreFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(
    _$ValidationFailureImpl value,
    $Res Function(_$ValidationFailureImpl) then,
  ) = __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Map<String, String>? fieldErrors});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(
    _$ValidationFailureImpl _value,
    $Res Function(_$ValidationFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? fieldErrors = freezed}) {
    return _then(
      _$ValidationFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        fieldErrors: freezed == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc

class _$ValidationFailureImpl implements ValidationFailure {
  const _$ValidationFailureImpl({
    required this.message,
    final Map<String, String>? fieldErrors,
  }) : _fieldErrors = fieldErrors;

  @override
  final String message;
  final Map<String, String>? _fieldErrors;
  @override
  Map<String, String>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Failure.validationFailure(message: $message, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(_fieldErrors),
  );

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return validationFailure(message, fieldErrors);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return validationFailure?.call(message, fieldErrors);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (validationFailure != null) {
      return validationFailure(message, fieldErrors);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return validationFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return validationFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (validationFailure != null) {
      return validationFailure(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure implements Failure {
  const factory ValidationFailure({
    required final String message,
    final Map<String, String>? fieldErrors,
  }) = _$ValidationFailureImpl;

  @override
  String get message;
  Map<String, String>? get fieldErrors;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
    _$CacheFailureImpl value,
    $Res Function(_$CacheFailureImpl) then,
  ) = __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
    _$CacheFailureImpl _value,
    $Res Function(_$CacheFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$CacheFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CacheFailureImpl implements CacheFailure {
  const _$CacheFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.cacheFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return cacheFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return cacheFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (cacheFailure != null) {
      return cacheFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return cacheFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return cacheFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (cacheFailure != null) {
      return cacheFailure(this);
    }
    return orElse();
  }
}

abstract class CacheFailure implements Failure {
  const factory CacheFailure({required final String message}) =
      _$CacheFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$UnknownFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.unknownFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return unknownFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return unknownFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (unknownFailure != null) {
      return unknownFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return unknownFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return unknownFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (unknownFailure != null) {
      return unknownFailure(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure({required final String message}) =
      _$UnknownFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SecurityFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$SecurityFailureImplCopyWith(
    _$SecurityFailureImpl value,
    $Res Function(_$SecurityFailureImpl) then,
  ) = __$$SecurityFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$SecurityFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$SecurityFailureImpl>
    implements _$$SecurityFailureImplCopyWith<$Res> {
  __$$SecurityFailureImplCopyWithImpl(
    _$SecurityFailureImpl _value,
    $Res Function(_$SecurityFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$SecurityFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SecurityFailureImpl implements SecurityFailure {
  const _$SecurityFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.securityFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityFailureImplCopyWith<_$SecurityFailureImpl> get copyWith =>
      __$$SecurityFailureImplCopyWithImpl<_$SecurityFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return securityFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return securityFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (securityFailure != null) {
      return securityFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return securityFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return securityFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (securityFailure != null) {
      return securityFailure(this);
    }
    return orElse();
  }
}

abstract class SecurityFailure implements Failure {
  const factory SecurityFailure({
    required final String message,
    final String? code,
  }) = _$SecurityFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityFailureImplCopyWith<_$SecurityFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BiometricFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$BiometricFailureImplCopyWith(
    _$BiometricFailureImpl value,
    $Res Function(_$BiometricFailureImpl) then,
  ) = __$$BiometricFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$BiometricFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$BiometricFailureImpl>
    implements _$$BiometricFailureImplCopyWith<$Res> {
  __$$BiometricFailureImplCopyWithImpl(
    _$BiometricFailureImpl _value,
    $Res Function(_$BiometricFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$BiometricFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$BiometricFailureImpl implements BiometricFailure {
  const _$BiometricFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.biometricFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BiometricFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BiometricFailureImplCopyWith<_$BiometricFailureImpl> get copyWith =>
      __$$BiometricFailureImplCopyWithImpl<_$BiometricFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return biometricFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return biometricFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (biometricFailure != null) {
      return biometricFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return biometricFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return biometricFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (biometricFailure != null) {
      return biometricFailure(this);
    }
    return orElse();
  }
}

abstract class BiometricFailure implements Failure {
  const factory BiometricFailure({
    required final String message,
    final String? code,
  }) = _$BiometricFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BiometricFailureImplCopyWith<_$BiometricFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$SessionFailureImplCopyWith(
    _$SessionFailureImpl value,
    $Res Function(_$SessionFailureImpl) then,
  ) = __$$SessionFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$SessionFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$SessionFailureImpl>
    implements _$$SessionFailureImplCopyWith<$Res> {
  __$$SessionFailureImplCopyWithImpl(
    _$SessionFailureImpl _value,
    $Res Function(_$SessionFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$SessionFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SessionFailureImpl implements SessionFailure {
  const _$SessionFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.sessionFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionFailureImplCopyWith<_$SessionFailureImpl> get copyWith =>
      __$$SessionFailureImplCopyWithImpl<_$SessionFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return sessionFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return sessionFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (sessionFailure != null) {
      return sessionFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return sessionFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return sessionFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (sessionFailure != null) {
      return sessionFailure(this);
    }
    return orElse();
  }
}

abstract class SessionFailure implements Failure {
  const factory SessionFailure({
    required final String message,
    final String? code,
  }) = _$SessionFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionFailureImplCopyWith<_$SessionFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$DeviceFailureImplCopyWith(
    _$DeviceFailureImpl value,
    $Res Function(_$DeviceFailureImpl) then,
  ) = __$$DeviceFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$DeviceFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$DeviceFailureImpl>
    implements _$$DeviceFailureImplCopyWith<$Res> {
  __$$DeviceFailureImplCopyWithImpl(
    _$DeviceFailureImpl _value,
    $Res Function(_$DeviceFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$DeviceFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DeviceFailureImpl implements DeviceFailure {
  const _$DeviceFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.deviceFailure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceFailureImplCopyWith<_$DeviceFailureImpl> get copyWith =>
      __$$DeviceFailureImplCopyWithImpl<_$DeviceFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) serverFailure,
    required TResult Function(String message) networkFailure,
    required TResult Function(String message, String? code) authFailure,
    required TResult Function(String message, String? code) firestoreFailure,
    required TResult Function(String message, Map<String, String>? fieldErrors)
    validationFailure,
    required TResult Function(String message) cacheFailure,
    required TResult Function(String message) unknownFailure,
    required TResult Function(String message, String? code) securityFailure,
    required TResult Function(String message, String? code) biometricFailure,
    required TResult Function(String message, String? code) sessionFailure,
    required TResult Function(String message, String? code) deviceFailure,
  }) {
    return deviceFailure(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? serverFailure,
    TResult? Function(String message)? networkFailure,
    TResult? Function(String message, String? code)? authFailure,
    TResult? Function(String message, String? code)? firestoreFailure,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult? Function(String message)? cacheFailure,
    TResult? Function(String message)? unknownFailure,
    TResult? Function(String message, String? code)? securityFailure,
    TResult? Function(String message, String? code)? biometricFailure,
    TResult? Function(String message, String? code)? sessionFailure,
    TResult? Function(String message, String? code)? deviceFailure,
  }) {
    return deviceFailure?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? serverFailure,
    TResult Function(String message)? networkFailure,
    TResult Function(String message, String? code)? authFailure,
    TResult Function(String message, String? code)? firestoreFailure,
    TResult Function(String message, Map<String, String>? fieldErrors)?
    validationFailure,
    TResult Function(String message)? cacheFailure,
    TResult Function(String message)? unknownFailure,
    TResult Function(String message, String? code)? securityFailure,
    TResult Function(String message, String? code)? biometricFailure,
    TResult Function(String message, String? code)? sessionFailure,
    TResult Function(String message, String? code)? deviceFailure,
    required TResult orElse(),
  }) {
    if (deviceFailure != null) {
      return deviceFailure(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(AuthFailure value) authFailure,
    required TResult Function(FirestoreFailure value) firestoreFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
    required TResult Function(SecurityFailure value) securityFailure,
    required TResult Function(BiometricFailure value) biometricFailure,
    required TResult Function(SessionFailure value) sessionFailure,
    required TResult Function(DeviceFailure value) deviceFailure,
  }) {
    return deviceFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(AuthFailure value)? authFailure,
    TResult? Function(FirestoreFailure value)? firestoreFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
    TResult? Function(SecurityFailure value)? securityFailure,
    TResult? Function(BiometricFailure value)? biometricFailure,
    TResult? Function(SessionFailure value)? sessionFailure,
    TResult? Function(DeviceFailure value)? deviceFailure,
  }) {
    return deviceFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(AuthFailure value)? authFailure,
    TResult Function(FirestoreFailure value)? firestoreFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    TResult Function(SecurityFailure value)? securityFailure,
    TResult Function(BiometricFailure value)? biometricFailure,
    TResult Function(SessionFailure value)? sessionFailure,
    TResult Function(DeviceFailure value)? deviceFailure,
    required TResult orElse(),
  }) {
    if (deviceFailure != null) {
      return deviceFailure(this);
    }
    return orElse();
  }
}

abstract class DeviceFailure implements Failure {
  const factory DeviceFailure({
    required final String message,
    final String? code,
  }) = _$DeviceFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceFailureImplCopyWith<_$DeviceFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
