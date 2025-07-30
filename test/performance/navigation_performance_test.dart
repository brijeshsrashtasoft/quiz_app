import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/navigation_utils.dart';
import '../test_config.dart';

/// Performance tests for navigation system
/// Tests navigation speed, memory usage, and responsiveness
/// Following TDD approach for performance requirements

void main() {
  group('Navigation Performance Tests', () {
    group('RED PHASE: Route Navigation Performance', () {
      widgetTestCase(
        'should navigate between routes within performance threshold',
        TestCategory.performance,
        (WidgetTester tester) async {
          // TDD RED: Test navigation speed requirements (<200ms per navigation)

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
          ];

          for (final route in routes) {
            final stopwatch = Stopwatch()..start();

            AppRouter.go(route);
            await tester.pumpAndSettle();

            stopwatch.stop();

            // Should navigate within 200ms performance threshold
            expect(
              stopwatch.elapsed,
              lessThan(const Duration(milliseconds: 200)),
              reason: 'Navigation to $route should be fast (<200ms)',
            );
          }
        },
      );

      widgetTestCase(
        'should handle rapid navigation changes efficiently',
        TestCategory.performance,
        (WidgetTester tester) async {
          // TDD RED: Test rapid navigation performance

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          final stopwatch = Stopwatch()..start();

          // Rapid navigation sequence
          const int rapidNavigationCount = 20;
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
          ];

          for (int i = 0; i < rapidNavigationCount; i++) {
            final route = routes[i % routes.length];
            AppRouter.go(route);
            await tester.pump(); // Don't wait for settle to test rapid changes
          }

          await tester.pumpAndSettle();
          stopwatch.stop();

          // Should handle rapid navigation within reasonable time
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 5)),
            reason: 'Rapid navigation should be efficient',
          );

          // Should not have performance-related errors
          expect(tester.takeException(), isNull);
        },
      );

      widgetTestCase(
        'should maintain performance with deep navigation stack',
        TestCategory.performance,
        (WidgetTester tester) async {
          // TDD RED: Test navigation stack performance

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          final stopwatch = Stopwatch()..start();

          // Build deep navigation stack
          AppRouter.go(RouteConstants.home);
          await tester.pumpAndSettle();

          for (int i = 0; i < 10; i++) {
            AppRouter.push('${RouteConstants.about}?level=$i');
            await tester.pump();
          }

          await tester.pumpAndSettle();

          // Pop through stack
          while (AppRouter.canPop()) {
            AppRouter.pop();
            await tester.pump();
          }

          await tester.pumpAndSettle();
          stopwatch.stop();

          // Should handle deep stack operations efficiently
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 3)),
            reason: 'Deep navigation stack should be performant',
          );
        },
      );
    });

    group('RED PHASE: Route Parameter Performance', () {
      testCase(
        'should validate route parameters quickly',
        TestCategory.performance,
        () {
          // TDD RED: Test parameter validation performance

          final stopwatch = Stopwatch()..start();

          // Test multiple parameter validations
          for (int i = 0; i < 1000; i++) {
            NavigationUtils.isValidQuizId('quiz-id-$i');
            NavigationUtils.isValidSessionId('session-id-$i');
            NavigationUtils.isValidQuestionIndex(i);
          }

          stopwatch.stop();

          // Should validate parameters quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Parameter validation should be fast',
          );
        },
      );

      testCase(
        'should extract parameters from state efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test parameter extraction performance

          final mockState = _MockRouterState();
          final stopwatch = Stopwatch()..start();

          // Test multiple parameter extractions
          for (int i = 0; i < 1000; i++) {
            NavigationUtils.getQuizIdFromState(mockState);
            NavigationUtils.getSessionIdFromState(mockState);
            NavigationUtils.getQuestionIndexFromState(mockState);
          }

          stopwatch.stop();

          // Should extract parameters quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 50)),
            reason: 'Parameter extraction should be fast',
          );
        },
      );
    });

    group('RED PHASE: Deep Link Performance', () {
      testCase(
        'should process deep links efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test deep link processing performance

          final testUrls = [
            'https://quizapp.com/game/join?pin=123456',
            'https://quizapp.com/quiz/test-quiz-123',
            'https://quizapp.com/game/session-456/waiting',
            'https://quizapp.com/leaderboard/session/789',
          ];

          final stopwatch = Stopwatch()..start();

          // Process multiple deep links
          for (int i = 0; i < 100; i++) {
            for (final url in testUrls) {
              NavigationUtils.extractGamePinFromUrl(url);
              NavigationUtils.isValidDeepLink(url);
              NavigationUtils.generateQuizShareUrl('quiz-$i');
              NavigationUtils.generateGameJoinUrl('${100000 + i}');
            }
          }

          stopwatch.stop();

          // Should process deep links quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 200)),
            reason: 'Deep link processing should be fast',
          );
        },
      );

      testCase(
        'should generate shareable URLs efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test URL generation performance

          final stopwatch = Stopwatch()..start();

          // Generate multiple shareable URLs
          for (int i = 0; i < 1000; i++) {
            NavigationUtils.generateQuizShareUrl('quiz-$i');
            NavigationUtils.generateGameJoinUrl('${100000 + i}');
            NavigationUtils.generateLeaderboardShareUrl('session-$i');
          }

          stopwatch.stop();

          // Should generate URLs quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'URL generation should be fast',
          );
        },
      );
    });

    group('RED PHASE: Route Classification Performance', () {
      testCase(
        'should classify routes efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test route classification performance

          final testRoutes = [
            RouteConstants.login,
            RouteConstants.register,
            RouteConstants.home,
            '/game/session-123',
            '/quiz/quiz-456',
            '/leaderboard/session/789',
            RouteConstants.about,
            RouteConstants.help,
          ];

          final stopwatch = Stopwatch()..start();

          // Classify multiple routes
          for (int i = 0; i < 1000; i++) {
            for (final route in testRoutes) {
              NavigationUtils.isAuthRoute(route);
              NavigationUtils.isGameRoute(route);
              NavigationUtils.isQuizRoute(route);
              NavigationUtils.isLeaderboardRoute(route);
            }
          }

          stopwatch.stop();

          // Should classify routes quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Route classification should be fast',
          );
        },
      );

      testCase(
        'should compare routes efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test route comparison performance

          final testRoutes = [
            '/test/route/1',
            '/test/route/2',
            '/another/path',
            '/parent/child',
            '/parent',
          ];

          final stopwatch = Stopwatch()..start();

          // Compare multiple route combinations
          for (int i = 0; i < 1000; i++) {
            for (final route1 in testRoutes) {
              for (final route2 in testRoutes) {
                NavigationUtils.isSameRoute(route1, route2);
                NavigationUtils.isChildRoute(route1, route2);
              }
            }
          }

          stopwatch.stop();

          // Should compare routes quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 200)),
            reason: 'Route comparison should be fast',
          );
        },
      );
    });

    group('RED PHASE: Analytics Performance', () {
      setUp(() {
        RouterAnalytics.clearAnalytics();
      });

      testCase(
        'should track navigation events efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test analytics tracking performance

          final stopwatch = Stopwatch()..start();

          // Track many navigation events
          for (int i = 0; i < 1000; i++) {
            RouterAnalytics.trackNavigation('/route-$i');
          }

          stopwatch.stop();

          // Should track events quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Analytics tracking should be fast',
          );

          // Should maintain reasonable memory usage
          expect(
            RouterAnalytics.navigationHistory.length,
            lessThanOrEqualTo(50),
          );
        },
      );

      testCase(
        'should handle large visit counts efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test analytics performance with high visit counts

          const testRoute = '/popular-route';
          final stopwatch = Stopwatch()..start();

          // Track many visits to same route
          for (int i = 0; i < 10000; i++) {
            RouterAnalytics.trackNavigation(testRoute);
          }

          stopwatch.stop();

          // Should handle high visit counts efficiently
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 500)),
            reason: 'High visit count tracking should be efficient',
          );

          expect(RouterAnalytics.routeVisitCounts[testRoute], equals(10000));
        },
      );

      testCase(
        'should clear analytics data quickly',
        TestCategory.performance,
        () {
          // TDD RED: Test analytics clearing performance

          // Fill up analytics data
          for (int i = 0; i < 1000; i++) {
            RouterAnalytics.trackNavigation('/route-$i');
          }

          final stopwatch = Stopwatch()..start();
          RouterAnalytics.clearAnalytics();
          stopwatch.stop();

          // Should clear data quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 10)),
            reason: 'Analytics clearing should be fast',
          );

          expect(RouterAnalytics.navigationHistory, isEmpty);
          expect(RouterAnalytics.routeVisitCounts, isEmpty);
          expect(RouterAnalytics.recentlyVisited, isEmpty);
        },
      );
    });

    group('RED PHASE: Breadcrumb Performance', () {
      testCase(
        'should generate breadcrumbs efficiently',
        TestCategory.performance,
        () {
          // TDD RED: Test breadcrumb generation performance

          final testRoutes = [
            '/quiz-creation/form',
            '/quiz-creation/preview',
            '/game/session123/waiting',
            '/game/session123/question/5',
            '/leaderboard/session/456',
            '/home',
            '/login',
          ];

          final stopwatch = Stopwatch()..start();

          // Generate breadcrumbs for multiple routes
          for (int i = 0; i < 1000; i++) {
            for (final route in testRoutes) {
              NavigationUtils.generateBreadcrumbs(route);
            }
          }

          stopwatch.stop();

          // Should generate breadcrumbs quickly
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Breadcrumb generation should be fast',
          );
        },
      );
    });

    group('RED PHASE: Memory Usage Performance', () {
      widgetTestCase(
        'should maintain reasonable memory usage during navigation',
        TestCategory.performance,
        (WidgetTester tester) async {
          // TDD RED: Test memory usage during extended navigation

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Perform extensive navigation to test memory usage
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
          ];

          // Navigation cycles to simulate extended usage
          for (int cycle = 0; cycle < 20; cycle++) {
            for (final route in routes) {
              AppRouter.go(route);
              await tester.pump();

              // Track analytics to test memory with data accumulation
              RouterAnalytics.trackNavigation(route);
            }

            // Periodically settle and check for memory issues
            if (cycle % 5 == 0) {
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          }

          await tester.pumpAndSettle();

          // Should not have memory-related errors
          expect(tester.takeException(), isNull);

          // Analytics should have limited memory usage
          expect(
            RouterAnalytics.navigationHistory.length,
            lessThanOrEqualTo(50),
          );
        },
      );

      testCase(
        'should handle memory efficiently with large datasets',
        TestCategory.performance,
        () {
          // TDD RED: Test memory efficiency with large route datasets

          RouterAnalytics.clearAnalytics();

          // Create large dataset
          final routes = List.generate(10000, (i) => '/route-$i');

          final stopwatch = Stopwatch()..start();

          // Process large dataset
          for (final route in routes) {
            RouterAnalytics.trackNavigation(route);

            // Also test route utilities with large dataset
            if (route.contains('game')) {
              NavigationUtils.isGameRoute(route);
            }
            if (route.contains('quiz')) {
              NavigationUtils.isQuizRoute(route);
            }
          }

          stopwatch.stop();

          // Should handle large dataset efficiently
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 5)),
            reason: 'Large dataset processing should be efficient',
          );

          // Should maintain memory limits
          expect(
            RouterAnalytics.navigationHistory.length,
            lessThanOrEqualTo(50),
          );
        },
      );
    });

    group('RED PHASE: Concurrent Performance', () {
      testCase(
        'should handle concurrent navigation operations efficiently',
        TestCategory.performance,
        () async {
          // TDD RED: Test concurrent navigation performance

          final stopwatch = Stopwatch()..start();

          // Simulate concurrent operations
          final futures = <Future>[];

          for (int i = 0; i < 10; i++) {
            futures.add(
              Future(() {
                // Each future performs navigation operations
                for (int j = 0; j < 50; j++) {
                  RouterAnalytics.trackNavigation('/concurrent-route-$i-$j');
                  NavigationUtils.isValidQuizId('quiz-$i-$j');
                  NavigationUtils.generateGameJoinUrl(
                    '${100000 + i * 100 + j}',
                  );
                }
              }),
            );
          }

          await Future.wait(futures);
          stopwatch.stop();

          // Should handle concurrent operations efficiently
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 2)),
            reason: 'Concurrent navigation operations should be efficient',
          );
        },
      );
    });
  });
}

/// Mock router state for testing
class _MockRouterState {
  final Map<String, String> pathParameters = {
    'quizId': 'test-quiz-123',
    'sessionId': 'test-session-456',
    'questionIndex': '5',
  };
}
