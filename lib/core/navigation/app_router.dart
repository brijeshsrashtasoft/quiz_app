import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_constants.dart';
import 'route_guards.dart';
import 'pages/placeholder_pages.dart';

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

    // Global redirect logic
    redirect: (BuildContext context, GoRouterState state) async {
      // Check route guards
      final redirectRoute = await GuardRegistry.checkRouteAccess(
        context,
        state,
      );
      return redirectRoute;
    },

    // Error handling
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),

    // Route definitions
    routes: [
      // Splash screen
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
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
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
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
        builder: (context, state) => const HomePage(),
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
        builder: (context, state) => const QuizCreationPage(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'quiz-creation-form',
            builder: (context, state) => const QuizCreationFormPage(),
          ),
          GoRoute(
            path: 'preview',
            name: 'quiz-creation-preview',
            builder: (context, state) => const QuizCreationPreviewPage(),
          ),
          GoRoute(
            path: 'publish',
            name: 'quiz-creation-publish',
            builder: (context, state) => const QuizCreationPublishPage(),
          ),
        ],
      ),

      // Quiz details and editing
      GoRoute(
        path: '/quiz/:quizId',
        name: 'quiz-details',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return QuizDetailsPage(quizId: quizId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'quiz-edit',
            builder: (context, state) {
              final quizId = state.pathParameters['quizId']!;
              return QuizEditPage(quizId: quizId);
            },
          ),
        ],
      ),

      // Game session routes
      GoRoute(
        path: RouteConstants.gameJoin,
        name: 'game-join',
        builder: (context, state) => const GameJoinPage(),
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
          final sessionId = state.pathParameters['sessionId']!;
          return GameSessionPage(sessionId: sessionId);
        },
        routes: [
          GoRoute(
            path: 'waiting',
            name: 'game-waiting',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
              return GameWaitingPage(sessionId: sessionId);
            },
          ),
          GoRoute(
            path: 'question/:questionIndex',
            name: 'game-question',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
              final questionIndex = state.pathParameters['questionIndex']!;
              return GameQuestionPage(
                sessionId: sessionId,
                questionIndex: questionIndex,
              );
            },
          ),
          GoRoute(
            path: 'results',
            name: 'game-results',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
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
              final sessionId = state.pathParameters['sessionId']!;
              return SessionLeaderboardPage(sessionId: sessionId);
            },
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
        builder: (context, state) => const NotFoundPage(),
      ),
      GoRoute(
        path: RouteConstants.error,
        name: 'error',
        builder: (context, state) => const ErrorPage(),
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

/// Custom page transitions
class CustomPageTransition {
  static Page<T> slideTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
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

  static Page<T> fadeTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    Curve curve = Curves.easeInOut,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  static Page<T> scaleTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
      },
    );
  }
}
