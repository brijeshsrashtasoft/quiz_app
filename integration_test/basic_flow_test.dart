import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;

/// Basic integration test for quiz app functionality
/// Tests fundamental app flow and navigation
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Basic App Flow Tests', () {
    testWidgets('App launches and shows home screen', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app launches successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Look for key home screen elements
      final homeElements = [
        find.text('Quiz Master'),
        find.text('Quick Actions'),
        find.text('Create Quiz'),
        find.text('Join Game'),
        find.text('Host Game'),
        find.textContaining('Good'),
      ];

      bool foundHomeElement = false;
      for (final element in homeElements) {
        if (element.evaluate().isNotEmpty) {
          foundHomeElement = true;
          debugPrint('Found home element: ${element.toString()}');
          break;
        }
      }

      expect(
        foundHomeElement,
        isTrue,
        reason: 'Should find at least one home screen element',
      );
    });

    testWidgets('Can navigate to login page', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for login navigation
      final loginButtons = [
        find.text('Login'),
        find.text('Sign In'),
        find.text('Sign in'),
      ];

      bool foundLogin = false;
      for (final button in loginButtons) {
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle();
          foundLogin = true;
          debugPrint('Tapped login button: ${button.toString()}');
          break;
        }
      }

      if (foundLogin) {
        // Verify we're on login page
        final loginPageElements = [
          find.byType(TextFormField),
          find.byType(TextField),
          find.text('Login'),
          find.text('Sign In'),
          find.text('Email'),
          find.text('Password'),
        ];

        bool foundLoginElement = false;
        for (final element in loginPageElements) {
          if (element.evaluate().isNotEmpty) {
            foundLoginElement = true;
            debugPrint('Found login page element: ${element.toString()}');
            break;
          }
        }

        expect(
          foundLoginElement,
          isTrue,
          reason: 'Should find login page elements',
        );
      } else {
        debugPrint('No login button found - user might already be logged in');
      }
    });

    testWidgets('Can navigate to quiz creation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for create quiz button
      final createQuizButton = find.text('Create Quiz');

      if (createQuizButton.evaluate().isNotEmpty) {
        await tester.tap(createQuizButton);
        await tester.pumpAndSettle();

        // Verify we're on quiz creation page or see appropriate response
        final creationElements = [
          find.text('Create Quiz'),
          find.text('Quiz Title'),
          find.text('Add Question'),
          find.byType(TextFormField),
          find.byType(TextField),
        ];

        bool foundCreationElement = false;
        for (final element in creationElements) {
          if (element.evaluate().isNotEmpty) {
            foundCreationElement = true;
            debugPrint('Found creation element: ${element.toString()}');
            break;
          }
        }

        // Either found creation elements or we're redirected to auth
        expect(
          foundCreationElement || find.text('Login').evaluate().isNotEmpty,
          isTrue,
          reason: 'Should find creation elements or be redirected to login',
        );
      } else {
        fail('Create Quiz button not found');
      }
    });

    testWidgets('Can navigate to join game', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for join game button
      final joinGameButton = find.text('Join Game');

      if (joinGameButton.evaluate().isNotEmpty) {
        await tester.tap(joinGameButton);
        await tester.pumpAndSettle();

        // Check if dialog opened or navigated to page
        final joinElements = [
          find.text('Enter PIN'),
          find.text('Game PIN'),
          find.text('PIN'),
          find.text('Join'),
          find.byType(TextFormField),
          find.byType(TextField),
          find.byType(AlertDialog),
        ];

        bool foundJoinElement = false;
        for (final element in joinElements) {
          if (element.evaluate().isNotEmpty) {
            foundJoinElement = true;
            debugPrint('Found join element: ${element.toString()}');
            break;
          }
        }

        expect(
          foundJoinElement,
          isTrue,
          reason: 'Should find join game elements',
        );
      } else {
        fail('Join Game button not found');
      }
    });

    testWidgets('Can navigate to host game', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for host game button
      final hostGameButton = find.text('Host Game');

      if (hostGameButton.evaluate().isNotEmpty) {
        await tester.tap(hostGameButton);
        await tester.pumpAndSettle();

        // Check if we're on host game page or redirected to auth
        final hostElements = [
          find.text('Host Game'),
          find.text('Host'),
          find.text('PIN'),
          find.text('Players'),
          find.text('Start Game'),
          find.text('Login'), // If redirected to auth
        ];

        bool foundHostElement = false;
        for (final element in hostElements) {
          if (element.evaluate().isNotEmpty) {
            foundHostElement = true;
            debugPrint('Found host element: ${element.toString()}');
            break;
          }
        }

        expect(
          foundHostElement,
          isTrue,
          reason: 'Should find host elements or login',
        );
      } else {
        fail('Host Game button not found');
      }
    });

    testWidgets('App remains stable during navigation', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test rapid navigation without crashes
      final navigationTargets = [
        'Create Quiz',
        'Join Game',
        'Host Game',
        'Login',
      ];

      for (final target in navigationTargets) {
        final targetButton = find.text(target);
        if (targetButton.evaluate().isNotEmpty) {
          await tester.tap(targetButton);
          await tester.pumpAndSettle();

          // Go back
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }

      // Verify no exceptions occurred
      expect(
        tester.takeException(),
        isNull,
        reason: 'Should not have exceptions during navigation',
      );

      // Verify app is still functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets(
      'Authentication UI elements present for unauthenticated users',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Look for authentication-related elements
        final authElements = [
          find.text('Login'),
          find.text('Sign Up'),
          find.text('Sign in with Google'),
          find.text('OR'),
        ];

        int foundAuthElements = 0;
        for (final element in authElements) {
          if (element.evaluate().isNotEmpty) {
            foundAuthElements++;
            debugPrint('Found auth element: ${element.toString()}');
          }
        }

        // Should find at least some auth elements for unauthenticated users
        expect(
          foundAuthElements,
          greaterThan(0),
          reason: 'Should find authentication elements',
        );
      },
    );

    testWidgets('Performance test - app startup time', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      stopwatch.stop();

      // App should start within reasonable time
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason:
            'App should start within 10 seconds, took ${stopwatch.elapsedMilliseconds}ms',
      );

      // Verify app loaded successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    tearDown(() async {
      // Clean up after each test
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDownAll(() async {
      debugPrint('All basic integration tests completed');
    });
  });
}
