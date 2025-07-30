import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/navigation/navigation.dart';

void main() {
  group('AppRouter', () {
    testWidgets('should initialize with splash route', (tester) async {
      final router = AppRouter.router;

      expect(router.routerDelegate.currentConfiguration.isNotEmpty, true);
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        RouteConstants.splash,
      );
    });

    testWidgets('should navigate to home route', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );

      // Start at splash
      expect(find.text('Quiz App'), findsOneWidget);

      // Navigate to home
      AppRouter.go(RouteConstants.home);
      await tester.pumpAndSettle();

      expect(find.text('Quiz App Home'), findsOneWidget);
    });

    testWidgets('should navigate to login route', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );

      AppRouter.go(RouteConstants.login);
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should handle invalid quiz ID parameter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );

      AppRouter.go('/quiz/invalid');
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Invalid quiz ID'), findsOneWidget);
    });

    testWidgets('should handle valid quiz ID parameter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );

      AppRouter.go('/quiz/123456');
      await tester.pumpAndSettle();

      expect(find.text('Quiz Details'), findsOneWidget);
      expect(find.text('Quiz ID: 123456'), findsOneWidget);
    });

    testWidgets('should handle invalid session ID parameter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );

      AppRouter.go('/game/123');
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Invalid game session ID'), findsOneWidget);
    });

    testWidgets('should handle valid session ID parameter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: AppRouter.router),
        ),
      );

      AppRouter.go('/game/123456');
      await tester.pumpAndSettle();

      expect(find.text('Game Session'), findsOneWidget);
      expect(find.text('Session: 123456'), findsOneWidget);
    });

    test('should get current route', () {
      final router = AppRouter.router;
      expect(AppRouter.currentRoute, isNotNull);
    });

    test('should check if current route matches', () {
      AppRouter.go(RouteConstants.home);
      expect(AppRouter.isCurrentRoute(RouteConstants.home), true);
      expect(AppRouter.isCurrentRoute(RouteConstants.login), false);
    });
  });

  group('AuthGuardRegistry', () {
    test('should return guards for protected routes', () {
      final guards = AuthGuardRegistry.getGuards(RouteConstants.profile);
      expect(guards.isNotEmpty, true);
      expect(guards.first, isA<AuthGuard>());
    });

    test('should return guest guards for auth routes', () {
      final guards = AuthGuardRegistry.getGuards(RouteConstants.login);
      expect(guards.isNotEmpty, true);
      expect(guards.first, isA<GuestGuard>());
    });

    test('should return empty guards for public routes', () {
      final guards = AuthGuardRegistry.getGuards(RouteConstants.home);
      expect(guards.isEmpty, true);
    });

    test('should check if route is protected', () {
      expect(AuthGuardRegistry.isProtected(RouteConstants.profile), true);
      expect(AuthGuardRegistry.isProtected(RouteConstants.home), false);
    });

    test('should get guard types for debugging', () {
      final guardTypes = AuthGuardRegistry.getGuardTypes(
        RouteConstants.profile,
      );
      expect(guardTypes.contains('AuthGuard'), true);
    });
  });

  group('AppRouterHelper', () {
    test('should generate quiz share link', () {
      final link = AppRouterHelper.generateQuizShareLink('123456');
      expect(link.contains('/quiz/123456'), true);
    });

    test('should generate game join link', () {
      final link = AppRouterHelper.generateGameJoinLink('123456');
      expect(link.contains('/game/join'), true);
      expect(link.contains('pin=123456'), true);
    });

    test('should get current navigation context', () {
      AppRouter.go(RouteConstants.home);
      final context = AppRouterHelper.getCurrentContext();

      expect(context.route, RouteConstants.home);
      expect(context.isGameRoute, false);
      expect(context.isAuthRoute, false);
      expect(context.isQuizRoute, false);
    });

    test('should identify game route context', () {
      AppRouter.go('/game/123456');
      final context = AppRouterHelper.getCurrentContext();

      expect(context.isGameRoute, true);
      expect(context.isAuthRoute, false);
      expect(context.isQuizRoute, false);
    });
  });

  group('RouterAnalytics', () {
    setUp(() {
      RouterAnalytics.clearAnalytics();
    });

    test('should track navigation events', () {
      RouterAnalytics.trackNavigation(RouteConstants.home);
      RouterAnalytics.trackNavigation(RouteConstants.login);

      final history = RouterAnalytics.navigationHistory;
      expect(history.length, 2);
      expect(history.contains(RouteConstants.home), true);
      expect(history.contains(RouteConstants.login), true);
    });

    test('should count route visits', () {
      RouterAnalytics.trackNavigation(RouteConstants.home);
      RouterAnalytics.trackNavigation(RouteConstants.home);
      RouterAnalytics.trackNavigation(RouteConstants.login);

      final visitCounts = RouterAnalytics.routeVisitCounts;
      expect(visitCounts[RouteConstants.home], 2);
      expect(visitCounts[RouteConstants.login], 1);
    });

    test('should track recently visited routes', () {
      RouterAnalytics.trackNavigation(RouteConstants.home);

      final recentlyVisited = RouterAnalytics.recentlyVisited;
      expect(recentlyVisited.containsKey(RouteConstants.home), true);
      expect(recentlyVisited[RouteConstants.home], isA<DateTime>());
    });

    test('should limit navigation history to 50 entries', () {
      // Add more than 50 entries
      for (int i = 0; i < 60; i++) {
        RouterAnalytics.trackNavigation('/test/$i');
      }

      final history = RouterAnalytics.navigationHistory;
      expect(history.length, 50);
      expect(history.first, '/test/10'); // First 10 should be removed
    });

    test('should clear analytics data', () {
      RouterAnalytics.trackNavigation(RouteConstants.home);
      RouterAnalytics.clearAnalytics();

      expect(RouterAnalytics.navigationHistory.isEmpty, true);
      expect(RouterAnalytics.routeVisitCounts.isEmpty, true);
      expect(RouterAnalytics.recentlyVisited.isEmpty, true);
    });
  });

  group('CustomPageTransition', () {
    test('should have transition methods available', () {
      // Test that the transition methods exist and are callable
      expect(CustomPageTransition.slideTransition, isA<Function>());
      expect(CustomPageTransition.fadeTransition, isA<Function>());
      expect(CustomPageTransition.scaleTransition, isA<Function>());
      expect(CustomPageTransition.rotationTransition, isA<Function>());
      expect(CustomPageTransition.getContextualTransition, isA<Function>());
    });
  });
}
