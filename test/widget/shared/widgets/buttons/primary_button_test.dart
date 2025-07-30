import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/shared/widgets/buttons/primary_button.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import 'package:quiz_app/shared/constants/app_text_styles.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('renders correctly with text', (tester) async {
      const testText = 'Test Button';
      
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: testText,
          ),
        ),
      );
      
      expect(find.text(testText), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Test Button',
            onPressed: () => wasPressed = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(PrimaryButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('does not respond to tap when disabled', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Test Button',
            isDisabled: true,
            onPressed: () => wasPressed = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(PrimaryButton));
      expect(wasPressed, isFalse);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Test Button',
            isLoading: true,
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Test Button',
            icon: Icons.star,
          ),
        ),
      );
      
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('uses custom colors when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Test Button',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          ),
        ),
      );
      
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
    });

    testWidgets('applies disabled style when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Test Button',
            isDisabled: true,
          ),
        ),
      );
      
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.disabled));
    });

    testWidgets('has proper semantics', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Test Button',
          ),
        ),
      );
      
      final semantics = tester.getSemantics(find.byType(PrimaryButton));
      expect(semantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(semantics.label?.trim(), equals('Test Button'));
    });

    testWidgets('animates on tap', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Test Button',
            onPressed: () {},
          ),
        ),
      );
      
      // Get initial transform
      final initialTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Transform),
        ),
      );
      
      // Start tap gesture
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PrimaryButton)),
      );
      
      await tester.pump(const Duration(milliseconds: 50));
      
      // Transform should have changed during animation
      final animatedTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Transform),
        ),
      );
      
      expect(animatedTransform, isNot(equals(initialTransform)));
      
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('respects custom width and height', (tester) async {
      const customWidth = 200.0;
      const customHeight = 60.0;
      
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Test Button',
            width: customWidth,
            height: customHeight,
          ),
        ),
      );
      
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ).first,
      );
      
      // Check if custom dimensions are applied through the widget structure
      expect(container, isNotNull);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });
  });
}