import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';

import '../../../../../test_config.dart';
import '../helpers/auth_domain_test_helpers.dart';

import 'auth_repository_test.mocks.dart';

/// Comprehensive unit tests for AuthRepository interface contracts
/// Following TDD principles and CLAUDE.md testing patterns
/// Tests repository interface behavior and contracts
@GenerateMocks([AuthRepository])
void main() {
  testGroup('AuthRepository Interface', TestCategory.unit, () {
    late MockAuthRepository mockAuthRepository;
    late UserEntity testUser;

    setUpAll(() {
      testUser = AuthDomainTestHelpers.createTestUserEntity(
        id: 'test-user-123',
        name: 'Test User',
        email: 'test@example.com',
      );
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    group('Sign In Methods', () {
      testCase(
        'signInWithEmailPassword should return Result<UserEntity>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await mockAuthRepository.signInWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
          );

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(testUser));
          verify(
            mockAuthRepository.signInWithEmailPassword(
              email: 'test@example.com',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      testCase(
        'signInWithGoogle should return Result<UserEntity>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signInWithGoogle(),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await mockAuthRepository.signInWithGoogle();

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(testUser));
          verify(mockAuthRepository.signInWithGoogle()).called(1);
        },
      );

      testCase(
        'signInWithEmailPassword should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Invalid credentials',
            code: 'AUTH_INVALID_CREDENTIALS',
          );
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.signInWithEmailPassword(
            email: 'test@example.com',
            password: 'wrong-password',
          );

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );

      testCase(
        'signInWithGoogle should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Google sign in cancelled',
            code: 'AUTH_GOOGLE_CANCELLED',
          );
          when(
            mockAuthRepository.signInWithGoogle(),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.signInWithGoogle();

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('User Creation Methods', () {
      testCase(
        'createUserWithEmailPassword should return Result<UserEntity>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.createUserWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              name: any,
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await mockAuthRepository.createUserWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
            name: 'Test User',
          );

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(testUser));
          verify(
            mockAuthRepository.createUserWithEmailPassword(
              email: 'test@example.com',
              password: 'password123',
              name: 'Test User',
            ),
          ).called(1);
        },
      );

      testCase(
        'createUserWithEmailPassword should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Email already in use',
            code: 'AUTH_EMAIL_ALREADY_IN_USE',
          );
          when(
            mockAuthRepository.createUserWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              name: any,
            ),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.createUserWithEmailPassword(
            email: 'existing@example.com',
            password: 'password123',
            name: 'Test User',
          );

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('Sign Out Methods', () {
      testCase(
        'signOut should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signOut(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.signOut();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.signOut()).called(1);
        },
      );

      testCase(
        'signOut should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Sign out failed',
            code: 'AUTH_SIGNOUT_ERROR',
          );
          when(
            mockAuthRepository.signOut(),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.signOut();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('Password Management Methods', () {
      testCase(
        'sendPasswordResetEmail should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.sendPasswordResetEmail(email: any),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.sendPasswordResetEmail(
            email: 'test@example.com',
          );

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(
            mockAuthRepository.sendPasswordResetEmail(
              email: 'test@example.com',
            ),
          ).called(1);
        },
      );

      testCase(
        'updatePassword should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.updatePassword(
              currentPassword: anyNamed('currentPassword'),
              newPassword: anyNamed('newPassword'),
            ),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.updatePassword(
            currentPassword: 'current-password',
            newPassword: 'new-password',
          );

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(
            mockAuthRepository.updatePassword(
              currentPassword: 'current-password',
              newPassword: 'new-password',
            ),
          ).called(1);
        },
      );

      testCase(
        'sendPasswordResetEmail should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'User not found',
            code: 'AUTH_USER_NOT_FOUND',
          );
          when(
            mockAuthRepository.sendPasswordResetEmail(email: any),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.sendPasswordResetEmail(
            email: 'nonexistent@example.com',
          );

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('Current User Methods', () {
      testCase(
        'getCurrentUser should return Result<UserEntity?>',
        TestCategory.unit,
        () {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(testUser));

          // Act
          final result = mockAuthRepository.getCurrentUser();

          // Assert
          expect(result, isA<Result<UserEntity?>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(testUser));
          verify(mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      testCase(
        'getCurrentUser should return null when not authenticated',
        TestCategory.unit,
        () {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(null));

          // Act
          final result = mockAuthRepository.getCurrentUser();

          // Assert
          expect(result, isA<Result<UserEntity?>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isNull);
        },
      );

      testCase(
        'getCurrentUser should handle failure cases',
        TestCategory.unit,
        () {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Failed to get current user',
            code: 'AUTH_GET_USER_ERROR',
          );
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.failure(authFailure));

          // Act
          final result = mockAuthRepository.getCurrentUser();

          // Assert
          expect(result, isA<Result<UserEntity?>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );

      testCase(
        'isAuthenticated getter should return boolean',
        TestCategory.unit,
        () {
          // Arrange
          when(mockAuthRepository.isAuthenticated).thenReturn(true);

          // Act
          final result = mockAuthRepository.isAuthenticated;

          // Assert
          expect(result, isA<bool>());
          expect(result, isTrue);
          verify(mockAuthRepository.isAuthenticated).called(1);
        },
      );

      testCase(
        'currentUserId getter should return String?',
        TestCategory.unit,
        () {
          // Arrange
          when(mockAuthRepository.currentUserId).thenReturn('test-user-123');

          // Act
          final result = mockAuthRepository.currentUserId;

          // Assert
          expect(result, isA<String?>());
          expect(result, equals('test-user-123'));
          verify(mockAuthRepository.currentUserId).called(1);
        },
      );

      testCase(
        'currentUserId getter should return null when not authenticated',
        TestCategory.unit,
        () {
          // Arrange
          when(mockAuthRepository.currentUserId).thenReturn(null);

          // Act
          final result = mockAuthRepository.currentUserId;

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('Stream Methods', () {
      testCase(
        'watchAuthState should return Stream<Result<UserEntity?>>',
        TestCategory.unit,
        () {
          // Arrange
          final authStream = Stream.value(
            Result<UserEntity?>.success(testUser),
          );
          when(
            mockAuthRepository.watchAuthState(),
          ).thenAnswer((_) => authStream);

          // Act
          final result = mockAuthRepository.watchAuthState();

          // Assert
          expect(result, isA<Stream<Result<UserEntity?>>>());
          verify(mockAuthRepository.watchAuthState()).called(1);
        },
      );

      testCase(
        'watchAuthState should emit authentication changes',
        TestCategory.unit,
        () async {
          // Arrange
          final authStream = Stream.fromIterable([
            Result<UserEntity?>.success(null), // Unauthenticated
            Result<UserEntity?>.success(testUser), // Authenticated
            Result<UserEntity?>.success(null), // Signed out
          ]);
          when(
            mockAuthRepository.watchAuthState(),
          ).thenAnswer((_) => authStream);

          // Act
          final results = await mockAuthRepository.watchAuthState().toList();

          // Assert
          expect(results.length, equals(3));
          expect(results[0].dataOrNull, isNull);
          expect(results[1].dataOrNull, equals(testUser));
          expect(results[2].dataOrNull, isNull);
        },
      );

      testCase(
        'watchAuthState should handle error cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Auth stream error',
            code: 'AUTH_STREAM_ERROR',
          );
          final authStream = Stream.value(
            Result<UserEntity?>.failure(authFailure),
          );
          when(
            mockAuthRepository.watchAuthState(),
          ).thenAnswer((_) => authStream);

          // Act
          final result = await mockAuthRepository.watchAuthState().first;

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('Account Management Methods', () {
      testCase(
        'deleteCurrentUser should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.deleteCurrentUser(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.deleteCurrentUser();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.deleteCurrentUser()).called(1);
        },
      );

      testCase(
        'deleteCurrentUser should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Account deletion failed',
            code: 'AUTH_DELETE_ACCOUNT_ERROR',
          );
          when(
            mockAuthRepository.deleteCurrentUser(),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.deleteCurrentUser();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );

      testCase(
        'sendEmailVerification should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.sendEmailVerification(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.sendEmailVerification();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.sendEmailVerification()).called(1);
        },
      );

      testCase(
        'isEmailVerified getter should return boolean',
        TestCategory.unit,
        () {
          // Arrange
          when(mockAuthRepository.isEmailVerified).thenReturn(true);

          // Act
          final result = mockAuthRepository.isEmailVerified;

          // Assert
          expect(result, isA<bool>());
          expect(result, isTrue);
          verify(mockAuthRepository.isEmailVerified).called(1);
        },
      );

      testCase(
        'reloadUser should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.reloadUser(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.reloadUser();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.reloadUser()).called(1);
        },
      );
    });

    group('Email Management Methods', () {
      testCase(
        'updateEmail should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.updateEmail(
              newEmail: anyNamed('newEmail'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.updateEmail(
            newEmail: 'new@example.com',
            password: 'current-password',
          );

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(
            mockAuthRepository.updateEmail(
              newEmail: 'new@example.com',
              password: 'current-password',
            ),
          ).called(1);
        },
      );

      testCase(
        'reauthenticate should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.reauthenticate(password: any),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.reauthenticate(
            password: 'current-password',
          );

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(
            mockAuthRepository.reauthenticate(password: 'current-password'),
          ).called(1);
        },
      );

      testCase(
        'getSignInMethodsForEmail should return Result<List<String>>',
        TestCategory.unit,
        () async {
          // Arrange
          final signInMethods = ['password', 'google.com'];
          when(
            mockAuthRepository.getSignInMethodsForEmail(
              email: anyNamed('email'),
            ),
          ).thenAnswer((_) async => Result.success(signInMethods));

          // Act
          final result = await mockAuthRepository.getSignInMethodsForEmail(
            email: 'test@example.com',
          );

          // Assert
          expect(result, isA<Result<List<String>>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(signInMethods));
          verify(
            mockAuthRepository.getSignInMethodsForEmail(
              email: 'test@example.com',
            ),
          ).called(1);
        },
      );
    });

    group('Google Account Linking', () {
      testCase(
        'linkGoogleAccount should return Result<UserEntity>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.linkGoogleAccount(),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await mockAuthRepository.linkGoogleAccount();

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(testUser));
          verify(mockAuthRepository.linkGoogleAccount()).called(1);
        },
      );

      testCase(
        'unlinkGoogleAccount should return Result<void>',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.unlinkGoogleAccount(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await mockAuthRepository.unlinkGoogleAccount();

          // Assert
          expect(result, isA<Result<void>>());
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.unlinkGoogleAccount()).called(1);
        },
      );

      testCase(
        'linkGoogleAccount should handle failure cases',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = AuthDomainTestHelpers.createAuthFailure(
            message: 'Google account linking failed',
            code: 'AUTH_GOOGLE_LINK_ERROR',
          );
          when(
            mockAuthRepository.linkGoogleAccount(),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await mockAuthRepository.linkGoogleAccount();

          // Assert
          expect(result, isA<Result<UserEntity>>());
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('Repository Behavior Verification', () {
      testCase(
        'should support multiple concurrent operations',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(testUser));
          when(mockAuthRepository.isAuthenticated).thenReturn(true);
          when(mockAuthRepository.currentUserId).thenReturn('test-user-123');

          // Act - Execute concurrently
          final futures = await Future.wait([
            Future.value(mockAuthRepository.getCurrentUser()),
            Future.value(mockAuthRepository.isAuthenticated),
            Future.value(mockAuthRepository.currentUserId),
          ]);

          // Assert
          expect(futures[0], isA<Result<UserEntity?>>());
          expect(futures[1], isA<bool>());
          expect(futures[2], isA<String?>());
        },
      );

      testCase('should maintain state consistency', TestCategory.unit, () {
        // Arrange - Set up consistent state
        when(mockAuthRepository.isAuthenticated).thenReturn(true);
        when(mockAuthRepository.currentUserId).thenReturn('test-user-123');
        when(
          mockAuthRepository.getCurrentUser(),
        ).thenReturn(Result.success(testUser));

        // Act & Assert - Multiple calls should be consistent
        expect(mockAuthRepository.isAuthenticated, isTrue);
        expect(mockAuthRepository.currentUserId, equals('test-user-123'));
        expect(
          mockAuthRepository.getCurrentUser().dataOrNull,
          equals(testUser),
        );

        // All calls should return the same values
        expect(mockAuthRepository.isAuthenticated, isTrue);
        expect(mockAuthRepository.currentUserId, equals('test-user-123'));
        expect(
          mockAuthRepository.getCurrentUser().dataOrNull,
          equals(testUser),
        );
      });

      testCase(
        'should handle rapid successive calls',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act - Rapid successive calls
          final futures = List.generate(10, (index) {
            return mockAuthRepository.signInWithEmailPassword(
              email: 'test$index@example.com',
              password: 'password123',
            );
          });

          final results = await Future.wait(futures);

          // Assert - All should succeed
          expect(results.every((result) => result.isSuccess), isTrue);
          expect(
            results.every((result) => result.dataOrNull == testUser),
            isTrue,
          );
        },
      );
    });

    group('Error Handling Patterns', () {
      testCase(
        'should handle network failures consistently',
        TestCategory.unit,
        () async {
          // Arrange
          final networkFailure = AuthDomainTestHelpers.createNetworkFailure(
            message: 'Network error',
          );

          // Set up multiple methods to return network failure
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.failure(networkFailure));

          when(
            mockAuthRepository.signOut(),
          ).thenAnswer((_) async => Result.failure(networkFailure));

          when(
            mockAuthRepository.sendPasswordResetEmail(email: any),
          ).thenAnswer((_) async => Result.failure(networkFailure));

          // Act & Assert
          final signInResult = await mockAuthRepository.signInWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
          );
          expect(signInResult.isFailure, isTrue);
          expect(signInResult.failureOrNull, equals(networkFailure));

          final signOutResult = await mockAuthRepository.signOut();
          expect(signOutResult.isFailure, isTrue);
          expect(signOutResult.failureOrNull, equals(networkFailure));

          final resetResult = await mockAuthRepository.sendPasswordResetEmail(
            email: 'test@example.com',
          );
          expect(resetResult.isFailure, isTrue);
          expect(resetResult.failureOrNull, equals(networkFailure));
        },
      );

      testCase(
        'should handle validation failures consistently',
        TestCategory.unit,
        () async {
          // Arrange
          final validationFailure =
              AuthDomainTestHelpers.createValidationFailure(
                message: 'Validation error',
                fieldErrors: {'field': 'VALIDATION_ERROR'},
              );

          // Set up methods to return validation failure
          when(
            mockAuthRepository.createUserWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              name: any,
            ),
          ).thenAnswer((_) async => Result.failure(validationFailure));

          when(
            mockAuthRepository.updateEmail(
              newEmail: anyNamed('newEmail'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.failure(validationFailure));

          // Act & Assert
          final createResult = await mockAuthRepository
              .createUserWithEmailPassword(
                email: 'invalid-email',
                password: 'weak',
                name: '',
              );
          expect(createResult.isFailure, isTrue);
          expect(createResult.failureOrNull, equals(validationFailure));

          final updateResult = await mockAuthRepository.updateEmail(
            newEmail: 'invalid-email',
            password: 'password123',
          );
          expect(updateResult.isFailure, isTrue);
          expect(updateResult.failureOrNull, equals(validationFailure));
        },
      );
    });

    group('Performance and Resource Management', () {
      testCase(
        'should complete operations within time limits',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            await mockAuthRepository.signInWithEmailPassword(
              email: 'test@example.com',
              password: 'password123',
            );
          });
        },
      );

      testCase(
        'should handle memory pressure during batch operations',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(testUser));

          // Act - Many synchronous operations
          final results = List.generate(1000, (index) {
            return mockAuthRepository.getCurrentUser();
          });

          // Assert - All should complete successfully
          expect(results.every((result) => result.isSuccess), isTrue);
          expect(
            results.every((result) => result.dataOrNull == testUser),
            isTrue,
          );
        },
      );
    });
  });
}
