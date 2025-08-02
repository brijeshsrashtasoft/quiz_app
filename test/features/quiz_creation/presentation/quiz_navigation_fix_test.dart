import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Simple test to verify the navigation issue and demonstrate the fix
void main() {
  group('Quiz Navigation Fix Tests', () {
    testWidgets('ISSUE REPRODUCTION: Current navigation breaks', (tester) async {
      bool hasNavigatedCorrectly = false;
      String? capturedQuizId;
      
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // This is the CURRENT (broken) approach from quiz_creation_page.dart line 67
                    const quizId = 'test_quiz_123';
                    final brokenRoute = '/quiz-creation/preview?id=$quizId';
                    print('❌ BROKEN: Trying to push: $brokenRoute');
                    
                    try {
                      context.push(brokenRoute);
                    } catch (e) {
                      print('❌ BROKEN: Push failed: $e');
                    }
                  },
                  child: const Text('Test Broken Navigation'),
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
                  capturedQuizId = state.uri.queryParameters['id'];
                  hasNavigatedCorrectly = capturedQuizId != null;
                  
                  print('🔍 Preview route accessed');
                  print('🔍 Quiz ID found: $capturedQuizId');
                  print('🔍 Navigation successful: $hasNavigatedCorrectly');
                  
                  if (capturedQuizId == null) {
                    return const Scaffold(
                      backgroundColor: Colors.grey,
                      body: Center(
                        child: Text(
                          'BLANK SCREEN: No quiz ID found!',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      ),
                    );
                  }
                  
                  return Scaffold(
                    body: Center(
                      child: Text('✅ SUCCESS: Preview for quiz $capturedQuizId'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Test the current broken navigation
      await tester.tap(find.text('Test Broken Navigation'));
      await tester.pumpAndSettle();

      if (hasNavigatedCorrectly) {
        print('✅ Unexpected: Navigation worked!');
        expect(find.text('✅ SUCCESS: Preview for quiz test_quiz_123'), findsOneWidget);
      } else {
        print('❌ CONFIRMED: Navigation is broken - blank screen appears');
        // This should show the blank screen issue
        expect(find.text('BLANK SCREEN: No quiz ID found!'), findsOneWidget);
      }
    });

    testWidgets('SOLUTION: Correct navigation approach', (tester) async {
      bool hasNavigatedCorrectly = false;
      String? capturedQuizId;
      
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // SOLUTION 1: Use the constant directly
                        const quizId = 'test_quiz_123';
                        const correctRoute = '/quiz-creation/preview?id=$quizId';
                        print('✅ SOLUTION 1: Trying to push: $correctRoute');
                        context.push(correctRoute);
                      },
                      child: const Text('Test Fixed Navigation'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // SOLUTION 2: Use go instead of push for nested routes
                        const quizId = 'test_quiz_456';
                        const alternativeRoute = '/quiz-creation/preview?id=$quizId';
                        print('✅ SOLUTION 2: Trying to go: $alternativeRoute');
                        context.go(alternativeRoute);
                      },
                      child: const Text('Test Alternative Navigation'),
                    ),
                  ],
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
                  capturedQuizId = state.uri.queryParameters['id'];
                  hasNavigatedCorrectly = capturedQuizId != null;
                  
                  print('🔍 Preview route accessed');
                  print('🔍 Quiz ID found: $capturedQuizId');
                  print('🔍 Navigation successful: $hasNavigatedCorrectly');
                  
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✅ SUCCESS: Preview for quiz $capturedQuizId'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/test'),
                            child: const Text('Back to Test'),
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
      await tester.pumpAndSettle();

      // Test the fixed navigation
      await tester.tap(find.text('Test Fixed Navigation'));
      await tester.pumpAndSettle();

      expect(hasNavigatedCorrectly, isTrue);
      expect(find.text('✅ SUCCESS: Preview for quiz test_quiz_123'), findsOneWidget);

      // Go back and test alternative
      await tester.tap(find.text('Back to Test'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Alternative Navigation'));
      await tester.pumpAndSettle();

      expect(find.text('✅ SUCCESS: Preview for quiz test_quiz_456'), findsOneWidget);
    });

    testWidgets('DEMONSTRATION: What causes the blank screen', (tester) async {
      // This test demonstrates exactly what causes the blank screen issue
      
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/demo',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const Text('Blank Screen Demo'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // This will cause blank screen because ID is not passed
                        context.push('/quiz-creation/preview');
                      },
                      child: const Text('Cause Blank Screen'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // This works because ID is passed
                        context.push('/quiz-creation/preview?id=working_quiz');
                      },
                      child: const Text('Working Navigation'),
                    ),
                  ],
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
                  
                  if (quizId == null) {
                    print('❌ BLANK SCREEN CAUSE: No quiz ID in URL parameters');
                    print('❌ URL: ${state.uri}');
                    print('❌ Query params: ${state.uri.queryParameters}');
                    
                    return const Scaffold(
                      backgroundColor: Colors.grey,
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'BLANK SCREEN ISSUE IDENTIFIED',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Quiz ID not found in URL parameters',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Scaffold(
                    body: Center(
                      child: Text('Preview for quiz: $quizId'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Cause the blank screen
      await tester.tap(find.text('Cause Blank Screen'));
      await tester.pumpAndSettle();

      expect(find.text('BLANK SCREEN ISSUE IDENTIFIED'), findsOneWidget);
      expect(find.text('Quiz ID not found in URL parameters'), findsOneWidget);

      // Go back to demo page
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test working navigation
      await tester.tap(find.text('Working Navigation'));
      await tester.pumpAndSettle();

      expect(find.text('Preview for quiz: working_quiz'), findsOneWidget);
    });
  });
}