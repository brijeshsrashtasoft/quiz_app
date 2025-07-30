import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_constants.dart';

/// Utility class for navigation operations and URL parsing
class NavigationUtils {
  NavigationUtils._();

  /// Parse quiz ID from route parameters
  static String? getQuizIdFromState(GoRouterState state) {
    return state.pathParameters['quizId'];
  }

  /// Parse session ID from route parameters
  static String? getSessionIdFromState(GoRouterState state) {
    return state.pathParameters['sessionId'];
  }

  /// Parse question index from route parameters
  static int? getQuestionIndexFromState(GoRouterState state) {
    final indexStr = state.pathParameters['questionIndex'];
    return indexStr != null ? int.tryParse(indexStr) : null;
  }

  /// Get query parameters from current state
  static Map<String, String> getQueryParameters(GoRouterState state) {
    return state.uri.queryParameters;
  }

  /// Build URL with query parameters
  static String buildUrlWithQuery(
    String path,
    Map<String, String> queryParams,
  ) {
    if (queryParams.isEmpty) return path;

    final uri = Uri.parse(path);
    final newUri = uri.replace(queryParameters: queryParams);
    return newUri.toString();
  }

  /// Validate route parameters
  static bool isValidQuizId(String? quizId) {
    return quizId != null && quizId.isNotEmpty && quizId.length >= 6;
  }

  static bool isValidSessionId(String? sessionId) {
    return sessionId != null && sessionId.isNotEmpty && sessionId.length >= 6;
  }

  static bool isValidQuestionIndex(int? index) {
    return index != null && index >= 0;
  }

  /// Deep link handling utilities
  static String? extractGamePinFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // Check for game PIN in query parameters
    final pin = uri.queryParameters['pin'];
    if (pin != null && pin.length == 6) {
      return pin;
    }

    // Check for game PIN in path segments
    final segments = uri.pathSegments;
    if (segments.contains('game') && segments.length > 1) {
      final index = segments.indexOf('game');
      if (index + 1 < segments.length) {
        final potentialPin = segments[index + 1];
        if (potentialPin.length == 6 && int.tryParse(potentialPin) != null) {
          return potentialPin;
        }
      }
    }

    return null;
  }

  /// Generate shareable URLs
  static String generateQuizShareUrl(String quizId, {String? baseUrl}) {
    final base = baseUrl ?? 'https://quizapp.com';
    return '$base${RouteConstants.quizDetailsPath(quizId)}';
  }

  static String generateGameJoinUrl(String gamePin, {String? baseUrl}) {
    final base = baseUrl ?? 'https://quizapp.com';
    return '$base${RouteConstants.gameJoin}?pin=$gamePin';
  }

  static String generateLeaderboardShareUrl(
    String sessionId, {
    String? baseUrl,
  }) {
    final base = baseUrl ?? 'https://quizapp.com';
    return '$base${RouteConstants.leaderboardSessionPath(sessionId)}';
  }

  /// Route matching utilities
  static bool isAuthRoute(String route) {
    return route == RouteConstants.login ||
        route == RouteConstants.register ||
        route == RouteConstants.forgotPassword;
  }

  static bool isGameRoute(String route) {
    return route.startsWith('/game');
  }

  static bool isQuizRoute(String route) {
    return route.startsWith('/quiz') || route.startsWith('/quiz-creation');
  }

  static bool isLeaderboardRoute(String route) {
    return route.startsWith('/leaderboard');
  }

  /// Navigation state helpers
  static bool canGoBack(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  static void goBackOrHome(BuildContext context) {
    if (canGoBack(context)) {
      GoRouter.of(context).pop();
    } else {
      GoRouter.of(context).go(RouteConstants.home);
    }
  }

  /// Safe navigation with error handling
  static void safeNavigate(
    BuildContext context,
    String route, {
    Object? extra,
    VoidCallback? onError,
  }) {
    try {
      GoRouter.of(context).go(route, extra: extra);
    } catch (e) {
      debugPrint('Navigation error: $e');
      onError?.call();
    }
  }

  static void safePush(
    BuildContext context,
    String route, {
    Object? extra,
    VoidCallback? onError,
  }) {
    try {
      GoRouter.of(context).push(route, extra: extra);
    } catch (e) {
      debugPrint('Navigation error: $e');
      onError?.call();
    }
  }

  /// Route transition helpers
  static String getRouteTransitionType(String fromRoute, String toRoute) {
    // Authentication transitions
    if (isAuthRoute(fromRoute) && isAuthRoute(toRoute)) {
      return 'slide';
    }

    // Game flow transitions
    if (isGameRoute(fromRoute) && isGameRoute(toRoute)) {
      return 'slide';
    }

    // Quiz creation flow transitions
    if (toRoute.startsWith('/quiz-creation')) {
      return 'slide';
    }

    // Default transition
    return 'fade';
  }

  /// Breadcrumb utilities
  static List<String> generateBreadcrumbs(String currentRoute) {
    final breadcrumbs = <String>[];

    if (currentRoute.startsWith('/quiz-creation')) {
      breadcrumbs.add('Quiz Creation');
      if (currentRoute.contains('form')) {
        breadcrumbs.add('Form');
      } else if (currentRoute.contains('preview')) {
        breadcrumbs.add('Preview');
      } else if (currentRoute.contains('publish')) {
        breadcrumbs.add('Publish');
      }
    } else if (currentRoute.startsWith('/game')) {
      breadcrumbs.add('Game');
      if (currentRoute.contains('waiting')) {
        breadcrumbs.add('Waiting');
      } else if (currentRoute.contains('question')) {
        breadcrumbs.add('Question');
      } else if (currentRoute.contains('results')) {
        breadcrumbs.add('Results');
      }
    } else if (currentRoute.startsWith('/leaderboard')) {
      breadcrumbs.add('Leaderboard');
      if (currentRoute.contains('global')) {
        breadcrumbs.add('Global');
      } else if (currentRoute.contains('session')) {
        breadcrumbs.add('Session');
      }
    }

    return breadcrumbs;
  }

  /// Analytics and tracking helpers
  static Map<String, dynamic> getRouteAnalyticsData(GoRouterState state) {
    return {
      'route': state.matchedLocation,
      'path_parameters': state.pathParameters,
      'query_parameters': state.uri.queryParameters,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// URL validation
  static bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Route comparison utilities
  static bool isSameRoute(String route1, String route2) {
    // Remove query parameters for comparison
    final uri1 = Uri.parse(route1);
    final uri2 = Uri.parse(route2);
    return uri1.path == uri2.path;
  }

  static bool isChildRoute(String parentRoute, String childRoute) {
    return childRoute.startsWith(parentRoute) && childRoute != parentRoute;
  }

  /// Navigation timing utilities
  static void delayedNavigation(
    BuildContext context,
    String route,
    Duration delay, {
    Object? extra,
  }) {
    Future.delayed(delay, () {
      if (context.mounted) {
        GoRouter.of(context).go(route, extra: extra);
      }
    });
  }

  /// Error recovery navigation
  static void recoverFromNavigationError(BuildContext context) {
    // Try to go to home, if that fails go to root
    try {
      GoRouter.of(context).go(RouteConstants.home);
    } catch (e) {
      try {
        GoRouter.of(context).go(RouteConstants.root);
      } catch (e) {
        debugPrint('Critical navigation error: $e');
      }
    }
  }
}
