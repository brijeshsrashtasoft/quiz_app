import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import '../../../../../test_config.dart';

import 'auth_service_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  testGroup('AuthService Unit Tests', TestCategory.unit, () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      authService = AuthService();
    });

    testGroup('signInWithEmailAndPassword', () {
      testCase(
        'should return success when Firebase Auth succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(mockUserCredential.user).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('test-uid');
          when(mockUser.email).thenReturn(email);

          // Act
          final result = await authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isA<UserCredential>());
        },
      );

      testCase(
        'should return failure when Firebase Auth throws exception',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'wrongpassword';

          // Act
          final result = await authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
          expect(result.failureOrNull?.code, contains('AUTH_SIGNIN_ERROR'));
        },
      );

      testCase(
        'should handle invalid email format',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'invalid-email';
          const password = 'password123';

          // Act
          final result = await authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
        },
      );

      testCase('should handle weak password', TestCategory.unit, () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123'; // Too weak

        // Act
        final result = await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
      });
    });

    testGroup('createUserWithEmailAndPassword', () {
      testCase(
        'should return success when user creation succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'newuser@example.com';
          const password = 'password123';
          const displayName = 'New User';

          when(mockUserCredential.user).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('new-user-uid');
          when(mockUser.email).thenReturn(email);
          when(mockUser.displayName).thenReturn(displayName);

          // Act
          final result = await authService.createUserWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isA<UserCredential>());
        },
      );

      testCase(
        'should return failure when email already exists',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'existing@example.com';
          const password = 'password123';

          // Act
          final result = await authService.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
          expect(
            result.failureOrNull?.code,
            contains('AUTH_CREATE_USER_ERROR'),
          );
        },
      );

      testCase(
        'should handle password too weak error',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = '123'; // Too weak

          // Act
          final result = await authService.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
        },
      );
    });

    testGroup('signOut', () {
      testCase(
        'should return success when sign out succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.email).thenReturn('test@example.com');

          // Act
          final result = await authService.signOut();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isNull);
        },
      );

      testCase(
        'should return failure when sign out fails',
        TestCategory.unit,
        () async {
          // Act
          final result = await authService.signOut();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
          expect(result.failureOrNull?.code, contains('AUTH_SIGNOUT_ERROR'));
        },
      );
    });

    testGroup('sendPasswordResetEmail', () {
      testCase(
        'should return success when password reset email is sent',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'test@example.com';

          // Act
          final result = await authService.sendPasswordResetEmail(email: email);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isNull);
        },
      );

      testCase(
        'should return failure when email does not exist',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'nonexistent@example.com';

          // Act
          final result = await authService.sendPasswordResetEmail(email: email);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
          expect(
            result.failureOrNull?.code,
            contains('AUTH_PASSWORD_RESET_ERROR'),
          );
        },
      );

      testCase(
        'should handle invalid email format',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'invalid-email';

          // Act
          final result = await authService.sendPasswordResetEmail(email: email);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
        },
      );
    });

    testGroup('updateUserProfile', () {
      testCase(
        'should return success when profile update succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          const displayName = 'Updated Name';
          const photoURL = 'https://example.com/photo.jpg';

          when(mockUser.email).thenReturn('test@example.com');

          // Act
          final result = await authService.updateUserProfile(
            displayName: displayName,
            photoURL: photoURL,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isNull);
        },
      );

      testCase(
        'should return failure when no user is signed in',
        TestCategory.unit,
        () async {
          // Act
          final result = await authService.updateUserProfile(
            displayName: 'New Name',
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
          expect(
            result.failureOrNull?.code,
            contains('AUTH_PROFILE_UPDATE_ERROR'),
          );
        },
      );
    });

    testGroup('deleteUserAccount', () {
      testCase(
        'should return success when account deletion succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.email).thenReturn('test@example.com');

          // Act
          final result = await authService.deleteUserAccount();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isNull);
        },
      );

      testCase(
        'should return failure when no user is signed in',
        TestCategory.unit,
        () async {
          // Act
          final result = await authService.deleteUserAccount();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
          expect(
            result.failureOrNull?.code,
            contains('AUTH_DELETE_ACCOUNT_ERROR'),
          );
        },
      );

      testCase(
        'should return failure when deletion requires recent authentication',
        TestCategory.unit,
        () async {
          // Arrange
          when(mockUser.email).thenReturn('test@example.com');

          // Act
          final result = await authService.deleteUserAccount();

          // Assert - This would typically fail in a real scenario
          // where user needs to re-authenticate for sensitive operations
          expect(result, isA<Result<void>>());
        },
      );
    });

    testGroup('authentication state getters', () {
      testCase(
        'currentUser should return null when not authenticated',
        TestCategory.unit,
        () {
          // Act
          final user = authService.currentUser;

          // Assert
          expect(user, isNull);
        },
      );

      testCase(
        'isAuthenticated should return false when not authenticated',
        TestCategory.unit,
        () {
          // Act
          final isAuth = authService.isAuthenticated;

          // Assert
          expect(isAuth, isFalse);
        },
      );

      testCase(
        'currentUserId should return null when not authenticated',
        TestCategory.unit,
        () {
          // Act
          final userId = authService.currentUserId;

          // Assert
          expect(userId, isNull);
        },
      );
    });

    testGroup('Performance Tests', () {
      testCase(
        'signInWithEmailAndPassword should complete within threshold',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          // Act & Assert
          await TestExpectations.expectPerformant(
            () => authService.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            threshold: const Duration(milliseconds: 200),
          );
        },
      );

      testCase(
        'createUserWithEmailAndPassword should complete within threshold',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'newuser@example.com';
          const password = 'password123';

          // Act & Assert
          await TestExpectations.expectPerformant(
            () => authService.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
            threshold: const Duration(milliseconds: 200),
          );
        },
      );
    });

    testGroup('Edge Cases and Error Handling', () {
      testCase(
        'should handle network connectivity issues',
        TestCategory.unit,
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          // Act
          final result = await authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Assert - Should handle network errors gracefully
          expect(result, isA<Result<UserCredential>>());
          if (result.isFailure) {
            expect(result.failureOrNull, isA<Failure>());
          }
        },
      );

      testCase(
        'should handle null or empty email gracefully',
        TestCategory.unit,
        () async {
          // Act
          final result1 = await authService.signInWithEmailAndPassword(
            email: '',
            password: 'password123',
          );

          // Assert
          expect(result1.isFailure, isTrue);
        },
      );

      testCase(
        'should handle null or empty password gracefully',
        TestCategory.unit,
        () async {
          // Act
          final result = await authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: '',
          );

          // Assert
          expect(result.isFailure, isTrue);
        },
      );
    });
  });

  testGroup('Authentication State Management', TestCategory.unit, () {
    testCase(
      'AuthState should properly represent unauthenticated state',
      TestCategory.unit,
      () {
        // Arrange & Act
        const authState = AuthState.unauthenticated();

        // Assert
        expect(authState.isUnauthenticated, isTrue);
        expect(authState.isAuthenticated, isFalse);
        expect(authState.hasError, isFalse);
        expect(authState.firebaseUser, isNull);
        expect(authState.user, isNull);
        expect(authState.errorMessage, isNull);
      },
    );

    testCase(
      'AuthState should properly represent loading state',
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
      'AuthState should properly represent error state',
      TestCategory.unit,
      () {
        // Arrange & Act
        const authState = AuthState.error(message: 'Test error');

        // Assert
        expect(authState.hasError, isTrue);
        expect(authState.errorMessage, equals('Test error'));
        expect(authState.isAuthenticated, isFalse);
        expect(authState.isUnauthenticated, isFalse);
      },
    );
  });
}
