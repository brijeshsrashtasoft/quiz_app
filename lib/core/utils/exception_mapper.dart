import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Utility class to map exceptions to failures
/// Following CLAUDE.md Clean Architecture patterns
class ExceptionMapper {
  /// Map any exception to appropriate failure
  static Failure mapExceptionToFailure(Exception exception) {
    switch (exception.runtimeType) {
      case ServerException _:
        final serverException = exception as ServerException;
        return Failure.serverFailure(
          message: serverException.message,
          code: serverException.code,
        );
      case NetworkException _:
        final networkException = exception as NetworkException;
        return Failure.networkFailure(message: networkException.message);
      case AuthException _:
        final authException = exception as AuthException;
        return Failure.authFailure(
          message: authException.message,
          code: authException.code,
        );
      case FirestoreException _:
        final firestoreException = exception as FirestoreException;
        return Failure.firestoreFailure(
          message: firestoreException.message,
          code: firestoreException.code,
        );
      case ValidationException _:
        final validationException = exception as ValidationException;
        return Failure.validationFailure(
          message: validationException.message,
          fieldErrors: validationException.fieldErrors,
        );
      case CacheException _:
        final cacheException = exception as CacheException;
        return Failure.cacheFailure(message: cacheException.message);
      default:
        return Failure.unknownFailure(message: exception.toString());
    }
  }

  /// Helper for creating data exceptions (for backward compatibility)
  static Exception dataException(String message, {String? code}) {
    return ServerException(message: message, code: code);
  }
}

/// Extension method for easier exception mapping
extension ExceptionMapperX on Exception {
  Failure toFailure() => ExceptionMapper.mapExceptionToFailure(this);
}
