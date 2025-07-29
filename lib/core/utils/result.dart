import 'package:freezed_annotation/freezed_annotation.dart';
import '../errors/failures.dart';

part 'result.freezed.dart';

/// Result pattern for error handling in Clean Architecture
/// Following CLAUDE.md patterns for proper error handling
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;
}

/// Extension methods for Result pattern
extension ResultX<T> on Result<T> {
  /// Check if result is successful
  bool get isSuccess => when(
    success: (_) => true,
    failure: (_) => false,
  );
  
  /// Check if result is failure
  bool get isFailure => !isSuccess;
  
  /// Get data if successful, null otherwise
  T? get dataOrNull => when(
    success: (data) => data,
    failure: (_) => null,
  );
  
  /// Get failure if error, null otherwise
  Failure? get failureOrNull => when(
    success: (_) => null,
    failure: (failure) => failure,
  );
  
  /// Transform success data
  Result<R> transform<R>(R Function(T) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (failure) => Result.failure(failure),
    );
  }
  
  /// Chain operations
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return when(
      success: (data) => transform(data),
      failure: (failure) => Result.failure(failure),
    );
  }
  
  /// Get data or throw exception
  T get dataOrThrow => when(
    success: (data) => data,
    failure: (failure) => throw Exception(failure.userMessage),
  );
}