import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Base test helper class providing common functionality for E2E tests
class E2ETestHelpers {
  const E2ETestHelpers._();

  /// Initialize integration test binding
  static void initialize() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Wait for widget to appear with custom timeout
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    final end = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle();
      
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      
      await Future.delayed(interval);
    }
    
    throw Exception('Widget not found within ${timeout.inSeconds} seconds');
  }

  /// Wait for navigation to complete
  static Future<void> waitForNavigation(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Take screenshot for debugging
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name,
  ) async {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }

  /// Verify text exists on screen
  static void verifyTextExists(String text) {
    expect(find.text(text), findsOneWidget, reason: 'Text "$text" should be visible');
  }

  /// Verify widget exists by key
  static void verifyWidgetExists(Key key) {
    expect(find.byKey(key), findsOneWidget, reason: 'Widget with key "$key" should exist');
  }

  /// Verify widget exists by type
  static void verifyWidgetByType<T extends Widget>() {
    expect(find.byType(T), findsOneWidget, reason: 'Widget of type "$T" should exist');
  }

  /// Verify multiple widgets exist by type
  static void verifyMultipleWidgetsByType<T extends Widget>(int expectedCount) {
    expect(
      find.byType(T),
      findsNWidgets(expectedCount),
      reason: 'Expected $expectedCount widgets of type "$T"',
    );
  }

  /// Tap on widget and wait for result
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration settleTime = const Duration(milliseconds: 500),
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(settleTime);
  }

  /// Enter text in field and wait
  static Future<void> enterTextAndWait(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration settleTime = const Duration(milliseconds: 500),
  }) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle(settleTime);
  }

  /// Scroll until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100.0,
    AxisDirection scrollDirection = AxisDirection.down,
  }) async {
    const maxScrolls = 50;
    int scrollCount = 0;

    while (finder.evaluate().isEmpty && scrollCount < maxScrolls) {
      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pumpAndSettle();
      scrollCount++;
    }

    if (finder.evaluate().isEmpty) {
      throw Exception('Widget not found after scrolling');
    }
  }

  /// Wait for loading to complete (no CircularProgressIndicator)
  static Future<void> waitForLoadingToComplete(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle();
      
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    throw Exception('Loading did not complete within ${timeout.inSeconds} seconds');
  }

  /// Verify route by checking URL (web) or route name
  static void verifyCurrentRoute(String expectedRoute) {
    // This would need to be implemented based on your routing system
    // For now, we'll use a simple widget finder approach
    // In a real implementation, you'd check the router state
  }

  /// Handle platform-specific behaviors
  static Future<void> handlePlatformSpecificSetup(WidgetTester tester) async {
    // Add any platform-specific setup here
    await tester.pumpAndSettle();
  }
}

/// Custom finders for common UI patterns
class E2EFinders {
  const E2EFinders._();

  /// Find button by text
  static Finder buttonWithText(String text) {
    return find.widgetWithText(ElevatedButton, text);
  }

  /// Find icon button by icon
  static Finder iconButton(IconData icon) {
    return find.byIcon(icon);
  }

  /// Find text field by label
  static Finder textFieldWithLabel(String label) {
    return find.widgetWithText(TextField, label);
  }

  /// Find card with specific content
  static Finder cardWithText(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(Card),
    );
  }

  /// Find navigation item
  static Finder navigationItem(String text) {
    return find.text(text);
  }
}

/// Test data helpers
class E2ETestData {
  const E2ETestData._();

  /// Mock user data for authentication tests
  static const Map<String, String> mockUser = {
    'email': 'test@example.com',
    'password': 'TestPassword123!',
    'name': 'Test User',
  };

  /// Mock quiz data
  static const Map<String, dynamic> mockQuiz = {
    'title': 'Test Quiz',
    'description': 'A quiz for testing purposes',
    'questions': 5,
    'difficulty': 'Medium',
    'category': 'Test',
  };

  /// Test PIN for game sessions
  static const String testPin = '123456';
}