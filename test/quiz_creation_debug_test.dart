import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Simple test to debug the actual quiz creation flow issue
void main() {
  testWidgets('Debug quiz creation navigation issue', (tester) async {
    // Track all console output and errors
    final List<String> debugMessages = [];
    final List<String> errors = [];

    // Create a simple app that mimics the real navigation structure
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      debugMessages.add('Navigating to quiz creation');
                      context.go('/quiz-creation');
                    },
                    child: const Text('Create Quiz'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      debugMessages.add('Direct navigation to preview');
                      context.go('/quiz-creation/preview?id=test-123');
                    },
                    child: const Text('Direct to Preview'),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/quiz-creation',
          builder: (context, state) {
            debugMessages.add('Quiz creation page builder called');
            return Scaffold(
              appBar: AppBar(title: const Text('Create Quiz')),
              body: Column(
                children: [
                  const Text('Quiz Creation Form'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      debugMessages.add('Save & Preview clicked');
                      // Simulate successful quiz creation
                      const quizId = 'created-quiz-123';
                      final route = '/quiz-creation/preview?id=$quizId';
                      debugMessages.add('Navigating to: $route');

                      try {
                        context.go(route);
                        debugMessages.add('Navigation call completed');
                      } catch (e) {
                        errors.add('Navigation error: $e');
                      }
                    },
                    child: const Text('Save & Preview'),
                  ),
                ],
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'preview',
              builder: (context, state) {
                debugMessages.add('Preview page builder called');
                final quizId = state.uri.queryParameters['id'];
                debugMessages.add('Preview page quiz ID: $quizId');

                // Check if this is causing issues
                if (quizId == null) {
                  errors.add('No quiz ID provided to preview page');
                  return const Scaffold(
                    body: Center(child: Text('Error: No quiz ID provided')),
                  );
                }

                return Scaffold(
                  appBar: AppBar(title: const Text('Quiz Preview')),
                  body: Center(
                    child: Column(
                      children: [
                        Text('Preview for quiz: $quizId'),
                        const SizedBox(height: 20),
                        const Text('Quiz preview content would be here'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
      onException: (context, state, exception) {
        errors.add('Router exception: $exception');
      },
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    // Test the complete flow
    print('=== Starting Quiz Creation Debug Test ===');

    // 1. Verify home page loads
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Create Quiz'), findsOneWidget);
    print('✓ Home page loaded correctly');

    // 2. Navigate to quiz creation
    await tester.tap(find.text('Create Quiz'));
    await tester.pumpAndSettle();

    print('Debug messages after navigation to quiz creation:');
    for (final msg in debugMessages) {
      print('  - $msg');
    }

    if (errors.isNotEmpty) {
      print('Errors after navigation to quiz creation:');
      for (final error in errors) {
        print('  - ERROR: $error');
      }
    }

    // 3. Verify quiz creation page loads
    expect(find.text('Create Quiz'), findsOneWidget); // AppBar title
    expect(find.text('Quiz Creation Form'), findsOneWidget);
    expect(find.text('Save & Preview'), findsOneWidget);
    print('✓ Quiz creation page loaded correctly');

    // 4. Test the save and preview flow
    await tester.tap(find.text('Save & Preview'));
    await tester.pumpAndSettle();

    print('Debug messages after Save & Preview:');
    for (final msg in debugMessages) {
      print('  - $msg');
    }

    if (errors.isNotEmpty) {
      print('Errors after Save & Preview:');
      for (final error in errors) {
        print('  - ERROR: $error');
      }
    }

    // 5. Verify preview page loads
    expect(find.text('Quiz Preview'), findsOneWidget);
    expect(find.text('Preview for quiz: created-quiz-123'), findsOneWidget);
    expect(find.text('Quiz preview content would be here'), findsOneWidget);
    print('✓ Preview page loaded correctly with quiz ID');

    // 6. Test direct navigation to preview
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Direct to Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Preview for quiz: test-123'), findsOneWidget);
    print('✓ Direct navigation to preview works');

    print('=== Quiz Creation Debug Test Completed Successfully ===');

    // Print final summary
    print('\\nFinal Debug Messages (${debugMessages.length} total):');
    for (int i = 0; i < debugMessages.length; i++) {
      print('  ${i + 1}. ${debugMessages[i]}');
    }

    if (errors.isNotEmpty) {
      print('\\nFinal Errors (${errors.length} total):');
      for (int i = 0; i < errors.length; i++) {
        print('  ${i + 1}. ERROR: ${errors[i]}');
      }
      fail('Test completed but errors were detected');
    } else {
      print('\\n✅ No errors detected - navigation flow works correctly');
    }
  });
}
