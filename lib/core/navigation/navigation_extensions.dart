import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_constants.dart';

/// Extension methods for type-safe navigation
extension NavigationExtensions on BuildContext {
  // Basic navigation methods
  void pushNamed(String routeName, {Object? extra}) {
    GoRouter.of(this).pushNamed(routeName, extra: extra);
  }

  void goNamed(String routeName, {Object? extra}) {
    GoRouter.of(this).goNamed(routeName, extra: extra);
  }

  void pushReplacementNamed(String routeName, {Object? extra}) {
    GoRouter.of(this).pushReplacementNamed(routeName, extra: extra);
  }

  void pop<T extends Object?>([T? result]) {
    GoRouter.of(this).pop(result);
  }

  bool canPop() {
    return GoRouter.of(this).canPop();
  }

  // Authentication navigation
  void goToLogin() => go(RouteConstants.login);
  void goToRegister() => go(RouteConstants.register);
  void goToForgotPassword() => go(RouteConstants.forgotPassword);
  void goToProfile() => go(RouteConstants.profile);

  // Home and dashboard navigation
  void goToHome() => go(RouteConstants.home);
  void goToDashboard() => go(RouteConstants.dashboard);

  // Quiz creation navigation
  void goToQuizCreation() => go(RouteConstants.quizCreation);
  void goToQuizCreationForm() => go(RouteConstants.quizCreationForm);
  void goToQuizCreationPreview() => go(RouteConstants.quizCreationPreview);
  void goToQuizCreationPublish() => go(RouteConstants.quizCreationPublish);

  void goToQuizDetails(String quizId) {
    go(RouteConstants.quizDetailsPath(quizId));
  }

  void goToQuizEdit(String quizId) {
    go(RouteConstants.quizEditPath(quizId));
  }

  // Game session navigation
  void goToGameJoin() => go(RouteConstants.gameJoin);
  void goToGameHost() => go(RouteConstants.gameHost);
  void goToGameHostSetup() => go(RouteConstants.gameHostSetup);

  void goToGameSession(String sessionId) {
    go(RouteConstants.gameSessionPath(sessionId));
  }

  void goToGameWaiting(String sessionId) {
    go(RouteConstants.gameWaitingPath(sessionId));
  }

  void goToGameQuestion(String sessionId, int questionIndex) {
    go(RouteConstants.gameQuestionPath(sessionId, questionIndex));
  }

  void goToGameResults(String sessionId) {
    go(RouteConstants.gameResultsPath(sessionId));
  }

  // Leaderboard navigation
  void goToLeaderboard() => go(RouteConstants.leaderboard);
  void goToGlobalLeaderboard() => go(RouteConstants.leaderboardGlobal);

  void goToSessionLeaderboard(String sessionId) {
    go(RouteConstants.leaderboardSessionPath(sessionId));
  }

  // Settings navigation
  void goToSettings() => go(RouteConstants.settings);
  void goToAbout() => go(RouteConstants.about);
  void goToHelp() => go(RouteConstants.help);

  // Error navigation
  void goToNotFound() => go(RouteConstants.notFound);
  void goToError() => go(RouteConstants.error);

  // Push methods for navigation stack management
  void pushToQuizDetails(String quizId) {
    push(RouteConstants.quizDetailsPath(quizId));
  }

  void pushToGameSession(String sessionId) {
    push(RouteConstants.gameSessionPath(sessionId));
  }

  void pushToSessionLeaderboard(String sessionId) {
    push(RouteConstants.leaderboardSessionPath(sessionId));
  }

  // Stack management
  void popUntilHome() {
    while (canPop() &&
        GoRouter.of(
              this,
            ).routerDelegate.currentConfiguration.last.matchedLocation !=
            RouteConstants.home) {
      pop();
    }
  }

  void popUntilDashboard() {
    while (canPop() &&
        GoRouter.of(
              this,
            ).routerDelegate.currentConfiguration.last.matchedLocation !=
            RouteConstants.dashboard) {
      pop();
    }
  }

  // Clear navigation stack and go to route
  void clearAndGoTo(String route) {
    while (canPop()) {
      pop();
    }
    go(route);
  }

  void clearAndGoToHome() => clearAndGoTo(RouteConstants.home);
  void clearAndGoToDashboard() => clearAndGoTo(RouteConstants.dashboard);
  void clearAndGoToLogin() => clearAndGoTo(RouteConstants.login);
}

/// Extension methods for GoRouter
extension GoRouterExtensions on GoRouter {
  /// Get current route name
  String? get currentRoute {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    return lastMatch.matchedLocation;
  }

  /// Check if currently on specific route
  bool isCurrentRoute(String route) {
    return currentRoute == route;
  }

  /// Check if authentication routes
  bool get isOnAuthRoute {
    final current = currentRoute;
    return current == RouteConstants.login ||
        current == RouteConstants.register ||
        current == RouteConstants.forgotPassword;
  }

  /// Check if on game session routes
  bool get isOnGameRoute {
    final current = currentRoute;
    return current?.startsWith('/game') == true;
  }

  /// Check if on quiz creation routes
  bool get isOnQuizCreationRoute {
    final current = currentRoute;
    return current?.startsWith('/quiz-creation') == true;
  }
}
