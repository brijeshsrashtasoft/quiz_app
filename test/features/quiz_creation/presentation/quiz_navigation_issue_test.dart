import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Constants for testing
const String kQuizCreationRoute = '/quiz-creation';

/// Test to identify the exact navigation issue causing blank screen
void main() {
  group('Navigation Issue Investigation', () {
    testWidgets('Reproduce the exact navigation issue from QuizCreationPage', (
      tester,
    ) async {
      // This test reproduces the exact problem from the quiz creation page

      // Track what happens with different route formats
      final List<String> attemptedRoutes = [];
      final List<String> builtRoutes = [];
      final List<String> errors = [];

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => TestNavigationPage(
              onNavigate: (route) {
                attemptedRoutes.add(route);
                try {
                  context.push(route);
                } catch (e) {
                  errors.add('Push error for $route: $e');
                }
              },
            ),
          ),

          // This mimics the actual router configuration
          GoRoute(
            path: kQuizCreationRoute, // '/quiz-creation'
            builder: (context, state) => const Text('Quiz Creation'),
            routes: [
              GoRoute(
                path: 'preview', // This creates '/quiz-creation/preview'
                builder: (context, state) {
                  final quizId = state.uri.queryParameters['id'];
                  builtRoutes.add('Built preview route with ID: $quizId');

                  if (quizId == null) {
                    return const Scaffold(
                      backgroundColor: Colors.grey,
                      body: Center(child: Text('BLANK SCREEN: No quiz ID')),
                    );
                  }

                  return Scaffold(
                    body: Center(child: Text('Preview for quiz: $quizId')),
                  );
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.pumpAndSettle();

      // Test the exact route format from QuizCreationPage line 67
      final problematicRoute = '$kQuizCreationRoute/preview?id=test_quiz_123';
      print('Testing problematic route: $problematicRoute');

      await tester.tap(find.text('Test Navigation'));
      await tester.pumpAndSettle();

      print('Attempted routes: $attemptedRoutes');
      print('Built routes: $builtRoutes');
      print('Errors: $errors');

      // Check if we got a blank screen
      final blankScreen = find.text('BLANK SCREEN: No quiz ID');
      final successScreen = find.text('Preview for quiz: test_quiz_123');

      if (blankScreen.evaluate().isNotEmpty) {
        print('🚨 CONFIRMED: Blank screen issue reproduced!');
        print(
          'The route $kQuizCreationRoute/preview?id=test_quiz_123 is not working correctly',
        );
      } else if (successScreen.evaluate().isNotEmpty) {
        print('✅ Navigation worked correctly');
      } else {
        print('❓ Unexpected result - check what actually rendered');
      }
    });

    testWidgets('Test different route formats to find the working one', (
      tester,
    ) async {
      final Map<String, String> routeResults = {};

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => RouteTestPage(
              onTestRoute: (route) async {
                try {
                  context.go(route);
                  await Future.delayed(const Duration(milliseconds: 100));
                  return 'Navigated successfully';
                } catch (e) {
                  return 'Error: $e';
                }
              },
            ),
          ),
          GoRoute(
            path: '/quiz-creation',
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  final quizId = state.uri.queryParameters['id'];
                  final result = quizId != null
                      ? 'SUCCESS: Found quiz ID $quizId'
                      : 'FAIL: No quiz ID found';

                  return Scaffold(body: Center(child: Text(result)));
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final routesToTest = [
        '/quiz-creation/preview?id=123', // Expected working format
        '/quiz-creation/preview/123', // Alternative format
        '/quiz-creation/preview', // Without ID
      ];

      for (final route in routesToTest) {
        print('Testing route format: $route');

        router.go(route);
        await tester.pumpAndSettle();

        final successText = find.textContaining('SUCCESS:');
        final failText = find.textContaining('FAIL:');

        if (successText.evaluate().isNotEmpty) {
          print('  ✅ SUCCESS: Route $route works correctly');
        } else if (failText.evaluate().isNotEmpty) {
          print('  ❌ FAIL: Route $route does not pass quiz ID');
        } else {
          print('  ❓ UNKNOWN: Route $route had unexpected result');
        }
      }
    });

    testWidgets('Test the exact line 67 navigation from QuizCreationPage', (
      tester,
    ) async {
      // This simulates the exact code from line 67 in quiz_creation_page.dart
      // context.push('${RouteConstants.quizCreation}/preview?id=$quizId');

      String? navigationResult;
      String? errorResult;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Simulate the exact line from QuizCreationPage
                    const quizId = 'saved_quiz_123';
                    final route = '$kQuizCreationRoute/preview?id=$quizId';

                    print('Attempting to push: $route');
                    print('kQuizCreationRoute = $kQuizCreationRoute');

                    try {
                      context.push(route);
                      navigationResult = 'Push succeeded';
                    } catch (e) {
                      errorResult = 'Push failed: $e';
                      print('Push error: $e');
                    }
                  },
                  child: const Text('Simulate Line 67'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/quiz-creation',
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  final quizId = state.uri.queryParameters['id'];
                  print('Preview route built with quiz ID: $quizId');
                  print('Full URI: ${state.uri}');
                  print('Path: ${state.path}');
                  print('Matched location: ${state.matchedLocation}');

                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Quiz ID: ${quizId ?? "NOT FOUND"}'),
                          Text('URI: ${state.uri}'),
                          Text('Path: ${state.path}'),
                          if (quizId == null)
                            const Text(
                              'THIS IS THE BLANK SCREEN CAUSE!',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.text('Simulate Line 67'));
      await tester.pumpAndSettle();

      print('Navigation result: $navigationResult');
      print('Error result: $errorResult');

      // Check what we ended up with
      if (find.text('NOT FOUND').evaluate().isNotEmpty) {
        print('🚨 CONFIRMED ISSUE: Quiz ID not being passed correctly!');
        expect(find.text('THIS IS THE BLANK SCREEN CAUSE!'), findsOneWidget);
      } else {
        print('✅ Quiz ID passed correctly');
        expect(find.text('Quiz ID: saved_quiz_123'), findsOneWidget);
      }
    });
  });
}

class TestNavigationPage extends StatelessWidget {
  final Function(String) onNavigate;

  const TestNavigationPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final route = '$kQuizCreationRoute/preview?id=test_quiz_123';
            onNavigate(route);
          },
          child: const Text('Test Navigation'),
        ),
      ),
    );
  }
}

class RouteTestPage extends StatelessWidget {
  final Future<String> Function(String) onTestRoute;

  const RouteTestPage({super.key, required this.onTestRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => onTestRoute('/quiz-creation/preview?id=123'),
              child: const Text('Test Query Param Route'),
            ),
            ElevatedButton(
              onPressed: () => onTestRoute('/quiz-creation/preview/123'),
              child: const Text('Test Path Param Route'),
            ),
          ],
        ),
      ),
    );
  }
}
