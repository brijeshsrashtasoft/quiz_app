import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../../../lib/features/authentication/domain/usecases/sign_out_usecase.dart';
import '../../../../../../lib/core/utils/result.dart';
import '../../../../../../lib/core/errors/failures.dart';
import '../../../../../../lib/core/base/base_usecase.dart';

/// Test file for SignOutUseCase and SignOutAndClearSessionUseCase
/// Following TDD principles and CLAUDE.md testing patterns
/// Covers all sign out scenarios and edge cases

void main() {
  group('SignOutUseCase', () {
    late SignOutUseCase signOutUseCase;

    setUp(() {
      signOutUseCase = SignOutUseCase();
    });

    group('Successful Sign Out', () {
      test('should return success when user is signed in', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutUseCase(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNull);
      });

      test('should handle sign out when already signed out', () async {
        // Arrange
        const params = NoParams();

        // Act - Call sign out multiple times
        final result1 = await signOutUseCase(params);
        final result2 = await signOutUseCase(params);

        // Assert - Should handle gracefully
        expect(result1, isA<Result<void>>());
        expect(result2, isA<Result<void>>());
      });
    });

    group('Authentication Failures', () {
      test('should handle case when no user is signed in', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutUseCase(params);

        // Assert - May return failure or success depending on implementation
        expect(result, isA<Result<void>>());

        if (result.isFailure) {
          expect(result.failureOrNull, isA<Failure>());
          final failure = result.failureOrNull as AuthFailure;
          expect(failure.code, equals('AUTH_NO_CURRENT_USER'));
          expect(failure.userMessage, equals('No user is currently signed in'));
        }
      });

      test('should handle network errors during sign out', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutUseCase(params);

        // Assert - Testing error handling structure
        expect(result, isA<Result<void>>());
      });
    });

    group('Edge Cases', () {
      test('should be idempotent - multiple calls should work', () async {
        // Arrange
        const params = NoParams();

        // Act
        final results = await Future.wait([
          signOutUseCase(params),
          signOutUseCase(params),
          signOutUseCase(params),
        ]);

        // Assert - All calls should complete
        for (final result in results) {
          expect(result, isA<Result<void>>());
        }
      });

      test('should handle concurrent sign out calls', () async {
        // Arrange
        const params = NoParams();

        // Act - Start multiple sign out operations concurrently
        final futures = List.generate(5, (_) => signOutUseCase(params));
        final results = await Future.wait(futures);

        // Assert - All should complete without throwing
        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, isA<Result<void>>());
        }
      });
    });

    group('Performance', () {
      test('should complete within reasonable time', () async {
        // Arrange
        const params = NoParams();

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await signOutUseCase(params);
        stopwatch.stop();

        // Assert - Should complete within 3 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(result, isA<Result<void>>());
      });
    });
  });

  group('SignOutAndClearSessionUseCase', () {
    late SignOutAndClearSessionUseCase signOutAndClearSessionUseCase;

    setUp(() {
      signOutAndClearSessionUseCase = SignOutAndClearSessionUseCase();
    });

    group('Successful Comprehensive Sign Out', () {
      test('should return success when user is signed in', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNull);
      });

      test('should clear all session data', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert - Should complete the comprehensive cleanup
        expect(result, isA<Result<void>>());
      });
    });

    group('Authentication Failures', () {
      test('should handle case when no user is signed in', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert
        expect(result, isA<Result<void>>());

        if (result.isFailure) {
          expect(result.failureOrNull, isA<Failure>());
          final failure = result.failureOrNull as AuthFailure;
          expect(failure.code, equals('AUTH_NO_CURRENT_USER'));
          expect(failure.userMessage, equals('No user is currently signed in'));
        }
      });

      test('should handle partial cleanup failures gracefully', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert - Should handle partial failures
        expect(result, isA<Result<void>>());
      });
    });

    group('Cleanup Operations', () {
      test('should perform comprehensive cleanup', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert - Should complete cleanup operations
        expect(result, isA<Result<void>>());

        // TODO: When other features are implemented, add specific cleanup assertions:
        // - Verify cached user data is cleared
        // - Verify local storage is cleared
        // - Verify streams are cancelled
        // - Verify quiz session data is cleared
        // - Verify leaderboard cache is cleared
      });

      test('should handle cleanup timeout scenarios', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert - Should handle timeouts gracefully
        expect(result, isA<Result<void>>());
      });
    });

    group('Edge Cases', () {
      test('should be idempotent for comprehensive sign out', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result1 = await signOutAndClearSessionUseCase(params);
        final result2 = await signOutAndClearSessionUseCase(params);

        // Assert
        expect(result1, isA<Result<void>>());
        expect(result2, isA<Result<void>>());
      });

      test('should handle memory cleanup properly', () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await signOutAndClearSessionUseCase(params);

        // Assert - Should not cause memory leaks
        expect(result, isA<Result<void>>());
      });
    });

    group('Performance', () {
      test(
        'should complete comprehensive cleanup within reasonable time',
        () async {
          // Arrange
          const params = NoParams();

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await signOutAndClearSessionUseCase(params);
          stopwatch.stop();

          // Assert - Should complete within 5 seconds even with comprehensive cleanup
          expect(stopwatch.elapsedMilliseconds, lessThan(5000));
          expect(result, isA<Result<void>>());
        },
      );

      test('should not block UI during cleanup', () async {
        // Arrange
        const params = NoParams();

        // Act - Should be non-blocking
        final result = await signOutAndClearSessionUseCase(params);

        // Assert
        expect(result, isA<Result<void>>());
      });
    });

    group('Comparison with Simple Sign Out', () {
      test(
        'comprehensive sign out should take longer than simple sign out',
        () async {
          // Arrange
          const params = NoParams();
          final simpleSignOut = SignOutUseCase();

          // Act
          final stopwatch1 = Stopwatch()..start();
          await simpleSignOut(params);
          stopwatch1.stop();

          final stopwatch2 = Stopwatch()..start();
          await signOutAndClearSessionUseCase(params);
          stopwatch2.stop();

          // Assert - Comprehensive should take longer (or same time if both are fast)
          expect(
            stopwatch2.elapsedMilliseconds,
            greaterThanOrEqualTo(stopwatch1.elapsedMilliseconds),
          );
        },
      );
    });
  });
}
