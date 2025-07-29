import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/firebase_test_helper.dart';

/// Integration tests for Firestore security rules
/// Testing authentication and authorization scenarios
/// Following CLAUDE.md security requirements
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late FirebaseAuth auth;
  late FirebaseTestHelper testHelper;

  setUpAll(() async {
    testHelper = FirebaseTestHelper();
    await testHelper.initialize();

    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;

    // Use Firebase emulator for testing
    firestore.useFirestoreEmulator('localhost', 8080);
    await auth.useAuthEmulator('localhost', 9099);
  });

  tearDownAll(() async {
    await testHelper.cleanup();
    await auth.signOut();
  });

  group('Firestore Security Rules Tests', () {
    late User testUser1;
    late User testUser2;

    setUpAll(() async {
      // Create test users
      final userCredential1 = await auth.createUserWithEmailAndPassword(
        email: 'testuser1@example.com',
        password: 'password123',
      );
      testUser1 = userCredential1.user!;

      await auth.signOut();

      final userCredential2 = await auth.createUserWithEmailAndPassword(
        email: 'testuser2@example.com',
        password: 'password123',
      );
      testUser2 = userCredential2.user!;
    });

    group('Users Collection Security', () {
      testWidgets('authenticated user can read/write their own data', (
        tester,
      ) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        final userData = {
          'name': 'Test User 1',
          'email': 'testuser1@example.com',
          'createdAt': FieldValue.serverTimestamp(),
          'stats': {
            'totalQuizzes': 0,
            'totalGamesPlayed': 0,
            'totalGamesWon': 0,
            'averageScore': 0.0,
          },
        };

        // Act & Assert - Create user document
        await expectLater(
          firestore.collection('users').doc(testUser1.uid).set(userData),
          completes,
        );

        // Act & Assert - Read own data
        final doc = await firestore
            .collection('users')
            .doc(testUser1.uid)
            .get();
        expect(doc.exists, true);
        expect(doc.data()?['name'], 'Test User 1');

        // Act & Assert - Update own data
        await expectLater(
          firestore.collection('users').doc(testUser1.uid).update({
            'name': 'Updated Test User 1',
          }),
          completes,
        );
      });

      testWidgets('authenticated user cannot access other users data', (
        tester,
      ) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        // Act & Assert - Try to read other user's data
        await expectLater(
          firestore.collection('users').doc(testUser2.uid).get(),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to write to other user's document
        await expectLater(
          firestore.collection('users').doc(testUser2.uid).set({
            'name': 'Malicious Update',
            'email': 'hacker@example.com',
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );
      });

      testWidgets('unauthenticated user cannot access users collection', (
        tester,
      ) async {
        // Arrange
        await auth.signOut();

        // Act & Assert - Try to read as unauthenticated user
        await expectLater(
          firestore.collection('users').doc(testUser1.uid).get(),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to write as unauthenticated user
        await expectLater(
          firestore.collection('users').doc('random-id').set({
            'name': 'Unauthorized User',
            'email': 'unauthorized@example.com',
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );
      });

      testWidgets('user data validation rules are enforced', (tester) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        // Act & Assert - Try to create user with invalid email
        await expectLater(
          firestore.collection('users').doc(testUser1.uid).set({
            'name': 'Test User',
            'email': 'invalid-email', // Invalid email format
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to create user with missing required fields
        await expectLater(
          firestore.collection('users').doc(testUser1.uid).set({
            'name': 'Test User',
            // Missing required email and createdAt
          }),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to create user with name too long
        await expectLater(
          firestore.collection('users').doc(testUser1.uid).set({
            'name': 'a' * 101, // Exceeds 100 character limit
            'email': 'testuser1@example.com',
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('Quizzes Collection Security', () {
      testWidgets(
        'authenticated user can create and manage their own quizzes',
        (tester) async {
          // Arrange
          await auth.signInWithEmailAndPassword(
            email: 'testuser1@example.com',
            password: 'password123',
          );

          final quizData = {
            'title': 'Test Quiz',
            'description': 'A test quiz for security testing',
            'createdBy': testUser1.uid,
            'questions': [
              {
                'question': 'What is 2+2?',
                'options': ['2', '3', '4', '5'],
                'correctAnswer': 2,
                'timeLimit': 30,
                'points': 100,
              },
            ],
            'isPublic': true,
            'category': 'Math',
            'createdAt': FieldValue.serverTimestamp(),
          };

          // Act & Assert - Create quiz
          final docRef = await firestore.collection('quizzes').add(quizData);
          expect(docRef.id, isNotEmpty);

          // Act & Assert - Read own quiz
          final doc = await docRef.get();
          expect(doc.exists, true);
          expect(doc.data()?['title'], 'Test Quiz');

          // Act & Assert - Update own quiz
          await expectLater(
            docRef.update({'title': 'Updated Test Quiz'}),
            completes,
          );

          // Act & Assert - Delete own quiz
          await expectLater(docRef.delete(), completes);
        },
      );

      testWidgets('authenticated user can read public quizzes', (tester) async {
        // Arrange - User 1 creates a public quiz
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        final publicQuizRef = await firestore.collection('quizzes').add({
          'title': 'Public Quiz',
          'description': 'A public quiz for everyone',
          'createdBy': testUser1.uid,
          'questions': [
            {
              'question': 'What is the capital of France?',
              'options': ['London', 'Berlin', 'Paris', 'Madrid'],
              'correctAnswer': 2,
              'timeLimit': 30,
              'points': 100,
            },
          ],
          'isPublic': true,
          'category': 'Geography',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Switch to User 2
        await auth.signOut();
        await auth.signInWithEmailAndPassword(
          email: 'testuser2@example.com',
          password: 'password123',
        );

        // Act & Assert - User 2 can read public quiz
        final doc = await publicQuizRef.get();
        expect(doc.exists, true);
        expect(doc.data()?['title'], 'Public Quiz');

        // Act & Assert - User 2 cannot update other user's quiz
        await expectLater(
          publicQuizRef.update({'title': 'Hacked Quiz'}),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - User 2 cannot delete other user's quiz
        await expectLater(
          publicQuizRef.delete(),
          throwsA(isA<FirebaseException>()),
        );
      });

      testWidgets('quiz data validation rules are enforced', (tester) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        // Act & Assert - Try to create quiz with missing required fields
        await expectLater(
          firestore.collection('quizzes').add({
            'title': 'Incomplete Quiz',
            // Missing required fields
          }),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to create quiz with invalid question structure
        await expectLater(
          firestore.collection('quizzes').add({
            'title': 'Invalid Quiz',
            'description': 'Quiz with invalid questions',
            'createdBy': testUser1.uid,
            'questions': [
              {
                'question': 'What is 2+2?',
                'options': ['4'], // Too few options (minimum 2)
                'correctAnswer': 0,
                'timeLimit': 30,
                'points': 100,
              },
            ],
            'isPublic': true,
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to create quiz with title too long
        await expectLater(
          firestore.collection('quizzes').add({
            'title': 'a' * 201, // Exceeds 200 character limit
            'description': 'Valid description',
            'createdBy': testUser1.uid,
            'questions': [
              {
                'question': 'What is 2+2?',
                'options': ['2', '3', '4', '5'],
                'correctAnswer': 2,
                'timeLimit': 30,
                'points': 100,
              },
            ],
            'isPublic': true,
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('Game Sessions Collection Security', () {
      testWidgets('host can create and manage game sessions', (tester) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        final sessionData = {
          'quizId': 'test-quiz-id',
          'hostId': testUser1.uid,
          'pin': '123456',
          'status': 'waiting',
          'players': <String, dynamic>{},
          'currentQuestionIndex': 0,
          'settings': {
            'maxPlayers': 50,
            'showCorrectAnswers': true,
            'shuffleQuestions': false,
            'allowReplay': true,
          },
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Act & Assert - Create game session
        final docRef = await firestore
            .collection('game_sessions')
            .add(sessionData);
        expect(docRef.id, isNotEmpty);

        // Act & Assert - Host can read and update session
        await expectLater(docRef.update({'status': 'active'}), completes);

        final doc = await docRef.get();
        expect(doc.data()?['status'], 'active');
      });

      testWidgets('players can join waiting game sessions', (tester) async {
        // Arrange - User 1 creates a game session
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        final sessionRef = await firestore.collection('game_sessions').add({
          'quizId': 'test-quiz-id',
          'hostId': testUser1.uid,
          'pin': '654321',
          'status': 'waiting',
          'players': <String, dynamic>{},
          'currentQuestionIndex': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Switch to User 2 (player)
        await auth.signOut();
        await auth.signInWithEmailAndPassword(
          email: 'testuser2@example.com',
          password: 'password123',
        );

        // Act & Assert - Player can join session
        await expectLater(
          sessionRef.update({
            'players.${testUser2.uid}': {
              'name': 'Test Player',
              'joinedAt': FieldValue.serverTimestamp(),
              'score': 0,
              'answers': [],
              'isReady': false,
            },
          }),
          completes,
        );

        // Act & Assert - Player can read session they joined
        final doc = await sessionRef.get();
        expect(doc.exists, true);
        expect(doc.data()?['players'][testUser2.uid], isNotNull);
      });

      testWidgets('game session validation rules are enforced', (tester) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        // Act & Assert - Try to create session with invalid PIN format
        await expectLater(
          firestore.collection('game_sessions').add({
            'quizId': 'test-quiz-id',
            'hostId': testUser1.uid,
            'pin': '12345', // Invalid length (should be 6 digits)
            'status': 'waiting',
            'players': <String, dynamic>{},
            'currentQuestionIndex': 0,
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );

        // Act & Assert - Try to create session with non-numeric PIN
        await expectLater(
          firestore.collection('game_sessions').add({
            'quizId': 'test-quiz-id',
            'hostId': testUser1.uid,
            'pin': 'ABC123', // Non-numeric PIN
            'status': 'waiting',
            'players': <String, dynamic>{},
            'currentQuestionIndex': 0,
            'createdAt': FieldValue.serverTimestamp(),
          }),
          throwsA(isA<FirebaseException>()),
        );
      });
    });

    group('Leaderboards Collection Security', () {
      testWidgets('host can create and manage leaderboards', (tester) async {
        // Arrange - Create a game session first
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        final sessionRef = await firestore.collection('game_sessions').add({
          'quizId': 'test-quiz-id',
          'hostId': testUser1.uid,
          'pin': '789012',
          'status': 'completed',
          'players': <String, dynamic>{},
          'currentQuestionIndex': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final leaderboardData = {
          'scores': [
            {
              'playerId': testUser2.uid,
              'playerName': 'Test Player',
              'score': 100,
              'correctAnswers': 1,
              'totalAnswers': 1,
              'rank': 1,
              'timeTaken': 30,
            },
          ],
          'finalResults': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Act & Assert - Host can create leaderboard
        await expectLater(
          firestore
              .collection('leaderboards')
              .doc(sessionRef.id)
              .set(leaderboardData),
          completes,
        );

        // Act & Assert - Host can update leaderboard
        await expectLater(
          firestore.collection('leaderboards').doc(sessionRef.id).update({
            'finalResults': false,
          }),
          completes,
        );
      });

      testWidgets(
        'players can read leaderboards for sessions they participated in',
        (tester) async {
          // Arrange - User 1 creates session and leaderboard
          await auth.signInWithEmailAndPassword(
            email: 'testuser1@example.com',
            password: 'password123',
          );

          final sessionRef = await firestore.collection('game_sessions').add({
            'quizId': 'test-quiz-id',
            'hostId': testUser1.uid,
            'pin': '345678',
            'status': 'completed',
            'players': {
              testUser2.uid: {
                'name': 'Test Player',
                'joinedAt': FieldValue.serverTimestamp(),
                'score': 100,
              },
            },
            'currentQuestionIndex': 1,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await firestore.collection('leaderboards').doc(sessionRef.id).set({
            'scores': [
              {
                'playerId': testUser2.uid,
                'playerName': 'Test Player',
                'score': 100,
                'correctAnswers': 1,
                'totalAnswers': 1,
                'rank': 1,
              },
            ],
            'finalResults': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Switch to User 2 (player)
          await auth.signOut();
          await auth.signInWithEmailAndPassword(
            email: 'testuser2@example.com',
            password: 'password123',
          );

          // Act & Assert - Player can read leaderboard for session they participated in
          final doc = await firestore
              .collection('leaderboards')
              .doc(sessionRef.id)
              .get();
          expect(doc.exists, true);
          expect(doc.data()?['scores'], isNotEmpty);

          // Act & Assert - Player cannot update leaderboard
          await expectLater(
            firestore.collection('leaderboards').doc(sessionRef.id).update({
              'finalResults': false,
            }),
            throwsA(isA<FirebaseException>()),
          );
        },
      );
    });

    group('Performance and Latency Tests', () {
      testWidgets('read operations complete within 200ms', (tester) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        // Create test data
        await firestore.collection('users').doc(testUser1.uid).set({
          'name': 'Performance Test User',
          'email': 'testuser1@example.com',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Act & Assert - Read operation timing
        final stopwatch = Stopwatch()..start();
        final doc = await firestore
            .collection('users')
            .doc(testUser1.uid)
            .get();
        stopwatch.stop();

        expect(doc.exists, true);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
        ); // CLAUDE.md requirement
      });

      testWidgets('write operations complete within 200ms', (tester) async {
        // Arrange
        await auth.signInWithEmailAndPassword(
          email: 'testuser1@example.com',
          password: 'password123',
        );

        // Act & Assert - Write operation timing
        final stopwatch = Stopwatch()..start();
        await firestore.collection('users').doc(testUser1.uid).update({
          'name': 'Updated Performance Test User',
        });
        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
        ); // CLAUDE.md requirement
      });
    });
  });
}
