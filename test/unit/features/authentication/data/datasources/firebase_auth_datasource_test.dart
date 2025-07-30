import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/features/authentication/data/datasources/firebase_auth_datasource.dart';
import '../../../../../test_config.dart';

import 'firebase_auth_datasource_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  AuthCredential,
])
void main() {
  late FirebaseAuthDataSource dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuth;
  late MockAuthCredential mockAuthCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuth = MockGoogleSignInAuthentication();
    mockAuthCredential = MockAuthCredential();

    dataSource = FirebaseAuthDataSource(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  testGroup('FirebaseAuthDataSource', TestCategory.unit, () {
    final testEmail = 'test@example.com';
    final testPassword = 'testpassword123';
    final testDisplayName = 'Test User';
    final testUserId = 'test-user-id';

    group('signInWithEmailAndPassword', () {
      testCase(
        'should return UserCredential when sign in succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.uid).thenReturn(testUserId);
          when(mockUser.email).thenReturn(testEmail);
          when(mockUser.displayName).thenReturn(testDisplayName);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );
          stopwatch.stop();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(mockUserCredential));
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(200),
          ); // Performance requirement
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when FirebaseAuthException is thrown',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found for that email.',
            ),
          );

          // Act
          final result = await dataSource.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
          expect(result.failureOrNull?.code, equals('user-not-found'));
        },
      );

      testCase(
        'should return Failure when generic exception is thrown',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(Exception('Network error'));

          // Act
          final result = await dataSource.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
        },
      );

      testCase(
        'should trim email input and handle edge cases',
        TestCategory.unit,
        () async {
          // Arrange
          const emailWithSpaces = '  test@example.com  ';
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);

          // Act
          final result = await dataSource.signInWithEmailAndPassword(
            email: emailWithSpaces,
            password: testPassword,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: emailWithSpaces.trim(),
              password: testPassword,
            ),
          ).called(1);
        },
      );
    });

    group('createUserWithEmailAndPassword', () {
      testCase(
        'should return UserCredential when user creation succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.uid).thenReturn(testUserId);
          when(mockUser.email).thenReturn(testEmail);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );
          stopwatch.stop();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(mockUserCredential));
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(200),
          ); // Performance requirement
          verify(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when FirebaseAuthException is thrown',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'The account already exists for that email.',
            ),
          );

          // Act
          final result = await dataSource.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
          expect(result.failureOrNull?.code, equals('email-already-in-use'));
        },
      );

      testCase(
        'should handle weak password error',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'weak-password',
              message: 'The password provided is too weak.',
            ),
          );

          // Act
          final result = await dataSource.createUserWithEmailAndPassword(
            email: testEmail,
            password: '123',
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('weak-password'));
        },
      );
    });

    group('signInWithGoogle', () {
      testCase(
        'should return UserCredential when Google sign in succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockGoogleSignInAuth.accessToken,
          ).thenReturn('mock-access-token');
          when(mockGoogleSignInAuth.idToken).thenReturn('mock-id-token');
          when(
            mockGoogleSignInAccount.authentication,
          ).thenAnswer((_) async => mockGoogleSignInAuth);
          when(
            mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleSignInAccount);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => mockUserCredential);

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.signInWithGoogle();
          stopwatch.stop();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(mockUserCredential));
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(200),
          ); // Performance requirement
          verify(mockGoogleSignIn.signIn()).called(1);
          verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        },
      );

      testCase(
        'should return Failure when Google sign in is cancelled',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

          // Act
          final result = await dataSource.signInWithGoogle();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
          expect(result.failureOrNull?.message, contains('cancelled'));
        },
      );

      testCase(
        'should return Failure when Google sign in throws exception',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockGoogleSignIn.signIn(),
          ).thenThrow(Exception('Google Sign In failed'));

          // Act
          final result = await dataSource.signInWithGoogle();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
        },
      );
    });

    group('signOut', () {
      testCase(
        'should successfully sign out from both Firebase and Google',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
          when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.signOut();
          stopwatch.stop();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(200),
          ); // Performance requirement
          verify(mockFirebaseAuth.signOut()).called(1);
          verify(mockGoogleSignIn.signOut()).called(1);
        },
      );

      testCase(
        'should return Failure when sign out throws exception',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.signOut(),
          ).thenThrow(Exception('Sign out failed'));

          // Act
          final result = await dataSource.signOut();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
        },
      );
    });

    group('sendPasswordResetEmail', () {
      testCase(
        'should successfully send password reset email',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => {});

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.sendPasswordResetEmail(
            email: testEmail,
          );
          stopwatch.stop();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(200),
          ); // Performance requirement
          verify(
            mockFirebaseAuth.sendPasswordResetEmail(email: testEmail),
          ).called(1);
        },
      );

      testCase(
        'should return Failure when FirebaseAuthException is thrown',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found for that email.',
            ),
          );

          // Act
          final result = await dataSource.sendPasswordResetEmail(
            email: testEmail,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('user-not-found'));
        },
      );
    });

    group('updateUserProfile', () {
      testCase(
        'should successfully update user profile',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.updateDisplayName(any)).thenAnswer((_) async => {});
          when(mockUser.updatePhotoURL(any)).thenAnswer((_) async => {});
          when(mockUser.reload()).thenAnswer((_) async => {});

          // Act
          final result = await dataSource.updateUserProfile(
            displayName: testDisplayName,
            photoURL: 'https://example.com/photo.jpg',
          );

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockUser.updateDisplayName(testDisplayName)).called(1);
          verify(
            mockUser.updatePhotoURL('https://example.com/photo.jpg'),
          ).called(1);
          verify(mockUser.reload()).called(1);
        },
      );

      testCase(
        'should return Failure when no current user',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(null);

          // Act
          final result = await dataSource.updateUserProfile(
            displayName: testDisplayName,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('no-current-user'));
        },
      );
    });

    group('deleteUserAccount', () {
      testCase(
        'should successfully delete user account',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.delete()).thenAnswer((_) async => {});

          // Act
          final result = await dataSource.deleteUserAccount();

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockUser.delete()).called(1);
        },
      );

      testCase(
        'should return Failure when no current user',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(null);

          // Act
          final result = await dataSource.deleteUserAccount();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('no-current-user'));
        },
      );

      testCase(
        'should return Failure when requires recent login',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.delete()).thenThrow(
            FirebaseAuthException(
              code: 'requires-recent-login',
              message:
                  'This operation is sensitive and requires recent authentication.',
            ),
          );

          // Act
          final result = await dataSource.deleteUserAccount();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('requires-recent-login'));
        },
      );
    });

    group('getCurrentUser', () {
      testCase(
        'should return current user when authenticated',
        TestCategory.unit,
        () {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

          // Act
          final result = dataSource.getCurrentUser();

          // Assert
          expect(result, equals(mockUser));
        },
      );

      testCase(
        'should return null when not authenticated',
        TestCategory.unit,
        () {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(null);

          // Act
          final result = dataSource.getCurrentUser();

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('authStateChanges', () {
      testCase('should return auth state stream', TestCategory.unit, () async {
        // Arrange
        final userStream = Stream<User?>.fromIterable([mockUser, null]);
        when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => userStream);

        // Act
        final stream = dataSource.authStateChanges();
        final users = await stream.take(2).toList();

        // Assert
        expect(users.length, equals(2));
        expect(users[0], equals(mockUser));
        expect(users[1], isNull);
      });
    });

    group('idTokenChanges', () {
      testCase(
        'should return id token changes stream',
        TestCategory.unit,
        () async {
          // Arrange
          final userStream = Stream<User?>.fromIterable([mockUser]);
          when(mockFirebaseAuth.idTokenChanges()).thenAnswer((_) => userStream);

          // Act
          final stream = dataSource.idTokenChanges();
          final user = await stream.first;

          // Assert
          expect(user, equals(mockUser));
        },
      );
    });
  });

  testGroup('Error Handling Edge Cases', TestCategory.unit, () {
    testCase(
      'should handle network timeout errors',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
            message: 'A network error has occurred.',
          ),
        );

        // Act
        final result = await dataSource.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.code, equals('network-request-failed'));
      },
    );

    testCase(
      'should handle too many requests error',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many unsuccessful login attempts.',
          ),
        );

        // Act
        final result = await dataSource.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull?.code, equals('too-many-requests'));
      },
    );
  });

  testGroup('Performance Tests', TestCategory.performance, () {
    testCase(
      'all auth operations should complete within 200ms threshold',
      TestCategory.performance,
      () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async => {});

        // Test sign in performance
        await TestExpectations.expectPerformant(() async {
          await dataSource.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password',
          );
        });

        // Test sign up performance
        await TestExpectations.expectPerformant(() async {
          await dataSource.createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password',
          );
        });

        // Test sign out performance
        await TestExpectations.expectPerformant(() async {
          await dataSource.signOut();
        });

        // Test password reset performance
        await TestExpectations.expectPerformant(() async {
          await dataSource.sendPasswordResetEmail(email: 'test@example.com');
        });
      },
    );
  });
}
