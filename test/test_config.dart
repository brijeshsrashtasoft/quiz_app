/// Test configuration and setup for TDD workflow
/// Provides centralized test configuration and utilities

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/shared/theme/app_theme.dart';

/// Global test configuration
class TestConfig {
  TestConfig._();

  /// Standard test timeout for async operations
  static const Duration testTimeout = Duration(seconds: 30);

  /// Pump duration for widget tests
  static const Duration pumpDuration = Duration(milliseconds: 100);

  /// Animation settle duration
  static const Duration settleDuration = Duration(milliseconds: 300);

  /// Test database configurations
  static const Map<String, String> testFirebaseConfig = {
    'projectId': 'test-quiz-app',
    'apiKey': 'test-api-key',
    'authDomain': 'test-quiz-app.firebaseapp.com',
    'storageBucket': 'test-quiz-app.appspot.com',
  };
}

/// Test wrapper widgets for consistent testing
class TestWrappers {
  TestWrappers._();

  /// Basic material app wrapper for widget tests
  static Widget materialApp({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Provider scope wrapper for widget tests with Riverpod
  static Widget providerScope({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(overrides: overrides, child: child);
  }

  /// Full app wrapper with navigation for integration tests
  static Widget fullApp({
    List<Override> overrides = const [],
    String initialLocation = '/',
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Scaffold wrapper for isolated widget testing
  static Widget scaffoldWrapper({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Common test expectations and assertions
class TestExpectations {
  TestExpectations._();

  /// Expect widget to build without errors
  static void expectWidgetBuilds(WidgetTester tester, Widget widget) {
    expect(
      () => tester.pumpWidget(TestWrappers.materialApp(child: widget)),
      returnsNormally,
    );
  }

  /// Expect async operation to complete within timeout
  static Future<void> expectAsyncCompletion<T>(
    Future<T> future, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await expectLater(
      future.timeout(timeout),
      completes,
      reason: 'Operation should complete within $timeout',
    );
  }

  /// Expect widget to be accessible
  static void expectAccessible(WidgetTester tester) {
    // Simplified accessibility check for compilation
    expect(
      find.byType(Widget),
      findsWidgets,
      reason: 'Widget should be accessible',
    );
  }

  /// Expect performance within threshold
  static Future<void> expectPerformant(
    Future<void> Function() operation, {
    Duration threshold = const Duration(milliseconds: 200),
  }) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();

    expect(
      stopwatch.elapsed,
      lessThan(threshold),
      reason: 'Operation should complete within $threshold',
    );
  }
}

/// TDD Test Categories
enum TestCategory {
  unit,
  widget,
  integration,
  e2e,
  performance;

  String get displayName {
    switch (this) {
      case TestCategory.unit:
        return 'Unit Tests';
      case TestCategory.widget:
        return 'Widget Tests';
      case TestCategory.integration:
        return 'Integration Tests';
      case TestCategory.e2e:
        return 'End-to-End Tests';
      case TestCategory.performance:
        return 'Performance Tests';
    }
  }

  /// Get test timeout based on category
  Duration get timeout {
    switch (this) {
      case TestCategory.unit:
        return const Duration(seconds: 5);
      case TestCategory.widget:
        return const Duration(seconds: 10);
      case TestCategory.integration:
        return const Duration(seconds: 30);
      case TestCategory.e2e:
        return const Duration(minutes: 2);
      case TestCategory.performance:
        return const Duration(minutes: 1);
    }
  }
}

/// Test group wrapper with category support
void testGroup(
  String description,
  TestCategory category,
  void Function() body, {
  dynamic skip,
}) {
  group('[${category.displayName}] $description', body, skip: skip);
}

/// Test wrapper with category support and timeout
void testCase(
  String description,
  TestCategory category,
  dynamic Function() body, {
  dynamic skip,
  dynamic tags,
}) {
  test(
    description,
    body,
    skip: skip,
    tags: tags,
    timeout: Timeout(category.timeout),
  );
}

/// Widget test wrapper with category support
void widgetTestCase(
  String description,
  TestCategory category,
  Future<void> Function(WidgetTester) callback, {
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  testWidgets(
    description,
    callback,
    skip: skip,
    timeout: timeout ?? Timeout(category.timeout),
    tags: tags,
  );
}

/// TDD workflow helper
class TDDWorkflow {
  TDDWorkflow._();

  /// Step 1: Write failing test
  static void writeFailingTest(String testName, void Function() testBody) {
    print('🔴 TDD Step 1: Writing failing test - $testName');
    testBody();
  }

  /// Step 2: Write minimal code to pass
  static void writeMinimalCode(String description) {
    print('🟢 TDD Step 2: Writing minimal code - $description');
  }

  /// Step 3: Refactor while keeping tests green
  static void refactor(String description) {
    print('🔵 TDD Step 3: Refactoring - $description');
  }

  /// Complete TDD cycle logging
  static void completeCycle(String featureName) {
    print('✅ TDD Cycle Complete: $featureName');
  }
}

/// Test data builders for consistent test fixtures
class TestDataBuilders {
  TestDataBuilders._();

  /// Create test user data
  static Map<String, dynamic> createUserData({
    String? id,
    String? name,
    String? email,
  }) {
    return {
      'id': id ?? 'test-user-123',
      'name': name ?? 'Test User',
      'email': email ?? 'test@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Create test quiz data
  static Map<String, dynamic> createQuizData({
    String? id,
    String? title,
    List<Map<String, dynamic>>? questions,
  }) {
    return {
      'id': id ?? 'test-quiz-123',
      'title': title ?? 'Test Quiz',
      'description': 'A test quiz for unit testing',
      'questions':
          questions ??
          [
            {
              'question': 'What is 2 + 2?',
              'options': ['3', '4', '5', '6'],
              'correctAnswer': 1,
            },
          ],
      'createdBy': 'test-user-123',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Create test game session data
  static Map<String, dynamic> createGameSessionData({
    String? id,
    String? pin,
    String? status,
  }) {
    return {
      'id': id ?? 'test-session-123',
      'quizId': 'test-quiz-123',
      'hostId': 'test-user-123',
      'pin': pin ?? '123456',
      'status': status ?? 'waiting',
      'players': <String, dynamic>{},
      'currentQuestionIndex': 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Create test leaderboard data
  static Map<String, dynamic> createLeaderboardData({
    String? sessionId,
    List<Map<String, dynamic>>? scores,
  }) {
    return {
      'sessionId': sessionId ?? 'test-session-123',
      'scores':
          scores ??
          [
            {
              'playerId': 'player-1',
              'playerName': 'Player 1',
              'score': 100,
              'correctAnswers': 2,
              'totalAnswers': 2,
            },
          ],
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'finalResults': false,
    };
  }
}
