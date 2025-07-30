import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/shared/widgets/buttons/answer_button.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('AnswerButton Widget Tests', () {
    testWidgets('renders correctly with text and shape', (tester) async {
      const testText = 'Answer Option A';
      
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: testText,
            shape: AnswerShape.triangle,
          ),
        ),
      );
      
      expect(find.text(testText), findsOneWidget);
      expect(find.byType(AnswerButton), findsOneWidget);
      expect(find.byIcon(Icons.change_history), findsOneWidget); // Triangle icon
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        buildTestableWidget(
          AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.circle,
            onPressed: () => wasPressed = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(AnswerButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('does not respond to tap when disabled', (tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        buildTestableWidget(
          AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.square,
            isDisabled: true,
            onPressed: () => wasPressed = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(AnswerButton));
      expect(wasPressed, isFalse);
    });

    testWidgets('displays correct color for each shape', (tester) async {
      // Test triangle (red)
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.triangle,
          ),
        ),
      );
      
      Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnswerButton),
          matching: find.byType(Container),
        ).first,
      );
      
      BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.triangleRed));
      
      // Test diamond (green)
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer B',
            shape: AnswerShape.diamond,
          ),
        ),
      );
      
      container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnswerButton),
          matching: find.byType(Container),
        ).first,
      );
      
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.diamondGreen));
    });

    testWidgets('shows correct icon for each shape', (tester) async {
      // Test all shapes
      const shapes = [
        (AnswerShape.triangle, Icons.change_history),
        (AnswerShape.diamond, Icons.diamond),
        (AnswerShape.circle, Icons.circle),
        (AnswerShape.square, Icons.square),
      ];
      
      for (final (shape, expectedIcon) in shapes) {
        await tester.pumpWidget(
          buildTestableWidget(
            AnswerButton(
              text: 'Answer',
              shape: shape,
            ),
          ),
        );
        
        expect(find.byIcon(expectedIcon), findsOneWidget,
            reason: 'Expected $expectedIcon for $shape');
      }
    });

    testWidgets('shows selected state correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.circle,
            isSelected: true,
          ),
        ),
      );
      
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnswerButton),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect((decoration.border as Border).top.color, equals(AppColors.pureWhite));
      expect((decoration.border as Border).top.width, equals(3.0));
    });

    testWidgets('shows correct result state', (tester) async {
      // Test correct answer
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Correct Answer',
            shape: AnswerShape.triangle,
            showResult: true,
            isCorrect: true,
          ),
        ),
      );
      
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnswerButton),
          matching: find.byType(Container),
        ).first,
      );
      
      BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.correctAnswer));
      
      // Test incorrect answer
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Wrong Answer',
            shape: AnswerShape.circle,
            showResult: true,
            isIncorrect: true,
          ),
        ),
      );
      
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      
      container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnswerButton),
          matching: find.byType(Container),
        ).first,
      );
      
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.incorrectAnswer));
    });

    testWidgets('has proper semantics', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.diamond,
          ),
        ),
      );
      
      final semantics = tester.getSemantics(find.byType(AnswerButton));
      expect(semantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(semantics.label, equals('diamond answer: Answer A'));
    });

    testWidgets('animates result indicator', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.square,
            showResult: false,
            isCorrect: true,
          ),
        ),
      );
      
      // Initially no result indicator
      expect(find.byIcon(Icons.check_circle), findsNothing);
      
      // Update to show result
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.square,
            showResult: true,
            isCorrect: true,
          ),
        ),
      );
      
      // Should trigger animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('applies proper margin and dimensions', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AnswerButton(
            text: 'Answer A',
            shape: AnswerShape.circle,
          ),
        ),
      );
      
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnswerButton),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.margin, isNotNull);
      // Container width is not directly accessible, checking constraints instead
      expect(container.constraints, isNull); // No explicit constraints set
    });
  });
}