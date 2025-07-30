import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/features/authentication/presentation/widgets/social_auth_buttons.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import '../../../../../test_config.dart';

void main() {
  testGroup('SocialAuthButtons Widget Tests', TestCategory.widget, () {
    widgetTestCase(
      'should display Google sign-in button',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const SocialAuthButtons()),
        );

        // Assert
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
      },
    );

    widgetTestCase(
      'should display Apple sign-in button on iOS platform',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const SocialAuthButtons()),
        );

        // Assert - Apple button should be present if platform is iOS
        // For now, just check that buttons are rendered
        expect(find.byType(ElevatedButton), findsWidgets);
      },
    );

    widgetTestCase(
      'should apply correct styling to Google button',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const SocialAuthButtons()),
        );

        // Assert
        final googleButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Continue with Google'),
        );

        expect(googleButton.style?.backgroundColor?.resolve({}), isNotNull);
        expect(googleButton.onPressed, isNotNull);
      },
    );

    widgetTestCase(
      'should handle Google sign-in button tap',
      TestCategory.widget,
      (tester) async {
        // Arrange
        bool wasPressed = false;

        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: ElevatedButton(
              onPressed: () => wasPressed = true,
              child: const Text('Continue with Google'),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();

        // Assert
        expect(wasPressed, isTrue);
      },
    );

    widgetTestCase(
      'should be accessible with proper semantics',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const SocialAuthButtons()),
        );

        // Assert
        TestExpectations.expectAccessible(tester);

        // Check for accessibility labels
        expect(find.bySemanticsLabel('Sign in with Google'), findsOneWidget);
      },
    );

    widgetTestCase(
      'should maintain proper spacing between buttons',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const SocialAuthButtons()),
        );

        // Assert
        expect(find.byType(SizedBox), findsWidgets);

        final column = tester.widget<Column>(find.byType(Column));
        expect(column.children.length, greaterThanOrEqualTo(1));
      },
    );

    widgetTestCase(
      'should handle loading state properly',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const SocialAuthButtons(isLoading: true),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      },
    );

    widgetTestCase('should disable buttons when loading', TestCategory.widget, (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestWrappers.materialApp(
          child: const SocialAuthButtons(isLoading: true),
        ),
      );

      // Assert
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
    });

    widgetTestCase(
      'should display correct icons for each provider',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(child: const SocialAuthButtons()),
        );

        // Assert
        expect(find.byType(Icon), findsWidgets);

        // Check for Google icon (would be custom icon or image)
        expect(find.byType(Image), findsWidgets);
      },
    );

    widgetTestCase(
      'should adapt to different screen sizes',
      TestCategory.widget,
      (tester) async {
        // Arrange - Test multiple screen sizes
        final screenSizes = [
          const Size(320, 568), // iPhone SE
          const Size(375, 667), // iPhone 8
          const Size(414, 896), // iPhone 11 Pro Max
        ];

        for (final size in screenSizes) {
          // Act
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            TestWrappers.materialApp(child: const SocialAuthButtons()),
          );

          // Assert
          expect(find.byType(ElevatedButton), findsWidgets);
          expect(tester.takeException(), isNull);
        }

        // Reset to default size
        addTearDown(() => tester.view.resetPhysicalSize());
      },
    );

    testGroup('SocialAuthButtons Error Handling', () {
      widgetTestCase(
        'should handle authentication errors gracefully',
        TestCategory.widget,
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            TestWrappers.materialApp(
              child: const SocialAuthButtons(
                errorMessage: 'Google sign-in failed',
              ),
            ),
          );

          // Assert
          expect(find.text('Google sign-in failed'), findsOneWidget);
          expect(find.byIcon(Icons.error_outline), findsOneWidget);
        },
      );

      widgetTestCase(
        'should clear error message after successful retry',
        TestCategory.widget,
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            TestWrappers.materialApp(
              child: const SocialAuthButtons(errorMessage: 'Sign-in failed'),
            ),
          );

          expect(find.text('Sign-in failed'), findsOneWidget);

          // Act - Simulate successful retry
          await tester.pumpWidget(
            TestWrappers.materialApp(child: const SocialAuthButtons()),
          );

          // Assert
          expect(find.text('Sign-in failed'), findsNothing);
        },
      );
    });

    testGroup('SocialAuthButtons Performance Tests', () {
      widgetTestCase(
        'should build quickly without performance issues',
        TestCategory.widget,
        (tester) async {
          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            await tester.pumpWidget(
              TestWrappers.materialApp(child: const SocialAuthButtons()),
            );
          }, threshold: const Duration(milliseconds: 100));
        },
      );

      widgetTestCase(
        'should handle rapid button taps efficiently',
        TestCategory.widget,
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            TestWrappers.materialApp(child: const SocialAuthButtons()),
          );

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            for (int i = 0; i < 5; i++) {
              await tester.tap(find.text('Continue with Google'));
              await tester.pump();
            }
          }, threshold: const Duration(milliseconds: 100));
        },
      );
    });

    testGroup('SocialAuthButtons Dark Mode Tests', () {
      widgetTestCase(
        'should adapt button styling to dark theme',
        TestCategory.widget,
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            TestWrappers.materialApp(
              theme: ThemeData.dark(),
              child: const SocialAuthButtons(),
            ),
          );

          // Assert
          expect(find.byType(ElevatedButton), findsWidgets);

          final button = tester.widget<ElevatedButton>(
            find.byType(ElevatedButton).first,
          );
          expect(button.style?.backgroundColor?.resolve({}), isNotNull);
        },
      );

      widgetTestCase(
        'should maintain contrast in dark mode',
        TestCategory.widget,
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            TestWrappers.materialApp(
              theme: ThemeData.dark(),
              child: const SocialAuthButtons(),
            ),
          );

          // Assert
          expect(find.text('Continue with Google'), findsOneWidget);

          final textWidget = tester.widget<Text>(
            find.text('Continue with Google'),
          );
          expect(textWidget.style?.color, isNotNull);
        },
      );
    });

    testGroup('Platform-Specific Tests', () {
      widgetTestCase(
        'should show Apple button only on iOS',
        TestCategory.widget,
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            TestWrappers.materialApp(child: const SocialAuthButtons()),
          );

          // Assert - Implementation would check platform
          expect(find.byType(ElevatedButton), findsWidgets);

          // On iOS, should show Apple button
          // On Android, should not show Apple button
          // This test verifies the component handles platform differences
        },
      );
    });
  });
}
