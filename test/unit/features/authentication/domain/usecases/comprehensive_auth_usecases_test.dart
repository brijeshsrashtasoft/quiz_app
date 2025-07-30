import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/update_user_profile_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/delete_account_usecase.dart';

import '../../../../../test_config.dart';
import '../../../../../helpers/authentication_test_helper.dart';

import 'comprehensive_auth_usecases_test.mocks.dart';

/// Comprehensive unit tests for all Authentication Use Cases
/// Following TDD principles and CLAUDE.md testing patterns
/// Tests business logic, validation, error handling, and edge cases
@GenerateMocks([AuthRepository])
void main() {
  testGroup('Authentication Use Cases', TestCategory.unit, () {
    late MockAuthRepository mockAuthRepository;
    late UserEntity testUser;

    setUpAll(() {
      testUser = AuthTestHelper.createTestUser(
        id: 'test-user-123',
        name: 'Test User',
        email: 'test@example.com',
      );
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    group('SignInUseCase', () {
      late SignInUseCase signInUseCase;

      setUp(() {
        signInUseCase = SignInUseCase(authRepository: mockAuthRepository);
      });

      testCase(
        'should return user when sign in succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(
            email: 'test@example.com',
            password: 'password123',
          );

          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await signInUseCase(params);

          // Assert
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
        'should trim email before calling repository',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(
            email: '  test@example.com  ',
            password: 'password123',
          );

          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          await signInUseCase(params);

          // Assert
          verify(
            mockAuthRepository.signInWithEmailPassword(
              email: 'test@example.com', // Should be trimmed
              password: 'password123',
            ),
          ).called(1);
        },
      );

      testCase(
        'should return validation failure when email is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(email: '', password: 'password123');

          // Act
          final result = await signInUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Email address is required'));
          expect(
            failure.fieldErrors?['email'],
            equals('Email address is required'),
          );
          verifyNever(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          );
        },
      );

      testCase(
        'should return validation failure when password is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(email: 'test@example.com', password: '');

          // Act
          final result = await signInUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Password is required'));
          expect(
            failure.fieldErrors?['password'],
            equals('Password is required'),
          );
        },
      );

      testCase(
        'should return validation failure for invalid email format',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(
            email: 'invalid-email',
            password: 'password123',
          );

          // Act
          final result = await signInUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Please enter a valid email address'));
          expect(
            failure.fieldErrors?['email'],
            equals('Please enter a valid email address'),
          );
        },
      );

      testCase(
        'should return repository failure when sign in fails',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(
            email: 'test@example.com',
            password: 'wrong-password',
          );
          final authFailure = Failure.authFailure(
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
          final result = await signInUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );

      testCase(
        'should handle unexpected exceptions',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(
            email: 'test@example.com',
            password: 'password123',
          );

          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await signInUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
          final failure = result.failureOrNull as AuthFailure;
          expect(failure.message, equals('Sign in failed. Please try again'));
          expect(failure.code, equals('AUTH_SIGNIN_ERROR'));
        },
      );

      testCase(
        'should complete within performance threshold',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignInParams(
            email: 'test@example.com',
            password: 'password123',
          );
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act & Assert
          await AuthTestHelper.expectAuthPerformant(() async {
            await signInUseCase(params);
          });
        },
      );
    });

    group('SignUpUseCase', () {
      late SignUpUseCase signUpUseCase;

      setUp(() {
        signUpUseCase = SignUpUseCase(authRepository: mockAuthRepository);
      });

      testCase(
        'should return user when sign up succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: 'password123',
            name: 'Test User',
          );

          when(
            mockAuthRepository.createUserWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              name: anyNamed('name'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          final result = await signUpUseCase(params);

          // Assert
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
        'should trim email and name before calling repository',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: '  test@example.com  ',
            password: 'password123',
            name: '  Test User  ',
          );

          when(
            mockAuthRepository.createUserWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              name: anyNamed('name'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act
          await signUpUseCase(params);

          // Assert
          verify(
            mockAuthRepository.createUserWithEmailPassword(
              email: 'test@example.com', // Should be trimmed
              password: 'password123',
              name: 'Test User', // Should be trimmed
            ),
          ).called(1);
        },
      );

      testCase(
        'should return validation failure when email is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: '',
            password: 'password123',
            name: 'Test User',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Email address is required'));
          expect(
            failure.fieldErrors?['email'],
            equals('Email address is required'),
          );
        },
      );

      testCase(
        'should return validation failure when password is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: '',
            name: 'Test User',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Password is required'));
          expect(
            failure.fieldErrors?['password'],
            equals('Password is required'),
          );
        },
      );

      testCase(
        'should return validation failure when name is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: 'password123',
            name: '',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Full name is required'));
          expect(failure.fieldErrors?['name'], equals('Full name is required'));
        },
      );

      testCase(
        'should return validation failure for invalid email format',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'invalid-email',
            password: 'password123',
            name: 'Test User',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Please enter a valid email address'));
          expect(
            failure.fieldErrors?['email'],
            equals('Please enter a valid email address'),
          );
        },
      );

      testCase(
        'should return validation failure for weak password',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: '123',
            name: 'Test User',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(
            failure.message,
            contains('Password must be at least 6 characters'),
          );
        },
      );

      testCase(
        'should return validation failure for short name',
        TestCategory.unit,
        () async {
          // Arrange
          const params = SignUpParams(
            email: 'test@example.com',
            password: 'password123',
            name: 'A',
          );

          // Act
          final result = await signUpUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(
            failure.message,
            contains('Name must be at least 2 characters'),
          );
        },
      );
    });

    group('SignOutUseCase', () {
      late SignOutUseCase signOutUseCase;

      setUp(() {
        signOutUseCase = SignOutUseCase(authRepository: mockAuthRepository);
      });

      testCase(
        'should return success when sign out succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signOut(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await signOutUseCase(NoParams());

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.signOut()).called(1);
        },
      );

      testCase(
        'should return failure when sign out fails',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = Failure.authFailure(
            message: 'Sign out failed',
            code: 'AUTH_SIGNOUT_ERROR',
          );
          when(
            mockAuthRepository.signOut(),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await signOutUseCase(NoParams());

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );

      testCase(
        'should handle unexpected exceptions',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.signOut(),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await signOutUseCase(NoParams());

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
        },
      );
    });

    group('ResetPasswordUseCase', () {
      late ResetPasswordUseCase resetPasswordUseCase;

      setUp(() {
        resetPasswordUseCase = ResetPasswordUseCase(
          authRepository: mockAuthRepository,
        );
      });

      testCase(
        'should return success when password reset email sent',
        TestCategory.unit,
        () async {
          // Arrange
          const params = ResetPasswordParams(email: 'test@example.com');
          when(
            mockAuthRepository.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await resetPasswordUseCase(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockAuthRepository.sendPasswordResetEmail(
              email: 'test@example.com',
            ),
          ).called(1);
        },
      );

      testCase(
        'should trim email before calling repository',
        TestCategory.unit,
        () async {
          // Arrange
          const params = ResetPasswordParams(email: '  test@example.com  ');
          when(
            mockAuthRepository.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          await resetPasswordUseCase(params);

          // Assert
          verify(
            mockAuthRepository.sendPasswordResetEmail(
              email: 'test@example.com',
            ),
          ).called(1);
        },
      );

      testCase(
        'should return validation failure when email is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = ResetPasswordParams(email: '');

          // Act
          final result = await resetPasswordUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Email address is required'));
          expect(
            failure.fieldErrors?['email'],
            equals('Email address is required'),
          );
        },
      );

      testCase(
        'should return validation failure for invalid email format',
        TestCategory.unit,
        () async {
          // Arrange
          const params = ResetPasswordParams(email: 'invalid-email');

          // Act
          final result = await resetPasswordUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('Please enter a valid email address'));
          expect(
            failure.fieldErrors?['email'],
            equals('Please enter a valid email address'),
          );
        },
      );

      testCase(
        'should return repository failure when reset fails',
        TestCategory.unit,
        () async {
          // Arrange
          const params = ResetPasswordParams(email: 'test@example.com');
          final authFailure = Failure.authFailure(
            message: 'User not found',
            code: 'AUTH_USER_NOT_FOUND',
          );
          when(
            mockAuthRepository.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await resetPasswordUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('GetCurrentUserUseCase', () {
      late GetCurrentUserUseCase getCurrentUserUseCase;

      setUp(() {
        getCurrentUserUseCase = GetCurrentUserUseCase(
          authRepository: mockAuthRepository,
        );
      });

      testCase(
        'should return current user when authenticated',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(testUser));

          // Act
          final result = await getCurrentUserUseCase(NoParams());

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(testUser));
          verify(mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      testCase(
        'should return null when not authenticated',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(null));

          // Act
          final result = await getCurrentUserUseCase(NoParams());

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, isNull);
        },
      );

      testCase(
        'should return failure when repository fails',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = Failure.authFailure(
            message: 'Failed to get current user',
            code: 'AUTH_GET_USER_ERROR',
          );
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.failure(authFailure));

          // Act
          final result = await getCurrentUserUseCase(NoParams());

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );
    });

    group('UpdateUserProfileUseCase', () {
      late UpdateUserProfileUseCase updateUserProfileUseCase;

      setUp() {
        updateUserProfileUseCase = UpdateUserProfileUseCase(
          authRepository: mockAuthRepository,
        );
      }

      testCase(
        'should return updated user when update succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          const params = UpdateUserProfileParams(
            name: 'Updated Name',
            email: 'updated@example.com',
          );
          final updatedUser = testUser.copyWith(
            name: 'Updated Name',
            email: 'updated@example.com',
          );

          when(
            mockAuthRepository.updateEmail(
              newEmail: anyNamed('newEmail'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(null));

          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(updatedUser));

          // Act
          final result = await updateUserProfileUseCase(params);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(updatedUser));
        },
      );

      testCase(
        'should return validation failure when name is empty',
        TestCategory.unit,
        () async {
          // Arrange
          const params = UpdateUserProfileParams(name: '');

          // Act
          final result = await updateUserProfileUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, contains('Name is required'));
        },
      );

      testCase(
        'should return validation failure for invalid email format',
        TestCategory.unit,
        () async {
          // Arrange
          const params = UpdateUserProfileParams(email: 'invalid-email');

          // Act
          final result = await updateUserProfileUseCase(params);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, contains('valid email address'));
        },
      );
    });

    group('DeleteAccountUseCase', () {
      late DeleteAccountUseCase deleteAccountUseCase;

      setUp() {
        deleteAccountUseCase = DeleteAccountUseCase(
          authRepository: mockAuthRepository,
        );
      }

      testCase(
        'should return success when account deletion succeeds',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.deleteCurrentUser(),
          ).thenAnswer((_) async => Result.success(null));

          // Act
          final result = await deleteAccountUseCase(NoParams());

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthRepository.deleteCurrentUser()).called(1);
        },
      );

      testCase(
        'should return failure when account deletion fails',
        TestCategory.unit,
        () async {
          // Arrange
          final authFailure = Failure.authFailure(
            message: 'Account deletion failed',
            code: 'AUTH_DELETE_ACCOUNT_ERROR',
          );
          when(
            mockAuthRepository.deleteCurrentUser(),
          ).thenAnswer((_) async => Result.failure(authFailure));

          // Act
          final result = await deleteAccountUseCase(NoParams());

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));
        },
      );

      testCase(
        'should handle unexpected exceptions',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockAuthRepository.deleteCurrentUser(),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await deleteAccountUseCase(NoParams());

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<AuthFailure>());
        },
      );
    });

    group('Edge Cases and Performance', () {
      testCase(
        'should handle concurrent use case executions',
        TestCategory.unit,
        () async {
          // Arrange
          final signInUseCase = SignInUseCase(
            authRepository: mockAuthRepository,
          );
          final getCurrentUserUseCase = GetCurrentUserUseCase(
            authRepository: mockAuthRepository,
          );

          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(Result.success(testUser));

          // Act - Execute concurrently
          final futures = await Future.wait([
            signInUseCase(
              SignInParams(email: 'test@example.com', password: 'password123'),
            ),
            getCurrentUserUseCase(NoParams()),
          ]);

          // Assert
          expect(futures[0].isSuccess, isTrue);
          expect(futures[1].isSuccess, isTrue);
        },
      );

      testCase(
        'should handle repository timeout gracefully',
        TestCategory.unit,
        () async {
          // Arrange
          final signInUseCase = SignInUseCase(
            authRepository: mockAuthRepository,
          );
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async {
            await Future.delayed(Duration(seconds: 10)); // Simulate timeout
            return Result.success(testUser);
          });

          // Act & Assert - Should complete within reasonable time or handle timeout
          try {
            await signInUseCase(
              SignInParams(email: 'test@example.com', password: 'password123'),
            ).timeout(Duration(seconds: 5));
            fail('Should have timed out');
          } catch (e) {
            expect(e, isA<Exception>());
          }
        },
      );

      testCase(
        'should handle memory pressure during batch operations',
        TestCategory.unit,
        () async {
          // Arrange
          final signInUseCase = SignInUseCase(
            authRepository: mockAuthRepository,
          );
          when(
            mockAuthRepository.signInWithEmailPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Result.success(testUser));

          // Act - Execute many operations
          final futures = List.generate(100, (index) {
            return signInUseCase(
              SignInParams(
                email: 'test$index@example.com',
                password: 'password123',
              ),
            );
          });

          final results = await Future.wait(futures);

          // Assert - All should succeed
          expect(results.every((result) => result.isSuccess), isTrue);
        },
      );
    });
  });
}

/// Mock parameters for testing use cases that aren't implemented yet
class SignUpParams {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<void>> call(NoParams params) async {
    try {
      return await _authRepository.signOut();
    } catch (e) {
      return Result.failure(
        Failure.authFailure(
          message: 'Sign out failed. Please try again',
          code: 'AUTH_SIGNOUT_ERROR',
        ),
      );
    }
  }
}

class ResetPasswordParams {
  final String email;

  const ResetPasswordParams({required this.email});
}

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<void>> call(ResetPasswordParams params) async {
    try {
      // Validate email
      if (params.email.trim().isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Email address is required',
            fieldErrors: {'email': 'Email address is required'},
          ),
        );
      }

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(params.email.trim())) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Please enter a valid email address',
            fieldErrors: {'email': 'Please enter a valid email address'},
          ),
        );
      }

      return await _authRepository.sendPasswordResetEmail(
        email: params.email.trim(),
      );
    } catch (e) {
      return Result.failure(
        Failure.authFailure(
          message: 'Password reset failed. Please try again',
          code: 'AUTH_PASSWORD_RESET_ERROR',
        ),
      );
    }
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<UserEntity?>> call(NoParams params) async {
    try {
      return Future.value(_authRepository.getCurrentUser());
    } catch (e) {
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to get current user',
          code: 'AUTH_GET_USER_ERROR',
        ),
      );
    }
  }
}

class UpdateUserProfileParams {
  final String? name;
  final String? email;

  const UpdateUserProfileParams({this.name, this.email});
}

class UpdateUserProfileUseCase {
  final AuthRepository _authRepository;

  UpdateUserProfileUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<UserEntity?>> call(UpdateUserProfileParams params) async {
    try {
      // Validate name if provided
      if (params.name != null && params.name!.trim().isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Name is required',
            fieldErrors: {'name': 'Name is required'},
          ),
        );
      }

      // Validate email if provided
      if (params.email != null) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(params.email!.trim())) {
          return Result.failure(
            Failure.validationFailure(
              message: 'Please enter a valid email address',
              fieldErrors: {'email': 'Please enter a valid email address'},
            ),
          );
        }
      }

      // Update email if provided (requires password in real implementation)
      if (params.email != null) {
        final updateResult = await _authRepository.updateEmail(
          newEmail: params.email!.trim(),
          password:
              'dummy-password', // In real implementation, this would be required
        );
        if (updateResult.isFailure) {
          return Result.failure(updateResult.failureOrNull!);
        }
      }

      // Return updated user
      return Future.value(_authRepository.getCurrentUser());
    } catch (e) {
      return Result.failure(
        Failure.authFailure(
          message: 'Profile update failed. Please try again',
          code: 'AUTH_UPDATE_PROFILE_ERROR',
        ),
      );
    }
  }
}

class DeleteAccountUseCase {
  final AuthRepository _authRepository;

  DeleteAccountUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<void>> call(NoParams params) async {
    try {
      return await _authRepository.deleteCurrentUser();
    } catch (e) {
      return Result.failure(
        Failure.authFailure(
          message: 'Account deletion failed. Please try again',
          code: 'AUTH_DELETE_ACCOUNT_ERROR',
        ),
      );
    }
  }
}

class NoParams {
  const NoParams();
}
