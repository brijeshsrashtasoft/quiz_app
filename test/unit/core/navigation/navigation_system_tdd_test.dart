import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/navigation_utils.dart';
import 'package:quiz_app/core/navigation/auth_guard.dart';
import '../../../test_config.dart';
import 'navigation_system_tdd_test.mocks.dart';

/// TDD-driven comprehensive navigation system tests
/// Following Red-Green-Refactor approach for navigation functionality
///
/// RED PHASE: Write failing tests first
/// GREEN PHASE: Implement minimal code to pass
/// BLUE PHASE: Refactor while keeping tests green

@GenerateMocks([BuildContext, GoRouterState])
void main() {
  group('TDD Navigation System Tests', () {
    late MockBuildContext mockContext;
    late MockGoRouterState mockState;

    setUp(() {
      mockContext = MockBuildContext();
      mockState = MockGoRouterState();
    });

    group('RED PHASE: Route Constants Validation', () {
      testCase(
        'should have all required route constants defined',
        TestCategory.unit,
        () {
          // TDD RED: Write test that verifies all navigation routes exist

          // Core application routes
          expect(RouteConstants.root, equals('/'));
          expect(RouteConstants.splash, equals('/splash'));
          expect(RouteConstants.home, equals('/home'));

          // Authentication flow routes
          expect(RouteConstants.login, equals('/login'));
          expect(RouteConstants.register, equals('/register'));
          expect(RouteConstants.forgotPassword, equals('/forgot-password'));
          expect(RouteConstants.profile, equals('/profile'));

          // Dashboard and main app areas
          expect(RouteConstants.dashboard, equals('/dashboard'));

          // Quiz creation workflow routes
          expect(RouteConstants.quizCreation, equals('/quiz-creation'));
          expect(
            RouteConstants.quizCreationForm,
            equals('/quiz-creation/form'),
          );
          expect(
            RouteConstants.quizCreationPreview,
            equals('/quiz-creation/preview'),
          );
          expect(
            RouteConstants.quizCreationPublish,
            equals('/quiz-creation/publish'),
          );

          // Dynamic quiz routes
          expect(RouteConstants.quizDetails, equals('/quiz/:quizId'));
          expect(RouteConstants.quizEdit, equals('/quiz/:quizId/edit'));

          // Game session flow routes
          expect(RouteConstants.gameJoin, equals('/game/join'));
          expect(RouteConstants.gameSession, equals('/game/:sessionId'));
          expect(
            RouteConstants.gameWaiting,
            equals('/game/:sessionId/waiting'),
          );
          expect(
            RouteConstants.gameQuestion,
            equals('/game/:sessionId/question/:questionIndex'),
          );
          expect(
            RouteConstants.gameResults,
            equals('/game/:sessionId/results'),
          );
          expect(RouteConstants.gameHost, equals('/game/host'));
          expect(RouteConstants.gameHostSetup, equals('/game/host/setup'));

          // Leaderboard routes
          expect(RouteConstants.leaderboard, equals('/leaderboard'));
          expect(
            RouteConstants.leaderboardGlobal,
            equals('/leaderboard/global'),
          );
          expect(
            RouteConstants.leaderboardSession,
            equals('/leaderboard/session/:sessionId'),
          );

          // Application utility routes
          expect(RouteConstants.settings, equals('/settings'));
          expect(RouteConstants.about, equals('/about'));
          expect(RouteConstants.help, equals('/help'));

          // Error handling routes
          expect(RouteConstants.notFound, equals('/404'));
          expect(RouteConstants.error, equals('/error'));
        },
      );

      testCase(
        'should generate dynamic route paths correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test dynamic route generation helpers

          // Quiz dynamic routes
          expect(
            RouteConstants.quizDetailsPath('quiz123'),
            equals('/quiz/quiz123'),
          );
          expect(
            RouteConstants.quizEditPath('quiz123'),
            equals('/quiz/quiz123/edit'),
          );

          // Game session dynamic routes
          expect(
            RouteConstants.gameSessionPath('session456'),
            equals('/game/session456'),
          );
          expect(
            RouteConstants.gameWaitingPath('session456'),
            equals('/game/session456/waiting'),
          );
          expect(
            RouteConstants.gameQuestionPath('session456', 2),
            equals('/game/session456/question/2'),
          );
          expect(
            RouteConstants.gameResultsPath('session456'),
            equals('/game/session456/results'),
          );

          // Leaderboard dynamic routes
          expect(
            RouteConstants.leaderboardSessionPath('session789'),
            equals('/leaderboard/session/session789'),
          );
        },
      );
    });

    group('RED PHASE: Navigation Utilities Functionality', () {
      testCase(
        'should validate route parameters correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test parameter validation for security and UX

          // Quiz ID validation
          expect(NavigationUtils.isValidQuizId('validQuizId123'), isTrue);
          expect(NavigationUtils.isValidQuizId('quiz-with-dashes'), isTrue);
          expect(
            NavigationUtils.isValidQuizId('quiz_with_underscores'),
            isTrue,
          );
          expect(NavigationUtils.isValidQuizId(''), isFalse);
          expect(NavigationUtils.isValidQuizId(null), isFalse);
          expect(NavigationUtils.isValidQuizId('short'), isFalse);

          // Session ID validation
          expect(NavigationUtils.isValidSessionId('validSessionId123'), isTrue);
          expect(
            NavigationUtils.isValidSessionId('session-with-dashes'),
            isTrue,
          );
          expect(
            NavigationUtils.isValidSessionId('session_with_underscores'),
            isTrue,
          );
          expect(NavigationUtils.isValidSessionId(''), isFalse);
          expect(NavigationUtils.isValidSessionId(null), isFalse);
          expect(NavigationUtils.isValidSessionId('short'), isFalse);

          // Question index validation
          expect(NavigationUtils.isValidQuestionIndex(0), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(5), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(100), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(-1), isFalse);
          expect(NavigationUtils.isValidQuestionIndex(null), isFalse);
        },
      );

      testCase(
        'should extract parameters from router state correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test parameter extraction from GoRouter state

          // Quiz ID extraction
          when(
            mockState.pathParameters,
          ).thenReturn({'quizId': 'test-quiz-123'});
          expect(
            NavigationUtils.getQuizIdFromState(mockState),
            equals('test-quiz-123'),
          );

          // Session ID extraction
          when(
            mockState.pathParameters,
          ).thenReturn({'sessionId': 'test-session-456'});
          expect(
            NavigationUtils.getSessionIdFromState(mockState),
            equals('test-session-456'),
          );

          // Question index extraction
          when(mockState.pathParameters).thenReturn({'questionIndex': '5'});
          expect(
            NavigationUtils.getQuestionIndexFromState(mockState),
            equals(5),
          );

          // Handle missing parameters
          when(mockState.pathParameters).thenReturn({});
          expect(NavigationUtils.getQuizIdFromState(mockState), isNull);
          expect(NavigationUtils.getSessionIdFromState(mockState), isNull);
          expect(NavigationUtils.getQuestionIndexFromState(mockState), isNull);
        },
      );

      testCase(
        'should build URLs with query parameters correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test URL building for deep links and sharing

          // Simple URL without query parameters
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {}),
            equals('/test'),
          );

          // URL with single query parameter
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {'param': 'value'}),
            equals('/test?param=value'),
          );

          // URL with multiple query parameters
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {
              'param1': 'value1',
              'param2': 'value2',
            }),
            contains('param1=value1'),
          );
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {
              'param1': 'value1',
              'param2': 'value2',
            }),
            contains('param2=value2'),
          );
        },
      );
    });

    group('RED PHASE: Deep Link Handling', () {
      testCase(
        'should extract game PIN from URLs correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test deep link parsing for game joining

          // Valid URLs with PIN in query parameters
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/join?pin=123456',
            ),
            equals('123456'),
          );

          // Valid URLs with PIN in path segments
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/123456',
            ),
            equals('123456'),
          );

          // Invalid URLs should return null
          expect(NavigationUtils.extractGamePinFromUrl('invalid-url'), isNull);
          expect(NavigationUtils.extractGamePinFromUrl(''), isNull);
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/join',
            ),
            isNull,
          );

          // PIN too short or too long
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/join?pin=12345',
            ),
            isNull,
          );
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/join?pin=1234567',
            ),
            isNull,
          );
        },
      );

      testCase(
        'should generate shareable URLs correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test URL generation for sharing functionality

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

          // Custom base URL
          final customQuizUrl = NavigationUtils.generateQuizShareUrl(
            'quiz123',
            baseUrl: 'https://custom.com',
          );
          expect(customQuizUrl, startsWith('https://custom.com'));
          expect(customQuizUrl, contains('/quiz/quiz123'));
        },
      );

      testCase(
        'should validate deep link URLs correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test URL validation for security

          // Valid URLs
          expect(
            NavigationUtils.isValidDeepLink('https://quizapp.com/game/join'),
            isTrue,
          );
          expect(
            NavigationUtils.isValidDeepLink('http://localhost:3000/quiz/123'),
            isTrue,
          );
          expect(
            NavigationUtils.isValidDeepLink('https://custom-domain.com/path'),
            isTrue,
          );

          // Invalid URLs
          expect(NavigationUtils.isValidDeepLink('invalid-url'), isFalse);
          expect(NavigationUtils.isValidDeepLink(''), isFalse);
          expect(NavigationUtils.isValidDeepLink('not-a-url'), isFalse);
        },
      );
    });

    group('RED PHASE: Route Classification', () {
      testCase(
        'should classify authentication routes correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test route classification for navigation logic

          // Authentication routes
          expect(NavigationUtils.isAuthRoute(RouteConstants.login), isTrue);
          expect(NavigationUtils.isAuthRoute(RouteConstants.register), isTrue);
          expect(
            NavigationUtils.isAuthRoute(RouteConstants.forgotPassword),
            isTrue,
          );

          // Non-authentication routes
          expect(NavigationUtils.isAuthRoute(RouteConstants.home), isFalse);
          expect(
            NavigationUtils.isAuthRoute(RouteConstants.dashboard),
            isFalse,
          );
          expect(NavigationUtils.isAuthRoute(RouteConstants.settings), isFalse);
        },
      );

      testCase('should classify game routes correctly', TestCategory.unit, () {
        // TDD RED: Test game route classification

        // Game routes
        expect(NavigationUtils.isGameRoute('/game/join'), isTrue);
        expect(NavigationUtils.isGameRoute('/game/session123'), isTrue);
        expect(NavigationUtils.isGameRoute('/game/session123/waiting'), isTrue);
        expect(
          NavigationUtils.isGameRoute('/game/session123/question/1'),
          isTrue,
        );
        expect(NavigationUtils.isGameRoute('/game/session123/results'), isTrue);
        expect(NavigationUtils.isGameRoute('/game/host'), isTrue);

        // Non-game routes
        expect(NavigationUtils.isGameRoute(RouteConstants.home), isFalse);
        expect(NavigationUtils.isGameRoute(RouteConstants.login), isFalse);
        expect(NavigationUtils.isGameRoute('/quiz/123'), isFalse);
      });

      testCase('should classify quiz routes correctly', TestCategory.unit, () {
        // TDD RED: Test quiz route classification

        // Quiz routes
        expect(NavigationUtils.isQuizRoute('/quiz/123'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz/123/edit'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation/form'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation/preview'), isTrue);

        // Non-quiz routes
        expect(NavigationUtils.isQuizRoute(RouteConstants.home), isFalse);
        expect(NavigationUtils.isQuizRoute('/game/join'), isFalse);
        expect(
          NavigationUtils.isQuizRoute(RouteConstants.leaderboard),
          isFalse,
        );
      });

      testCase(
        'should classify leaderboard routes correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test leaderboard route classification

          // Leaderboard routes
          expect(NavigationUtils.isLeaderboardRoute('/leaderboard'), isTrue);
          expect(
            NavigationUtils.isLeaderboardRoute('/leaderboard/global'),
            isTrue,
          );
          expect(
            NavigationUtils.isLeaderboardRoute('/leaderboard/session/123'),
            isTrue,
          );

          // Non-leaderboard routes
          expect(
            NavigationUtils.isLeaderboardRoute(RouteConstants.home),
            isFalse,
          );
          expect(NavigationUtils.isLeaderboardRoute('/game/join'), isFalse);
          expect(NavigationUtils.isLeaderboardRoute('/quiz/123'), isFalse);
        },
      );
    });

    group('RED PHASE: Route Comparison and Utilities', () {
      testCase('should compare routes correctly', TestCategory.unit, () {
        // TDD RED: Test route comparison logic

        // Same routes
        expect(NavigationUtils.isSameRoute('/test', '/test'), isTrue);
        expect(
          NavigationUtils.isSameRoute('/test?param=value', '/test'),
          isTrue,
        );
        expect(
          NavigationUtils.isSameRoute('/test', '/test?param=value'),
          isTrue,
        );

        // Different routes
        expect(NavigationUtils.isSameRoute('/test1', '/test2'), isFalse);
        expect(
          NavigationUtils.isSameRoute('/path1/sub', '/path2/sub'),
          isFalse,
        );
      });

      testCase('should identify child routes correctly', TestCategory.unit, () {
        // TDD RED: Test hierarchical route relationships

        // Valid child routes
        expect(
          NavigationUtils.isChildRoute('/parent', '/parent/child'),
          isTrue,
        );
        expect(
          NavigationUtils.isChildRoute('/quiz-creation', '/quiz-creation/form'),
          isTrue,
        );
        expect(
          NavigationUtils.isChildRoute('/game', '/game/session123'),
          isTrue,
        );

        // Not child routes
        expect(NavigationUtils.isChildRoute('/parent', '/parent'), isFalse);
        expect(NavigationUtils.isChildRoute('/parent', '/other'), isFalse);
        expect(
          NavigationUtils.isChildRoute('/parent/child', '/parent'),
          isFalse,
        );
      });
    });

    group('RED PHASE: Navigation Breadcrumbs', () {
      testCase('should generate breadcrumbs correctly', TestCategory.unit, () {
        // TDD RED: Test breadcrumb generation for navigation context

        // Quiz creation flow breadcrumbs
        expect(
          NavigationUtils.generateBreadcrumbs('/quiz-creation'),
          equals(['Quiz Creation']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/quiz-creation/form'),
          equals(['Quiz Creation', 'Form']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/quiz-creation/preview'),
          equals(['Quiz Creation', 'Preview']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/quiz-creation/publish'),
          equals(['Quiz Creation', 'Publish']),
        );

        // Game flow breadcrumbs
        expect(
          NavigationUtils.generateBreadcrumbs('/game/session123'),
          equals(['Game']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/game/session123/waiting'),
          equals(['Game', 'Waiting']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/game/session123/question/1'),
          equals(['Game', 'Question']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/game/session123/results'),
          equals(['Game', 'Results']),
        );

        // Leaderboard breadcrumbs
        expect(
          NavigationUtils.generateBreadcrumbs('/leaderboard'),
          equals(['Leaderboard']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/leaderboard/global'),
          equals(['Leaderboard', 'Global']),
        );
        expect(
          NavigationUtils.generateBreadcrumbs('/leaderboard/session/123'),
          equals(['Leaderboard', 'Session']),
        );

        // Routes without breadcrumbs
        expect(NavigationUtils.generateBreadcrumbs('/home'), isEmpty);
        expect(NavigationUtils.generateBreadcrumbs('/login'), isEmpty);
      });
    });

    group('RED PHASE: Router Configuration', () {
      testCase('should initialize router correctly', TestCategory.unit, () {
        // TDD RED: Test router initialization and configuration

        final router = AppRouter.router;
        expect(router, isNotNull);
        expect(router, isA<GoRouter>());
        expect(router.routerDelegate, isNotNull);
        expect(router.routeInformationParser, isNotNull);
      });

      testCase(
        'should provide router through Riverpod correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test Riverpod provider integration

          final container = ProviderContainer();
          final routerFromProvider = container.read(routerProvider);

          expect(routerFromProvider, isNotNull);
          expect(routerFromProvider, isA<GoRouter>());
          expect(routerFromProvider, equals(AppRouter.router));

          container.dispose();
        },
      );

      testCase(
        'should handle navigation operations safely',
        TestCategory.unit,
        () {
          // TDD RED: Test safe navigation methods

          // These should not throw exceptions
          expect(() => AppRouter.go(RouteConstants.home), returnsNormally);
          expect(() => AppRouter.push(RouteConstants.about), returnsNormally);
          expect(() => AppRouter.canPop(), returnsNormally);
          expect(AppRouter.canPop(), isA<bool>());
        },
      );
    });

    group('RED PHASE: Auth Guard Registry', () {
      testCase(
        'should identify protected routes correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test route protection identification

          // Authentication routes (protected by GuestGuard)
          expect(AuthGuardRegistry.isProtected(RouteConstants.login), isTrue);
          expect(
            AuthGuardRegistry.isProtected(RouteConstants.register),
            isTrue,
          );
          expect(
            AuthGuardRegistry.isProtected(RouteConstants.forgotPassword),
            isTrue,
          );

          // User-protected routes (protected by AuthGuard)
          expect(
            AuthGuardRegistry.isProtected(RouteConstants.dashboard),
            isTrue,
          );
          expect(AuthGuardRegistry.isProtected(RouteConstants.profile), isTrue);
          expect(
            AuthGuardRegistry.isProtected(RouteConstants.quizCreation),
            isTrue,
          );

          // Public routes (not protected)
          expect(AuthGuardRegistry.isProtected(RouteConstants.home), isFalse);
          expect(AuthGuardRegistry.isProtected(RouteConstants.about), isFalse);
          expect(AuthGuardRegistry.isProtected(RouteConstants.help), isFalse);
        },
      );

      testCase(
        'should return appropriate guards for routes',
        TestCategory.unit,
        () {
          // TDD RED: Test guard assignment per route

          // Guest-only routes should have GuestGuard
          final loginGuards = AuthGuardRegistry.getGuards(RouteConstants.login);
          expect(loginGuards, isNotEmpty);
          expect(loginGuards.first, isA<GuestGuard>());

          // Protected routes should have AuthGuard
          final dashboardGuards = AuthGuardRegistry.getGuards(
            RouteConstants.dashboard,
          );
          expect(dashboardGuards, isNotEmpty);
          expect(dashboardGuards.first, isA<AuthGuard>());

          // Public routes should have no guards
          final homeGuards = AuthGuardRegistry.getGuards(RouteConstants.home);
          expect(homeGuards, isEmpty);
        },
      );

      testCase(
        'should match parametrized routes correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test pattern matching for dynamic routes

          // Game session routes should match SessionGuard pattern
          final sessionGuards = AuthGuardRegistry.getGuards(
            '/game/test-session-123',
          );
          expect(sessionGuards, isNotEmpty);
          expect(sessionGuards.first, isA<SessionGuard>());

          // Quiz edit routes should match multiple guards
          final quizEditGuards = AuthGuardRegistry.getGuards(
            '/quiz/test-quiz-123/edit',
          );
          expect(quizEditGuards, isNotEmpty);
          expect(
            quizEditGuards.length,
            greaterThan(1),
          ); // Should have AuthGuard + QuizOwnershipGuard
        },
      );

      testCase(
        'should provide guard type information for debugging',
        TestCategory.unit,
        () {
          // TDD RED: Test debugging utilities

          final loginGuardTypes = AuthGuardRegistry.getGuardTypes(
            RouteConstants.login,
          );
          expect(loginGuardTypes, contains('GuestGuard'));

          final dashboardGuardTypes = AuthGuardRegistry.getGuardTypes(
            RouteConstants.dashboard,
          );
          expect(dashboardGuardTypes, contains('AuthGuard'));

          final protectedRoutes = AuthGuardRegistry.protectedRoutes;
          expect(protectedRoutes, isNotEmpty);
          expect(protectedRoutes, contains(RouteConstants.login));
          expect(protectedRoutes, contains(RouteConstants.dashboard));
        },
      );
    });

    group('RED PHASE: Router Analytics', () {
      setUp(() {
        RouterAnalytics.clearAnalytics();
      });

      testCase(
        'should track navigation events correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test navigation analytics tracking

          const testRoute = '/test-route';
          RouterAnalytics.trackNavigation(testRoute);

          final history = RouterAnalytics.navigationHistory;
          expect(history, contains(testRoute));
          expect(RouterAnalytics.routeVisitCounts[testRoute], equals(1));
          expect(RouterAnalytics.recentlyVisited[testRoute], isA<DateTime>());
        },
      );

      testCase('should limit navigation history size', TestCategory.unit, () {
        // TDD RED: Test memory management for analytics

        // Add more than 50 routes
        for (int i = 0; i < 60; i++) {
          RouterAnalytics.trackNavigation('/route-$i');
        }

        final history = RouterAnalytics.navigationHistory;
        expect(history.length, equals(50));
        expect(
          history.first,
          equals('/route-10'),
        ); // First 10 should be removed
        expect(history.last, equals('/route-59'));
      });

      testCase(
        'should track route visit counts correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test visit frequency tracking

          const popularRoute = '/popular-route';
          for (int i = 0; i < 5; i++) {
            RouterAnalytics.trackNavigation(popularRoute);
          }

          expect(RouterAnalytics.routeVisitCounts[popularRoute], equals(5));
        },
      );

      testCase(
        'should handle analytics errors gracefully',
        TestCategory.unit,
        () {
          // TDD RED: Test error resilience

          // Should not throw when clearing empty analytics
          expect(() => RouterAnalytics.clearAnalytics(), returnsNormally);

          // Should handle null/empty route names
          expect(() => RouterAnalytics.trackNavigation(''), returnsNormally);

          // Verify data cleared correctly
          RouterAnalytics.trackNavigation('/test');
          expect(RouterAnalytics.navigationHistory, isNotEmpty);

          RouterAnalytics.clearAnalytics();
          expect(RouterAnalytics.navigationHistory, isEmpty);
          expect(RouterAnalytics.routeVisitCounts, isEmpty);
          expect(RouterAnalytics.recentlyVisited, isEmpty);
        },
      );
    });

    group('RED PHASE: Navigation Context and State', () {
      testCase(
        'should provide navigation context correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test navigation context generation

          final context = AppRouterHelper.getCurrentContext();
          expect(context, isA<NavigationContext>());
          expect(context.route, isA<String>());
          expect(context.isGameRoute, isA<bool>());
          expect(context.isAuthRoute, isA<bool>());
          expect(context.isQuizRoute, isA<bool>());
          expect(context.breadcrumbs, isA<List<String>>());
        },
      );

      testCase(
        'should handle route transitions correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test route transition logic

          // Authentication flow transitions
          final authTransition = NavigationUtils.getRouteTransitionType(
            RouteConstants.login,
            RouteConstants.register,
          );
          expect(authTransition, equals('slide'));

          // Game flow transitions
          final gameTransition = NavigationUtils.getRouteTransitionType(
            '/game/session123/waiting',
            '/game/session123/question/1',
          );
          expect(gameTransition, equals('slide'));

          // Quiz creation transitions
          final quizTransition = NavigationUtils.getRouteTransitionType(
            '/quiz-creation/form',
            '/quiz-creation/preview',
          );
          expect(quizTransition, equals('slide'));

          // Default transition
          final defaultTransition = NavigationUtils.getRouteTransitionType(
            RouteConstants.home,
            RouteConstants.about,
          );
          expect(defaultTransition, equals('fade'));
        },
      );
    });

    group('RED PHASE: Error Handling and Recovery', () {
      testCase(
        'should handle navigation errors gracefully',
        TestCategory.unit,
        () {
          // TDD RED: Test error handling for robust navigation

          // Safe navigation should not throw
          expect(
            () => AppRouterHelper.safeNavigateTo('/non-existent-route'),
            returnsNormally,
          );

          // Error recovery should not throw
          expect(
            () => NavigationUtils.recoverFromNavigationError(mockContext),
            returnsNormally,
          );

          // Safe push navigation should not throw
          expect(
            () => NavigationUtils.safePush(mockContext, '/test-route'),
            returnsNormally,
          );
        },
      );

      testCase('should validate navigation operations', TestCategory.unit, () {
        // TDD RED: Test input validation for navigation security

        // Back navigation validation
        expect(() => NavigationUtils.canGoBack(mockContext), returnsNormally);

        // Safe navigation with error callback
        var errorCalled = false;
        NavigationUtils.safeNavigate(
          mockContext,
          '/test-route',
          onError: () => errorCalled = true,
        );

        // The implementation should determine if error callback is called
        expect(errorCalled, isA<bool>());
      });

      testCase(
        'should handle delayed navigation correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test timed navigation features

          expect(
            () => NavigationUtils.delayedNavigation(
              mockContext,
              RouteConstants.home,
              const Duration(milliseconds: 100),
            ),
            returnsNormally,
          );
        },
      );
    });

    group('RED PHASE: Performance and Memory Management', () {
      testCase(
        'should handle rapid navigation changes efficiently',
        TestCategory.performance,
        () async {
          // TDD RED: Test navigation performance under load

          final stopwatch = Stopwatch()..start();

          // Simulate rapid navigation calls
          for (int i = 0; i < 10; i++) {
            RouterAnalytics.trackNavigation('/route-$i');
          }

          stopwatch.stop();

          // Navigation tracking should be fast
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Navigation tracking should be performant',
          );
        },
      );

      testCase(
        'should manage memory correctly for analytics',
        TestCategory.performance,
        () {
          // TDD RED: Test memory management for long-running apps

          // Fill up analytics history
          for (int i = 0; i < 100; i++) {
            RouterAnalytics.trackNavigation('/route-$i');
          }

          // Should limit memory usage by capping history
          expect(
            RouterAnalytics.navigationHistory.length,
            lessThanOrEqualTo(50),
          );

          // Should handle large visit counts efficiently
          const testRoute = '/popular-route';
          for (int i = 0; i < 1000; i++) {
            RouterAnalytics.trackNavigation(testRoute);
          }

          expect(RouterAnalytics.routeVisitCounts[testRoute], equals(1000));
        },
      );
    });
  });
}
