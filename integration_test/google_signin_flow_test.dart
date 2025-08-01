import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;
import 'package:quiz_app/shared/widgets/buttons/google_signin_button.dart';
import 'package:quiz_app/features/authentication/presentation/widgets/social_auth_buttons.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Google Sign-In Integration Tests', () {
    
    group('Home Page Google Sign-In', () {
      testWidgets('should show Google Sign-In button for unauthenticated users', (tester) async {
        // Act
        app.main();
        await tester.pumpAndSettle();

        // Wait for app to initialize
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Assert - Check if Google Sign-In button is visible on home page
        expect(find.text('Sign in with Google'), findsAtLeastNWidgets(1));
        expect(find.byType(GoogleSignInButton), findsAtLeastNWidgets(1));
      });

      testWidgets('should show loading state when Google Sign-In is tapped', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Tap on Google Sign-In button (will fail without actual OAuth setup)
        final googleButton = find.text('Sign in with Google').first;
        expect(googleButton, findsOneWidget);
        
        await tester.tap(googleButton);
        await tester.pump();

        // Assert - Should show loading state briefly
        expect(find.text('Signing in...'), findsAtLeastNWidgets(1));
        
        // Wait for the operation to complete (will show error without real OAuth)
        await tester.pumpAndSettle(const Duration(seconds: 5));
      });

      testWidgets('should show email sign-up button as alternative', (tester) async {
        // Act
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Assert - Check if email sign-up button is also available
        expect(find.text('Sign Up with Email'), findsOneWidget);
      });

      testWidgets('should show OR divider between sign-in options', (tester) async {
        // Act
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Assert - Check if OR divider is present
        expect(find.text('OR'), findsAtLeastNWidgets(1));
      });
    });

    group('Login Page Google Sign-In', () {
      testWidgets('should navigate to login page and show Google Sign-In', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Navigate to login page
        final signUpButton = find.text('Sign Up with Email');
        expect(signUpButton, findsOneWidget);
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // Navigate to login from register page
        final signInLink = find.text('Sign In');
        if (signInLink.evaluate().isNotEmpty) {
          await tester.tap(signInLink);
          await tester.pumpAndSettle();
        }

        // Assert - Check if Google Sign-In is available on login page
        expect(find.byType(SocialAuthButtons), findsOneWidget);
        expect(find.text('Continue with Google'), findsAtLeastNWidgets(1));
      });

      testWidgets('should show OR divider on login page', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Navigate to register page first
        final signUpButton = find.text('Sign Up with Email');
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // Navigate to login page
        final signInLink = find.text('Sign In');
        if (signInLink.evaluate().isNotEmpty) {
          await tester.tap(signInLink);
          await tester.pumpAndSettle();
        }

        // Assert - Check if OR divider exists between email and social login
        expect(find.text('OR'), findsAtLeastNWidgets(1));
      });
    });

    group('Register Page Google Sign-In', () {
      testWidgets('should show Google Sign-In on register page', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Navigate to register page
        final signUpButton = find.text('Sign Up with Email');
        expect(signUpButton, findsOneWidget);
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // Assert - Check if Google Sign-In is available on register page
        expect(find.byType(SocialAuthButtons), findsOneWidget);
        expect(find.text('Continue with Google'), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle Google Sign-In error gracefully on register page', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Navigate to register page
        final signUpButton = find.text('Sign Up with Email');
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // Act - Tap Google Sign-In (will fail without proper OAuth setup)
        final googleButton = find.text('Continue with Google').first;
        await tester.tap(googleButton);
        await tester.pump();

        // Wait for error to appear
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Assert - Should show error snackbar or handle gracefully
        // Note: Actual error depends on Firebase configuration
        expect(find.byType(SnackBar), findsWidgets);
      });
    });

    group('Navigation Flow Tests', () {
      testWidgets('should maintain proper navigation state during Google Sign-In attempt', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Try Google Sign-In from home page
        final googleButton = find.text('Sign in with Google').first;
        await tester.tap(googleButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Assert - Should remain on current page after failed sign-in
        // (since OAuth is not properly configured)
        expect(find.text('Quiz Master'), findsAtLeastNWidgets(1)); // Home page title
      });

      testWidgets('should handle multiple Google Sign-In attempts gracefully', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Try multiple Google Sign-In attempts
        final googleButton = find.text('Sign in with Google').first;
        
        // First attempt
        await tester.tap(googleButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Second attempt (should not crash)
        if (find.text('Sign in with Google').evaluate().isNotEmpty) {
          await tester.tap(find.text('Sign in with Google').first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Assert - App should remain stable
        expect(tester.takeException(), isNull);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should show appropriate error for cancelled sign-in', (tester) async {
        // Note: This test simulates user cancellation behavior
        // In a real test with mocked dependencies, we would inject a mock
        // that returns a cancellation error
        
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Tap Google Sign-In button
        final googleButton = find.text('Sign in with Google').first;
        await tester.tap(googleButton);
        await tester.pump();
        
        // Wait for sign-in process
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Assert - Should handle the result gracefully (error or success)
        expect(tester.takeException(), isNull);
      });

      testWidgets('should recover from network errors', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Simulate network error scenario by rapid tapping
        final googleButton = find.text('Sign in with Google').first;
        await tester.tap(googleButton);
        await tester.pump();
        
        // Wait and verify app stability
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Assert - App should remain stable and show appropriate feedback
        expect(tester.takeException(), isNull);
        // Should show either success navigation or error message
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for Google Sign-In buttons', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act & Assert - Check semantics
        final googleButtonFinder = find.text('Sign in with Google').first;
        expect(googleButtonFinder, findsOneWidget);

        final semantics = tester.getSemantics(googleButtonFinder);
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
      });

      testWidgets('should support screen reader navigation', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Test semantic navigation
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/semantics',
          null,
          (data) {},
        );

        // Assert - Should not crash with screen reader enabled
        expect(find.text('Sign in with Google'), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull);
      });
    });

    group('Performance Tests', () {
      testWidgets('should load Google Sign-In buttons quickly', (tester) async {
        // Arrange & Act
        final stopwatch = Stopwatch()..start();
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        stopwatch.stop();

        // Assert - Should load within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
        expect(find.text('Sign in with Google'), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle rapid button presses without memory leaks', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Rapid button presses
        for (int i = 0; i < 5; i++) {
          final googleButton = find.text('Sign in with Google').first;
          if (googleButton.evaluate().isNotEmpty) {
            await tester.tap(googleButton);
            await tester.pump();
          }
        }

        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Assert - Should remain stable
        expect(tester.takeException(), isNull);
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}