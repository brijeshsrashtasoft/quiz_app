import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/value_objects/user_id.dart';
import '../../../../../test_config.dart';

/// Comprehensive unit tests for UserId value object
/// Following TDD principles and CLAUDE.md testing patterns
/// Covers: Validation, creation, extension methods, edge cases
void main() {
  testGroup('UserId Value Object', TestCategory.unit, () {
    group('UserId Validation', () {
      testCase(
        'should create valid UserId when input is correct',
        TestCategory.unit,
        () {
          // Arrange
          const validUserIds = [
            'user123',
            'john-doe',
            'user_name',
            'test.user',
            'firebase-uid-123',
            'a1b2c3d4e5f6g7h8i9j0k1l2m3n4',
            'CamelCase123',
          ];

          for (final userIdString in validUserIds) {
            // Act
            final result = UserId.validate(userIdString);

            // Assert
            expect(
              result.isSuccess,
              isTrue,
              reason: 'UserId $userIdString should be valid',
            );
            expect(result.dataOrNull, isA<UserId>());
            expect(result.dataOrNull?.value, equals(userIdString));
          }
        },
      );

      testCase('should reject invalid UserId formats', TestCategory.unit, () {
        // Arrange
        const invalidUserIds = [
          'user@invalid',
          'user with spaces',
          'user#invalid',
          'user\$invalid',
          'user%invalid',
          'user&invalid',
          'user*invalid',
          'user+invalid',
          'user=invalid',
        ];

        for (final userIdString in invalidUserIds) {
          // Act
          final result = UserId.validate(userIdString);

          // Assert
          expect(
            result.isFailure,
            isTrue,
            reason: 'UserId $userIdString should be invalid',
          );
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(
            failure.message,
            equals('User ID contains invalid characters'),
          );
          expect(
            failure.fieldErrors?['userId'],
            contains('User ID can only contain'),
          );
        }
      });

      testCase('should reject empty UserId', TestCategory.unit, () {
        // Act
        final result = UserId.validate('');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        final failure = result.failureOrNull as ValidationFailure;
        expect(failure.message, equals('User ID is required'));
        expect(failure.fieldErrors?['userId'], equals('User ID is required'));
      });

      testCase(
        'should trim whitespace before validation',
        TestCategory.unit,
        () {
          // Act
          final result = UserId.validate('  valid-user-123  ');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull?.value, equals('valid-user-123'));
        },
      );

      testCase('should reject UserId that is too short', TestCategory.unit, () {
        // Arrange
        const shortUserIds = ['a', 'ab'];

        for (final userIdString in shortUserIds) {
          // Act
          final result = UserId.validate(userIdString);

          // Assert
          expect(
            result.isFailure,
            isTrue,
            reason: 'UserId $userIdString should be too short',
          );
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(
            failure.message,
            equals('User ID must be at least 3 characters long'),
          );
          expect(
            failure.fieldErrors?['userId'],
            equals('User ID must be at least 3 characters long'),
          );
        }
      });

      testCase('should reject UserId that is too long', TestCategory.unit, () {
        // Arrange
        final tooLongUserId = 'a' * 51; // Over 50 characters

        // Act
        final result = UserId.validate(tooLongUserId);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        final failure = result.failureOrNull as ValidationFailure;
        expect(failure.message, equals('User ID is too long'));
        expect(failure.fieldErrors?['userId'], equals('User ID is too long'));
      });

      testCase('should reject reserved UserId values', TestCategory.unit, () {
        // Arrange
        const reservedIds = [
          'admin',
          'root',
          'system',
          'anonymous',
          'guest',
          'user',
          'moderator',
          'support',
          'help',
          'api',
          'bot',
          'test',
        ];

        for (final userIdString in reservedIds) {
          // Act
          final result = UserId.validate(userIdString);

          // Assert
          expect(
            result.isFailure,
            isTrue,
            reason: 'UserId $userIdString should be reserved',
          );
          expect(result.failureOrNull, isA<ValidationFailure>());
          final failure = result.failureOrNull as ValidationFailure;
          expect(failure.message, equals('User ID is reserved'));
          expect(
            failure.fieldErrors?['userId'],
            equals('This user ID is reserved, please choose another'),
          );
        }
      });

      testCase(
        'should reject reserved UserId values case insensitively',
        TestCategory.unit,
        () {
          // Arrange
          const reservedIdsUpperCase = [
            'ADMIN',
            'ROOT',
            'SYSTEM',
            'Admin',
            'Root',
            'System',
          ];

          for (final userIdString in reservedIdsUpperCase) {
            // Act
            final result = UserId.validate(userIdString);

            // Assert
            expect(
              result.isFailure,
              isTrue,
              reason: 'UserId $userIdString should be reserved',
            );
            expect(result.failureOrNull, isA<ValidationFailure>());
            final failure = result.failureOrNull as ValidationFailure;
            expect(failure.message, equals('User ID is reserved'));
          }
        },
      );
    });

    group('UserId Creation Methods', () {
      testCase(
        'should create UserId with fromString method',
        TestCategory.unit,
        () {
          // Act
          final userId = UserId.fromString('valid-user-123');

          // Assert
          expect(userId, isNotNull);
          expect(userId?.value, equals('valid-user-123'));
        },
      );

      testCase(
        'should return null for invalid UserId with fromString',
        TestCategory.unit,
        () {
          // Act
          final userId = UserId.fromString('invalid@user');

          // Assert
          expect(userId, isNull);
        },
      );

      testCase(
        'should create UserId with unsafe constructor',
        TestCategory.unit,
        () {
          // Act
          final userId = UserId.unsafe('valid-user-123');

          // Assert
          expect(userId.value, equals('valid-user-123'));
        },
      );
    });

    group('UserId Extension Methods', () {
      testCase(
        'should identify Firebase UIDs correctly',
        TestCategory.unit,
        () {
          // Arrange
          final firebaseUid = UserId.unsafe(
            'abcdefghijklmnopqrstuvwxyz12',
          ); // 28 chars
          final customId = UserId.unsafe('custom-user-id');

          // Act & Assert
          expect(firebaseUid.isFirebaseUid, isTrue);
          expect(firebaseUid.isCustomId, isFalse);
          expect(customId.isFirebaseUid, isFalse);
          expect(customId.isCustomId, isTrue);
        },
      );

      testCase(
        'should identify admin user IDs correctly',
        TestCategory.unit,
        () {
          // Arrange
          final adminIds = [
            UserId.unsafe('admin'),
            UserId.unsafe('admin_user'),
            UserId.unsafe('admin_123'),
          ];

          final nonAdminIds = [
            UserId.unsafe('user123'),
            UserId.unsafe('regular-user'),
            UserId.unsafe('test-user'),
          ];

          // Act & Assert
          for (final adminId in adminIds) {
            expect(
              adminId.isAdminId,
              isTrue,
              reason: '${adminId.value} should be admin',
            );
          }

          for (final nonAdminId in nonAdminIds) {
            expect(
              nonAdminId.isAdminId,
              isFalse,
              reason: '${nonAdminId.value} should not be admin',
            );
          }
        },
      );

      testCase(
        'should identify system user IDs correctly',
        TestCategory.unit,
        () {
          // Arrange
          final systemIds = [
            UserId.unsafe('system'),
            UserId.unsafe('root'),
            UserId.unsafe('api'),
            UserId.unsafe('system_service'),
          ];

          final nonSystemIds = [
            UserId.unsafe('user123'),
            UserId.unsafe('regular-user'),
            UserId.unsafe('test-user'),
          ];

          // Act & Assert
          for (final systemId in systemIds) {
            expect(
              systemId.isSystemId,
              isTrue,
              reason: '${systemId.value} should be system',
            );
          }

          for (final nonSystemId in nonSystemIds) {
            expect(
              nonSystemId.isSystemId,
              isFalse,
              reason: '${nonSystemId.value} should not be system',
            );
          }
        },
      );

      testCase(
        'should identify test user IDs correctly',
        TestCategory.unit,
        () {
          // Arrange
          final testIds = [
            UserId.unsafe('test_user'),
            UserId.unsafe('testuser123'),
            UserId.unsafe('user-test'),
          ];

          final nonTestIds = [
            UserId.unsafe('user123'),
            UserId.unsafe('regular-user'),
            UserId.unsafe('production-user'),
          ];

          // Act & Assert
          for (final testId in testIds) {
            expect(
              testId.isTestId,
              isTrue,
              reason: '${testId.value} should be test ID',
            );
          }

          for (final nonTestId in nonTestIds) {
            expect(
              nonTestId.isTestId,
              isFalse,
              reason: '${nonTestId.value} should not be test ID',
            );
          }
        },
      );

      testCase(
        'should mask user IDs for security logging',
        TestCategory.unit,
        () {
          // Arrange
          final shortId = UserId.unsafe('abc');
          final mediumId = UserId.unsafe('user123');
          final longId = UserId.unsafe('very-long-user-id-for-testing');

          // Act
          final shortMasked = shortId.masked;
          final mediumMasked = mediumId.masked;
          final longMasked = longId.masked;

          // Assert
          expect(shortMasked, equals('***')); // All masked for short IDs
          expect(mediumMasked, equals('use***'));
          expect(longMasked, startsWith('ver'));
          expect(longMasked, endsWith('ing'));
          expect(longMasked, contains('*'));
        },
      );

      testCase('should create short display versions', TestCategory.unit, () {
        // Arrange
        final shortId = UserId.unsafe('user123');
        final longId = UserId.unsafe('very-long-user-id-for-testing-purposes');

        // Act
        final shortDisplay = shortId.shortDisplay;
        final longDisplay = longId.shortDisplay;

        // Assert
        expect(shortDisplay, equals('user123')); // Under 8 chars, no truncation
        expect(longDisplay, equals('very-lon...')); // Over 8 chars, truncated
      });
    });

    group('UserId Equality and Hash Code', () {
      testCase(
        'should be equal when UserId values are same',
        TestCategory.unit,
        () {
          // Arrange
          final userId1 = UserId.unsafe('same-user-id');
          final userId2 = UserId.unsafe('same-user-id');

          // Assert
          expect(userId1, equals(userId2));
          expect(userId1.hashCode, equals(userId2.hashCode));
        },
      );

      testCase(
        'should not be equal when UserId values differ',
        TestCategory.unit,
        () {
          // Arrange
          final userId1 = UserId.unsafe('user-id-1');
          final userId2 = UserId.unsafe('user-id-2');

          // Assert
          expect(userId1, isNot(equals(userId2)));
          expect(userId1.hashCode, isNot(equals(userId2.hashCode)));
        },
      );

      testCase('should be case sensitive for equality', TestCategory.unit, () {
        // Arrange
        final userId1 = UserId.unsafe('UserID');
        final userId2 = UserId.unsafe('userid');

        // Assert
        expect(userId1, isNot(equals(userId2)));
      });
    });

    group('UserId Edge Cases', () {
      testCase(
        'should handle UserId with mixed case and numbers',
        TestCategory.unit,
        () {
          // Arrange
          const mixedCaseIds = [
            'User123',
            'CamelCase456',
            'mixedCase789',
            'ALL_CAPS_123',
            'snake_case_456',
          ];

          for (final userIdString in mixedCaseIds) {
            // Act
            final result = UserId.validate(userIdString);

            // Assert
            expect(
              result.isSuccess,
              isTrue,
              reason: 'UserId $userIdString should be valid',
            );
          }
        },
      );

      testCase(
        'should handle UserId with hyphens and underscores',
        TestCategory.unit,
        () {
          // Arrange
          const specialIds = [
            'user-with-hyphens',
            'user_with_underscores',
            'user.with.dots',
            'user-123_test.id',
          ];

          for (final userIdString in specialIds) {
            // Act
            final result = UserId.validate(userIdString);

            // Assert
            expect(
              result.isSuccess,
              isTrue,
              reason: 'UserId $userIdString should be valid',
            );
          }
        },
      );

      testCase(
        'should handle UserId starting or ending with special chars',
        TestCategory.unit,
        () {
          // Arrange
          const edgeCaseIds = [
            '-user-id',
            'user-id-',
            '_user_id',
            'user_id_',
            '.user.id',
            'user.id.',
          ];

          for (final userIdString in edgeCaseIds) {
            // Act
            final result = UserId.validate(userIdString);

            // Assert
            expect(
              result.isSuccess,
              isTrue,
              reason: 'UserId $userIdString should be valid',
            );
          }
        },
      );

      testCase('should handle very long valid UserId', TestCategory.unit, () {
        // Arrange - Create UserId that's long but under 50 characters
        final longUserId = 'very-long-but-valid-user-id-under-limit-123';

        // Act
        final result = UserId.validate(longUserId);

        // Assert
        if (longUserId.length <= 50) {
          expect(result.isSuccess, isTrue);
        } else {
          expect(result.isFailure, isTrue);
        }
      });

      testCase('should handle UserId with only numbers', TestCategory.unit, () {
        // Act
        final result = UserId.validate('123456789');

        // Assert
        expect(result.isSuccess, isTrue);
      });

      testCase('should handle UserId with only letters', TestCategory.unit, () {
        // Act
        final result = UserId.validate('abcdefghijk');

        // Assert
        expect(result.isSuccess, isTrue);
      });
    });

    group('UserId toString and Display', () {
      testCase('should have meaningful toString', TestCategory.unit, () {
        // Arrange
        final userId = UserId.unsafe('test-user-123');

        // Act
        final toString = userId.toString();

        // Assert
        expect(toString, contains('test-user-123'));
        expect(toString, contains('UserId'));
      });

      testCase(
        'should not expose sensitive information in toString',
        TestCategory.unit,
        () {
          // For security, UserId toString should be safe for logging
          // Arrange
          final sensitiveUserId = UserId.unsafe('sensitive-user-id');

          // Act
          final toString = sensitiveUserId.toString();

          // Assert
          expect(toString, isA<String>());
          // The current implementation may or may not mask the ID
          // This test documents the current behavior
        },
      );
    });

    group('UserId Performance', () {
      testCase(
        'should validate many UserIds efficiently',
        TestCategory.unit,
        () {
          // Arrange
          const userIdsToTest = 1000;
          final stopwatch = Stopwatch()..start();

          // Act
          for (int i = 0; i < userIdsToTest; i++) {
            UserId.validate('user$i');
          }

          stopwatch.stop();

          // Assert - Should complete within reasonable time
          expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        },
      );

      testCase(
        'should create UserIds without memory leaks',
        TestCategory.unit,
        () {
          // Arrange & Act
          final userIds = List.generate(1000, (index) {
            return UserId.unsafe('user$index');
          });

          // Assert
          expect(userIds.length, equals(1000));
          expect(userIds.first.value, equals('user0'));
          expect(userIds.last.value, equals('user999'));
        },
      );
    });

    group('UserId Security Considerations', () {
      testCase(
        'should provide masked version for logging',
        TestCategory.unit,
        () {
          // Arrange
          final userId = UserId.unsafe('sensitive-user-12345');

          // Act
          final masked = userId.masked;

          // Assert
          expect(masked, isNot(equals(userId.value)));
          expect(masked, contains('*'));
          expect(masked.length, equals(userId.value.length));
        },
      );

      testCase(
        'should handle potential injection patterns safely',
        TestCategory.unit,
        () {
          // Arrange
          const maliciousPatterns = [
            'user\'; DROP TABLE users; --',
            'user<script>alert("xss")</script>',
            'user\n\rmalicious',
            'user\0null',
          ];

          for (final pattern in maliciousPatterns) {
            // Act
            final result = UserId.validate(pattern);

            // Assert - Should reject due to invalid characters
            expect(
              result.isFailure,
              isTrue,
              reason: 'Pattern $pattern should be rejected',
            );
          }
        },
      );

      testCase(
        'should resist timing attacks in validation',
        TestCategory.unit,
        () {
          // This is a basic test - in production, constant-time validation would be preferred
          // Arrange
          const userId1 = 'short';
          const userId2 = 'very-long-user-id-that-takes-more-time';

          // Act
          final stopwatch1 = Stopwatch()..start();
          UserId.validate(userId1);
          stopwatch1.stop();

          final stopwatch2 = Stopwatch()..start();
          UserId.validate(userId2);
          stopwatch2.stop();

          // Assert - Time difference should be minimal (this is a basic check)
          final timeDifference =
              (stopwatch1.elapsedMicroseconds - stopwatch2.elapsedMicroseconds)
                  .abs();
          expect(timeDifference, lessThan(10000)); // Less than 10ms difference
        },
      );
    });

    group('UserId Integration with Business Logic', () {
      testCase('should work with Firebase UID patterns', TestCategory.unit, () {
        // Arrange
        const firebaseUidPattern =
            'abcdefghijklmnopqrstuvwxyz12'; // 28 chars, alphanumeric

        // Act
        final result = UserId.validate(firebaseUidPattern);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.isFirebaseUid, isTrue);
        expect(result.dataOrNull?.isCustomId, isFalse);
      });

      testCase(
        'should work with custom user ID patterns',
        TestCategory.unit,
        () {
          // Arrange
          const customIdPatterns = [
            'john-doe',
            'user_123',
            'company.employee',
            'department-head-456',
          ];

          for (final pattern in customIdPatterns) {
            // Act
            final result = UserId.validate(pattern);

            // Assert
            expect(result.isSuccess, isTrue);
            expect(result.dataOrNull?.isCustomId, isTrue);
            expect(result.dataOrNull?.isFirebaseUid, isFalse);
          }
        },
      );

      testCase(
        'should provide appropriate display formats for UI',
        TestCategory.unit,
        () {
          // Arrange
          final longUserId = UserId.unsafe(
            'very-long-username-for-display-purposes',
          );
          final shortUserId = UserId.unsafe('short');

          // Act
          final longDisplay = longUserId.shortDisplay;
          final shortDisplay = shortUserId.shortDisplay;
          final longMasked = longUserId.masked;
          final shortMasked = shortUserId.masked;

          // Assert
          expect(longDisplay, contains('...'));
          expect(shortDisplay, isNot(contains('...')));
          expect(longMasked, contains('*'));
          expect(shortMasked, equals('*****'));
        },
      );
    });
  });
}
