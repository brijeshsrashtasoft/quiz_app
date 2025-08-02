import 'dart:async';
import '../utils/result.dart';

abstract class StreamUseCase<Type, Params> {
  Stream<Result<Type>> call(Params params);
}
