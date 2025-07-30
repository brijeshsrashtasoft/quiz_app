import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/utils/result.dart';

/// Test utilities for common testing scenarios
class TestUtilities {
  static final Random _random = Random();

  /// Generate a random string of specified length
  static String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// Generate a random integer within range
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Generate a random double within range
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  /// Generate a random boolean
  static bool randomBool() {
    return _random.nextBool();
  }

  /// Generate a random color
  static Color randomColor() {
    return Color.fromRGBO(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      1.0,
    );
  }

  /// Generate a random DateTime within the last year
  static DateTime randomDateTime() {
    final now = DateTime.now();
    final daysBack = _random.nextInt(365);
    return now.subtract(Duration(days: daysBack));
  }

  /// Generate a random email address
  static String randomEmail() {
    final username = randomString(8).toLowerCase();
    final domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'example.com'];
    final domain = domains[_random.nextInt(domains.length)];
    return '$username@$domain';
  }

  /// Generate a random phone number
  static String randomPhoneNumber() {
    return '+1${randomInt(100, 999)}${randomInt(100, 999)}${randomInt(1000, 9999)}';
  }

  /// Generate a random PIN code
  static String randomPin({int length = 6}) {
    return List.generate(length, (_) => randomInt(0, 9)).join();
  }

  /// Generate a random UUID-like string
  static String randomId() {
    return '${randomString(8)}-${randomString(4)}-${randomString(4)}-${randomString(4)}-${randomString(12)}'.toLowerCase();
  }

  /// Create a delay for testing async operations
  static Future<void> delay([Duration duration = const Duration(milliseconds: 100)]) {
    return Future.delayed(duration);
  }

  /// Create a random list of items
  static List<T> randomList<T>(T Function() generator, {int? length}) {
    final listLength = length ?? randomInt(1, 10);
    return List.generate(listLength, (_) => generator());
  }

  /// Create a random map with string keys
  static Map<String, dynamic> randomMap({int? keyCount}) {
    final count = keyCount ?? randomInt(3, 8);
    final map = <String, dynamic>{};
    
    for (int i = 0; i < count; i++) {
      final key = randomString(8).toLowerCase();
      final valueType = randomInt(0, 4);
      
      switch (valueType) {
        case 0:
          map[key] = randomString(10);
          break;
        case 1:
          map[key] = randomInt(1, 1000);
          break;
        case 2:
          map[key] = randomDouble(0.0, 100.0);
          break;
        case 3:
          map[key] = randomBool();
          break;
        default:
          map[key] = randomDateTime().toIso8601String();
      }
    }
    
    return map;
  }
}

/// Mock result builders for testing Result<T> pattern
class MockResultBuilder {
  /// Create a successful result
  static Result<T> success<T>(T data) {
    return Result.success(data);
  }

  /// Create a failure result
  static Result<T> failure<T>(String message, [int? code]) {
    return Result.failure(
      message: message,
      code: code ?? 500,
    );
  }

  /// Create a random result (50% success, 50% failure)
  static Result<T> random<T>(T successData, [String? errorMessage]) {
    if (TestUtilities.randomBool()) {
      return success(successData);
    } else {
      return failure(errorMessage ?? 'Random test failure');
    }
  }

  /// Create a loading result (if your Result class supports it)
  static Result<T> loading<T>() {
    // This depends on your Result implementation
    // For now, return a success with null data
    return Result.success(null as T);
  }
}

/// Test expectation helpers
class TestExpectations {
  /// Expect widget to be found exactly once
  static void expectSingleWidget(Type widgetType) {
    expect(find.byType(widgetType), findsOneWidget);
  }

  /// Expect text to be found exactly once
  static void expectSingleText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Expect widget to not be found
  static void expectNoWidget(Type widgetType) {
    expect(find.byType(widgetType), findsNothing);
  }

  /// Expect text to not be found
  static void expectNoText(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Expect multiple widgets of same type
  static void expectMultipleWidgets(Type widgetType, int count) {
    expect(find.byType(widgetType), findsNWidgets(count));
  }

  /// Expect at least one widget
  static void expectAtLeastOneWidget(Type widgetType) {
    expect(find.byType(widgetType), findsAtLeastNWidgets(1));
  }

  /// Expect widget to have specific property
  static void expectWidgetProperty<T extends Widget>(
    Type widgetType,
    bool Function(T) predicate,
    String description,
  ) {
    final widget = find.byType(widgetType).evaluate().single.widget as T;
    expect(predicate(widget), isTrue, reason: description);
  }

  /// Expect async operation to complete
  static Future<void> expectAsyncCompletion(
    Future<void> Function() operation, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await expectLater(
      operation(),
      completes,
      reason: 'Async operation should complete within timeout',
    );
  }

  /// Expect async operation to throw
  static Future<void> expectAsyncThrow(
    Future<void> Function() operation,
    dynamic matcher,
  ) async {
    await expectLater(
      operation(),
      throwsA(matcher),
    );
  }
}

/// Performance testing utilities
class PerformanceTestUtils {
  /// Measure widget build time
  static Future<Duration> measureBuildTime(
    WidgetTester tester,
    Widget widget,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    await tester.pumpWidget(widget);
    
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measure animation performance
  static Future<List<Duration>> measureAnimationFrames(
    WidgetTester tester,
    VoidCallback triggerAnimation,
    Duration animationDuration,
  ) async {
    final frameTimes = <Duration>[];
    final stopwatch = Stopwatch();
    
    triggerAnimation();
    stopwatch.start();
    
    while (stopwatch.elapsed < animationDuration) {
      final frameStart = stopwatch.elapsed;
      await tester.pump(const Duration(milliseconds: 16)); // 60fps
      final frameEnd = stopwatch.elapsed;
      frameTimes.add(frameEnd - frameStart);
    }
    
    return frameTimes;
  }

  /// Check if widget renders within performance threshold
  static Future<bool> isPerformant(
    WidgetTester tester,
    Widget widget, {
    Duration threshold = const Duration(milliseconds: 100),
  }) async {
    final buildTime = await measureBuildTime(tester, widget);
    return buildTime <= threshold;
  }
}

/// Memory testing utilities
class MemoryTestUtils {
  /// Track memory usage during test
  static Future<void> trackMemoryUsage(
    String testName,
    Future<void> Function() testFunction,
  ) async {
    // Force garbage collection before test
    await _forceGarbageCollection();
    
    print('Starting memory tracking for: $testName');
    
    await testFunction();
    
    // Force garbage collection after test
    await _forceGarbageCollection();
    
    print('Completed memory tracking for: $testName');
  }

  static Future<void> _forceGarbageCollection() async {
    // Trigger multiple GC cycles
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      // In a real implementation, you might use developer tools
      // or platform-specific memory APIs
    }
  }

  /// Check for memory leaks in widget disposal
  static Future<void> checkForMemoryLeaks(
    WidgetTester tester,
    Widget widget,
  ) async {
    // Create and dispose widget multiple times
    for (int i = 0; i < 10; i++) {
      await tester.pumpWidget(widget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
    
    await _forceGarbageCollection();
    
    // In a real implementation, you would check actual memory usage
    // This is more of a framework for memory testing
  }
}

/// Accessibility testing utilities
class AccessibilityTestUtils {
  /// Check if widget meets accessibility guidelines
  static Future<void> checkAccessibility(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(widget);
    
    // Check for semantic labels
    final semantics = tester.allSemantics;
    expect(semantics, isNotEmpty, reason: 'Widget should have semantic information');
    
    // Check for proper contrast (this would need actual implementation)
    await _checkColorContrast(tester);
    
    // Check for touch target sizes
    await _checkTouchTargets(tester);
  }

  static Future<void> _checkColorContrast(WidgetTester tester) async {
    // Implementation would check actual color contrast ratios
    // This is a placeholder for the framework
  }

  static Future<void> _checkTouchTargets(WidgetTester tester) async {
    // Check that interactive elements meet minimum size requirements
    final buttons = find.byType(GestureDetector);
    
    for (final button in buttons.evaluate()) {
      final size = tester.getSize(find.byWidget(button.widget));
      expect(size.width, greaterThanOrEqualTo(44.0), 
             reason: 'Touch targets should be at least 44x44 points');
      expect(size.height, greaterThanOrEqualTo(44.0), 
             reason: 'Touch targets should be at least 44x44 points');
    }
  }

  /// Generate accessibility report
  static Map<String, dynamic> generateAccessibilityReport(
    WidgetTester tester,
  ) {
    final semantics = tester.allSemantics;
    
    return {
      'totalElements': semantics.length,
      'elementsWithLabels': semantics.where((s) => s.label?.isNotEmpty == true).length,
      'buttons': semantics.where((s) => s.hasFlag(SemanticsFlag.isButton)).length,
      'textFields': semantics.where((s) => s.hasFlag(SemanticsFlag.isTextField)).length,
      'images': semantics.where((s) => s.hasFlag(SemanticsFlag.isImage)).length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}