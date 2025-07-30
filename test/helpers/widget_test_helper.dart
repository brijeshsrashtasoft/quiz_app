import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/shared/theme/app_theme.dart';

/// Helper function to wrap widgets for testing with proper theme and material app
Widget buildTestableWidget(
  Widget child, {
  ThemeData? theme,
  Locale? locale,
  NavigatorObserver? navigatorObserver,
  List<NavigatorObserver>? navigatorObservers,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    locale: locale,
    navigatorObservers:
        navigatorObservers ??
        (navigatorObserver != null ? [navigatorObserver] : []),
    home: Scaffold(body: child),
  );
}

/// Helper function to create a mock MaterialApp with routing
Widget buildTestableWidgetWithRouter(
  Widget child, {
  String initialRoute = '/',
  Map<String, WidgetBuilder>? routes,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    initialRoute: initialRoute,
    routes: routes ?? {'/': (context) => Scaffold(body: child)},
  );
}

/// Helper function to pump widget and wait for animations
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(timeout);
}

/// Helper function to find widget by key with type safety
T findWidgetByKey<T extends Widget>(Key key) {
  final finder = find.byKey(key);
  return finder.evaluate().single.widget as T;
}

/// Helper function to simulate long press gesture
Future<void> longPress(
  WidgetTester tester,
  Finder finder, {
  Duration duration = const Duration(milliseconds: 500),
}) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  await tester.pump(duration);
  await gesture.up();
  await tester.pump();
}

/// Helper function to simulate swipe gesture
Future<void> swipe(WidgetTester tester, Finder finder, Offset offset) async {
  await tester.drag(finder, offset);
  await tester.pumpAndSettle();
}

/// Helper function to enter text with proper focus handling
Future<void> enterTextHelper(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.tap(finder);
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Helper function to scroll until widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder item,
  Finder scrollable, {
  double delta = 100.0,
}) async {
  await tester.scrollUntilVisible(item, delta, scrollable: scrollable);
}

/// Custom matchers for widget testing
class WidgetMatchers {
  /// Matcher to check if widget has specific color
  static Matcher hasColor(Color expectedColor) {
    return predicate<Widget>((widget) {
      if (widget is Container) {
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == expectedColor;
        }
      }
      return false;
    }, 'has color $expectedColor');
  }

  /// Matcher to check if widget is enabled
  static Matcher isEnabled() {
    return predicate<Widget>((widget) {
      if (widget is TextButton) {
        return widget.onPressed != null;
      }
      if (widget is ElevatedButton) {
        return widget.onPressed != null;
      }
      if (widget is OutlinedButton) {
        return widget.onPressed != null;
      }
      return true;
    }, 'is enabled');
  }

  /// Matcher to check if widget is disabled
  static Matcher isDisabled() {
    return predicate<Widget>((widget) {
      if (widget is TextButton) {
        return widget.onPressed == null;
      }
      if (widget is ElevatedButton) {
        return widget.onPressed == null;
      }
      if (widget is OutlinedButton) {
        return widget.onPressed == null;
      }
      return false;
    }, 'is disabled');
  }

  /// Matcher to check if text has specific style property
  static Matcher hasTextStyle(TextStyle expectedStyle) {
    return predicate<Text>((text) {
      return text.style?.fontSize == expectedStyle.fontSize &&
          text.style?.color == expectedStyle.color &&
          text.style?.fontWeight == expectedStyle.fontWeight;
    }, 'has text style $expectedStyle');
  }
}

/// Test data builders for common scenarios
class TestDataBuilders {
  /// Create test quiz data
  static Map<String, dynamic> createQuizData({
    String? id,
    String? title,
    String? description,
    int? questionCount,
    String? imageUrl,
  }) {
    return {
      'id': id ?? 'test_quiz_1',
      'title': title ?? 'Test Quiz',
      'description': description ?? 'A test quiz for unit testing',
      'questionCount': questionCount ?? 10,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
      'isPublic': true,
    };
  }

  /// Create test user data
  static Map<String, dynamic> createUserData({
    String? id,
    String? name,
    String? email,
  }) {
    return {
      'id': id ?? 'test_user_1',
      'name': name ?? 'Test User',
      'email': email ?? 'test@example.com',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test game session data
  static Map<String, dynamic> createGameSessionData({
    String? id,
    String? pin,
    String? quizId,
    String? hostId,
    String? status,
  }) {
    return {
      'id': id ?? 'test_session_1',
      'pin': pin ?? '123456',
      'quizId': quizId ?? 'test_quiz_1',
      'hostId': hostId ?? 'test_user_1',
      'status': status ?? 'waiting',
      'players': <String, dynamic>{},
      'currentQuestionIndex': 0,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test question data
  static Map<String, dynamic> createQuestionData({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswer,
    int? timeLimit,
  }) {
    return {
      'id': id ?? 'test_question_1',
      'question': question ?? 'What is 2 + 2?',
      'options': options ?? ['2', '3', '4', '5'],
      'correctAnswer': correctAnswer ?? 2,
      'timeLimit': timeLimit ?? 30,
      'points': 1000,
    };
  }
}

/// Mock navigator observer for testing navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> routes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      routes.remove(oldRoute);
    }
    if (newRoute != null) {
      routes.add(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    // Implementation for new method
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    // Implementation for new method
  }

  @override
  void didStopUserGesture() {
    // Implementation for new method
  }
}

/// Mock class for testing (requires mockito to be added to pubspec)
class Mock {
  // This is a placeholder - in real implementation, you'd use mockito's Mock
  // For now, this allows the code to compile
}

/// Extension methods for widget testing
extension WidgetTesterExtensions on WidgetTester {
  /// Pump widget with default duration
  Future<void> pumpWithDuration([
    Duration duration = const Duration(milliseconds: 100),
  ]) async {
    await pump(duration);
  }

  /// Pump and settle with timeout
  Future<void> pumpAndSettleWithTimeout([
    Duration timeout = const Duration(seconds: 5),
  ]) async {
    await pumpAndSettle(timeout);
  }

  /// Find and tap with automatic pump
  Future<void> tapAndPump(Finder finder) async {
    await tap(finder);
    await pump();
  }

  /// Enter text and pump
  Future<void> enterTextAndPump(Finder finder, String text) async {
    await tap(finder);
    await enterText(finder, text);
    await pump();
  }
}
