import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_constants.dart';

/// Abstract base class for route guards
abstract class RouteGuard {
  const RouteGuard();

  /// Check if user can access the route
  /// Returns null if access is allowed, otherwise returns redirect route
  Future<String?> canActivate(BuildContext context, GoRouterState state);
}

/// Authentication guard to protect routes that require login
class AuthGuard extends RouteGuard {
  const AuthGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    // TODO: Implement actual authentication check
    // For now, return null to allow access during development

    // Example implementation:
    // final container = ProviderScope.containerOf(context);
    // final authState = container.read(authProvider);
    //
    // if (authState.isAuthenticated) {
    //   return null; // Allow access
    // } else {
    //   return RouteConstants.login; // Redirect to login
    // }

    return null;
  }
}

/// Guest guard to redirect authenticated users away from auth pages
class GuestGuard extends RouteGuard {
  const GuestGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    // TODO: Implement actual authentication check
    // For now, return null to allow access during development

    // Example implementation:
    // final container = ProviderScope.containerOf(context);
    // final authState = container.read(authProvider);
    //
    // if (authState.isAuthenticated) {
    //   return RouteConstants.home; // Redirect to home if already authenticated
    // } else {
    //   return null; // Allow access to auth pages
    // }

    return null;
  }
}

/// Game session guard to validate session access
class GameSessionGuard extends RouteGuard {
  const GameSessionGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    final sessionId = state.pathParameters['sessionId'];

    if (sessionId == null || sessionId.isEmpty) {
      return RouteConstants.gameJoin; // Redirect to join game if no session ID
    }

    // TODO: Implement session validation
    // Example implementation:
    // final container = ProviderScope.containerOf(context);
    // final gameSessionState = container.read(gameSessionProvider(sessionId));
    //
    // if (gameSessionState.exists && gameSessionState.isActive) {
    //   return null; // Allow access
    // } else {
    //   return RouteConstants.gameJoin; // Redirect if session doesn't exist
    // }

    return null;
  }
}

/// Quiz ownership guard to validate quiz editing permissions
class QuizOwnershipGuard extends RouteGuard {
  const QuizOwnershipGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    final quizId = state.pathParameters['quizId'];

    if (quizId == null || quizId.isEmpty) {
      return RouteConstants.home; // Redirect to home if no quiz ID
    }

    // TODO: Implement ownership validation
    // Example implementation:
    // final container = ProviderScope.containerOf(context);
    // final authState = container.read(authProvider);
    // final quiz = await container.read(quizProvider(quizId).future);
    //
    // if (quiz != null && quiz.createdBy == authState.user?.id) {
    //   return null; // Allow access if user owns the quiz
    // } else {
    //   return RouteConstants.quizDetailsPath(quizId); // Redirect to view only
    // }

    return null;
  }
}

/// Host guard to validate game hosting permissions
class GameHostGuard extends RouteGuard {
  const GameHostGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    // TODO: Implement host permission validation
    // Example implementation:
    // final container = ProviderScope.containerOf(context);
    // final authState = container.read(authProvider);
    //
    // if (authState.user?.canHostGames == true) {
    //   return null; // Allow access
    // } else {
    //   return RouteConstants.home; // Redirect if user cannot host
    // }

    return null;
  }
}

/// Admin guard for administrative routes
class AdminGuard extends RouteGuard {
  const AdminGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    // TODO: Implement admin permission validation
    // Example implementation:
    // final container = ProviderScope.containerOf(context);
    // final authState = container.read(authProvider);
    //
    // if (authState.user?.isAdmin == true) {
    //   return null; // Allow access
    // } else {
    //   return RouteConstants.home; // Redirect if not admin
    // }

    return null;
  }
}

/// Guard registry for managing multiple guards per route
class GuardRegistry {
  static const Map<String, List<RouteGuard>> _routeGuards = {
    // Authentication routes - only for guests
    RouteConstants.login: [GuestGuard()],
    RouteConstants.register: [GuestGuard()],
    RouteConstants.forgotPassword: [GuestGuard()],

    // Protected routes - require authentication
    RouteConstants.profile: [AuthGuard()],
    RouteConstants.dashboard: [AuthGuard()],
    RouteConstants.quizCreation: [AuthGuard()],
    RouteConstants.quizCreationForm: [AuthGuard()],
    RouteConstants.quizCreationPreview: [AuthGuard()],
    RouteConstants.quizCreationPublish: [AuthGuard()],
    RouteConstants.settings: [AuthGuard()],

    // Quiz editing - require authentication and ownership
    '/quiz/:quizId/edit': [AuthGuard(), QuizOwnershipGuard()],

    // Game hosting - require authentication and host permissions
    RouteConstants.gameHost: [AuthGuard(), GameHostGuard()],
    RouteConstants.gameHostSetup: [AuthGuard(), GameHostGuard()],

    // Game session routes - require session validation
    '/game/:sessionId': [GameSessionGuard()],
    '/game/:sessionId/waiting': [GameSessionGuard()],
    '/game/:sessionId/question/:questionIndex': [GameSessionGuard()],
    '/game/:sessionId/results': [GameSessionGuard()],
  };

  /// Get guards for a specific route
  static List<RouteGuard> getGuards(String route) {
    return _routeGuards[route] ?? [];
  }

  /// Check all guards for a route
  static Future<String?> checkRouteAccess(
    BuildContext context,
    GoRouterState state,
  ) async {
    final guards = getGuards(state.matchedLocation);

    for (final guard in guards) {
      final redirectRoute = await guard.canActivate(context, state);
      if (redirectRoute != null) {
        return redirectRoute; // Return first redirect found
      }
    }

    return null; // No redirect needed
  }
}
