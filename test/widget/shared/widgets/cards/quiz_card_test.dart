import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/shared/widgets/cards/quiz_card.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('QuizCard Widget Tests', () {
    testWidgets('renders correctly with all properties', (tester) async {
      const title = 'Test Quiz';
      const description = 'This is a test quiz description';
      const questionCount = 10;

      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: title,
            description: description,
            questionCount: questionCount,
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.text('$questionCount questions'), findsOneWidget);
      expect(find.byType(QuizCard), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
            onTap: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(QuizCard));
      expect(wasTapped, isTrue);
    });

    testWidgets('shows default icon when no image provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
          ),
        ),
      );

      expect(find.byIcon(Icons.quiz), findsOneWidget);
    });

    testWidgets('shows network image when imageUrl provided', (tester) async {
      const imageUrl = 'https://example.com/image.jpg';

      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
            imageUrl: imageUrl,
          ),
        ),
      );

      expect(find.byType(NetworkImage), findsOneWidget);
      expect(find.byIcon(Icons.quiz), findsNothing);
    });

    testWidgets('shows selected state correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
            isSelected: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(QuizCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border as Border).top.color,
        equals(AppColors.vibrantPurple),
      );
    });

    testWidgets('uses custom card color when provided', (tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
            cardColor: customColor,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(QuizCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('has proper semantics', (tester) async {
      const title = 'Math Quiz';
      const description = 'Basic math problems';
      const questionCount = 15;

      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: title,
            description: description,
            questionCount: questionCount,
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(QuizCard));
      expect(semantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(
        semantics.label,
        equals('$title. $description. $questionCount questions'),
      );
    });

    testWidgets('animates on tap', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
            onTap: () {},
          ),
        ),
      );

      // Start tap gesture
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(QuizCard)),
      );

      await tester.pump(const Duration(milliseconds: 50));

      // Should find Transform widget (for scale animation)
      expect(find.byType(Transform), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('displays question count badge correctly', (tester) async {
      const questionCount = 25;

      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: questionCount,
          ),
        ),
      );

      expect(find.text('$questionCount questions'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('truncates long text properly', (tester) async {
      const longTitle =
          'This is a very long title that should be truncated because it exceeds the maximum number of lines allowed';
      const longDescription =
          'This is a very long description that should also be truncated because it exceeds the maximum number of lines allowed in the card description area';

      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: longTitle,
            description: longDescription,
            questionCount: 5,
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text(longTitle));
      final descriptionText = tester.widget<Text>(find.text(longDescription));

      expect(titleText.maxLines, equals(2));
      expect(titleText.overflow, equals(TextOverflow.ellipsis));
      expect(descriptionText.maxLines, equals(3));
      expect(descriptionText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('applies proper margin and border radius', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const QuizCard(
            title: 'Test Quiz',
            description: 'Description',
            questionCount: 5,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(QuizCard),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.margin, isNotNull);
      // Container width property is not directly accessible

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.boxShadow, isNotNull);
    });
  });
}
