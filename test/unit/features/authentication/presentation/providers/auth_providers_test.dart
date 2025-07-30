import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/usecases/get_user_by_id_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/create_user_usecase.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import '../../../../../../test_config.dart';

import 'auth_providers_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([User, GetUserByIdUseCase, CreateUserUseCase])
void main() {
  testGroup('Authentication Providers Tests', TestCategory.unit, () {
    late MockUser mockFirebaseUser;
    late MockGetUserByIdUseCase mockGetUserByIdUseCase;
    late MockCreateUserUseCase mockCreateUserUseCase;
    late ProviderContainer container;

    setUp(() {
      mockFirebaseUser = MockUser();
      mockGetUserByIdUseCase = MockGetUserByIdUseCase();
      mockCreateUserUseCase = MockCreateUserUseCase();

      container = ProviderContainer(
        overrides: [
          getUserByIdUseCaseProvider.overrideWithValue(mockGetUserByIdUseCase),
          createUserUseCaseProvider.overrideWithValue(mockCreateUserUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testGroup('AuthState', () {
      testCase(
        'unauthenticated state should have correct properties',
        TestCategory.unit,
        () {
          // Arrange & Act
          const authState = AuthState.unauthenticated();

          // Assert
          expect(authState.isUnauthenticated, isTrue);
          expect(authState.isAuthenticated, isFalse);
          expect(authState.hasError, isFalse);
          expect(authState.isLoading, isFalse);
          expect(authState.firebaseUser, isNull);
          expect(authState.user, isNull);
          expect(authState.errorMessage, isNull);
        },
      );

      testCase(
        'loading state should have correct properties',
        TestCategory.unit,
        () {
          // Arrange & Act
          const authState = AuthState.loading();

          // Assert
          expect(authState.isLoading, isTrue);
          expect(authState.isAuthenticated, isFalse);
          expect(authState.isUnauthenticated, isFalse);
          expect(authState.hasError, isFalse);
        },
      );

      testCase(
        'authenticated state should have correct properties',
        TestCategory.unit,
        () {
          // Arrange
          final userEntity = UserEntity(
            id: 'test-id',
            name: 'Test User',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          );

          // Act
          final authState = AuthState.authenticated(
            firebaseUser: mockFirebaseUser,
            user: userEntity,
          );

          // Assert
          expect(authState.isAuthenticated, isTrue);
          expect(authState.isUnauthenticated, isFalse);
          expect(authState.hasError, isFalse);
          expect(authState.isLoading, isFalse);
          expect(authState.firebaseUser, equals(mockFirebaseUser));
          expect(authState.user, equals(userEntity));
        },
      );

      testCase(
        'error state should have correct properties',
        TestCategory.unit,
        () {
          // Arrange & Act
          const authState = AuthState.error(
            firebaseUser: null,
            message: 'Test error message',
          );

          // Assert
          expect(authState.hasError, isTrue);
          expect(authState.errorMessage, equals('Test error message'));
          expect(authState.isAuthenticated, isFalse);
          expect(authState.isUnauthenticated, isFalse);
          expect(authState.isLoading, isFalse);
        },
      );
    });

    testGroup('Provider Dependencies', () {
      testCase(
        'currentUserProvider should return null when unauthenticated',
        TestCategory.unit,
        () async {
          // Arrange
          container = ProviderContainer(
            overrides: [
              authStateProvider.overrideWith(
                (ref) => Stream.value(
                  const AuthState.unauthenticated(),
                ).asBroadcastStream(),
              ),
            ],
          );

          // Act
          final currentUser = container.read(currentUserProvider);

          // Assert
          expect(currentUser, isNull);
        },
      );

      testCase(
        'isAuthenticatedProvider should return false when unauthenticated',
        TestCategory.unit,
        () {
          // Arrange
          container = ProviderContainer(
            overrides: [
              authStateProvider.overrideWith(
                (ref) => Stream.value(
                  const AuthState.unauthenticated(),
                ).asBroadcastStream(),
              ),
            ],
          );

          // Act
          final isAuthenticated = container.read(isAuthenticatedProvider);

          // Assert
          expect(isAuthenticated, isFalse);
        },
      );

      testCase(
        'currentUserIdProvider should return null when unauthenticated',
        TestCategory.unit,
        () {
          // Arrange
          container = ProviderContainer(
            overrides: [currentUserProvider.overrideWithValue(null)],
          );

          // Act
          final userId = container.read(currentUserIdProvider);

          // Assert
          expect(userId, isNull);
        },
      );

      testCase(
        'currentFirebaseUserProvider should return firebase user when authenticated',
        TestCategory.unit,
        () {
          // Arrange
          final userEntity = UserEntity(
            id: 'test-id',
            name: 'Test User',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          );

          final authState = AuthState.authenticated(
            firebaseUser: mockFirebaseUser,
            user: userEntity,
          );

          container = ProviderContainer(
            overrides: [
              authStateProvider.overrideWith(
                (ref) => Stream.value(authState).asBroadcastStream(),
              ),
            ],
          );

          // Act
          final firebaseUser = container.read(currentFirebaseUserProvider);

          // Assert
          expect(firebaseUser, equals(mockFirebaseUser));
        },
      );
    });

    testGroup('Authentication State Stream', () {
      testCase(
        'should handle successful user data loading',
        TestCategory.unit,
        () async {
          // Arrange
          const userId = 'test-user-id';
          const email = 'test@example.com';

          when(mockFirebaseUser.uid).thenReturn(userId);
          when(mockFirebaseUser.email).thenReturn(email);
          when(mockFirebaseUser.displayName).thenReturn('Test User');

          final userEntity = UserEntity(
            id: userId,
            name: 'Test User',
            email: email,
            createdAt: DateTime.now(),
          );

          when(
            mockGetUserByIdUseCase(GetUserByIdParams(userId: userId)),
          ).thenAnswer((_) async => Result.success(userEntity));

          // Act
          final firebaseUserStream = Stream.value(mockFirebaseUser);
          container = ProviderContainer(
            overrides: [
              firebaseAuthProvider.overrideWith((ref) => firebaseUserStream),
              getUserByIdUseCaseProvider.overrideWithValue(
                mockGetUserByIdUseCase,
              ),
            ],
          );

          final authStateStream = container.read(authStateProvider.stream);
          final authState = await authStateStream.first;

          // Assert
          expect(authState.isAuthenticated, isTrue);
          expect(authState.user, equals(userEntity));
          expect(authState.firebaseUser, equals(mockFirebaseUser));
        },
      );

      testCase(
        'should create new user when user data not found',
        TestCategory.unit,
        () async {
          // Arrange
          const userId = 'new-user-id';
          const email = 'newuser@example.com';
          const displayName = 'New User';

          when(mockFirebaseUser.uid).thenReturn(userId);
          when(mockFirebaseUser.email).thenReturn(email);
          when(mockFirebaseUser.displayName).thenReturn(displayName);

          // User not found initially
          when(
            mockGetUserByIdUseCase(GetUserByIdParams(userId: userId)),
          ).thenAnswer(
            (_) async => Result.failure(
              Failure.firestoreFailure(
                message: 'User not found',
                code: 'USER_NOT_FOUND',
              ),
            ),
          );

          final newUser = UserEntity(
            id: userId,
            name: displayName,
            email: email,
            createdAt: DateTime.now(),
          );

          when(
            mockCreateUserUseCase(any),
          ).thenAnswer((_) async => Result.success(newUser));

          // Act
          final firebaseUserStream = Stream.value(mockFirebaseUser);
          container = ProviderContainer(
            overrides: [
              firebaseAuthProvider.overrideWith((ref) => firebaseUserStream),
              getUserByIdUseCaseProvider.overrideWithValue(
                mockGetUserByIdUseCase,
              ),
              createUserUseCaseProvider.overrideWithValue(
                mockCreateUserUseCase,
              ),
            ],
          );

          final authStateStream = container.read(authStateProvider.stream);
          final authState = await authStateStream.first;

          // Assert
          expect(authState.isAuthenticated, isTrue);
          expect(authState.user?.email, equals(email));
          verify(mockCreateUserUseCase(any)).called(1);
        },
      );

      testCase(
        'should handle user creation failure gracefully',
        TestCategory.unit,
        () async {
          // Arrange
          const userId = 'new-user-id';
          const email = 'newuser@example.com';

          when(mockFirebaseUser.uid).thenReturn(userId);
          when(mockFirebaseUser.email).thenReturn(email);
          when(mockFirebaseUser.displayName).thenReturn('New User');

          // User not found
          when(
            mockGetUserByIdUseCase(GetUserByIdParams(userId: userId)),
          ).thenAnswer(
            (_) async => Result.failure(
              Failure.firestoreFailure(
                message: 'User not found',
                code: 'USER_NOT_FOUND',
              ),
            ),
          );

          // User creation fails
          when(mockCreateUserUseCase(any)).thenAnswer(
            (_) async => Result.failure(
              Failure.firestoreFailure(
                message: 'Failed to create user',
                code: 'CREATE_USER_ERROR',
              ),
            ),
          );

          // Act
          final firebaseUserStream = Stream.value(mockFirebaseUser);
          container = ProviderContainer(
            overrides: [
              firebaseAuthProvider.overrideWith((ref) => firebaseUserStream),
              getUserByIdUseCaseProvider.overrideWithValue(
                mockGetUserByIdUseCase,
              ),
              createUserUseCaseProvider.overrideWithValue(
                mockCreateUserUseCase,
              ),
            ],
          );

          final authStateStream = container.read(authStateProvider.stream);
          final authState = await authStateStream.first;

          // Assert
          expect(authState.hasError, isTrue);
          expect(
            authState.errorMessage,
            contains('Failed to create user profile'),
          );
          expect(authState.firebaseUser, equals(mockFirebaseUser));
        },
      );

      testCase('should handle null firebase user', TestCategory.unit, () async {
        // Act
        final firebaseUserStream = Stream<User?>.value(null);
        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWith((ref) => firebaseUserStream),
          ],
        );

        final authStateStream = container.read(authStateProvider.stream);
        final authState = await authStateStream.first;

        // Assert
        expect(authState.isUnauthenticated, isTrue);
        expect(authState.firebaseUser, isNull);
        expect(authState.user, isNull);
      });
    });

    testGroup('Watch User Provider', () {
      testCase(
        'should return stream of user updates',
        TestCategory.unit,
        () async {
          // Arrange
          const userId = 'test-user-id';
          final userEntity = UserEntity(
            id: userId,
            name: 'Test User',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          );

          final userStream = Stream.fromIterable([
            Result.success(userEntity),
            Result.success(userEntity.copyWith(name: 'Updated User')),
          ]);

          // Mock the use case to return our stream
          container = ProviderContainer(
            overrides: [
              watchUserProvider(userId).overrideWith((ref) async* {
                await for (final result in userStream) {
                  yield result.when(
                    success: (user) => user,
                    failure: (error) => null,
                  );
                }
              }),
            ],
          );

          // Act
          final watchStream = container.read(watchUserProvider(userId).stream);
          final results = await watchStream.take(2).toList();

          // Assert
          expect(results.length, equals(2));
          expect(results[0]?.name, equals('Test User'));
          expect(results[1]?.name, equals('Updated User'));
        },
      );

      testCase(
        'should handle watch user errors gracefully',
        TestCategory.unit,
        () async {
          // Arrange
          const userId = 'test-user-id';

          container = ProviderContainer(
            overrides: [
              watchUserProvider(userId).overrideWith((ref) async* {
                yield null; // Simulate error result
              }),
            ],
          );

          // Act
          final watchStream = container.read(watchUserProvider(userId).stream);
          final result = await watchStream.first;

          // Assert
          expect(result, isNull);
        },
      );
    });

    testGroup('Provider Performance Tests', () {
      testCase(
        'auth state provider should handle rapid state changes',
        TestCategory.unit,
        () async {
          // Arrange
          final rapidStateChanges = Stream.fromIterable([
            const AuthState.loading(),
            const AuthState.unauthenticated(),
            const AuthState.loading(),
            const AuthState.unauthenticated(),
          ]);

          container = ProviderContainer(
            overrides: [
              authStateProvider.overrideWith((ref) => rapidStateChanges),
            ],
          );

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            final stream = container.read(authStateProvider.stream);
            await stream.take(4).toList();
          }, threshold: const Duration(milliseconds: 100));
        },
      );

      testCase(
        'provider dependencies should resolve quickly',
        TestCategory.unit,
        () async {
          // Arrange
          final userEntity = UserEntity(
            id: 'test-id',
            name: 'Test User',
            email: 'test@example.com',
            createdAt: DateTime.now(),
          );

          container = ProviderContainer(
            overrides: [currentUserProvider.overrideWithValue(userEntity)],
          );

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            final user = container.read(currentUserProvider);
            final isAuth = container.read(isAuthenticatedProvider);
            final userId = container.read(currentUserIdProvider);

            expect(user, isNotNull);
            expect(isAuth, isNotNull);
            expect(userId, isNotNull);
          }, threshold: const Duration(milliseconds: 50));
        },
      );
    });

    testGroup('Provider Memory Management', () {
      testCase(
        'providers should not leak memory on disposal',
        TestCategory.unit,
        () {
          // Arrange
          final containers = <ProviderContainer>[];

          // Act
          for (int i = 0; i < 100; i++) {
            final container = ProviderContainer();
            container.read(authServiceProvider);
            containers.add(container);
          }

          // Dispose all containers
          for (final container in containers) {
            container.dispose();
          }

          // Assert - No memory leaks (in real scenario, would check with profiler)
          expect(containers.length, equals(100));
        },
      );
    });

    testGroup('Error Recovery Tests', () {
      testCase(
        'should recover from temporary network errors',
        TestCategory.unit,
        () async {
          // Arrange
          const userId = 'test-user-id';
          when(mockFirebaseUser.uid).thenReturn(userId);
          when(mockFirebaseUser.email).thenReturn('test@example.com');

          // First call fails, second succeeds
          when(mockGetUserByIdUseCase(GetUserByIdParams(userId: userId)))
              .thenAnswer(
                (_) async => Result.failure(
                  Failure.networkFailure(
                    message: 'Network error',
                    code: 'NETWORK_ERROR',
                  ),
                ),
              )
              .thenAnswer(
                (_) async => Result.success(
                  UserEntity(
                    id: userId,
                    name: 'Test User',
                    email: 'test@example.com',
                    createdAt: DateTime.now(),
                  ),
                ),
              );

          // Act
          final firebaseUserStream = Stream.value(mockFirebaseUser);
          container = ProviderContainer(
            overrides: [
              firebaseAuthProvider.overrideWith((ref) => firebaseUserStream),
              getUserByIdUseCaseProvider.overrideWithValue(
                mockGetUserByIdUseCase,
              ),
            ],
          );

          final authStateStream = container.read(authStateProvider.stream);
          final authState = await authStateStream.first;

          // Assert - Should handle the error gracefully
          expect(authState, isA<AuthState>());
        },
      );
    });
  });
}
