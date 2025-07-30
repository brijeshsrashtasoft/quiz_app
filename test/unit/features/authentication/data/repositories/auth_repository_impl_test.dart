import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:quiz_app/features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_entity.dart';
import '../../../../../test_config.dart';

import 'auth_repository_impl_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([FirebaseAuthDataSource, UserCredential, User])
void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuthDataSource mockDataSource;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockDataSource = MockFirebaseAuthDataSource();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    repository = AuthRepositoryImpl(dataSource: mockDataSource);
  });

  testGroup('AuthRepositoryImpl', TestCategory.unit, () {
    final testEmail = 'test@example.com';
    final testPassword = 'testpassword123';
    final testUserId = 'test-user-id';
    final testDisplayName = 'Test User';

    group('signInWithEmailAndPassword', () {
      testCase(
        'should return AuthEntity when sign in succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.uid).thenReturn(testUserId);
          when(mockUser.email).thenReturn(testEmail);
          when(mockUser.displayName).thenReturn(testDisplayName);
          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.photoURL).thenReturn(null);
          when(mockUserCredential.user).thenReturn(mockUser);

          when(
            mockDataSource.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act
          final result = await repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          final authEntity = result.dataOrNull!;
          expect(authEntity.user.id, equals(testUserId));
          expect(authEntity.user.email, equals(testEmail));
          expect(authEntity.user.displayName, equals(testDisplayName));
          expect(authEntity.isEmailVerified, isTrue);

          verify(
            mockDataSource.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when data source fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'User not found',
            code: 'user-not-found',
          );
          when(
            mockDataSource.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );

      testCase(
        'should handle null user in UserCredential',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUserCredential.user).thenReturn(null);
          when(
            mockDataSource.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act
          final result = await repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
          expect(result.failureOrNull?.code, equals('null-user-error'));
        },
      );

      testCase(
        'should complete within performance threshold',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.uid).thenReturn(testUserId);
          when(mockUser.email).thenReturn(testEmail);
          when(mockUser.displayName).thenReturn(testDisplayName);
          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.photoURL).thenReturn(null);
          when(mockUserCredential.user).thenReturn(mockUser);

          when(
            mockDataSource.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            await repository.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            );
          });
        },
      );
    });

    group('createUserWithEmailAndPassword', () {
      testCase(
        'should return AuthEntity when user creation succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.uid).thenReturn(testUserId);
          when(mockUser.email).thenReturn(testEmail);
          when(mockUser.displayName).thenReturn(testDisplayName);
          when(mockUser.emailVerified).thenReturn(false);
          when(mockUser.photoURL).thenReturn(null);
          when(mockUserCredential.user).thenReturn(mockUser);

          when(
            mockDataSource.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act
          final result = await repository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          final authEntity = result.dataOrNull!;
          expect(authEntity.user.id, equals(testUserId));
          expect(authEntity.user.email, equals(testEmail));
          expect(authEntity.isEmailVerified, isFalse);

          verify(
            mockDataSource.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when data source fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'Email already in use',
            code: 'email-already-in-use',
          );
          when(
            mockDataSource.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('signInWithGoogle', () {
      testCase(
        'should return AuthEntity when Google sign in succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.uid).thenReturn(testUserId);
          when(mockUser.email).thenReturn(testEmail);
          when(mockUser.displayName).thenReturn(testDisplayName);
          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
          when(mockUserCredential.user).thenReturn(mockUser);

          when(
            mockDataSource.signInWithGoogle(),
          ).thenAnswer((_) async => Result.success(mockUserCredential));

          // Act
          final result = await repository.signInWithGoogle();

          // Assert
          expect(result.isSuccess, isTrue);
          final authEntity = result.dataOrNull!;
          expect(authEntity.user.id, equals(testUserId));
          expect(authEntity.user.email, equals(testEmail));
          expect(authEntity.user.displayName, equals(testDisplayName));
          expect(
            authEntity.user.photoURL,
            equals('https://example.com/photo.jpg'),
          );
          expect(authEntity.isEmailVerified, isTrue);

          verify(mockDataSource.signInWithGoogle()).called(1);
        },
      );

      testCase(
        'should return Failure when Google sign in fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'Google sign in cancelled',
            code: 'sign_in_cancelled',
          );
          when(
            mockDataSource.signInWithGoogle(),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.signInWithGoogle();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('signOut', () {
      testCase(
        'should return success when sign out succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockDataSource.signOut(),
          ).thenAnswer((_) async => const Result.success(null));

          // Act
          final result = await repository.signOut();

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockDataSource.signOut()).called(1);
        },
      );

      testCase(
        'should return Failure when sign out fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'Sign out failed',
            code: 'signout_error',
          );
          when(
            mockDataSource.signOut(),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.signOut();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('sendPasswordResetEmail', () {
      testCase(
        'should return success when password reset email is sent',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockDataSource.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => const Result.success(null));

          // Act
          final result = await repository.sendPasswordResetEmail(
            email: testEmail,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockDataSource.sendPasswordResetEmail(email: testEmail),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when password reset fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'User not found',
            code: 'user-not-found',
          );
          when(
            mockDataSource.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.sendPasswordResetEmail(
            email: testEmail,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('updateUserProfile', () {
      testCase(
        'should return success when profile update succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockDataSource.updateUserProfile(
              displayName: anyNamed('displayName'),
              photoURL: anyNamed('photoURL'),
            ),
          ).thenAnswer((_) async => const Result.success(null));

          // Act
          final result = await repository.updateUserProfile(
            displayName: testDisplayName,
            photoURL: 'https://example.com/photo.jpg',
          );

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockDataSource.updateUserProfile(
              displayName: testDisplayName,
              photoURL: 'https://example.com/photo.jpg',
            ),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when profile update fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'No current user',
            code: 'no-current-user',
          );
          when(
            mockDataSource.updateUserProfile(
              displayName: anyNamed('displayName'),
              photoURL: anyNamed('photoURL'),
            ),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.updateUserProfile(
            displayName: testDisplayName,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('deleteUserAccount', () {
      testCase(
        'should return success when account deletion succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockDataSource.deleteUserAccount(),
          ).thenAnswer((_) async => const Result.success(null));

          // Act
          final result = await repository.deleteUserAccount();

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockDataSource.deleteUserAccount()).called(1);
        },
      );

      testCase(
        'should return Failure when account deletion fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'Requires recent login',
            code: 'requires-recent-login',
          );
          when(
            mockDataSource.deleteUserAccount(),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.deleteUserAccount();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('getCurrentUser', () {
      testCase(
        'should return current user when available',
        TestCategory.unit,
        () {
          // Arrange
          when(mockDataSource.getCurrentUser()).thenReturn(mockUser);

          // Act
          final result = repository.getCurrentUser();

          // Assert
          expect(result, equals(mockUser));
          verify(mockDataSource.getCurrentUser()).called(1);
        },
      );

      testCase(
        'should return null when no current user',
        TestCategory.unit,
        () {
          // Arrange
          when(mockDataSource.getCurrentUser()).thenReturn(null);

          // Act
          final result = repository.getCurrentUser();

          // Assert
          expect(result, isNull);
          verify(mockDataSource.getCurrentUser()).called(1);
        },
      );
    });

    group('isAuthenticated', () {
      testCase(
        'should return true when user is authenticated',
        TestCategory.unit,
        () {
          // Arrange
          when(mockDataSource.isAuthenticated).thenReturn(true);

          // Act
          final result = repository.isAuthenticated;

          // Assert
          expect(result, isTrue);
        },
      );

      testCase(
        'should return false when user is not authenticated',
        TestCategory.unit,
        () {
          // Arrange
          when(mockDataSource.isAuthenticated).thenReturn(false);

          // Act
          final result = repository.isAuthenticated;

          // Assert
          expect(result, isFalse);
        },
      );
    });

    group('currentUserId', () {
      testCase('should return user ID when available', TestCategory.unit, () {
        // Arrange
        when(mockDataSource.currentUserId).thenReturn(testUserId);

        // Act
        final result = repository.currentUserId;

        // Assert
        expect(result, equals(testUserId));
      });

      testCase(
        'should return null when no current user',
        TestCategory.unit,
        () {
          // Arrange
          when(mockDataSource.currentUserId).thenReturn(null);

          // Act
          final result = repository.currentUserId;

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('authStateChanges', () {
      testCase('should return auth state stream', TestCategory.unit, () async {
        // Arrange
        final userStream = Stream<User?>.fromIterable([mockUser, null]);
        when(mockDataSource.authStateChanges()).thenAnswer((_) => userStream);

        // Act
        final stream = repository.authStateChanges();
        final users = await stream.take(2).toList();

        // Assert
        expect(users.length, equals(2));
        expect(users[0], equals(mockUser));
        expect(users[1], isNull);
        verify(mockDataSource.authStateChanges()).called(1);
      });
    });

    group('idTokenChanges', () {
      testCase(
        'should return id token changes stream',
        TestCategory.unit,
        () async {
          // Arrange
          final userStream = Stream<User?>.fromIterable([mockUser]);
          when(mockDataSource.idTokenChanges()).thenAnswer((_) => userStream);

          // Act
          final stream = repository.idTokenChanges();
          final user = await stream.first;

          // Assert
          expect(user, equals(mockUser));
          verify(mockDataSource.idTokenChanges()).called(1);
        },
      );
    });

    group('sendEmailVerification', () {
      testCase(
        'should return success when email verification is sent',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockDataSource.sendEmailVerification(),
          ).thenAnswer((_) async => const Result.success(null));

          // Act
          final result = await repository.sendEmailVerification();

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockDataSource.sendEmailVerification()).called(1);
        },
      );

      testCase(
        'should return Failure when email verification fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'Email already verified',
            code: 'email-already-verified',
          );
          when(
            mockDataSource.sendEmailVerification(),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.sendEmailVerification();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });

    group('reloadUser', () {
      testCase(
        'should return success when user reload succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockDataSource.reloadUser(),
          ).thenAnswer((_) async => const Result.success(null));

          // Act
          final result = await repository.reloadUser();

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockDataSource.reloadUser()).called(1);
        },
      );

      testCase(
        'should return Failure when user reload fails',
        TestCategory.unit,
        () async {
          // Arrange
          final failure = AuthFailure(
            message: 'No current user',
            code: 'no-current-user',
          );
          when(
            mockDataSource.reloadUser(),
          ).thenAnswer((_) async => Result.failure(failure));

          // Act
          final result = await repository.reloadUser();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(failure));
        },
      );
    });
  });

  testGroup('Entity Conversion Tests', TestCategory.unit, () {
    testCase(
      'should correctly convert Firebase User to AuthUser entity',
      TestCategory.unit,
      () async {
        // Arrange
        const userId = 'test-user-id';
        const email = 'test@example.com';
        const displayName = 'Test User';
        const photoURL = 'https://example.com/photo.jpg';
        const emailVerified = true;

        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockUser.photoURL).thenReturn(photoURL);
        when(mockUser.emailVerified).thenReturn(emailVerified);
        when(mockUserCredential.user).thenReturn(mockUser);

        when(
          mockDataSource.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.success(mockUserCredential));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: 'password',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final authEntity = result.dataOrNull!;
        expect(authEntity.user.id, equals(userId));
        expect(authEntity.user.email, equals(email));
        expect(authEntity.user.displayName, equals(displayName));
        expect(authEntity.user.photoURL, equals(photoURL));
        expect(authEntity.isEmailVerified, equals(emailVerified));
      },
    );

    testCase(
      'should handle null optional fields in Firebase User',
      TestCategory.unit,
      () async {
        // Arrange
        const userId = 'test-user-id';
        const email = 'test@example.com';

        when(mockUser.uid).thenReturn(userId);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUserCredential.user).thenReturn(mockUser);

        when(
          mockDataSource.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.success(mockUserCredential));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: 'password',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final authEntity = result.dataOrNull!;
        expect(authEntity.user.id, equals(userId));
        expect(authEntity.user.email, equals(email));
        expect(authEntity.user.displayName, isNull);
        expect(authEntity.user.photoURL, isNull);
        expect(authEntity.isEmailVerified, isFalse);
      },
    );
  });
}
