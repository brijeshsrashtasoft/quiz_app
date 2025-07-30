import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/base/base_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

/// Test use case implementations for testing base use case functionality
class TestParams {
  final String value;
  const TestParams(this.value);
}

class TestUseCase extends BaseUseCase<String, TestParams> {
  @override
  Future<Result<String>> call(TestParams params) async {
    if (params.value == 'success') {
      return Result.success('test_success');
    } else if (params.value == 'failure') {
      return Result.failure(
        const Failure.serverFailure(message: 'test_failure'),
      );
    } else {
      throw Exception('unexpected_value');
    }
  }
}

class TestUseCaseNoParams extends BaseUseCaseNoParams<String> {
  @override
  Future<Result<String>> call() async {
    return Result.success('no_params_success');
  }
}

class TestSyncUseCase extends BaseSyncUseCase<String, TestParams> {
  @override
  Result<String> call(TestParams params) {
    if (params.value == 'sync_success') {
      return Result.success('sync_test_success');
    } else {
      return Result.failure(
        const Failure.validationFailure(message: 'sync_test_failure'),
      );
    }
  }
}

class TestStreamUseCase extends BaseStreamUseCase<String, TestParams> {
  @override
  Stream<Result<String>> call(TestParams params) {
    if (params.value == 'stream_success') {
      return Stream.value(Result.success('stream_test_success'));
    } else {
      return Stream.value(
        Result.failure(
          const Failure.networkFailure(message: 'stream_test_failure'),
        ),
      );
    }
  }
}

void main() {
  group('BaseUseCase', () {
    late TestUseCase useCase;

    setUp(() {
      useCase = TestUseCase();
    });

    testWidgets('should return success result when operation succeeds', 
        (tester) async {
      // Arrange
      const params = TestParams('success');

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('test_success'));
    });

    testWidgets('should return failure result when operation fails', 
        (tester) async {
      // Arrange
      const params = TestParams('failure');

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.userMessage, 
          contains('Server error: test_failure'));
    });

    testWidgets('should handle exceptions thrown by use case', 
        (tester) async {
      // Arrange
      const params = TestParams('exception');

      // Act & Assert
      expect(() => useCase.call(params), throwsException);
    });
  });

  group('BaseUseCaseNoParams', () {
    late TestUseCaseNoParams useCase;

    setUp(() {
      useCase = TestUseCaseNoParams();
    });

    testWidgets('should execute without parameters', (tester) async {
      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('no_params_success'));
    });
  });

  group('BaseSyncUseCase', () {
    late TestSyncUseCase useCase;

    setUp(() {
      useCase = TestSyncUseCase();
    });

    testWidgets('should execute synchronously and return success', 
        (tester) async {
      // Arrange
      const params = TestParams('sync_success');

      // Act
      final result = useCase.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('sync_test_success'));
    });

    testWidgets('should execute synchronously and return failure', 
        (tester) async {
      // Arrange
      const params = TestParams('sync_failure');

      // Act
      final result = useCase.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.userMessage, 
          contains('Validation error: sync_test_failure'));
    });
  });

  group('BaseStreamUseCase', () {
    late TestStreamUseCase useCase;

    setUp(() {
      useCase = TestStreamUseCase();
    });

    testWidgets('should return stream with success result', (tester) async {
      // Arrange
      const params = TestParams('stream_success');

      // Act
      final stream = useCase.call(params);
      final result = await stream.first;

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('stream_test_success'));
    });

    testWidgets('should return stream with failure result', (tester) async {
      // Arrange
      const params = TestParams('stream_failure');

      // Act
      final stream = useCase.call(params);
      final result = await stream.first;

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.userMessage, 
          contains('Network error: stream_test_failure'));
    });
  });

  group('NoParams', () {
    testWidgets('should create NoParams instance', (tester) async {
      // Act
      const noParams = NoParams();

      // Assert
      expect(noParams, isA<NoParams>());
    });
  });
}