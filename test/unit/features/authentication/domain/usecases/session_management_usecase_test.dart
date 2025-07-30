import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/session_entity.dart';
import 'package:quiz_app/features/authentication/domain/entities/security_event_entity.dart';
import 'package:quiz_app/features/authentication/domain/repositories/security_repository.dart';
import 'package:quiz_app/features/authentication/domain/usecases/session_management_usecase.dart';
import '../../../../../test_config.dart';
import '../../../../../helpers/tdd_templates.dart';

// Manual mock for SecurityRepository
class MockSecurityRepository extends Mock implements SecurityRepository {}

/// Unit tests for SessionManagementUseCase
/// Following TDD approach and CLAUDE.md testing strategy
void main() {
  testGroup('SessionManagementUseCase', TestCategory.unit, () {
    late SessionManagementUseCase useCase;
    late MockSecurityRepository mockSecurityRepository;
    late SessionEntity validSession;
    late SessionEntity expiredSession;
    late SessionEntity nearExpirationSession;

    setUp(() {
      mockSecurityRepository = MockSecurityRepository();
      useCase = SessionManagementUseCase(mockSecurityRepository);

      final now = DateTime.now();
      validSession = SessionEntity(
        id: 'session-123',
        userId: 'user-123',
        deviceId: 'device-123',
        deviceName: 'iPhone 14',
        deviceType: 'mobile',
        ipAddress: '192.168.1.100',
        createdAt: now.subtract(const Duration(hours: 1)),
        lastActivityAt: now.subtract(const Duration(minutes: 5)),
        expiresAt: now.add(const Duration(hours: 23)),
        isActive: true,
        isTrusted: true,
        location: 'New York, NY',
      );

      expiredSession = validSession.copyWith(
        expiresAt: now.subtract(const Duration(hours: 1)),
      );

      nearExpirationSession = validSession.copyWith(
        expiresAt: now.add(const Duration(minutes: 15)),
      );
    });

    group('TDD Cycle - Session Creation', () {
      testCase(
        'should successfully create new session',
        TestCategory.unit,
        () async {
          // Arrange
          final createParams = SessionManagementParams(
            operation: SessionOperation.create,
            userId: 'user-123',
            deviceId: 'device-123',
            deviceName: 'iPhone 14',
            deviceType: 'mobile',
            ipAddress: '192.168.1.100',
            location: 'New York, NY',
            userAgent: 'Mozilla/5.0',
          );

          when(
            mockSecurityRepository.createSession(
              userId: anyNamed('userId'),
              deviceId: anyNamed('deviceId'),
              deviceName: anyNamed('deviceName'),
              deviceType: anyNamed('deviceType'),
              ipAddress: anyNamed('ipAddress'),
              location: anyNamed('location'),
              userAgent: anyNamed('userAgent'),
            ),
          ).thenAnswer((_) async => Result.success(validSession));

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
                description: 'Session created successfully',
              ),
            ),
          );

          // Act
          final result = await useCase.call(createParams);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data?.id, equals('session-123'));

          // Verify interactions
          verify(
            mockSecurityRepository.createSession(
              userId: 'user-123',
              deviceId: 'device-123',
              deviceName: 'iPhone 14',
              deviceType: 'mobile',
              ipAddress: '192.168.1.100',
              location: 'New York, NY',
              userAgent: 'Mozilla/5.0',
            ),
          ).called(1);

          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: 'user-123',
              eventType: SecurityEventType.loginSuccess,
              deviceId: 'device-123',
              description: 'Session created successfully',
              severity: SecurityEventSeverity.low,
            ),
          ).called(1);
        },
      );
    });

    group('Session Validation', () {
      testCase(
        'should successfully validate active session',
        TestCategory.unit,
        () async {
          // Arrange
          final validateParams = SessionManagementParams(
            operation: SessionOperation.validate,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.getSessionById('session-123'),
          ).thenAnswer((_) async => Result.success(validSession));
          when(
            mockSecurityRepository.updateSessionActivity(
              sessionId: anyNamed('sessionId'),
              lastActivityAt: anyNamed('lastActivityAt'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              validSession.copyWith(lastActivityAt: DateTime.now()),
            ),
          );

          // Act
          final result = await useCase.call(validateParams);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockSecurityRepository.getSessionById('session-123'),
          ).called(1);
          verify(
            mockSecurityRepository.updateSessionActivity(
              sessionId: 'session-123',
              lastActivityAt: anyNamed('lastActivityAt'),
            ),
          ).called(1);
        },
      );

      testCase(
        'should fail validation for expired session',
        TestCategory.unit,
        () async {
          // Arrange
          final validateParams = SessionManagementParams(
            operation: SessionOperation.validate,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.getSessionById('session-123'),
          ).thenAnswer((_) async => Result.success(expiredSession));
          when(
            mockSecurityRepository.terminateSession('session-123'),
          ).thenAnswer((_) async => Result.success(expiredSession));
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
                type: SecurityEventType.sessionTimeout,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Session terminated due to expiration',
              ),
            ),
          );

          // Act
          final result = await useCase.call(validateParams);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('SESSION_EXPIRED'));

          // Verify session is terminated and logged
          verify(
            mockSecurityRepository.terminateSession('session-123'),
          ).called(1);
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: expiredSession.userId,
              eventType: SecurityEventType.sessionTimeout,
              deviceId: expiredSession.deviceId,
              description: 'Session terminated due to expiration',
              severity: SecurityEventSeverity.low,
            ),
          ).called(1);
        },
      );

      testCase(
        'should fail validation for inactive session',
        TestCategory.unit,
        () async {
          // Arrange
          final inactiveSession = validSession.copyWith(
            lastActivityAt: DateTime.now().subtract(const Duration(hours: 25)),
          );
          final validateParams = SessionManagementParams(
            operation: SessionOperation.validate,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.getSessionById('session-123'),
          ).thenAnswer((_) async => Result.success(inactiveSession));
          when(
            mockSecurityRepository.terminateSession('session-123'),
          ).thenAnswer((_) async => Result.success(inactiveSession));
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
                type: SecurityEventType.sessionTimeout,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Session terminated due to expiration',
              ),
            ),
          );

          // Act
          final result = await useCase.call(validateParams);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull?.code, equals('SESSION_INACTIVE'));
        },
      );
    });

    group('Session Refresh', () {
      testCase(
        'should successfully refresh session near expiration',
        TestCategory.unit,
        () async {
          // Arrange
          final refreshParams = SessionManagementParams(
            operation: SessionOperation.refresh,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.getSessionById('session-123'),
          ).thenAnswer((_) async => Result.success(nearExpirationSession));
          when(
            mockSecurityRepository.refreshSession(
              sessionId: anyNamed('sessionId'),
              extendHours: anyNamed('extendHours'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              nearExpirationSession.copyWith(
                expiresAt: DateTime.now().add(const Duration(hours: 24)),
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
                description: 'Session refreshed',
              ),
            ),
          );

          // Act
          final result = await useCase.call(refreshParams);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockSecurityRepository.refreshSession(
              sessionId: 'session-123',
              extendHours: 24,
            ),
          ).called(1);
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: nearExpirationSession.userId,
              eventType: SecurityEventType.loginSuccess,
              deviceId: nearExpirationSession.deviceId,
              description: 'Session refreshed',
              severity: SecurityEventSeverity.low,
            ),
          ).called(1);
        },
      );

      testCase(
        'should not refresh session that does not need refresh',
        TestCategory.unit,
        () async {
          // Arrange
          final refreshParams = SessionManagementParams(
            operation: SessionOperation.refresh,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.getSessionById('session-123'),
          ).thenAnswer((_) async => Result.success(validSession));

          // Act
          final result = await useCase.call(refreshParams);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data?.id, equals(validSession.id));

          // Verify refresh was not called
          verifyNever(
            mockSecurityRepository.refreshSession(
              sessionId: anyNamed('sessionId'),
              extendHours: anyNamed('extendHours'),
            ),
          );
        },
      );
    });

    group('Session Termination', () {
      testCase(
        'should successfully terminate session',
        TestCategory.unit,
        () async {
          // Arrange
          final terminateParams = SessionManagementParams(
            operation: SessionOperation.terminate,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.terminateSession('session-123'),
          ).thenAnswer(
            (_) async => Result.success(validSession.copyWith(isActive: false)),
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
                type: SecurityEventType.logoutSuccess,
                severity: SecurityEventSeverity.low,
                timestamp: DateTime.now(),
                deviceId: 'device-123',
                ipAddress: '192.168.1.100',
                description: 'Session terminated by user',
              ),
            ),
          );

          // Act
          final result = await useCase.call(terminateParams);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data?.isActive, isFalse);

          verify(
            mockSecurityRepository.terminateSession('session-123'),
          ).called(1);
          verify(
            mockSecurityRepository.logSecurityEvent(
              userId: validSession.userId,
              eventType: SecurityEventType.logoutSuccess,
              deviceId: validSession.deviceId,
              description: 'Session terminated by user',
              severity: SecurityEventSeverity.low,
            ),
          ).called(1);
        },
      );
    });

    group('Error Handling', () {
      testCase(
        'should handle repository errors gracefully',
        TestCategory.unit,
        () async {
          // Arrange
          final validateParams = SessionManagementParams(
            operation: SessionOperation.validate,
            sessionId: 'invalid-session',
          );
          const repositoryError = Failure.firestoreFailure(
            message: 'Session not found',
            code: 'SESSION_NOT_FOUND',
          );

          when(
            mockSecurityRepository.getSessionById('invalid-session'),
          ).thenAnswer((_) async => const Result.failure(repositoryError));

          // Act
          final result = await useCase.call(validateParams);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.failureOrNull, equals(repositoryError));
        },
      );
    });

    group('Performance Requirements', () {
      testCase(
        'should complete session operations within performance threshold',
        TestCategory.unit,
        () async {
          // Arrange
          final validateParams = SessionManagementParams(
            operation: SessionOperation.validate,
            sessionId: 'session-123',
          );

          when(
            mockSecurityRepository.getSessionById('session-123'),
          ).thenAnswer((_) async => Result.success(validSession));
          when(
            mockSecurityRepository.updateSessionActivity(
              sessionId: anyNamed('sessionId'),
              lastActivityAt: anyNamed('lastActivityAt'),
            ),
          ).thenAnswer((_) async => Result.success(validSession));

          // Act & Assert - Should complete within 200ms as per CLAUDE.md requirements
          await TestExpectations.expectPerformant(() async {
            await useCase.call(validateParams);
          }, threshold: const Duration(milliseconds: 200));
        },
      );
    });
  });
}
