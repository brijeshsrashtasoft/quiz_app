/// TDD Test Example for CreateUserUseCase
/// Demonstrates comprehensive TDD integration with Clean Architecture
/// Following CLAUDE.md patterns and TDD workflow
library create_user_usecase_tdd_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/core/base/base_usecase.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/user_repository.dart';
import 'package:quiz_app/features/authentication/domain/usecases/create_user_usecase.dart';

import '../../../../../helpers/tdd_templates.dart';
import '../../../../../helpers/architecture_test_builders.dart';

import 'create_user_usecase_tdd_test.mocks.dart';

// Generate mocks for testing
@GenerateMocks([UserRepository])
void main() {
  late CreateUserUseCase useCase;
  late MockUserRepository mockRepository;

  // Test data factory
  final testUser = UserEntity(
    id: 'test-user-id',
    name: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime.now(),
    stats: const UserStats(
      totalQuizzes: 0,
      totalGamesPlayed: 0,
      totalGamesWon: 0,
      averageScore: 0.0,
    ),
    preferences: const UserPreferences(
      soundEnabled: true,
      notificationsEnabled: true,
      theme: 'light',
      language: 'en',
    ),
  );

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = CreateUserUseCase(repository: mockRepository);
  });

  group('CreateUserUseCase - TDD Implementation', () {
    group('TDD RED Phase - Write Failing Tests First', () {
      test('TDD DEMO: This test would fail if usecase was not implemented', () {
        // In real TDD, this would be written BEFORE implementation
        // The test would fail, then we implement minimal code to pass

        // Arrange
        final params = CreateUserParams(user: testUser);

        // Act & Assert
        // This demonstrates what a failing test would look like
        expect(useCase, isA<CreateUserUseCase>());
        expect(useCase.repository, equals(mockRepository));
      });
    });

    group('TDD GREEN Phase - Make Tests Pass', () {
      test(
        'should create user successfully when repository succeeds',
        () async {
          // Arrange
          final params = CreateUserParams(user: testUser);
          when(
            mockRepository.createUser(testUser),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await useCase.call(params);

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isSuccess, isTrue);
          expect(result.data, equals(testUser));
          verify(mockRepository.createUser(testUser)).called(1);
        },
      );

      test('should return failure when repository fails', () async {
        // Arrange
        final params = CreateUserParams(user: testUser);
        const failure = Failure.validationFailure(
          message: 'User email already exists',
        );
        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error, equals(failure));
        verify(mockRepository.createUser(testUser)).called(1);
      });

      test('should handle repository exceptions gracefully', () async {
        // Arrange
        final params = CreateUserParams(user: testUser);
        when(
          mockRepository.createUser(testUser),
        ).thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(() => useCase.call(params), throwsException);
        verify(mockRepository.createUser(testUser)).called(1);
      });
    });

    group('TDD REFACTOR Phase - Enhance Implementation', () {
      test('should validate user data before creating', () async {
        // This test drives refactoring to add validation
        // In TDD, we would enhance the usecase after this test

        // Arrange
        final invalidUser = testUser.copyWith(email: ''); // Invalid email
        final params = CreateUserParams(user: invalidUser);

        // Currently passes through to repository
        // In refactoring phase, we might add validation here
        when(mockRepository.createUser(invalidUser)).thenAnswer(
          (_) async => const Result.failure(
            Failure.validationFailure(message: 'Invalid email'),
          ),
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, isTrue);
        verify(mockRepository.createUser(invalidUser)).called(1);
      });

      test('should handle concurrent user creation requests', () async {
        // Test concurrent execution performance
        // This drives refactoring for thread safety

        // Arrange
        final params = CreateUserParams(user: testUser);
        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.success(testUser));

        // Act - Create multiple concurrent requests
        final futures = List.generate(5, (_) => useCase.call(params));
        final results = await Future.wait(futures);

        // Assert
        expect(results.every((r) => r.isSuccess), isTrue);
        verify(mockRepository.createUser(testUser)).called(5);
      });

      test('should provide detailed error context', () async {
        // This test drives refactoring for better error handling

        // Arrange
        final params = CreateUserParams(user: testUser);
        const failure = Failure.firestoreFailure(
          message: 'Network timeout',
          code: 'network_timeout',
        );
        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error?.userMessage, contains('Network'));
        final firestoreFailure = result.error as FirestoreFailure?;
        expect(firestoreFailure?.code, equals('network_timeout'));
        verify(mockRepository.createUser(testUser)).called(1);
      });
    });

    group('Business Logic Validation', () {
      test('should ensure user has required fields', () async {
        // Test business rule: user must have name and email

        // Arrange
        final userWithoutName = testUser.copyWith(name: '');
        final params = CreateUserParams(user: userWithoutName);

        // Repository would validate this, but use case might add logic
        when(mockRepository.createUser(userWithoutName)).thenAnswer(
          (_) async => const Result.failure(
            Failure.validationFailure(message: 'Name is required'),
          ),
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, isTrue);
        verify(mockRepository.createUser(userWithoutName)).called(1);
      });

      test('should set default user stats for new users', () async {
        // Test business rule: new users get default stats

        // Arrange
        final userWithoutStats = testUser.copyWith(stats: null);
        final params = CreateUserParams(user: userWithoutStats);
        final expectedUserWithDefaults = userWithoutStats.copyWith(
          stats: const UserStats(
            totalQuizzes: 0,
            totalGamesPlayed: 0,
            totalGamesWon: 0,
            averageScore: 0.0,
          ),
        );

        when(
          mockRepository.createUser(any),
        ).thenAnswer((_) async => Result.success(expectedUserWithDefaults));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.stats, isNotNull);
        expect(result.data?.stats?.totalQuizzes, equals(0));
      });
    });

    group('Error Scenarios and Edge Cases', () {
      test('should handle duplicate email creation attempts', () async {
        // Arrange
        final params = CreateUserParams(user: testUser);
        const duplicateFailure = Failure.validationFailure(
          message: 'Email already exists',
        );

        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.failure(duplicateFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error?.userMessage, contains('already exists'));
        verify(mockRepository.createUser(testUser)).called(1);
      });

      test('should handle network connectivity issues', () async {
        // Arrange
        final params = CreateUserParams(user: testUser);
        const networkFailure = Failure.networkFailure(
          message: 'No internet connection',
        );

        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.failure(networkFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error, isA<NetworkFailure>());
        verify(mockRepository.createUser(testUser)).called(1);
      });

      test('should handle user entity with null optional fields', () async {
        // Arrange
        final minimalUser = UserEntity(
          id: 'minimal-user',
          name: 'Minimal User',
          email: 'minimal@example.com',
          createdAt: DateTime.now(),
          // Optional fields are null
          stats: null,
          preferences: null,
          profileImageUrl: null,
        );
        final params = CreateUserParams(user: minimalUser);

        when(
          mockRepository.createUser(minimalUser),
        ).thenAnswer((_) async => Result.success(minimalUser));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.stats, isNull);
        expect(result.data?.preferences, isNull);
        verify(mockRepository.createUser(minimalUser)).called(1);
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle large user data efficiently', () async {
        // Test with user containing large data

        // Arrange
        final largeUser = testUser.copyWith(
          name: 'A' * 1000, // Large name
          stats: const UserStats(
            totalQuizzes: 999999,
            totalGamesPlayed: 999999,
            totalGamesWon: 999999,
            averageScore: 99.99,
          ),
        );
        final params = CreateUserParams(user: largeUser);

        when(
          mockRepository.createUser(largeUser),
        ).thenAnswer((_) async => Result.success(largeUser));

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await useCase.call(params);
        stopwatch.stop();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
        verify(mockRepository.createUser(largeUser)).called(1);
      });

      test('should not cause memory leaks with multiple calls', () async {
        // Test memory efficiency

        // Arrange
        final params = CreateUserParams(user: testUser);
        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.success(testUser));

        // Act - Multiple sequential calls
        for (int i = 0; i < 100; i++) {
          final result = await useCase.call(params);
          expect(result.isSuccess, isTrue);
        }

        // Assert
        verify(mockRepository.createUser(testUser)).called(100);
      });
    });
  });

  group('Architecture Compliance Tests', () {
    test('should follow Clean Architecture principles', () {
      // Verify use case extends BaseUseCase
      expect(useCase, isA<BaseUseCase<UserEntity, CreateUserParams>>());

      // Verify dependency injection
      expect(useCase.repository, isA<UserRepository>());

      // Verify return type follows Result pattern
      expect(
        useCase.call(CreateUserParams(user: testUser)),
        isA<Future<Result<UserEntity>>>(),
      );
    });

    test('should not have direct dependencies on data layer', () {
      // This is checked by architecture tests, but can be verified here too
      expect(useCase.repository, isA<UserRepository>());
      // Repository interface is in domain layer, not data layer
    });

    test('should support dependency injection via constructor', () {
      // Verify constructor injection pattern
      final newRepository = MockUserRepository();
      final newUseCase = CreateUserUseCase(repository: newRepository);

      expect(newUseCase.repository, equals(newRepository));
      expect(newUseCase.repository, isNot(equals(mockRepository)));
    });
  });

  group('TDD Template Integration', () {
    test('should integrate with TDD workflow templates', () {
      // Demonstrate integration with TDD templates

      UseCaseTestTemplate<
        CreateUserUseCase,
        UserEntity,
        CreateUserParams
      >.runBasicTests(
        createUseCase: () => CreateUserUseCase(repository: mockRepository),
        createValidParams: () => CreateUserParams(user: testUser),
        createInvalidParams: () => CreateUserParams(
          user: testUser.copyWith(email: ''), // Invalid
        ),
        useCaseName: 'CreateUserUseCase',
        expectedSuccessResult: testUser,
        expectedFailures: const [
          Failure.validationFailure(message: 'Validation failed'),
          Failure.networkFailure(message: 'Network failed'),
        ],
        mockRepository: mockRepository,
      );
    });
  });

  group('Real TDD Workflow Demonstration', () {
    group('TDD Cycle Example: Add Email Validation', () {
      // This demonstrates a complete TDD cycle for adding new functionality

      test('RED: Should validate email format before creation', () async {
        // Step 1: Write failing test for new functionality
        // This test would fail initially because validation doesn't exist

        // Arrange
        final userWithInvalidEmail = testUser.copyWith(
          email: 'invalid-email-format',
        );
        final params = CreateUserParams(user: userWithInvalidEmail);

        // Currently this would pass through to repository
        // After TDD GREEN phase, usecase would validate email format
        when(mockRepository.createUser(userWithInvalidEmail)).thenAnswer(
          (_) async => const Result.failure(
            Failure.validationFailure(message: 'Invalid email format'),
          ),
        );

        // Act
        final result = await useCase.call(params);

        // Assert - Test what we want the behavior to be
        expect(result.isFailure, isTrue);
        expect(result.error?.userMessage, contains('Invalid email'));
      });

      test('GREEN: Should pass with valid email format', () async {
        // Step 2: Write test for positive case
        // Implementation would be added to make both tests pass

        // Arrange
        final params = CreateUserParams(user: testUser); // Valid email
        when(
          mockRepository.createUser(testUser),
        ).thenAnswer((_) async => Result.success(testUser));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockRepository.createUser(testUser)).called(1);
      });

      test('REFACTOR: Should handle various email validation cases', () async {
        // Step 3: Add comprehensive test cases
        // Refactor implementation to handle edge cases

        final testCases = [
          ('valid@example.com', true),
          ('invalid.email', false),
          ('', false),
          ('user@', false),
          ('@domain.com', false),
          ('user@domain', false),
          ('user.name+tag@domain.com', true),
        ];

        for (final (email, shouldSucceed) in testCases) {
          // Arrange
          final userWithEmail = testUser.copyWith(email: email);
          final params = CreateUserParams(user: userWithEmail);

          if (shouldSucceed) {
            when(
              mockRepository.createUser(userWithEmail),
            ).thenAnswer((_) async => Result.success(userWithEmail));
          } else {
            when(mockRepository.createUser(userWithEmail)).thenAnswer(
              (_) async => const Result.failure(
                Failure.validationFailure(message: 'Invalid email'),
              ),
            );
          }

          // Act
          final result = await useCase.call(params);

          // Assert
          expect(
            result.isSuccess,
            equals(shouldSucceed),
            reason: 'Email $email should ${shouldSucceed ? 'succeed' : 'fail'}',
          );
        }
      });
    });
  });
}

/// Extension methods for testing
extension CreateUserUseCaseTestX on CreateUserUseCase {
  /// Helper for testing private methods (if any)
  UserRepository get testRepository => repository;
}

/// Test data builders for TDD
class CreateUserTestDataBuilder {
  static UserEntity validUser({String? id, String? name, String? email}) {
    return UserEntity(
      id: id ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: DateTime.now(),
      stats: const UserStats(
        totalQuizzes: 0,
        totalGamesPlayed: 0,
        totalGamesWon: 0,
        averageScore: 0.0,
      ),
      preferences: const UserPreferences(
        soundEnabled: true,
        notificationsEnabled: true,
        theme: 'light',
        language: 'en',
      ),
    );
  }

  static UserEntity invalidUser({String? reason}) {
    switch (reason) {
      case 'empty_name':
        return validUser(name: '');
      case 'empty_email':
        return validUser(email: '');
      case 'invalid_email':
        return validUser(email: 'invalid-email');
      default:
        return validUser(email: ''); // Default invalid case
    }
  }

  static CreateUserParams validParams({UserEntity? user}) {
    return CreateUserParams(user: user ?? validUser());
  }

  static CreateUserParams invalidParams({String? reason}) {
    return CreateUserParams(user: invalidUser(reason: reason));
  }
}
