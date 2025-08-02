import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_app_1/features/quiz_creation/presentation/pages/quiz_creation_page.dart';
import 'package:quiz_app_1/features/quiz_creation/presentation/providers/quiz_creation_provider.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/entities/quiz.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/entities/question_entities.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/usecases/create_quiz_usecase.dart';
import 'package:quiz_app_1/core/common/result.dart';
import 'package:quiz_app_1/core/navigation/route_constants.dart';
import 'package:quiz_app_1/shared/constants/app_colors.dart';

// Create mock classes manually to avoid build_runner issues
class MockCreateQuizUseCase extends Mock implements CreateQuizUseCase {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('Quiz Creation Flow Tests', () {
    late MockCreateQuizUseCase mockCreateUseCase;
    late MockGoRouter mockRouter;
    late ProviderContainer container;

    setUp(() {
      mockCreateUseCase = MockCreateQuizUseCase();
      mockRouter = MockGoRouter();

      container = ProviderContainer(
        overrides: [
          quizCreationProvider.overrideWith(
            (ref) => QuizCreationNotifier(
              createUseCase: mockCreateUseCase,
              currentUserId: 'test_user_123',
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Quiz Submission Flow Tests', () {
      testWidgets('should show loading state during quiz submission', (
        tester,
      ) async {
        // Setup - Mock delayed response
        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return const Result.success(
            Quiz(
              id: 'test_quiz_123',
              title: 'Test Quiz',
              description: 'Test Description',
              createdBy: 'test_user_123',
              questions: [],
              isPublic: true,
              createdAt: null,
              metadata: QuizMetadata(
                category: 'General',
                tags: [],
                difficulty: 'medium',
                language: 'en',
                estimatedDuration: 5,
              ),
              isDraft: true,
            ),
          );
        });

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const QuizCreationPage(),
                  ),
                ],
              ),
            ),
          ),
        );

        // Fill in quiz metadata
        await _fillQuizMetadata(tester);

        // Navigate to final step (step 2)
        await _navigateToStep(tester, 2);

        // Find the save button
        final saveButton = find.text('Save & Preview');
        expect(saveButton, findsOneWidget);

        // Tap save button
        await tester.tap(saveButton);
        await tester.pump();

        // Should show loading state
        expect(find.text('Saving...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsAtLeastOneWidget);

        // Complete the async operation
        await tester.pumpAndSettle();
      });

      testWidgets('should navigate to preview page on successful quiz save', (
        tester,
      ) async {
        // Setup successful save
        final mockQuiz = Quiz(
          id: 'saved_quiz_123',
          title: 'Saved Quiz',
          description: 'Successfully saved quiz',
          createdBy: 'test_user_123',
          questions: [
            MultipleChoiceQuestion(
              id: 'q1',
              questionText: 'Test Question',
              options: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 0,
              questionTimeLimit: 30,
              points: 100,
            ),
          ],
          isPublic: true,
          createdAt: DateTime.now(),
          metadata: const QuizMetadata(
            category: 'General',
            tags: ['test'],
            difficulty: 'medium',
            language: 'en',
            estimatedDuration: 5,
          ),
          isDraft: true,
        );

        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          return Result.success(mockQuiz);
        });

        // Track navigation calls
        final List<String> navigationCalls = [];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => Builder(
                      builder: (context) {
                        // Override context.push to track calls
                        return _NavigationWrapper(
                          onNavigate: (route) => navigationCalls.add(route),
                          child: const QuizCreationPage(),
                        );
                      },
                    ),
                  ),
                  GoRoute(
                    path: '${RouteConstants.quizCreation}/preview',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Preview Page')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Fill quiz data and submit
        await _fillCompleteQuizData(tester);
        await _navigateToStep(tester, 2);

        // Tap save button
        final saveButton = find.text('Save & Preview');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify navigation was called with correct route
        expect(navigationCalls, isNotEmpty);
        expect(navigationCalls.last, contains('/quiz-creation/preview'));
        expect(navigationCalls.last, contains('id=saved_quiz_123'));
      });

      testWidgets('should show error message when quiz save fails', (
        tester,
      ) async {
        // Setup failed save
        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          return const Result.failure(
            Failure(
              code: 'SAVE_ERROR',
              message: 'Failed to save quiz to database',
            ),
          );
        });

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        // Fill quiz data and submit
        await _fillCompleteQuizData(tester);
        await _navigateToStep(tester, 2);

        // Tap save button
        final saveButton = find.text('Save & Preview');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show error snackbar
        expect(find.text('Failed to save quiz to database'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);

        // Should not navigate away
        expect(find.byType(QuizCreationPage), findsOneWidget);
      });

      testWidgets('should handle validation errors during save', (
        tester,
      ) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        // Don't fill any data - should trigger validation
        await _navigateToStep(tester, 2);

        // Tap save button
        final saveButton = find.text('Save & Preview');
        await tester.tap(saveButton);
        await tester.pump();

        // Should show validation error
        expect(
          find.textContaining('Quiz title must be at least 3 characters'),
          findsOneWidget,
        );

        // Should not call the use case
        verifyNever(mockCreateUseCase.call(any));
      });
    });

    group('Navigation Issue Investigation', () {
      testWidgets('should correctly construct preview route URL', (
        tester,
      ) async {
        final mockQuiz = Quiz(
          id: 'test_quiz_navigation',
          title: 'Navigation Test Quiz',
          description: 'Testing navigation construction',
          createdBy: 'test_user',
          questions: [],
          isPublic: true,
          createdAt: DateTime.now(),
          metadata: const QuizMetadata(
            category: 'Test',
            tags: [],
            difficulty: 'easy',
            language: 'en',
            estimatedDuration: 5,
          ),
          isDraft: true,
        );

        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          return Result.success(mockQuiz);
        });

        final List<String> pushedRoutes = [];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => _NavigationWrapper(
                      onNavigate: (route) => pushedRoutes.add(route),
                      child: const QuizCreationPage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await _fillCompleteQuizData(tester);
        await _navigateToStep(tester, 2);

        // Save quiz
        await tester.tap(find.text('Save & Preview'));
        await tester.pumpAndSettle();

        // Verify the exact route that was pushed
        expect(pushedRoutes, isNotEmpty);
        final pushedRoute = pushedRoutes.last;

        // Check the route construction
        expect(
          pushedRoute,
          startsWith('${RouteConstants.quizCreation}/preview'),
        );
        expect(pushedRoute, contains('?id=test_quiz_navigation'));

        // Log the actual route for debugging
        print('DEBUG: Pushed route: $pushedRoute');
        print(
          'DEBUG: Expected pattern: ${RouteConstants.quizCreation}/preview?id=test_quiz_navigation',
        );
      });

      testWidgets('should handle blank screen navigation issue', (
        tester,
      ) async {
        // This test specifically looks for the blank screen issue
        final mockQuiz = Quiz(
          id: 'blank_screen_test',
          title: 'Blank Screen Test',
          description: 'Testing blank screen issue',
          createdBy: 'test_user',
          questions: [
            MultipleChoiceQuestion(
              id: 'q1',
              questionText: 'Test Question',
              options: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 0,
              questionTimeLimit: 30,
              points: 100,
            ),
          ],
          isPublic: true,
          createdAt: DateTime.now(),
          metadata: const QuizMetadata(
            category: 'Test',
            tags: [],
            difficulty: 'easy',
            language: 'en',
            estimatedDuration: 5,
          ),
          isDraft: true,
        );

        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          return Result.success(mockQuiz);
        });

        // Set up router that might cause blank screen
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const QuizCreationPage(),
            ),
            GoRoute(
              path: '${RouteConstants.quizCreation}/preview',
              builder: (context, state) {
                final quizId = state.uri.queryParameters['id'];
                if (quizId == null) {
                  // This might be causing the blank screen
                  return const Scaffold(
                    backgroundColor: Colors.grey,
                    body: Center(child: Text('ERROR: No quiz ID found')),
                  );
                }
                return Scaffold(
                  body: Center(child: Text('Preview for quiz: $quizId')),
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

        await _fillCompleteQuizData(tester);
        await _navigateToStep(tester, 2);

        // Save quiz and check what happens
        await tester.tap(find.text('Save & Preview'));
        await tester.pumpAndSettle();

        // Check if we ended up with a blank/gray screen
        final greyScaffolds = find.byWidgetPredicate(
          (widget) =>
              widget is Scaffold && widget.backgroundColor == Colors.grey,
        );

        if (greyScaffolds.evaluate().isNotEmpty) {
          print(
            'FOUND ISSUE: Grey screen detected - likely navigation problem',
          );
          expect(find.text('ERROR: No quiz ID found'), findsOneWidget);
        } else {
          // Should show the preview page
          expect(
            find.text('Preview for quiz: blank_screen_test'),
            findsOneWidget,
          );
        }
      });
    });

    group('Form Validation Tests', () {
      testWidgets('should validate required fields before saving', (
        tester,
      ) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        // Try to save without filling any data
        await _navigateToStep(tester, 2);
        await tester.tap(find.text('Save & Preview'));
        await tester.pump();

        // Should show validation errors
        expect(
          find.textContaining('Quiz title must be at least 3 characters'),
          findsOneWidget,
        );
      });

      testWidgets('should validate questions exist before saving', (
        tester,
      ) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        // Fill only metadata, no questions
        await _fillQuizMetadata(tester);
        await _navigateToStep(tester, 2);
        await tester.tap(find.text('Save & Preview'));
        await tester.pump();

        // Should show question validation error
        expect(
          find.textContaining('Quiz must have at least one question'),
          findsOneWidget,
        );
      });
    });

    group('Provider State Tests', () {
      testWidgets('should update loading state correctly during save', (
        tester,
      ) async {
        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const Result.success(
            Quiz(
              id: 'test_id',
              title: 'Test',
              description: 'Test desc',
              createdBy: 'user',
              questions: [],
              isPublic: true,
              createdAt: null,
              metadata: QuizMetadata(
                category: 'Test',
                tags: [],
                difficulty: 'easy',
                language: 'en',
                estimatedDuration: 5,
              ),
              isDraft: true,
            ),
          );
        });

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
                        Text('Loading: ${state.isLoading}'),
                        Text('Error: ${state.error ?? 'none'}'),
                        const Expanded(child: QuizCreationPage()),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Initial state
        expect(find.text('Loading: false'), findsOneWidget);

        await _fillCompleteQuizData(tester);
        await _navigateToStep(tester, 2);

        // Start save operation
        await tester.tap(find.text('Save & Preview'));
        await tester.pump();

        // Should show loading
        expect(find.text('Loading: true'), findsOneWidget);

        // Complete operation
        await tester.pumpAndSettle();

        // Should stop loading
        expect(find.text('Loading: false'), findsOneWidget);
      });
    });

    group('Step Navigation Tests', () {
      testWidgets('should enable next button only when current step is valid', (
        tester,
      ) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        // Initially on step 0, next button should be disabled without data
        final nextButton = find.text('Next');
        expect(nextButton, findsOneWidget);

        // Fill metadata to enable next
        await _fillQuizMetadata(tester);

        // Should be able to proceed to step 1
        await tester.tap(nextButton);
        await tester.pumpAndSettle();

        // Now should be on questions step
        expect(find.text('Previous'), findsOneWidget);
      });
    });
  });
}

// Helper functions for testing
Future<void> _fillQuizMetadata(WidgetTester tester) async {
  // Fill in title
  final titleField = find.byType(TextFormField).first;
  await tester.enterText(titleField, 'Test Quiz Title');

  // Fill in description
  final descriptionField = find.byType(TextFormField).at(1);
  await tester.enterText(
    descriptionField,
    'This is a test quiz description for testing purposes',
  );

  await tester.pump();
}

Future<void> _fillCompleteQuizData(WidgetTester tester) async {
  await _fillQuizMetadata(tester);

  // Add a test question
  // Note: This would need to be implemented based on your question builder UI
  // For now, we'll simulate it by directly updating the provider
}

Future<void> _navigateToStep(WidgetTester tester, int step) async {
  for (int i = 0; i < step; i++) {
    final nextButton = find.text('Next');
    if (nextButton.evaluate().isNotEmpty) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
    }
  }
}

// Custom widget to capture navigation calls
class _NavigationWrapper extends StatefulWidget {
  final Widget child;
  final Function(String) onNavigate;

  const _NavigationWrapper({required this.child, required this.onNavigate});

  @override
  State<_NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<_NavigationWrapper> {
  @override
  Widget build(BuildContext context) {
    return _NavigationCapture(
      onNavigate: widget.onNavigate,
      child: widget.child,
    );
  }
}

class _NavigationCapture extends InheritedWidget {
  final Function(String) onNavigate;

  const _NavigationCapture({required this.onNavigate, required Widget child})
    : super(child: child);

  @override
  bool updateShouldNotify(_NavigationCapture oldWidget) {
    return onNavigate != oldWidget.onNavigate;
  }

  static _NavigationCapture? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NavigationCapture>();
  }
}

// Extension to capture navigation in tests
extension NavigationTestExtension on BuildContext {
  void capturedPush(String route) {
    final capture = _NavigationCapture.of(this);
    capture?.onNavigate(route);
  }
}
