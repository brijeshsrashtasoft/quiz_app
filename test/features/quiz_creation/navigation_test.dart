import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Quiz Creation Navigation Tests', () {
    testWidgets('should navigate to preview page correctly', (tester) async {
      // Track navigation calls
      String? lastRoute;

      // Create a mock navigation context
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  // Simulate the navigation call from quiz creation
                  const quizId = 'test-quiz-123';
                  final route = '/quiz-creation/preview?id=$quizId';
                  lastRoute = route;
                  context.go(route);
                },
                child: const Text('Save & Preview'),
              ),
            ),
          ),
          GoRoute(
            path: '/quiz-creation',
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  final id = state.uri.queryParameters['id'];
                  return Scaffold(body: Text('Preview for quiz: $id'));
                },
              ),
            ],
            builder: (context, state) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Find and tap the button to simulate quiz creation
      await tester.tap(find.text('Save & Preview'));
      await tester.pumpAndSettle();

      // Verify navigation occurred with correct route
      expect(lastRoute, equals('/quiz-creation/preview?id=test-quiz-123'));

      // Verify we're on the preview page
      expect(find.text('Preview for quiz: test-quiz-123'), findsOneWidget);
    });

    testWidgets('should handle quiz preview route with parameters', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/quiz-creation/preview?id=sample-quiz',
        routes: [
          GoRoute(
            path: '/quiz-creation',
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  final id = state.uri.queryParameters['id'];
                  return Scaffold(
                    appBar: AppBar(title: const Text('Quiz Preview')),
                    body: Column(
                      children: [
                        Text('Quiz ID: ${id ?? "No ID"}'),
                        if (id != null)
                          const Text('Preview loaded successfully'),
                      ],
                    ),
                  );
                },
              ),
            ],
            builder: (context, state) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.pumpAndSettle();

      // Verify the preview page loads with correct data
      expect(find.text('Quiz Preview'), findsOneWidget);
      expect(find.text('Quiz ID: sample-quiz'), findsOneWidget);
      expect(find.text('Preview loaded successfully'), findsOneWidget);
    });
  });
}
