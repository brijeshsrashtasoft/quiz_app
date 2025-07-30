import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/security_event_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/security_repository.dart';
import 'package:quiz_app/features/authentication/domain/usecases/biometric_auth_usecase.dart';
import '../../../../../test_config.dart';
import '../../../../../helpers/tdd_templates.dart';

// Manual mock for SecurityRepository
class MockSecurityRepository extends Mock implements SecurityRepository {}

/// Unit tests for BiometricAuthUseCase
/// Following TDD approach and CLAUDE.md testing strategy
void main() {
  testGroup('BiometricAuthUseCase', TestCategory.unit, () {
    late BiometricAuthUseCase useCase;
    late MockSecurityRepository mockSecurityRepository;
    late BiometricAuthParams validParams;
    late BiometricAuthParams invalidParams;

    setUp(() {
      mockSecurityRepository = MockSecurityRepository();
      useCase = BiometricAuthUseCase(mockSecurityRepository);

      validParams = const BiometricAuthParams(
        userId: 'user-123',
        deviceId: 'device-123',
        reason: 'Authenticate to access quiz app',
        localizedFallbackTitle: 'Use Password',
      );

      invalidParams = const BiometricAuthParams(
        userId: '',
        deviceId: '',
        reason: '',
      );
    });

    // Basic use case tests using TDD template
    UseCaseTestTemplate.runBasicTests<
      BiometricAuthUseCase,
      BiometricAuthResult,
      BiometricAuthParams
    >(
      createUseCase: () => useCase,
      createValidParams: () => validParams,
      createInvalidParams: () => invalidParams,
      useCaseName: 'BiometricAuthUseCase',
    );

    group('TDD Cycle - Biometric Authentication Success', () {
      testCase(
        'RED: should fail when biometric authentication succeeds',
        TestCategory.unit,
        () async {
          // Arrange - This should fail initially (Red phase)
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.success(true));
          when(
            mockSecurityRepository.authenticateWithBiometric(
              reason: anyNamed('reason'),
              localizedFallbackTitle: anyNamed('localizedFallbackTitle'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              BiometricAuthResult(
                isAuthenticated: true,
                authenticationMethod: 'biometric',
                timestamp: DateTime.now(),
              ),
            ),
          );
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.loginSuccess,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric authentication successful',
              ),
            ),
          );

          // Act
          final result = await useCase.call(validParams);

          // Assert - GREEN: Now test passes
          expect(result.isSuccess, isTrue);
          expect(result.data?.isAuthenticated, isTrue);
          expect(result.data?.authenticationMethod, equals('biometric'));

          // Verify interactions
          verify(mockSecurityRepository.checkBiometricAvailability()).called(1);
          verify(
            mockSecurityRepository.authenticateWithBiometric(
              reason: validParams.reason,
              localizedFallbackTitle: validParams.localizedFallbackTitle,
            ),
          ).called(1);
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: validParams.userId,
              eventType: SecurityEventType.loginSuccess,
              deviceId: validParams.deviceId,
              description: 'Biometric authentication successful',
              severity: SecurityEventSeverity.low,
            ),
          ).called(1);
        },
      );
    });

    group('Biometric Authentication Failure Scenarios', () {
      testCase(
        'should return failure when biometric is not available',
        TestCategory.unit,
        () async {
          // Arrange
          const biometricFailure = Failure.biometricFailure(
            message: 'Biometric hardware not available',
            code: 'BIOMETRIC_NOT_AVAILABLE',
          );
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.failure(biometricFailure));
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.biometricFailure,
                severity: SecurityEventSeverity.medium,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric not available',
              ),
            ),
          );

          // Act
          final result = await useCase.call(validParams);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(biometricFailure));

          // Verify security event logged
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: validParams.userId,
              eventType: SecurityEventType.biometricFailure,
              deviceId: validParams.deviceId,
              description: 'Biometric not available',
              severity: SecurityEventSeverity.medium,
            ),
          ).called(1);
        },
      );

      testCase(
        'should return failure when biometric authentication fails',
        TestCategory.unit,
        () async {
          // Arrange
          const authFailure = Failure.biometricFailure(
            message: 'Biometric authentication failed',
            code: 'BIOMETRIC_AUTH_FAILED',
          );
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.success(true));
          when(
            mockSecurityRepository.authenticateWithBiometric(
              reason: anyNamed('reason'),
              localizedFallbackTitle: anyNamed('localizedFallbackTitle'),
            ),
          ).thenAnswer((_) async => const Result.failure(authFailure));
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.biometricFailure,
                severity: SecurityEventSeverity.medium,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric authentication failed',
              ),
            ),
          );

          // Act
          final result = await useCase.call(validParams);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(authFailure));

          // Verify security event logged
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: validParams.userId,
              eventType: SecurityEventType.biometricFailure,
              deviceId: validParams.deviceId,
              description: 'Biometric authentication failed',
              severity: SecurityEventSeverity.medium,
            ),
          ).called(1);
        },
      );
    });

    group('Security Event Logging', () {
      testCase(
        'should log security event for successful authentication',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.success(true));
          when(
            mockSecurityRepository.authenticateWithBiometric(
              reason: anyNamed('reason'),
              localizedFallbackTitle: anyNamed('localizedFallbackTitle'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              BiometricAuthResult(
                isAuthenticated: true,
                authenticationMethod: 'biometric',
                timestamp: DateTime.now(),
              ),
            ),
          );
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.loginSuccess,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric authentication successful',
              ),
            ),
          );

          // Act
          await useCase.call(validParams);

          // Assert - Verify security event is logged with correct parameters
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: validParams.userId,
              eventType: SecurityEventType.loginSuccess,
              deviceId: validParams.deviceId,
              description: 'Biometric authentication successful',
              severity: SecurityEventSeverity.low,
            ),
          ).called(1);
        },
      );

      testCase(
        'should log security event for failed authentication',
        TestCategory.unit,
        () async {
          // Arrange
          const authFailure = Failure.biometricFailure(
            message: 'Authentication failed',
            code: 'AUTH_FAILED',
          );
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.success(true));
          when(
            mockSecurityRepository.authenticateWithBiometric(
              reason: anyNamed('reason'),
              localizedFallbackTitle: anyNamed('localizedFallbackTitle'),
            ),
          ).thenAnswer((_) async => const Result.failure(authFailure));
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.biometricFailure,
                severity: SecurityEventSeverity.medium,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric authentication failed',
              ),
            ),
          );

          // Act
          await useCase.call(validParams);

          // Assert - Verify security event is logged with correct parameters
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: validParams.userId,
              eventType: SecurityEventType.biometricFailure,
              deviceId: validParams.deviceId,
              description: 'Biometric authentication failed',
              severity: SecurityEventSeverity.medium,
            ),
          ).called(1);
        },
      );
    });

    group('Edge Cases', () {
      testCase(
        'should handle null localizedFallbackTitle gracefully',
        TestCategory.unit,
        () async {
          // Arrange
          final paramsWithNullFallback = validParams.copyWith(
            localizedFallbackTitle: null,
          );
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.success(true));
          when(
            mockSecurityRepository.authenticateWithBiometric(
              reason: anyNamed('reason'),
              localizedFallbackTitle: anyNamed('localizedFallbackTitle'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              BiometricAuthResult(
                isAuthenticated: true,
                authenticationMethod: 'biometric',
                timestamp: DateTime.now(),
              ),
            ),
          );
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.loginSuccess,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric authentication successful',
              ),
            ),
          );

          // Act
          final result = await useCase.call(paramsWithNullFallback);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockSecurityRepository.authenticateWithBiometric(
              reason: paramsWithNullFallback.reason,
              localizedFallbackTitle: null,
            ),
          ).called(1);
        },
      );
    });

    group('Performance Requirements', () {
      testCase(
        'should complete biometric authentication within performance threshold',
        TestCategory.unit,
        () async {
          // Arrange
          when(
            mockSecurityRepository.checkBiometricAvailability(),
          ).thenAnswer((_) async => const Result.success(true));
          when(
            mockSecurityRepository.authenticateWithBiometric(
              reason: anyNamed('reason'),
              localizedFallbackTitle: anyNamed('localizedFallbackTitle'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              BiometricAuthResult(
                isAuthenticated: true,
                authenticationMethod: 'biometric',
                timestamp: DateTime.now(),
              ),
            ),
          );
          when(
            mockSecurityRepository.logSecurityEvent(
              userId: anyNamed('userId'),
              eventType: anyNamed('eventType'),
              deviceId: anyNamed('deviceId'),
              description: anyNamed('description'),
              severity: anyNamed('severity'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              SecurityEventEntity(
                id: 'event-123',
                userId: 'user-123',
                type: SecurityEventType.loginSuccess,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Biometric authentication successful',
              ),
            ),
          );

          // Act & Assert - Should complete within 200ms as per CLAUDE.md requirements
          await TestExpectations.expectPerformant(() async {
            await useCase.call(validParams);
          }, threshold: const Duration(milliseconds: 200));
        },
      );
    });
  });
}

/// Extension to add copyWith method to BiometricAuthParams for testing
extension BiometricAuthParamsTestExtension on BiometricAuthParams {
  BiometricAuthParams copyWith({
    String? userId,
    String? deviceId,
    String? reason,
    String? localizedFallbackTitle,
  }) {
    return BiometricAuthParams(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      reason: reason ?? this.reason,
      localizedFallbackTitle:
          localizedFallbackTitle ?? this.localizedFallbackTitle,
    );
  }
}
