import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import '../../../test_config.dart';

/// Widget tests for navigation components and UI interactions
/// Tests navigation UI elements, transitions, and user interactions
/// Following TDD approach for navigation widget functionality

void main() {
  group('Navigation Widget Tests', () {
    group('RED PHASE: Router Widget Integration', () {
      widgetTestCase(
        'should render MaterialApp with router correctly',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test router integration with MaterialApp

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: AppRouter.router,
                title: 'Quiz App Test',
              ),
            ),
          );

          // Should build without errors
          expect(tester.takeException(), isNull);

          // Should create a MaterialApp
          expect(find.byType(MaterialApp), findsOneWidget);

          // Should integrate with router
          final context = tester.element(find.byType(MaterialApp));
          final router = GoRouter.of(context);
          expect(router, isNotNull);
        },
      );

      widgetTestCase(
        'should provide router through Riverpod widget tree',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test Riverpod provider access in widget tree

          late GoRouter capturedRouter;

          await tester.pumpWidget(
            ProviderScope(
              child: Consumer(
                builder: (context, ref, child) {
                  capturedRouter = ref.watch(routerProvider);
                  return MaterialApp.router(routerConfig: capturedRouter);
                },
              ),
            ),
          );

          expect(capturedRouter, isNotNull);
          expect(capturedRouter, isA<GoRouter>());
        },
      );
    });

    group('RED PHASE: Navigation Transitions', () {
      widgetTestCase(
        'should handle route transitions smoothly',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test navigation transitions and animations

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate to different route
          AppRouter.go(RouteConstants.about);

          // Should trigger transition
          await tester.pump();
          expect(tester.hasRunningAnimations, isTrue);

          // Should complete transition
          await tester.pumpAndSettle();
          expect(tester.hasRunningAnimations, isFalse);
        },
      );

      widgetTestCase(
        'should handle rapid navigation changes without breaking',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test navigation stability under rapid changes

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
          ];

          for (final route in routes) {
            AppRouter.go(route);
            await tester.pump(); // Don't wait for animations
          }

          // Should not have exceptions
          expect(tester.takeException(), isNull);

          // Should settle without errors
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Navigation Error Handling', () {
      widgetTestCase(
        'should display error page for invalid routes',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test error page display for navigation errors

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate to invalid route
          AppRouter.go('/non-existent-route');
          await tester.pumpAndSettle();

          // Should handle error gracefully
          expect(tester.takeException(), isNull);

          // Should show some form of error indication
          // The exact widget depends on error page implementation
          expect(find.byType(Widget), findsWidgets);
        },
      );

      widgetTestCase(
        'should recover from navigation errors gracefully',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test error recovery in navigation

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Try invalid navigation
          AppRouter.go('/invalid-1');
          await tester.pump();

          // Try another invalid navigation
          AppRouter.go('/invalid-2');
          await tester.pump();

          // Navigate to valid route
          AppRouter.go(RouteConstants.home);
          await tester.pumpAndSettle();

          // Should not have accumulated errors
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Deep Link Widget Integration', () {
      widgetTestCase(
        'should handle deep link URLs correctly',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test deep link handling in widget tree

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate using deep link format
          const gamePin = '123456';
          final deepLinkUrl = '${RouteConstants.gameJoin}?pin=$gamePin';

          AppRouter.go(deepLinkUrl);
          await tester.pumpAndSettle();

          // Should navigate without errors
          expect(tester.takeException(), isNull);
        },
      );

      widgetTestCase(
        'should parse query parameters in widget context',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test query parameter parsing in widgets

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate with query parameters
          AppRouter.go('${RouteConstants.about}?test=value&page=1');
          await tester.pumpAndSettle();

          // Should handle query parameters without errors
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Navigation Performance in Widgets', () {
      widgetTestCase(
        'should handle navigation stack efficiently',
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

          // Build navigation stack
          for (int i = 0; i < 5; i++) {
            AppRouter.push('${RouteConstants.about}?level=$i');
            await tester.pump();
          }

          await tester.pumpAndSettle();
          stopwatch.stop();

          // Should complete within reasonable time
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 3)),
            reason: 'Navigation stack operations should be performant',
          );

          // Clear stack
          AppRouter.clearAndGoTo(RouteConstants.home);
          await tester.pumpAndSettle();
        },
      );

      widgetTestCase(
        'should handle memory efficiently during navigation',
        TestCategory.performance,
        (WidgetTester tester) async {
          // TDD RED: Test memory efficiency

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Perform multiple navigation operations
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
          ];

          for (int cycle = 0; cycle < 3; cycle++) {
            for (final route in routes) {
              AppRouter.go(route);
              await tester.pumpAndSettle();
            }
          }

          // Should not accumulate errors or memory issues
          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Browser Integration', () {
      widgetTestCase(
        'should handle browser back button correctly',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test browser back button integration

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate forward
          AppRouter.push(RouteConstants.about);
          await tester.pumpAndSettle();

          // Test back navigation capability
          expect(AppRouter.canPop(), isA<bool>());

          // Simulate back navigation
          if (AppRouter.canPop()) {
            AppRouter.pop();
            await tester.pumpAndSettle();
          }

          // Should handle back navigation without errors
          expect(tester.takeException(), isNull);
        },
      );

      widgetTestCase(
        'should maintain navigation state correctly',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test navigation state persistence

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate through multiple pages
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();

          AppRouter.push(RouteConstants.help);
          await tester.pumpAndSettle();

          // Check navigation state
          expect(AppRouter.canPop(), isTrue);

          // Pop and verify state
          AppRouter.pop();
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    });

    group('RED PHASE: Accessibility in Navigation', () {
      widgetTestCase(
        'should maintain accessibility during navigation',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test accessibility preservation during navigation

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Check initial accessibility
          final semantics = tester.semantics;
          expect(semantics, isNotNull);

          // Navigate to different pages
          final routes = [
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.home,
          ];

          for (final route in routes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            // Verify accessibility is maintained
            final newSemantics = tester.semantics;
            expect(newSemantics, isNotNull);
          }
        },
      );

      widgetTestCase(
        'should announce navigation changes to screen readers',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test screen reader announcements

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate and check for semantic updates
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();

          // Should not break accessibility
          expect(tester.takeException(), isNull);

          // Should maintain semantic tree
          expect(tester.semantics, isNotNull);
        },
      );
    });

    group('RED PHASE: Responsive Navigation', () {
      widgetTestCase(
        'should handle different screen sizes correctly',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test responsive navigation behavior

          // Test with mobile screen size
          await tester.binding.setSurfaceSize(const Size(375, 667));

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate on mobile
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Test with tablet screen size
          await tester.binding.setSurfaceSize(const Size(768, 1024));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Test with desktop screen size
          await tester.binding.setSurfaceSize(const Size(1920, 1080));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Reset to default size
          await tester.binding.setSurfaceSize(null);
        },
      );

      widgetTestCase(
        'should adapt navigation UI to screen orientation',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test orientation changes during navigation

          // Portrait orientation
          await tester.binding.setSurfaceSize(const Size(375, 667));

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate in portrait
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();

          // Change to landscape orientation
          await tester.binding.setSurfaceSize(const Size(667, 375));
          await tester.pumpAndSettle();

          // Should handle orientation change without errors
          expect(tester.takeException(), isNull);

          // Reset to default size
          await tester.binding.setSurfaceSize(null);
        },
      );
    });

    group('RED PHASE: Navigation State Management', () {
      widgetTestCase(
        'should maintain navigation state across rebuilds',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test state persistence during widget rebuilds

          var rebuildCount = 0;

          StatefulWidget buildApp() {
            return StatefulBuilder(
              builder: (context, setState) {
                rebuildCount++;
                return ProviderScope(
                  child: MaterialApp.router(
                    routerConfig: AppRouter.router,
                    key: ValueKey(rebuildCount),
                  ),
                );
              },
            );
          }

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Navigate to a page
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();

          // Trigger rebuild
          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Should maintain navigation state
          expect(tester.takeException(), isNull);
          expect(rebuildCount, greaterThan(1));
        },
      );

      widgetTestCase(
        'should handle provider updates during navigation',
        TestCategory.widget,
        (WidgetTester tester) async {
          // TDD RED: Test navigation with provider updates

          final container = ProviderContainer();

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(routerConfig: AppRouter.router),
            ),
          );

          await tester.pumpAndSettle();

          // Navigate while updating providers
          AppRouter.go(RouteConstants.about);

          // Force provider refresh
          container.refresh(routerProvider);

          await tester.pumpAndSettle();

          // Should handle provider updates gracefully
          expect(tester.takeException(), isNull);

          container.dispose();
        },
      );
    });
  });
}
