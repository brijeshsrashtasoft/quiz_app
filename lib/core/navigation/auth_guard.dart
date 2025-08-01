import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_constants.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/domain/entities/user_entity.dart';
import '../../features/game_session/data/datasources/game_session_firestore_datasource.dart';
import '../../features/game_session/data/models/game_session_model.dart';
import '../../features/quiz_creation/data/datasources/quiz_firestore_datasource.dart';

/// Authentication guard interface for route protection
abstract class AuthGuardInterface {
  /// Check if user can access the route
  /// Returns null if access is allowed, otherwise returns redirect route
  Future<String?> canActivate(BuildContext context, GoRouterState state);
}

/// Main authentication guard implementation
class AuthGuard implements AuthGuardInterface {
  const AuthGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    try {
      // Get ProviderContainer from context
      final container = ProviderScope.containerOf(context);

      // Check current auth state
      final authStateAsync = container.read(authStateProvider);

      return authStateAsync.when(
        data: (authState) => authState.when(
          authenticated: (user) {
            debugPrint('AuthGuard: User authenticated: ${user.email}');
            return null; // Allow access
          },
          unauthenticated: () {
            debugPrint(
              'AuthGuard: User not authenticated, redirecting to login',
            );
            return RouteConstants.login;
          },
          loading: () {
            debugPrint('AuthGuard: Auth state loading, redirecting to splash');
            return RouteConstants.splash;
          },
          error: (message, code) {
            debugPrint('AuthGuard: Auth error: $message, redirecting to login');
            return RouteConstants.login;
          },
        ),
        loading: () {
          debugPrint('AuthGuard: Auth state loading, redirecting to splash');
          return RouteConstants.splash;
        },
        error: (error, stackTrace) {
          debugPrint(
            'AuthGuard: Auth async error: $error, redirecting to login',
          );
          return RouteConstants.login;
        },
      );
    } catch (e) {
      // In case of any error, redirect to login for safety
      debugPrint('AuthGuard error: $e');
      return RouteConstants.login;
    }
  }
}

/// Guest guard to redirect authenticated users away from auth pages
class GuestGuard implements AuthGuardInterface {
  const GuestGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    try {
      final container = ProviderScope.containerOf(context);

      // Check current auth state
      final authStateAsync = container.read(authStateProvider);

      return authStateAsync.when(
        data: (authState) => authState.when(
          authenticated: (user) {
            debugPrint(
              'GuestGuard: User already authenticated, redirecting to home',
            );
            return RouteConstants.home; // Redirect authenticated users to home
          },
          unauthenticated: () {
            debugPrint(
              'GuestGuard: User not authenticated, allowing access to auth pages',
            );
            return null; // Allow access to auth pages
          },
          loading: () {
            debugPrint('GuestGuard: Auth state loading, allowing access');
            return null; // Allow access while loading
          },
          error: (message, code) {
            debugPrint('GuestGuard: Auth error, allowing access');
            return null; // Allow access on error
          },
        ),
        loading: () {
          debugPrint('GuestGuard: Auth state loading, allowing access');
          return null; // Allow access while loading
        },
        error: (error, stackTrace) {
          debugPrint('GuestGuard: Auth async error, allowing access');
          return null; // Allow access on error
        },
      );
    } catch (e) {
      debugPrint('GuestGuard error: $e');
      return null; // Allow access in case of error
    }
  }
}

/// Session validation guard for game routes
class SessionGuard implements AuthGuardInterface {
  const SessionGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    final sessionId = state.pathParameters['sessionId'];

    // Validate session ID parameter
    if (sessionId == null || sessionId.isEmpty || sessionId.length < 6) {
      debugPrint('SessionGuard: Invalid session ID parameter');
      return RouteConstants.gameJoin;
    }

    try {
      final container = ProviderScope.containerOf(context);

      // First check if user is authenticated
      final authStateAsync = container.read(authStateProvider);

      final authRedirect = authStateAsync.when(
        data: (authState) => authState.when(
          authenticated: (_) => null, // Allow access if authenticated
          unauthenticated: () => RouteConstants.login,
          loading: () => RouteConstants.splash,
          error: (_, __) => RouteConstants.login,
        ),
        loading: () => RouteConstants.splash,
        error: (_, __) => RouteConstants.login,
      );

      if (authRedirect != null) {
        debugPrint(
          'SessionGuard: User not authenticated, redirecting to $authRedirect',
        );
        return authRedirect;
      }

      // Validate game session exists and is active using Firestore
      final gameSessionDataSource = GameSessionFirestoreDataSource();
      final sessionResult = await gameSessionDataSource.getGameSessionById(
        sessionId,
      );

      return sessionResult.when(
        success: (session) {
          // Check if session is valid and active
          if (!session.isValid || session.hasExpired) {
            debugPrint(
              'SessionGuard: Session $sessionId is invalid or expired',
            );
            return RouteConstants.gameJoin;
          }

          // Check if user can access this session
          // We know user is authenticated here based on previous check
          final currentUserId = authStateAsync.when(
            data: (authState) => authState.when(
              authenticated: (user) => user.id,
              unauthenticated: () => '',
              loading: () => '',
              error: (_, __) => '',
            ),
            loading: () => '',
            error: (_, __) => '',
          );
          final canAccess =
              session.isHost(currentUserId) ||
              session.isPlayer(currentUserId) ||
              session.status.canJoin;

          if (!canAccess) {
            debugPrint('SessionGuard: User cannot access session $sessionId');
            return RouteConstants.gameJoin;
          }

          debugPrint('SessionGuard: Session $sessionId is valid for user');
          return null; // Allow access
        },
        failure: (error) {
          debugPrint(
            'SessionGuard: Session $sessionId not found: ${error.message}',
          );
          return RouteConstants.gameJoin;
        },
      );
    } catch (e) {
      debugPrint('SessionGuard error for session $sessionId: $e');
      return RouteConstants.gameJoin;
    }
  }
}

/// Quiz ownership guard for quiz editing routes
class QuizOwnershipGuard implements AuthGuardInterface {
  const QuizOwnershipGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    final quizId = state.pathParameters['quizId'];

    // Validate quiz ID parameter
    if (quizId == null || quizId.isEmpty || quizId.length < 6) {
      debugPrint('QuizOwnershipGuard: Invalid quiz ID parameter');
      return RouteConstants.home;
    }

    try {
      final container = ProviderScope.containerOf(context);

      // First check if user is authenticated
      final authStateAsync = container.read(authStateProvider);

      final authRedirect = authStateAsync.when(
        data: (authState) => authState.when(
          authenticated: (_) => null, // Allow access if authenticated
          unauthenticated: () => RouteConstants.login,
          loading: () => RouteConstants.splash,
          error: (_, __) => RouteConstants.login,
        ),
        loading: () => RouteConstants.splash,
        error: (_, __) => RouteConstants.login,
      );

      if (authRedirect != null) {
        debugPrint(
          'QuizOwnershipGuard: User not authenticated, redirecting to $authRedirect',
        );
        return authRedirect;
      }

      // Validate quiz ownership using Firestore
      final quizDataSource = QuizFirestoreDataSource();
      final quizResult = await quizDataSource.getQuizById(quizId);

      return quizResult.when(
        success: (quiz) {
          // We know user is authenticated here based on previous check
          final currentUserId = authStateAsync.when(
            data: (authState) => authState.when(
              authenticated: (user) => user.id,
              unauthenticated: () => '',
              loading: () => '',
              error: (_, __) => '',
            ),
            loading: () => '',
            error: (_, __) => '',
          );

          // Check if user owns the quiz
          if (quiz.createdBy != currentUserId) {
            debugPrint(
              'QuizOwnershipGuard: User does not own quiz $quizId, redirecting to view-only',
            );
            return RouteConstants.quizDetailsPath(
              quizId,
            ); // Redirect to view-only
          }

          debugPrint(
            'QuizOwnershipGuard: User owns quiz $quizId, allowing edit access',
          );
          return null; // Allow access
        },
        failure: (error) {
          debugPrint(
            'QuizOwnershipGuard: Quiz $quizId not found: ${error.message}',
          );
          return RouteConstants.home;
        },
      );
    } catch (e) {
      debugPrint('QuizOwnershipGuard error for quiz $quizId: $e');
      return RouteConstants.home;
    }
  }
}

/// Host permission guard for game hosting routes
class HostGuard implements AuthGuardInterface {
  const HostGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    try {
      final container = ProviderScope.containerOf(context);

      // Check if user is authenticated
      final authStateAsync = container.read(authStateProvider);

      return authStateAsync.when(
        data: (authState) => authState.when(
          authenticated: (user) {
            // Basic host permission checks
            if (!user.isProfileComplete) {
              debugPrint(
                'HostGuard: User profile incomplete, cannot host games',
              );
              return RouteConstants.profile;
            }

            // For now, allow all authenticated users to host games
            // In the future, this could check for specific permissions or user roles

            debugPrint('HostGuard: User ${user.email} can host games');
            return null; // Allow access
          },
          unauthenticated: () {
            debugPrint(
              'HostGuard: User not authenticated, redirecting to login',
            );
            return RouteConstants.login;
          },
          loading: () {
            debugPrint('HostGuard: Auth state loading, redirecting to splash');
            return RouteConstants.splash;
          },
          error: (message, code) {
            debugPrint('HostGuard: Auth error: $message, redirecting to login');
            return RouteConstants.login;
          },
        ),
        loading: () {
          debugPrint('HostGuard: Auth state loading, redirecting to splash');
          return RouteConstants.splash;
        },
        error: (error, stackTrace) {
          debugPrint(
            'HostGuard: Auth async error: $error, redirecting to login',
          );
          return RouteConstants.login;
        },
      );
    } catch (e) {
      debugPrint('HostGuard error: $e');
      return RouteConstants.home;
    }
  }
}

/// Admin permission guard for administrative routes
class AdminGuard implements AuthGuardInterface {
  const AdminGuard();

  @override
  Future<String?> canActivate(BuildContext context, GoRouterState state) async {
    try {
      final container = ProviderScope.containerOf(context);

      // Check if user is authenticated
      final authStateAsync = container.read(authStateProvider);

      return authStateAsync.when(
        data: (authState) => authState.when(
          authenticated: (user) {
            // Check admin privileges based on email domain or specific user IDs
            // This is a simple implementation - in production, use proper role-based access
            final isAdmin = _checkAdminPrivileges(user.email);

            if (!isAdmin) {
              debugPrint(
                'AdminGuard: User ${user.email} does not have admin privileges',
              );
              return RouteConstants.home;
            }

            debugPrint('AdminGuard: Admin access granted for ${user.email}');
            return null; // Allow access
          },
          unauthenticated: () {
            debugPrint(
              'AdminGuard: User not authenticated, redirecting to login',
            );
            return RouteConstants.login;
          },
          loading: () {
            debugPrint('AdminGuard: Auth state loading, redirecting to splash');
            return RouteConstants.splash;
          },
          error: (message, code) {
            debugPrint(
              'AdminGuard: Auth error: $message, redirecting to login',
            );
            return RouteConstants.login;
          },
        ),
        loading: () {
          debugPrint('AdminGuard: Auth state loading, redirecting to splash');
          return RouteConstants.splash;
        },
        error: (error, stackTrace) {
          debugPrint(
            'AdminGuard: Auth async error: $error, redirecting to login',
          );
          return RouteConstants.login;
        },
      );
    } catch (e) {
      debugPrint('AdminGuard error: $e');
      return RouteConstants.home;
    }
  }

  /// Check if user has admin privileges
  /// In production, this should be replaced with proper role-based access control
  bool _checkAdminPrivileges(String email) {
    // Example admin check - replace with your logic
    const adminEmails = ['admin@quizapp.com', 'support@quizapp.com'];

    // Check against admin email list
    if (adminEmails.contains(email.toLowerCase())) {
      return true;
    }

    // Check against admin domain
    if (email.toLowerCase().endsWith('@quizapp.com')) {
      return true;
    }

    return false;
  }
}

/// Route guard registry for managing guards per route
class AuthGuardRegistry {
  AuthGuardRegistry._();

  /// Route guards mapping
  static const Map<String, List<AuthGuardInterface>> _routeGuards = {
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
    RouteConstants.gameHost: [AuthGuard(), HostGuard()],
    RouteConstants.gameHostSetup: [AuthGuard(), HostGuard()],

    // Game session routes - require session validation
    '/game/:sessionId': [SessionGuard()],
    '/game/:sessionId/waiting': [SessionGuard()],
    '/game/:sessionId/question/:questionIndex': [SessionGuard()],
    '/game/:sessionId/results': [SessionGuard()],
  };

  /// Get guards for a specific route
  static List<AuthGuardInterface> getGuards(String route) {
    // Check exact match first
    if (_routeGuards.containsKey(route)) {
      return _routeGuards[route]!;
    }

    // Check for pattern matches (e.g., routes with parameters)
    for (final pattern in _routeGuards.keys) {
      if (_routeMatches(pattern, route)) {
        return _routeGuards[pattern]!;
      }
    }

    return [];
  }

  /// Check if a route pattern matches a specific route
  static bool _routeMatches(String pattern, String route) {
    // Simple pattern matching for parameter routes
    final patternSegments = pattern.split('/');
    final routeSegments = route.split('/');

    if (patternSegments.length != routeSegments.length) {
      return false;
    }

    for (int i = 0; i < patternSegments.length; i++) {
      final patternSegment = patternSegments[i];
      final routeSegment = routeSegments[i];

      // Skip parameter segments (starting with :)
      if (patternSegment.startsWith(':')) {
        continue;
      }

      // Exact match required for non-parameter segments
      if (patternSegment != routeSegment) {
        return false;
      }
    }

    return true;
  }

  /// Check all guards for a route
  static Future<String?> checkRouteAccess(
    BuildContext context,
    GoRouterState state,
  ) async {
    final guards = getGuards(state.matchedLocation);

    for (final guard in guards) {
      try {
        final redirectRoute = await guard.canActivate(context, state);
        if (redirectRoute != null) {
          return redirectRoute; // Return first redirect found
        }
      } catch (e) {
        debugPrint('Guard execution error: $e');
        // Continue to next guard instead of failing completely
      }
    }

    return null; // No redirect needed
  }

  /// Add custom guard for a route (for dynamic route protection)
  static void addGuard(String route, AuthGuardInterface guard) {
    if (_routeGuards.containsKey(route)) {
      // Create a new list to avoid modifying the const map
      final existingGuards = List<AuthGuardInterface>.from(
        _routeGuards[route]!,
      );
      existingGuards.add(guard);
      // Note: This would require making _routeGuards non-const
      // For now, guards are defined statically above
    }
  }

  /// Remove guard from a route (for dynamic route protection)
  static void removeGuard(String route, AuthGuardInterface guard) {
    if (_routeGuards.containsKey(route)) {
      // Create a new list to avoid modifying the const map
      final existingGuards = List<AuthGuardInterface>.from(
        _routeGuards[route]!,
      );
      existingGuards.remove(guard);
      // Note: This would require making _routeGuards non-const
      // For now, guards are defined statically above
    }
  }

  /// Get all protected routes
  static List<String> get protectedRoutes {
    return _routeGuards.keys.toList();
  }

  /// Check if a route is protected
  static bool isProtected(String route) {
    return getGuards(route).isNotEmpty;
  }

  /// Get guard types for a route (for debugging)
  static List<String> getGuardTypes(String route) {
    return getGuards(
      route,
    ).map((guard) => guard.runtimeType.toString()).toList();
  }
}
