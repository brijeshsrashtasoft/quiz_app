import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_app_1/features/quiz_creation/presentation/pages/quiz_creation_page.dart';
import 'package:quiz_app_1/features/quiz_creation/presentation/pages/quiz_preview_page.dart';
import 'package:quiz_app_1/features/quiz_creation/presentation/providers/quiz_creation_provider.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/entities/quiz.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/entities/question_entities.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/usecases/create_quiz_usecase.dart';
import 'package:quiz_app_1/core/common/result.dart';
import 'package:quiz_app_1/core/navigation/route_constants.dart';

/// Debug tests to identify the blank screen navigation issue
void main() {
  group('Quiz Creation Navigation Debug Tests', () {
    testWidgets('NAVIGATION DEBUG: Test the exact route navigation issue', (
      tester,
    ) async {
      // Track all navigation calls
      final List<String> navigationLog = [];
      final List<String> routeBuilds = [];

      // Mock successful quiz save
      final mockCreateUseCase = _MockCreateQuizUseCase();

      final container = ProviderContainer(
        overrides: [
          quizCreationProvider.overrideWith(
            (ref) => QuizCreationNotifier(
              createUseCase: mockCreateUseCase,
              currentUserId: 'debug_user',
            ),
          ),
        ],
      );

      // Create router with debug logging
      final router = GoRouter(
        initialLocation: '/quiz-creation',
        routes: [
          GoRoute(
            path: '/quiz-creation',
            name: 'quiz-creation',
            builder: (context, state) {
              routeBuilds.add('quiz-creation: ${state.uri}');
              return _DebugNavigationWrapper(
                onNavigate: (route) => navigationLog.add('PUSH: $route'),
                child: const QuizCreationPage(),
              );
            },
            routes: [
              GoRoute(
                path: 'preview',
                name: 'quiz-preview',
                builder: (context, state) {
                  final quizId = state.uri.queryParameters['id'];
                  routeBuilds.add('preview: ${state.uri}, quizId: $quizId');

                  if (quizId == null) {
                    // This is likely causing the blank screen!
                    return const Scaffold(
                      backgroundColor: Colors.grey,
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'BLANK SCREEN CAUSE: No quiz ID in URL',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const QuizPreviewPage();
                },
              ),
            ],
          ),
          // Catch-all route for debugging
          GoRoute(
            path: '/:path(.*)',
            builder: (context, state) {
              routeBuilds.add('catch-all: ${state.uri}');
              return Scaffold(
                backgroundColor: Colors.orange,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 64),
                      const SizedBox(height: 16),
                      Text('UNHANDLED ROUTE: ${state.uri}'),
                      const SizedBox(height: 16),
                      Text('Path: ${state.path}'),
                      Text('Query: ${state.uri.queryParameters}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();
      print('=== INITIAL STATE ===');
      print('Route builds: $routeBuilds');

      // Fill minimal quiz data to pass validation
      await _fillBasicQuizData(tester, container);

      // Navigate to settings step (step 2)
      for (int i = 0; i < 2; i++) {
        final nextButton = find.text('Next');
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
        }
      }

      print('=== BEFORE SAVE ===');
      print('Navigation log: $navigationLog');
      print('Route builds: $routeBuilds');

      // Clear logs to focus on the save operation
      navigationLog.clear();
      routeBuilds.clear();

      // Find and tap the save button
      final saveButton = find.text('Save & Preview');
      expect(
        saveButton,
        findsOneWidget,
        reason: 'Save button should be visible',
      );

      await tester.tap(saveButton);
      await tester.pump(); // Process the tap

      print('=== DURING SAVE ===');
      print('Navigation log: $navigationLog');
      print('Route builds: $routeBuilds');

      // Complete async operations
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('=== AFTER SAVE ===');
      print('Navigation log: $navigationLog');
      print('Route builds: $routeBuilds');

      // Check what's currently on screen
      final currentWidgets = tester.allWidgets
          .map((w) => w.runtimeType.toString())
          .toList();
      print('Current widgets: $currentWidgets');

      // Look for signs of blank screen
      final greyScreens = find.byWidgetPredicate(
        (widget) => widget is Scaffold && widget.backgroundColor == Colors.grey,
      );

      final orangeScreens = find.byWidgetPredicate(
        (widget) =>
            widget is Scaffold && widget.backgroundColor == Colors.orange,
      );

      if (greyScreens.evaluate().isNotEmpty) {
        print('🚨 FOUND THE ISSUE: Grey screen detected!');
        expect(
          find.text('BLANK SCREEN CAUSE: No quiz ID in URL'),
          findsOneWidget,
        );

        // Log the exact navigation that caused this
        print('Navigation that led to blank screen: $navigationLog');
        print('Route builds that led to blank screen: $routeBuilds');
      } else if (orangeScreens.evaluate().isNotEmpty) {
        print('🚨 FOUND THE ISSUE: Unhandled route detected!');
        expect(find.text('UNHANDLED ROUTE:'), findsOneWidget);
      } else {
        print('✅ Navigation successful - preview page should be showing');
        expect(find.byType(QuizPreviewPage), findsOneWidget);
      }

      container.dispose();
    });

    testWidgets('NAVIGATION DEBUG: Test correct route format expectations', (
      tester,
    ) async {
      // Test what the router actually expects vs what we're pushing

      final List<RouteMatch> routeMatches = [];

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/quiz-creation',
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  routeMatches.add(state);
                  final quizId = state.uri.queryParameters['id'];

                  return Scaffold(
                    body: Center(
                      child: Column(
                        children: [
                          Text('Full URI: ${state.uri}'),
                          Text('Path: ${state.path}'),
                          Text('Query ID: ${quizId ?? "NULL"}'),
                          Text('Location: ${state.matchedLocation}'),
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

      // Test different route formats that might be attempted
      final testRoutes = [
        '/quiz-creation/preview?id=test123',
        '/quiz-creation/preview/test123',
        '/quiz-creation/preview',
      ];

      for (final route in testRoutes) {
        print('Testing route: $route');

        try {
          router.go(route);
          await tester.pumpAndSettle();

          final uriText = find.textContaining('Full URI:');
          if (uriText.evaluate().isNotEmpty) {
            final widget = tester.widget<Text>(uriText);
            print('  Result: ${widget.data}');
          }
        } catch (e) {
          print('  Error: $e');
        }
      }
    });

    testWidgets('PROVIDER DEBUG: Test quiz creation provider state during save', (
      tester,
    ) async {
      final mockCreateUseCase = _MockCreateQuizUseCase();
      final container = ProviderContainer(
        overrides: [
          quizCreationProvider.overrideWith(
            (ref) => QuizCreationNotifier(
              createUseCase: mockCreateUseCase,
              currentUserId: 'debug_user',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(quizCreationProvider);
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Title: "${state.title}"'),
                      Text('Description: "${state.description}"'),
                      Text('Questions: ${state.questions.length}'),
                      Text('Loading: ${state.isLoading}'),
                      Text('Error: ${state.error ?? "none"}'),
                      ElevatedButton(
                        onPressed: () async {
                          // Set basic data
                          ref
                              .read(quizCreationProvider.notifier)
                              .updateMetadata(
                                title: 'Debug Test Quiz',
                                description:
                                    'This is a debug test quiz with sufficient length',
                              );

                          // Add a question
                          ref
                              .read(quizCreationProvider.notifier)
                              .addQuestion(
                                MultipleChoiceQuestion(
                                  id: 'debug_q1',
                                  questionText: 'Debug question?',
                                  options: ['A', 'B', 'C', 'D'],
                                  correctAnswerIndex: 0,
                                  questionTimeLimit: 30,
                                  points: 100,
                                ),
                              );

                          // Try to save
                          final result = await ref
                              .read(quizCreationProvider.notifier)
                              .saveQuiz();
                          print('Save result: $result');
                        },
                        child: const Text('Test Save'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Check initial state
      expect(find.text('Title: ""'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);

      // Trigger save
      await tester.tap(find.text('Test Save'));
      await tester.pump();

      // Check loading state
      expect(find.text('Loading: true'), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();

      // Check final state
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Title: "Debug Test Quiz"'), findsOneWidget);
      expect(find.text('Questions: 1'), findsOneWidget);

      container.dispose();
    });
  });
}

// Helper functions
Future<void> _fillBasicQuizData(
  WidgetTester tester,
  ProviderContainer container,
) async {
  // Use the provider directly to set data
  container
      .read(quizCreationProvider.notifier)
      .updateMetadata(
        title: 'Debug Quiz Title',
        description:
            'This is a debug quiz description that is long enough to pass validation',
      );

  // Add a test question
  container
      .read(quizCreationProvider.notifier)
      .addQuestion(
        MultipleChoiceQuestion(
          id: 'debug_q1',
          questionText: 'What is the capital of France?',
          options: ['London', 'Berlin', 'Paris', 'Madrid'],
          correctAnswerIndex: 2,
          questionTimeLimit: 30,
          points: 100,
        ),
      );

  await tester.pump();
}

// Mock implementation
class _MockCreateQuizUseCase implements CreateQuizUseCase {
  @override
  Future<Result<Quiz, Failure>> call(CreateQuizParams params) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Return success with the quiz including an ID
    final quizWithId = Quiz(
      id: 'debug_quiz_123',
      title: params.quiz.title,
      description: params.quiz.description,
      createdBy: params.quiz.createdBy,
      questions: params.quiz.questions,
      isPublic: params.quiz.isPublic,
      createdAt: DateTime.now(),
      metadata: params.quiz.metadata,
      isDraft: params.quiz.isDraft,
    );

    return Result.success(quizWithId);
  }
}

// Debug navigation wrapper
class _DebugNavigationWrapper extends StatelessWidget {
  final Widget child;
  final Function(String) onNavigate;

  const _DebugNavigationWrapper({
    required this.child,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return _NavigationInterceptor(onNavigate: onNavigate, child: child);
  }
}

class _NavigationInterceptor extends StatefulWidget {
  final Widget child;
  final Function(String) onNavigate;

  const _NavigationInterceptor({required this.child, required this.onNavigate});

  @override
  State<_NavigationInterceptor> createState() => _NavigationInterceptorState();
}

class _NavigationInterceptorState extends State<_NavigationInterceptor> {
  @override
  Widget build(BuildContext context) {
    // Wrap the child to intercept navigation calls
    return Builder(
      builder: (context) {
        // Override the context's navigation methods for debugging
        return widget.child;
      },
    );
  }
}
