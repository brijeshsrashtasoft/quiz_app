import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/navigation_utils.dart';
import '../../../test_config.dart';

/// Isolated navigation utility tests that avoid problematic dependencies
/// Following TDD approach for core navigation functionality
/// These tests focus purely on navigation logic without UI dependencies

void main() {
  group('TDD Navigation Utilities - Isolated Tests', () {
    group('RED PHASE: Route Constants Validation', () {
      testCase(
        'should have all required route constants defined',
        TestCategory.unit,
        () {
          // TDD RED: Verify all core route constants exist
          expect(RouteConstants.root, equals('/'));
          expect(RouteConstants.splash, equals('/splash'));
          expect(RouteConstants.home, equals('/home'));
          expect(RouteConstants.login, equals('/login'));
          expect(RouteConstants.register, equals('/register'));
          expect(RouteConstants.forgotPassword, equals('/forgot-password'));
          expect(RouteConstants.profile, equals('/profile'));
          expect(RouteConstants.dashboard, equals('/dashboard'));
          expect(RouteConstants.quizCreation, equals('/quiz-creation'));
          expect(RouteConstants.gameJoin, equals('/game/join'));
          expect(RouteConstants.gameHost, equals('/game/host'));
          expect(RouteConstants.leaderboard, equals('/leaderboard'));
          expect(RouteConstants.settings, equals('/settings'));
          expect(RouteConstants.about, equals('/about'));
          expect(RouteConstants.help, equals('/help'));
          expect(RouteConstants.notFound, equals('/404'));
          expect(RouteConstants.error, equals('/error'));
        },
      );

      testCase(
        'should generate dynamic route paths correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test dynamic route generation
          expect(
            RouteConstants.quizDetailsPath('quiz123'),
            equals('/quiz/quiz123'),
          );
          expect(
            RouteConstants.quizEditPath('quiz123'),
            equals('/quiz/quiz123/edit'),
          );
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
          expect(
            RouteConstants.leaderboardSessionPath('session789'),
            equals('/leaderboard/session/session789'),
          );
        },
      );
    });

    group('RED PHASE: Parameter Validation', () {
      testCase('should validate quiz IDs correctly', TestCategory.unit, () {
        // TDD RED: Test quiz ID validation logic
        // Valid quiz IDs
        expect(NavigationUtils.isValidQuizId('validQuizId123'), isTrue);
        expect(NavigationUtils.isValidQuizId('quiz-with-dashes'), isTrue);
        expect(NavigationUtils.isValidQuizId('quiz_with_underscores'), isTrue);
        expect(NavigationUtils.isValidQuizId('123456'), isTrue);
        expect(NavigationUtils.isValidQuizId('a'.padRight(20, 'x')), isTrue);

        // Invalid quiz IDs
        expect(NavigationUtils.isValidQuizId(''), isFalse);
        expect(NavigationUtils.isValidQuizId(null), isFalse);
        expect(NavigationUtils.isValidQuizId('short'), isFalse);
        expect(NavigationUtils.isValidQuizId('x'), isFalse);
        expect(
          NavigationUtils.isValidQuizId('12345'),
          isFalse,
        ); // Less than 6 chars
      });

      testCase('should validate session IDs correctly', TestCategory.unit, () {
        // TDD RED: Test session ID validation logic
        // Valid session IDs
        expect(NavigationUtils.isValidSessionId('validSessionId123'), isTrue);
        expect(NavigationUtils.isValidSessionId('session-with-dashes'), isTrue);
        expect(
          NavigationUtils.isValidSessionId('session_with_underscores'),
          isTrue,
        );
        expect(NavigationUtils.isValidSessionId('123456'), isTrue);
        expect(NavigationUtils.isValidSessionId('a'.padRight(20, 'x')), isTrue);

        // Invalid session IDs
        expect(NavigationUtils.isValidSessionId(''), isFalse);
        expect(NavigationUtils.isValidSessionId(null), isFalse);
        expect(NavigationUtils.isValidSessionId('short'), isFalse);
        expect(NavigationUtils.isValidSessionId('x'), isFalse);
        expect(
          NavigationUtils.isValidSessionId('12345'),
          isFalse,
        ); // Less than 6 chars
      });

      testCase(
        'should validate question indices correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test question index validation
          // Valid indices
          expect(NavigationUtils.isValidQuestionIndex(0), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(1), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(5), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(100), isTrue);
          expect(NavigationUtils.isValidQuestionIndex(999), isTrue);

          // Invalid indices
          expect(NavigationUtils.isValidQuestionIndex(null), isFalse);
          expect(NavigationUtils.isValidQuestionIndex(-1), isFalse);
          expect(NavigationUtils.isValidQuestionIndex(-10), isFalse);
          expect(NavigationUtils.isValidQuestionIndex(-999), isFalse);
        },
      );
    });

    group('RED PHASE: URL Building', () {
      testCase(
        'should build URLs with query parameters correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test URL building functionality
          // Empty query parameters
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {}),
            equals('/test'),
          );

          // Single query parameter
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {'param': 'value'}),
            equals('/test?param=value'),
          );

          // Multiple query parameters
          final multiParamUrl = NavigationUtils.buildUrlWithQuery('/test', {
            'param1': 'value1',
            'param2': 'value2',
            'param3': 'value3',
          });
          expect(multiParamUrl, startsWith('/test?'));
          expect(multiParamUrl, contains('param1=value1'));
          expect(multiParamUrl, contains('param2=value2'));
          expect(multiParamUrl, contains('param3=value3'));

          // Special characters in parameters
          expect(
            NavigationUtils.buildUrlWithQuery('/test', {
              'key': 'value with spaces',
            }),
            contains('key=value%20with%20spaces'),
          );
        },
      );
    });

    group('RED PHASE: Deep Link Processing', () {
      testCase(
        'should extract game PIN from URLs correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test game PIN extraction from various URL formats
          // Valid URLs with PIN in query parameters
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/join?pin=123456',
            ),
            equals('123456'),
          );
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'http://localhost:3000/game/join?pin=654321',
            ),
            equals('654321'),
          );

          // Valid URLs with PIN in path segments
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/123456',
            ),
            equals('123456'),
          );
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://example.com/game/654321/join',
            ),
            equals('654321'),
          );

          // Invalid URLs
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
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/12345',
            ),
            isNull,
          );

          // Non-numeric PINs
          expect(
            NavigationUtils.extractGamePinFromUrl(
              'https://quizapp.com/game/abcdef',
            ),
            isNull,
          );
        },
      );

      testCase(
        'should generate shareable URLs correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test URL generation for sharing
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
          final customUrl = NavigationUtils.generateQuizShareUrl(
            'quiz456',
            baseUrl: 'https://custom.com',
          );
          expect(customUrl, startsWith('https://custom.com'));
          expect(customUrl, contains('/quiz/quiz456'));
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
          expect(
            NavigationUtils.isValidDeepLink('ftp://example.com/file'),
            isTrue,
          );

          // Invalid URLs
          expect(NavigationUtils.isValidDeepLink('invalid-url'), isFalse);
          expect(NavigationUtils.isValidDeepLink(''), isFalse);
          expect(NavigationUtils.isValidDeepLink('not-a-url'), isFalse);
          expect(NavigationUtils.isValidDeepLink('just-text'), isFalse);
        },
      );
    });

    group('RED PHASE: Route Classification', () {
      testCase(
        'should classify authentication routes correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test authentication route identification
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
          expect(NavigationUtils.isAuthRoute(RouteConstants.about), isFalse);
          expect(NavigationUtils.isAuthRoute('/game/join'), isFalse);
          expect(NavigationUtils.isAuthRoute('/quiz/123'), isFalse);
        },
      );

      testCase('should classify game routes correctly', TestCategory.unit, () {
        // TDD RED: Test game route identification
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
        expect(NavigationUtils.isGameRoute('/game/host/setup'), isTrue);

        // Non-game routes
        expect(NavigationUtils.isGameRoute(RouteConstants.home), isFalse);
        expect(NavigationUtils.isGameRoute(RouteConstants.login), isFalse);
        expect(NavigationUtils.isGameRoute('/quiz/123'), isFalse);
        expect(NavigationUtils.isGameRoute('/leaderboard'), isFalse);
        expect(NavigationUtils.isGameRoute('/settings'), isFalse);
      });

      testCase('should classify quiz routes correctly', TestCategory.unit, () {
        // TDD RED: Test quiz route identification
        // Quiz routes
        expect(NavigationUtils.isQuizRoute('/quiz/123'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz/123/edit'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation/form'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation/preview'), isTrue);
        expect(NavigationUtils.isQuizRoute('/quiz-creation/publish'), isTrue);

        // Non-quiz routes
        expect(NavigationUtils.isQuizRoute(RouteConstants.home), isFalse);
        expect(NavigationUtils.isQuizRoute('/game/join'), isFalse);
        expect(
          NavigationUtils.isQuizRoute(RouteConstants.leaderboard),
          isFalse,
        );
        expect(NavigationUtils.isQuizRoute(RouteConstants.login), isFalse);
      });

      testCase(
        'should classify leaderboard routes correctly',
        TestCategory.unit,
        () {
          // TDD RED: Test leaderboard route identification
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
          expect(
            NavigationUtils.isLeaderboardRoute(RouteConstants.login),
            isFalse,
          );
        },
      );
    });

    group('RED PHASE: Route Comparison', () {
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
        expect(
          NavigationUtils.isSameRoute('/test?a=1&b=2', '/test?b=2&a=1'),
          isTrue,
        );

        // Different routes
        expect(NavigationUtils.isSameRoute('/test1', '/test2'), isFalse);
        expect(
          NavigationUtils.isSameRoute('/path1/sub', '/path2/sub'),
          isFalse,
        );
        expect(NavigationUtils.isSameRoute('/game/join', '/quiz/123'), isFalse);

        // Case sensitivity
        expect(NavigationUtils.isSameRoute('/Test', '/test'), isFalse);
        expect(NavigationUtils.isSameRoute('/PATH', '/path'), isFalse);
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
        expect(
          NavigationUtils.isChildRoute(
            '/game/session123',
            '/game/session123/waiting',
          ),
          isTrue,
        );

        // Not child routes
        expect(NavigationUtils.isChildRoute('/parent', '/parent'), isFalse);
        expect(NavigationUtils.isChildRoute('/parent', '/other'), isFalse);
        expect(
          NavigationUtils.isChildRoute('/parent/child', '/parent'),
          isFalse,
        );
        expect(NavigationUtils.isChildRoute('/quiz', '/game'), isFalse);

        // Edge cases
        expect(NavigationUtils.isChildRoute('', '/child'), isTrue);
        expect(NavigationUtils.isChildRoute('/parent', ''), isFalse);
        expect(NavigationUtils.isChildRoute('', ''), isFalse);
      });
    });

    group('RED PHASE: Breadcrumb Generation', () {
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
        expect(NavigationUtils.generateBreadcrumbs('/about'), isEmpty);
        expect(NavigationUtils.generateBreadcrumbs('/settings'), isEmpty);
        expect(NavigationUtils.generateBreadcrumbs(''), isEmpty);
      });
    });

    group('RED PHASE: Route Transition Types', () {
      testCase(
        'should determine appropriate transition types',
        TestCategory.unit,
        () {
          // TDD RED: Test transition type selection logic
          // Authentication flow transitions
          expect(
            NavigationUtils.getRouteTransitionType(
              RouteConstants.login,
              RouteConstants.register,
            ),
            equals('slide'),
          );
          expect(
            NavigationUtils.getRouteTransitionType(
              RouteConstants.register,
              RouteConstants.forgotPassword,
            ),
            equals('slide'),
          );

          // Game flow transitions
          expect(
            NavigationUtils.getRouteTransitionType(
              '/game/session123/waiting',
              '/game/session123/question/1',
            ),
            equals('slide'),
          );
          expect(
            NavigationUtils.getRouteTransitionType(
              '/game/session123/question/1',
              '/game/session123/results',
            ),
            equals('slide'),
          );

          // Quiz creation transitions
          expect(
            NavigationUtils.getRouteTransitionType(
              '/quiz-creation/form',
              '/quiz-creation/preview',
            ),
            equals('slide'),
          );
          expect(
            NavigationUtils.getRouteTransitionType(
              '/quiz-creation/preview',
              '/quiz-creation/publish',
            ),
            equals('slide'),
          );

          // Default transition
          expect(
            NavigationUtils.getRouteTransitionType(
              RouteConstants.home,
              RouteConstants.about,
            ),
            equals('fade'),
          );
          expect(
            NavigationUtils.getRouteTransitionType(
              '/random/path',
              '/another/path',
            ),
            equals('fade'),
          );
        },
      );
    });

    group('RED PHASE: Performance Requirements', () {
      testCase(
        'should perform route validation quickly',
        TestCategory.performance,
        () {
          // TDD RED: Test validation performance
          final stopwatch = Stopwatch()..start();

          // Perform many validations
          for (int i = 0; i < 1000; i++) {
            NavigationUtils.isValidQuizId('quiz-id-$i');
            NavigationUtils.isValidSessionId('session-id-$i');
            NavigationUtils.isValidQuestionIndex(i);
          }

          stopwatch.stop();

          // Should complete within performance threshold
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Route validation should be performant',
          );
        },
      );

      testCase(
        'should perform route classification quickly',
        TestCategory.performance,
        () {
          // TDD RED: Test classification performance
          final testRoutes = [
            RouteConstants.login,
            '/game/session-123',
            '/quiz/quiz-456',
            '/leaderboard/session/789',
            RouteConstants.home,
          ];

          final stopwatch = Stopwatch()..start();

          // Perform many classifications
          for (int i = 0; i < 1000; i++) {
            for (final route in testRoutes) {
              NavigationUtils.isAuthRoute(route);
              NavigationUtils.isGameRoute(route);
              NavigationUtils.isQuizRoute(route);
              NavigationUtils.isLeaderboardRoute(route);
            }
          }

          stopwatch.stop();

          // Should complete within performance threshold
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(milliseconds: 100)),
            reason: 'Route classification should be performant',
          );
        },
      );

      testCase('should generate URLs quickly', TestCategory.performance, () {
        // TDD RED: Test URL generation performance
        final stopwatch = Stopwatch()..start();

        // Generate many URLs
        for (int i = 0; i < 1000; i++) {
          NavigationUtils.generateQuizShareUrl('quiz-$i');
          NavigationUtils.generateGameJoinUrl('${100000 + i}');
          NavigationUtils.generateLeaderboardShareUrl('session-$i');
        }

        stopwatch.stop();

        // Should complete within performance threshold
        expect(
          stopwatch.elapsed,
          lessThan(const Duration(milliseconds: 100)),
          reason: 'URL generation should be performant',
        );
      });
    });

    group('RED PHASE: Edge Cases and Error Handling', () {
      testCase(
        'should handle null and empty inputs gracefully',
        TestCategory.unit,
        () {
          // TDD RED: Test error handling for invalid inputs
          // Null inputs
          expect(NavigationUtils.isValidQuizId(null), isFalse);
          expect(NavigationUtils.isValidSessionId(null), isFalse);
          expect(NavigationUtils.isValidQuestionIndex(null), isFalse);

          // Empty inputs
          expect(NavigationUtils.isValidQuizId(''), isFalse);
          expect(NavigationUtils.isValidSessionId(''), isFalse);
          expect(NavigationUtils.extractGamePinFromUrl(''), isNull);
          expect(NavigationUtils.isValidDeepLink(''), isFalse);

          // Should not throw exceptions
          expect(
            () => NavigationUtils.buildUrlWithQuery('', {}),
            returnsNormally,
          );
          expect(
            () => NavigationUtils.generateBreadcrumbs(''),
            returnsNormally,
          );
          expect(() => NavigationUtils.isSameRoute('', ''), returnsNormally);
          expect(() => NavigationUtils.isChildRoute('', ''), returnsNormally);
        },
      );

      testCase(
        'should handle malformed URLs gracefully',
        TestCategory.unit,
        () {
          // TDD RED: Test handling of malformed URLs
          final malformedUrls = [
            'ht tp://invalid',
            'https://[invalid',
            'not-a-url-at-all',
            'javascript:alert("xss")',
            '../../../../etc/passwd',
          ];

          for (final url in malformedUrls) {
            expect(
              () => NavigationUtils.extractGamePinFromUrl(url),
              returnsNormally,
            );
            expect(() => NavigationUtils.isValidDeepLink(url), returnsNormally);
            expect(NavigationUtils.extractGamePinFromUrl(url), isNull);
          }
        },
      );

      testCase('should handle extreme values correctly', TestCategory.unit, () {
        // TDD RED: Test boundary conditions
        // Extremely long strings
        final longString = 'x' * 10000;
        expect(
          () => NavigationUtils.isValidQuizId(longString),
          returnsNormally,
        );
        expect(
          () => NavigationUtils.isValidSessionId(longString),
          returnsNormally,
        );

        // Large numbers
        expect(NavigationUtils.isValidQuestionIndex(999999), isTrue);
        expect(NavigationUtils.isValidQuestionIndex(-999999), isFalse);

        // Unicode and special characters
        expect(NavigationUtils.isValidQuizId('quiz-中文-123'), isTrue);
        expect(NavigationUtils.isValidQuizId('quiz-🎮-123'), isTrue);
        expect(() => NavigationUtils.isAuthRoute('/路径/测试'), returnsNormally);
      });
    });
  });
}
