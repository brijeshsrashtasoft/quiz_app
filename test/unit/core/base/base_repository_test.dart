import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/base/base_repository.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

/// Test repository implementation for testing base repository functionality
class TestRepository extends BaseRepository {
  Future<Result<String>> testOperation() async {
    return handleRepositoryOperation(() async {
      return 'test_success';
    });
  }

  Future<Result<String>> testOperationWithException() async {
    return handleRepositoryOperation(() async {
      throw Exception('test_exception');
    });
  }

  Future<Result<String>> testOperationWithFailure() async {
    return handleRepositoryOperation(() async {
      throw const Failure.serverFailure(message: 'test_server_failure');
    });
  }
}

void main() {
  group('BaseRepository', () {
    late TestRepository repository;

    setUp(() {
      repository = TestRepository();
    });

    group('handleRepositoryOperation', () {
      testWidgets('should return success result when operation succeeds', 
          (tester) async {
        // Act
        final result = await repository.testOperation();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('test_success'));
      });

      testWidgets('should return failure result when operation throws exception', 
          (tester) async {
        // Act
        final result = await repository.testOperationWithException();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.userMessage, 
            contains('Unknown error: Exception: test_exception'));
      });

      testWidgets('should return failure result when operation throws failure', 
          (tester) async {
        // Act
        final result = await repository.testOperationWithFailure();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.userMessage, 
            contains('Server error: test_server_failure'));
      });
    });

    group('error mapping', () {
      testWidgets('should map exceptions to unknown failure by default', 
          (tester) async {
        // Act
        final result = await repository.testOperationWithException();

        // Assert
        expect(result.isFailure, isTrue);
        final failure = result.failureOrNull;
        expect(failure, isA<Failure>());
        failure?.when(
          serverFailure: (message, code) => fail('Should not be server failure'),
          networkFailure: (message) => fail('Should not be network failure'),
          authFailure: (message, code) => fail('Should not be auth failure'),
          firestoreFailure: (message, code) => fail('Should not be firestore failure'),
          validationFailure: (message, fieldErrors) => fail('Should not be validation failure'),
          cacheFailure: (message) => fail('Should not be cache failure'),
          unknownFailure: (message) => expect(message, contains('Exception: test_exception')),
        );
      });

      testWidgets('should preserve failure when operation throws failure', 
          (tester) async {
        // Act
        final result = await repository.testOperationWithFailure();

        // Assert
        expect(result.isFailure, isTrue);
        final failure = result.failureOrNull;
        expect(failure, isA<Failure>());
        failure?.when(
          serverFailure: (message, code) => expect(message, equals('test_server_failure')),
          networkFailure: (message) => fail('Should not be network failure'),
          authFailure: (message, code) => fail('Should not be auth failure'),
          firestoreFailure: (message, code) => fail('Should not be firestore failure'),
          validationFailure: (message, fieldErrors) => fail('Should not be validation failure'),
          cacheFailure: (message) => fail('Should not be cache failure'),
          unknownFailure: (message) => fail('Should not be unknown failure'),
        );
      });
    });
  });
}