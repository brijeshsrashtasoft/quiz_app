import '../utils/result.dart';

/// Base use case abstract class
abstract class BaseUseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// UseCase alias for BaseUseCase (for backward compatibility)
typedef UseCase<Type, Params> = BaseUseCase<Type, Params>;

/// Base use case for no parameters
abstract class BaseUseCaseNoParams<Type> {
  Future<Result<Type>> call();
}

/// Base stream use case abstract class
abstract class BaseStreamUseCase<Type, Params> {
  Stream<Result<Type>> call(Params params);
}

/// Base class for all use case parameters
abstract class BaseUseCaseParams {
  const BaseUseCaseParams();
}

/// No parameters use case
class NoParams extends BaseUseCaseParams {
  const NoParams();
}
