# Shared Widgets Documentation

This directory contains all reusable UI components following the Kahoot-style design system. All components are thoroughly tested and follow accessibility guidelines.

## Architecture

```
widgets/
├── buttons/          # Interactive button components
├── cards/           # Content display cards
├── layout/          # Layout and responsive components
├── inputs/          # Form input components
├── feedback/        # Loading, snackbars, and user feedback
└── index.dart       # Barrel export file
```

## Usage

Import all widgets using the barrel export:

```dart
import 'package:quiz_app/shared/widgets/index.dart';
```

## Components

### Buttons

#### PrimaryButton

Main action button with Kahoot-style animations and theming.

```dart
// Basic usage
PrimaryButton(
  text: 'Start Quiz',
  onPressed: () => startQuiz(),
)

// With icon
PrimaryButton(
  text: 'Create Quiz',
  icon: Icons.add,
  onPressed: () => createQuiz(),
)

// Loading state
PrimaryButton(
  text: 'Saving...',
  isLoading: true,
  onPressed: null,
)

// Disabled state
PrimaryButton(
  text: 'Submit',
  isDisabled: true,
  onPressed: () {},
)

// Custom styling
PrimaryButton(
  text: 'Custom Button',
  backgroundColor: Colors.red,
  textColor: Colors.white,
  width: 200,
  height: 50,
  onPressed: () {},
)
```

**Properties:**
- `text` (required): Button text
- `onPressed`: Callback function
- `isLoading`: Shows loading spinner
- `isDisabled`: Disables interaction
- `icon`: Optional icon
- `backgroundColor`: Custom background color
- `textColor`: Custom text color
- `width/height`: Custom dimensions

#### AnswerButton

Specialized button for quiz answers with shape-based color coding.

```dart
// Basic answer button
AnswerButton(
  text: 'Paris',
  shape: AnswerShape.triangle,
  onPressed: () => selectAnswer(0),
)

// Selected state
AnswerButton(
  text: 'London',
  shape: AnswerShape.circle,
  isSelected: true,
  onPressed: () => selectAnswer(1),
)

// Show correct result
AnswerButton(
  text: 'Berlin',
  shape: AnswerShape.square,
  showResult: true,
  isCorrect: true,
  onPressed: null,
)

// Show incorrect result
AnswerButton(
  text: 'Madrid',
  shape: AnswerShape.diamond,
  showResult: true,
  isIncorrect: true,
  onPressed: null,
)
```

**Properties:**
- `text` (required): Answer text
- `shape` (required): AnswerShape enum (triangle, diamond, circle, square)
- `onPressed`: Selection callback
- `isSelected`: Shows selection state
- `isCorrect/isIncorrect`: Result states
- `showResult`: Displays result indicator
- `isDisabled`: Disables interaction

### Cards

#### QuizCard

Displays quiz information with thumbnail and metadata.

```dart
// Basic quiz card
QuizCard(
  title: 'Geography Quiz',
  description: 'Test your knowledge of world capitals',
  questionCount: 15,
  onTap: () => openQuiz('quiz_123'),
)

// With image
QuizCard(
  title: 'Science Quiz',
  description: 'Biology, Chemistry, and Physics',
  questionCount: 20,
  imageUrl: 'https://example.com/science.jpg',
  onTap: () => openQuiz('quiz_456'),
)

// Selected state
QuizCard(
  title: 'History Quiz',
  description: 'Ancient civilizations and events',
  questionCount: 12,
  isSelected: true,
  cardColor: Colors.blue.shade50,
  onTap: () => openQuiz('quiz_789'),
)
```

**Properties:**
- `title` (required): Quiz title
- `description` (required): Quiz description
- `questionCount` (required): Number of questions
- `imageUrl`: Optional thumbnail image
- `onTap`: Card tap callback
- `isSelected`: Shows selected state
- `cardColor`: Custom card background

### Layout Components

#### ResponsiveLayout

Adapts content to different screen sizes.

```dart
// Responsive layout with different widgets per breakpoint
ResponsiveLayout(
  mobile: _buildMobileLayout(),
  tablet: _buildTabletLayout(),
  desktop: _buildDesktopLayout(),
)

// Custom breakpoints
ResponsiveLayout(
  mobile: _buildMobileLayout(),
  tablet: _buildTabletLayout(),
  tabletBreakpoint: 800,
  desktopBreakpoint: 1200,
)
```

#### ResponsiveGrid

Grid layout that adapts to screen size.

```dart
// Basic responsive grid
ResponsiveGrid(
  children: quizCards,
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
)

// Custom spacing
ResponsiveGrid(
  children: items,
  spacing: 20.0,
  runSpacing: 16.0,
  crossAxisAlignment: CrossAxisAlignment.start,
)
```

#### PageLayout

Standardized page structure with app bar and safe area.

```dart
// Basic page
PageLayout(
  title: 'My Quizzes',
  body: QuizListView(),
)

// With actions
PageLayout(
  title: 'Quiz Creation',
  actions: [
    IconButton(
      icon: Icon(Icons.save),
      onPressed: () => saveQuiz(),
    ),
  ],
  body: QuizEditor(),
)

// Custom app bar
PageLayout(
  appBar: CustomAppBar(),
  body: Content(),
  floatingActionButton: FloatingActionButton(
    onPressed: () => addQuiz(),
    child: Icon(Icons.add),
  ),
)
```

#### LoadingPageLayout & ErrorPageLayout

Specialized layouts for loading and error states.

```dart
// Loading page
LoadingPageLayout(
  message: 'Loading quizzes...',
)

// Error page with retry
ErrorPageLayout(
  title: 'Connection Error',
  message: 'Failed to load quizzes. Check your internet connection.',
  onRetry: () => retryLoading(),
  retryButtonText: 'Try Again',
)

// Empty state
EmptyStateLayout(
  title: 'No Quizzes Yet',
  message: 'Create your first quiz to get started!',
  icon: Icons.quiz_outlined,
  action: PrimaryButton(
    text: 'Create Quiz',
    onPressed: () => createQuiz(),
  ),
)
```

### Input Components

#### CustomTextInput

Styled text input with validation support.

```dart
// Basic text input
CustomTextInput(
  label: 'Quiz Title',
  hint: 'Enter quiz title',
  controller: titleController,
  onChanged: (value) => updateTitle(value),
)

// With validation
CustomTextInput(
  label: 'Email',
  hint: 'your@email.com',
  keyboardType: TextInputType.emailAddress,
  controller: emailController,
  errorText: emailError,
  helperText: 'We\'ll use this to send you updates',
)

// Multiline input
CustomTextInput(
  label: 'Description',
  hint: 'Describe your quiz...',
  maxLines: 4,
  controller: descriptionController,
)

// With icons
CustomTextInput(
  label: 'Password',
  hint: 'Enter password',
  obscureText: true,
  prefixIcon: Icon(Icons.lock),
  suffixIcon: IconButton(
    icon: Icon(Icons.visibility),
    onPressed: () => togglePasswordVisibility(),
  ),
)
```

#### SearchInput

Search input with clear functionality.

```dart
// Basic search
SearchInput(
  hint: 'Search quizzes...',
  onChanged: (query) => searchQuizzes(query),
  onSubmitted: (query) => performSearch(query),
)

// With controller
SearchInput(
  controller: searchController,
  hint: 'Search by title or topic',
  onClear: () => clearSearch(),
  autofocus: true,
)
```

#### PinInput

PIN code input for game sessions.

```dart
// Game PIN input
PinInput(
  length: 6,
  onChanged: (pin) => updatePin(pin),
  onCompleted: (pin) => joinGame(pin),
  autofocus: true,
)

// Custom length
PinInput(
  length: 4,
  onCompleted: (pin) => verifyCode(pin),
)
```

### Feedback Components

#### LoadingSpinner

Customizable loading indicators.

```dart
// Basic spinner
LoadingSpinner()

// With message
LoadingSpinner(
  message: 'Creating quiz...',
  size: 48,
  color: Colors.blue,
)

// Custom styling
LoadingSpinner(
  size: 24,
  strokeWidth: 2.0,
  color: AppColors.vibrantPurple,
)
```

#### PulsingDots

Animated loading dots.

```dart
// Default pulsing dots
PulsingDots()

// Custom configuration
PulsingDots(
  dotCount: 5,
  dotSize: 12.0,
  color: Colors.orange,
  duration: Duration(milliseconds: 800),
)
```

#### ShimmerLoading

Shimmer effect for content placeholders.

```dart
// Shimmer for list items
ShimmerLoading(
  enabled: isLoading,
  child: ListItemPlaceholder(),
)

// Custom shimmer colors
ShimmerLoading(
  enabled: true,
  baseColor: Colors.grey.shade300,
  highlightColor: Colors.grey.shade100,
  child: CardPlaceholder(),
)
```

#### CustomSnackBar

Styled snackbars with different types.

```dart
// Success message
CustomSnackBar.showSuccess(
  context,
  'Quiz created successfully!',
)

// Error message
CustomSnackBar.showError(
  context,
  'Failed to save quiz. Please try again.',
  actionLabel: 'Retry',
  onAction: () => retryAction(),
)

// Warning
CustomSnackBar.showWarning(
  context,
  'Some changes may not be saved.',
)

// Info with custom duration
CustomSnackBar.showInfo(
  context,
  'Quiz shared with 5 participants',
  duration: Duration(seconds: 2),
)
```

#### Toast

Top-positioned toast notifications.

```dart
// Success toast
Toast.show(
  context,
  message: 'Answer submitted!',
  type: SnackBarType.success,
)

// Quick info toast
Toast.show(
  context,
  message: 'Copied to clipboard',
  duration: Duration(seconds: 1),
)
```

## Best Practices

### Performance

1. **Use const constructors** when possible:
   ```dart
   const PrimaryButton(
     text: 'Static Text',
     // other properties
   )
   ```

2. **Avoid rebuilding expensive widgets**:
   ```dart
   // Good: Build expensive content once
   final expensiveChild = ExpensiveWidget();
   
   ResponsiveLayout(
     mobile: expensiveChild,
     tablet: expensiveChild,
   )
   ```

3. **Use keys for list items**:
   ```dart
   ListView.builder(
     itemBuilder: (context, index) => QuizCard(
       key: Key('quiz_${quizzes[index].id}'),
       // other properties
     ),
   )
   ```

### Accessibility

1. **Provide semantic labels**:
   ```dart
   PrimaryButton(
     text: 'Play',
     onPressed: () => startGame(),
     // Semantic label is automatically set from text
   )
   ```

2. **Use proper contrast ratios**:
   ```dart
   // Colors are automatically checked for accessibility
   AnswerButton(
     text: 'Answer',
     shape: AnswerShape.triangle,
     // Colors use AppColors.getAccessibleTextColor()
   )
   ```

3. **Ensure touch targets are large enough**:
   ```dart
   // All buttons meet 44x44 minimum touch target
   PrimaryButton(
     text: 'Small Text',
     height: 48, // Minimum recommended height
   )
   ```

### Responsive Design

1. **Use responsive layouts**:
   ```dart
   ResponsiveLayout(
     mobile: SingleColumnLayout(),
     tablet: TwoColumnLayout(),
     desktop: ThreeColumnLayout(),
   )
   ```

2. **Adapt spacing and sizes**:
   ```dart
   ResponsivePadding(
     mobilePadding: EdgeInsets.all(AppSpacing.spacingM),
     tabletPadding: EdgeInsets.all(AppSpacing.spacingL),
     desktopPadding: EdgeInsets.all(AppSpacing.spacingXL),
     child: content,
   )
   ```

3. **Test on different screen sizes**:
   ```dart
   // Use ScreenSize utility in widgets
   if (ScreenSize.isMobile(context)) {
     return MobileSpecificWidget();
   }
   ```

### Testing

All components include comprehensive tests:

```dart
// Widget tests
testWidgets('PrimaryButton renders correctly', (tester) async {
  await tester.pumpWidget(
    buildTestableWidget(
      PrimaryButton(
        text: 'Test Button',
        onPressed: () {},
      ),
    ),
  );
  
  expect(find.text('Test Button'), findsOneWidget);
});

// Integration tests
testWidgets('Navigation works correctly', (tester) async {
  // Test navigation between screens
});
```

## Animation Guidelines

All components use consistent animation timing and curves from `AppAnimations`:

- **Short animations** (150ms): Button presses, small transitions
- **Medium animations** (300ms): Page transitions, card animations
- **Long animations** (500ms): Complex state changes

## Theming

Components automatically adapt to light/dark themes using `AppColors` and `AppTextStyles`:

```dart
// Components automatically use theme colors
PrimaryButton(
  text: 'Themed Button',
  // backgroundColor uses AppColors.vibrantPurple
  // textColor uses AppColors.getAccessibleTextColor()
)
```

## Contributing

When adding new widgets:

1. Follow the established pattern (StatefulWidget with animations)
2. Include comprehensive documentation and examples
3. Add widget tests with >90% coverage
4. Follow accessibility guidelines
5. Use design system colors and spacing
6. Export from `index.dart`

For more details, see the main project documentation in `/docs/ui_guideline.md`.