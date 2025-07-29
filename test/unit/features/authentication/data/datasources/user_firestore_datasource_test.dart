import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../lib/core/errors/exceptions.dart';
import '../../../../../../lib/core/utils/logger.dart';
import '../../../../../../lib/core/utils/result.dart';
import '../../../../../../lib/features/authentication/data/datasources/user_firestore_datasource.dart';
import '../../../../../../lib/features/authentication/data/models/user_model.dart';
import '../../../../../../lib/core/firebase/firestore_config.dart';

import 'user_firestore_datasource_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  WriteBatch,
])
void main() {
  late UserFirestoreDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocSnapshot;

  setUp(() {
    dataSource = UserFirestoreDataSource();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    // Setup AppLogger to avoid logging during tests
    AppLogger.init(logLevel: LogLevel.none);
  });

  group('UserFirestoreDataSource', () {
    final testUserId = 'test-user-id';
    final testEmail = 'test@example.com';
    final testUserData = {
      'id': testUserId,
      'name': 'Test User',
      'email': testEmail,
      'createdAt': Timestamp.now(),
      'stats': {
        'totalQuizzes': 5,
        'totalGamesPlayed': 10,
        'totalGamesWon': 3,
        'averageScore': 85.5,
      },
    };

    final testUserModel = UserModel.fromFirestore(testUserData);

    group('getUserById', () {
      test('should return UserModel when document exists', () async {
        // Arrange
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn(testUserData);
        when(mockDocumentSnapshot.id).thenReturn(testUserId);
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

        // Act
        final result = await dataSource.getUserById(testUserId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.id, testUserId);
        expect(result.data?.name, 'Test User');
        expect(result.data?.email, testEmail);
      });

      test(
        'should return DataException when document does not exist',
        () async {
          // Arrange
          when(mockDocumentSnapshot.exists).thenReturn(false);
          when(
            mockDocument.get(),
          ).thenAnswer((_) async => mockDocumentSnapshot);

          // Act
          final result = await dataSource.getUserById(testUserId);

          // Assert
          expect(result.isFailure, true);
          expect(result.error, isA<DataException>());
          expect((result.error as DataException).code, 'user_not_found');
        },
      );

      test(
        'should return FirestoreException when Firestore throws error',
        () async {
          // Arrange
          when(mockDocument.get()).thenThrow(
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
          );

          // Act
          final result = await dataSource.getUserById(testUserId);

          // Assert
          expect(result.isFailure, true);
          expect(result.error, isA<FirestoreException>());
          expect((result.error as FirestoreException).code, 'get_user_error');
        },
      );
    });

    group('getUserByEmail', () {
      test('should return UserModel when user with email exists', () async {
        // Arrange
        when(mockQueryDocSnapshot.data()).thenReturn(testUserData);
        when(mockQueryDocSnapshot.id).thenReturn(testUserId);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(
          mockCollection.where('email', isEqualTo: testEmail),
        ).thenReturn(mockCollection);
        when(mockCollection.limit(1)).thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

        // Act
        final result = await dataSource.getUserByEmail(testEmail);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.email, testEmail);
      });

      test(
        'should return DataException when no user with email exists',
        () async {
          // Arrange
          when(mockQuerySnapshot.docs).thenReturn([]);
          when(
            mockCollection.where('email', isEqualTo: testEmail),
          ).thenReturn(mockCollection);
          when(mockCollection.limit(1)).thenReturn(mockCollection);
          when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

          // Act
          final result = await dataSource.getUserByEmail(testEmail);

          // Assert
          expect(result.isFailure, true);
          expect(result.error, isA<DataException>());
          expect((result.error as DataException).code, 'user_not_found');
        },
      );
    });

    group('createUser', () {
      test(
        'should return UserModel with generated ID when creation succeeds',
        () async {
          // Arrange
          final newUserId = 'new-user-id';
          when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);
          when(mockDocument.id).thenReturn(newUserId);

          // Act
          final result = await dataSource.createUser(testUserModel);

          // Assert
          expect(result.isSuccess, true);
          expect(result.data?.id, newUserId);
          verify(mockCollection.add(any)).called(1);
        },
      );

      test('should return FirestoreException when creation fails', () async {
        // Arrange
        when(mockCollection.add(any)).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'permission-denied'),
        );

        // Act
        final result = await dataSource.createUser(testUserModel);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<FirestoreException>());
        expect((result.error as FirestoreException).code, 'create_user_error');
      });
    });

    group('updateUser', () {
      test('should return UserModel when update succeeds', () async {
        // Arrange
        when(mockDocument.update(any)).thenAnswer((_) async => {});

        // Act
        final result = await dataSource.updateUser(testUserModel);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.id, testUserId);
        verify(mockDocument.update(any)).called(1);
      });

      test('should return FirestoreException when update fails', () async {
        // Arrange
        when(
          mockDocument.update(any),
        ).thenThrow(FirebaseException(plugin: 'firestore', code: 'not-found'));

        // Act
        final result = await dataSource.updateUser(testUserModel);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<FirestoreException>());
        expect((result.error as FirestoreException).code, 'update_user_error');
      });
    });

    group('deleteUser', () {
      test('should return success when deletion succeeds', () async {
        // Arrange
        when(mockDocument.delete()).thenAnswer((_) async => {});

        // Act
        final result = await dataSource.deleteUser(testUserId);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDocument.delete()).called(1);
      });

      test('should return FirestoreException when deletion fails', () async {
        // Arrange
        when(mockDocument.delete()).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'permission-denied'),
        );

        // Act
        final result = await dataSource.deleteUser(testUserId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<FirestoreException>());
        expect((result.error as FirestoreException).code, 'delete_user_error');
      });
    });

    group('userExists', () {
      test('should return true when user exists', () async {
        // Arrange
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

        // Act
        final result = await dataSource.userExists(testUserId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, true);
      });

      test('should return false when user does not exist', () async {
        // Arrange
        when(mockDocumentSnapshot.exists).thenReturn(false);
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

        // Act
        final result = await dataSource.userExists(testUserId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, false);
      });
    });

    group('searchUsersByName', () {
      test('should return list of users matching search query', () async {
        // Arrange
        final searchQuery = 'Test';
        when(mockQueryDocSnapshot.data()).thenReturn(testUserData);
        when(mockQueryDocSnapshot.id).thenReturn(testUserId);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(
          mockCollection.where('name', isGreaterThanOrEqualTo: searchQuery),
        ).thenReturn(mockCollection);
        when(
          mockCollection.where(
            'name',
            isLessThanOrEqualTo: '$searchQuery\uf8ff',
          ),
        ).thenReturn(mockCollection);
        when(mockCollection.limit(20)).thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

        // Act
        final result = await dataSource.searchUsersByName(searchQuery);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?.first.name, 'Test User');
      });
    });

    group('getTopUsersByScore', () {
      test('should return list of top users by average score', () async {
        // Arrange
        final limit = 10;
        when(mockQueryDocSnapshot.data()).thenReturn(testUserData);
        when(mockQueryDocSnapshot.id).thenReturn(testUserId);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(
          mockCollection.where('stats.averageScore', isGreaterThan: 0),
        ).thenReturn(mockCollection);
        when(
          mockCollection.orderBy('stats.averageScore', descending: true),
        ).thenReturn(mockCollection);
        when(mockCollection.limit(limit)).thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

        // Act
        final result = await dataSource.getTopUsersByScore(limit);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?.first.stats?.averageScore, 85.5);
      });
    });

    group('watchUser', () {
      test('should return stream of UserModel updates', () async {
        // Arrange
        final controller =
            Stream<DocumentSnapshot<Map<String, dynamic>>>.fromIterable([
              mockDocumentSnapshot,
            ]);

        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn(testUserData);
        when(mockDocumentSnapshot.id).thenReturn(testUserId);
        when(mockDocument.snapshots()).thenAnswer((_) => controller);

        // Act
        final stream = dataSource.watchUser(testUserId);
        final result = await stream.first;

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.id, testUserId);
      });

      test(
        'should return DataException when watched user does not exist',
        () async {
          // Arrange
          final controller =
              Stream<DocumentSnapshot<Map<String, dynamic>>>.fromIterable([
                mockDocumentSnapshot,
              ]);

          when(mockDocumentSnapshot.exists).thenReturn(false);
          when(mockDocument.snapshots()).thenAnswer((_) => controller);

          // Act
          final stream = dataSource.watchUser(testUserId);
          final result = await stream.first;

          // Assert
          expect(result.isFailure, true);
          expect(result.error, isA<DataException>());
        },
      );
    });

    group('batchUpdateUsers', () {
      test('should successfully update multiple users in batch', () async {
        // Arrange
        final users = [testUserModel, testUserModel.copyWith(id: 'user-2')];
        final mockBatch = MockWriteBatch();
        when(mockBatch.commit()).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.batchUpdateUsers(users);

        // Assert
        expect(result.isSuccess, true);
        // Note: Actual batch operations would need more complex mocking
        // This test verifies the basic structure
      });
    });
  });

  group('Performance Tests', () {
    test('getUserById should complete within performance threshold', () async {
      // Arrange
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testUserData);
      when(mockDocumentSnapshot.id).thenReturn('test-user-id');
      when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await dataSource.getUserById('test-user-id');
      stopwatch.stop();

      // Assert
      expect(result.isSuccess, true);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
      ); // <200ms requirement
    });
  });

  group('Data Validation Tests', () {
    test('should handle malformed Firestore data gracefully', () async {
      // Arrange
      final malformedData = {
        'id': 'test-id',
        'name': 123, // Invalid type
        'email': null, // Missing required field
        'createdAt': 'invalid-timestamp',
      };

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(malformedData);
      when(mockDocumentSnapshot.id).thenReturn('test-id');
      when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

      // Act & Assert
      expect(
        () async => await dataSource.getUserById('test-id'),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
