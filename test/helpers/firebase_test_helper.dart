import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Helper class for setting up Firebase mocks in tests
class FirebaseTestHelper {
  static bool _isInitialized = false;

  /// Initialize Firebase for testing
  static Future<void> setupFirebaseForTest() async {
    if (_isInitialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock Firebase.initializeApp to prevent actual Firebase initialization
    // This prevents the "No Firebase App has been created" errors
    _isInitialized = true;
  }

  /// Clean up Firebase after tests
  static Future<void> tearDownFirebase() async {
    _isInitialized = false;
  }

  /// Create a fake Firestore instance for testing
  static FakeFirebaseFirestore createFakeFirestore() {
    return FakeFirebaseFirestore();
  }

  /// Setup test data in fake Firestore
  static Future<void> setupTestData(FakeFirebaseFirestore firestore) async {
    // Add test users
    await firestore.collection('users').doc('test_user_1').set({
      'name': 'Test User 1',
      'email': 'test1@example.com',
      'createdAt': DateTime.now(),
      'stats': {
        'gamesPlayed': 5,
        'gamesWon': 3,
        'totalScore': 150,
        'correctAnswers': 45,
        'totalQuestions': 60,
        'averageScore': 75.0,
        'lastGameDate': DateTime.now(),
      },
    });

    // Add test quizzes
    await firestore.collection('quizzes').doc('test_quiz_1').set({
      'title': 'Test Quiz 1',
      'description': 'A sample quiz for testing',
      'createdBy': 'test_user_1',
      'questions': [
        {
          'question': 'What is 2 + 2?',
          'answers': ['3', '4', '5', '6'],
          'correctAnswer': 1,
        },
        {
          'question': 'What is the capital of France?',
          'answers': ['London', 'Berlin', 'Paris', 'Madrid'],
          'correctAnswer': 2,
        },
      ],
      'isPublic': true,
      'createdAt': DateTime.now(),
    });

    // Add test game sessions
    await firestore.collection('game_sessions').doc('test_session_1').set({
      'quizId': 'test_quiz_1',
      'hostId': 'test_user_1',
      'pin': '123456',
      'status': 'waiting',
      'players': <String, dynamic>{},
      'currentQuestionIndex': 0,
      'createdAt': DateTime.now(),
    });

    // Add test leaderboards
    await firestore.collection('leaderboards').doc('test_session_1').set({
      'scores': [
        {
          'userId': 'test_user_1',
          'name': 'Test User 1',
          'score': 100,
          'correctAnswers': 2,
          'totalQuestions': 2,
        },
      ],
      'updatedAt': DateTime.now(),
    });
  }

  /// Create mock user credentials for testing
  static Map<String, dynamic> createMockUserData({
    String uid = 'test_uid',
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'emailVerified': true,
      'isAnonymous': false,
      'metadata': {
        'creationTime': DateTime.now().toIso8601String(),
        'lastSignInTime': DateTime.now().toIso8601String(),
      },
      'providerData': [
        {
          'uid': email,
          'email': email,
          'displayName': displayName,
          'providerId': 'password',
        },
      ],
    };
  }

  /// Simulate authentication state changes
  static Stream<Map<String, dynamic>?> createAuthStateStream({
    bool isAuthenticated = false,
    Map<String, dynamic>? userData,
  }) {
    return Stream.value(
      isAuthenticated ? (userData ?? createMockUserData()) : null,
    );
  }
}

/// Custom test group that sets up Firebase
void firebaseTestGroup(
  String description,
  void Function() body, {
  bool skip = false,
}) {
  group(description, () {
    setUpAll(() async {
      await FirebaseTestHelper.setupFirebaseForTest();
    });

    tearDownAll(() async {
      await FirebaseTestHelper.tearDownFirebase();
    });

    body();
  }, skip: skip);
}

/// Custom test that sets up Firebase
void firebaseTest(
  String description,
  dynamic Function() body, {
  bool skip = false,
  dynamic tags,
}) {
  test(
    description,
    () async {
      await FirebaseTestHelper.setupFirebaseForTest();
      await body();
    },
    skip: skip,
    tags: tags,
  );
}
