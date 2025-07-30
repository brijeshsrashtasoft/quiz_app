import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/send_password_reset_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/update_user_profile_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/delete_user_account_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/send_email_verification_usecase.dart';
import '../../../../../test_config.dart';

import 'auth_usecases_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  // Test data
  final testAuthUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: null,
  );

  final testAuthEntity = AuthEntity(
    user: testAuthUser,
    isEmailVerified: true,
    lastSignInTime: DateTime.now(),
    creationTime: DateTime.now(),
  );

  testGroup('Sign In With Email Use Case', TestCategory.unit, () {
    late SignInWithEmailUseCase useCase;

    setUp(() {
      useCase = SignInWithEmailUseCase(repository: mockRepository);
    });

    testCase(
      'should return AuthEntity when sign in succeeds',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'testpassword123';
        when(
          mockRepository.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.success(testAuthEntity));

        // Act
        final result = await useCase(
          SignInWithEmailParams(email: email, password: password),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testAuthEntity));
        verify(
          mockRepository.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      },
    );

    testCase(
      'should return Failure when sign in fails',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        final failure = AuthFailure(
          message: 'Wrong password',
          code: 'wrong-password',
        );
        when(
          mockRepository.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(
          SignInWithEmailParams(email: email, password: password),
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );

    testCase('should validate email format', TestCategory.unit, () async {
      // Arrange
      const invalidEmail = 'invalid-email';
      const password = 'testpassword123';

      // Act
      final result = await useCase(
        SignInWithEmailParams(email: invalidEmail, password: password),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.code, equals('invalid-email'));
      verifyNever(
        mockRepository.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    testCase('should validate password length', TestCategory.unit, () async {
      // Arrange
      const email = 'test@example.com';
      const shortPassword = '123';

      // Act
      final result = await useCase(
        SignInWithEmailParams(email: email, password: shortPassword),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.code, equals('weak-password'));
    });

    testCase(
      'should complete within performance threshold',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'testpassword123';
        when(
          mockRepository.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.success(testAuthEntity));

        // Act & Assert
        await TestExpectations.expectPerformant(() async {
          await useCase(
            SignInWithEmailParams(email: email, password: password),
          );
        });
      },
    );
  });

  testGroup('Sign Up With Email Use Case', TestCategory.unit, () {
    late SignUpWithEmailUseCase useCase;

    setUp(() {
      useCase = SignUpWithEmailUseCase(repository: mockRepository);
    });

    testCase(
      'should return AuthEntity when sign up succeeds',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'newpassword123';
        const displayName = 'New User';
        when(
          mockRepository.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.success(testAuthEntity));

        // Act
        final result = await useCase(
          SignUpWithEmailParams(
            email: email,
            password: password,
            displayName: displayName,
          ),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testAuthEntity));
        verify(
          mockRepository.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      },
    );

    testCase(
      'should return Failure when email already exists',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        final failure = AuthFailure(
          message: 'Email already in use',
          code: 'email-already-in-use',
        );
        when(
          mockRepository.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(
          SignUpWithEmailParams(email: email, password: password),
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );

    testCase('should validate password strength', TestCategory.unit, () async {
      // Arrange
      const email = 'test@example.com';
      const weakPassword = '123';

      // Act
      final result = await useCase(
        SignUpWithEmailParams(email: email, password: weakPassword),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.code, equals('weak-password'));
    });
  });

  testGroup('Sign In With Google Use Case', TestCategory.unit, () {
    late SignInWithGoogleUseCase useCase;

    setUp(() {
      useCase = SignInWithGoogleUseCase(repository: mockRepository);
    });

    testCase(
      'should return AuthEntity when Google sign in succeeds',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.success(testAuthEntity));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testAuthEntity));
        verify(mockRepository.signInWithGoogle()).called(1);
      },
    );

    testCase(
      'should return Failure when Google sign in is cancelled',
      TestCategory.unit,
      () async {
        // Arrange
        final failure = AuthFailure(
          message: 'Google sign in cancelled',
          code: 'sign_in_cancelled',
        );
        when(
          mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );

    testCase(
      'should complete within performance threshold',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.success(testAuthEntity));

        // Act & Assert
        await TestExpectations.expectPerformant(() async {
          await useCase(NoParams());
        });
      },
    );
  });

  testGroup('Sign Out Use Case', TestCategory.unit, () {
    late SignOutUseCase useCase;

    setUp(() {
      useCase = SignOutUseCase(repository: mockRepository);
    });

    testCase(
      'should return success when sign out succeeds',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockRepository.signOut(),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockRepository.signOut()).called(1);
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
          mockRepository.signOut(),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );
  });

  testGroup('Send Password Reset Use Case', TestCategory.unit, () {
    late SendPasswordResetUseCase useCase;

    setUp(() {
      useCase = SendPasswordResetUseCase(repository: mockRepository);
    });

    testCase(
      'should return success when password reset email is sent',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'test@example.com';
        when(
          mockRepository.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await useCase(SendPasswordResetParams(email: email));

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockRepository.sendPasswordResetEmail(email: email)).called(1);
      },
    );

    testCase(
      'should return Failure when user not found',
      TestCategory.unit,
      () async {
        // Arrange
        const email = 'nonexistent@example.com';
        final failure = AuthFailure(
          message: 'User not found',
          code: 'user-not-found',
        );
        when(
          mockRepository.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(SendPasswordResetParams(email: email));

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );

    testCase('should validate email format', TestCategory.unit, () async {
      // Arrange
      const invalidEmail = 'invalid-email';

      // Act
      final result = await useCase(
        SendPasswordResetParams(email: invalidEmail),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.code, equals('invalid-email'));
    });
  });

  testGroup('Update User Profile Use Case', TestCategory.unit, () {
    late UpdateUserProfileUseCase useCase;

    setUp(() {
      useCase = UpdateUserProfileUseCase(repository: mockRepository);
    });

    testCase(
      'should return success when profile update succeeds',
      TestCategory.unit,
      () async {
        // Arrange
        const displayName = 'Updated Name';
        const photoURL = 'https://example.com/photo.jpg';
        when(
          mockRepository.updateUserProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
          ),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await useCase(
          UpdateUserProfileParams(displayName: displayName, photoURL: photoURL),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(
          mockRepository.updateUserProfile(
            displayName: displayName,
            photoURL: photoURL,
          ),
        ).called(1);
      },
    );

    testCase(
      'should return Failure when no current user',
      TestCategory.unit,
      () async {
        // Arrange
        const displayName = 'Updated Name';
        final failure = AuthFailure(
          message: 'No current user',
          code: 'no-current-user',
        );
        when(
          mockRepository.updateUserProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
          ),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(
          UpdateUserProfileParams(displayName: displayName),
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );

    testCase(
      'should validate display name length',
      TestCategory.unit,
      () async {
        // Arrange
        const tooLongName = 'a' * 101; // Assuming 100 char limit

        // Act
        final result = await useCase(
          UpdateUserProfileParams(displayName: tooLongName),
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        expect(result.failureOrNull?.code, equals('invalid-display-name'));
      },
    );
  });

  testGroup('Delete User Account Use Case', TestCategory.unit, () {
    late DeleteUserAccountUseCase useCase;

    setUp(() {
      useCase = DeleteUserAccountUseCase(repository: mockRepository);
    });

    testCase(
      'should return success when account deletion succeeds',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockRepository.deleteUserAccount(),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockRepository.deleteUserAccount()).called(1);
      },
    );

    testCase(
      'should return Failure when requires recent login',
      TestCategory.unit,
      () async {
        // Arrange
        final failure = AuthFailure(
          message: 'Requires recent login',
          code: 'requires-recent-login',
        );
        when(
          mockRepository.deleteUserAccount(),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );
  });

  testGroup('Send Email Verification Use Case', TestCategory.unit, () {
    late SendEmailVerificationUseCase useCase;

    setUp(() {
      useCase = SendEmailVerificationUseCase(repository: mockRepository);
    });

    testCase(
      'should return success when email verification is sent',
      TestCategory.unit,
      () async {
        // Arrange
        when(
          mockRepository.sendEmailVerification(),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockRepository.sendEmailVerification()).called(1);
      },
    );

    testCase(
      'should return Failure when email already verified',
      TestCategory.unit,
      () async {
        // Arrange
        final failure = AuthFailure(
          message: 'Email already verified',
          code: 'email-already-verified',
        );
        when(
          mockRepository.sendEmailVerification(),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, equals(failure));
      },
    );
  });

  testGroup('Business Logic Validation Tests', TestCategory.unit, () {
    testCase('should validate email format correctly', TestCategory.unit, () {
      // Valid emails
      expect(_isValidEmail('test@example.com'), isTrue);
      expect(_isValidEmail('user.name+tag@domain.co.uk'), isTrue);
      expect(_isValidEmail('valid_email@subdomain.domain.com'), isTrue);

      // Invalid emails
      expect(_isValidEmail('invalid-email'), isFalse);
      expect(_isValidEmail('missing@.com'), isFalse);
      expect(_isValidEmail('@missinglocal.com'), isFalse);
      expect(_isValidEmail('spaces @domain.com'), isFalse);
      expect(_isValidEmail(''), isFalse);
    });

    testCase(
      'should validate password strength correctly',
      TestCategory.unit,
      () {
        // Valid passwords
        expect(_isValidPassword('StrongPass123!'), isTrue);
        expect(_isValidPassword('mypassword123'), isTrue);
        expect(_isValidPassword('PASSWORD123'), isTrue);
        expect(_isValidPassword('12345678'), isTrue);

        // Invalid passwords
        expect(_isValidPassword('weak'), isFalse);
        expect(_isValidPassword('1234567'), isFalse);
        expect(_isValidPassword(''), isFalse);
      },
    );

    testCase('should validate display name correctly', TestCategory.unit, () {
      // Valid names
      expect(_isValidDisplayName('John Doe'), isTrue);
      expect(_isValidDisplayName('Single'), isTrue);
      expect(_isValidDisplayName('Name with spaces'), isTrue);
      expect(_isValidDisplayName('Unicode-éñ'), isTrue);

      // Invalid names
      expect(_isValidDisplayName(''), isFalse);
      expect(_isValidDisplayName('a' * 101), isFalse); // Too long
      expect(_isValidDisplayName('   '), isFalse); // Only spaces
    });
  });
}

/// Email validation helper
bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return emailRegex.hasMatch(email);
}

/// Password validation helper (minimum 8 characters)
bool _isValidPassword(String password) {
  return password.length >= 8;
}

/// Display name validation helper
bool _isValidDisplayName(String displayName) {
  return displayName.trim().isNotEmpty && displayName.length <= 100;
}
