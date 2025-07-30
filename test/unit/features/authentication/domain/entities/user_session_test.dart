import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_session.dart';
import '../../../../../test_config.dart';

/// Comprehensive unit tests for UserSession domain entities
/// Following TDD principles and CLAUDE.md testing patterns
/// Covers: UserSession, SecureUserSession, extensions, edge cases
void main() {
  testGroup('UserSession Entities', TestCategory.unit, () {
    late DateTime testDate;
    late UserSession testSession;

    setUpAll(() {
      testDate = DateTime.parse('2024-01-01T12:00:00.000Z');
      testSession = UserSession(
        sessionId: 'session-123',
        userId: 'user-123',
        createdAt: testDate,
        lastAccessedAt: testDate.add(Duration(minutes: 30)),
        expiresAt: testDate.add(Duration(hours: 24)),
        isActive: true,
        deviceInfo: 'iPhone 15 Pro',
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
        metadata: {'app_version': '1.0.0', 'build': '123'},
      );
    });

    group('UserSession Creation and Properties', () {
      testCase(
        'should create UserSession with required fields only',
        TestCategory.unit,
        () {
          // Act
          final session = UserSession(
            sessionId: 'session-456',
            userId: 'user-456',
            createdAt: testDate,
            lastAccessedAt: testDate,
            isActive: true,
          );

          // Assert
          expect(session.sessionId, equals('session-456'));
          expect(session.userId, equals('user-456'));
          expect(session.createdAt, equals(testDate));
          expect(session.lastAccessedAt, equals(testDate));
          expect(session.isActive, isTrue);
          expect(session.expiresAt, isNull);
          expect(session.deviceInfo, isNull);
          expect(session.ipAddress, isNull);
          expect(session.userAgent, isNull);
          expect(session.metadata, isNull);
        },
      );

      testCase(
        'should create UserSession with all fields',
        TestCategory.unit,
        () {
          // Assert
          expect(testSession.sessionId, equals('session-123'));
          expect(testSession.userId, equals('user-123'));
          expect(testSession.createdAt, equals(testDate));
          expect(
            testSession.lastAccessedAt,
            equals(testDate.add(Duration(minutes: 30))),
          );
          expect(
            testSession.expiresAt,
            equals(testDate.add(Duration(hours: 24))),
          );
          expect(testSession.isActive, isTrue);
          expect(testSession.deviceInfo, equals('iPhone 15 Pro'));
          expect(testSession.ipAddress, equals('192.168.1.1'));
          expect(testSession.userAgent, contains('iPhone'));
          expect(testSession.metadata?['app_version'], equals('1.0.0'));
        },
      );
    });

    group('UserSession Equality and Hash Code', () {
      testCase(
        'should be equal when all properties match',
        TestCategory.unit,
        () {
          // Arrange
          final session1 = UserSession(
            sessionId: 'session-123',
            userId: 'user-123',
            createdAt: testDate,
            lastAccessedAt: testDate,
            isActive: true,
          );

          final session2 = UserSession(
            sessionId: 'session-123',
            userId: 'user-123',
            createdAt: testDate,
            lastAccessedAt: testDate,
            isActive: true,
          );

          // Assert
          expect(session1, equals(session2));
          expect(session1.hashCode, equals(session2.hashCode));
        },
      );

      testCase(
        'should not be equal when session IDs differ',
        TestCategory.unit,
        () {
          // Arrange
          final session1 = UserSession(
            sessionId: 'session-123',
            userId: 'user-123',
            createdAt: testDate,
            lastAccessedAt: testDate,
            isActive: true,
          );

          final session2 = UserSession(
            sessionId: 'session-456',
            userId: 'user-123',
            createdAt: testDate,
            lastAccessedAt: testDate,
            isActive: true,
          );

          // Assert
          expect(session1, isNot(equals(session2)));
          expect(session1.hashCode, isNot(equals(session2.hashCode)));
        },
      );
    });

    group('UserSession Extension Methods', () {
      group('isExpired', () {
        testCase(
          'should return false when session has no expiry',
          TestCategory.unit,
          () {
            // Arrange
            final sessionWithoutExpiry = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
            );

            // Assert
            expect(sessionWithoutExpiry.isExpired, isFalse);
          },
        );

        testCase(
          'should return false when session is not yet expired',
          TestCategory.unit,
          () {
            // Arrange
            final futureExpiry = DateTime.now().add(Duration(hours: 1));
            final session = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
              expiresAt: futureExpiry,
            );

            // Assert
            expect(session.isExpired, isFalse);
          },
        );

        testCase(
          'should return true when session is expired',
          TestCategory.unit,
          () {
            // Arrange
            final pastExpiry = DateTime.now().subtract(Duration(hours: 1));
            final session = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
              expiresAt: pastExpiry,
            );

            // Assert
            expect(session.isExpired, isTrue);
          },
        );
      });

      group('sessionDuration', () {
        testCase(
          'should calculate correct session duration',
          TestCategory.unit,
          () {
            // Arrange
            final createdAt = DateTime.now().subtract(Duration(hours: 2));
            final session = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: createdAt,
              lastAccessedAt: DateTime.now(),
              isActive: true,
            );

            // Act
            final duration = session.sessionDuration;

            // Assert
            expect(duration.inHours, equals(2));
          },
        );
      });

      group('idleTime', () {
        testCase('should calculate correct idle time', TestCategory.unit, () {
          // Arrange
          final lastAccessed = DateTime.now().subtract(Duration(minutes: 30));
          final session = UserSession(
            sessionId: 'session-123',
            userId: 'user-123',
            createdAt: testDate,
            lastAccessedAt: lastAccessed,
            isActive: true,
          );

          // Act
          final idleTime = session.idleTime;

          // Assert
          expect(idleTime.inMinutes, greaterThanOrEqualTo(29));
          expect(idleTime.inMinutes, lessThanOrEqualTo(31));
        });
      });

      group('isMobileSession', () {
        testCase(
          'should return true for mobile device info',
          TestCategory.unit,
          () {
            // Arrange
            final mobileDevices = [
              'iPhone 15 Pro',
              'Samsung Galaxy S23',
              'Google Pixel 7',
              'iPad Pro',
              'Android Tablet',
              'iOS Device',
            ];

            for (final device in mobileDevices) {
              final session = UserSession(
                sessionId: 'session-123',
                userId: 'user-123',
                createdAt: testDate,
                lastAccessedAt: testDate,
                isActive: true,
                deviceInfo: device,
              );

              // Assert
              expect(
                session.isMobileSession,
                isTrue,
                reason: 'Device $device should be mobile',
              );
            }
          },
        );

        testCase(
          'should return false for non-mobile device info',
          TestCategory.unit,
          () {
            // Arrange
            final nonMobileDevices = [
              'Windows 11 PC',
              'MacBook Pro',
              'Linux Desktop',
              'Chrome OS',
            ];

            for (final device in nonMobileDevices) {
              final session = UserSession(
                sessionId: 'session-123',
                userId: 'user-123',
                createdAt: testDate,
                lastAccessedAt: testDate,
                isActive: true,
                deviceInfo: device,
              );

              // Assert
              expect(
                session.isMobileSession,
                isFalse,
                reason: 'Device $device should not be mobile',
              );
            }
          },
        );

        testCase(
          'should return false when device info is null',
          TestCategory.unit,
          () {
            // Arrange
            final session = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
            );

            // Assert
            expect(session.isMobileSession, isFalse);
          },
        );
      });

      group('isWebSession', () {
        testCase('should return true for web user agents', TestCategory.unit, () {
          // Arrange
          final webUserAgents = [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Firefox/89.0',
          ];

          for (final userAgent in webUserAgents) {
            final session = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
              userAgent: userAgent,
            );

            // Assert
            expect(
              session.isWebSession,
              isTrue,
              reason: 'User agent should be web',
            );
          }
        });

        testCase(
          'should return false for non-web user agents',
          TestCategory.unit,
          () {
            // Arrange
            final nonWebUserAgents = [
              'MobileApp/1.0.0',
              'NativeApp iOS',
              'Custom Client',
            ];

            for (final userAgent in nonWebUserAgents) {
              final session = UserSession(
                sessionId: 'session-123',
                userId: 'user-123',
                createdAt: testDate,
                lastAccessedAt: testDate,
                isActive: true,
                userAgent: userAgent,
              );

              // Assert
              expect(
                session.isWebSession,
                isFalse,
                reason: 'User agent should not be web',
              );
            }
          },
        );

        testCase(
          'should return false when user agent is null',
          TestCategory.unit,
          () {
            // Arrange
            final session = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
            );

            // Assert
            expect(session.isWebSession, isFalse);
          },
        );
      });

      group('needsRenewal', () {
        testCase(
          'should return true when idle for more than 6 hours',
          TestCategory.unit,
          () {
            // Arrange
            final longIdleSession = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: DateTime.now().subtract(Duration(hours: 7)),
              isActive: true,
            );

            // Assert
            expect(longIdleSession.needsRenewal, isTrue);
          },
        );

        testCase(
          'should return true when session is older than 24 hours',
          TestCategory.unit,
          () {
            // Arrange
            final oldSession = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: DateTime.now().subtract(Duration(hours: 25)),
              lastAccessedAt: DateTime.now(),
              isActive: true,
            );

            // Assert
            expect(oldSession.needsRenewal, isTrue);
          },
        );

        testCase(
          'should return false for fresh active session',
          TestCategory.unit,
          () {
            // Arrange
            final freshSession = UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: DateTime.now().subtract(Duration(hours: 1)),
              lastAccessedAt: DateTime.now().subtract(Duration(minutes: 30)),
              isActive: true,
            );

            // Assert
            expect(freshSession.needsRenewal, isFalse);
          },
        );
      });
    });

    group('SecureUserSession', () {
      late SecureUserSession secureSession;

      setUp(() {
        secureSession = SecureUserSession(
          session: testSession,
          securityLevel: SecurityLevel.enhanced,
          permissions: ['read', 'write', 'admin'],
          lastAuthenticationAt: testDate,
          lastPasswordChangeAt: testDate.subtract(Duration(days: 15)),
          deviceType: DeviceType.mobile,
        );
      });

      testCase(
        'should create SecureUserSession with all properties',
        TestCategory.unit,
        () {
          // Assert
          expect(secureSession.session, equals(testSession));
          expect(secureSession.securityLevel, equals(SecurityLevel.enhanced));
          expect(secureSession.permissions, contains('admin'));
          expect(secureSession.lastAuthenticationAt, equals(testDate));
          expect(secureSession.deviceType, equals(DeviceType.mobile));
        },
      );

      group('Permission Management', () {
        testCase(
          'should check if user has specific permission',
          TestCategory.unit,
          () {
            // Act & Assert
            expect(secureSession.hasPermission('read'), isTrue);
            expect(secureSession.hasPermission('write'), isTrue);
            expect(secureSession.hasPermission('admin'), isTrue);
            expect(secureSession.hasPermission('delete'), isFalse);
          },
        );

        testCase(
          'should check if user has any of given permissions',
          TestCategory.unit,
          () {
            // Act & Assert
            expect(secureSession.hasAnyPermission(['read', 'unknown']), isTrue);
            expect(
              secureSession.hasAnyPermission(['unknown', 'invalid']),
              isFalse,
            );
          },
        );

        testCase(
          'should check if user has all given permissions',
          TestCategory.unit,
          () {
            // Act & Assert
            expect(secureSession.hasAllPermissions(['read', 'write']), isTrue);
            expect(
              secureSession.hasAllPermissions(['read', 'write', 'admin']),
              isTrue,
            );
            expect(
              secureSession.hasAllPermissions(['read', 'write', 'delete']),
              isFalse,
            );
          },
        );

        testCase('should add permission to session', TestCategory.unit, () {
          // Act
          final updatedSession = secureSession.addPermission('delete');

          // Assert
          expect(updatedSession.hasPermission('delete'), isTrue);
          expect(updatedSession.permissions, contains('delete'));
          expect(
            secureSession.hasPermission('delete'),
            isFalse,
          ); // Original unchanged
        });

        testCase(
          'should not duplicate permissions when adding existing',
          TestCategory.unit,
          () {
            // Act
            final updatedSession = secureSession.addPermission('read');

            // Assert
            expect(
              updatedSession.permissions.where((p) => p == 'read').length,
              equals(1),
            );
          },
        );

        testCase(
          'should remove permission from session',
          TestCategory.unit,
          () {
            // Act
            final updatedSession = secureSession.removePermission('admin');

            // Assert
            expect(updatedSession.hasPermission('admin'), isFalse);
            expect(updatedSession.permissions, isNot(contains('admin')));
            expect(
              secureSession.hasPermission('admin'),
              isTrue,
            ); // Original unchanged
          },
        );

        testCase(
          'should handle removing non-existent permission',
          TestCategory.unit,
          () {
            // Act
            final updatedSession = secureSession.removePermission(
              'nonexistent',
            );

            // Assert
            expect(
              updatedSession.permissions,
              equals(secureSession.permissions),
            );
          },
        );
      });

      group('Security Level Management', () {
        testCase(
          'should allow sensitive operations for enhanced security',
          TestCategory.unit,
          () {
            // Arrange
            final enhancedSession = secureSession.copyWith(
              securityLevel: SecurityLevel.enhanced,
            );
            final maximumSession = secureSession.copyWith(
              securityLevel: SecurityLevel.maximum,
            );
            final basicSession = secureSession.copyWith(
              securityLevel: SecurityLevel.basic,
            );

            // Act & Assert
            expect(enhancedSession.allowsSensitiveOperations, isTrue);
            expect(maximumSession.allowsSensitiveOperations, isTrue);
            expect(basicSession.allowsSensitiveOperations, isFalse);
          },
        );

        testCase(
          'should update security level with new authentication time',
          TestCategory.unit,
          () {
            // Arrange
            final newLevel = SecurityLevel.maximum;

            // Act
            final updatedSession = secureSession.updateSecurityLevel(newLevel);

            // Assert
            expect(updatedSession.securityLevel, equals(newLevel));
            expect(
              updatedSession.lastAuthenticationAt.isAfter(
                secureSession.lastAuthenticationAt,
              ),
              isTrue,
            );
          },
        );

        testCase(
          'should require recent auth for old authentication',
          TestCategory.unit,
          () {
            // Arrange
            final oldAuthSession = secureSession.copyWith(
              lastAuthenticationAt: DateTime.now().subtract(Duration(hours: 1)),
            );

            // Assert
            expect(oldAuthSession.requiresRecentAuth, isTrue);
          },
        );

        testCase(
          'should not require recent auth for fresh authentication',
          TestCategory.unit,
          () {
            // Arrange
            final freshAuthSession = secureSession.copyWith(
              lastAuthenticationAt: DateTime.now().subtract(
                Duration(minutes: 10),
              ),
            );

            // Assert
            expect(freshAuthSession.requiresRecentAuth, isFalse);
          },
        );
      });

      group('Device Type Inference', () {
        testCase(
          'should infer device type from session when not explicitly set',
          TestCategory.unit,
          () {
            // Arrange
            final mobileSession = testSession.copyWith(
              deviceInfo: 'iPhone 15 Pro',
              userAgent: 'MobileApp/1.0.0',
            );
            final webSession = testSession.copyWith(
              userAgent:
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/91.0',
            );

            final secureWithoutType = SecureUserSession(
              session: mobileSession,
              securityLevel: SecurityLevel.basic,
              permissions: [],
              lastAuthenticationAt: testDate,
            );

            final secureWebWithoutType = SecureUserSession(
              session: webSession,
              securityLevel: SecurityLevel.basic,
              permissions: [],
              lastAuthenticationAt: testDate,
            );

            // Act & Assert
            expect(
              secureWithoutType.inferredDeviceType,
              equals(DeviceType.mobile),
            );
            expect(
              secureWebWithoutType.inferredDeviceType,
              equals(DeviceType.web),
            );
          },
        );

        testCase(
          'should return unknown device type when cannot infer',
          TestCategory.unit,
          () {
            // Arrange
            final unknownSession = testSession.copyWith(
              deviceInfo: null,
              userAgent: null,
            );

            final secureUnknown = SecureUserSession(
              session: unknownSession,
              securityLevel: SecurityLevel.basic,
              permissions: [],
              lastAuthenticationAt: testDate,
            );

            // Act & Assert
            expect(
              secureUnknown.inferredDeviceType,
              equals(DeviceType.unknown),
            );
          },
        );
      });

      group('Password Security', () {
        testCase(
          'should identify recent password change',
          TestCategory.unit,
          () {
            // Arrange
            final recentPasswordSession = secureSession.copyWith(
              lastPasswordChangeAt: DateTime.now().subtract(Duration(days: 15)),
            );

            // Assert
            expect(recentPasswordSession.hasRecentPasswordChange, isTrue);
          },
        );

        testCase('should identify old password change', TestCategory.unit, () {
          // Arrange
          final oldPasswordSession = secureSession.copyWith(
            lastPasswordChangeAt: DateTime.now().subtract(Duration(days: 35)),
          );

          // Assert
          expect(oldPasswordSession.hasRecentPasswordChange, isFalse);
        });

        testCase(
          'should handle null password change date',
          TestCategory.unit,
          () {
            // Arrange
            final noPasswordSession = secureSession.copyWith(
              lastPasswordChangeAt: null,
            );

            // Assert
            expect(noPasswordSession.hasRecentPasswordChange, isFalse);
          },
        );
      });
    });

    group('Enumerations', () {
      testCase(
        'should have all expected SessionStatus values',
        TestCategory.unit,
        () {
          // Assert
          expect(SessionStatus.values, hasLength(4));
          expect(SessionStatus.values, contains(SessionStatus.active));
          expect(SessionStatus.values, contains(SessionStatus.expired));
          expect(SessionStatus.values, contains(SessionStatus.terminated));
          expect(SessionStatus.values, contains(SessionStatus.suspended));
        },
      );

      testCase(
        'should have all expected DeviceType values',
        TestCategory.unit,
        () {
          // Assert
          expect(DeviceType.values, hasLength(5));
          expect(DeviceType.values, contains(DeviceType.mobile));
          expect(DeviceType.values, contains(DeviceType.tablet));
          expect(DeviceType.values, contains(DeviceType.desktop));
          expect(DeviceType.values, contains(DeviceType.web));
          expect(DeviceType.values, contains(DeviceType.unknown));
        },
      );

      testCase(
        'should have all expected SecurityLevel values',
        TestCategory.unit,
        () {
          // Assert
          expect(SecurityLevel.values, hasLength(4));
          expect(SecurityLevel.values, contains(SecurityLevel.basic));
          expect(SecurityLevel.values, contains(SecurityLevel.verified));
          expect(SecurityLevel.values, contains(SecurityLevel.enhanced));
          expect(SecurityLevel.values, contains(SecurityLevel.maximum));
        },
      );
    });

    group('Edge Cases', () {
      testCase(
        'should handle sessions with null metadata',
        TestCategory.unit,
        () {
          // Act & Assert - Should not throw
          expect(
            () => UserSession(
              sessionId: 'session-123',
              userId: 'user-123',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
              metadata: null,
            ),
            returnsNormally,
          );
        },
      );

      testCase(
        'should handle sessions with empty permissions',
        TestCategory.unit,
        () {
          // Act
          final emptyPermissionsSession = SecureUserSession(
            session: testSession,
            securityLevel: SecurityLevel.basic,
            permissions: [],
            lastAuthenticationAt: testDate,
          );

          // Assert
          expect(emptyPermissionsSession.permissions, isEmpty);
          expect(emptyPermissionsSession.hasPermission('any'), isFalse);
          expect(emptyPermissionsSession.hasAnyPermission(['any']), isFalse);
          expect(emptyPermissionsSession.hasAllPermissions([]), isTrue);
        },
      );

      testCase(
        'should handle concurrent session access',
        TestCategory.unit,
        () {
          // This tests that session objects are immutable and thread-safe
          // Arrange
          final originalPermissions = List<String>.from(
            secureSession.permissions,
          );

          // Act - Simulate concurrent modifications
          final futures = List.generate(10, (index) {
            return Future.value(secureSession.addPermission('perm$index'));
          });

          // Assert
          expect(
            secureSession.permissions,
            equals(originalPermissions),
          ); // Original unchanged
          expect(futures, hasLength(10));
        },
      );
    });

    group('Performance', () {
      testCase(
        'should create many sessions efficiently',
        TestCategory.unit,
        () {
          // Arrange
          const sessionsToCreate = 1000;
          final stopwatch = Stopwatch()..start();

          // Act
          final sessions = List.generate(sessionsToCreate, (index) {
            return UserSession(
              sessionId: 'session-$index',
              userId: 'user-$index',
              createdAt: testDate,
              lastAccessedAt: testDate,
              isActive: true,
            );
          });

          stopwatch.stop();

          // Assert
          expect(sessions, hasLength(sessionsToCreate));
          expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        },
      );

      testCase(
        'should handle permission operations efficiently',
        TestCategory.unit,
        () {
          // Arrange
          var currentSession = secureSession;
          final stopwatch = Stopwatch()..start();

          // Act - Add and remove many permissions
          for (int i = 0; i < 100; i++) {
            currentSession = currentSession.addPermission('perm$i');
          }

          for (int i = 0; i < 50; i++) {
            currentSession = currentSession.removePermission('perm$i');
          }

          stopwatch.stop();

          // Assert
          expect(
            currentSession.permissions,
            hasLength(53),
          ); // 3 original + 50 remaining
          expect(stopwatch.elapsedMilliseconds, lessThan(100));
        },
      );
    });
  });
}
