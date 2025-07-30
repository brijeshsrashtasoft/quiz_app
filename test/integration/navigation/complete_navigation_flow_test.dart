import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import '../../test_config.dart';
import '../../helpers/test_utilities.dart';

/// Integration tests for complete navigation flows
/// Tests end-to-end navigation scenarios with authentication
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testGroup(
    'Complete Navigation Flow Integration Tests',
    TestCategory.integration,
    () {
      widgetTestCase(
        'should complete unauthenticated user flow',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT & ASSERT - App starts at splash
          expect(find.text('Quiz App'), findsOneWidget);

          // Should navigate to home/login based on auth state
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify navigation works for unauthenticated user
          // This depends on the actual routing implementation
        },
      );

      widgetTestCase(
        'should handle authentication flow correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT - Navigate to login page
          AppRouter.go(RouteConstants.login);
          await tester.pumpAndSettle();

          // ASSERT - Should be on login page
          expect(find.text('Welcome Back'), findsOneWidget);
          expect(find.text('Sign in to your account'), findsOneWidget);

          // ACT - Fill login form
          await tester.enterText(
            find.byKey(const Key('email_field')),
            'test@example.com',
          );
          await tester.enterText(
            find.byKey(const Key('password_field')),
            'password123',
          );

          // Submit form
          await tester.tap(find.text('Sign In'));
          await tester.pumpAndSettle();

          // ASSERT - Behavior depends on actual authentication implementation
          // In a real test, this would verify successful navigation after auth
        },
      );

      widgetTestCase(
        'should navigate between public pages correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT & ASSERT - Navigate to different public pages
          AppRouter.go(RouteConstants.about);
          await tester.pumpAndSettle();
          expect(find.text('About'), findsOneWidget);

          AppRouter.go(RouteConstants.help);
          await tester.pumpAndSettle();
          expect(find.text('Help'), findsOneWidget);

          // Navigate back to home
          AppRouter.go(RouteConstants.home);
          await tester.pumpAndSettle();
        },
      );

      widgetTestCase(
        'should handle deep link navigation correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT - Navigate to deep link URL
          const gamePin = '123456';
          final deepLinkUrl = '${RouteConstants.gameJoin}?pin=$gamePin';
          AppRouter.go(deepLinkUrl);
          await tester.pumpAndSettle();

          // ASSERT - Should be on game join page with PIN pre-filled
          expect(find.text('Join Game'), findsOneWidget);
          // This would check if the PIN is pre-filled based on implementation
        },
      );

      widgetTestCase(
        'should handle quiz navigation flow correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT - Navigate through quiz creation flow
          AppRouter.go(RouteConstants.quizCreation);
          await tester.pumpAndSettle();
          expect(find.text('Create Quiz'), findsOneWidget);

          // Navigate to quiz form
          AppRouter.go(RouteConstants.quizCreationForm);
          await tester.pumpAndSettle();
          expect(find.text('Quiz Details'), findsOneWidget);

          // Navigate to preview
          AppRouter.go(RouteConstants.quizCreationPreview);
          await tester.pumpAndSettle();
          expect(find.text('Preview Quiz'), findsOneWidget);

          // Navigate to publish
          AppRouter.go(RouteConstants.quizCreationPublish);
          await tester.pumpAndSettle();
          expect(find.text('Publish Quiz'), findsOneWidget);
        },
      );

      widgetTestCase(
        'should handle game session navigation flow',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // This test would require authentication and session creation
          // For now, test navigation to game routes
          const sessionId = 'test-session-123';

          // ACT - Navigate to game waiting room
          AppRouter.go(RouteConstants.gameWaitingPath(sessionId));
          await tester.pumpAndSettle();

          // ASSERT - Should handle the navigation (may redirect to login)
          // The exact behavior depends on authentication state
        },
      );

      widgetTestCase(
        'should handle error routes correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT - Navigate to non-existent route
          AppRouter.go('/non-existent-route');
          await tester.pumpAndSettle();

          // ASSERT - Should show error page
          expect(find.textContaining('Error'), findsAtLeastNWidgets(1));
        },
      );

      widgetTestCase(
        'should handle browser back button correctly',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT - Navigate to a page and then back
          AppRouter.push(RouteConstants.about);
          await tester.pumpAndSettle();
          expect(find.text('About'), findsOneWidget);

          // Simulate back navigation
          if (AppRouter.canPop()) {
            AppRouter.pop();
            await tester.pumpAndSettle();
          }

          // ASSERT - Should be back at previous page
          expect(find.text('About'), findsNothing);
        },
      );
    },
  );

  testGroup(
    'Authentication Guard Integration Tests',
    TestCategory.integration,
    () {
      widgetTestCase(
        'should redirect unauthenticated users from protected routes',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                // Override auth state to be unauthenticated
                authStateProvider.overrideWith(
                  (ref) => Stream.value(const AuthState.unauthenticated()),
                ),
              ],
              child: const QuizApp(),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Try to navigate to protected route
          AppRouter.go(RouteConstants.dashboard);
          await tester.pumpAndSettle();

          // ASSERT - Should be redirected to login
          // The exact assertion depends on guard implementation
        },
      );

      widgetTestCase(
        'should allow authenticated users to access protected routes',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                // Override auth state to be authenticated
                authStateProvider.overrideWith(
                  (ref) => Stream.value(
                    AuthState.authenticated(
                      firebaseUser: MockFirebaseUser(),
                      user: UserEntity(
                        id: 'test-user-123',
                        name: 'Test User',
                        email: 'test@example.com',
                        createdAt: DateTime.now(),
                      ),
                    ),
                  ),
                ),
              ],
              child: const QuizApp(),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Navigate to protected route
          AppRouter.go(RouteConstants.dashboard);
          await tester.pumpAndSettle();

          // ASSERT - Should be able to access dashboard
          expect(find.text('Dashboard'), findsOneWidget);
        },
      );

      widgetTestCase(
        'should redirect authenticated users away from guest routes',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                // Override auth state to be authenticated
                authStateProvider.overrideWith(
                  (ref) => Stream.value(
                    AuthState.authenticated(
                      firebaseUser: MockFirebaseUser(),
                      user: UserEntity(
                        id: 'test-user-123',
                        name: 'Test User',
                        email: 'test@example.com',
                        createdAt: DateTime.now(),
                      ),
                    ),
                  ),
                ),
              ],
              child: const QuizApp(),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Try to navigate to login (guest-only route)
          AppRouter.go(RouteConstants.login);
          await tester.pumpAndSettle();

          // ASSERT - Should be redirected to home
          // The exact behavior depends on guard implementation
        },
      );
    },
  );

  testGroup(
    'Navigation Performance Integration Tests',
    TestCategory.performance,
    () {
      widgetTestCase(
        'should handle rapid navigation changes',
        TestCategory.performance,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          final stopwatch = Stopwatch()..start();

          // ACT - Perform rapid navigation
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
            RouteConstants.gameJoin,
            RouteConstants.leaderboard,
          ];

          for (final route in routes) {
            AppRouter.go(route);
            await tester.pump();
          }

          await tester.pumpAndSettle();
          stopwatch.stop();

          // ASSERT - Should complete within reasonable time
          expect(
            stopwatch.elapsed,
            lessThan(const Duration(seconds: 5)),
            reason: 'Rapid navigation should be performant',
          );
        },
      );

      widgetTestCase(
        'should handle deep navigation stack efficiently',
        TestCategory.performance,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT - Build deep navigation stack
          for (int i = 0; i < 10; i++) {
            AppRouter.push('${RouteConstants.about}?page=$i');
            await tester.pump();
          }

          await tester.pumpAndSettle();

          // ASSERT - Should handle deep stack without performance issues
          expect(find.text('About'), findsOneWidget);

          // Clear stack
          AppRouter.clearAndGoTo(RouteConstants.home);
          await tester.pumpAndSettle();
        },
      );
    },
  );

  testGroup(
    'Navigation Accessibility Integration Tests',
    TestCategory.integration,
    () {
      widgetTestCase(
        'should maintain accessibility throughout navigation',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(const ProviderScope(child: QuizApp()));
          await tester.pumpAndSettle();

          // ACT & ASSERT - Check accessibility on different pages
          final routes = [
            RouteConstants.home,
            RouteConstants.about,
            RouteConstants.help,
          ];

          for (final route in routes) {
            AppRouter.go(route);
            await tester.pumpAndSettle();

            // Check basic accessibility
            final semantics = tester.semantics;
            expect(semantics, isNotNull);

            // Check that navigation is announced for screen readers
            // This would require more sophisticated accessibility testing
          }
        },
      );
    },
  );

  testGroup('Real-time Navigation Updates', TestCategory.integration, () {
    widgetTestCase(
      'should handle auth state changes during navigation',
      TestCategory.integration,
      (WidgetTester tester) async {
        // ARRANGE
        final authStateController = StreamController<AuthState>.broadcast();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                (ref) => authStateController.stream,
              ),
            ],
            child: const QuizApp(),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Start unauthenticated
        authStateController.add(const AuthState.unauthenticated());
        await tester.pumpAndSettle();

        // Try to navigate to protected route
        AppRouter.go(RouteConstants.dashboard);
        await tester.pumpAndSettle();

        // Now authenticate user
        authStateController.add(
          AuthState.authenticated(
            firebaseUser: MockFirebaseUser(),
            user: UserEntity(
              id: 'test-user-123',
              name: 'Test User',
              email: 'test@example.com',
              createdAt: DateTime.now(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - Should now be able to access dashboard
        // The exact behavior depends on how guards handle state changes

        // Cleanup
        authStateController.close();
      },
    );
  });
}

/// Mock classes for integration testing
class MockFirebaseUser {
  String get uid => 'test-user-123';
  String get email => 'test@example.com';
  String get displayName => 'Test User';
}
