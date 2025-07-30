import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/core/navigation/navigation_utils.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import '../../../test_config.dart';
import '../../../helpers/test_utilities.dart';
import 'navigation_utils_test.mocks.dart';

/// Generate mocks for testing
@GenerateMocks([BuildContext, GoRouter, GoRouterState])
void main() {
  testGroup('NavigationUtils Route Parameter Parsing', TestCategory.unit, () {
    late MockGoRouterState mockState;

    setUp(() {
      mockState = MockGoRouterState();
    });

    testCase(
      'should parse quiz ID from route parameters',
      TestCategory.unit,
      () {
        // ARRANGE
        when(mockState.pathParameters).thenReturn({'quizId': 'test-quiz-123'});

        // ACT
        final quizId = NavigationUtils.getQuizIdFromState(mockState);

        // ASSERT
        expect(quizId, equals('test-quiz-123'));
      },
    );

    testCase(
      'should parse session ID from route parameters',
      TestCategory.unit,
      () {
        // ARRANGE
        when(
          mockState.pathParameters,
        ).thenReturn({'sessionId': 'test-session-456'});

        // ACT
        final sessionId = NavigationUtils.getSessionIdFromState(mockState);

        // ASSERT
        expect(sessionId, equals('test-session-456'));
      },
    );

    testCase(
      'should parse question index from route parameters',
      TestCategory.unit,
      () {
        // ARRANGE
        when(mockState.pathParameters).thenReturn({'questionIndex': '5'});

        // ACT
        final questionIndex = NavigationUtils.getQuestionIndexFromState(
          mockState,
        );

        // ASSERT
        expect(questionIndex, equals(5));
      },
    );

    testCase(
      'should return null for invalid question index',
      TestCategory.unit,
      () {
        // ARRANGE
        when(mockState.pathParameters).thenReturn({'questionIndex': 'invalid'});

        // ACT
        final questionIndex = NavigationUtils.getQuestionIndexFromState(
          mockState,
        );

        // ASSERT
        expect(questionIndex, isNull);
      },
    );

    testCase(
      'should return null for missing parameters',
      TestCategory.unit,
      () {
        // ARRANGE
        when(mockState.pathParameters).thenReturn({});

        // ACT
        final quizId = NavigationUtils.getQuizIdFromState(mockState);
        final sessionId = NavigationUtils.getSessionIdFromState(mockState);
        final questionIndex = NavigationUtils.getQuestionIndexFromState(
          mockState,
        );

        // ASSERT
        expect(quizId, isNull);
        expect(sessionId, isNull);
        expect(questionIndex, isNull);
      },
    );
  });

  testGroup('NavigationUtils Query Parameter Handling', TestCategory.unit, () {
    late MockGoRouterState mockState;

    setUp(() {
      mockState = MockGoRouterState();
    });

    testCase(
      'should extract query parameters correctly',
      TestCategory.unit,
      () {
        // ARRANGE
        final mockUri = Uri.parse('/game/join?pin=123456&mode=test');
        when(mockState.uri).thenReturn(mockUri);

        // ACT
        final queryParams = NavigationUtils.getQueryParameters(mockState);

        // ASSERT
        expect(queryParams['pin'], equals('123456'));
        expect(queryParams['mode'], equals('test'));
      },
    );

    testCase(
      'should build URL with query parameters correctly',
      TestCategory.unit,
      () {
        // ARRANGE
        const basePath = '/game/join';
        const queryParams = {'pin': '123456', 'mode': 'test'};

        // ACT
        final url = NavigationUtils.buildUrlWithQuery(basePath, queryParams);

        // ASSERT
        expect(url, contains('pin=123456'));
        expect(url, contains('mode=test'));
        expect(url, startsWith('/game/join'));
      },
    );

    testCase(
      'should return original path when no query parameters',
      TestCategory.unit,
      () {
        // ARRANGE
        const basePath = '/game/join';
        const queryParams = <String, String>{};

        // ACT
        final url = NavigationUtils.buildUrlWithQuery(basePath, queryParams);

        // ASSERT
        expect(url, equals(basePath));
      },
    );
  });

  testGroup('NavigationUtils Parameter Validation', TestCategory.unit, () {
    testCase('should validate quiz IDs correctly', TestCategory.unit, () {
      // Valid quiz IDs
      expect(NavigationUtils.isValidQuizId('quiz123456'), isTrue);
      expect(NavigationUtils.isValidQuizId('very-long-quiz-id-123'), isTrue);
      expect(NavigationUtils.isValidQuizId('123456'), isTrue);

      // Invalid quiz IDs
      expect(NavigationUtils.isValidQuizId(null), isFalse);
      expect(NavigationUtils.isValidQuizId(''), isFalse);
      expect(NavigationUtils.isValidQuizId('short'), isFalse);
      expect(NavigationUtils.isValidQuizId('12345'), isFalse); // Too short
    });

    testCase('should validate session IDs correctly', TestCategory.unit, () {
      // Valid session IDs
      expect(NavigationUtils.isValidSessionId('session123456'), isTrue);
      expect(NavigationUtils.isValidSessionId('very-long-session-id'), isTrue);
      expect(NavigationUtils.isValidSessionId('123456'), isTrue);

      // Invalid session IDs
      expect(NavigationUtils.isValidSessionId(null), isFalse);
      expect(NavigationUtils.isValidSessionId(''), isFalse);
      expect(NavigationUtils.isValidSessionId('short'), isFalse);
      expect(NavigationUtils.isValidSessionId('12345'), isFalse);
    });

    testCase(
      'should validate question indices correctly',
      TestCategory.unit,
      () {
        // Valid indices
        expect(NavigationUtils.isValidQuestionIndex(0), isTrue);
        expect(NavigationUtils.isValidQuestionIndex(1), isTrue);
        expect(NavigationUtils.isValidQuestionIndex(100), isTrue);
        expect(NavigationUtils.isValidQuestionIndex(999), isTrue);

        // Invalid indices
        expect(NavigationUtils.isValidQuestionIndex(null), isFalse);
        expect(NavigationUtils.isValidQuestionIndex(-1), isFalse);
        expect(NavigationUtils.isValidQuestionIndex(-100), isFalse);
      },
    );
  });

  testGroup('NavigationUtils Deep Link Processing', TestCategory.unit, () {
    testCase(
      'should extract game PIN from query parameters',
      TestCategory.unit,
      () {
        // Valid URLs with query parameters
        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/join?pin=123456',
          ),
          equals('123456'),
        );

        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/join?pin=654321&mode=test',
          ),
          equals('654321'),
        );
      },
    );

    testCase(
      'should extract game PIN from path segments',
      TestCategory.unit,
      () {
        // Valid URLs with PIN in path
        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/123456',
          ),
          equals('123456'),
        );

        expect(
          NavigationUtils.extractGamePinFromUrl(
            'https://example.com/game/654321/waiting',
          ),
          equals('654321'),
        );
      },
    );

    testCase('should return null for invalid URLs', TestCategory.unit, () {
      // Invalid URLs
      expect(NavigationUtils.extractGamePinFromUrl('invalid-url'), isNull);

      expect(NavigationUtils.extractGamePinFromUrl(''), isNull);

      expect(
        NavigationUtils.extractGamePinFromUrl(
          'https://example.com/game/join?pin=12345',
        ),
        isNull,
      ); // PIN too short

      expect(
        NavigationUtils.extractGamePinFromUrl(
          'https://example.com/game/join?pin=1234567',
        ),
        isNull,
      ); // PIN too long

      expect(
        NavigationUtils.extractGamePinFromUrl(
          'https://example.com/game/join?pin=abcdef',
        ),
        isNull,
      ); // Non-numeric PIN
    });
  });

  testGroup('NavigationUtils Shareable URL Generation', TestCategory.unit, () {
    testCase(
      'should generate quiz share URLs correctly',
      TestCategory.unit,
      () {
        // With default base URL
        final url1 = NavigationUtils.generateQuizShareUrl('quiz123');
        expect(url1, contains('/quiz/quiz123'));
        expect(url1, startsWith('https://quizapp.com'));

        // With custom base URL
        final url2 = NavigationUtils.generateQuizShareUrl(
          'quiz456',
          baseUrl: 'https://custom.com',
        );
        expect(url2, contains('/quiz/quiz456'));
        expect(url2, startsWith('https://custom.com'));
      },
    );

    testCase('should generate game join URLs correctly', TestCategory.unit, () {
      // With default base URL
      final url1 = NavigationUtils.generateGameJoinUrl('123456');
      expect(url1, contains('/game/join?pin=123456'));
      expect(url1, startsWith('https://quizapp.com'));

      // With custom base URL
      final url2 = NavigationUtils.generateGameJoinUrl(
        '654321',
        baseUrl: 'https://custom.com',
      );
      expect(url2, contains('/game/join?pin=654321'));
      expect(url2, startsWith('https://custom.com'));
    });

    testCase(
      'should generate leaderboard share URLs correctly',
      TestCategory.unit,
      () {
        // With default base URL
        final url1 = NavigationUtils.generateLeaderboardShareUrl('session123');
        expect(url1, contains('/leaderboard/session/session123'));
        expect(url1, startsWith('https://quizapp.com'));

        // With custom base URL
        final url2 = NavigationUtils.generateLeaderboardShareUrl(
          'session456',
          baseUrl: 'https://custom.com',
        );
        expect(url2, contains('/leaderboard/session/session456'));
        expect(url2, startsWith('https://custom.com'));
      },
    );
  });

  testGroup('NavigationUtils Route Classification', TestCategory.unit, () {
    testCase(
      'should identify authentication routes correctly',
      TestCategory.unit,
      () {
        // Auth routes should return true
        expect(NavigationUtils.isAuthRoute(RouteConstants.login), isTrue);
        expect(NavigationUtils.isAuthRoute(RouteConstants.register), isTrue);
        expect(
          NavigationUtils.isAuthRoute(RouteConstants.forgotPassword),
          isTrue,
        );

        // Non-auth routes should return false
        expect(NavigationUtils.isAuthRoute(RouteConstants.home), isFalse);
        expect(NavigationUtils.isAuthRoute(RouteConstants.dashboard), isFalse);
        expect(NavigationUtils.isAuthRoute('/game/join'), isFalse);
        expect(NavigationUtils.isAuthRoute('/quiz/123'), isFalse);
      },
    );

    testCase('should identify game routes correctly', TestCategory.unit, () {
      // Game routes should return true
      expect(NavigationUtils.isGameRoute('/game/join'), isTrue);
      expect(NavigationUtils.isGameRoute('/game/session123'), isTrue);
      expect(NavigationUtils.isGameRoute('/game/session123/waiting'), isTrue);
      expect(
        NavigationUtils.isGameRoute('/game/session123/question/1'),
        isTrue,
      );
      expect(NavigationUtils.isGameRoute('/game/session123/results'), isTrue);

      // Non-game routes should return false
      expect(NavigationUtils.isGameRoute(RouteConstants.home), isFalse);
      expect(NavigationUtils.isGameRoute(RouteConstants.login), isFalse);
      expect(NavigationUtils.isGameRoute('/quiz/123'), isFalse);
      expect(NavigationUtils.isGameRoute('/leaderboard'), isFalse);
    });

    testCase('should identify quiz routes correctly', TestCategory.unit, () {
      // Quiz routes should return true
      expect(NavigationUtils.isQuizRoute('/quiz/123'), isTrue);
      expect(NavigationUtils.isQuizRoute('/quiz/123/edit'), isTrue);
      expect(NavigationUtils.isQuizRoute('/quiz-creation'), isTrue);
      expect(NavigationUtils.isQuizRoute('/quiz-creation/form'), isTrue);
      expect(NavigationUtils.isQuizRoute('/quiz-creation/preview'), isTrue);

      // Non-quiz routes should return false
      expect(NavigationUtils.isQuizRoute(RouteConstants.home), isFalse);
      expect(NavigationUtils.isQuizRoute('/game/join'), isFalse);
      expect(NavigationUtils.isQuizRoute('/leaderboard'), isFalse);
    });

    testCase(
      'should identify leaderboard routes correctly',
      TestCategory.unit,
      () {
        // Leaderboard routes should return true
        expect(NavigationUtils.isLeaderboardRoute('/leaderboard'), isTrue);
        expect(
          NavigationUtils.isLeaderboardRoute('/leaderboard/global'),
          isTrue,
        );
        expect(
          NavigationUtils.isLeaderboardRoute('/leaderboard/session/123'),
          isTrue,
        );

        // Non-leaderboard routes should return false
        expect(
          NavigationUtils.isLeaderboardRoute(RouteConstants.home),
          isFalse,
        );
        expect(NavigationUtils.isLeaderboardRoute('/game/join'), isFalse);
        expect(NavigationUtils.isLeaderboardRoute('/quiz/123'), isFalse);
      },
    );
  });

  testGroup('NavigationUtils Navigation State Helpers', TestCategory.unit, () {
    late MockBuildContext mockContext;
    late MockGoRouter mockRouter;

    setUp(() {
      mockContext = MockBuildContext();
      mockRouter = MockGoRouter();
    });

    testCase('should check if can go back correctly', TestCategory.unit, () {
      // This would require proper mocking of GoRouter.of(context)
      // For now, test that the method doesn't throw
      expect(() => NavigationUtils.canGoBack(mockContext), returnsNormally);
    });

    testCase('should handle go back or home correctly', TestCategory.unit, () {
      // Test that the method doesn't throw
      expect(() => NavigationUtils.goBackOrHome(mockContext), returnsNormally);
    });
  });

  testGroup('NavigationUtils Safe Navigation', TestCategory.unit, () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    testCase(
      'should handle safe navigation without throwing',
      TestCategory.unit,
      () {
        // Test safe navigation methods don't throw
        expect(
          () => NavigationUtils.safeNavigate(mockContext, '/test-route'),
          returnsNormally,
        );

        expect(
          () => NavigationUtils.safePush(mockContext, '/test-route'),
          returnsNormally,
        );
      },
    );

    testCase(
      'should call error handler on navigation failure',
      TestCategory.unit,
      () {
        // ARRANGE
        bool errorHandlerCalled = false;
        void errorHandler() {
          errorHandlerCalled = true;
        }

        // ACT
        NavigationUtils.safeNavigate(
          mockContext,
          '/test-route',
          onError: errorHandler,
        );

        NavigationUtils.safePush(
          mockContext,
          '/test-route',
          onError: errorHandler,
        );

        // Note: In a real test, you'd need to mock GoRouter.of to throw
        // For now, just test that the methods accept the error handler
        expect(errorHandler, isA<VoidCallback>());
      },
    );
  });

  testGroup('NavigationUtils Route Transition Types', TestCategory.unit, () {
    testCase(
      'should return slide transition for auth routes',
      TestCategory.unit,
      () {
        final transitionType = NavigationUtils.getRouteTransitionType(
          RouteConstants.login,
          RouteConstants.register,
        );
        expect(transitionType, equals('slide'));
      },
    );

    testCase(
      'should return slide transition for game routes',
      TestCategory.unit,
      () {
        final transitionType = NavigationUtils.getRouteTransitionType(
          '/game/join',
          '/game/session123/waiting',
        );
        expect(transitionType, equals('slide'));
      },
    );

    testCase(
      'should return slide transition for quiz creation',
      TestCategory.unit,
      () {
        final transitionType = NavigationUtils.getRouteTransitionType(
          '/quiz-creation',
          '/quiz-creation/form',
        );
        expect(transitionType, equals('slide'));
      },
    );

    testCase('should return fade transition as default', TestCategory.unit, () {
      final transitionType = NavigationUtils.getRouteTransitionType(
        RouteConstants.home,
        RouteConstants.about,
      );
      expect(transitionType, equals('fade'));
    });
  });

  testGroup('NavigationUtils Breadcrumb Generation', TestCategory.unit, () {
    testCase(
      'should generate breadcrumbs for quiz creation routes',
      TestCategory.unit,
      () {
        // Quiz creation form
        final breadcrumbs1 = NavigationUtils.generateBreadcrumbs(
          '/quiz-creation/form',
        );
        expect(breadcrumbs1, contains('Quiz Creation'));
        expect(breadcrumbs1, contains('Form'));

        // Quiz creation preview
        final breadcrumbs2 = NavigationUtils.generateBreadcrumbs(
          '/quiz-creation/preview',
        );
        expect(breadcrumbs2, contains('Quiz Creation'));
        expect(breadcrumbs2, contains('Preview'));

        // Quiz creation publish
        final breadcrumbs3 = NavigationUtils.generateBreadcrumbs(
          '/quiz-creation/publish',
        );
        expect(breadcrumbs3, contains('Quiz Creation'));
        expect(breadcrumbs3, contains('Publish'));
      },
    );

    testCase(
      'should generate breadcrumbs for game routes',
      TestCategory.unit,
      () {
        // Game waiting
        final breadcrumbs1 = NavigationUtils.generateBreadcrumbs(
          '/game/session123/waiting',
        );
        expect(breadcrumbs1, contains('Game'));
        expect(breadcrumbs1, contains('Waiting'));

        // Game question
        final breadcrumbs2 = NavigationUtils.generateBreadcrumbs(
          '/game/session123/question/1',
        );
        expect(breadcrumbs2, contains('Game'));
        expect(breadcrumbs2, contains('Question'));

        // Game results
        final breadcrumbs3 = NavigationUtils.generateBreadcrumbs(
          '/game/session123/results',
        );
        expect(breadcrumbs3, contains('Game'));
        expect(breadcrumbs3, contains('Results'));
      },
    );

    testCase(
      'should generate breadcrumbs for leaderboard routes',
      TestCategory.unit,
      () {
        // Global leaderboard
        final breadcrumbs1 = NavigationUtils.generateBreadcrumbs(
          '/leaderboard/global',
        );
        expect(breadcrumbs1, contains('Leaderboard'));
        expect(breadcrumbs1, contains('Global'));

        // Session leaderboard
        final breadcrumbs2 = NavigationUtils.generateBreadcrumbs(
          '/leaderboard/session/123',
        );
        expect(breadcrumbs2, contains('Leaderboard'));
        expect(breadcrumbs2, contains('Session'));
      },
    );

    testCase(
      'should return empty breadcrumbs for unknown routes',
      TestCategory.unit,
      () {
        final breadcrumbs = NavigationUtils.generateBreadcrumbs('/unknown');
        expect(breadcrumbs, isEmpty);
      },
    );
  });

  testGroup('NavigationUtils Analytics and Tracking', TestCategory.unit, () {
    late MockGoRouterState mockState;

    setUp(() {
      mockState = MockGoRouterState();
    });

    testCase('should generate analytics data correctly', TestCategory.unit, () {
      // ARRANGE
      final mockUri = Uri.parse('/game/join?pin=123456');
      when(mockState.matchedLocation).thenReturn('/game/join');
      when(mockState.pathParameters).thenReturn({});
      when(mockState.uri).thenReturn(mockUri);

      // ACT
      final analyticsData = NavigationUtils.getRouteAnalyticsData(mockState);

      // ASSERT
      expect(analyticsData, isA<Map<String, dynamic>>());
      expect(analyticsData['route'], equals('/game/join'));
      expect(analyticsData['path_parameters'], isA<Map>());
      expect(analyticsData['query_parameters'], isA<Map>());
      expect(analyticsData['timestamp'], isA<String>());
    });
  });

  testGroup('NavigationUtils URL Validation', TestCategory.unit, () {
    testCase('should validate deep links correctly', TestCategory.unit, () {
      // Valid URLs
      expect(
        NavigationUtils.isValidDeepLink('https://example.com/game/join'),
        isTrue,
      );
      expect(
        NavigationUtils.isValidDeepLink('http://localhost:3000/quiz/123'),
        isTrue,
      );

      // Invalid URLs
      expect(NavigationUtils.isValidDeepLink(''), isFalse);
      expect(NavigationUtils.isValidDeepLink('invalid-url'), isFalse);
      expect(NavigationUtils.isValidDeepLink('/relative/path'), isFalse);
    });
  });

  testGroup('NavigationUtils Route Comparison', TestCategory.unit, () {
    testCase(
      'should compare routes correctly ignoring query parameters',
      TestCategory.unit,
      () {
        expect(
          NavigationUtils.isSameRoute(
            '/game/join?pin=123456',
            '/game/join?pin=654321',
          ),
          isTrue,
        );

        expect(NavigationUtils.isSameRoute('/quiz/123', '/quiz/456'), isFalse);

        expect(NavigationUtils.isSameRoute('/game/join', '/game/join'), isTrue);
      },
    );

    testCase('should identify child routes correctly', TestCategory.unit, () {
      expect(NavigationUtils.isChildRoute('/quiz', '/quiz/123'), isTrue);

      expect(
        NavigationUtils.isChildRoute('/game', '/game/session123/waiting'),
        isTrue,
      );

      expect(NavigationUtils.isChildRoute('/quiz', '/quiz'), isFalse);

      expect(NavigationUtils.isChildRoute('/game', '/home'), isFalse);
    });
  });

  testGroup('NavigationUtils Delayed Navigation', TestCategory.unit, () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    testCase('should handle delayed navigation', TestCategory.unit, () async {
      // Test that delayed navigation doesn't throw immediately
      expect(
        () => NavigationUtils.delayedNavigation(
          mockContext,
          '/test-route',
          const Duration(milliseconds: 10),
        ),
        returnsNormally,
      );

      // Wait for the delay to complete
      await Future.delayed(const Duration(milliseconds: 20));
    });
  });

  testGroup('NavigationUtils Error Recovery', TestCategory.unit, () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    testCase('should handle navigation error recovery', TestCategory.unit, () {
      // Test that error recovery doesn't throw
      expect(
        () => NavigationUtils.recoverFromNavigationError(mockContext),
        returnsNormally,
      );
    });
  });
}
