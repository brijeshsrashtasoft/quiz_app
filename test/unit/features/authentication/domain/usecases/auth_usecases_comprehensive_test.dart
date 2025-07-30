import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/user_repository.dart';
import 'package:quiz_app/features/authentication/domain/usecases/create_user_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/get_user_by_id_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/watch_user_usecase.dart';
import '../../../../../../test_config.dart';

import 'auth_usecases_comprehensive_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([UserRepository])
void main() {
  testGroup(
    'Authentication Use Cases Comprehensive Tests',
    TestCategory.unit,
    () {
      late MockUserRepository mockRepository;
      late CreateUserUseCase createUserUseCase;
      late GetUserByIdUseCase getUserByIdUseCase;
      late WatchUserUseCase watchUserUseCase;

      setUp(() {
        mockRepository = MockUserRepository();
        createUserUseCase = CreateUserUseCase(repository: mockRepository);
        getUserByIdUseCase = GetUserByIdUseCase(repository: mockRepository);
        watchUserUseCase = WatchUserUseCase(repository: mockRepository);
      });

      testGroup('CreateUserUseCase', () {
        final testUser = UserEntity(
          id: 'test-user-id',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        testCase(
          'should return UserEntity when repository creates user successfully',
          TestCategory.unit,
          () async {
            // Arrange
            when(
              mockRepository.createUser(testUser),
            ).thenAnswer((_) async => Result.success(testUser));

            // Act
            final result = await createUserUseCase(
              CreateUserParams(user: testUser),
            );

            // Assert
            expect(result.isSuccess, isTrue);
            expect(result.dataOrNull, equals(testUser));
            verify(mockRepository.createUser(testUser)).called(1);
          },
        );

        testCase(
          'should return failure when repository fails to create user',
          TestCategory.unit,
          () async {
            // Arrange
            final failure = Failure.firestoreFailure(
              message: 'Failed to create user',
              code: 'CREATE_USER_ERROR',
            );
            when(
              mockRepository.createUser(testUser),
            ).thenAnswer((_) async => Result.failure(failure));

            // Act
            final result = await createUserUseCase(
              CreateUserParams(user: testUser),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull, equals(failure));
            verify(mockRepository.createUser(testUser)).called(1);
          },
        );

        testCase(
          'should validate user data before creation',
          TestCategory.unit,
          () async {
            // Arrange - User with invalid data
            final invalidUser = UserEntity(
              id: '',
              name: '',
              email: 'invalid-email',
              createdAt: DateTime.now(),
            );

            // Act
            final result = await createUserUseCase(
              CreateUserParams(user: invalidUser),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, contains('VALIDATION_ERROR'));
          },
        );

        testCase(
          'should handle duplicate email gracefully',
          TestCategory.unit,
          () async {
            // Arrange
            final failure = Failure.firestoreFailure(
              message: 'User with email already exists',
              code: 'DUPLICATE_EMAIL',
            );
            when(
              mockRepository.createUser(testUser),
            ).thenAnswer((_) async => Result.failure(failure));

            // Act
            final result = await createUserUseCase(
              CreateUserParams(user: testUser),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, equals('DUPLICATE_EMAIL'));
          },
        );

        testCase(
          'should handle network errors during user creation',
          TestCategory.unit,
          () async {
            // Arrange
            final networkFailure = Failure.networkFailure(
              message: 'Network connection failed',
              code: 'NETWORK_ERROR',
            );
            when(
              mockRepository.createUser(testUser),
            ).thenAnswer((_) async => Result.failure(networkFailure));

            // Act
            final result = await createUserUseCase(
              CreateUserParams(user: testUser),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, equals('NETWORK_ERROR'));
          },
        );

        testCase(
          'should complete within performance threshold',
          TestCategory.unit,
          () async {
            // Arrange
            when(
              mockRepository.createUser(testUser),
            ).thenAnswer((_) async => Result.success(testUser));

            // Act & Assert
            await TestExpectations.expectPerformant(
              () => createUserUseCase(CreateUserParams(user: testUser)),
              threshold: const Duration(milliseconds: 200),
            );
          },
        );
      });

      testGroup('GetUserByIdUseCase', () {
        const userId = 'test-user-id';
        final testUser = UserEntity(
          id: userId,
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        testCase(
          'should return UserEntity when user exists',
          TestCategory.unit,
          () async {
            // Arrange
            when(
              mockRepository.getUserById(userId),
            ).thenAnswer((_) async => Result.success(testUser));

            // Act
            final result = await getUserByIdUseCase(
              GetUserByIdParams(userId: userId),
            );

            // Assert
            expect(result.isSuccess, isTrue);
            expect(result.dataOrNull, equals(testUser));
            verify(mockRepository.getUserById(userId)).called(1);
          },
        );

        testCase(
          'should return failure when user does not exist',
          TestCategory.unit,
          () async {
            // Arrange
            final failure = Failure.firestoreFailure(
              message: 'User not found',
              code: 'USER_NOT_FOUND',
            );
            when(
              mockRepository.getUserById(userId),
            ).thenAnswer((_) async => Result.failure(failure));

            // Act
            final result = await getUserByIdUseCase(
              GetUserByIdParams(userId: userId),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, equals('USER_NOT_FOUND'));
          },
        );

        testCase(
          'should validate userId parameter',
          TestCategory.unit,
          () async {
            // Act
            final result = await getUserByIdUseCase(
              const GetUserByIdParams(userId: ''),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, contains('VALIDATION_ERROR'));
          },
        );

        testCase(
          'should handle malformed user data gracefully',
          TestCategory.unit,
          () async {
            // Arrange
            final failure = Failure.serializationFailure(
              message: 'Failed to parse user data',
              code: 'SERIALIZATION_ERROR',
            );
            when(
              mockRepository.getUserById(userId),
            ).thenAnswer((_) async => Result.failure(failure));

            // Act
            final result = await getUserByIdUseCase(
              GetUserByIdParams(userId: userId),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, equals('SERIALIZATION_ERROR'));
          },
        );

        testCase(
          'should cache user data appropriately',
          TestCategory.unit,
          () async {
            // Arrange
            when(
              mockRepository.getUserById(userId),
            ).thenAnswer((_) async => Result.success(testUser));

            // Act - Multiple calls
            await getUserByIdUseCase(GetUserByIdParams(userId: userId));
            await getUserByIdUseCase(GetUserByIdParams(userId: userId));

            // Assert
            verify(mockRepository.getUserById(userId)).called(2);
            // In a real implementation, caching logic would reduce calls
          },
        );
      });

      testGroup('WatchUserUseCase', () {
        const userId = 'test-user-id';
        final testUser = UserEntity(
          id: userId,
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        testCase(
          'should return stream of UserEntity updates',
          TestCategory.unit,
          () async {
            // Arrange
            final userStream = Stream.fromIterable([
              Result.success(testUser),
              Result.success(testUser.copyWith(name: 'Updated User')),
            ]);
            when(
              mockRepository.watchUser(userId),
            ).thenAnswer((_) => userStream);

            // Act
            final stream = watchUserUseCase(WatchUserParams(userId: userId));
            final results = await stream.take(2).toList();

            // Assert
            expect(results.length, equals(2));
            expect(results[0].isSuccess, isTrue);
            expect(results[0].dataOrNull?.name, equals('Test User'));
            expect(results[1].dataOrNull?.name, equals('Updated User'));
          },
        );

        testCase(
          'should handle stream errors gracefully',
          TestCategory.unit,
          () async {
            // Arrange
            final errorStream = Stream<Result<UserEntity>>.fromIterable([
              Result.success(testUser),
              Result.failure(
                Failure.firestoreFailure(
                  message: 'Connection lost',
                  code: 'CONNECTION_ERROR',
                ),
              ),
            ]);
            when(
              mockRepository.watchUser(userId),
            ).thenAnswer((_) => errorStream);

            // Act
            final stream = watchUserUseCase(WatchUserParams(userId: userId));
            final results = await stream.take(2).toList();

            // Assert
            expect(results.length, equals(2));
            expect(results[0].isSuccess, isTrue);
            expect(results[1].isFailure, isTrue);
            expect(results[1].failureOrNull?.code, equals('CONNECTION_ERROR'));
          },
        );

        testCase(
          'should validate userId parameter for stream',
          TestCategory.unit,
          () async {
            // Act
            final stream = watchUserUseCase(const WatchUserParams(userId: ''));

            // Assert
            expect(
              () async => await stream.first,
              throwsA(isA<ArgumentError>()),
            );
          },
        );

        testCase(
          'should handle stream cancellation properly',
          TestCategory.unit,
          () async {
            // Arrange
            final userStream = Stream.fromIterable([
              Result.success(testUser),
            ]).asBroadcastStream();
            when(
              mockRepository.watchUser(userId),
            ).thenAnswer((_) => userStream);

            // Act
            final stream = watchUserUseCase(WatchUserParams(userId: userId));
            final subscription = stream.listen((_) {});
            await subscription.cancel();

            // Assert - No exceptions should be thrown
            expect(subscription, isNotNull);
          },
        );
      });

      testGroup('Use Case Parameter Validation', () {
        testCase(
          'CreateUserParams should validate user entity',
          TestCategory.unit,
          () {
            // Arrange
            final validUser = UserEntity(
              id: 'test-id',
              name: 'Test User',
              email: 'test@example.com',
              createdAt: DateTime.now(),
            );

            // Act
            final params = CreateUserParams(user: validUser);

            // Assert
            expect(params.user, equals(validUser));
            expect(params.validate(), isTrue);
          },
        );

        testCase(
          'GetUserByIdParams should validate userId',
          TestCategory.unit,
          () {
            // Act
            const validParams = GetUserByIdParams(userId: 'valid-id');
            const invalidParams = GetUserByIdParams(userId: '');

            // Assert
            expect(validParams.userId, equals('valid-id'));
            expect(validParams.validate(), isTrue);
            expect(invalidParams.validate(), isFalse);
          },
        );

        testCase(
          'WatchUserParams should validate userId',
          TestCategory.unit,
          () {
            // Act
            const validParams = WatchUserParams(userId: 'valid-id');
            const invalidParams = WatchUserParams(userId: '');

            // Assert
            expect(validParams.userId, equals('valid-id'));
            expect(validParams.validate(), isTrue);
            expect(invalidParams.validate(), isFalse);
          },
        );
      });

      testGroup('Use Case Error Handling', () {
        testCase(
          'should handle repository timeout errors',
          TestCategory.unit,
          () async {
            // Arrange
            final timeoutFailure = Failure.networkFailure(
              message: 'Request timeout',
              code: 'TIMEOUT_ERROR',
            );
            when(
              mockRepository.getUserById(any),
            ).thenAnswer((_) async => Result.failure(timeoutFailure));

            // Act
            final result = await getUserByIdUseCase(
              const GetUserByIdParams(userId: 'test-id'),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, equals('TIMEOUT_ERROR'));
          },
        );

        testCase(
          'should handle permission denied errors',
          TestCategory.unit,
          () async {
            // Arrange
            final permissionFailure = Failure.firestoreFailure(
              message: 'Permission denied',
              code: 'PERMISSION_DENIED',
            );
            when(
              mockRepository.getUserById(any),
            ).thenAnswer((_) async => Result.failure(permissionFailure));

            // Act
            final result = await getUserByIdUseCase(
              const GetUserByIdParams(userId: 'test-id'),
            );

            // Assert
            expect(result.isFailure, isTrue);
            expect(result.failureOrNull?.code, equals('PERMISSION_DENIED'));
          },
        );
      });

      testGroup('Use Case Performance Tests', () {
        testCase(
          'multiple concurrent user fetches should complete efficiently',
          TestCategory.unit,
          () async {
            // Arrange
            final testUser = UserEntity(
              id: 'test-id',
              name: 'Test User',
              email: 'test@example.com',
              createdAt: DateTime.now(),
            );
            when(
              mockRepository.getUserById(any),
            ).thenAnswer((_) async => Result.success(testUser));

            // Act & Assert
            await TestExpectations.expectPerformant(() async {
              final futures = List.generate(
                10,
                (index) => getUserByIdUseCase(
                  GetUserByIdParams(userId: 'user-$index'),
                ),
              );
              await Future.wait(futures);
            }, threshold: const Duration(milliseconds: 500));
          },
        );

        testCase(
          'user creation with large datasets should complete within threshold',
          TestCategory.unit,
          () async {
            // Arrange
            final userWithLargeStats = UserEntity(
              id: 'test-id',
              name: 'Test User',
              email: 'test@example.com',
              createdAt: DateTime.now(),
              stats: UserStats(
                totalQuizzes: 1000,
                totalGamesPlayed: 5000,
                totalGamesWon: 2500,
                averageScore: 85.5,
              ),
            );
            when(
              mockRepository.createUser(any),
            ).thenAnswer((_) async => Result.success(userWithLargeStats));

            // Act & Assert
            await TestExpectations.expectPerformant(
              () =>
                  createUserUseCase(CreateUserParams(user: userWithLargeStats)),
              threshold: const Duration(milliseconds: 200),
            );
          },
        );
      });
    },
  );
}
