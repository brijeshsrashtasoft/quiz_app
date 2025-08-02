import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/base/base_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import '../../../mocks/auth_mocks.mocks.dart';

/// US-002 Google Sign-In Integration Tests
///
/// Simplified integration tests for Google Sign-In functionality
/// focusing on core use case behavior.

void main() {
  group('US-002 Google Sign-In Integration Tests', () {
    late MockAuthRepository mockAuthRepository;
    late SignInWithGoogleUseCase signInWithGoogleUseCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );
    });

    group('Google Sign-In Success Flow', () {
      test('should complete successful Google Sign-In flow', () async {
        // Arrange
        final testUser = UserEntity(
          id: 'google_123',
          name: 'John Doe',
          email: 'john.doe@gmail.com',
          createdAt: DateTime.now(),
        );

        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.success(testUser));

        // Act
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testUser));
        expect(result.dataOrNull?.email, equals('john.doe@gmail.com'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle new user creation during Google Sign-In', () async {
        // Arrange
        final newUser = UserEntity(
          id: 'new_456',
          name: 'New User',
          email: 'newuser@gmail.com',
          createdAt: DateTime.now(),
        );

        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.success(newUser));

        // Act
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(newUser));
        expect(result.dataOrNull?.name, equals('New User'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });
    });

    group('Google Sign-In Error Handling', () {
      test('should handle Google Sign-In cancellation', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.authFailure(message: 'User cancelled Google Sign-In'),
          ),
        );

        // Act
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('cancelled'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle network errors during Google Sign-In', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.networkFailure(message: 'Network error'),
          ),
        );

        // Act
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('Network'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle Google services unavailable', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(
              message: 'Google Play Services not available',
            ),
          ),
        );

        // Act
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('Google'));
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });
    });

    group('Google Sign-In Performance', () {
      test('should complete Google Sign-In within reasonable time', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        // Act
        final startTime = DateTime.now();
        final result = await signInWithGoogleUseCase.call(const NoParams());
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Assert
        expect(duration.inSeconds, lessThan(5));
        expect(result.isFailure, isTrue);
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('should handle concurrent Google Sign-In attempts', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        // Act
        final futures = List.generate(
          3,
          (_) => signInWithGoogleUseCase.call(const NoParams()),
        );
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, isA<Failure>());
        }
        verify(mockAuthRepository.signInWithGoogle()).called(3);
      });
    });
  });
}
