import '../utils/result.dart';
import '../errors/failures.dart';

/// Base repository interface following Clean Architecture patterns
/// Referenced from CLAUDE.md architecture principles
abstract class BaseRepository {
  /// Handle repository operations with proper error handling
  Future<Result<T>> handleRepositoryOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Map exceptions to appropriate failures
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }

    // Add more specific mappings as needed
    return Failure.unknownFailure(message: exception.toString());
  }
}
