import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/features/authentication/presentation/widgets/auth_header.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import 'package:quiz_app/shared/constants/app_text_styles.dart';
import '../../../../../test_config.dart';

void main() {
  testGroup('AuthHeader Widget Tests', TestCategory.widget, () {
    const testTitle = 'Welcome Back!';
    const testSubtitle = 'Sign in to join amazing quizzes';
    const testIcon = Icons.quiz;

    widgetTestCase(
      'should display title and subtitle correctly',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const AuthHeader(
              title: testTitle,
              subtitle: testSubtitle,
              icon: testIcon,
            ),
          ),
        );

        // Assert
        expect(find.text(testTitle), findsOneWidget);
        expect(find.text(testSubtitle), findsOneWidget);
        expect(find.byIcon(testIcon), findsOneWidget);
      },
    );

    widgetTestCase('should apply correct text styles', TestCategory.widget, (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestWrappers.materialApp(
          child: const AuthHeader(
            title: testTitle,
            subtitle: testSubtitle,
            icon: testIcon,
          ),
        ),
      );

      // Assert
      final titleWidget = tester.widget<Text>(find.text(testTitle));
      final subtitleWidget = tester.widget<Text>(find.text(testSubtitle));

      expect(titleWidget.style?.fontSize, equals(AppTextStyles.h2.fontSize));
      expect(
        titleWidget.style?.fontWeight,
        equals(AppTextStyles.h2.fontWeight),
      );
      expect(
        subtitleWidget.style?.fontSize,
        equals(AppTextStyles.bodyText.fontSize),
      );
    });

    widgetTestCase(
      'should display icon with correct color',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const AuthHeader(
              title: testTitle,
              subtitle: testSubtitle,
              icon: testIcon,
            ),
          ),
        );

        // Assert
        final iconWidget = tester.widget<Icon>(find.byIcon(testIcon));
        expect(iconWidget.color, equals(AppColors.vibrantPurple));
        expect(iconWidget.size, equals(48.0));
      },
    );

    widgetTestCase(
      'should build without error when minimal props provided',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const AuthHeader(title: testTitle, subtitle: testSubtitle),
          ),
        );

        // Assert
        expect(find.text(testTitle), findsOneWidget);
        expect(find.text(testSubtitle), findsOneWidget);
      },
    );

    widgetTestCase(
      'should handle long title text without overflow',
      TestCategory.widget,
      (tester) async {
        // Arrange
        const longTitle =
            'This is a very long title that might cause overflow issues in the auth header component';

        // Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const AuthHeader(
              title: longTitle,
              subtitle: testSubtitle,
              icon: testIcon,
            ),
          ),
        );

        // Assert
        expect(find.text(longTitle), findsOneWidget);
        expect(tester.takeException(), isNull); // No overflow errors
      },
    );

    widgetTestCase(
      'should handle long subtitle text without overflow',
      TestCategory.widget,
      (tester) async {
        // Arrange
        const longSubtitle =
            'This is a very long subtitle that explains what the user should do and might wrap to multiple lines without causing layout issues';

        // Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const AuthHeader(
              title: testTitle,
              subtitle: longSubtitle,
              icon: testIcon,
            ),
          ),
        );

        // Assert
        expect(find.text(longSubtitle), findsOneWidget);
        expect(tester.takeException(), isNull); // No overflow errors
      },
    );

    widgetTestCase('should be accessible', TestCategory.widget, (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestWrappers.materialApp(
          child: const AuthHeader(
            title: testTitle,
            subtitle: testSubtitle,
            icon: testIcon,
          ),
        ),
      );

      // Assert
      TestExpectations.expectAccessible(tester);

      // Verify semantic labels exist
      expect(find.bySemanticsLabel('Welcome Back!'), findsOneWidget);
    });

    widgetTestCase(
      'should maintain proper spacing between elements',
      TestCategory.widget,
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          TestWrappers.materialApp(
            child: const AuthHeader(
              title: testTitle,
              subtitle: testSubtitle,
              icon: testIcon,
            ),
          ),
        );

        // Assert
        final column = tester.widget<Column>(find.byType(Column));
        expect(
          column.children.length,
          greaterThanOrEqualTo(3),
        ); // Icon, title, subtitle

        // Check for SizedBox spacing widgets
        expect(find.byType(SizedBox), findsWidgets);
      },
    );

    widgetTestCase('should center content properly', TestCategory.widget, (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestWrappers.materialApp(
          child: const AuthHeader(
            title: testTitle,
            subtitle: testSubtitle,
            icon: testIcon,
          ),
        ),
      );

      // Assert
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.center));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    widgetTestCase(
      'should render consistently across different screen sizes',
      TestCategory.widget,
      (tester) async {
        // Arrange - Test multiple screen sizes
        final screenSizes = [
          const Size(320, 568), // iPhone SE
          const Size(375, 667), // iPhone 8
          const Size(414, 896), // iPhone 11 Pro Max
          const Size(768, 1024), // iPad
        ];

        for (final size in screenSizes) {
          // Act
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            TestWrappers.materialApp(
              child: const AuthHeader(
                title: testTitle,
                subtitle: testSubtitle,
                icon: testIcon,
              ),
            ),
          );

          // Assert
          expect(find.text(testTitle), findsOneWidget);
          expect(find.text(testSubtitle), findsOneWidget);
          expect(find.byIcon(testIcon), findsOneWidget);
          expect(tester.takeException(), isNull);
        }

        // Reset to default size
        addTearDown(() => tester.view.resetPhysicalSize());
      },
    );

    testGroup('AuthHeader Performance Tests', () {
      widgetTestCase(
        'should build quickly without performance issues',
        TestCategory.widget,
        (tester) async {
          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            await tester.pumpWidget(
              TestWrappers.materialApp(
                child: const AuthHeader(
                  title: testTitle,
                  subtitle: testSubtitle,
                  icon: testIcon,
                ),
              ),
            );
          }, threshold: const Duration(milliseconds: 100));
        },
      );

      widgetTestCase(
        'should handle rapid rebuilds efficiently',
        TestCategory.widget,
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            TestWrappers.materialApp(
              child: const AuthHeader(
                title: testTitle,
                subtitle: testSubtitle,
                icon: testIcon,
              ),
            ),
          );

          // Act & Assert
          await TestExpectations.expectPerformant(() async {
            for (int i = 0; i < 10; i++) {
              await tester.pump();
            }
          }, threshold: const Duration(milliseconds: 50));
        },
      );
    });

    testGroup('AuthHeader Dark Mode Tests', () {
      widgetTestCase(
        'should adapt to dark theme correctly',
        TestCategory.widget,
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            TestWrappers.materialApp(
              theme: ThemeData.dark(),
              child: const AuthHeader(
                title: testTitle,
                subtitle: testSubtitle,
                icon: testIcon,
              ),
            ),
          );

          // Assert
          expect(find.text(testTitle), findsOneWidget);
          expect(find.text(testSubtitle), findsOneWidget);
          expect(find.byIcon(testIcon), findsOneWidget);

          // Colors should adapt to dark theme
          final titleWidget = tester.widget<Text>(find.text(testTitle));
          expect(titleWidget.style?.color, isNotNull);
        },
      );
    });

    testGroup('AuthHeader Animation Tests', () {
      widgetTestCase(
        'should support animation when used in animated contexts',
        TestCategory.widget,
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            TestWrappers.materialApp(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: const AuthHeader(
                  title: testTitle,
                  subtitle: testSubtitle,
                  icon: testIcon,
                ),
              ),
            ),
          );

          // Act
          await tester.pumpAndSettle();

          // Assert
          expect(find.text(testTitle), findsOneWidget);
          expect(find.text(testSubtitle), findsOneWidget);
          expect(find.byIcon(testIcon), findsOneWidget);
        },
      );
    });
  });
}
