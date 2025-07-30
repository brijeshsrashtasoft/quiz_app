import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';

/// Mock implementations for navigation testing
/// Provides controlled test doubles for external dependencies

/// Mock Firebase User for authentication testing
class MockFirebaseUser extends Mock implements User {
  @override
  String get uid => 'test-user-123';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  bool get emailVerified => true;

  @override
  DateTime? get metadata => null;

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get refreshToken => 'mock-refresh-token';

  @override
  String? get tenantId => null;

  @override
  bool get isAnonymous => false;
}

/// Mock User Entity for domain testing
class MockUserEntity extends UserEntity {
  const MockUserEntity({
    String id = 'test-user-123',
    String name = 'Test User',
    String email = 'test@example.com',
    DateTime? createdAt,
  }) : super(
         id: id,
         name: name,
         email: email,
         createdAt: createdAt ?? const MockDateTime(),
       );
}

/// Mock DateTime for consistent testing
class MockDateTime extends DateTime {
  const MockDateTime()
    : super.fromMillisecondsSinceEpoch(1640995200000); // 2022-01-01
}

/// Mock Authentication States for testing different auth scenarios
class MockAuthStates {
  static const AuthState unauthenticated = AuthState.unauthenticated();

  static AuthState authenticated({
    String userId = 'test-user-123',
    String userName = 'Test User',
    String userEmail = 'test@example.com',
  }) {
    return AuthState.authenticated(
      firebaseUser: MockFirebaseUser(),
      user: MockUserEntity(
        id: userId,
        name: userName,
        email: userEmail,
        createdAt: const MockDateTime(),
      ),
    );
  }

  static AuthState error({String message = 'Test authentication error'}) {
    return AuthState.error(firebaseUser: MockFirebaseUser(), message: message);
  }

  static AuthState loading() {
    return const AuthState.loading();
  }
}

/// Mock BuildContext for navigation testing
class MockBuildContext extends Mock implements BuildContext {
  @override
  bool get mounted => true;

  @override
  Widget get widget => const Placeholder();
}

/// Mock GoRouterState for route testing
class MockGoRouterState extends Mock implements GoRouterState {
  final String _location;
  final Map<String, String> _pathParameters;
  final Map<String, String> _queryParameters;

  MockGoRouterState({
    String location = '/test',
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) : _location = location,
       _pathParameters = pathParameters,
       _queryParameters = queryParameters;

  @override
  String get matchedLocation => _location;

  @override
  String get location => _location;

  @override
  Map<String, String> get pathParameters => _pathParameters;

  @override
  Uri get uri =>
      Uri.parse(_location).replace(queryParameters: _queryParameters);

  @override
  String? get name => null;

  @override
  String get path => _location;

  @override
  String get fullPath => _location;

  @override
  Object? get extra => null;

  @override
  ValueKey<String> get pageKey => ValueKey(_location);
}

/// Mock Navigation Test Data
class MockNavigationData {
  /// Valid test route parameters
  static const Map<String, String> validQuizParams = {
    'quizId': 'valid-quiz-123456',
  };

  static const Map<String, String> validSessionParams = {
    'sessionId': 'valid-session-123456',
  };

  static const Map<String, String> validGameParams = {
    'sessionId': 'valid-session-123456',
    'questionIndex': '5',
  };

  /// Invalid test route parameters
  static const Map<String, String> invalidQuizParams = {'quizId': 'short'};

  static const Map<String, String> invalidSessionParams = {'sessionId': ''};

  static const Map<String, String> invalidGameParams = {
    'sessionId': 'valid-session-123456',
    'questionIndex': '-1',
  };

  /// Test URLs for deep link testing
  static const List<String> validDeepLinks = [
    'https://quizapp.com/game/join?pin=123456',
    'https://quizapp.com/quiz/test-quiz-123',
    'https://quizapp.com/game/session-456/waiting',
    'https://quizapp.com/leaderboard/session/789',
  ];

  static const List<String> invalidDeepLinks = [
    'invalid-url',
    '',
    'not-a-url',
    'https://quizapp.com/game/join?pin=12345', // PIN too short
  ];

  /// Test routes for navigation testing
  static const List<String> publicRoutes = [
    '/home',
    '/about',
    '/help',
    '/game/join',
    '/leaderboard',
  ];

  static const List<String> authRoutes = [
    '/login',
    '/register',
    '/forgot-password',
  ];

  static const List<String> protectedRoutes = [
    '/dashboard',
    '/profile',
    '/quiz-creation',
    '/settings',
  ];

  static const List<String> gameRoutes = [
    '/game/join',
    '/game/session123',
    '/game/session123/waiting',
    '/game/session123/question/1',
    '/game/session123/results',
    '/game/host',
  ];

  static const List<String> quizRoutes = [
    '/quiz/123',
    '/quiz/123/edit',
    '/quiz-creation',
    '/quiz-creation/form',
    '/quiz-creation/preview',
    '/quiz-creation/publish',
  ];

  static const List<String> leaderboardRoutes = [
    '/leaderboard',
    '/leaderboard/global',
    '/leaderboard/session/123',
  ];
}

/// Mock Game Session Data for navigation testing
class MockGameSessionData {
  static const String validSessionId = 'valid-session-123456';
  static const String invalidSessionId = 'short';
  static const String expiredSessionId = 'expired-session-123';
  static const String privateSessionId = 'private-session-456';

  static Map<String, dynamic> createValidSession({
    String? sessionId,
    String? hostId,
    String status = 'waiting',
    bool isExpired = false,
    bool isPrivate = false,
  }) {
    return {
      'id': sessionId ?? validSessionId,
      'hostId': hostId ?? 'test-host-123',
      'status': status,
      'pin': '123456',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': isExpired
          ? DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch
          : DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
      'isPrivate': isPrivate,
      'players': <String, dynamic>{},
      'currentQuestionIndex': 0,
    };
  }
}

/// Mock Quiz Data for navigation testing
class MockQuizData {
  static const String validQuizId = 'valid-quiz-123456';
  static const String invalidQuizId = 'short';
  static const String privateQuizId = 'private-quiz-123';

  static Map<String, dynamic> createValidQuiz({
    String? quizId,
    String? createdBy,
    bool isPublic = true,
  }) {
    return {
      'id': quizId ?? validQuizId,
      'title': 'Test Quiz',
      'description': 'A test quiz for navigation testing',
      'createdBy': createdBy ?? 'test-user-123',
      'isPublic': isPublic,
      'questions': [
        {
          'question': 'What is 2 + 2?',
          'options': ['3', '4', '5', '6'],
          'correctAnswer': 1,
        },
      ],
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

/// Mock Performance Benchmarks
class MockPerformanceBenchmarks {
  /// Navigation performance thresholds (from CLAUDE.md requirements)
  static const Duration navigationThreshold = Duration(milliseconds: 200);
  static const Duration rapidNavigationThreshold = Duration(seconds: 5);
  static const Duration stackOperationThreshold = Duration(seconds: 3);
  static const Duration parameterValidationThreshold = Duration(
    milliseconds: 100,
  );
  static const Duration deepLinkProcessingThreshold = Duration(
    milliseconds: 200,
  );
  static const Duration urlGenerationThreshold = Duration(milliseconds: 100);
  static const Duration routeClassificationThreshold = Duration(
    milliseconds: 100,
  );
  static const Duration routeComparisonThreshold = Duration(milliseconds: 200);
  static const Duration analyticsTrackingThreshold = Duration(
    milliseconds: 100,
  );
  static const Duration breadcrumbGenerationThreshold = Duration(
    milliseconds: 100,
  );

  /// Memory usage limits
  static const int maxAnalyticsHistorySize = 50;
  static const int maxConcurrentOperations = 10;
  static const int largeDatasetSize = 10000;
  static const Duration largeDatasetProcessingThreshold = Duration(seconds: 5);
}

/// Mock Error Scenarios for testing error handling
class MockErrorScenarios {
  static const List<String> invalidRoutes = [
    '/completely-invalid-route',
    '/another-bad-route',
    '/non-existent-path',
    '/invalid/parameters/route',
  ];

  static const List<String> maliciousRoutes = [
    '/admin/delete-all',
    '/system/shutdown',
    '/../../../etc/passwd',
    '/javascript:alert("xss")',
  ];

  static const Map<String, String> invalidParameters = {
    'quizId': '',
    'sessionId': 'x',
    'questionIndex': '-1',
    'userId': '<script>alert("xss")</script>',
  };

  static Exception createNavigationException(String message) {
    return Exception('Navigation Error: $message');
  }

  static Exception createAuthException(String message) {
    return Exception('Authentication Error: $message');
  }

  static Exception createValidationException(String message) {
    return Exception('Validation Error: $message');
  }
}

/// Mock Test Utilities for navigation testing
class MockTestUtils {
  /// Create a test-friendly router state
  static MockGoRouterState createRouterState({
    required String location,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
  }) {
    return MockGoRouterState(
      location: location,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }

  /// Create test user entity with specific properties
  static MockUserEntity createTestUser({
    String? id,
    String? name,
    String? email,
    bool isProfileComplete = true,
  }) {
    return MockUserEntity(
      id: id ?? 'test-user-123',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: const MockDateTime(),
    );
  }

  /// Create test Firebase user
  static MockFirebaseUser createFirebaseUser({
    String? uid,
    String? email,
    String? displayName,
  }) {
    final user = MockFirebaseUser();
    when(user.uid).thenReturn(uid ?? 'test-user-123');
    when(user.email).thenReturn(email ?? 'test@example.com');
    when(user.displayName).thenReturn(displayName ?? 'Test User');
    return user;
  }

  /// Generate test route with parameters
  static String generateTestRoute(String base, Map<String, String> params) {
    var route = base;
    params.forEach((key, value) {
      route = route.replaceAll(':$key', value);
    });
    return route;
  }

  /// Generate test query parameters
  static String addQueryParams(String route, Map<String, String> params) {
    if (params.isEmpty) return route;

    final uri = Uri.parse(route);
    final newUri = uri.replace(queryParameters: params);
    return newUri.toString();
  }
}
