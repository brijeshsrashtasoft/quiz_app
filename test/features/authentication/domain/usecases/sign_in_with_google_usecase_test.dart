import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/base/base_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';

import 'sign_in_with_google_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('SignInWithGoogleUseCase', () {
    late SignInWithGoogleUseCase useCase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      useCase = SignInWithGoogleUseCase(authRepository: mockAuthRepository);
    });

    group('call', () {
      const testUser = UserEntity(
        id: 'test_id',
        name: 'John Doe',
        email: 'john.doe@gmail.com',
        createdAt: null,
        profileImageUrl: 'https://example.com/photo.jpg',
      );

      test('should return UserEntity when Google sign-in is successful', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.success(testUser));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, testUser);
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should return failure when repository returns auth failure', () async {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Google sign-in failed',
          code: 'google_signin_error',
        );
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull, failure);
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should return failure when repository returns network failure', () async {
        // Arrange
        const failure = Failure.networkFailure(
          message: 'No internet connection',
        );
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull, failure);
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should return failure when repository throws exception', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('Google sign in failed'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle user cancellation gracefully', () async {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Sign in cancelled',
          code: 'google_signin_cancelled',
        );
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('cancelled'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle account disabled error', () async {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Account has been disabled',
          code: 'user-disabled',
        );
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('disabled'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle email already in use error', () async {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Email already associated with another account',
          code: 'email-already-in-use',
        );
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase(NoParams());

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('already associated'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should measure performance and log timing', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.success(testUser));

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await useCase(NoParams());
        stopwatch.stop();

        // Assert
        expect(result.isSuccess, true);
        expect(stopwatch.elapsedMilliseconds, greaterThan(0));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle multiple concurrent calls', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Result.success(testUser));

        // Act
        final futures = List.generate(
          3,
          (_) => useCase(NoParams()),
        );
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result.isSuccess, true);
          expect(result.dataOrNull, testUser);
        }
        verify(mockAuthRepository.signInWithGoogle()).called(3);
      });
    });
  });
}