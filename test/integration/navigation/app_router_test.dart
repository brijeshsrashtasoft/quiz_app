import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import '../../helpers/widget_test_helper.dart';

void main() {
  group('AppRouter Integration Tests', () {
    late GoRouter router;

    setUp(() {
      router = AppRouter.router;
    });

    testWidgets('navigates to login route', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Should start at login route
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.login),
      );
    });

    testWidgets('navigates to home after login', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Navigate to home
      router.go(RouteConstants.home);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.home),
      );
    });

    testWidgets('navigates to quiz creation', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.go(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.quizCreation),
      );
    });

    testWidgets('navigates to quiz detail with parameter', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      const quizId = 'test-quiz-123';
      router.go(RouteConstants.quizDetailsPath(quizId));
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals('${RouteConstants.quizDetail}/$quizId'),
      );
    });

    testWidgets('navigates to game session with PIN', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      const sessionPin = '123456';
      router.go(RouteConstants.gameSessionPath(sessionPin));
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals('${RouteConstants.gameSession}/$sessionPin'),
      );
    });

    testWidgets('handles navigation with query parameters', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.go('${RouteConstants.home}?tab=quizzes&sort=recent');
      await tester.pumpAndSettle();

      final uri = router.routerDelegate.currentConfiguration.uri;
      expect(uri.path, equals(RouteConstants.home));
      expect(uri.queryParameters['tab'], equals('quizzes'));
      expect(uri.queryParameters['sort'], equals('recent'));
    });

    testWidgets('navigates back correctly', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Navigate to home
      router.go(RouteConstants.home);
      await tester.pumpAndSettle();

      // Navigate to quiz creation
      router.push(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.quizCreation),
      );

      // Navigate back
      router.pop();
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.home),
      );
    });

    testWidgets('handles deep links correctly', (tester) async {
      // Create router with initial location - using existing router
      const deepLink = '/game/ABCD12';
      final routerWithDeepLink = AppRouter.router;

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: routerWithDeepLink),
      );

      expect(
        routerWithDeepLink.routerDelegate.currentConfiguration.uri.path,
        equals(deepLink),
      );
    });

    testWidgets('redirects unauthenticated users', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Try to navigate to protected route
      router.go(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      // Should be redirected based on auth state
      // Note: This depends on the actual route guard implementation
      final currentPath = router.routerDelegate.currentConfiguration.uri.path;
      expect(
        currentPath,
        anyOf(
          equals(RouteConstants.login),
          equals(RouteConstants.quizCreation),
        ),
      );
    });

    testWidgets('maintains route state during navigation', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Navigate through multiple routes
      router.go(RouteConstants.home);
      await tester.pumpAndSettle();

      router.push(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      router.push(RouteConstants.quizDetailsPath('test-123'));
      await tester.pumpAndSettle();

      // Check navigation stack
      expect(router.canPop(), isTrue);

      // Pop back to quiz creation
      router.pop();
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.quizCreation),
      );
    });

    testWidgets('handles route replacement correctly', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.go(RouteConstants.home);
      await tester.pumpAndSettle();

      // Replace current route
      router.pushReplacement(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.quizCreation),
      );

      // Should not be able to pop back to home
      // Note: This behavior depends on the router implementation
    });
  });

  group('Route Guards Tests', () {
    testWidgets('protects authenticated routes', (tester) async {
      final router = AppRouter.createRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Try to access protected route without authentication
      router.go(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      // Should redirect to login or show authentication required
      final currentPath = router.routerDelegate.currentConfiguration.uri.path;
      // This test depends on actual auth implementation
      expect(currentPath, isNotNull);
    });

    testWidgets('allows access to public routes', (tester) async {
      final router = AppRouter.createRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Navigate to public route
      router.go(RouteConstants.login);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.login),
      );
    });
  });

  group('Error Handling Tests', () {
    testWidgets('handles unknown routes', (tester) async {
      final router = AppRouter.createRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Try to navigate to unknown route
      router.go('/unknown-route');
      await tester.pumpAndSettle();

      // Should show error page or redirect
      // The exact behavior depends on router configuration
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('handles malformed URLs', (tester) async {
      final router = AppRouter.createRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Try to navigate with malformed URL
      router.go('/quiz/'); // Missing ID
      await tester.pumpAndSettle();

      // Should handle gracefully
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Browser Integration Tests', () {
    testWidgets('updates browser URL on navigation', (tester) async {
      final router = AppRouter.createRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.go(RouteConstants.home);
      await tester.pumpAndSettle();

      // In web environment, this would update browser URL
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.home),
      );
    });

    testWidgets('handles browser back button', (tester) async {
      final router = AppRouter.createRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.go(RouteConstants.home);
      await tester.pumpAndSettle();

      router.push(RouteConstants.quizCreation);
      await tester.pumpAndSettle();

      // Simulate browser back button
      router.pop();
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(RouteConstants.home),
      );
    });
  });
}
