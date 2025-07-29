# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kahoot-style interactive quiz application built with Flutter, Firestore, and Clean Architecture following Claude Code best practices. The app supports real-time multiplayer quiz sessions across Android, iOS, and web platforms with engaging UI/UX and robust performance.

## Claude Code Best Practices Implementation

### Development Workflow (Explore → Plan → Code → Commit)
1. **Explore**: Always read relevant files first using Read/Glob tools
2. **Plan**: Create detailed implementation plans before coding
3. **Code**: Implement solutions following TDD approach
4. **Commit**: Make incremental commits with clear messages

### Test-Driven Development (TDD) Approach
- Write tests first and confirm they fail
- Implement minimal code to make tests pass
- Refactor while keeping tests green
- Commit after each successful test implementation

### Context Management
- Use `/clear` command to maintain focused context
- Be specific in instructions and file references
- Course correct early and often during development
- Use visual references and screenshots when helpful

## Architecture & Design Principles

### Clean Architecture + MVVM Pattern
```
├── lib/
│   ├── core/                 # Shared utilities and constants
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   └── utils/
│   ├── features/             # Feature-based organization
│   │   ├── authentication/
│   │   ├── quiz_creation/
│   │   ├── game_session/
│   │   └── leaderboard/
│   └── shared/              # Shared widgets and providers
│       ├── widgets/
│       └── providers/
```

### Each Feature Follows Clean Architecture:
```
feature/
├── data/                    # Data layer
│   ├── datasources/        # Remote/Local data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                  # Business logic layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository contracts
│   └── usecases/          # Business use cases
└── presentation/           # UI layer (MVVM)
    ├── pages/             # UI screens
    ├── providers/         # Riverpod state providers
    └── widgets/           # Feature-specific widgets
```

## Development Commands

### Essential Flutter Commands
- `flutter run` - Run app in debug mode (hot reload enabled)
- `flutter run --release` - Run app in release mode
- `flutter run -d chrome` - Run web version in Chrome
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version

### Firebase Commands
- `firebase login` - Authenticate with Firebase
- `firebase use --add` - Add Firebase project
- `firebase deploy` - Deploy Cloud Functions
- `firebase emulators:start` - Start local Firebase emulators

### Testing and Quality
- `flutter test` - Run all unit and widget tests
- `flutter analyze` - Run static analysis (lint checks)
- `dart format .` - Format all Dart code
- `flutter test --coverage` - Run tests with coverage report

### Dependencies
- `flutter pub get` - Install/update dependencies
- `flutter pub upgrade` - Upgrade dependencies to latest versions
- `flutter pub outdated` - Check for outdated packages
- `flutter pub deps` - Show dependency tree

## Claude Code Workflow Integration

### GitHub Integration Setup
1. Run `/install-github-app` in Claude Code terminal
2. Configure GitHub Actions for automated PR creation
3. Enable issue-based development workflow
4. Set up automated code reviews with Claude

### MCP Server Configuration
Essential MCP servers for this project:
- **GitHub MCP**: Issue tracking and PR management
- **Playwright MCP**: Automated E2E testing
- **Firebase MCP**: Backend operations and deployment

### Installation Commands:
```bash
# Install MCP servers
claude mcp add github
claude mcp add playwright npx -- @playwright/mcp@latest
claude mcp add firebase
```

### Specialized Sub-Agents

Our project uses specialized Claude Code sub-agents for focused expertise:

#### Available Sub-Agents:
- **flutter-architect**: Clean Architecture implementation and code structure
- **firebase-specialist**: Firestore, Authentication, and real-time features
- **ui-designer**: Kahoot-style UI components and design system compliance
- **testing-specialist**: TDD implementation and comprehensive test coverage
- **code-reviewer**: Quality assurance and architecture compliance validation
- **performance-optimizer**: Performance optimization and memory management

#### Sub-Agent Usage:
- **Automatic**: Sub-agents are invoked automatically based on task context
- **Explicit**: Use "Use the [agent-name] subagent to [specific task]"
- **Examples**:
  - "Use the firebase-specialist subagent to implement real-time leaderboard"
  - "Use the ui-designer subagent to create answer button components"
  - "Use the testing-specialist subagent to write comprehensive tests"

#### Sub-Agent Coordination:
- Each sub-agent follows project standards from CLAUDE.md
- All sub-agents use centralized UI components and approved colors
- Sub-agents communicate through consistent file structures
- Code review sub-agent validates all implementations

## Technology Stack

### Core Dependencies
- `flutter_riverpod` - State management and dependency injection
- `go_router` - Declarative routing
- `freezed` - Immutable data classes
- `json_annotation` - JSON serialization

### Firebase Integration (Firestore Focus)
- `firebase_core` - Firebase SDK initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Primary database (NoSQL document database)
- `firebase_storage` - File and media storage
- `cloud_functions` - Serverless functions for complex logic
- `firebase_analytics` - User analytics and behavior tracking

### UI/UX & Animations
- `flutter_animate` - Easy animations
- `lottie` - Complex animations
- `cached_network_image` - Image caching
- `flutter_svg` - Vector graphics

### Testing
- `flutter_test` - Widget and unit testing
- `mockito` - Mocking for tests
- `golden_toolkit` - Golden file testing
- `integration_test` - Integration testing

### Utilities
- `uuid` - Unique identifiers
- `shared_preferences` - Local storage
- `dio` - HTTP client
- `logger` - Structured logging

## Development Workflow

### Ticket-Based Development (Following GitHub Standards)

**Reference**: All GitHub workflow standards are defined in `docs/github_instruction.md`

#### Issue Creation Standards
- **Title format**: `[Action] [Component]: [Specific outcome]`
  - Examples: "Fix authentication: Resolve login timeout errors"
  - Examples: "Add quiz creation: Display question builder interface"
- **Description structure** (Max 100 words):
  - **Problem**: One sentence describing what's broken/missing
  - **Goal**: One sentence describing desired outcome  
  - **Acceptance**: 2-3 bullet points of completion criteria
- **One main goal per ticket** - Focus on single objective
- **Essential information only** - Remove unnecessary words

#### Parallel Development Workflow

**Branch Strategy**:
- `main` - Production-ready code (protected)
- `development` - Main integration branch (all agents pull from here)
- `feature/issue-{number}-{short-description}` - Individual feature branches

**Development Steps**:
1. **Start Work**: Always pull latest `development` branch
   ```bash
   git checkout development
   git pull origin development
   git checkout -b feature/issue-{number}-{short-description}
   ```

2. **Implement**: Use Claude Code subagents to implement the ticket
   - Follow TDD approach
   - Use UI guidelines and centralized components
   - Write comprehensive tests

3. **Commit**: Follow commit standards
   ```bash
   git add .
   git commit -m "type(scope): description - closes #issue-number"
   ```

4. **Create PR**: Always create PR from feature branch to `development`
   ```bash
   git push -u origin feature/issue-{number}-{short-description}
   gh pr create --base development --title "type(scope): description" --body "Template content"
   ```

5. **Review & Merge**: PR reviewed and merged to `development`

6. **Release**: Periodic PRs from `development` to `main` for releases

**Multi-Agent Coordination**:
- Each agent works on separate feature branch
- All PRs target `development` branch (never `main` directly)
- Regular sync with `development` to avoid conflicts
- Use issue assignments to prevent duplicate work

### Testing Strategy
- **Unit Tests**: Business logic and use cases
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: Feature workflows
- **E2E Tests**: Complete user journeys with Playwright MCP

### Code Quality Guidelines

#### Architecture & Code Standards
- Follow clean architecture principles strictly
- Use Riverpod for all state management
- Implement proper error handling with Result pattern
- Use Freezed for immutable data classes
- Follow Flutter/Dart style guide

#### Commit Message Standards
- **Format**: `type(scope): concise description`
- **Types**: fix, feat, docs, refactor, test, chore
- **Description**: Start with verb, stay under 50 characters
- **Examples**:
  - `fix(auth): resolve session timeout`
  - `feat(quiz): add question builder`
  - `docs(readme): update setup instructions`

#### Code Comments Standards
- **Only explain WHY, never WHAT**
- **Focus on business logic and non-obvious decisions**
- **Remove TODO comments before committing**
- **Maximum one line per comment**

#### Pull Request Standards
- **Title**: Same as commit message format
- **Description** (Max 3 sentences):
  - **Changes**: What was modified
  - **Testing**: How you verified it works
  - **Impact**: What this affects
- **No implementation details in description**

## Firebase Configuration

### Required Firebase Services
- **Authentication**: Google, Email/Password
- **Realtime Database**: Game sessions and real-time updates
- **Cloud Functions**: Game logic and scoring
- **Analytics**: User behavior tracking
- **Cloud Messaging**: Push notifications

### Environment Setup
- Development: `firebase use dev`
- Production: `firebase use prod`
- Local testing: `firebase emulators:start`

## Key Features Implementation

### Real-time Multiplayer (Firestore Streams)
- Real-time data synchronization via Firestore listeners
- Stream-based architecture with Riverpod StreamProvider
- Sub-200ms latency for competitive gameplay
- Game session management with unique PINs stored in Firestore
- Live leaderboard updates through Firestore real-time listeners

### Interactive UI/UX
- Vibrant color schemes with accessibility support
- Smooth animations and transitions
- Sound effects and visual feedback
- Responsive design for all screen sizes

### Cross-Platform Support
- Consistent experience across mobile and web
- Platform-specific optimizations
- Adaptive UI layouts
- Touch and mouse/keyboard input support

## Performance Requirements
- App startup time: < 3 seconds
- Real-time updates: < 200ms latency
- Memory usage: < 100MB on mobile
- Battery optimization for mobile devices
- Smooth 60fps animations

## Security Guidelines
- Never commit Firebase config files with secrets
- Use Firebase Security Rules for data protection
- Implement proper authentication flows
- Validate all user inputs
- Use HTTPS for all network communications

## Custom Slash Commands
Create these custom slash commands for repeated workflows:

### `/test-feature <feature-name>`
```bash
# Run tests for specific feature
flutter test test/features/<feature-name>/
```

### `/build-all`
```bash
# Build for all platforms
flutter build web && flutter build apk && flutter build ios
```

### `/firestore-rules`
```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules
```

### `/generate-code`
```bash
# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

## Firestore Database Design

### Collections Structure
```
users/
  {userId}/
    - name: string
    - email: string
    - createdAt: timestamp
    - stats: object

quizzes/
  {quizId}/
    - title: string
    - description: string
    - createdBy: string
    - questions: array
    - isPublic: boolean
    - createdAt: timestamp

game_sessions/
  {sessionId}/
    - quizId: string
    - hostId: string
    - pin: string
    - status: string (waiting|active|completed)
    - players: map
    - currentQuestionIndex: number
    - createdAt: timestamp

leaderboards/
  {sessionId}/
    - scores: array of objects
    - updatedAt: timestamp
```

### Security Rules Approach
- Users can only read/write their own data
- Quiz creators can modify their quizzes
- Game session participants can join and submit answers
- Use Firebase Auth for user verification

## Communication Standards

### Review Comments (For Subagents)
- **Be specific**: Point to exact lines/issues
- **Suggest solutions**: Don't just identify problems  
- **Use imperative mood**: "Change X to Y" not "X should be Y"
- **One issue per comment**

### General Writing Rules
- **Eliminate filler words**: "just", "simply", "basically", "actually"
- **Use specific numbers**: "Reduce load time by 200ms" not "faster"
- **Avoid jargon**: Write for any team member to understand
- **Edit ruthlessly**: Cut everything non-essential
- **Immediate clarity**: Reader should understand purpose within 5 seconds

## UI/UX Design Guidelines

### Color System (Use Only These Colors)
```dart
// Primary Colors
static const Color primaryBlue = Color(0xFF2563EB);      // Kahoot blue
static const Color primaryRed = Color(0xFFEF4444);       // Answer A - Red
static const Color primaryGreen = Color(0xFF10B981);     // Answer B - Green  
static const Color primaryYellow = Color(0xFFF59E0B);    // Answer C - Yellow
static const Color primaryPurple = Color(0xFF8B5CF6);    // Answer D - Purple

// Neutral Colors
static const Color backgroundLight = Color(0xFFF8FAFC);  // Light background
static const Color backgroundDark = Color(0xFF1E293B);   // Dark background
static const Color textPrimary = Color(0xFF0F172A);      // Primary text
static const Color textSecondary = Color(0xFF64748B);    // Secondary text
static const Color surfaceWhite = Color(0xFFFFFFFF);     // Cards/surfaces
static const Color borderGray = Color(0xFFE2E8F0);       // Borders

// Status Colors
static const Color successGreen = Color(0xFF059669);     // Success states
static const Color errorRed = Color(0xFFDC2626);         // Error states
static const Color warningOrange = Color(0xFFF97316);    // Warning states
```

### Component Library (Always Use These)

#### Button Components
- **PrimaryButton**: Main actions (Start Quiz, Join Game)
- **SecondaryButton**: Secondary actions (Cancel, Back)
- **AnswerButton**: Quiz answer options with color coding
- **FloatingActionButton**: Add/Create actions

#### Input Components
- **QuizTextField**: Standard text input with validation
- **PinCodeInput**: Game PIN entry with large numbers
- **SearchInput**: Search functionality with icon

#### Display Components
- **QuizCard**: Display quiz information
- **PlayerCard**: Show participant information
- **ScoreCard**: Leaderboard entries
- **CountdownTimer**: Question time limits

#### Layout Components
- **AppScaffold**: Standard page layout with consistent styling
- **LoadingOverlay**: Loading states with animations
- **ErrorWidget**: Consistent error display
- **EmptyStateWidget**: When no data is available

### Typography System
```dart
// Headings
static const TextStyle headingLarge = TextStyle(
  fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary);
static const TextStyle headingMedium = TextStyle(
  fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary);
static const TextStyle headingSmall = TextStyle(
  fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary);

// Body Text
static const TextStyle bodyLarge = TextStyle(
  fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary);
static const TextStyle bodyMedium = TextStyle(
  fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary);
static const TextStyle bodySmall = TextStyle(
  fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary);

// Button Text
static const TextStyle buttonText = TextStyle(
  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
```

### Animation Standards
```dart
// Animation Durations
static const Duration shortAnimation = Duration(milliseconds: 200);
static const Duration mediumAnimation = Duration(milliseconds: 400);
static const Duration longAnimation = Duration(milliseconds: 600);

// Common Animations
- Button press: Scale(0.95) with shortAnimation
- Page transitions: Slide with mediumAnimation
- Loading states: Pulse with longAnimation
- Answer feedback: Color change + scale with shortAnimation
```

### Spacing System
```dart
// Consistent Spacing (Use Only These)
static const double spacingXS = 4.0;   // Tiny gaps
static const double spacingS = 8.0;    // Small gaps  
static const double spacingM = 16.0;   // Standard padding
static const double spacingL = 24.0;   // Large padding
static const double spacingXL = 32.0;  // Extra large padding
static const double spacingXXL = 48.0; // Section spacing
```

### UI Implementation Rules
1. **Always use constants**: Never hardcode colors, spacing, or text styles
2. **Centralized components**: Use shared widgets from component library
3. **Consistent patterns**: Follow established design patterns across features
4. **Responsive design**: Support multiple screen sizes with adaptive layouts
5. **Accessibility**: Include semantic labels and proper contrast ratios
6. **Loading states**: Show appropriate loading indicators for all async operations
7. **Error handling**: Use consistent error display patterns

### File Structure for UI Components
```
lib/shared/
├── constants/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_spacing.dart
│   └── app_animations.dart
├── widgets/
│   ├── buttons/
│   ├── inputs/
│   ├── cards/
│   └── layouts/
└── theme/
    └── app_theme.dart
```

## Deployment Pipeline
1. **Explore**: Read and understand existing code structure
2. **Plan**: Create GitHub issue following standards (max 100 words)
3. **Design**: Use UI guidelines and centralized components
4. **Test**: Write tests first following TDD approach
5. **Code**: Implement with clear commit messages (`type(scope): description`)
6. **Review**: Use Claude Code subagents with specific feedback
7. **Test E2E**: Run Playwright MCP tests for web platform
8. **Deploy**: Firebase deployment via GitHub Actions
9. **Monitor**: Performance monitoring and analytics
10. **Iterate**: User feedback integration for continuous improvement