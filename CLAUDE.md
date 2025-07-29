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

### Subagent Utilization
- **Code Review Agent**: Ensures architecture compliance
- **Testing Agent**: Generates comprehensive tests
- **UI/UX Agent**: Maintains design consistency
- **Performance Agent**: Optimizes app performance

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

#### Development Workflow
1. Create GitHub issue following title/description standards
2. Use Claude Code subagents to implement via PR workflow
3. Follow commit message rules: `type(scope): concise description`
4. Automated testing with Playwright MCP
5. Code review with Claude subagents using specific feedback
6. Merge after automated checks pass

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

## Deployment Pipeline
1. **Explore**: Read and understand existing code structure
2. **Plan**: Create GitHub issue following standards (max 100 words)
3. **Test**: Write tests first following TDD approach
4. **Code**: Implement with clear commit messages (`type(scope): description`)
5. **Review**: Use Claude Code subagents with specific feedback
6. **Test E2E**: Run Playwright MCP tests for web platform
7. **Deploy**: Firebase deployment via GitHub Actions
8. **Monitor**: Performance monitoring and analytics
9. **Iterate**: User feedback integration for continuous improvement