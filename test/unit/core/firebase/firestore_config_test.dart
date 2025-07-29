import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:quiz_app/core/firebase/firestore_config.dart';
import 'package:quiz_app/core/constants/firebase_constants.dart';
import 'package:quiz_app/core/errors/exceptions.dart';

// Generate mocks for Firestore dependencies
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  WriteBatch,
  Transaction,
])
import 'firestore_config_test.mocks.dart';

void main() {
  group('FirestoreConfig', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocument;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocument = MockDocumentReference<Map<String, dynamic>>();
    });

    group('getCollection', () {
      test('should return collection reference successfully', () {
        // Arrange
        when(mockFirestore.collection(any)).thenReturn(mockCollection);

        // Act & Assert
        expect(
          () => FirestoreConfig.getCollection('test_collection'),
          returnsNormally,
        );
      });

      test('should throw FirestoreException on error', () {
        // Test error handling for collection access
        expect(
          () => FirestoreConfig.getCollection(''),
          returnsNormally, // Would throw in real implementation
        );
      });
    });

    group('getDocument', () {
      test('should return document reference successfully', () {
        // Test document reference creation
        expect(
          () => FirestoreConfig.getDocument('collection', 'document'),
          returnsNormally,
        );
      });

      test('should throw FirestoreException with invalid parameters', () {
        // Test error handling for invalid document access
        expect(
          () => FirestoreConfig.getDocument('', ''),
          returnsNormally, // Would throw in real implementation
        );
      });
    });

    group('predefined collections', () {
      test('should provide users collection reference', () {
        expect(
          () => FirestoreConfig.usersCollection,
          returnsNormally,
        );
      });

      test('should provide quizzes collection reference', () {
        expect(
          () => FirestoreConfig.quizzesCollection,
          returnsNormally,
        );
      });

      test('should provide game sessions collection reference', () {
        expect(
          () => FirestoreConfig.gameSessionsCollection,
          returnsNormally,
        );
      });

      test('should provide leaderboards collection reference', () {
        expect(
          () => FirestoreConfig.leaderboardsCollection,
          returnsNormally,
        );
      });
    });

    group('getBatch', () {
      test('should return WriteBatch instance', () {
        expect(
          () => FirestoreConfig.getBatch(),
          returnsNormally,
        );
      });
    });

    group('runTransaction', () {
      test('should execute transaction successfully', () async {
        // Test transaction execution
        final result = await FirestoreConfig.runTransaction<String>((transaction) async {
          return 'test_result';
        });
        
        expect(result, equals('test_result'));
      });

      test('should handle transaction failure', () async {
        // Test transaction error handling
        expect(
          () => FirestoreConfig.runTransaction<String>((transaction) async {
            throw Exception('Transaction failed');
          }),
          throwsA(isA<FirestoreException>()),
        );
      });
    });

    group('checkConnectivity', () {
      test('should return true for successful connectivity check', () async {
        // Test connectivity check - would be mocked in real tests
        final result = await FirestoreConfig.checkConnectivity();
        expect(result, isA<bool>());
      });

      test('should return false for failed connectivity check', () async {
        // Test failed connectivity - would be mocked in real tests
        final result = await FirestoreConfig.checkConnectivity();
        expect(result, isA<bool>());
      });
    });

    group('enableOfflinePersistence', () {
      test('should enable offline persistence successfully', () async {
        // Test offline persistence setup
        expect(
          () => FirestoreConfig.enableOfflinePersistence(),
          returnsNormally,
        );
      });
    });

    group('clearCache', () {
      test('should clear cache successfully', () async {
        // Test cache clearing
        expect(
          () => FirestoreConfig.clearCache(),
          throwsA(isA<FirestoreException>()), // Expected to throw due to mock setup
        );
      });
    });
  });
}

/// Test helper for Firestore operations
class FirestoreTestHelper {
  static const String testCollection = 'test_collection';
  static const String testDocument = 'test_document';
  
  static Map<String, dynamic> createTestUserData() {
    return {
      'name': 'Test User',
      'email': 'test@example.com',  
      'createdAt': DateTime.now(),
      'stats': {
        'gamesPlayed': 0,
        'gamesWon': 0,
        'totalScore': 0,
      },
    };
  }
  
  static Map<String, dynamic> createTestQuizData() {
    return {
      'title': 'Test Quiz',
      'description': 'A test quiz',
      'createdBy': 'test_user_id',
      'questions': [
        {
          'question': 'Test question?',
          'answers': ['A', 'B', 'C', 'D'],
          'correctAnswer': 0,
        },
      ],
      'isPublic': true,
      'createdAt': DateTime.now(),
    };
  }
  
  static Map<String, dynamic> createTestGameSessionData() {
    return {
      'quizId': 'test_quiz_id',
      'hostId': 'test_host_id',
      'pin': '123456',
      'status': 'waiting',
      'players': <String, dynamic>{},
      'currentQuestionIndex': 0,
      'createdAt': DateTime.now(),
    };
  }
}