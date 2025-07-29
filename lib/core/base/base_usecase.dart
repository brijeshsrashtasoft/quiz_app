import '../utils/result.dart';

/// Base use case interface following Clean Architecture patterns
/// Referenced from CLAUDE.md business logic implementation
abstract class BaseUseCase<Type, Params> {
  /// Execute the use case with parameters
  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
abstract class BaseUseCaseNoParams<Type> {
  /// Execute the use case without parameters
  Future<Result<Type>> call();
}

/// Synchronous use case
abstract class BaseSyncUseCase<Type, Params> {
  /// Execute the use case synchronously
  Result<Type> call(Params params);
}

/// Stream-based use case for real-time features
/// Following CLAUDE.md real-time requirements
abstract class BaseStreamUseCase<Type, Params> {
  /// Execute the use case and return a stream
  Stream<Result<Type>> call(Params params);
}

/// No parameters class for use cases
class NoParams {
  const NoParams();
}
