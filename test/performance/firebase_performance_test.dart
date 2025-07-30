import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/test_utilities.dart';

void main() {
  group('Firebase Performance Tests', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('Query Performance', () {
      testWidgets('single document read should be under 200ms', (tester) async {
        // Setup test data
        const docId = 'test-quiz-1';
        await firestore.collection('quizzes').doc(docId).set({
          'title': 'Test Quiz',
          'description': 'A test quiz',
          'questions': [],
          'createdAt': DateTime.now().toIso8601String(),
          'isPublic': true,
        });

        // Measure query time
        final stopwatch = Stopwatch()..start();

        final doc = await firestore.collection('quizzes').doc(docId).get();

        stopwatch.stop();

        expect(doc.exists, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Single document read took ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      testWidgets('collection query should be under 200ms', (tester) async {
        // Setup test data - create multiple documents
        final batch = firestore.batch();
        for (int i = 0; i < 20; i++) {
          final docRef = firestore.collection('quizzes').doc();
          batch.set(docRef, {
            'title': 'Quiz $i',
            'description': 'Description $i',
            'questions': TestUtilities.randomList(
              () => {
                'id': TestUtilities.randomId(),
                'text': 'Question ${TestUtilities.randomString(20)}',
                'options': ['A', 'B', 'C', 'D'],
                'correctAnswer': TestUtilities.randomInt(0, 3),
              },
              length: 5,
            ),
            'createdAt': DateTime.now().toIso8601String(),
            'isPublic': true,
          });
        }
        await batch.commit();

        // Measure collection query time
        final stopwatch = Stopwatch()..start();

        final querySnapshot = await firestore
            .collection('quizzes')
            .where('isPublic', isEqualTo: true)
            .limit(10)
            .get();

        stopwatch.stop();

        expect(querySnapshot.docs.length, equals(10));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason: 'Collection query took ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      testWidgets('complex query with ordering should be under 300ms', (
        tester,
      ) async {
        // Setup test data with timestamps
        final batch = firestore.batch();
        final now = DateTime.now();

        for (int i = 0; i < 50; i++) {
          final docRef = firestore.collection('quizzes').doc();
          batch.set(docRef, {
            'title': 'Quiz $i',
            'description': 'Description $i',
            'questionCount': TestUtilities.randomInt(5, 20),
            'createdAt': now.subtract(Duration(days: i)).toIso8601String(),
            'isPublic': i % 2 == 0, // Mix of public and private
            'authorId': 'user-${i % 5}', // Multiple authors
          });
        }
        await batch.commit();

        // Measure complex query time
        final stopwatch = Stopwatch()..start();

        final querySnapshot = await firestore
            .collection('quizzes')
            .where('isPublic', isEqualTo: true)
            .where('questionCount', isGreaterThan: 8)
            .orderBy('questionCount', descending: true)
            .orderBy('createdAt', descending: true)
            .limit(15)
            .get();

        stopwatch.stop();

        expect(querySnapshot.docs.isNotEmpty, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(300),
          reason: 'Complex query took ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      testWidgets('real-time listener setup should be under 100ms', (
        tester,
      ) async {
        // Setup test data
        await firestore.collection('game_sessions').doc('session-1').set({
          'pin': '123456',
          'status': 'waiting',
          'players': <String, dynamic>{},
          'currentQuestionIndex': 0,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Measure listener setup time
        final stopwatch = Stopwatch()..start();

        final stream = firestore
            .collection('game_sessions')
            .doc('session-1')
            .snapshots();

        // Wait for first event
        await stream.first;

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Real-time listener setup took ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Write Performance', () {
      testWidgets('single document write should be under 200ms', (
        tester,
      ) async {
        const docId = 'test-write-1';
        final data = {
          'title': 'New Quiz',
          'description': 'A newly created quiz',
          'questions': TestUtilities.randomList(
            () => {
              'id': TestUtilities.randomId(),
              'text': TestUtilities.randomString(50),
              'options': List.generate(
                4,
                (i) => TestUtilities.randomString(20),
              ),
              'correctAnswer': TestUtilities.randomInt(0, 3),
            },
            length: 10,
          ),
          'createdAt': DateTime.now().toIso8601String(),
          'isPublic': true,
        };

        // Measure write time
        final stopwatch = Stopwatch()..start();

        await firestore.collection('quizzes').doc(docId).set(data);

        stopwatch.stop();

        // Verify write was successful
        final doc = await firestore.collection('quizzes').doc(docId).get();
        expect(doc.exists, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Single document write took ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      testWidgets('batch write should be under 500ms', (tester) async {
        final batch = firestore.batch();

        // Create 20 documents in a batch
        for (int i = 0; i < 20; i++) {
          final docRef = firestore.collection('test_batch').doc();
          batch.set(docRef, {
            'index': i,
            'title': 'Batch Item $i',
            'data': TestUtilities.randomMap(keyCount: 5),
            'timestamp': DateTime.now().toIso8601String(),
          });
        }

        // Measure batch write time
        final stopwatch = Stopwatch()..start();

        await batch.commit();

        stopwatch.stop();

        // Verify all documents were written
        final querySnapshot = await firestore.collection('test_batch').get();
        expect(querySnapshot.docs.length, equals(20));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: 'Batch write took ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      testWidgets('document update should be under 150ms', (tester) async {
        const docId = 'test-update-1';

        // Create initial document
        await firestore.collection('quizzes').doc(docId).set({
          'title': 'Original Title',
          'questionCount': 5,
          'lastUpdated': DateTime.now().toIso8601String(),
        });

        // Measure update time
        final stopwatch = Stopwatch()..start();

        await firestore.collection('quizzes').doc(docId).update({
          'title': 'Updated Title',
          'questionCount': 10,
          'lastUpdated': DateTime.now().toIso8601String(),
        });

        stopwatch.stop();

        // Verify update was successful
        final doc = await firestore.collection('quizzes').doc(docId).get();
        expect(doc.data()!['title'], equals('Updated Title'));
        expect(doc.data()!['questionCount'], equals(10));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(150),
          reason: 'Document update took ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Real-time Performance', () {
      testWidgets('real-time updates should propagate within 100ms', (
        tester,
      ) async {
        const docId = 'realtime-test-1';

        // Setup document
        await firestore.collection('game_sessions').doc(docId).set({
          'playerCount': 0,
          'status': 'waiting',
          'lastUpdate': DateTime.now().toIso8601String(),
        });

        // Setup listener
        final stream = firestore
            .collection('game_sessions')
            .doc(docId)
            .snapshots();
        final updates = <DocumentSnapshot>[];

        final subscription = stream.listen((snapshot) {
          updates.add(snapshot);
        });

        // Wait for initial snapshot
        await Future.delayed(const Duration(milliseconds: 50));
        expect(updates.length, equals(1));

        // Measure update propagation time
        final stopwatch = Stopwatch()..start();

        // Make an update
        await firestore.collection('game_sessions').doc(docId).update({
          'playerCount': 5,
          'lastUpdate': DateTime.now().toIso8601String(),
        });

        // Wait for update to propagate
        await Future.delayed(const Duration(milliseconds: 50));

        stopwatch.stop();

        expect(updates.length, equals(2));
        expect(updates.last.data()!['playerCount'], equals(5));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Real-time update propagation took ${stopwatch.elapsedMilliseconds}ms',
        );

        await subscription.cancel();
      });

      testWidgets('concurrent listeners should not degrade performance', (
        tester,
      ) async {
        const baseDocId = 'concurrent-test';

        // Setup multiple documents
        final batch = firestore.batch();
        for (int i = 0; i < 10; i++) {
          final docRef = firestore
              .collection('concurrent_test')
              .doc('$baseDocId-$i');
          batch.set(docRef, {
            'value': i,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
        await batch.commit();

        // Setup multiple concurrent listeners
        final listeners = <StreamSubscription>[];
        final updateCounts = <int>[];

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10; i++) {
          updateCounts.add(0);
          final stream = firestore
              .collection('concurrent_test')
              .doc('$baseDocId-$i')
              .snapshots();

          final subscription = stream.listen((snapshot) {
            updateCounts[i]++;
          });
          listeners.add(subscription);
        }

        // Wait for all initial snapshots
        await Future.delayed(const Duration(milliseconds: 100));

        stopwatch.stop();

        // All listeners should have received initial snapshot
        expect(updateCounts.every((count) => count >= 1), isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Setting up 10 concurrent listeners took ${stopwatch.elapsedMilliseconds}ms',
        );

        // Clean up
        for (final subscription in listeners) {
          await subscription.cancel();
        }
      });
    });

    group('Memory Performance', () {
      testWidgets('large document handling should not cause memory issues', (
        tester,
      ) async {
        // Create a large document with substantial data
        final largeData = {
          'title': 'Large Quiz',
          'description': TestUtilities.randomString(1000),
          'questions': TestUtilities.randomList(
            () => {
              'id': TestUtilities.randomId(),
              'text': TestUtilities.randomString(200),
              'options': List.generate(
                4,
                (i) => TestUtilities.randomString(100),
              ),
              'explanation': TestUtilities.randomString(300),
              'correctAnswer': TestUtilities.randomInt(0, 3),
              'metadata': TestUtilities.randomMap(keyCount: 10),
            },
            length: 50, // 50 questions with substantial data
          ),
          'metadata': TestUtilities.randomMap(keyCount: 20),
          'createdAt': DateTime.now().toIso8601String(),
        };

        const docId = 'large-doc-test';

        // Write large document
        final writeStopwatch = Stopwatch()..start();
        await firestore.collection('large_docs').doc(docId).set(largeData);
        writeStopwatch.stop();

        expect(
          writeStopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason:
              'Large document write took ${writeStopwatch.elapsedMilliseconds}ms',
        );

        // Read large document
        final readStopwatch = Stopwatch()..start();
        final doc = await firestore.collection('large_docs').doc(docId).get();
        readStopwatch.stop();

        expect(doc.exists, isTrue);
        expect(doc.data()!['questions'].length, equals(50));
        expect(
          readStopwatch.elapsedMilliseconds,
          lessThan(500),
          reason:
              'Large document read took ${readStopwatch.elapsedMilliseconds}ms',
        );
      });

      testWidgets(
        'multiple simultaneous operations should complete efficiently',
        (tester) async {
          // Perform multiple operations simultaneously
          final futures = <Future>[];
          final stopwatch = Stopwatch()..start();

          // 10 concurrent writes
          for (int i = 0; i < 10; i++) {
            futures.add(
              firestore.collection('concurrent_ops').doc('write-$i').set({
                'index': i,
                'data': TestUtilities.randomMap(),
                'timestamp': DateTime.now().toIso8601String(),
              }),
            );
          }

          // 10 concurrent reads
          for (int i = 0; i < 10; i++) {
            futures.add(
              firestore
                  .collection('concurrent_ops')
                  .doc('read-$i')
                  .set({'index': i, 'temp': true})
                  .then(
                    (_) => firestore
                        .collection('concurrent_ops')
                        .doc('read-$i')
                        .get(),
                  ),
            );
          }

          // Wait for all operations to complete
          await Future.wait(futures);

          stopwatch.stop();

          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(2000),
            reason:
                '20 concurrent operations took ${stopwatch.elapsedMilliseconds}ms',
          );
        },
      );
    });

    group('Performance Benchmarks', () {
      testWidgets('quiz loading benchmark', (tester) async {
        // Setup realistic quiz data
        final batch = firestore.batch();
        for (int i = 0; i < 100; i++) {
          final docRef = firestore.collection('quizzes').doc();
          batch.set(docRef, {
            'title': 'Quiz $i',
            'description': TestUtilities.randomString(100),
            'questionCount': TestUtilities.randomInt(5, 20),
            'createdAt': DateTime.now()
                .subtract(Duration(days: i))
                .toIso8601String(),
            'isPublic': i % 3 != 0, // Most are public
            'category': ['science', 'math', 'history', 'geography'][i % 4],
            'difficulty': ['easy', 'medium', 'hard'][i % 3],
            'authorId': 'user-${i % 10}',
          });
        }
        await batch.commit();

        // Benchmark: Load recent public quizzes
        final stopwatch1 = Stopwatch()..start();
        final recentPublicQuizzes = await firestore
            .collection('quizzes')
            .where('isPublic', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();
        stopwatch1.stop();

        expect(recentPublicQuizzes.docs.isNotEmpty, isTrue);
        expect(stopwatch1.elapsedMilliseconds, lessThan(200));
        print('Recent public quiz load: ${stopwatch1.elapsedMilliseconds}ms');

        // Benchmark: Search quizzes by category
        final stopwatch2 = Stopwatch()..start();
        final scienceQuizzes = await firestore
            .collection('quizzes')
            .where('category', isEqualTo: 'science')
            .where('isPublic', isEqualTo: true)
            .limit(10)
            .get();
        stopwatch2.stop();

        expect(scienceQuizzes.docs.isNotEmpty, isTrue);
        expect(stopwatch2.elapsedMilliseconds, lessThan(200));
        print('Category search: ${stopwatch2.elapsedMilliseconds}ms');

        // Benchmark: Load user's quizzes
        final stopwatch3 = Stopwatch()..start();
        final userQuizzes = await firestore
            .collection('quizzes')
            .where('authorId', isEqualTo: 'user-1')
            .orderBy('createdAt', descending: true)
            .get();
        stopwatch3.stop();

        expect(userQuizzes.docs.isNotEmpty, isTrue);
        expect(stopwatch3.elapsedMilliseconds, lessThan(200));
        print('User quiz load: ${stopwatch3.elapsedMilliseconds}ms');
      });

      testWidgets('game session performance benchmark', (tester) async {
        const sessionId = 'benchmark-session';

        // Benchmark: Create game session
        final stopwatch1 = Stopwatch()..start();
        await firestore.collection('game_sessions').doc(sessionId).set({
          'pin': '123456',
          'quizId': 'quiz-123',
          'hostId': 'host-user',
          'status': 'waiting',
          'players': <String, dynamic>{},
          'currentQuestionIndex': 0,
          'settings': {
            'timePerQuestion': 30,
            'showAnswers': true,
            'allowRejoining': false,
          },
          'createdAt': DateTime.now().toIso8601String(),
        });
        stopwatch1.stop();

        expect(stopwatch1.elapsedMilliseconds, lessThan(200));
        print('Game session creation: ${stopwatch1.elapsedMilliseconds}ms');

        // Benchmark: Add players to session
        final stopwatch2 = Stopwatch()..start();
        final batch = firestore.batch();
        final sessionRef = firestore.collection('game_sessions').doc(sessionId);

        for (int i = 0; i < 50; i++) {
          final playerData = {
            'players.player_$i': {
              'name': 'Player $i',
              'joinedAt': DateTime.now().toIso8601String(),
              'score': 0,
              'answeredQuestions': <String>[],
            },
          };
          batch.update(sessionRef, playerData);
        }
        await batch.commit();
        stopwatch2.stop();

        expect(stopwatch2.elapsedMilliseconds, lessThan(1000));
        print('50 players join: ${stopwatch2.elapsedMilliseconds}ms');

        // Benchmark: Real-time session monitoring
        final stopwatch3 = Stopwatch()..start();
        final stream = firestore
            .collection('game_sessions')
            .doc(sessionId)
            .snapshots();
        await stream.first; // Wait for initial snapshot
        stopwatch3.stop();

        expect(stopwatch3.elapsedMilliseconds, lessThan(100));
        print(
          'Real-time monitoring setup: ${stopwatch3.elapsedMilliseconds}ms',
        );
      });
    });
  });
}
