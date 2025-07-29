import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/core/navigation/navigation.dart';
import 'package:quiz_app/main.dart';

void main() {
  group('Navigation System Tests', () {
    testWidgets('App initializes with correct router configuration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: QuizApp()));
      await tester.pumpAndSettle();

      // Should start at splash screen and navigate to home
      expect(find.text('Quiz App'), findsOneWidget);
    });

    testWidgets('Router provider is properly configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(routerProvider);
              expect(router, isNotNull);
              expect(router.routerDelegate, isNotNull);

              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    test('Route constants are properly defined', () {
      expect(RouteConstants.root, equals('/'));
      expect(RouteConstants.splash, equals('/splash'));
      expect(RouteConstants.home, equals('/home'));
      expect(RouteConstants.login, equals('/login'));
      expect(RouteConstants.dashboard, equals('/dashboard'));
      expect(RouteConstants.gameJoin, equals('/game/join'));
      expect(RouteConstants.leaderboard, equals('/leaderboard'));
    });

    test('Dynamic route helpers work correctly', () {
      expect(
        RouteConstants.quizDetailsPath('test123'),
        equals('/quiz/test123'),
      );
      expect(
        RouteConstants.gameSessionPath('game456'),
        equals('/game/game456'),
      );
      expect(
        RouteConstants.gameQuestionPath('game456', 2),
        equals('/game/game456/question/2'),
      );
      expect(
        RouteConstants.leaderboardSessionPath('session789'),
        equals('/leaderboard/session/session789'),
      );
    });

    testWidgets('Navigation extensions are available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            builder: (context, child) {
              // Test that extension methods are available
              expect(context.canPop, isA<Function>());
              expect(context.goToHome, isA<Function>());
              expect(context.goToLogin, isA<Function>());

              return child ?? const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('Route guards are properly configured', (
      WidgetTester tester,
    ) async {
      // Test that guard registry has correct guards
      final loginGuards = GuardRegistry.getGuards(RouteConstants.login);
      expect(loginGuards, isNotEmpty);
      expect(loginGuards.first, isA<GuestGuard>());

      final dashboardGuards = GuardRegistry.getGuards(RouteConstants.dashboard);
      expect(dashboardGuards, isNotEmpty);
      expect(dashboardGuards.first, isA<AuthGuard>());
    });

    test('Navigation utils provide correct functionality', () {
      // Test URL generation
      final quizShareUrl = NavigationUtils.generateQuizShareUrl('quiz123');
      expect(quizShareUrl, contains('/quiz/quiz123'));

      final gameJoinUrl = NavigationUtils.generateGameJoinUrl('123456');
      expect(gameJoinUrl, contains('/game/join?pin=123456'));

      // Test route validation
      expect(NavigationUtils.isValidQuizId('quiz123'), isTrue);
      expect(NavigationUtils.isValidQuizId(''), isFalse);
      expect(NavigationUtils.isValidQuizId(null), isFalse);

      expect(NavigationUtils.isValidSessionId('session123'), isTrue);
      expect(NavigationUtils.isValidQuestionIndex(0), isTrue);
      expect(NavigationUtils.isValidQuestionIndex(-1), isFalse);

      // Test route type checking
      expect(NavigationUtils.isAuthRoute('/login'), isTrue);
      expect(NavigationUtils.isAuthRoute('/register'), isTrue);
      expect(NavigationUtils.isAuthRoute('/home'), isFalse);

      expect(NavigationUtils.isGameRoute('/game/123'), isTrue);
      expect(NavigationUtils.isGameRoute('/home'), isFalse);
    });

    testWidgets('Placeholder pages render correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('Error handling works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ErrorPage(error: 'Test error message')),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('All major routes are accessible', (WidgetTester tester) async {
      final routes = [
        RouteConstants.home,
        RouteConstants.login,
        RouteConstants.register,
        RouteConstants.gameJoin,
        RouteConstants.leaderboard,
        RouteConstants.settings,
        RouteConstants.about,
      ];

      for (final route in routes) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(routerConfig: AppRouter.router),
          ),
        );

        // Navigate to each route programmatically
        AppRouter.go(route);
        await tester.pumpAndSettle();

        // Should not show error page
        expect(find.text('Error'), findsNothing);
      }
    });
  });
}
