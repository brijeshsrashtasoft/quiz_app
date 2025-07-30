import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Utility class to map exceptions to failures
/// Following CLAUDE.md Clean Architecture patterns
class ExceptionMapper {
  /// Map any exception to appropriate failure
  static Failure mapExceptionToFailure(Exception exception) {
    switch (exception.runtimeType) {
      case ServerException:
        final serverException = exception as ServerException;
        return Failure.serverFailure(
          message: serverException.message,
          code: serverException.code,
        );
      case NetworkException:
        final networkException = exception as NetworkException;
        return Failure.networkFailure(message: networkException.message);
      case AuthException:
        final authException = exception as AuthException;
        return Failure.authFailure(
          message: authException.message,
          code: authException.code,
        );
      case FirestoreException:
        final firestoreException = exception as FirestoreException;
        return Failure.firestoreFailure(
          message: firestoreException.message,
          code: firestoreException.code,
        );
      case ValidationException:
        final validationException = exception as ValidationException;
        return Failure.validationFailure(
          message: validationException.message,
          fieldErrors: validationException.fieldErrors,
        );
      case CacheException:
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
