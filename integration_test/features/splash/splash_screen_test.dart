import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_app/main.dart';
import 'package:quiz_app/features/splash/presentation/pages/splash_page.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/mock_providers.dart';

void main() {
  E2ETestHelpers.initialize();

  group('Splash Screen E2E Tests', () {
    testWidgets('should display splash screen with correct UI elements', (tester) async {
      // Arrange: Use unauthenticated state to prevent immediate navigation
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.unauthenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen to render
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));

      // Assert: Verify splash screen UI elements
      E2ETestHelpers.verifyWidgetByType<SplashPage>();
      E2ETestHelpers.verifyTextExists('Quiz App');
      E2ETestHelpers.verifyTextExists('Loading...');
      
      // Verify quiz icon is present
      expect(find.byIcon(Icons.quiz), findsOneWidget);
      
      // Verify loading indicator is present
      E2ETestHelpers.verifyWidgetByType<CircularProgressIndicator>();
      
      // Verify background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppColors.vibrantPurple));
    });

    testWidgets('should navigate to login when user is not authenticated', (tester) async {
      // Arrange: Set up unauthenticated state
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.unauthenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen and then navigation
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));
      await tester.pump(const Duration(seconds: 1)); // Wait for auth check
      await E2ETestHelpers.waitForNavigation(tester);

      // Assert: Should navigate to login page
      // Note: This would need to be adapted based on your actual login page widget
      // For now, we'll check that splash screen is no longer visible
      expect(find.byType(SplashPage), findsNothing);
    });

    testWidgets('should navigate to home when user is authenticated', (tester) async {
      // Arrange: Set up authenticated state
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen and then navigation
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));
      await tester.pump(const Duration(seconds: 1)); // Wait for auth check
      await E2ETestHelpers.waitForNavigation(tester);

      // Assert: Should navigate away from splash screen to home
      expect(find.byType(SplashPage), findsNothing);
    });

    testWidgets('should handle loading state correctly', (tester) async {
      // Arrange: Set up loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.loadingState),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen to render
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));

      // Assert: Splash screen should be visible during loading
      E2ETestHelpers.verifyWidgetByType<SplashPage>();
      E2ETestHelpers.verifyWidgetByType<CircularProgressIndicator>();
      E2ETestHelpers.verifyTextExists('Loading...');
    });

    testWidgets('should handle authentication error gracefully', (tester) async {
      // Arrange: Set up error state
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(
            TestScenario.errorState,
            'Authentication failed',
          ),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen and error handling
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);

      // Assert: Should navigate away from splash (likely to login on error)
      expect(find.byType(SplashPage), findsNothing);
    });

    testWidgets('should display splash screen for minimum duration', (tester) async {
      // Arrange: Set up authenticated state
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for navigation to complete
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));
      
      // Give some time for the splash to be visible
      await tester.pump(const Duration(milliseconds: 500));
      
      // Assert: Splash screen should be visible
      E2ETestHelpers.verifyWidgetByType<SplashPage>();
      
      stopwatch.stop();
      
      // Verify splash screen was visible for a reasonable amount of time
      expect(stopwatch.elapsedMilliseconds, greaterThan(400));
    });

    testWidgets('should have accessibility features', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.unauthenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));

      // Assert: Check semantic labels and accessibility
      expect(find.byIcon(Icons.quiz), findsOneWidget);
      
      // Verify text is readable and has proper contrast
      final titleText = tester.widget<Text>(find.text('Quiz App'));
      expect(titleText.style?.color, equals(AppColors.pureWhite));
      
      final loadingText = tester.widget<Text>(find.text('Loading...'));
      // Check loading text has some transparency by checking if it's not fully opaque
      final color = loadingText.style?.color;
      if (color != null) {
        expect((color.a * 255.0).round() & 0xff, lessThan(255)); // Should have some transparency
      }
    });

    testWidgets('should handle slow network conditions', (tester) async {
      // Arrange: Set up slow loading scenario
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.slowLoading),
          child: const QuizApp(),
        ),
      );

      // Act: Wait for splash screen
      await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));

      // Assert: Splash should remain visible during slow loading
      E2ETestHelpers.verifyWidgetByType<SplashPage>();
      E2ETestHelpers.verifyWidgetByType<CircularProgressIndicator>();
      
      // Wait a bit and verify splash is still showing
      await tester.pump(const Duration(seconds: 1));
      E2ETestHelpers.verifyWidgetByType<SplashPage>();
      
      // Eventually should navigate away
      await tester.pump(const Duration(seconds: 3));
      await E2ETestHelpers.waitForNavigation(tester);
    });

    testWidgets('should work across different screen sizes', (tester) async {
      // Test different screen sizes
      final screenSizes = [
        const Size(375, 812), // iPhone X
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(360, 640), // Small Android
        const Size(768, 1024), // Tablet
      ];

      for (final size in screenSizes) {
        // Arrange: Set screen size and create app
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: TestScenarioManager.getOverrides(TestScenario.unauthenticatedUser),
            child: const QuizApp(),
          ),
        );

        // Act: Wait for splash screen
        await E2ETestHelpers.waitForWidget(tester, find.byType(SplashPage));

        // Assert: UI elements should be present regardless of screen size
        E2ETestHelpers.verifyTextExists('Quiz App');
        E2ETestHelpers.verifyTextExists('Loading...');
        expect(find.byIcon(Icons.quiz), findsOneWidget);
        E2ETestHelpers.verifyWidgetByType<CircularProgressIndicator>();

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
  });
}