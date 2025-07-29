import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create success result with data', () {
        // Arrange
        const data = 'test data';

        // Act
        const result = Result.success(data);

        // Assert
        expect(result, isA<Success<String>>());
        result.when(
          success: (d) => expect(d, equals(data)),
          failure: (_) => fail('Should be Success'),
        );
      });
    });

    group('Failure', () {
      test('should create failure result with failure', () {
        // Arrange
        const failure = Failure.networkFailure(message: 'Network error');

        // Act
        const result = Result<String>.failure(failure);

        // Assert
        expect(result, isA<Error<String>>());
        result.when(
          success: (_) => fail('Should be Failure'),
          failure: (f) => expect(f, equals(failure)),
        );
      });
    });
  });

  group('ResultX extension', () {
    const successData = 'test data';
    const failure = Failure.networkFailure(message: 'Network error');
    const successResult = Result.success(successData);
    const failureResult = Result<String>.failure(failure);

    group('isSuccess', () {
      test('should return true for success result', () {
        expect(successResult.isSuccess, isTrue);
      });

      test('should return false for failure result', () {
        expect(failureResult.isSuccess, isFalse);
      });
    });

    group('isFailure', () {
      test('should return false for success result', () {
        expect(successResult.isFailure, isFalse);
      });

      test('should return true for failure result', () {
        expect(failureResult.isFailure, isTrue);
      });
    });

    group('dataOrNull', () {
      test('should return data for success result', () {
        expect(successResult.dataOrNull, equals(successData));
      });

      test('should return null for failure result', () {
        expect(failureResult.dataOrNull, isNull);
      });
    });

    group('failureOrNull', () {
      test('should return null for success result', () {
        expect(successResult.failureOrNull, isNull);
      });

      test('should return failure for failure result', () {
        expect(failureResult.failureOrNull, equals(failure));
      });
    });

    group('transform', () {
      test('should transform success data', () {
        // Arrange
        const result = Result.success(10);

        // Act
        final mapped = result.transform((data) => data * 2);

        // Assert
        expect(mapped.dataOrNull, equals(20));
      });

      test('should preserve failure', () {
        // Arrange
        const result = Result<int>.failure(failure);

        // Act
        final mapped = result.transform((data) => data * 2);

        // Assert
        expect(mapped.failureOrNull, equals(failure));
      });
    });

    group('flatMap', () {
      test('should chain successful operations', () {
        // Arrange
        const result = Result.success(10);

        // Act
        final flatMapped = result.flatMap((data) => Result.success(data * 2));

        // Assert
        expect(flatMapped.dataOrNull, equals(20));
      });

      test('should stop at first failure', () {
        // Arrange
        const result = Result<int>.failure(failure);

        // Act
        final flatMapped = result.flatMap((data) => Result.success(data * 2));

        // Assert
        expect(flatMapped.failureOrNull, equals(failure));
      });

      test('should propagate chained failure', () {
        // Arrange
        const result = Result.success(10);
        const chainedFailure = Failure.validationFailure(
          message: 'Invalid data',
        );

        // Act
        final flatMapped = result.flatMap(
          (_) => Result<int>.failure(chainedFailure),
        );

        // Assert
        expect(flatMapped.failureOrNull, equals(chainedFailure));
      });
    });

    group('dataOrThrow', () {
      test('should return data for success result', () {
        expect(successResult.dataOrThrow, equals(successData));
      });

      test('should throw exception for failure result', () {
        expect(
          () => failureResult.dataOrThrow,
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Network error'),
            ),
          ),
        );
      });
    });
  });

  group('Result chaining examples', () {
    test('should chain multiple operations successfully', () {
      // Arrange
      const initialResult = Result.success('hello');

      // Act
      final result = initialResult
          .transform((data) => data.toUpperCase())
          .flatMap((data) => Result.success('$data WORLD'))
          .transform((data) => data.length);

      // Assert
      expect(result.dataOrNull, equals(11)); // "HELLO WORLD".length
    });

    test('should stop at first failure in chain', () {
      // Arrange
      const initialResult = Result.success('hello');
      const validationFailure = Failure.validationFailure(message: 'Invalid');

      // Act
      final result = initialResult
          .transform((data) => data.toUpperCase())
          .flatMap((_) => Result<String>.failure(validationFailure))
          .transform((data) => data.length);

      // Assert
      expect(result.failureOrNull, equals(validationFailure));
    });
  });

  group('Type safety', () {
    test('should maintain type safety through transformations', () {
      // Arrange
      const stringResult = Result.success('test');

      // Act
      final intResult = stringResult.transform((s) => s.length);
      final boolResult = intResult.transform((i) => i > 3);

      // Assert
      expect(stringResult, isA<Result<String>>());
      expect(intResult, isA<Result<int>>());
      expect(boolResult, isA<Result<bool>>());
      expect(boolResult.dataOrNull, isTrue);
    });

    test('should handle different failure types', () {
      // Test different failure types can be used with Result
      const serverFailure = Failure.serverFailure(message: 'Server error');
      const authFailure = Failure.authFailure(message: 'Auth error');
      const networkFailure = Failure.networkFailure(message: 'Network error');

      const serverResult = Result<String>.failure(serverFailure);
      const authResult = Result<int>.failure(authFailure);
      const networkResult = Result<bool>.failure(networkFailure);

      expect(serverResult.failureOrNull, equals(serverFailure));
      expect(authResult.failureOrNull, equals(authFailure));
      expect(networkResult.failureOrNull, equals(networkFailure));
    });
  });
}
