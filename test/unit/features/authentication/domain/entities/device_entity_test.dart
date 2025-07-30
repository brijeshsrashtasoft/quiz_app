import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/entities/device_entity.dart';
import '../../../../../test_config.dart';
import '../../../../../helpers/tdd_templates.dart';

/// Unit tests for DeviceEntity
/// Following TDD approach and CLAUDE.md testing strategy
void main() {
  testGroup('DeviceEntity', TestCategory.unit, () {
    late DeviceEntity trustedDevice;
    late DeviceEntity untrustedDevice;
    late DeviceEntity blockedDevice;
    late DeviceEntity staleDevice;

    setUp(() {
      final now = DateTime.now();

      trustedDevice = DeviceEntity(
        id: 'device-123',
        userId: 'user-123',
        deviceName: 'iPhone 14 Pro',
        deviceType: 'mobile',
        deviceFingerprint: 'abc123def456',
        firstSeen: now.subtract(const Duration(days: 30)),
        lastSeen: now.subtract(const Duration(hours: 2)),
        isTrusted: true,
        isBlocked: false,
        location: 'New York, NY',
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0)',
        capabilities: {'biometric': true, 'faceId': true, 'touchId': false},
        metadata: {'manufacturer': 'Apple'},
      );

      untrustedDevice = trustedDevice.copyWith(isTrusted: false);

      blockedDevice = trustedDevice.copyWith(isBlocked: true);

      staleDevice = trustedDevice.copyWith(
        lastSeen: now.subtract(const Duration(days: 35)),
      );
    });

    // Basic entity tests using TDD template
    EntityTestTemplate.runBasicTests<DeviceEntity>(
      createValidEntity: () => trustedDevice,
      createInvalidEntity: () => trustedDevice.copyWith(id: ''),
      entityName: 'DeviceEntity',
      businessLogicMethods: [
        'trustLevel',
        'isRecentlyActive',
        'daysSinceLastSeen',
        'isStale',
        'status',
        'supportsBiometric',
      ],
    );

    group('Business Logic - Trust Level', () {
      testCase(
        'should return trusted level for trusted device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(trustedDevice.trustLevel, equals(DeviceTrustLevel.trusted));
        },
      );

      testCase(
        'should return untrusted level for blocked device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(blockedDevice.trustLevel, equals(DeviceTrustLevel.untrusted));
        },
      );

      testCase(
        'should return unknown level for non-trusted, non-blocked device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(untrustedDevice.trustLevel, equals(DeviceTrustLevel.unknown));
        },
      );
    });

    group('Business Logic - Activity Status', () {
      testCase(
        'should correctly identify recently active device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(trustedDevice.isRecentlyActive, isTrue);
        },
      );

      testCase('should correctly identify stale device', TestCategory.unit, () {
        // Act & Assert
        expect(staleDevice.isRecentlyActive, isFalse);
        expect(staleDevice.isStale, isTrue);
      });

      testCase(
        'should calculate days since last seen correctly',
        TestCategory.unit,
        () {
          // Act
          final daysSinceLastSeen = staleDevice.daysSinceLastSeen;

          // Assert
          expect(daysSinceLastSeen, equals(35));
        },
      );
    });

    group('Business Logic - Device Status', () {
      testCase(
        'should return correct status for active trusted device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(trustedDevice.status, equals('active'));
        },
      );

      testCase(
        'should return correct status for blocked device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(blockedDevice.status, equals('blocked'));
        },
      );

      testCase(
        'should return correct status for stale device',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(staleDevice.status, equals('stale'));
        },
      );

      testCase(
        'should return correct status for inactive device',
        TestCategory.unit,
        () {
          // Arrange
          final inactiveDevice = trustedDevice.copyWith(
            lastSeen: DateTime.now().subtract(const Duration(days: 10)),
          );

          // Act & Assert
          expect(inactiveDevice.status, equals('inactive'));
        },
      );
    });

    group('Business Logic - Capabilities', () {
      testCase(
        'should correctly identify biometric support',
        TestCategory.unit,
        () {
          // Act & Assert
          expect(trustedDevice.supportsBiometric, isTrue);
        },
      );

      testCase(
        'should handle missing biometric capability',
        TestCategory.unit,
        () {
          // Arrange
          final deviceWithoutBiometric = trustedDevice.copyWith(
            capabilities: {'biometric': false},
          );

          // Act & Assert
          expect(deviceWithoutBiometric.supportsBiometric, isFalse);
        },
      );

      testCase(
        'should handle null capabilities gracefully',
        TestCategory.unit,
        () {
          // Arrange
          final deviceWithNullCapabilities = trustedDevice.copyWith(
            capabilities: null,
          );

          // Act & Assert
          expect(deviceWithNullCapabilities.supportsBiometric, isFalse);
        },
      );
    });

    group('DeviceTrustLevel Enum', () {
      testCase('should have correct display names', TestCategory.unit, () {
        // Act & Assert
        expect(DeviceTrustLevel.unknown.displayName, equals('Unknown'));
        expect(DeviceTrustLevel.untrusted.displayName, equals('Untrusted'));
        expect(DeviceTrustLevel.trusted.displayName, equals('Trusted'));
        expect(DeviceTrustLevel.verified.displayName, equals('Verified'));
      });
    });

    group('Edge Cases', () {
      testCase(
        'should handle device seen in future correctly',
        TestCategory.unit,
        () {
          // Arrange
          final futureDevice = trustedDevice.copyWith(
            lastSeen: DateTime.now().add(const Duration(days: 1)),
          );

          // Act
          final daysSinceLastSeen = futureDevice.daysSinceLastSeen;

          // Assert - Should handle negative values gracefully
          expect(daysSinceLastSeen, isA<int>());
          expect(futureDevice.isRecentlyActive, isTrue);
        },
      );

      testCase(
        'should handle exactly 7 days since last seen',
        TestCategory.unit,
        () {
          // Arrange
          final exactlySevenDays = trustedDevice.copyWith(
            lastSeen: DateTime.now().subtract(const Duration(days: 7)),
          );

          // Act & Assert
          expect(exactlySevenDays.isRecentlyActive, isFalse);
        },
      );

      testCase(
        'should handle exactly 30 days since last seen',
        TestCategory.unit,
        () {
          // Arrange
          final exactlyThirtyDays = trustedDevice.copyWith(
            lastSeen: DateTime.now().subtract(const Duration(days: 30)),
          );

          // Act & Assert
          expect(exactlyThirtyDays.isStale, isFalse);
        },
      );

      testCase(
        'should handle exactly 31 days since last seen',
        TestCategory.unit,
        () {
          // Arrange
          final exactlyThirtyOneDays = trustedDevice.copyWith(
            lastSeen: DateTime.now().subtract(const Duration(days: 31)),
          );

          // Act & Assert
          expect(exactlyThirtyOneDays.isStale, isTrue);
        },
      );
    });

    group('Data Integrity', () {
      testCase(
        'should maintain data integrity after copyWith',
        TestCategory.unit,
        () {
          // Arrange
          const newDeviceName = 'Updated iPhone';

          // Act
          final updatedDevice = trustedDevice.copyWith(
            deviceName: newDeviceName,
          );

          // Assert
          expect(updatedDevice.deviceName, equals(newDeviceName));
          expect(updatedDevice.id, equals(trustedDevice.id));
          expect(updatedDevice.userId, equals(trustedDevice.userId));
          expect(updatedDevice != trustedDevice, isTrue);
        },
      );

      testCase(
        'should handle complex capabilities updates',
        TestCategory.unit,
        () {
          // Arrange
          final newCapabilities = {
            'biometric': false,
            'faceId': false,
            'touchId': true,
            'voice': true,
          };

          // Act
          final updatedDevice = trustedDevice.copyWith(
            capabilities: newCapabilities,
          );

          // Assert
          expect(updatedDevice.capabilities, equals(newCapabilities));
          expect(updatedDevice.supportsBiometric, isFalse);
        },
      );
    });
  });
}
