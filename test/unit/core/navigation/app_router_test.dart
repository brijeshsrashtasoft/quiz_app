import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/navigation_utils.dart';
import '../../../test_config.dart';
import '../../../helpers/test_utilities.dart';

/// Unit tests for AppRouter configuration and functionality
/// Following TDD approach: Write tests first, then verify implementation
void main() {
  testGroup('AppRouter Configuration', TestCategory.unit, () {
    late GoRouter router;

    setUp(() {
      router = AppRouter.router;
    });

    testCase(
      'should initialize with correct configuration',
      TestCategory.unit,
      () {
        // ARRANGE & ACT
        final router = AppRouter.router;

        // ASSERT
        expect(router, isNotNull);
        expect(router.routerDelegate, isNotNull);
        expect(router.routeInformationParser, isNotNull);
        expect(router.routeInformationProvider, isNotNull);
      },
    );

    testCase('should have correct initial location', TestCategory.unit, () {
      // ARRANGE & ACT
      final initialLocation = router.routeInformationProvider.value.uri.path;

      // ASSERT
      expect(initialLocation, equals(RouteConstants.splash));
    });

    testCase('should provide router through provider', TestCategory.unit, () {
      // ARRANGE
      final container = ProviderContainer();

      // ACT
      final routerFromProvider = container.read(routerProvider);

      // ASSERT
      expect(routerFromProvider, isNotNull);
      expect(routerFromProvider, isA<GoRouter>());
      expect(routerFromProvider, equals(AppRouter.router));

      container.dispose();
    });

    testCase(
      'should provide current route through provider',
      TestCategory.unit,
      () {
        // ARRANGE
        final container = ProviderContainer();

        // ACT
        final currentRoute = container.read(currentRouteProvider);

        // ASSERT
        expect(currentRoute, isA<String?>());

        container.dispose();
      },
    );
  });

  testGroup('Route Navigation Methods', TestCategory.unit, () {
    testCase('should navigate using go method', TestCategory.unit, () {
      // ARRANGE
      const testRoute = RouteConstants.home;

      // ACT & ASSERT
      expect(() => AppRouter.go(testRoute), returnsNormally);
    });

    testCase('should navigate using push method', TestCategory.unit, () {
      // ARRANGE
      const testRoute = RouteConstants.login;

      // ACT & ASSERT
      expect(() => AppRouter.push(testRoute), returnsNormally);
    });

    testCase('should handle pop operation', TestCategory.unit, () {
      // ACT & ASSERT
      expect(() => AppRouter.canPop(), returnsNormally);
      expect(AppRouter.canPop(), isA<bool>());
    });

    testCase(
      'should clear navigation stack and go to route',
      TestCategory.unit,
      () {
        // ARRANGE
        const testRoute = RouteConstants.home;

        // ACT & ASSERT
        expect(() => AppRouter.clearAndGoTo(testRoute), returnsNormally);
      },
    );
  });

  testGroup('Route Validation', TestCategory.unit, () {
    testCase('should validate quiz IDs correctly', TestCategory.unit, () {
      // Valid quiz IDs
      expect(NavigationUtils.isValidQuizId('quiz123456'), isTrue);
      expect(NavigationUtils.isValidQuizId('long-quiz-id-123'), isTrue);

      // Invalid quiz IDs
      expect(NavigationUtils.isValidQuizId(null), isFalse);
      expect(NavigationUtils.isValidQuizId(''), isFalse);
      expect(NavigationUtils.isValidQuizId('short'), isFalse);
    });

    testCase('should validate session IDs correctly', TestCategory.unit, () {
      // Valid session IDs
      expect(NavigationUtils.isValidSessionId('session123456'), isTrue);
      expect(NavigationUtils.isValidSessionId('long-session-id'), isTrue);

      // Invalid session IDs
      expect(NavigationUtils.isValidSessionId(null), isFalse);
      expect(NavigationUtils.isValidSessionId(''), isFalse);
      expect(NavigationUtils.isValidSessionId('short'), isFalse);
    });

    testCase(
      'should validate question indices correctly',
      TestCategory.unit,
      () {
        // Valid indices
        expect(NavigationUtils.isValidQuestionIndex(0), isTrue);
        expect(NavigationUtils.isValidQuestionIndex(5), isTrue);
        expect(NavigationUtils.isValidQuestionIndex(100), isTrue);

        // Invalid indices
        expect(NavigationUtils.isValidQuestionIndex(null), isFalse);
        expect(NavigationUtils.isValidQuestionIndex(-1), isFalse);
        expect(NavigationUtils.isValidQuestionIndex(-100), isFalse);
      },
    );
  });

  testGroup('Deep Link Handling', TestCategory.unit, () {
    testCase(
      'should extract game PIN from URL correctly',
      TestCategory.unit,
      () {
        // Valid URLs with PIN in query
        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/join?pin=123456',
          ),
          equals('123456'),
        );

        // Valid URLs with PIN in path
        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/123456',
          ),
          equals('123456'),
        );

        // Invalid URLs
        expect(NavigationUtils.extractGamePinFromUrl('invalid-url'), isNull);
        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/join?pin=12345',
          ),
          isNull,
        ); // PIN too short
      },
    );

    testCase('should generate shareable URLs correctly', TestCategory.unit, () {
      // Quiz share URL
      final quizUrl = NavigationUtils.generateQuizShareUrl('quiz123');
      expect(quizUrl, contains('/quiz/quiz123'));
      expect(quizUrl, startsWith('https://'));

      // Game join URL
      final gameUrl = NavigationUtils.generateGameJoinUrl('123456');
      expect(gameUrl, contains('/game/join?pin=123456'));
      expect(gameUrl, startsWith('https://'));

      // Leaderboard share URL
      final leaderboardUrl = NavigationUtils.generateLeaderboardShareUrl(
        'session123',
      );
      expect(leaderboardUrl, contains('/leaderboard/session/session123'));
      expect(leaderboardUrl, startsWith('https://'));
    });
  });

  testGroup('Route Classification', TestCategory.unit, () {
    testCase('should identify auth routes correctly', TestCategory.unit, () {
      expect(NavigationUtils.isAuthRoute(RouteConstants.login), isTrue);
      expect(NavigationUtils.isAuthRoute(RouteConstants.register), isTrue);
      expect(
        NavigationUtils.isAuthRoute(RouteConstants.forgotPassword),
        isTrue,
      );

      expect(NavigationUtils.isAuthRoute(RouteConstants.home), isFalse);
      expect(NavigationUtils.isAuthRoute(RouteConstants.dashboard), isFalse);
    });

    testCase('should identify game routes correctly', TestCategory.unit, () {
      expect(NavigationUtils.isGameRoute('/game/join'), isTrue);
      expect(NavigationUtils.isGameRoute('/game/session123'), isTrue);
      expect(NavigationUtils.isGameRoute('/game/session123/waiting'), isTrue);

      expect(NavigationUtils.isGameRoute(RouteConstants.home), isFalse);
      expect(NavigationUtils.isGameRoute(RouteConstants.quiz), isFalse);
    });

    testCase('should identify quiz routes correctly', TestCategory.unit, () {
      expect(NavigationUtils.isQuizRoute('/quiz/123'), isTrue);
      expect(NavigationUtils.isQuizRoute('/quiz-creation'), isTrue);
      expect(NavigationUtils.isQuizRoute('/quiz-creation/form'), isTrue);

      expect(NavigationUtils.isQuizRoute(RouteConstants.home), isFalse);
      expect(NavigationUtils.isQuizRoute('/game/join'), isFalse);
    });
  });

  testGroup('AppRouterHelper Functionality', TestCategory.unit, () {
    testCase('should handle deep link navigation', TestCategory.unit, () async {
      // Valid deep link with game PIN
      final result1 = await AppRouterHelper.handleGameJoinDeepLink(
        'https://example.com/game/join?pin=123456',
      );
      expect(result1, isTrue);

      // Invalid deep link
      final result2 = await AppRouterHelper.handleGameJoinDeepLink(
        'https://example.com/invalid',
      );
      expect(result2, isFalse);
    });

    testCase('should generate share links correctly', TestCategory.unit, () {
      final quizLink = AppRouterHelper.generateQuizShareLink('quiz123');
      expect(quizLink, contains('quiz123'));

      final gameLink = AppRouterHelper.generateGameJoinLink('123456');
      expect(gameLink, contains('123456'));
    });

    testCase('should provide navigation context', TestCategory.unit, () {
      final context = AppRouterHelper.getCurrentContext();
      expect(context, isA<NavigationContext>());
      expect(context.route, isA<String>());
      expect(context.isGameRoute, isA<bool>());
      expect(context.isAuthRoute, isA<bool>());
      expect(context.isQuizRoute, isA<bool>());
      expect(context.breadcrumbs, isA<List<String>>());
    });
  });

  testGroup('Router Analytics', TestCategory.unit, () {
    setUp(() {
      RouterAnalytics.clearAnalytics();
    });

    testCase('should track navigation events', TestCategory.unit, () {
      // ARRANGE
      const testRoute = '/test-route';

      // ACT
      RouterAnalytics.trackNavigation(testRoute);

      // ASSERT
      final history = RouterAnalytics.navigationHistory;
      expect(history, contains(testRoute));
      expect(RouterAnalytics.routeVisitCounts[testRoute], equals(1));
    });

    testCase('should limit navigation history size', TestCategory.unit, () {
      // ARRANGE & ACT - Add more than 50 routes
      for (int i = 0; i < 60; i++) {
        RouterAnalytics.trackNavigation('/route-$i');
      }

      // ASSERT
      final history = RouterAnalytics.navigationHistory;
      expect(history.length, equals(50));
      expect(history.first, equals('/route-10')); // First 10 removed
      expect(history.last, equals('/route-59'));
    });

    testCase('should track route visit counts', TestCategory.unit, () {
      // ARRANGE
      const testRoute = '/popular-route';

      // ACT
      for (int i = 0; i < 5; i++) {
        RouterAnalytics.trackNavigation(testRoute);
      }

      // ASSERT
      expect(RouterAnalytics.routeVisitCounts[testRoute], equals(5));
    });

    testCase('should clear analytics data', TestCategory.unit, () {
      // ARRANGE
      RouterAnalytics.trackNavigation('/test-route');
      expect(RouterAnalytics.navigationHistory, isNotEmpty);

      // ACT
      RouterAnalytics.clearAnalytics();

      // ASSERT
      expect(RouterAnalytics.navigationHistory, isEmpty);
      expect(RouterAnalytics.routeVisitCounts, isEmpty);
      expect(RouterAnalytics.recentlyVisited, isEmpty);
    });
  });

  testGroup('Error Handling', TestCategory.unit, () {
    testCase(
      'should handle navigation errors gracefully',
      TestCategory.unit,
      () {
        // Test safe navigation methods don't throw
        expect(
          () => AppRouterHelper.safeNavigateTo('/non-existent-route'),
          returnsNormally,
        );
      },
    );

    testCase('should provide error recovery', TestCategory.unit, () {
      // Error recovery should not throw
      expect(
        () => NavigationUtils.recoverFromNavigationError(MockBuildContext()),
        returnsNormally,
      );
    });
  });
}

/// Mock BuildContext for testing
class MockBuildContext extends Mock implements BuildContext {}
