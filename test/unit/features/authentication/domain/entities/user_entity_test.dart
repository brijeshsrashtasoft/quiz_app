import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import '../../../../../test_config.dart';

/// Comprehensive unit tests for UserEntity domain entity
/// Following TDD principles and CLAUDE.md testing patterns
/// Covers: Creation, equality, extensions, edge cases
void main() {
  testGroup('UserEntity', TestCategory.unit, () {
    late DateTime testDate;
    late UserStats testStats;
    late UserPreferences testPreferences;

    setUpAll(() {
      testDate = DateTime.parse('2024-01-01T00:00:00.000Z');
      testStats = UserStats(
        totalQuizzes: 10,
        totalGamesPlayed: 20,
        totalGamesWon: 5,
        averageScore: 85.5,
        lastGameDate: testDate,
      );
      testPreferences = UserPreferences(
        soundEnabled: true,
        notificationsEnabled: false,
        theme: 'dark',
        language: 'es',
      );
    });

    group('Creation and Properties', () {
      testCase(
        'should create UserEntity with required fields only',
        TestCategory.unit,
        () {
          // Act
          final user = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: testDate,
          );

          // Assert
          expect(user.id, equals('user-123'));
          expect(user.name, equals('John Doe'));
          expect(user.email, equals('john@example.com'));
          expect(user.createdAt, equals(testDate));
          expect(user.stats, isNull);
          expect(user.profileImageUrl, isNull);
          expect(user.preferences, isNull);
        },
      );

      testCase(
        'should create UserEntity with all fields',
        TestCategory.unit,
        () {
          // Act
          final user = UserEntity(
            id: 'user-123',
            name: 'Jane Smith',
            email: 'jane@example.com',
            createdAt: testDate,
            stats: testStats,
            profileImageUrl: 'https://example.com/profile.jpg',
            preferences: testPreferences,
          );

          // Assert
          expect(user.id, equals('user-123'));
          expect(user.name, equals('Jane Smith'));
          expect(user.email, equals('jane@example.com'));
          expect(user.createdAt, equals(testDate));
          expect(user.stats, equals(testStats));
          expect(
            user.profileImageUrl,
            equals('https://example.com/profile.jpg'),
          );
          expect(user.preferences, equals(testPreferences));
        },
      );

      testCase(
        'should support copyWith for immutable updates',
        TestCategory.unit,
        () {
          // Arrange
          final originalUser = UserEntity(
            id: 'user-123',
            name: 'Original Name',
            email: 'original@example.com',
            createdAt: testDate,
          );

          // Act
          final updatedUser = originalUser.copyWith(
            name: 'Updated Name',
            email: 'updated@example.com',
          );

          // Assert
          expect(updatedUser.id, equals(originalUser.id));
          expect(updatedUser.name, equals('Updated Name'));
          expect(updatedUser.email, equals('updated@example.com'));
          expect(updatedUser.createdAt, equals(originalUser.createdAt));
          expect(
            originalUser.name,
            equals('Original Name'),
          ); // Original unchanged
        },
      );
    });

    group('Equality and Hash Code', () {
      testCase(
        'should be equal when all properties match',
        TestCategory.unit,
        () {
          // Arrange
          final user1 = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: testDate,
            stats: testStats,
          );

          final user2 = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: testDate,
            stats: testStats,
          );

          // Assert
          expect(user1, equals(user2));
          expect(user1.hashCode, equals(user2.hashCode));
        },
      );

      testCase('should not be equal when IDs differ', TestCategory.unit, () {
        // Arrange
        final user1 = UserEntity(
          id: 'user-123',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: testDate,
        );

        final user2 = UserEntity(
          id: 'user-456',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: testDate,
        );

        // Assert
        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      testCase(
        'should not be equal when any property differs',
        TestCategory.unit,
        () {
          // Arrange
          final baseUser = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: testDate,
          );

          final differentUsers = [
            baseUser.copyWith(name: 'Jane Doe'),
            baseUser.copyWith(email: 'jane@example.com'),
            baseUser.copyWith(createdAt: DateTime.now()),
          ];

          // Assert
          for (final user in differentUsers) {
            expect(baseUser, isNot(equals(user)));
          }
        },
      );
    });

    group('Business Logic Extensions', () {
      group('isProfileComplete', () {
        testCase(
          'should return true when name and email are not empty',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: testDate,
            );

            // Assert
            expect(user.isProfileComplete, isTrue);
          },
        );

        testCase(
          'should return false when name is empty',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: '',
              email: 'john@example.com',
              createdAt: testDate,
            );

            // Assert
            expect(user.isProfileComplete, isFalse);
          },
        );

        testCase(
          'should return false when email is empty',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: '',
              createdAt: testDate,
            );

            // Assert
            expect(user.isProfileComplete, isFalse);
          },
        );
      });

      group('winRate', () {
        testCase('should return 0.0 when stats is null', TestCategory.unit, () {
          // Arrange
          final user = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: testDate,
          );

          // Assert
          expect(user.winRate, equals(0.0));
        });

        testCase(
          'should return 0.0 when totalGamesPlayed is 0',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: testDate,
              stats: UserStats(
                totalQuizzes: 5,
                totalGamesPlayed: 0,
                totalGamesWon: 0,
                averageScore: 0.0,
              ),
            );

            // Assert
            expect(user.winRate, equals(0.0));
          },
        );

        testCase(
          'should calculate correct win rate percentage',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: testDate,
              stats: UserStats(
                totalQuizzes: 10,
                totalGamesPlayed: 20,
                totalGamesWon: 5,
                averageScore: 85.5,
              ),
            );

            // Assert
            expect(user.winRate, equals(25.0)); // 5/20 * 100 = 25%
          },
        );

        testCase('should handle perfect win rate', TestCategory.unit, () {
          // Arrange
          final user = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: testDate,
            stats: UserStats(
              totalQuizzes: 10,
              totalGamesPlayed: 10,
              totalGamesWon: 10,
              averageScore: 100.0,
            ),
          );

          // Assert
          expect(user.winRate, equals(100.0));
        });
      });

      group('isExperiencedPlayer', () {
        testCase(
          'should return false when stats is null',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: testDate,
            );

            // Assert
            expect(user.isExperiencedPlayer, isFalse);
          },
        );

        testCase(
          'should return false when totalGamesPlayed is less than 10',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: testDate,
              stats: UserStats(
                totalQuizzes: 5,
                totalGamesPlayed: 9,
                totalGamesWon: 3,
                averageScore: 75.0,
              ),
            );

            // Assert
            expect(user.isExperiencedPlayer, isFalse);
          },
        );

        testCase(
          'should return true when totalGamesPlayed is 10 or more',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: testDate,
              stats: UserStats(
                totalQuizzes: 10,
                totalGamesPlayed: 10,
                totalGamesWon: 5,
                averageScore: 85.0,
              ),
            );

            // Assert
            expect(user.isExperiencedPlayer, isTrue);
          },
        );
      });

      group('isNewUser', () {
        testCase(
          'should return true when user created within last 7 days',
          TestCategory.unit,
          () {
            // Arrange
            final recentDate = DateTime.now().subtract(Duration(days: 3));
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: recentDate,
            );

            // Assert
            expect(user.isNewUser, isTrue);
          },
        );

        testCase(
          'should return false when user created more than 7 days ago',
          TestCategory.unit,
          () {
            // Arrange
            final oldDate = DateTime.now().subtract(Duration(days: 10));
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: oldDate,
            );

            // Assert
            expect(user.isNewUser, isFalse);
          },
        );

        testCase(
          'should return true when user created exactly 7 days ago',
          TestCategory.unit,
          () {
            // Arrange
            final exactDate = DateTime.now().subtract(Duration(days: 7));
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: exactDate,
            );

            // Assert
            expect(user.isNewUser, isTrue);
          },
        );
      });

      group('canHostGames', () {
        testCase(
          'should return false when profile is incomplete',
          TestCategory.unit,
          () {
            // Arrange
            final oldDate = DateTime.now().subtract(Duration(days: 10));
            final user = UserEntity(
              id: 'user-123',
              name: '', // Incomplete profile
              email: 'john@example.com',
              createdAt: oldDate,
            );

            // Assert
            expect(user.canHostGames, isFalse);
          },
        );

        testCase('should return false when user is new', TestCategory.unit, () {
          // Arrange
          final recentDate = DateTime.now().subtract(Duration(days: 3));
          final user = UserEntity(
            id: 'user-123',
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: recentDate, // New user
          );

          // Assert
          expect(user.canHostGames, isFalse);
        });

        testCase(
          'should return true when profile complete and user not new',
          TestCategory.unit,
          () {
            // Arrange
            final oldDate = DateTime.now().subtract(Duration(days: 10));
            final user = UserEntity(
              id: 'user-123',
              name: 'John Doe',
              email: 'john@example.com',
              createdAt: oldDate,
            );

            // Assert
            expect(user.canHostGames, isTrue);
          },
        );
      });

      group('isAdmin', () {
        testCase(
          'should return true for predefined admin emails',
          TestCategory.unit,
          () {
            // Arrange
            final adminEmails = ['admin@quizapp.com', 'support@quizapp.com'];

            for (final email in adminEmails) {
              final user = UserEntity(
                id: 'user-123',
                name: 'Admin User',
                email: email,
                createdAt: testDate,
              );

              // Assert
              expect(
                user.isAdmin,
                isTrue,
                reason: 'Email $email should be admin',
              );
            }
          },
        );

        testCase(
          'should return true for @quizapp.com domain emails',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'Company User',
              email: 'employee@quizapp.com',
              createdAt: testDate,
            );

            // Assert
            expect(user.isAdmin, isTrue);
          },
        );

        testCase(
          'should return false for regular user emails',
          TestCategory.unit,
          () {
            // Arrange
            final regularEmails = [
              'user@gmail.com',
              'test@example.com',
              'admin@other.com',
              'support@different.org',
            ];

            for (final email in regularEmails) {
              final user = UserEntity(
                id: 'user-123',
                name: 'Regular User',
                email: email,
                createdAt: testDate,
              );

              // Assert
              expect(
                user.isAdmin,
                isFalse,
                reason: 'Email $email should not be admin',
              );
            }
          },
        );

        testCase(
          'should handle case insensitive email checking',
          TestCategory.unit,
          () {
            // Arrange
            final user = UserEntity(
              id: 'user-123',
              name: 'Admin User',
              email: 'ADMIN@QUIZAPP.COM',
              createdAt: testDate,
            );

            // Assert
            expect(user.isAdmin, isTrue);
          },
        );
      });
    });

    group('Edge Cases', () {
      testCase('should handle empty strings gracefully', TestCategory.unit, () {
        // Act & Assert - Should not throw
        expect(
          () => UserEntity(id: '', name: '', email: '', createdAt: testDate),
          returnsNormally,
        );
      });

      testCase('should handle very long strings', TestCategory.unit, () {
        // Arrange
        final longString = 'a' * 1000;

        // Act & Assert - Should not throw
        expect(
          () => UserEntity(
            id: longString,
            name: longString,
            email: '${longString}@example.com',
            createdAt: testDate,
          ),
          returnsNormally,
        );
      });

      testCase(
        'should handle special characters in strings',
        TestCategory.unit,
        () {
          // Act & Assert - Should not throw
          expect(
            () => UserEntity(
              id: 'user-123!@#',
              name: 'José María',
              email: 'josé@éxample.com',
              createdAt: testDate,
            ),
            returnsNormally,
          );
        },
      );

      testCase('should handle future dates', TestCategory.unit, () {
        // Arrange
        final futureDate = DateTime.now().add(Duration(days: 365));

        // Act & Assert - Should not throw
        expect(
          () => UserEntity(
            id: 'user-123',
            name: 'Future User',
            email: 'future@example.com',
            createdAt: futureDate,
          ),
          returnsNormally,
        );
      });
    });

    group('UserStats Entity', () {
      testCase('should create with default values', TestCategory.unit, () {
        // Act
        final stats = UserStats();

        // Assert
        expect(stats.totalQuizzes, equals(0));
        expect(stats.totalGamesPlayed, equals(0));
        expect(stats.totalGamesWon, equals(0));
        expect(stats.averageScore, equals(0.0));
        expect(stats.lastGameDate, isNull);
      });

      testCase('should create with custom values', TestCategory.unit, () {
        // Act
        final stats = UserStats(
          totalQuizzes: 15,
          totalGamesPlayed: 30,
          totalGamesWon: 12,
          averageScore: 92.5,
          lastGameDate: testDate,
        );

        // Assert
        expect(stats.totalQuizzes, equals(15));
        expect(stats.totalGamesPlayed, equals(30));
        expect(stats.totalGamesWon, equals(12));
        expect(stats.averageScore, equals(92.5));
        expect(stats.lastGameDate, equals(testDate));
      });

      testCase('should support equality comparison', TestCategory.unit, () {
        // Arrange
        final stats1 = UserStats(
          totalQuizzes: 10,
          totalGamesPlayed: 20,
          totalGamesWon: 5,
          averageScore: 85.5,
          lastGameDate: testDate,
        );

        final stats2 = UserStats(
          totalQuizzes: 10,
          totalGamesPlayed: 20,
          totalGamesWon: 5,
          averageScore: 85.5,
          lastGameDate: testDate,
        );

        // Assert
        expect(stats1, equals(stats2));
        expect(stats1.hashCode, equals(stats2.hashCode));
      });
    });

    group('UserPreferences Entity', () {
      testCase('should create with default values', TestCategory.unit, () {
        // Act
        final preferences = UserPreferences();

        // Assert
        expect(preferences.soundEnabled, isTrue);
        expect(preferences.notificationsEnabled, isTrue);
        expect(preferences.theme, equals('light'));
        expect(preferences.language, equals('en'));
      });

      testCase('should create with custom values', TestCategory.unit, () {
        // Act
        final preferences = UserPreferences(
          soundEnabled: false,
          notificationsEnabled: true,
          theme: 'dark',
          language: 'es',
        );

        // Assert
        expect(preferences.soundEnabled, isFalse);
        expect(preferences.notificationsEnabled, isTrue);
        expect(preferences.theme, equals('dark'));
        expect(preferences.language, equals('es'));
      });

      testCase('should support copyWith updates', TestCategory.unit, () {
        // Arrange
        final originalPrefs = UserPreferences();

        // Act
        final updatedPrefs = originalPrefs.copyWith(
          theme: 'dark',
          language: 'fr',
        );

        // Assert
        expect(updatedPrefs.soundEnabled, equals(originalPrefs.soundEnabled));
        expect(
          updatedPrefs.notificationsEnabled,
          equals(originalPrefs.notificationsEnabled),
        );
        expect(updatedPrefs.theme, equals('dark'));
        expect(updatedPrefs.language, equals('fr'));
      });
    });
  });
}
