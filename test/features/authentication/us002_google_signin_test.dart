import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/base/base_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import '../../mocks/auth_mocks.dart';
import '../../mocks/auth_mocks.mocks.dart';

/// US-002 Google Sign-In Flow Tests
///
/// Comprehensive tests for the Google Sign-In functionality
/// covering the core requirements specified in US-002.

void main() {
  group('US-002 Google Sign-In Flow', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    group('1. Google Sign-In Use Case Logic', () {
      late SignInWithGoogleUseCase signInWithGoogleUseCase;

      setUp(() {
        signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );
      });

      test('should create SignInWithGoogleUseCase successfully', () {
        expect(signInWithGoogleUseCase, isNotNull);
        expect(signInWithGoogleUseCase, isA<SignInWithGoogleUseCase>());
      });

      test('should handle Google Sign-In parameters correctly', () async {
        // Setup mock to return failure (simulating Firebase not configured)
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        // Test with NoParams (Google Sign-In doesn't require additional params)
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // This will fail due to Firebase not being set up, but validates use case structure
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
      });

      test('should validate use case call with NoParams', () async {
        // Setup mock to return failure
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        // NoParams should be accepted by the use case
        const params = NoParams();
        expect(params, isNotNull);
        expect(params, isA<NoParams>());

        // Use case should accept NoParams without validation errors
        final result = await signInWithGoogleUseCase.call(params);

        // Result should be a failure due to Firebase not being configured
        expect(result, isA<Result<UserEntity>>());
        expect(result.isFailure, isTrue);
      });

      test('should handle network connectivity issues', () async {
        // Setup mock to return network failure
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.networkFailure(message: 'No internet connection'),
          ),
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('internet'));
      });

      test('should handle authentication service unavailable', () async {
        // Setup mock to return service failure
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Google services unavailable'),
          ),
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, isNotEmpty);
      });
    });

    group('2. Google Sign-In Success Scenarios', () {
      test('should handle successful Google Sign-In', () async {
        // Setup mock to return success
        final testUser = UserEntity(
          id: 'google_123',
          name: 'John Doe',
          email: 'john.doe@gmail.com',
          createdAt: DateTime.now(),
        );

        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.success(testUser));

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testUser));
        expect(result.dataOrNull?.email, equals('john.doe@gmail.com'));
      });

      test('should validate successful sign-in data structure', () async {
        // Setup mock to return success with user data
        final testUser = UserEntity(
          id: 'google_456',
          name: 'Jane Smith',
          email: 'jane.smith@gmail.com',
          createdAt: DateTime.now(),
        );

        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Result.success(testUser));

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Validate successful result structure
        expect(result, isA<Result<UserEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNotNull);
        expect(result.dataOrNull?.id, equals('google_456'));
        expect(result.dataOrNull?.name, equals('Jane Smith'));
        expect(result.dataOrNull?.email, equals('jane.smith@gmail.com'));
      });
    });

    group('3. Google Sign-In Error Handling', () {
      test('should handle user cancellation gracefully', () async {
        // Setup mock to simulate user cancellation
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.authFailure(message: 'User cancelled Google Sign-In'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('cancelled'));
      });

      test('should handle Google services not available', () async {
        // Setup mock to simulate Google services unavailable
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(
              message: 'Google Play Services not available',
            ),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('Google'));
      });

      test('should handle network timeout scenarios', () async {
        // Setup mock to simulate timeout
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.networkFailure(message: 'Request timed out'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, contains('timed out'));
      });
    });

    group('4. Google Sign-In Parameters and Configuration', () {
      test('should use NoParams correctly', () {
        const params = NoParams();

        expect(params, isNotNull);
        expect(params, isA<NoParams>());
        expect(params.toString(), contains('NoParams'));
      });

      test('should validate use case dependency injection', () {
        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        expect(signInWithGoogleUseCase, isNotNull);
        expect(
          signInWithGoogleUseCase.runtimeType.toString(),
          contains('SignInWithGoogleUseCase'),
        );
      });

      test('should handle concurrent sign-in attempts', () async {
        // Setup mock to return failure for all attempts
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        // Test multiple concurrent calls
        final futures = List.generate(
          3,
          (_) => signInWithGoogleUseCase.call(const NoParams()),
        );
        final results = await Future.wait(futures);

        for (final result in results) {
          expect(result, isA<Result<UserEntity>>());
          expect(result.isFailure, isTrue);
        }
      });
    });

    group('5. Google Sign-In Performance Tests', () {
      test('should complete sign-in attempt within reasonable time', () async {
        // Setup mock to return failure quickly
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final startTime = DateTime.now();
        final result = await signInWithGoogleUseCase.call(const NoParams());
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete within reasonable time (including failure cases)
        expect(duration.inSeconds, lessThan(5));
        expect(result.isFailure, isTrue);
      });

      test(
        'should handle multiple sequential sign-in attempts efficiently',
        () async {
          // Setup mock to return failure for all attempts
          when(mockAuthRepository.signInWithGoogle()).thenAnswer(
            (_) async => Result.failure(
              const Failure.serverFailure(message: 'Firebase not configured'),
            ),
          );

          final signInWithGoogleUseCase = SignInWithGoogleUseCase(
            authRepository: mockAuthRepository,
          );

          final startTime = DateTime.now();

          // Perform 5 sequential sign-in attempts
          for (int i = 0; i < 5; i++) {
            final result = await signInWithGoogleUseCase.call(const NoParams());
            expect(result.isFailure, isTrue);
          }

          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);

          // Should complete all attempts within reasonable time
          expect(duration.inSeconds, lessThan(10));
        },
      );
    });

    group('6. Google Sign-In Integration Scenarios', () {
      test('should validate complete Google Sign-In flow structure', () async {
        // Setup mock to return failure
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        // Test the complete flow structure
        final result = await signInWithGoogleUseCase.call(const NoParams());

        // Validate flow structure even when failing
        expect(result, isA<Result<UserEntity>>());
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
        expect(result.failureOrNull?.message, isNotNull);
      });

      test('should validate use case integration with repositories', () async {
        // Setup mock to return failure
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Repository integration test'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result, isA<Result<UserEntity>>());
        expect(result.isFailure, isTrue);

        // Verify repository was called
        verify(mockAuthRepository.signInWithGoogle()).called(1);
      });
    });
  });
}
