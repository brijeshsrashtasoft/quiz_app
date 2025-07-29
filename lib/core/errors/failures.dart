import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base failure class for error handling in Clean Architecture
/// Following CLAUDE.md error handling patterns
@freezed
class Failure with _$Failure {
  const factory Failure.serverFailure({required String message, String? code}) =
      ServerFailure;

  const factory Failure.networkFailure({required String message}) =
      NetworkFailure;

  const factory Failure.authFailure({required String message, String? code}) =
      AuthFailure;

  const factory Failure.firestoreFailure({
    required String message,
    String? code,
  }) = FirestoreFailure;

  const factory Failure.validationFailure({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  const factory Failure.cacheFailure({required String message}) = CacheFailure;

  const factory Failure.unknownFailure({required String message}) =
      UnknownFailure;
}

/// Extension for user-friendly error messages
extension FailureX on Failure {
  String get userMessage {
    return when(
      serverFailure: (message, code) => 'Server error: $message',
      networkFailure: (message) => 'Network error: $message',
      authFailure: (message, code) => 'Authentication error: $message',
      firestoreFailure: (message, code) => 'Database error: $message',
      validationFailure: (message, fieldErrors) => 'Validation error: $message',
      cacheFailure: (message) => 'Cache error: $message',
      unknownFailure: (message) => 'Unknown error: $message',
    );
  }
}
