import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/entities/security_event_entity.dart';
import '../../../../../test_config.dart';
import '../../../../../helpers/tdd_templates.dart';

/// Unit tests for SecurityEventEntity
/// Following TDD approach and CLAUDE.md testing strategy
void main() {
  testGroup('SecurityEventEntity', TestCategory.unit, () {
    late SecurityEventEntity criticalEvent;
    late SecurityEventEntity recentEvent;
    late SecurityEventEntity oldEvent;
    late SecurityEventEntity lowSeverityEvent;

    setUp(() {
      final now = DateTime.now();

      criticalEvent = SecurityEventEntity(
        id: 'event-123',
        userId: 'user-123',
        type: SecurityEventType.multipleFailedAttempts,
        severity: SecurityEventSeverity.critical,
        timestamp: now.subtract(const Duration(minutes: 30)),
        deviceId: 'device-123',
        ipAddress: '192.168.1.100',
        description: 'Multiple failed login attempts detected',
        sessionId: 'session-123',
        location: 'New York, NY',
        metadata: {'attemptCount': 5},
        resolved: false,
      );

      recentEvent = criticalEvent.copyWith(
        severity: SecurityEventSeverity.medium,
        timestamp: now.subtract(const Duration(minutes: 15)),
      );

      oldEvent = criticalEvent.copyWith(
        timestamp: now.subtract(const Duration(days: 2)),
      );

      lowSeverityEvent = criticalEvent.copyWith(
        type: SecurityEventType.loginSuccess,
        severity: SecurityEventSeverity.low,
      );
    });

    // Basic entity tests using TDD template
    EntityTestTemplate.runBasicTests<SecurityEventEntity>(
      createValidEntity: () => criticalEvent,
      createInvalidEntity: () => criticalEvent.copyWith(id: ''),
      entityName: 'SecurityEventEntity',
      businessLogicMethods: [
        'isCritical',
        'isRecent',
        'ageInHours',
        'requiresNotification',
        'triggersSecurityPolicy',
      ],
    );

    group('Business Logic - Event Criticality', () {
      testCase(
        'should correctly identify critical events',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(criticalEvent.isCritical, isTrue);
          expect(recentEvent.isCritical, isFalse);
          expect(lowSeverityEvent.isCritical, isFalse);
        },
      );

      testCase(
        'should correctly identify recent events',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(recentEvent.isRecent, isTrue);
          expect(oldEvent.isRecent, isFalse);
        },
      );

      testCase('should calculate event age correctly', TestCategory.unit, () {
        // Act
        final recentAge = recentEvent.ageInHours;
        final oldAge = oldEvent.ageInHours;

        // Assert
        expect(recentAge, equals(0)); // Less than 1 hour
        expect(oldAge, equals(48)); // 2 days = 48 hours
      });
    });

    group('Business Logic - Notification Requirements', () {
      testCase(
        'should require notification for medium and higher severity',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(criticalEvent.requiresNotification, isTrue);
          expect(recentEvent.requiresNotification, isTrue);
          expect(lowSeverityEvent.requiresNotification, isFalse);
        },
      );

      testCase(
        'should require notification for high severity',
        TestCategory.unit,
        () {
          // Arrange
          final highSeverityEvent = criticalEvent.copyWith(
            severity: SecurityEventSeverity.high,
          );

          // Act & Assert
          expect(highSeverityEvent.requiresNotification, isTrue);
        },
      );
    });

    group('Business Logic - Security Policy Triggers', () {
      testCase(
        'should trigger security policy for multiple failed attempts',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(criticalEvent.triggersSecurityPolicy, isTrue);
        },
      );

      testCase(
        'should trigger security policy for suspicious activity',
        TestCategory.unit,
        () {
          // Arrange
          final suspiciousEvent = criticalEvent.copyWith(
            type: SecurityEventType.suspiciousActivity,
            severity: SecurityEventSeverity.medium,
          );

          // Act & Assert
          expect(suspiciousEvent.triggersSecurityPolicy, isTrue);
        },
      );

      testCase(
        'should trigger security policy for critical severity regardless of type',
        TestCategory.unit,
        () {
          // Arrange
          final criticalLoginEvent = criticalEvent.copyWith(
            type: SecurityEventType.loginSuccess,
            severity: SecurityEventSeverity.critical,
          );

          // Act & Assert
          expect(criticalLoginEvent.triggersSecurityPolicy, isTrue);
        },
      );

      testCase(
        'should not trigger security policy for low severity events',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(lowSeverityEvent.triggersSecurityPolicy, isFalse);
        },
      );
    });

    group('SecurityEventType Enum', () {
      testCase(
        'should have correct display names for authentication events',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(
            SecurityEventType.loginAttempt.displayName,
            equals('Login Attempt'),
          );
          expect(
            SecurityEventType.loginSuccess.displayName,
            equals('Login Success'),
          );
          expect(
            SecurityEventType.loginFailure.displayName,
            equals('Login Failure'),
          );
          expect(
            SecurityEventType.logoutSuccess.displayName,
            equals('Logout Success'),
          );
        },
      );

      testCase(
        'should have correct display names for security events',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(
            SecurityEventType.accountLockout.displayName,
            equals('Account Lockout'),
          );
          expect(
            SecurityEventType.suspiciousActivity.displayName,
            equals('Suspicious Activity'),
          );
          expect(
            SecurityEventType.multipleFailedAttempts.displayName,
            equals('Multiple Failed Attempts'),
          );
        },
      );

      testCase(
        'should have correct display names for device events',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(
            SecurityEventType.deviceRegistration.displayName,
            equals('Device Registration'),
          );
          expect(
            SecurityEventType.deviceTrustChange.displayName,
            equals('Device Trust Change'),
          );
          expect(
            SecurityEventType.unknownDevice.displayName,
            equals('Unknown Device'),
          );
        },
      );
    });

    group('SecurityEventSeverity Enum', () {
      testCase(
        'should have correct display names for all severity levels',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(SecurityEventSeverity.low.displayName, equals('Low'));
          expect(SecurityEventSeverity.medium.displayName, equals('Medium'));
          expect(SecurityEventSeverity.high.displayName, equals('High'));
          expect(
            SecurityEventSeverity.critical.displayName,
            equals('Critical'),
          );
        },
      );

      testCase(
        'should have correct index ordering for severity comparison',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(SecurityEventSeverity.low.index, equals(0));
          expect(SecurityEventSeverity.medium.index, equals(1));
          expect(SecurityEventSeverity.high.index, equals(2));
          expect(SecurityEventSeverity.critical.index, equals(3));
        },
      );
    });

    group('Edge Cases', () {
      testCase(
        'should handle event created in future correctly',
        TestCategory.unit,
        () {
          // Arrange
          final futureEvent = criticalEvent.copyWith(
            timestamp: DateTime.now().add(const Duration(hours: 1)),
          );

          // Act
          final age = futureEvent.ageInHours;

          // Assert - Should handle negative values gracefully
          expect(age, isA<int>());
        },
      );

      testCase('should handle exactly 1 hour old event', TestCategory.unit, () {
        // Arrange
        final exactlyOneHour = criticalEvent.copyWith(
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act & Assert
        expect(exactlyOneHour.isRecent, isFalse);
        expect(exactlyOneHour.ageInHours, equals(1));
      });

      testCase('should handle null metadata gracefully', TestCategory.unit, () {
        // Arrange
        final eventWithNullMetadata = criticalEvent.copyWith(metadata: null);

        // Act & Assert
        expect(eventWithNullMetadata.metadata, isNull);
        expect(eventWithNullMetadata.isCritical, isTrue);
      });

      testCase(
        'should handle null session ID gracefully',
        TestCategory.unit,
        () {
          // Arrange
          final eventWithNullSession = criticalEvent.copyWith(sessionId: null);

          // Act & Assert
          expect(eventWithNullSession.sessionId, isNull);
          expect(eventWithNullSession.triggersSecurityPolicy, isTrue);
        },
      );
    });

    group('Data Integrity', () {
      testCase(
        'should maintain data integrity after copyWith',
        TestCategory.unit,
        () {
          // Arrange
          const newDescription = 'Updated security event description';

          // Act
          final updatedEvent = criticalEvent.copyWith(
            description: newDescription,
          );

          // Assert
          expect(updatedEvent.description, equals(newDescription));
          expect(updatedEvent.id, equals(criticalEvent.id));
          expect(updatedEvent.userId, equals(criticalEvent.userId));
          expect(updatedEvent != criticalEvent, isTrue);
        },
      );

      testCase('should handle complex metadata updates', TestCategory.unit, () {
        // Arrange
        final newMetadata = {
          'attemptCount': 10,
          'sourceIP': '10.0.0.1',
          'userAgent': 'BadBot/1.0',
        };

        // Act
        final updatedEvent = criticalEvent.copyWith(metadata: newMetadata);

        // Assert
        expect(updatedEvent.metadata, equals(newMetadata));
      });

      testCase('should handle resolved status changes', TestCategory.unit, () {
        // Arrange & Act
        final resolvedEvent = criticalEvent.copyWith(resolved: true);

        // Assert
        expect(resolvedEvent.resolved, isTrue);
        expect(criticalEvent.resolved, isFalse);
      });
    });
  });
}
