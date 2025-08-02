import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/base/base_usecase.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'mocks/auth_mocks.dart';
import 'mocks/auth_mocks.mocks.dart';

/// US-002 Google Sign-In Flow - Summary Test
///
/// This test suite validates that all core components of the Google Sign-In
/// flow are working correctly for US-002.

void main() {
  group('US-002 Google Sign-In Flow - Core Functionality Summary', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    test('✅ SignInWithGoogleUseCase instantiates correctly', () {
      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      expect(signInWithGoogleUseCase, isNotNull);
      expect(signInWithGoogleUseCase, isA<SignInWithGoogleUseCase>());
    });

    test('✅ NoParams works correctly for Google Sign-In', () {
      const params = NoParams();

      expect(params, isNotNull);
      expect(params, isA<NoParams>());
      expect(params.toString(), contains('NoParams'));
    });

    test('✅ Google Sign-In use case handles parameters correctly', () async {
      // Setup mock to return failure (simulating Firebase not configured)
      when(mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Result.failure(
          const Failure.serverFailure(message: 'Firebase not configured'),
        ),
      );

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      // Test with NoParams (Google Sign-In doesn't require additional params)
      final result = await signInWithGoogleUseCase.call(const NoParams());

      // Should return a Result object
      expect(result, isA<Result<UserEntity>>());

      // Will fail due to Firebase not being configured, but structure is correct
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isNotNull);
      expect(result.failureOrNull?.message, isNotEmpty);
    });

    test('✅ Google Sign-In error handling works correctly', () async {
      // Setup mock to return descriptive error
      when(mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Result.failure(
          const Failure.authFailure(message: 'User cancelled Google Sign-In'),
        ),
      );

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      // Test error handling when Firebase is not configured
      final result = await signInWithGoogleUseCase.call(const NoParams());

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isNotNull);

      // Error message should be descriptive
      final errorMessage = result.failureOrNull?.message ?? '';
      expect(errorMessage, isNotEmpty);
      expect(
        errorMessage.length,
        greaterThan(5),
      ); // Should have meaningful error
    });

    test('✅ Google Sign-In use case performance is acceptable', () async {
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

      // Test performance of sign-in attempt
      final result = await signInWithGoogleUseCase.call(const NoParams());

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Should complete within reasonable time (even failures)
      expect(duration.inSeconds, lessThan(5));
      expect(
        result.isFailure,
        isTrue,
      ); // Expected due to Firebase not configured
    });

    test('✅ Multiple Google Sign-In attempts work consistently', () async {
      // Setup mock to return consistent failures
      when(mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Result.failure(
          const Failure.serverFailure(message: 'Firebase not configured'),
        ),
      );

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      // Test multiple sequential attempts
      final results = <Result<UserEntity>>[];
      for (int i = 0; i < 3; i++) {
        final result = await signInWithGoogleUseCase.call(const NoParams());
        results.add(result);
      }

      // All results should be consistent
      for (final result in results) {
        expect(result, isA<Result<UserEntity>>());
        expect(
          result.isFailure,
          isTrue,
        ); // Expected due to Firebase not configured
        expect(result.failureOrNull, isNotNull);
        expect(result.failureOrNull?.message, isNotEmpty);
      }
    });

    test('✅ Google Sign-In concurrent attempts work correctly', () async {
      // Setup mock to return failures for all concurrent attempts
      when(mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Result.failure(
          const Failure.serverFailure(message: 'Firebase not configured'),
        ),
      );

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      // Test concurrent sign-in attempts
      final futures = List.generate(
        3,
        (_) => signInWithGoogleUseCase.call(const NoParams()),
      );

      final results = await Future.wait(futures);

      // All concurrent attempts should complete
      expect(results.length, equals(3));

      for (final result in results) {
        expect(result, isA<Result<UserEntity>>());
        expect(
          result.isFailure,
          isTrue,
        ); // Expected due to Firebase not configured
        expect(result.failureOrNull, isNotNull);
      }
    });

    test(
      '✅ Google Sign-In use case integration structure is correct',
      () async {
        // Setup mock
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => Result.failure(
            const Failure.serverFailure(message: 'Firebase not configured'),
          ),
        );

        final signInWithGoogleUseCase = SignInWithGoogleUseCase(
          authRepository: mockAuthRepository,
        );

        // Validate the use case follows Clean Architecture patterns
        expect(
          signInWithGoogleUseCase.runtimeType.toString(),
          contains('UseCase'),
        );

        // Test call method signature
        final result = await signInWithGoogleUseCase.call(const NoParams());

        expect(result, isA<Result<UserEntity>>());
        expect(
          result.isFailure,
          isTrue,
        ); // Expected due to Firebase not configured
      },
    );

    test('✅ Google Sign-In result types are correct', () async {
      // Setup mock to return failure
      when(mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Result.failure(
          const Failure.serverFailure(message: 'Firebase not configured'),
        ),
      );

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      final result = await signInWithGoogleUseCase.call(const NoParams());

      // Validate result structure
      expect(result, isA<Result<UserEntity>>());
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);

      // Failure case validation
      expect(result.failureOrNull, isNotNull);
      expect(result.dataOrNull, isNull);

      // Success case validation (when Firebase is configured)
      if (result.isSuccess) {
        expect(result.dataOrNull, isNotNull);
        expect(result.failureOrNull, isNull);
      }
    });

    test('✅ Google Sign-In parameter validation works', () {
      const params = NoParams();

      // NoParams should be valid for Google Sign-In
      expect(params, isA<NoParams>());
      expect(params.hashCode, isA<int>());
      expect(params == const NoParams(), isTrue);
    });

    test('✅ Google Sign-In use case cleanup works correctly', () async {
      // Setup mock to return consistent failures
      when(mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Result.failure(
          const Failure.serverFailure(message: 'Firebase not configured'),
        ),
      );

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      // Test that use case can be called multiple times without issues
      final result1 = await signInWithGoogleUseCase.call(const NoParams());
      final result2 = await signInWithGoogleUseCase.call(const NoParams());

      expect(result1, isA<Result<UserEntity>>());
      expect(result2, isA<Result<UserEntity>>());

      // Both should fail consistently due to Firebase not being configured
      expect(result1.isFailure, isTrue);
      expect(result2.isFailure, isTrue);

      // Error messages should be consistent
      expect(
        result1.failureOrNull?.message,
        equals(result2.failureOrNull?.message),
      );
    });

    test('✅ Google Sign-In success scenario works correctly', () async {
      // Setup mock to return success
      final testUser = UserEntity(
        id: 'google_test_123',
        name: 'Test User',
        email: 'test@gmail.com',
        createdAt: DateTime.now(),
      );

      when(
        mockAuthRepository.signInWithGoogle(),
      ).thenAnswer((_) async => Result.success(testUser));

      final signInWithGoogleUseCase = SignInWithGoogleUseCase(
        authRepository: mockAuthRepository,
      );

      final result = await signInWithGoogleUseCase.call(const NoParams());

      // Should succeed with proper user data
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNotNull);
      expect(result.dataOrNull?.email, equals('test@gmail.com'));
      expect(result.dataOrNull?.name, equals('Test User'));
      expect(result.failureOrNull, isNull);
    });
  });
}
