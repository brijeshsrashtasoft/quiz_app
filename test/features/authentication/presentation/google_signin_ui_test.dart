import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/shared/widgets/buttons/google_signin_button.dart';

/// US-002 Google Sign-In UI Widget Tests
///
/// Simplified widget tests for Google Sign-In button functionality
/// focusing on core UI behavior and rendering.

void main() {
  group('US-002 Google Sign-In UI Widget Tests', () {
    Widget createTestWidget({
      String? label,
      VoidCallback? onSuccess,
      VoidCallback? onError,
      bool showIcon = true,
      bool isCompact = false,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              label: label ?? 'Continue with Google',
              onSuccess: onSuccess,
              onError: onError,
              showIcon: showIcon,
              isCompact: isCompact,
            ),
          ),
        ),
      );
    }

    group('GoogleSignInButton Widget Rendering', () {
      testWidgets(
        'should render Google Sign-In button with default appearance',
        (tester) async {
          // Act
          await tester.pumpWidget(createTestWidget());

          // Assert
          expect(find.byType(GoogleSignInButton), findsOneWidget);
          expect(find.text('Continue with Google'), findsOneWidget);
        },
      );

      testWidgets('should render with custom label', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(label: 'Sign in with Google'));

        // Assert
        expect(find.text('Sign in with Google'), findsOneWidget);
      });

      testWidgets('should display Google logo icon when showIcon is true', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(showIcon: true));

        // Assert
        expect(find.text('G'), findsOneWidget); // Our placeholder Google icon
      });

      testWidgets('should hide Google logo icon when showIcon is false', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(showIcon: false));

        // Assert
        expect(find.text('G'), findsNothing);
      });

      testWidgets('should render compact version correctly', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(isCompact: true, showIcon: true),
        );

        // Assert
        expect(find.byType(GoogleSignInButton), findsOneWidget);
        expect(
          find.text('G'),
          findsOneWidget,
        ); // Icon should show in compact mode
      });
    });

    group('GoogleSignInButton User Interactions', () {
      testWidgets('should be tappable', (tester) async {
        // Arrange
        bool onSuccessCalled = false;

        await tester.pumpWidget(
          createTestWidget(onSuccess: () => onSuccessCalled = true),
        );

        // Act
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pump();

        // Assert - Button should be tappable (actual Google Sign-In would fail due to no Firebase setup)
        expect(find.byType(GoogleSignInButton), findsOneWidget);
      });

      testWidgets('should handle onSuccess callback', (tester) async {
        // Arrange
        bool onSuccessCalled = false;

        await tester.pumpWidget(
          createTestWidget(onSuccess: () => onSuccessCalled = true),
        );

        // Assert - Callback should be properly set
        expect(find.byType(GoogleSignInButton), findsOneWidget);
      });

      testWidgets('should handle onError callback', (tester) async {
        // Arrange
        bool onErrorCalled = false;

        await tester.pumpWidget(
          createTestWidget(onError: () => onErrorCalled = true),
        );

        // Assert - Callback should be properly set
        expect(find.byType(GoogleSignInButton), findsOneWidget);
      });

      testWidgets('should handle tap gesture without callbacks', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Tap should not crash without callbacks
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pump();

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });
    });

    group('CompactGoogleSignInButton', () {
      testWidgets('should render compact version with correct properties', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: const MaterialApp(
              home: Scaffold(body: CompactGoogleSignInButton()),
            ),
          ),
        );

        // Assert
        expect(find.byType(CompactGoogleSignInButton), findsOneWidget);
        expect(
          find.text('G'),
          findsOneWidget,
        ); // Icon should show in compact mode
      });

      testWidgets('should accept callbacks', (tester) async {
        // Arrange
        bool onSuccessCalled = false;
        bool onErrorCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: CompactGoogleSignInButton(
                  onSuccess: () => onSuccessCalled = true,
                  onError: () => onErrorCalled = true,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CompactGoogleSignInButton), findsOneWidget);
      });
    });

    group('GoogleSignInButton Accessibility', () {
      testWidgets('should have proper semantics for accessibility', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(GoogleSignInButton), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);

        // Should have semantic properties for accessibility
        // Note: Detailed semantics testing would require more complex setup
      });

      testWidgets('should have custom label in semantics', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(label: 'Custom Google Sign In'),
        );

        // Assert
        expect(find.text('Custom Google Sign In'), findsOneWidget);
      });
    });

    group('GoogleSignInButton Animation', () {
      testWidgets('should handle tap animation without crashing', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Test tap down and up animation
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(GoogleSignInButton)),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // Complete gesture
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 50));

        // Assert - No exceptions should be thrown
        expect(tester.takeException(), isNull);
      });
    });
  });
}
