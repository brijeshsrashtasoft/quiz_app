import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/navigation_utils.dart';
import '../../test_config.dart';

/// Integration tests for complete navigation flows
/// Tests end-to-end navigation scenarios and user journeys
/// Following TDD approach for navigation integration testing

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Integration Tests', () {
    group('RED PHASE: Core Navigation Flow', () {
      widgetTestCase(
        'should complete basic navigation journey successfully',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test basic user navigation through public pages

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: AppRouter.router,
                title: 'Navigation Test App',
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Start at initial route
          expect(tester.takeException(), isNull);

          // Navigate through public pages
          final publicRoutes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
          ];

          for (final route in publicRoutes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            // Should navigate without errors
            expect(tester.takeException(), isNull);

            // Should update current route
            final currentRoute = AppRouter.currentRoute;
            expect(currentRoute, isNotNull);
          }
        },
      );

      widgetTestCase(
        'should handle navigation stack operations correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test push/pop navigation stack operations

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Build navigation stack
          AppRouter.go(RouteConstants.home);
          await tester.pumpAndSettle();

          AppRouter.push(RouteConstants.about);
          await tester.pumpAndSettle();
          expect(AppRouter.canPop(), isTrue);

          AppRouter.push(RouteConstants.help);
          await tester.pumpAndSettle();
          expect(AppRouter.canPop(), isTrue);

          // Pop back through stack
          AppRouter.pop();
          await tester.pumpAndSettle();
          expect(AppRouter.canPop(), isTrue);

          AppRouter.pop();
          await tester.pumpAndSettle();

          // Should not throw errors
          expect(tester.takeException(), isNull);
        },
      );

      widgetTestCase(
        'should clear navigation stack correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test navigation stack clearing

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Build up navigation stack
          AppRouter.go(RouteConstants.home);
          await tester.pumpAndSettle();

          for (int i = 0; i < 3; i++) {
            AppRouter.push('${RouteConstants.about}?level=$i');
            await tester.pumpAndSettle();
          }

          expect(AppRouter.canPop(), isTrue);

          // Clear stack and navigate to new route
          AppRouter.clearAndGoTo(RouteConstants.home);
          await tester.pumpAndSettle();

          // Should have cleared the stack
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Deep Link Navigation Flow', () {
      widgetTestCase(
        'should handle game join deep links correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test deep link handling for game joining

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Test game join deep link with PIN
          const gamePin = '123456';
          final gameJoinUrl = '${RouteConstants.gameJoin}?pin=$gamePin';

          AppRouter.go(gameJoinUrl);
          await tester.pumpAndSettle();

          // Should navigate to game join page
          expect(tester.takeException(), isNull);

          // Should handle deep link processing
          final result = await AppRouterHelper.handleGameJoinDeepLink(
            'https://quizapp.com$gameJoinUrl',
          );
          expect(result, isA<bool>());
        },
      );

      widgetTestCase(
        'should handle quiz sharing deep links correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test quiz sharing deep link flow

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Test quiz details deep link
          const quizId = 'test-quiz-123';
          final quizUrl = RouteConstants.quizDetailsPath(quizId);

          AppRouter.go(quizUrl);
          await tester.pumpAndSettle();

          // Should handle navigation (might show error page if quiz doesn't exist)
          expect(tester.takeException(), isNull);

          // Test share link generation
          final shareLink = AppRouterHelper.generateQuizShareLink(quizId);
          expect(shareLink, contains(quizId));
        },
      );

      widgetTestCase(
        'should handle invalid deep links gracefully',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test error handling for invalid deep links

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Test invalid deep links
          final invalidLinks = [
            '/game/invalid-session',
            '/quiz/invalid-quiz',
            '/non-existent-route',
            '/game/join?pin=invalid',
          ];

          for (final link in invalidLinks) {
            AppRouter.go(link);
            await tester.pumpAndSettle();

            // Should handle gracefully without crashing
            expect(tester.takeException(), isNull);
          }
        },
      );
    });

    group('RED PHASE: Route Parameter Validation Flow', () {
      widgetTestCase(
        'should validate and handle route parameters correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test parameter validation in navigation flow

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Test valid parameters
          final validRoutes = [
            RouteConstants.quizDetailsPath('valid-quiz-123'),
            RouteConstants.gameSessionPath('valid-session-456'),
            RouteConstants.gameQuestionPath('session-123', 5),
            RouteConstants.leaderboardSessionPath('session-789'),
          ];

          for (final route in validRoutes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            // Should navigate without throwing
            expect(tester.takeException(), isNull);
          }

          // Test invalid parameters
          final invalidRoutes = [
            RouteConstants.quizDetailsPath(''),
            RouteConstants.gameSessionPath('x'),
            RouteConstants.gameQuestionPath('session', -1),
            RouteConstants.leaderboardSessionPath(''),
          ];

          for (final route in invalidRoutes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            // Should handle invalid parameters gracefully
            expect(tester.takeException(), isNull);
          }
        },
      );
    });

    group('RED PHASE: Navigation Analytics Flow', () {
      widgetTestCase(
        'should track navigation analytics throughout user journey',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test analytics tracking during navigation

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Clear analytics before test
          RouterAnalytics.clearAnalytics();

          // Navigate through various routes
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
            RouteConstants.help,
          ];

          for (final route in routes) {
            AppRouter.go(route);
            RouterAnalytics.trackNavigation(route);
            await tester.pumpAndSettle();
          }

          // Verify analytics tracking
          final history = RouterAnalytics.navigationHistory;
          expect(history.length, equals(routes.length));

          for (final route in routes) {
            expect(history, contains(route));
            expect(RouterAnalytics.routeVisitCounts[route], equals(1));
          }

          // Visit some routes multiple times
          AppRouter.go(RouteConstants.home);
          RouterAnalytics.trackNavigation(RouteConstants.home);
          await tester.pumpAndSettle();

          expect(
            RouterAnalytics.routeVisitCounts[RouteConstants.home],
            equals(2),
          );
        },
      );

      widgetTestCase(
        'should maintain analytics performance during extended usage',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test analytics performance over extended use

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          RouterAnalytics.clearAnalytics();

          final stopwatch = Stopwatch()..start();

          // Simulate extended navigation usage
          for (int i = 0; i < 100; i++) {
            final route = '/test-route-$i';
            RouterAnalytics.trackNavigation(route);

            if (i % 10 == 0) {
              // Periodically navigate to keep UI responsive
              AppRouter.go(RouteConstants.home);
              await tester.pump();
            }
          }

          stopwatch.stop();

          // Should complete within reasonable time
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 5)),
            reason: 'Analytics tracking should be performant',
          );

          // Should limit history size
          expect(
            RouterAnalytics.navigationHistory.length,
            lessThanOrEqualTo(50),
          );
        },
      );
    });

    group('RED PHASE: Error Recovery Flow', () {
      widgetTestCase(
        'should recover from navigation errors and continue functioning',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test error recovery and continued functionality

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Start with valid navigation
          AppRouter.go(RouteConstants.home);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Trigger navigation errors
          final errorRoutes = [
            '/completely-invalid-route',
            '/another-bad-route',
            '/yet-another-invalid-route',
          ];

          for (final route in errorRoutes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            // Clear any exceptions
            final exception = tester.takeException();
            if (exception != null) {
              // Expected - should handle gracefully
            }
          }

          // Should recover and work normally
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          AppRouter.go(RouteConstants.help);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );

      widgetTestCase(
        'should handle safe navigation methods correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test safe navigation error handling

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          final context = tester.element(find.byType(MaterialApp));

          // Test safe navigation methods
          var errorCallbackCalled = false;

          NavigationUtils.safeNavigate(
            context,
            '/invalid-route',
            onError: () => errorCallbackCalled = true,
          );

          await tester.pumpAndSettle();

          // Should handle error gracefully
          expect(tester.takeException(), isNull);

          // Test safe push navigation
          NavigationUtils.safePush(context, RouteConstants.about);

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Test error recovery
          NavigationUtils.recoverFromNavigationError(context);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Complex Navigation Scenarios', () {
      widgetTestCase(
        'should handle multi-step navigation workflows',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test complex multi-step navigation flows

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Simulate quiz creation workflow
          AppRouter.go(RouteConstants.quizCreation);
          await tester.pumpAndSettle();

          AppRouter.go(RouteConstants.quizCreationForm);
          await tester.pumpAndSettle();

          AppRouter.go(RouteConstants.quizCreationPreview);
          await tester.pumpAndSettle();

          AppRouter.go(RouteConstants.quizCreationPublish);
          await tester.pumpAndSettle();

          // Should complete workflow without errors
          expect(tester.takeException(), isNull);

          // Simulate game flow
          AppRouter.go(RouteConstants.gameJoin);
          await tester.pumpAndSettle();

          AppRouter.go(RouteConstants.gameHost);
          await tester.pumpAndSettle();

          AppRouter.go(RouteConstants.gameHostSetup);
          await tester.pumpAndSettle();

          // Should handle game flow without errors
          expect(tester.takeException(), isNull);
        },
      );

      widgetTestCase(
        'should handle parallel navigation operations',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test handling of rapid/parallel navigation

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Rapid navigation changes
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
          ];

          // Navigate rapidly without waiting for settle
          for (final route in routes) {
            AppRouter.go(route);
            await tester.pump(); // Don't wait for animations
          }

          // Should handle rapid changes without errors
          expect(tester.takeException(), isNull);

          // Wait for everything to settle
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Navigation State Consistency', () {
      widgetTestCase(
        'should maintain consistent navigation state',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test navigation state consistency

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Test navigation state tracking
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();

          final currentRoute = AppRouter.currentRoute;
          expect(currentRoute, isNotNull);

          // Test route checking
          expect(AppRouter.isCurrentRoute(RouteConstants.about), isA<bool>());

          // Navigate and verify state updates
          AppRouter.go(RouteConstants.help);
          await tester.pumpAndSettle();

          final newRoute = AppRouter.currentRoute;
          expect(newRoute, isNotNull);
          expect(newRoute, isNot(equals(currentRoute)));
        },
      );

      widgetTestCase(
        'should provide accurate navigation context',
        TestCategory.integration,
        (WidgetTester tester) async {
          // TDD RED: Test navigation context accuracy

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Test different route contexts
          final testRoutes = [
            RouteConstants.home,
            RouteConstants.login, // Auth route
            '/game/test-session', // Game route
            '/quiz/test-quiz', // Quiz route
            RouteConstants.leaderboard, // Leaderboard route
          ];

          for (final route in testRoutes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            final context = AppRouterHelper.getCurrentContext();
            expect(context, isA<NavigationContext>());
            expect(context.route, isA<String>());
            expect(
              context.isGameRoute,
              equals(NavigationUtils.isGameRoute(route)),
            );
            expect(
              context.isAuthRoute,
              equals(NavigationUtils.isAuthRoute(route)),
            );
            expect(
              context.isQuizRoute,
              equals(NavigationUtils.isQuizRoute(route)),
            );
            expect(context.breadcrumbs, isA<List<String>>());
          }
        },
      );
    });

    group('RED PHASE: Performance Under Load', () {
      widgetTestCase(
        'should maintain performance during extended navigation usage',
        TestCategory.performance,
        (WidgetTester tester) async {
          // TDD RED: Test performance under sustained navigation load

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          final stopwatch = Stopwatch()..start();

          // Sustained navigation operations
          for (int cycle = 0; cycle < 10; cycle++) {
            final routes = [
              RouteConstants.home,
              RouteConstants.about,
              RouteConstants.help,
              RouteConstants.gameJoin,
              RouteConstants.leaderboard,
            ];

            for (final route in routes) {
              AppRouter.go(route);
              await tester.pump();

              // Track analytics for additional load
              RouterAnalytics.trackNavigation(route);
            }

            // Periodically settle to check for errors
            if (cycle % 3 == 0) {
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          }

          await tester.pumpAndSettle();
          stopwatch.stop();

          // Should complete within reasonable time
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 30)),
            reason: 'Extended navigation should maintain performance',
          );

          // Should not have accumulated errors
          expect(tester.takeException(), isNull);
        },
      );
    });
  });
}
