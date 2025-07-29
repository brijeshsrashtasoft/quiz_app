import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.serverFailure([String? message]) = ServerFailure;
  const factory Failure.networkFailure([String? message]) = NetworkFailure;
  const factory Failure.authFailure([String? message]) = AuthFailure;
  const factory Failure.validationFailure([String? message]) = ValidationFailure;
  const factory Failure.unexpectedFailure([String? message]) = UnexpectedFailure;
}

extension FailureX on Failure {
  String get message {
    return when(
      serverFailure: (message) => message ?? 'Server error occurred',
      networkFailure: (message) => message ?? 'Network connection failed',
      authFailure: (message) => message ?? 'Authentication failed',
      validationFailure: (message) => message ?? 'Validation failed',
      unexpectedFailure: (message) => message ?? 'An unexpected error occurred',
    );
  }
}