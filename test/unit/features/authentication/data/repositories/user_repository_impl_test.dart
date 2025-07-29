import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/core/errors/exceptions.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/features/authentication/data/datasources/user_firestore_datasource.dart';
import 'package:quiz_app/features/authentication/data/models/user_model.dart';
import 'package:quiz_app/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';

import 'user_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([UserFirestoreDataSource])
void main() {
  late UserRepositoryImpl repository;
  late MockUserFirestoreDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockUserFirestoreDataSource();
    repository = UserRepositoryImpl(dataSource: mockDataSource);
  });

  group('UserRepositoryImpl', () {
    const testUserId = 'test-user-id';
    const testEmail = 'test@example.com';

    final testUserModel = UserModel(
      id: testUserId,
      name: 'Test User',
      email: testEmail,
      createdAt: DateTime.now(),
      stats: const UserStatsModel(
        totalQuizzes: 5,
        totalGamesPlayed: 10,
        totalGamesWon: 3,
        averageScore: 85.5,
      ),
    );

    final testUserEntity = testUserModel.toEntity();

    group('getUserById', () {
      test(
        'should return UserEntity when data source returns UserModel',
        () async {
          // Arrange
          when(
            mockDataSource.getUserById(testUserId),
          ).thenAnswer((_) async => Result.success(testUserModel));

          // Act
          final result = await repository.getUserById(testUserId);

          // Assert
          expect(result.isSuccess, true);
          expect(result.data, isA<UserEntity>());
          expect(result.data?.id, testUserId);
          expect(result.data?.name, 'Test User');
          expect(result.data?.email, testEmail);
          verify(mockDataSource.getUserById(testUserId)).called(1);
        },
      );

      test('should return failure when data source returns error', () async {
        // Arrange
        final error = Failure.firestoreFailure(
          message: 'User not found',
          code: 'user_not_found',
        );
        when(
          mockDataSource.getUserById(testUserId),
        ).thenAnswer((_) async => Result.failure(error));

        // Act
        final result = await repository.getUserById(testUserId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, equals(error));
        verify(mockDataSource.getUserById(testUserId)).called(1);
      });
    });

    group('getUserByEmail', () {
      test(
        'should return UserEntity when data source finds user by email',
        () async {
          // Arrange
          when(
            mockDataSource.getUserByEmail(testEmail),
          ).thenAnswer((_) async => Result.success(testUserModel));

          // Act
          final result = await repository.getUserByEmail(testEmail);

          // Assert
          expect(result.isSuccess, true);
          expect(result.data?.email, testEmail);
          verify(mockDataSource.getUserByEmail(testEmail)).called(1);
        },
      );

      test('should return failure when email is invalid format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';

        // Act
        final result = await repository.getUserByEmail(invalidEmail);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.getUserByEmail(any));
      });
    });

    group('createUser', () {
      test(
        'should return UserEntity when user is created successfully',
        () async {
          // Arrange
          final newUserModel = testUserModel.copyWith(id: 'new-user-id');
          when(
            mockDataSource.createUser(any),
          ).thenAnswer((_) async => Result.success(newUserModel));

          // Act
          final result = await repository.createUser(testUserEntity);

          // Assert
          expect(result.isSuccess, true);
          expect(result.data?.id, 'new-user-id');
          verify(mockDataSource.createUser(any)).called(1);
        },
      );

      test('should return failure when user data is invalid', () async {
        // Arrange
        final invalidUser = testUserEntity.copyWith(email: ''); // Invalid email

        // Act
        final result = await repository.createUser(invalidUser);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.createUser(any));
      });

      test('should return failure when data source returns error', () async {
        // Arrange
        final error = Failure.firestoreFailure(
          message: 'Failed to create user',
          code: 'create_user_error',
        );
        when(
          mockDataSource.createUser(any),
        ).thenAnswer((_) async => Result.failure(error));

        // Act
        final result = await repository.createUser(testUserEntity);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, equals(error));
        verify(mockDataSource.createUser(any)).called(1);
      });
    });

    group('updateUser', () {
      test('should return updated UserEntity when update succeeds', () async {
        // Arrange
        final updatedModel = testUserModel.copyWith(name: 'Updated Name');
        when(
          mockDataSource.updateUser(any),
        ).thenAnswer((_) async => Result.success(updatedModel));

        final updatedEntity = testUserEntity.copyWith(name: 'Updated Name');

        // Act
        final result = await repository.updateUser(updatedEntity);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.name, 'Updated Name');
        verify(mockDataSource.updateUser(any)).called(1);
      });

      test('should validate user data before updating', () async {
        // Arrange
        final invalidUser = testUserEntity.copyWith(
          name: 'a' * 101, // Exceeds maximum length
        );

        // Act
        final result = await repository.updateUser(invalidUser);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.updateUser(any));
      });
    });

    group('updateUserStats', () {
      test('should update user statistics successfully', () async {
        // Arrange
        const newStats = UserStats(
          totalQuizzes: 8,
          totalGamesPlayed: 15,
          totalGamesWon: 5,
          averageScore: 90.0,
        );

        final updatedModel = testUserModel.copyWith(stats: newStats.toModel());

        when(
          mockDataSource.updateUser(any),
        ).thenAnswer((_) async => Result.success(updatedModel));

        when(
          mockDataSource.getUserById(testUserId),
        ).thenAnswer((_) async => Result.success(testUserModel));

        // Act
        final result = await repository.updateUserStats(testUserId, newStats);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.stats?.totalQuizzes, 8);
        expect(result.data?.stats?.averageScore, 90.0);
        verify(mockDataSource.getUserById(testUserId)).called(1);
        verify(mockDataSource.updateUser(any)).called(1);
      });

      test('should return failure when user does not exist', () async {
        // Arrange
        final error = Failure.firestoreFailure(
          message: 'User not found',
          code: 'user_not_found',
        );
        when(
          mockDataSource.getUserById(testUserId),
        ).thenAnswer((_) async => Result.failure(error));

        const newStats = UserStats(
          totalQuizzes: 8,
          totalGamesPlayed: 15,
          totalGamesWon: 5,
          averageScore: 90.0,
        );

        // Act
        final result = await repository.updateUserStats(testUserId, newStats);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, equals(error));
        verify(mockDataSource.getUserById(testUserId)).called(1);
        verifyNever(mockDataSource.updateUser(any));
      });
    });

    group('deleteUser', () {
      test('should delete user successfully', () async {
        // Arrange
        when(
          mockDataSource.deleteUser(testUserId),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await repository.deleteUser(testUserId);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.deleteUser(testUserId)).called(1);
      });

      test('should return failure when deletion fails', () async {
        // Arrange
        final error = Failure.firestoreFailure(
          message: 'Failed to delete user',
          code: 'delete_user_error',
        );
        when(
          mockDataSource.deleteUser(testUserId),
        ).thenAnswer((_) async => Result.failure(error));

        // Act
        final result = await repository.deleteUser(testUserId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, equals(error));
        verify(mockDataSource.deleteUser(testUserId)).called(1);
      });
    });

    group('userExists', () {
      test('should return true when user exists', () async {
        // Arrange
        when(
          mockDataSource.userExists(testUserId),
        ).thenAnswer((_) async => const Result.success(true));

        // Act
        final result = await repository.userExists(testUserId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, true);
        verify(mockDataSource.userExists(testUserId)).called(1);
      });

      test('should return false when user does not exist', () async {
        // Arrange
        when(
          mockDataSource.userExists(testUserId),
        ).thenAnswer((_) async => const Result.success(false));

        // Act
        final result = await repository.userExists(testUserId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, false);
        verify(mockDataSource.userExists(testUserId)).called(1);
      });
    });

    group('searchUsersByName', () {
      test('should return list of users matching search query', () async {
        // Arrange
        const query = 'Test';
        final userList = [testUserModel];
        when(
          mockDataSource.searchUsersByName(query),
        ).thenAnswer((_) async => Result.success(userList));

        // Act
        final result = await repository.searchUsersByName(query);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isA<List<UserEntity>>());
        expect(result.data?.length, 1);
        expect(result.data?.first.name, 'Test User');
        verify(mockDataSource.searchUsersByName(query)).called(1);
      });

      test('should return failure when query is too short', () async {
        // Arrange
        const shortQuery = 'T'; // Less than minimum 2 characters

        // Act
        final result = await repository.searchUsersByName(shortQuery);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.searchUsersByName(any));
      });

      test('should sanitize search query', () async {
        // Arrange
        const maliciousQuery = '<script>alert("xss")</script>';
        const sanitizedQuery = 'scriptalert("xss")/script';
        when(
          mockDataSource.searchUsersByName(sanitizedQuery),
        ).thenAnswer((_) async => const Result.success([]));

        // Act
        final result = await repository.searchUsersByName(maliciousQuery);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.searchUsersByName(sanitizedQuery)).called(1);
      });
    });

    group('getTopUsersByScore', () {
      test('should return top users ordered by score', () async {
        // Arrange
        const limit = 10;
        final userList = [testUserModel];
        when(
          mockDataSource.getTopUsersByScore(limit),
        ).thenAnswer((_) async => Result.success(userList));

        // Act
        final result = await repository.getTopUsersByScore(limit);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        verify(mockDataSource.getTopUsersByScore(limit)).called(1);
      });

      test('should validate limit parameter', () async {
        // Arrange
        const invalidLimit = 0;

        // Act
        final result = await repository.getTopUsersByScore(invalidLimit);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.getTopUsersByScore(any));
      });

      test('should enforce maximum limit', () async {
        // Arrange
        const excessiveLimit = 1000;
        const maxLimit = 100; // Expected maximum
        when(
          mockDataSource.getTopUsersByScore(maxLimit),
        ).thenAnswer((_) async => const Result.success([]));

        // Act
        final result = await repository.getTopUsersByScore(excessiveLimit);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.getTopUsersByScore(maxLimit)).called(1);
      });
    });

    group('watchUser', () {
      test('should return stream of UserEntity updates', () async {
        // Arrange
        final modelStream = Stream.fromIterable([
          Result.success(testUserModel),
          Result.success(testUserModel.copyWith(name: 'Updated Name')),
        ]);
        when(
          mockDataSource.watchUser(testUserId),
        ).thenAnswer((_) => modelStream);

        // Act
        final stream = repository.watchUser(testUserId);
        final results = await stream.take(2).toList();

        // Assert
        expect(results.length, 2);
        expect(results[0].isSuccess, true);
        expect(results[0].data?.name, 'Test User');
        expect(results[1].isSuccess, true);
        expect(results[1].data?.name, 'Updated Name');
        verify(mockDataSource.watchUser(testUserId)).called(1);
      });

      test('should handle stream errors gracefully', () async {
        // Arrange
        final errorStream = Stream<Result<UserModel>>.fromIterable([
          Result.failure(
            Failure.firestoreFailure(
              message: 'Connection error',
              code: 'connection_error',
            ),
          ),
        ]);
        when(
          mockDataSource.watchUser(testUserId),
        ).thenAnswer((_) => errorStream);

        // Act
        final stream = repository.watchUser(testUserId);
        final result = await stream.first;

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verify(mockDataSource.watchUser(testUserId)).called(1);
      });
    });

    group('batchUpdateUsers', () {
      test('should update multiple users successfully', () async {
        // Arrange
        final users = [
          testUserEntity,
          testUserEntity.copyWith(id: 'user-2', name: 'User 2'),
        ];
        when(
          mockDataSource.batchUpdateUsers(any),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await repository.batchUpdateUsers(users);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.batchUpdateUsers(any)).called(1);
      });

      test('should validate all users before batch update', () async {
        // Arrange
        final users = [
          testUserEntity,
          testUserEntity.copyWith(id: 'user-2', email: ''), // Invalid
        ];

        // Act
        final result = await repository.batchUpdateUsers(users);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.batchUpdateUsers(any));
      });

      test('should enforce batch size limit', () async {
        // Arrange
        final users = List.generate(
          501, // Exceeds expected maximum of 500
          (index) => testUserEntity.copyWith(id: 'user-$index'),
        );

        // Act
        final result = await repository.batchUpdateUsers(users);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<Failure>());
        verifyNever(mockDataSource.batchUpdateUsers(any));
      });
    });
  });

  group('Data Mapping Tests', () {
    test('should correctly map UserModel to UserEntity', () {
      // Arrange
      final userModel = UserModel(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        stats: const UserStatsModel(
          totalQuizzes: 5,
          totalGamesPlayed: 10,
          totalGamesWon: 3,
          averageScore: 85.5,
        ),
        preferences: const UserPreferencesModel(
          soundEnabled: true,
          notificationsEnabled: false,
          theme: 'dark',
          language: 'es',
        ),
      );

      // Act
      final entity = userModel.toEntity();

      // Assert
      expect(entity.id, userModel.id);
      expect(entity.name, userModel.name);
      expect(entity.email, userModel.email);
      expect(entity.createdAt, userModel.createdAt);
      expect(entity.stats?.totalQuizzes, userModel.stats?.totalQuizzes);
      expect(entity.preferences?.theme, userModel.preferences?.theme);
    });

    test('should correctly map UserEntity to UserModel', () {
      // Arrange
      final userEntity = UserEntity(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        stats: const UserStats(
          totalQuizzes: 8,
          totalGamesPlayed: 15,
          totalGamesWon: 5,
          averageScore: 92.3,
        ),
        preferences: const UserPreferences(
          soundEnabled: false,
          notificationsEnabled: true,
          theme: 'light',
          language: 'fr',
        ),
      );

      // Act
      final model = userEntity.toModel();

      // Assert
      expect(model.id, userEntity.id);
      expect(model.name, userEntity.name);
      expect(model.email, userEntity.email);
      expect(model.createdAt, userEntity.createdAt);
      expect(model.stats?.totalGamesWon, userEntity.stats?.totalGamesWon);
      expect(model.preferences?.language, userEntity.preferences?.language);
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle null and empty values gracefully', () async {
      // Arrange
      final userWithNulls = UserEntity(
        id: 'test-id',
        name: '',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        stats: null,
        preferences: null,
      );

      // Act
      final result = await repository.createUser(userWithNulls);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<ValidationException>());
    });

    test('should handle concurrent operations correctly', () async {
      // Arrange
      const testUserId = 'test-user-id';
      final testUserModel = UserModel(
        id: testUserId,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        stats: const UserStatsModel(
          totalQuizzes: 5,
          totalGamesPlayed: 10,
          totalGamesWon: 3,
          averageScore: 85.5,
        ),
      );

      when(
        mockDataSource.getUserById(testUserId),
      ).thenAnswer((_) async => Result.success(testUserModel));

      // Act - Simulate concurrent reads
      final futures = List.generate(
        10,
        (_) => repository.getUserById(testUserId),
      );
      final results = await Future.wait(futures);

      // Assert
      expect(results.every((r) => r.isSuccess), true);
      verify(mockDataSource.getUserById(testUserId)).called(10);
    });
  });
}
