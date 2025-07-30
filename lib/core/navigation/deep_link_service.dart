import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_constants.dart';
import 'navigation_utils.dart';
import 'app_router.dart';

/// Deep link service for handling universal links and custom schemes
/// Supports Android App Links, iOS Universal Links, and Web deep linking
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;

  static const MethodChannel _channel = MethodChannel('deep_link_channel');

  /// Stream controller for deep link events
  final StreamController<DeepLinkData> _deepLinkController =
      StreamController<DeepLinkData>.broadcast();

  /// Stream of deep link events
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// Initialize deep link handling
  Future<void> initialize() async {
    try {
      debugPrint('DeepLinkService: Initializing deep link handling');

      // Set up method channel listener for initial link
      _channel.setMethodCallHandler(_handleMethodCall);

      // Check for initial deep link when app is launched
      await _checkInitialLink();

      debugPrint(
        'DeepLinkService: Deep link handling initialized successfully',
      );
    } catch (e) {
      debugPrint(
        'DeepLinkService: Failed to initialize deep link handling: $e',
      );
    }
  }

  /// Handle method calls from platform
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('DeepLinkService: Received method call: ${call.method}');

    switch (call.method) {
      case 'onDeepLink':
        final String? url = call.arguments as String?;
        if (url != null) {
          await _processDeepLink(url);
        }
        break;
      default:
        debugPrint('DeepLinkService: Unknown method call: ${call.method}');
    }
  }

  /// Check for initial deep link
  Future<void> _checkInitialLink() async {
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        debugPrint('DeepLinkService: Found initial link: $initialLink');
        await _processDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error checking initial link: $e');
    }
  }

  /// Process incoming deep link
  Future<void> _processDeepLink(String url) async {
    try {
      debugPrint('DeepLinkService: Processing deep link: $url');

      final deepLinkData = _parseDeepLink(url);
      if (deepLinkData != null) {
        _deepLinkController.add(deepLinkData);
        await _handleDeepLinkNavigation(deepLinkData);
      } else {
        debugPrint('DeepLinkService: Unable to parse deep link: $url');
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error processing deep link: $e');
    }
  }

  /// Parse deep link URL into structured data
  DeepLinkData? _parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final queryParams = uri.queryParameters;

      debugPrint(
        'DeepLinkService: Parsing URL - Path: $path, Query: $queryParams',
      );

      // Game join deep links
      if (path.startsWith('/game/join') || path == '/game/join') {
        final gamePin = queryParams['pin'];
        if (gamePin != null && gamePin.length == 6) {
          return DeepLinkData(
            type: DeepLinkType.gameJoin,
            route: RouteConstants.gameJoin,
            parameters: {'pin': gamePin},
            originalUrl: url,
          );
        }
      }

      // Game session deep links
      if (path.startsWith('/game/') && path.length > 6) {
        final sessionId = path.substring(6).split('/').first;
        if (NavigationUtils.isValidSessionId(sessionId)) {
          String route = RouteConstants.gameSessionPath(sessionId);

          // Check for specific game subpaths
          if (path.contains('/waiting')) {
            route = RouteConstants.gameWaitingPath(sessionId);
          } else if (path.contains('/question/')) {
            final questionMatch = RegExp(r'/question/(\d+)').firstMatch(path);
            if (questionMatch != null) {
              final questionIndex = int.tryParse(questionMatch.group(1)!);
              if (questionIndex != null) {
                route = RouteConstants.gameQuestionPath(
                  sessionId,
                  questionIndex,
                );
              }
            }
          } else if (path.contains('/results')) {
            route = RouteConstants.gameResultsPath(sessionId);
          }

          return DeepLinkData(
            type: DeepLinkType.gameSession,
            route: route,
            parameters: {'sessionId': sessionId},
            originalUrl: url,
          );
        }
      }

      // Quiz deep links
      if (path.startsWith('/quiz/') && path.length > 6) {
        final pathSegments = path.split('/');
        if (pathSegments.length >= 3) {
          final quizId = pathSegments[2];
          if (NavigationUtils.isValidQuizId(quizId)) {
            String route = RouteConstants.quizDetailsPath(quizId);

            // Check for quiz editing
            if (pathSegments.length > 3 && pathSegments[3] == 'edit') {
              route = RouteConstants.quizEditPath(quizId);
            }

            return DeepLinkData(
              type: DeepLinkType.quiz,
              route: route,
              parameters: {'quizId': quizId},
              originalUrl: url,
              metadata: {'shared': queryParams['shared'] == 'true'},
            );
          }
        }
      }

      // Leaderboard deep links
      if (path.startsWith('/leaderboard')) {
        if (path.contains('/session/')) {
          final sessionMatch = RegExp(r'/session/([^/]+)').firstMatch(path);
          if (sessionMatch != null) {
            final sessionId = sessionMatch.group(1)!;
            if (NavigationUtils.isValidSessionId(sessionId)) {
              return DeepLinkData(
                type: DeepLinkType.leaderboard,
                route: RouteConstants.leaderboardSessionPath(sessionId),
                parameters: {'sessionId': sessionId},
                originalUrl: url,
              );
            }
          }
        } else if (path == '/leaderboard/global') {
          return DeepLinkData(
            type: DeepLinkType.leaderboard,
            route: RouteConstants.leaderboardGlobal,
            parameters: {},
            originalUrl: url,
          );
        } else if (path == '/leaderboard') {
          return DeepLinkData(
            type: DeepLinkType.leaderboard,
            route: RouteConstants.leaderboard,
            parameters: {},
            originalUrl: url,
          );
        }
      }

      // Quiz creation deep links
      if (path.startsWith('/quiz-creation')) {
        return DeepLinkData(
          type: DeepLinkType.quizCreation,
          route: RouteConstants.quizCreation,
          parameters: {},
          originalUrl: url,
        );
      }

      // Authentication deep links
      if (path == '/login' ||
          path == '/register' ||
          path == '/forgot-password') {
        return DeepLinkData(
          type: DeepLinkType.authentication,
          route: path,
          parameters: queryParams,
          originalUrl: url,
        );
      }

      // Default home link
      if (path == '/' || path.isEmpty) {
        return DeepLinkData(
          type: DeepLinkType.home,
          route: RouteConstants.home,
          parameters: {},
          originalUrl: url,
        );
      }

      debugPrint('DeepLinkService: No matching pattern for path: $path');
      return null;
    } catch (e) {
      debugPrint('DeepLinkService: Error parsing deep link: $e');
      return null;
    }
  }

  /// Handle navigation for deep link
  Future<void> _handleDeepLinkNavigation(DeepLinkData deepLinkData) async {
    try {
      debugPrint('DeepLinkService: Navigating to ${deepLinkData.route}');

      // Add delay to ensure app is ready for navigation
      await Future.delayed(const Duration(milliseconds: 500));

      // Use the AppRouter for navigation
      AppRouter.go(deepLinkData.route);

      debugPrint(
        'DeepLinkService: Navigation completed for ${deepLinkData.type}',
      );
    } catch (e) {
      debugPrint('DeepLinkService: Navigation error: $e');
      // Fallback to home if navigation fails
      AppRouter.go(RouteConstants.home);
    }
  }

  /// Handle deep link with context (for authenticated routes)
  Future<void> handleDeepLinkWithContext(
    BuildContext context,
    DeepLinkData deepLinkData,
  ) async {
    try {
      debugPrint(
        'DeepLinkService: Handling deep link with context: ${deepLinkData.route}',
      );

      switch (deepLinkData.type) {
        case DeepLinkType.gameJoin:
          final gamePin = deepLinkData.parameters['pin'];
          if (gamePin != null) {
            // Use AppRouterHelper for game join navigation
            AppRouterHelper.navigateToGameJoinWithPin(gamePin);
          }
          break;

        case DeepLinkType.quiz:
          final quizId = deepLinkData.parameters['quizId'];
          if (quizId != null) {
            final isShared = deepLinkData.metadata?['shared'] == true;
            if (isShared) {
              AppRouterHelper.navigateToQuizDetailsFromShare(quizId);
            } else {
              AppRouter.go(RouteConstants.quizDetailsPath(quizId));
            }
          }
          break;

        default:
          AppRouter.go(deepLinkData.route);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Context navigation error: $e');
      AppRouter.go(RouteConstants.home);
    }
  }

  /// Generate shareable deep link
  String generateShareableLink({
    required DeepLinkType type,
    required Map<String, String> parameters,
    String baseUrl = 'https://quizapp.com',
  }) {
    switch (type) {
      case DeepLinkType.gameJoin:
        final gamePin = parameters['pin'];
        return '$baseUrl/game/join?pin=$gamePin';

      case DeepLinkType.quiz:
        final quizId = parameters['quizId'];
        return '$baseUrl/quiz/$quizId';

      case DeepLinkType.gameSession:
        final sessionId = parameters['sessionId'];
        return '$baseUrl/game/$sessionId';

      case DeepLinkType.leaderboard:
        final sessionId = parameters['sessionId'];
        if (sessionId != null) {
          return '$baseUrl/leaderboard/session/$sessionId';
        }
        return '$baseUrl/leaderboard';

      default:
        return baseUrl;
    }
  }

  /// Validate deep link URL
  bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);

      // Check for valid scheme
      if (!['https', 'http', 'quizapp'].contains(uri.scheme)) {
        return false;
      }

      // Check for valid host (for https/http)
      if ((uri.scheme == 'https' || uri.scheme == 'http') &&
          !['quizapp.com', 'www.quizapp.com', 'localhost'].contains(uri.host)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _deepLinkController.close();
  }
}

/// Deep link data structure
class DeepLinkData {
  final DeepLinkType type;
  final String route;
  final Map<String, String> parameters;
  final String originalUrl;
  final Map<String, dynamic>? metadata;

  const DeepLinkData({
    required this.type,
    required this.route,
    required this.parameters,
    required this.originalUrl,
    this.metadata,
  });

  @override
  String toString() {
    return 'DeepLinkData(type: $type, route: $route, parameters: $parameters, originalUrl: $originalUrl)';
  }
}

/// Types of deep links supported
enum DeepLinkType {
  home,
  authentication,
  gameJoin,
  gameSession,
  quiz,
  quizCreation,
  leaderboard,
}

/// Riverpod provider for deep link service
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService.instance;
});

/// Riverpod provider for deep link stream
final deepLinkStreamProvider = StreamProvider<DeepLinkData>((ref) {
  final deepLinkService = ref.watch(deepLinkServiceProvider);
  return deepLinkService.deepLinkStream;
});
