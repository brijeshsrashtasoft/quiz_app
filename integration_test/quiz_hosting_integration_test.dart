import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;

/// Integration tests for quiz hosting and joining functionality
/// Tests the complete end-to-end flow of creating, hosting, and joining quiz games
///
/// Test Users:
/// - Host: brijesh@yopmail.com (password: Brijesh@123)
/// - Player 1: ayushi@yopmail.com (password: Ayushi@123)
/// - Player 2: pankaj@yopmail.com (password: Pankaj!@#123)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quiz Hosting and Joining Integration Tests', () {
    // Test helper methods
    Future<void> signInUser(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      // Navigate to sign in
      await tester.tap(find.text('Sign Up with Email'));
      await tester.pumpAndSettle();

      // Navigate to login if on register page
      final signInLink = find.text('Sign In');
      if (signInLink.evaluate().isNotEmpty) {
        await tester.tap(signInLink);
        await tester.pumpAndSettle();
      }

      // Fill email field
      final emailField = find.byType(TextFormField).at(0);
      await tester.enterText(emailField, email);
      await tester.pumpAndSettle();

      // Fill password field
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, password);
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    Future<void> signOutCurrentUser(WidgetTester tester) async {
      // Navigate to profile or find logout option
      final profileButton = find.byIcon(Icons.person);
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton);
        await tester.pumpAndSettle();

        final logoutButton = find.text('Sign Out');
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pumpAndSettle();
        }
      }
    }

    Future<String> createAndHostQuiz(WidgetTester tester) async {
      // Navigate to quiz creation
      await tester.tap(find.text('Create Quiz'));
      await tester.pumpAndSettle();

      // Create a simple test quiz
      // Fill quiz title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Integration Test Quiz');
      await tester.pumpAndSettle();

      // Add a question (simplified for integration test)
      await tester.tap(find.text('Add Question'));
      await tester.pumpAndSettle();

      // Fill question text
      final questionField = find.byType(TextFormField).first;
      await tester.enterText(questionField, 'What is 2 + 2?');
      await tester.pumpAndSettle();

      // Add answer options (assuming multiple choice)
      final option1Field = find.byType(TextFormField).at(1);
      await tester.enterText(option1Field, '3');
      await tester.pumpAndSettle();

      final option2Field = find.byType(TextFormField).at(2);
      await tester.enterText(option2Field, '4');
      await tester.pumpAndSettle();

      final option3Field = find.byType(TextFormField).at(3);
      await tester.enterText(option3Field, '5');
      await tester.pumpAndSettle();

      final option4Field = find.byType(TextFormField).at(4);
      await tester.enterText(option4Field, '6');
      await tester.pumpAndSettle();

      // Mark correct answer (option 2)
      await tester.tap(find.byIcon(Icons.check_circle_outline).at(1));
      await tester.pumpAndSettle();

      // Save question
      await tester.tap(find.text('Save Question'));
      await tester.pumpAndSettle();

      // Publish quiz
      await tester.tap(find.text('Publish Quiz'));
      await tester.pumpAndSettle();

      // Start hosting
      await tester.tap(find.text('Host Game'));
      await tester.pumpAndSettle();

      // Extract PIN from display
      final pinDisplay = find.textContaining(RegExp(r'\d{6}'));
      expect(pinDisplay, findsOneWidget);

      final pinText = tester.widget<Text>(pinDisplay).data!;
      final pin = RegExp(r'\d{6}').firstMatch(pinText)?.group(0) ?? '';

      expect(pin.length, equals(6));
      return pin;
    }

    Future<void> joinGameWithPin(
      WidgetTester tester,
      String pin,
      String nickname,
    ) async {
      // Navigate to join game
      await tester.tap(find.text('Join Game'));
      await tester.pumpAndSettle();

      // Enter PIN
      for (int i = 0; i < pin.length; i++) {
        await tester.enterText(find.byType(TextFormField), pin[i]);
        await tester.pumpAndSettle();
      }

      // Submit PIN
      await tester.tap(find.text('Enter'));
      await tester.pumpAndSettle();

      // Enter nickname
      await tester.enterText(find.byType(TextFormField), nickname);
      await tester.pumpAndSettle();

      // Join game
      await tester.tap(find.text('Join Game'));
      await tester.pumpAndSettle();
    }

    // Core hosting and joining flow test
    testWidgets(
      'should allow host to create quiz and players to join successfully',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test Phase 1: Host creates and hosts quiz (Brijesh)
        await signInUser(tester, 'brijesh@yopmail.com', 'Brijesh@123');

        // Verify host is signed in
        expect(find.textContaining('Welcome'), findsAtLeastNWidgets(1));

        final gamePin = await createAndHostQuiz(tester);

        // Verify hosting screen is displayed
        expect(find.text('Players can join using this PIN'), findsOneWidget);
        expect(find.textContaining(gamePin), findsOneWidget);
        expect(find.text('0 Players'), findsOneWidget);

        // Sign out host for now
        await signOutCurrentUser(tester);

        // Test Phase 2: Player 1 joins (Ayushi)
        await signInUser(tester, 'ayushi@yopmail.com', 'Ayushi@123');

        await joinGameWithPin(tester, gamePin, 'Ayushi');

        // Verify player joined lobby
        expect(
          find.textContaining('Waiting for game to start'),
          findsAtLeastNWidgets(1),
        );

        await signOutCurrentUser(tester);

        // Test Phase 3: Player 2 joins (Pankaj)
        await signInUser(tester, 'pankaj@yopmail.com', 'Pankaj!@#123');

        await joinGameWithPin(tester, gamePin, 'Pankaj');

        // Verify second player joined
        expect(
          find.textContaining('Waiting for game to start'),
          findsAtLeastNWidgets(1),
        );

        await signOutCurrentUser(tester);

        // Test Phase 4: Host starts the game
        await signInUser(tester, 'brijesh@yopmail.com', 'Brijesh@123');

        // Navigate back to hosting screen
        await tester.tap(find.text('Host Game'));
        await tester.pumpAndSettle();

        // Verify 2 players joined
        expect(find.text('2 Players'), findsOneWidget);

        // Start the game
        await tester.tap(find.text('Start Game'));
        await tester.pumpAndSettle();

        // Verify game started
        expect(
          find.textContaining('Game in Progress'),
          findsAtLeastNWidgets(1),
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    // Error handling and validation tests
    group('Quiz Hosting Error Handling', () {
      testWidgets('should handle invalid quiz creation gracefully', (
        WidgetTester tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await signInUser(tester, 'brijesh@yopmail.com', 'Brijesh@123');

        // Try to create quiz without required fields
        await tester.tap(find.text('Create Quiz'));
        await tester.pumpAndSettle();

        // Attempt to publish without title or questions
        final publishButton = find.text('Publish Quiz');
        if (publishButton.evaluate().isNotEmpty) {
          await tester.tap(publishButton);
          await tester.pumpAndSettle();

          // Should show validation error
          expect(find.textContaining('required'), findsAtLeastNWidgets(1));
        }
      });

      testWidgets('should handle invalid PIN entry gracefully', (
        WidgetTester tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await signInUser(tester, 'ayushi@yopmail.com', 'Ayushi@123');

        // Try to join with invalid PIN
        await tester.tap(find.text('Join Game'));
        await tester.pumpAndSettle();

        // Enter invalid PIN
        await tester.enterText(find.byType(TextFormField), '000000');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Enter'));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.textContaining('Invalid'), findsAtLeastNWidgets(1));
      });
    });

    // Authentication flow tests
    group('Authentication Integration', () {
      testWidgets('should authenticate all test users successfully', (
        WidgetTester tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test Brijesh authentication
        await signInUser(tester, 'brijesh@yopmail.com', 'Brijesh@123');
        expect(find.textContaining('Welcome'), findsAtLeastNWidgets(1));
        await signOutCurrentUser(tester);

        // Test Ayushi authentication
        await signInUser(tester, 'ayushi@yopmail.com', 'Ayushi@123');
        expect(find.textContaining('Welcome'), findsAtLeastNWidgets(1));
        await signOutCurrentUser(tester);

        // Test Pankaj authentication
        await signInUser(tester, 'pankaj@yopmail.com', 'Pankaj!@#123');
        expect(find.textContaining('Welcome'), findsAtLeastNWidgets(1));
        await signOutCurrentUser(tester);
      });

      testWidgets('should handle authentication errors gracefully', (
        WidgetTester tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test with wrong password
        await tester.tap(find.text('Sign Up with Email'));
        await tester.pumpAndSettle();

        final signInLink = find.text('Sign In');
        if (signInLink.evaluate().isNotEmpty) {
          await tester.tap(signInLink);
          await tester.pumpAndSettle();
        }

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'brijesh@yopmail.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'wrongpassword',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show error message
        expect(find.textContaining('Invalid'), findsAtLeastNWidgets(1));
      });
    });

    // Performance and stability tests
    group('Performance and Stability', () {
      testWidgets('should handle rapid user interactions without crashes', (
        WidgetTester tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await signInUser(tester, 'brijesh@yopmail.com', 'Brijesh@123');

        // Rapidly navigate between screens
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Create Quiz'));
          await tester.pumpAndSettle();

          await tester.pageBack();
          await tester.pumpAndSettle();

          await tester.tap(find.text('Join Game'));
          await tester.pumpAndSettle();

          await tester.pageBack();
          await tester.pumpAndSettle();
        }

        // Should not crash
        expect(tester.takeException(), isNull);
      });

      testWidgets('should maintain consistent performance during game flow', (
        WidgetTester tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await signInUser(tester, 'brijesh@yopmail.com', 'Brijesh@123');

        stopwatch.stop();

        // Authentication should complete within reasonable time
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(15000),
        ); // 15 seconds max

        // App should remain responsive
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    // Real-time functionality tests (placeholder)
    group('Real-time Game Features', () {
      testWidgets('should handle real-time player updates - PLACEHOLDER', (
        WidgetTester tester,
      ) async {
        // TODO: Implement real-time player joining/leaving tests
        // This would require more complex coordination between multiple
        // app instances or mocked real-time updates

        app.main();
        await tester.pumpAndSettle();

        // For now, just verify app launches
        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets('should sync game state across all players - PLACEHOLDER', (
        WidgetTester tester,
      ) async {
        // TODO: Implement game state synchronization tests
        // This would test question progression, answer submission,
        // and leaderboard updates in real-time

        app.main();
        await tester.pumpAndSettle();

        // For now, just verify app launches
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    // Network and connectivity tests (placeholder)
    group('Network and Connectivity', () {
      testWidgets(
        'should handle network interruptions gracefully - PLACEHOLDER',
        (WidgetTester tester) async {
          // TODO: Implement network failure simulation
          // Test offline/online transitions during game

          app.main();
          await tester.pumpAndSettle();

          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );

      testWidgets(
        'should recover from Firebase connection issues - PLACEHOLDER',
        (WidgetTester tester) async {
          // TODO: Implement Firebase connection recovery tests
          // Test Firestore reconnection and data sync

          app.main();
          await tester.pumpAndSettle();

          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );
    });

    // Game mechanics tests (placeholder)
    group('Game Mechanics', () {
      testWidgets('should handle answer submission and scoring - PLACEHOLDER', (
        WidgetTester tester,
      ) async {
        // TODO: Implement answer submission flow tests
        // Test question display, answer selection, time limits

        app.main();
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets(
        'should calculate and display leaderboard correctly - PLACEHOLDER',
        (WidgetTester tester) async {
          // TODO: Implement leaderboard calculation tests
          // Test score calculation, ranking, final results

          app.main();
          await tester.pumpAndSettle();

          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );
    });

    // Edge cases and boundary tests
    group('Edge Cases and Boundaries', () {
      testWidgets('should handle maximum player limit - PLACEHOLDER', (
        WidgetTester tester,
      ) async {
        // TODO: Test maximum concurrent players

        app.main();
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets(
        'should handle host disconnection during game - PLACEHOLDER',
        (WidgetTester tester) async {
          // TODO: Test host leaving mid-game

          app.main();
          await tester.pumpAndSettle();

          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );

      testWidgets(
        'should handle quiz with no questions or invalid data - PLACEHOLDER',
        (WidgetTester tester) async {
          // TODO: Test edge case quiz configurations

          app.main();
          await tester.pumpAndSettle();

          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );
    });

    // Security and validation tests
    group('Security and Validation', () {
      testWidgets(
        'should validate user permissions for hosting - PLACEHOLDER',
        (WidgetTester tester) async {
          // TODO: Test that only authenticated users can host

          app.main();
          await tester.pumpAndSettle();

          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );

      testWidgets('should prevent unauthorized game access - PLACEHOLDER', (
        WidgetTester tester,
      ) async {
        // TODO: Test game access controls

        app.main();
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}
