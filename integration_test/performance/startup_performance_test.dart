import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;

import '../helpers/test_utilities.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Startup Performance Tests', () {
    late E2ETestUtilities testUtils;

    setUpAll(() async {
      testUtils = E2ETestUtilities();
      await testUtils.initialize();
    });

    setUp(() async {
      await testUtils.resetAppState();
    });

    tearDown(() async {
      await testUtils.cleanup();
    });

    tearDownAll(() async {
      await testUtils.dispose();
    });

    testWidgets('Cold startup performance benchmark', (
      WidgetTester tester,
    ) async {
      // Measure cold startup time
      final stopwatch = Stopwatch()..start();

      // Start the app
      app.main();

      // Wait for first frame
      await tester.pumpAndSettle();

      // Wait for app to be fully loaded
      await tester.pumpAndSettle(const Duration(seconds: 1));

      stopwatch.stop();
      final startupTime = stopwatch.elapsed;

      // Performance requirement: <3 seconds cold startup
      expect(
        startupTime.inMilliseconds,
        lessThan(3000),
        reason: 'Cold startup should be under 3 seconds',
      );

      // Log performance metrics
      print('📊 Cold Startup Performance:');
      print('  - Startup Time: ${startupTime.inMilliseconds}ms');
      print('  - Target: <3000ms');
      print(
        '  - Status: ${startupTime.inMilliseconds < 3000 ? "✅ PASS" : "❌ FAIL"}',
      );

      // Store metrics for reporting
      testUtils.getPerformanceReport()['coldStartupTime'] =
          startupTime.inMilliseconds;
    });

    testWidgets('Startup performance regression test', (
      WidgetTester tester,
    ) async {
      // Run multiple startup cycles to check for performance regression
      final startupTimes = <int>[];

      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();

        app.main();
        await tester.pumpAndSettle();

        stopwatch.stop();
        startupTimes.add(stopwatch.elapsed.inMilliseconds);

        // Reset between cycles
        await testUtils.resetAppState();
      }

      // Calculate statistics
      final averageStartupTime =
          startupTimes.reduce((a, b) => a + b) / startupTimes.length;
      final maxStartupTime = startupTimes.reduce((a, b) => a > b ? a : b);
      final minStartupTime = startupTimes.reduce((a, b) => a < b ? a : b);
      final variance =
          startupTimes
              .map(
                (time) =>
                    (time - averageStartupTime) * (time - averageStartupTime),
              )
              .reduce((a, b) => a + b) /
          startupTimes.length;
      final standardDeviation = math.sqrt(variance);

      // Performance requirements
      expect(
        averageStartupTime,
        lessThan(3000),
        reason: 'Average startup time should be under 3 seconds',
      );
      expect(
        maxStartupTime,
        lessThan(4000),
        reason: 'Maximum startup time should be under 4 seconds',
      );
      expect(
        standardDeviation,
        lessThan(500),
        reason: 'Startup time should be consistent (std dev < 500ms)',
      );

      print('📊 Startup Performance Regression Analysis:');
      print('  - Average: ${averageStartupTime.toStringAsFixed(0)}ms');
      print('  - Min: ${minStartupTime}ms');
      print('  - Max: ${maxStartupTime}ms');
      print('  - Std Dev: ${standardDeviation.toStringAsFixed(0)}ms');
      print(
        '  - Consistency: ${standardDeviation < 500 ? "✅ CONSISTENT" : "⚠️ VARIABLE"}',
      );

      // Store regression metrics
      final report = testUtils.getPerformanceReport();
      report['averageStartupTime'] = averageStartupTime;
      report['maxStartupTime'] = maxStartupTime;
      report['minStartupTime'] = minStartupTime;
      report['startupConsistency'] = standardDeviation;
    });
  });
}
