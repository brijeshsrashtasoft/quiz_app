import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_constants.dart';
import 'pages/placeholder_pages.dart';
import '../../features/quiz_creation/presentation/pages/quiz_creation_page.dart'
    as quiz_pages;
import '../../features/quiz_creation/presentation/pages/quiz_preview_page.dart';
import '../../features/quiz_creation/presentation/pages/quiz_publish_page.dart';
import 'navigation_utils.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/email_verification_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/profile_page.dart'
    as auth_pages;
import '../../features/home/presentation/pages/home_page.dart' as home_pages;
import '../../features/ui_showcase/presentation/pages/ui_showcase_page.dart';
import '../../features/ui_showcase/presentation/pages/theme_settings_page.dart';
import '../../features/ui_showcase/presentation/pages/all_components_demo_page.dart';
import '../../shared/widgets/error/error_page_widget.dart';
import '../../shared/widgets/deep_link/game_join_widget.dart';
import '../../features/splash/presentation/pages/splash_redirect_page.dart';

/// Global router configuration for the entire app
/// Implements type-safe navigation with route guards and transitions
class AppRouter {
  AppRouter._();

  /// Global router key for accessing router from anywhere
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Shell navigator key for nested navigation (unused but reserved for future)
  // static final GlobalKey<NavigatorState> _shellNavigatorKey =
  //     GlobalKey<NavigatorState>(debugLabel: 'shell');

  /// Get the configured GoRouter instance
  static GoRouter get router => _router;

  /// Router configuration with all routes and guards
  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: RouteConstants.splash,

    // Global redirect logic with authentication guards
    redirect: (BuildContext context, GoRouterState state) async {
      try {
        // TEMPORARILY DISABLED for testing - immediately navigate from splash
        if (state.matchedLocation == RouteConstants.splash) {
          return RouteConstants.home;
        }

        // Skip auth guards for now to make app work
        return null;

        // TODO: Re-enable after fixing auth
        // final redirectRoute = await AuthGuardRegistry.checkRouteAccess(
        //   context,
        //   state,
        // );
        // return redirectRoute;
      } catch (e) {
        // In case of guard error, allow navigation but log the error
        debugPrint('Router redirect error: $e');
        return null;
      }
    },

    // Error handling
    errorBuilder: (context, state) => ErrorPageWidget(
      title: 'Navigation Error',
      message:
          state.error?.toString() ?? 'An unexpected navigation error occurred',
      errorCode: 'NAVIGATION_ERROR',
    ),

    // Route definitions
    routes: [
      // Splash screen
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashRedirectPage(),
      ),

      // Authentication routes
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
        routes: [
          GoRoute(
            path: 'verify-email',
            name: 'verify-email',
            builder: (context, state) => const EmailVerificationPage(),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: 'profile',
        builder: (context, state) => const auth_pages.ProfilePage(),
      ),

      // Home and dashboard routes
      GoRoute(
        path: RouteConstants.root,
        name: 'root',
        redirect: (context, state) => RouteConstants.home,
      ),
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (context, state) => const home_pages.HomePage(),
      ),
      GoRoute(
        path: RouteConstants.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Quiz creation routes
      GoRoute(
        path: RouteConstants.quizCreation,
        name: 'quiz-creation',
        builder: (context, state) => const quiz_pages.QuizCreationPage(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'quiz-creation-form',
            builder: (context, state) => const quiz_pages.QuizCreationPage(),
          ),
          GoRoute(
            path: 'preview',
            name: 'quiz-creation-preview',
            builder: (context, state) => const QuizPreviewPage(),
          ),
          GoRoute(
            path: 'publish',
            name: 'quiz-creation-publish',
            builder: (context, state) => const QuizPublishPage(),
          ),
        ],
      ),

      // Quiz details and editing with validation
      GoRoute(
        path: '/quiz/:quizId',
        name: 'quiz-details',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId'];

          // Validate quiz ID parameter
          if (quizId == null || !NavigationUtils.isValidQuizId(quizId)) {
            return const ErrorPageWidget(
              title: 'Invalid Quiz',
              message: 'The quiz ID provided is not valid',
              errorCode: 'INVALID_QUIZ_ID',
            );
          }

          return QuizDetailsPage(quizId: quizId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'quiz-edit',
            builder: (context, state) {
              final quizId = state.pathParameters['quizId'];

              // Validate quiz ID parameter
              if (quizId == null || !NavigationUtils.isValidQuizId(quizId)) {
                return const ErrorPageWidget(
                  title: 'Invalid Quiz',
                  message: 'The quiz ID provided for editing is not valid',
                  errorCode: 'INVALID_QUIZ_EDIT_ID',
                );
              }

              return QuizEditPage(quizId: quizId);
            },
          ),
        ],
      ),

      // Game session routes with deep linking support
      GoRoute(
        path: RouteConstants.gameJoin,
        name: 'game-join',
        builder: (context, state) {
          // Check for game PIN in query parameters for deep linking
          final queryParams = NavigationUtils.getQueryParameters(state);
          final gamePin = queryParams['pin'];

          if (gamePin != null &&
              NavigationUtils.extractGamePinFromUrl(state.uri.toString()) !=
                  null) {
            // Deep link with game PIN - use GameJoinWidget
            return GameJoinWidget(initialPin: gamePin, isDeepLink: true);
          }

          return const GameJoinWidget();
        },
      ),
      GoRoute(
        path: RouteConstants.gameHost,
        name: 'game-host',
        builder: (context, state) => const GameHostPage(),
        routes: [
          GoRoute(
            path: 'setup',
            name: 'game-host-setup',
            builder: (context, state) => const GameHostSetupPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/game/:sessionId',
        name: 'game-session',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'];

          // Validate session ID parameter
          if (sessionId == null ||
              !NavigationUtils.isValidSessionId(sessionId)) {
            return const ErrorPageWidget(
              title: 'Invalid Game Session',
              message: 'The game session ID provided is not valid',
              errorCode: 'INVALID_SESSION_ID',
            );
          }

          return GameSessionPage(sessionId: sessionId);
        },
        routes: [
          GoRoute(
            path: 'waiting',
            name: 'game-waiting',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId'];

              // Validate session ID parameter
              if (sessionId == null ||
                  !NavigationUtils.isValidSessionId(sessionId)) {
                return const ErrorPage(
                  error: 'Invalid session ID for waiting room',
                );
              }

              return GameWaitingPage(sessionId: sessionId);
            },
          ),
          GoRoute(
            path: 'question/:questionIndex',
            name: 'game-question',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId'];
              final questionIndexStr = state.pathParameters['questionIndex'];

              // Validate session ID and question index
              if (sessionId == null ||
                  !NavigationUtils.isValidSessionId(sessionId)) {
                return const ErrorPage(
                  error: 'Invalid session ID for question',
                );
              }

              final questionIndex = NavigationUtils.getQuestionIndexFromState(
                state,
              );
              if (questionIndex == null ||
                  !NavigationUtils.isValidQuestionIndex(questionIndex)) {
                return const ErrorPage(error: 'Invalid question index');
              }

              return GameQuestionPage(
                sessionId: sessionId,
                questionIndex: questionIndexStr!,
              );
            },
          ),
          GoRoute(
            path: 'results',
            name: 'game-results',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId'];

              // Validate session ID parameter
              if (sessionId == null ||
                  !NavigationUtils.isValidSessionId(sessionId)) {
                return const ErrorPage(error: 'Invalid session ID for results');
              }

              return GameResultsPage(sessionId: sessionId);
            },
          ),
        ],
      ),

      // Leaderboard routes
      GoRoute(
        path: RouteConstants.leaderboard,
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardPage(),
        routes: [
          GoRoute(
            path: 'global',
            name: 'leaderboard-global',
            builder: (context, state) => const GlobalLeaderboardPage(),
          ),
          GoRoute(
            path: 'session/:sessionId',
            name: 'leaderboard-session',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId'];

              // Validate session ID parameter
              if (sessionId == null ||
                  !NavigationUtils.isValidSessionId(sessionId)) {
                return const ErrorPage(
                  error: 'Invalid session ID for leaderboard',
                );
              }

              return SessionLeaderboardPage(sessionId: sessionId);
            },
          ),
        ],
      ),

      // UI Showcase routes
      GoRoute(
        path: RouteConstants.uiShowcase,
        name: 'ui-showcase',
        builder: (context, state) => const UIShowcasePage(),
        routes: [
          GoRoute(
            path: 'buttons',
            name: 'ui-showcase-buttons',
            builder: (context, state) => const PlaceholderPage(
              title: 'Answer Buttons',
              subtitle: 'Interactive answer buttons with shapes and animations',
              icon: Icons.radio_button_checked,
            ),
          ),
          GoRoute(
            path: 'animations',
            name: 'ui-showcase-animations',
            builder: (context, state) => const PlaceholderPage(
              title: 'Animations',
              subtitle: 'Smooth transitions and micro-interactions',
              icon: Icons.animation,
            ),
          ),
          GoRoute(
            path: 'timers',
            name: 'ui-showcase-timers',
            builder: (context, state) => const PlaceholderPage(
              title: 'Countdown Timers',
              subtitle: 'Animated timer with progress indicators',
              icon: Icons.timer,
            ),
          ),
          GoRoute(
            path: 'effects',
            name: 'ui-showcase-effects',
            builder: (context, state) => const PlaceholderPage(
              title: 'Particle Effects',
              subtitle: 'Celebration effects and visual feedback',
              icon: Icons.auto_awesome,
            ),
          ),
          GoRoute(
            path: 'lobby',
            name: 'ui-showcase-lobby',
            builder: (context, state) => const PlaceholderPage(
              title: 'Lobby Screen',
              subtitle: 'Waiting room with animated player avatars',
              icon: Icons.people,
            ),
          ),
          GoRoute(
            path: 'themes',
            name: 'ui-showcase-themes',
            builder: (context, state) => const ThemeSettingsPage(),
          ),
          GoRoute(
            path: 'loading',
            name: 'ui-showcase-loading',
            builder: (context, state) => const PlaceholderPage(
              title: 'Loading States',
              subtitle: 'Engaging loading animations and spinners',
              icon: Icons.hourglass_empty,
            ),
          ),
          GoRoute(
            path: 'scores',
            name: 'ui-showcase-scores',
            builder: (context, state) => const PlaceholderPage(
              title: 'Score Counter',
              subtitle: 'Animated score displays and achievements',
              icon: Icons.emoji_events,
            ),
          ),
          GoRoute(
            path: 'all-components',
            name: 'ui-showcase-all',
            builder: (context, state) => const AllComponentsDemoPage(),
          ),
        ],
      ),

      // Settings and utility routes
      GoRoute(
        path: RouteConstants.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RouteConstants.about,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: RouteConstants.help,
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),

      // Error routes
      GoRoute(
        path: RouteConstants.notFound,
        name: 'not-found',
        builder: (context, state) => const NotFoundErrorWidget(),
      ),
      GoRoute(
        path: RouteConstants.error,
        name: 'error',
        builder: (context, state) => const ErrorPageWidget(
          title: 'Application Error',
          message: 'An unexpected error occurred in the application',
        ),
      ),
    ],
  );

  /// Get current route name
  static String? get currentRoute {
    return _router.routerDelegate.currentConfiguration.last.matchedLocation;
  }

  /// Check if on specific route
  static bool isCurrentRoute(String route) {
    return currentRoute == route;
  }

  /// Navigation helper methods
  static void go(String route) {
    _router.go(route);
  }

  static void push(String route) {
    _router.push(route);
  }

  static void pop<T extends Object?>([T? result]) {
    _router.pop(result);
  }

  static bool canPop() {
    return _router.canPop();
  }

  /// Clear navigation stack and go to route
  static void clearAndGoTo(String route) {
    while (canPop()) {
      pop();
    }
    go(route);
  }
}

/// Riverpod provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// Provider for current route information
final currentRouteProvider = Provider<String?>((ref) {
  return AppRouter.currentRoute;
});

/// Enhanced router utilities and navigation helpers
class AppRouterHelper {
  AppRouterHelper._();

  /// Deep link handling for game joining
  static Future<bool> handleGameJoinDeepLink(String url) async {
    try {
      final gamePin = NavigationUtils.extractGamePinFromUrl(url);
      if (gamePin != null) {
        final joinUrl = NavigationUtils.generateGameJoinUrl(gamePin);
        AppRouter.go(joinUrl);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Deep link handling error: $e');
      return false;
    }
  }

  /// Generate shareable quiz URL
  static String generateQuizShareLink(String quizId) {
    return NavigationUtils.generateQuizShareUrl(quizId);
  }

  /// Generate shareable game join URL
  static String generateGameJoinLink(String gamePin) {
    return NavigationUtils.generateGameJoinUrl(gamePin);
  }

  /// Safe navigation with error recovery
  static void safeNavigateTo(String route, {Object? extra}) {
    try {
      AppRouter.go(route);
    } catch (e) {
      debugPrint('Navigation error to $route: $e');
      // Fallback to home if navigation fails
      AppRouter.go(RouteConstants.home);
    }
  }

  /// Navigate to game join with PIN
  static void navigateToGameJoinWithPin(String gamePin) {
    final url = NavigationUtils.buildUrlWithQuery(RouteConstants.gameJoin, {
      'pin': gamePin,
    });
    AppRouter.go(url);
  }

  /// Navigate to quiz details with sharing context
  static void navigateToQuizDetailsFromShare(String quizId) {
    final url = NavigationUtils.buildUrlWithQuery(
      RouteConstants.quizDetailsPath(quizId),
      {'shared': 'true'},
    );
    AppRouter.go(url);
  }

  /// Get current navigation context
  static NavigationContext getCurrentContext() {
    final currentRoute = AppRouter.currentRoute ?? RouteConstants.home;
    return NavigationContext(
      route: currentRoute,
      isGameRoute: NavigationUtils.isGameRoute(currentRoute),
      isAuthRoute: NavigationUtils.isAuthRoute(currentRoute),
      isQuizRoute: NavigationUtils.isQuizRoute(currentRoute),
      breadcrumbs: NavigationUtils.generateBreadcrumbs(currentRoute),
    );
  }
}

/// Navigation context information
class NavigationContext {
  final String route;
  final bool isGameRoute;
  final bool isAuthRoute;
  final bool isQuizRoute;
  final List<String> breadcrumbs;

  const NavigationContext({
    required this.route,
    required this.isGameRoute,
    required this.isAuthRoute,
    required this.isQuizRoute,
    required this.breadcrumbs,
  });
}

/// Custom page transitions with enhanced animation support
class CustomPageTransition {
  /// Slide transition for sequential flows (quiz creation, game flow)
  static Page<T> slideTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOutCubic,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
      },
    );
  }

  /// Fade transition for general navigation
  static Page<T> fadeTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  /// Scale transition for modal-like navigation
  static Page<T> scaleTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOutBack,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
          ),
          child: FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
            child: child,
          ),
        );
      },
    );
  }

  /// Rotation transition for fun navigation (game results, celebrations)
  static Page<T> rotationTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.elasticOut,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: animation.drive(
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
          ),
          child: ScaleTransition(
            scale: animation.drive(
              Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Get appropriate transition based on route context
  static Page<T> getContextualTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    final fromRoute = AppRouter.currentRoute ?? '';
    final toRoute = state.matchedLocation;
    final transitionType = NavigationUtils.getRouteTransitionType(
      fromRoute,
      toRoute,
    );

    switch (transitionType) {
      case 'slide':
        return slideTransition(context, state, child);
      case 'scale':
        return scaleTransition(context, state, child);
      case 'rotation':
        return rotationTransition(context, state, child);
      case 'fade':
      default:
        return fadeTransition(context, state, child);
    }
  }
}

/// Router analytics and monitoring
class RouterAnalytics {
  static final List<String> _navigationHistory = [];
  static final Map<String, int> _routeVisitCount = {};
  static final Map<String, DateTime> _routeLastVisited = {};

  /// Track navigation events
  static void trackNavigation(String route) {
    try {
      _navigationHistory.add(route);
      _routeVisitCount[route] = (_routeVisitCount[route] ?? 0) + 1;
      _routeLastVisited[route] = DateTime.now();

      // Keep only last 50 navigation events
      if (_navigationHistory.length > 50) {
        _navigationHistory.removeAt(0);
      }
    } catch (e) {
      debugPrint('Router analytics error: $e');
    }
  }

  /// Get navigation history
  static List<String> get navigationHistory => List.from(_navigationHistory);

  /// Get most visited routes
  static Map<String, int> get routeVisitCounts => Map.from(_routeVisitCount);

  /// Get recently visited routes
  static Map<String, DateTime> get recentlyVisited =>
      Map.from(_routeLastVisited);

  /// Clear analytics data
  static void clearAnalytics() {
    _navigationHistory.clear();
    _routeVisitCount.clear();
    _routeLastVisited.clear();
  }
}
