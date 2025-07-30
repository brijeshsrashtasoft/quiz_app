import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/data/models/user_model.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
// import '../../../../../helpers/test_utilities.dart'; // Not used in this test

void main() {
  group('UserModel', () {
    late UserModel testUserModel;
    late DateTime testDateTime;
    late UserStatsModel testStats;
    late UserPreferencesModel testPreferences;

    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30);
      testStats = const UserStatsModel(
        totalQuizzes: 5,
        totalGamesPlayed: 10,
        totalGamesWon: 3,
        averageScore: 85.5,
      );
      testPreferences = const UserPreferencesModel(
        soundEnabled: true,
        notificationsEnabled: false,
        theme: 'dark',
        language: 'es',
      );
      testUserModel = UserModel(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: testDateTime,
        stats: testStats,
        profileImageUrl: 'https://example.com/avatar.png',
        preferences: testPreferences,
      );
    });

    group('fromFirestore', () {
      test('should create UserModel from Firestore document data', () {
        // Arrange
        final firestoreData = {
          'id': 'test-user-id',
          'name': 'Test User',
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(testDateTime),
          'stats': {
            'totalQuizzes': 5,
            'totalGamesPlayed': 10,
            'totalGamesWon': 3,
            'averageScore': 85.5,
          },
          'profileImageUrl': 'https://example.com/avatar.png',
          'preferences': {
            'soundEnabled': true,
            'notificationsEnabled': false,
            'theme': 'dark',
            'language': 'es',
          },
        };

        // Act
        final result = UserModel.fromFirestore(firestoreData);

        // Assert
        expect(result.id, 'test-user-id');
        expect(result.name, 'Test User');
        expect(result.email, 'test@example.com');
        expect(result.createdAt, testDateTime);
        expect(result.stats?.totalQuizzes, 5);
        expect(result.stats?.averageScore, 85.5);
        expect(result.profileImageUrl, 'https://example.com/avatar.png');
        expect(result.preferences?.theme, 'dark');
        expect(result.preferences?.language, 'es');
      });

      test('should handle optional fields being null', () {
        // Arrange
        final firestoreData = {
          'id': 'test-user-id',
          'name': 'Test User',
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(testDateTime),
        };

        // Act
        final result = UserModel.fromFirestore(firestoreData);

        // Assert
        expect(result.id, 'test-user-id');
        expect(result.name, 'Test User');
        expect(result.email, 'test@example.com');
        expect(result.createdAt, testDateTime);
        expect(result.stats, isNull);
        expect(result.profileImageUrl, isNull);
        expect(result.preferences, isNull);
      });

      test('should handle malformed Firestore data gracefully', () {
        // Arrange
        final malformedData = {
          'id': 'test-user-id',
          'name': 'Test User',
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(testDateTime),
          'stats': 'invalid-stats', // Invalid type
          'preferences': 123, // Invalid type
        };

        // Act & Assert
        expect(
          () => UserModel.fromFirestore(malformedData),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('fromJson', () {
      test('should create UserModel from JSON', () {
        // Arrange
        final jsonData = {
          'id': 'test-user-id',
          'name': 'Test User',
          'email': 'test@example.com',
          'createdAt': testDateTime.toIso8601String(),
          'stats': {
            'totalQuizzes': 5,
            'totalGamesPlayed': 10,
            'totalGamesWon': 3,
            'averageScore': 85.5,
            'lastGameDate': null,
          },
          'profileImageUrl': 'https://example.com/avatar.png',
          'preferences': {
            'soundEnabled': true,
            'notificationsEnabled': false,
            'theme': 'dark',
            'language': 'es',
          },
        };

        // Act
        final result = UserModel.fromJson(jsonData);

        // Assert
        expect(result.id, 'test-user-id');
        expect(result.name, 'Test User');
        expect(result.email, 'test@example.com');
        expect(result.stats?.totalQuizzes, 5);
        expect(result.preferences?.theme, 'dark');
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON', () {
        // Act
        final result = testUserModel.toJson();

        // Assert
        expect(result['id'], 'test-user-id');
        expect(result['name'], 'Test User');
        expect(result['email'], 'test@example.com');
        expect(result['stats'], isNotNull);
        expect(result['preferences'], isNotNull);
      });
    });

    group('toEntity', () {
      test('should convert UserModel to UserEntity correctly', () {
        // Act
        final result = testUserModel.toEntity();

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.id, testUserModel.id);
        expect(result.name, testUserModel.name);
        expect(result.email, testUserModel.email);
        expect(result.createdAt, testUserModel.createdAt);
        expect(result.stats?.totalQuizzes, testUserModel.stats?.totalQuizzes);
        expect(result.preferences?.theme, testUserModel.preferences?.theme);
      });

      test('should handle null optional fields', () {
        // Arrange
        final modelWithNulls = UserModel(
          id: 'test-id',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: testDateTime,
        );

        // Act
        final result = modelWithNulls.toEntity();

        // Assert
        expect(result.stats, isNull);
        expect(result.profileImageUrl, isNull);
        expect(result.preferences, isNull);
      });
    });

    group('toFirestore', () {
      test('should convert UserModel to Firestore format', () {
        // Act
        final result = testUserModel.toFirestore();

        // Assert
        expect(result['id'], 'test-user-id');
        expect(result['name'], 'Test User');
        expect(result['email'], 'test@example.com');
        expect(result['createdAt'], isA<Timestamp>());
        expect(result['stats'], isA<Map<String, dynamic>>());
        expect(result['preferences'], isA<Map<String, dynamic>>());
        expect(result['profileImageUrl'], 'https://example.com/avatar.png');
      });

      test('should handle null optional fields in Firestore conversion', () {
        // Arrange
        final modelWithNulls = UserModel(
          id: 'test-id',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: testDateTime,
        );

        // Act
        final result = modelWithNulls.toFirestore();

        // Assert
        expect(result.containsKey('stats'), false);
        expect(result.containsKey('profileImageUrl'), false);
        expect(result.containsKey('preferences'), false);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Act
        final result = testUserModel.copyWith(
          name: 'Updated Name',
          email: 'updated@example.com',
        );

        // Assert
        expect(result.name, 'Updated Name');
        expect(result.email, 'updated@example.com');
        expect(result.id, testUserModel.id); // Unchanged
        expect(result.createdAt, testUserModel.createdAt); // Unchanged
      });

      test('should preserve original values when not specified', () {
        // Act
        final result = testUserModel.copyWith();

        // Assert
        expect(result, equals(testUserModel));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        // Arrange
        final other = UserModel(
          id: 'test-user-id',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: testDateTime,
          stats: testStats,
          profileImageUrl: 'https://example.com/avatar.png',
          preferences: testPreferences,
        );

        // Assert
        expect(testUserModel, equals(other));
        expect(testUserModel.hashCode, equals(other.hashCode));
      });

      test('should not be equal when fields differ', () {
        // Arrange
        final other = testUserModel.copyWith(name: 'Different Name');

        // Assert
        expect(testUserModel, isNot(equals(other)));
        expect(testUserModel.hashCode, isNot(equals(other.hashCode)));
      });
    });
  });

  group('UserStatsModel', () {
    test('should create with default values', () {
      // Act
      const result = UserStatsModel();

      // Assert
      expect(result.totalQuizzes, 0);
      expect(result.totalGamesPlayed, 0);
      expect(result.totalGamesWon, 0);
      expect(result.averageScore, 0.0);
      expect(result.lastGameDate, isNull);
    });

    test('should create from Firestore map with all fields', () {
      // Arrange
      final testDate = DateTime.now();
      final data = {
        'totalQuizzes': 8,
        'totalGamesPlayed': 15,
        'totalGamesWon': 5,
        'averageScore': 92.5,
        'lastGameDate': Timestamp.fromDate(testDate),
      };

      // Act
      final result = UserStatsModel.fromMap(data);

      // Assert
      expect(result.totalQuizzes, 8);
      expect(result.totalGamesPlayed, 15);
      expect(result.totalGamesWon, 5);
      expect(result.averageScore, 92.5);
      expect(result.lastGameDate, testDate);
    });

    test('should handle missing fields with defaults', () {
      // Arrange
      final data = <String, dynamic>{};

      // Act
      final result = UserStatsModel.fromMap(data);

      // Assert
      expect(result.totalQuizzes, 0);
      expect(result.totalGamesPlayed, 0);
      expect(result.totalGamesWon, 0);
      expect(result.averageScore, 0.0);
      expect(result.lastGameDate, isNull);
    });

    test('should convert to domain entity correctly', () {
      // Arrange
      const model = UserStatsModel(
        totalQuizzes: 5,
        totalGamesPlayed: 10,
        totalGamesWon: 3,
        averageScore: 85.5,
      );

      // Act
      final result = model.toEntity();

      // Assert
      expect(result, isA<UserStats>());
      expect(result.totalQuizzes, 5);
      expect(result.totalGamesPlayed, 10);
      expect(result.totalGamesWon, 3);
      expect(result.averageScore, 85.5);
    });

    test('should convert to Firestore format correctly', () {
      // Arrange
      final testDate = DateTime.now();
      final model = UserStatsModel(
        totalQuizzes: 5,
        totalGamesPlayed: 10,
        totalGamesWon: 3,
        averageScore: 85.5,
        lastGameDate: testDate,
      );

      // Act
      final result = model.toFirestore();

      // Assert
      expect(result['totalQuizzes'], 5);
      expect(result['totalGamesPlayed'], 10);
      expect(result['totalGamesWon'], 3);
      expect(result['averageScore'], 85.5);
      expect(result['lastGameDate'], isA<Timestamp>());
    });
  });

  group('UserPreferencesModel', () {
    test('should create with default values', () {
      // Act
      const result = UserPreferencesModel();

      // Assert
      expect(result.soundEnabled, true);
      expect(result.notificationsEnabled, true);
      expect(result.theme, 'light');
      expect(result.language, 'en');
    });

    test('should create from Firestore map', () {
      // Arrange
      final data = {
        'soundEnabled': false,
        'notificationsEnabled': true,
        'theme': 'dark',
        'language': 'fr',
      };

      // Act
      final result = UserPreferencesModel.fromMap(data);

      // Assert
      expect(result.soundEnabled, false);
      expect(result.notificationsEnabled, true);
      expect(result.theme, 'dark');
      expect(result.language, 'fr');
    });

    test('should handle missing fields with defaults', () {
      // Arrange
      final data = <String, dynamic>{};

      // Act
      final result = UserPreferencesModel.fromMap(data);

      // Assert
      expect(result.soundEnabled, true);
      expect(result.notificationsEnabled, true);
      expect(result.theme, 'light');
      expect(result.language, 'en');
    });

    test('should convert to domain entity correctly', () {
      // Arrange
      const model = UserPreferencesModel(
        soundEnabled: false,
        notificationsEnabled: true,
        theme: 'dark',
        language: 'es',
      );

      // Act
      final result = model.toEntity();

      // Assert
      expect(result, isA<UserPreferences>());
      expect(result.soundEnabled, false);
      expect(result.notificationsEnabled, true);
      expect(result.theme, 'dark');
      expect(result.language, 'es');
    });

    test('should convert to Firestore format correctly', () {
      // Arrange
      const model = UserPreferencesModel(
        soundEnabled: false,
        notificationsEnabled: true,
        theme: 'dark',
        language: 'es',
      );

      // Act
      final result = model.toFirestore();

      // Assert
      expect(result['soundEnabled'], false);
      expect(result['notificationsEnabled'], true);
      expect(result['theme'], 'dark');
      expect(result['language'], 'es');
    });
  });

  group('Entity to Model Conversions', () {
    test('UserEntity should convert to UserModel correctly', () {
      // Arrange
      final testDate = DateTime.now();
      final entity = UserEntity(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: testDate,
        stats: const UserStats(
          totalQuizzes: 5,
          totalGamesPlayed: 10,
          totalGamesWon: 3,
          averageScore: 85.5,
        ),
        preferences: const UserPreferences(
          soundEnabled: false,
          notificationsEnabled: true,
          theme: 'dark',
          language: 'fr',
        ),
      );

      // Act
      final result = entity.toModel();

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, 'test-id');
      expect(result.name, 'Test User');
      expect(result.email, 'test@example.com');
      expect(result.createdAt, testDate);
      expect(result.stats?.totalQuizzes, 5);
      expect(result.preferences?.theme, 'dark');
    });

    test('UserStats should convert to UserStatsModel correctly', () {
      // Arrange
      final testDate = DateTime.now();
      final entity = UserStats(
        totalQuizzes: 5,
        totalGamesPlayed: 10,
        totalGamesWon: 3,
        averageScore: 85.5,
        lastGameDate: testDate,
      );

      // Act
      final result = entity.toModel();

      // Assert
      expect(result, isA<UserStatsModel>());
      expect(result.totalQuizzes, 5);
      expect(result.totalGamesPlayed, 10);
      expect(result.totalGamesWon, 3);
      expect(result.averageScore, 85.5);
      expect(result.lastGameDate, testDate);
    });

    test(
      'UserPreferences should convert to UserPreferencesModel correctly',
      () {
        // Arrange
        const entity = UserPreferences(
          soundEnabled: false,
          notificationsEnabled: true,
          theme: 'dark',
          language: 'es',
        );

        // Act
        final result = entity.toModel();

        // Assert
        expect(result, isA<UserPreferencesModel>());
        expect(result.soundEnabled, false);
        expect(result.notificationsEnabled, true);
        expect(result.theme, 'dark');
        expect(result.language, 'es');
      },
    );
  });

  group('Edge Cases and Validation', () {
    test('should handle very large numbers in stats', () {
      // Arrange
      const model = UserStatsModel(
        totalQuizzes: 999999,
        totalGamesPlayed: 999999,
        totalGamesWon: 999999,
        averageScore: 100.0,
      );

      // Act
      final firestoreData = model.toFirestore();
      final entity = model.toEntity();

      // Assert
      expect(firestoreData['totalQuizzes'], 999999);
      expect(entity.totalQuizzes, 999999);
    });

    test('should handle edge case scores', () {
      // Arrange
      const model = UserStatsModel(averageScore: 0.0);

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.averageScore, 0.0);
    });

    test('should handle empty string preferences', () {
      // Arrange
      const model = UserPreferencesModel(theme: '', language: '');

      // Act
      final result = model.toFirestore();

      // Assert
      expect(result['theme'], '');
      expect(result['language'], '');
    });

    test('should handle special characters in user data', () {
      // Arrange
      final model = UserModel(
        id: 'test-id',
        name: 'João Müller',
        email: 'joão@müller.com',
        createdAt: DateTime.now(),
      );

      // Act
      final entity = model.toEntity();
      final firestore = model.toFirestore();

      // Assert
      expect(entity.name, 'João Müller');
      expect(firestore['name'], 'João Müller');
    });

    test('should maintain precision in decimal values', () {
      // Arrange
      const model = UserStatsModel(averageScore: 85.567890123456789);

      // Act
      final entity = model.toEntity();
      final firestore = model.toFirestore();

      // Assert
      expect(entity.averageScore, 85.567890123456789);
      expect(firestore['averageScore'], 85.567890123456789);
    });
  });

  group('Performance Tests', () {
    test('should handle model creation efficiently', () {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      for (int i = 0; i < 1000; i++) {
        UserModel(
          id: 'test-id-$i',
          name: 'Test User $i',
          email: 'test$i@example.com',
          createdAt: DateTime.now(),
        );
      }

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
    });

    test('should handle conversions efficiently', () {
      // Arrange
      final models = List.generate(
        100,
        (i) => UserModel(
          id: 'test-id-$i',
          name: 'Test User $i',
          email: 'test$i@example.com',
          createdAt: DateTime.now(),
          stats: const UserStatsModel(totalQuizzes: 5),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Act
      for (final model in models) {
        model.toEntity();
        model.toFirestore();
      }

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should be fast
    });
  });
}
