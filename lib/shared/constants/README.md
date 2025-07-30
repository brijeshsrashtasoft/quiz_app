# UI Constants System

This directory contains the complete UI constants system following the Kahoot-style design guidelines from `docs/ui_guideline.md`.

## Quick Start

Import all constants with a single import:

```dart
import 'package:quiz_app/shared/constants/app_constants.dart';
```

## File Structure

### `app_colors.dart`
Complete color palette including:
- **Primary Brand Colors**: Vibrant Purple, Turquoise, Coral Red, Mint Green, Warm Yellow
- **Answer Button Colors**: Shape-specific colors (Triangle-Red, Diamond-Green, Circle-Yellow, Square-Turquoise)
- **Neutral Colors**: Charcoal, Cool Gray, Off-White, Pure White, Light Gray
- **Dark Mode Colors**: Dark-optimized color variants
- **Game State Colors**: Success, error, warning, achievement colors
- **Gradients**: Pre-configured gradients for special effects

### `app_text_styles.dart`
Typography system with:
- **Text Hierarchy**: Game Title, Section Headers, Question Text, Answer Options, Body Text, Captions
- **Special Styles**: Timer Display, Score Display, Button Text, Input Text
- **Dark Mode Variants**: All styles have dark mode equivalents
- **Accessibility Styles**: Enhanced sizes for accessibility
- **Context Helpers**: Dynamic styling based on game state

### `app_spacing.dart`
8dp grid-based spacing system:
- **Base Spacing**: XS(4), S(8), M(16), L(24), XL(32), XXL(48)
- **Component Spacing**: Card padding, button spacing, input padding
- **Responsive Helpers**: Screen-size adaptive spacing
- **Layout Spacing**: Grid, form, navigation spacing

### `app_dimensions.dart`
Component dimensions and sizing:
- **Border Radius**: Consistent rounded corners (8dp, 12dp, 16dp, 24dp)
- **Component Heights**: Buttons, cards, inputs, timers
- **Icon Sizes**: XS(16) to XXL(64)
- **Elevations**: Low(2), Medium(4), High(8), Overlay(16)
- **Responsive Helpers**: Screen-adaptive sizing

### `app_animations.dart`
Animation constants and configurations:
- **Durations**: Short(200ms), Medium(400ms), Long(600ms)
- **Curves**: Ease, bounce, elastic, spring animations
- **Sequences**: Pre-configured animation sequences
- **Game Interactions**: Button press, correct/wrong answer feedback

## Usage Examples

### Colors
```dart
Container(
  color: AppColors.vibrantPurple,
  child: Text(
    'Quiz Title',
    style: TextStyle(color: AppColors.pureWhite),
  ),
)
```

### Text Styles
```dart
Text(
  'Welcome to Quiz!',
  style: AppTextStyles.gameTitle,
)

Text(
  'Question 1 of 10',
  style: AppTextStyles.questionText,
)
```

### Spacing
```dart
Padding(
  padding: AppSpacing.screenPaddingAll,
  child: Column(
    children: [
      QuestionCard(),
      SizedBox(height: AppSpacing.spacingL),
      AnswerButtons(),
    ],
  ),
)
```

### Dimensions
```dart
Container(
  height: AppDimensions.answerButtonHeight,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowButton,
        blurRadius: AppDimensions.elevationMedium,
      ),
    ],
  ),
)
```

### Animations
```dart
AnimatedContainer(
  duration: AppAnimations.shortAnimation,
  curve: AppAnimations.buttonTapCurve,
  transform: Matrix4.identity()..scale(AppAnimations.buttonPressScale),
  child: AnswerButton(),
)
```

## Design System Compliance

### Mandatory Rules
1. **NEVER hardcode colors** - Always use AppColors constants
2. **NEVER hardcode spacing** - Always use AppSpacing constants  
3. **NEVER hardcode dimensions** - Always use AppDimensions constants
4. **NEVER hardcode animations** - Always use AppAnimations constants
5. **ALWAYS use text styles** - Never create custom TextStyles inline

### Color Usage Guidelines
- **Primary Actions**: `AppColors.vibrantPurple`
- **Success States**: `AppColors.turquoise`
- **Error States**: `AppColors.coralRed`
- **Warning States**: `AppColors.timeWarning`
- **Neutral Elements**: `AppColors.coolGray`

### Accessibility Compliance
- All color combinations meet WCAG AA contrast ratios
- Use `AppTextStyles.*_Accessible` variants for enhanced accessibility
- Touch targets use `AppDimensions.minTouchTarget` (48dp minimum)
- Motion can be reduced using `AppAnimations` with shorter durations

### Dark Mode Support
- All colors have dark mode variants
- Text styles automatically adapt
- Theme handles color switching automatically
- Test both light and dark themes

## Responsive Design

### Screen Breakpoints
- **Mobile**: < 600px (`AppDimensions.mobileBreakpoint`)
- **Tablet**: 600-1200px (`AppDimensions.tabletBreakpoint`)  
- **Desktop**: > 1200px (`AppDimensions.desktopBreakpoint`)

### Responsive Helpers
```dart
// Responsive spacing
double spacing = AppSpacing.responsiveSpacing(screenWidth);

// Responsive dimensions
double buttonHeight = AppDimensions.getButtonHeight(screenWidth);

// Responsive padding
double padding = AppSpacing.responsivePadding(screenWidth);
```

## Animation Best Practices

### Performance
- Use `AppAnimations.shortAnimation` for micro-interactions
- Use `AppAnimations.mediumAnimation` for page transitions
- Provide reduced motion options for accessibility

### User Feedback
- Button presses: Scale down with `AppAnimations.buttonPress`
- Correct answers: Pulse with `AppAnimations.correctAnswer`
- Wrong answers: Shake with `AppAnimations.wrongAnswer`
- Achievements: Bounce with `AppAnimations.achievement`

## Testing

### Widget Tests
```dart
testWidgets('uses correct colors', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  final container = tester.widget<Container>(find.byType(Container));
  expect(container.color, AppColors.vibrantPurple);
});
```

### Golden Tests
All UI components should use these constants for consistent golden file generation.

## Contributing

When adding new constants:

1. **Follow naming conventions**: descriptive, consistent names
2. **Add documentation**: Explain usage and context
3. **Update this README**: Document new additions
4. **Test thoroughly**: Verify on all platforms and screen sizes
5. **Consider accessibility**: Ensure WCAG compliance
6. **Maintain consistency**: Align with existing design system

## References

- **Main Documentation**: `docs/ui_guideline.md`
- **Theme Implementation**: `lib/shared/theme/app_theme.dart`
- **Architecture Guide**: `CLAUDE.md`
- **Development Guide**: `DEVELOPMENT_GUIDE.md`