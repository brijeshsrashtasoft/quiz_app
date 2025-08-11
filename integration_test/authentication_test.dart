import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;

/// Authentication integration tests
/// Tests user authentication flow with actual test users
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Tests', () {
    // Test credentials (should match actual Firebase users)
    const testUsers = {
      'host': {'email': 'brijesh@yopmail.com', 'password': 'Brijesh@123'},
      'player1': {'email': 'ayushi@yopmail.com', 'password': 'Ayushi@123'},
      'player2': {'email': 'pankaj@yopmail.com', 'password': 'Pankaj!@#123'},
    };

    /// Helper to sign in a user
    Future<bool> signInUser(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      try {
        // Navigate to login
        final loginButton = find.text('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle();
        } else {
          return false;
        }

        // Find and fill email field
        final emailFields = find.byType(TextFormField);
        if (emailFields.evaluate().length >= 2) {
          await tester.enterText(emailFields.at(0), email);
          await tester.pumpAndSettle();

          // Fill password field
          await tester.enterText(emailFields.at(1), password);
          await tester.pumpAndSettle();

          // Tap login button
          final signInButton = find.text('Sign In');
          if (signInButton.evaluate().isNotEmpty) {
            await tester.tap(signInButton);
            await tester.pumpAndSettle(const Duration(seconds: 5));

            // Check for success indicators
            final successIndicators = [
              find.textContaining('Good'),
              find.text('Quick Actions'),
              find.text('Create Quiz'),
            ];

            for (final indicator in successIndicators) {
              if (indicator.evaluate().isNotEmpty) {
                return true;
              }
            }
          }
        }
        return false;
      } catch (e) {
        debugPrint('Sign in error: $e');
        return false;
      }
    }

    testWidgets(
      'Host user can sign in successfully',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final hostUser = testUsers['host']!;
        final success = await signInUser(
          tester,
          hostUser['email']!,
          hostUser['password']!,
        );

        expect(success, isTrue, reason: 'Host user should be able to sign in');

        // Verify user is on home screen
        expect(find.text('Create Quiz'), findsAtLeastNWidgets(1));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Player 1 can sign in successfully',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final player1 = testUsers['player1']!;
        final success = await signInUser(
          tester,
          player1['email']!,
          player1['password']!,
        );

        expect(success, isTrue, reason: 'Player 1 should be able to sign in');

        // Verify user is on home screen
        expect(find.text('Join Game'), findsAtLeastNWidgets(1));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Player 2 can sign in successfully',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final player2 = testUsers['player2']!;
        final success = await signInUser(
          tester,
          player2['email']!,
          player2['password']!,
        );

        expect(success, isTrue, reason: 'Player 2 should be able to sign in');

        // Verify user is on home screen
        expect(find.text('Host Game'), findsAtLeastNWidgets(1));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Invalid credentials show error',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Try to sign in with invalid credentials
        final loginButton = find.text('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          final emailFields = find.byType(TextFormField);
          if (emailFields.evaluate().length >= 2) {
            await tester.enterText(emailFields.at(0), 'invalid@test.com');
            await tester.enterText(emailFields.at(1), 'wrongpassword');
            await tester.pumpAndSettle();

            final signInButton = find.text('Sign In');
            if (signInButton.evaluate().isNotEmpty) {
              await tester.tap(signInButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));

              // Should still be on login page or show error
              final stillOnLogin =
                  find.byType(TextFormField).evaluate().length >= 2;
              expect(
                stillOnLogin,
                isTrue,
                reason: 'Should remain on login page for invalid credentials',
              );
            }
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'Can navigate between auth pages',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Navigate to register from home
        final signUpButton = find.text('Sign Up');
        if (signUpButton.evaluate().isNotEmpty) {
          await tester.tap(signUpButton);
          await tester.pumpAndSettle();

          // Should be on register page
          expect(find.byType(TextFormField), findsAtLeastNWidgets(2));

          // Navigate back to login if link exists
          final signInLink = find.text('Sign In');
          if (signInLink.evaluate().isNotEmpty) {
            await tester.tap(signInLink);
            await tester.pumpAndSettle();

            // Should be on login page
            expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    tearDown(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });

    tearDownAll(() async {
      debugPrint('Authentication tests completed');
    });
  });
}
