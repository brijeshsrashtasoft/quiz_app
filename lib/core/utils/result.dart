import 'package:freezed_annotation/freezed_annotation.dart';
import '../errors/failures.dart';

part 'result.freezed.dart';

@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;
  
  T? get data => when(
    success: (data) => data,
    failure: (_) => null,
  );
  
  Failure? get failure => when(
    success: (_) => null,
    failure: (failure) => failure,
  );
}