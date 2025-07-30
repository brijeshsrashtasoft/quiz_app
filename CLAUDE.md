# CLAUDE.md - Project Master Documentation

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📚 Documentation Index & Cross-References

**Primary Documentation Files:**
- **CLAUDE.md** (this file) - Master project documentation and architecture guidelines
- **DOCUMENTATION_INDEX.md** - Complete documentation navigation hub and cross-reference matrix
- **README.md** - Project overview and getting started guide
- **DEVELOPMENT_GUIDE.md** - Complete development workflow, commands, and troubleshooting
- **docs/github_instruction.md** - GitHub workflow standards, commit formats, and PR guidelines (CONCISE FORMAT)
- **docs/ui_guideline.md** - Comprehensive UI/UX design system, color palette, and component specifications
- **docs/parallel-execution-guide.md** - Mandatory parallel sub-agent execution patterns and workflows
- **docs/firebase_setup.md** - Firebase configuration and environment setup (CONCISE FORMAT)

**Ticket Documentation:**
- **docs/tickets/ui-constants-implementation.md** - UI constants implementation specifications

**Sub-Agent Documentation:**
- **.claude/agents/flutter-architect.md** - Clean Architecture and code structure specialist
- **.claude/agents/firebase-specialist.md** - Firestore, Authentication, and real-time features expert
- **.claude/agents/ui-designer.md** - Kahoot-style UI and design system compliance
- **.claude/agents/testing-specialist.md** - TDD implementation and comprehensive test coverage
- **.claude/agents/code-reviewer.md** - Quality assurance and architecture compliance validation
- **.claude/agents/performance-optimizer.md** - Performance optimization and memory management

**Custom Commands:**
- **.claude/commands/implement-issue.md** - Intelligent agent assignment for GitHub issues
- **.claude/commands/brainstorm-feature.md** - Comprehensive feature planning and analysis

**Automation Scripts:**
- **scripts/daily-dev.sh** - Daily development workflow automation
- **scripts/develop-feature.sh** - Feature development setup and branch creation
- **scripts/quality-check.sh** - Pre-PR quality validation and testing
- **scripts/firebase-ops.sh** - Firebase operations and deployment helper

**Important Note**: All sub-agents and scripts reference these documentation files for consistent implementation. When making changes, ensure cross-references remain accurate.

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

**Sub-Agent Documentation Location**: All sub-agents are documented in `.claude/agents/` directory with detailed role definitions, responsibilities, and handoff protocols.

#### Available Sub-Agents:
- **flutter-architect**: Clean Architecture implementation and code structure
- **firebase-specialist**: Firestore, Authentication, and real-time features
- **ui-designer**: Kahoot-style UI components and design system compliance
- **testing-specialist**: TDD implementation and comprehensive test coverage
- **code-reviewer**: Quality assurance and architecture compliance validation
- **performance-optimizer**: Performance optimization and memory management

#### Sub-Agent Usage (MANDATORY):
- **ALWAYS USE SUB-AGENTS**: Never work directly - ALWAYS delegate to specialized sub-agents for maximum speed and parallel execution
- **PARALLEL EXECUTION**: Use multiple sub-agents simultaneously whenever possible to maximize development speed
- **MANDATORY DELEGATION**: Even simple tasks must be delegated to appropriate sub-agents for consistency and optimization
- **Examples**:
  - "Use the firebase-specialist subagent to implement real-time leaderboard"
  - "Use the ui-designer subagent to create answer button components"
  - "Use the testing-specialist subagent to write comprehensive tests"
  - "Use multiple agents in parallel: flutter-architect + ui-designer + testing-specialist"

#### Sub-Agent Coordination:

**PARALLEL Agent Assignment by Issue Type:**
- **Setup/Infrastructure** → flutter-architect + firebase-specialist + testing-specialist (ALL WORK IN PARALLEL)
- **Authentication** → firebase-specialist + flutter-architect + ui-designer + testing-specialist (ALL WORK IN PARALLEL)
- **UI/Components** → ui-designer + flutter-architect + testing-specialist (ALL WORK IN PARALLEL)
- **Real-time Features** → firebase-specialist + performance-optimizer + flutter-architect + testing-specialist (ALL WORK IN PARALLEL)
- **Testing** → testing-specialist + flutter-architect (WORK IN PARALLEL)
- **Performance** → performance-optimizer + flutter-architect + testing-specialist (ALL WORK IN PARALLEL)

**PARALLEL Execution Process (MANDATORY):**
1. **Launch Multiple Agents Simultaneously** - Use multiple Task tool calls in single message for maximum parallel execution
2. **Coordinated Development** - All agents work on their specialization simultaneously
3. **Platform Verification by ALL** - Every agent must verify platforms build after their changes
4. **Structured Handoff** - When coordination needed between agents:
   ```
   HANDOFF TO [NEXT-AGENT]:
   - Completed: [What was implemented]
   - Platform Verification: ✅ PASSED - All platforms build successfully
   - Next Required: [What the next agent needs to do]
   - Context: [Important implementation details]  
   - Files Modified: [List of files created/changed]
   - Testing Status: [What tests are written/needed]
   ```
3. **Final Validation**: code-reviewer subagent validates complete implementation
4. **Quality Gates**: All agents follow project standards and use centralized components

**Communication Standards:**
- Each sub-agent follows project standards from CLAUDE.md
- All sub-agents use centralized UI components and approved colors
- Sub-agents communicate through structured handoff templates
- Clear documentation of work completed and next steps required

### Agent Coordination & Unblocking Protocols (CRITICAL)

**MANDATORY: Continuous Agent Status Monitoring**
- **Check agent status BEFORE launching**: Use `flutter analyze` to detect blocking issues
- **Monitor during execution**: Track compilation errors and build failures in real-time
- **Coordinate unblocking**: Immediately address critical architecture issues that block multiple agents

#### Agent Blocking Detection System

**Critical Blocking Indicators:**
```bash
# Run these commands to detect agent blocking issues:
flutter analyze                    # Detect compilation errors (>50 errors = BLOCKED)
flutter test --dry-run            # Detect test framework issues  
dart run build_runner build       # Detect code generation issues
flutter run --debug --dry-run     # Detect navigation/routing issues
```

**Blocking Issue Categories:**
1. **CRITICAL (Blocks ALL agents)**: Missing core architecture, Result pattern issues, code generation failures
2. **HIGH (Blocks 2+ agents)**: Navigation system missing, UI constants missing, Firebase provider issues  
3. **MEDIUM (Blocks 1 agent)**: Feature-specific implementation issues, test-specific problems

#### Unblocking Protocol (MANDATORY EXECUTION)

**Phase 1: Immediate Triage (30 seconds)**
```bash
# Quick status check command sequence:
flutter analyze | head -20        # Get first 20 errors for triage
git status                        # Check working tree state
flutter doctor                    # Verify Flutter environment
```

**Phase 2: Critical Fix Implementation (Parallel)**
- **Launch flutter-architect**: Fix core architecture blocking issues
- **Launch ui-designer**: Create missing UI constants and theme system
- **Launch firebase-specialist**: Fix Firebase provider integration
- **Launch testing-specialist**: Fix test framework and mocking issues

**Phase 3: Agent Coordination During Fixes**
```
AGENT UNBLOCKING STATUS UPDATE:
- Current Blocking Issue: [Specific error/missing component]
- Fix Status: [IN_PROGRESS/COMPLETED/NEEDS_ASSISTANCE] 
- Platform Verification: [✅ PASSED / ⚠️ BUILDING / ❌ FAILED]
- Impact on Other Agents: [Which agents can now proceed]
- Next Critical Fix: [What needs to be fixed next]
```

**Phase 4: Immediate Verification & Resume**
```bash
# After each critical fix, run verification:
flutter analyze                   # Must show <10 errors to proceed
flutter test --dry-run           # Tests must compile successfully
flutter run --debug --dry-run    # App must compile for all platforms
```

#### Agent Recovery Workflow

**RECOVERY SEQUENCE (When >50 compilation errors detected):**
1. **STOP all parallel agents immediately** - Prevent wasted parallel effort
2. **Triage critical blocking issues** - Identify root cause (architecture/navigation/UI/Firebase)
3. **Launch coordinated unblocking** - Deploy appropriate specialist agents for fixes
4. **Verify each fix immediately** - Run platform verification after each component fix
5. **Resume parallel execution** - Only after <10 compilation errors remain
6. **Continuous monitoring** - Check agent status every 5 minutes during execution

#### Agent Communication During Crisis

**BLOCKING ALERT FORMAT:**
```
🚨 AGENT BLOCKING DETECTED 🚨
- Total Errors: [Number]
- Blocked Agents: [List of affected agents]
- Root Cause: [Architecture/Navigation/UI/Firebase/Tests]
- Priority: [CRITICAL/HIGH/MEDIUM]
- Immediate Action: [Specific fix required]
```

**UNBLOCKING SUCCESS FORMAT:**
```
✅ AGENT UNBLOCKED ✅
- Fixed Component: [What was fixed]
- Remaining Errors: [Number]
- Agents Ready to Resume: [List]
- Platform Status: [All platforms building: YES/NO]
- Next Steps: [Continue with parallel execution/Additional fixes needed]
```

#### Parallel Execution Health Monitoring

**MANDATORY: Real-time Agent Health Checks**
- **Every 5 minutes**: Run `flutter analyze | wc -l` to track error count
- **After each agent completes a task**: Run platform verification
- **Before launching new parallel work**: Ensure error count <10
- **When any agent reports failure**: Immediately check blocking status

**Platform Verification Commands (Required after each fix):**
```bash
# Run all three in parallel to verify platform compatibility:
flutter build web --no-pub & 
flutter build apk --debug --no-pub &
flutter build ios --debug --no-pub --simulator &
wait  # Wait for all builds to complete
```

This coordination system ensures maximum parallel efficiency while preventing agent blocking cascades.

### MANDATORY Platform Verification for Pull Requests (CRITICAL)

**REQUIREMENT: All PRs MUST pass platform verification before creation**

#### Pre-PR Platform Verification Checklist (MANDATORY)

**Before creating ANY pull request, ALL of the following MUST pass:**

```bash
# 1. MANDATORY: Flutter Analysis (MUST show <50 issues)
flutter analyze
# ✅ REQUIRED: Less than 50 issues, no critical errors

# 2. MANDATORY: All Platform Builds MUST succeed
flutter build web --release             # ✅ Web build success required
flutter build apk --release             # ✅ Android build success required  
flutter build ios --release --no-codesign # ✅ iOS build success required

# 3. MANDATORY: All Platform App Execution MUST succeed
flutter run -d chrome --release         # ✅ Web app must launch and run
flutter run -d android --release        # ✅ Android app must launch and run
flutter run -d "iPhone Simulator" --release # ✅ iOS app must launch and run

# 4. MANDATORY: Test Suite MUST pass
flutter test                            # ✅ All tests must pass
```

#### Platform Verification Requirements

**Web Platform:**
- ✅ Build completes without errors
- ✅ App launches in Chrome without console errors
- ✅ Navigation system works correctly
- ✅ Firebase authentication initializes
- ✅ UI components render with proper theming

**Android Platform:**
- ✅ APK builds successfully
- ✅ App installs and launches on emulator/device
- ✅ All native dependencies resolve correctly
- ✅ Firebase services initialize properly
- ✅ UI adapts to Material Design guidelines

**iOS Platform:**
- ✅ iOS build completes without CocoaPods errors
- ✅ App launches on iOS Simulator
- ✅ Firebase services initialize properly
- ✅ UI adapts to Cupertino design patterns
- ✅ All native iOS dependencies resolve correctly

#### Automated Platform Verification Script

Create and use this script before ANY PR creation:

```bash
#!/bin/bash
# scripts/platform-verification.sh - MANDATORY before PR creation

echo "🚀 MANDATORY Platform Verification for PR Creation"
echo "================================================="

# Step 1: Flutter Analysis
echo "📊 Step 1: Flutter Analysis (MUST be <50 issues)"
flutter analyze > analysis_results.txt
issues_count=$(grep -c "•" analysis_results.txt || echo "0")
echo "   Issues found: $issues_count"
if [ "$issues_count" -gt 50 ]; then
    echo "❌ FAILED: Too many issues ($issues_count > 50). Fix issues before PR."
    exit 1
fi
echo "✅ PASSED: Flutter analysis ($issues_count issues)"

# Step 2: Platform Builds
echo "🏗️  Step 2: Platform Builds (ALL must succeed)"

echo "   Building Web..."
if flutter build web --release; then
    echo "✅ PASSED: Web build successful"
else
    echo "❌ FAILED: Web build failed. Fix build before PR."
    exit 1
fi

echo "   Building Android..."  
if flutter build apk --release; then
    echo "✅ PASSED: Android build successful"
else
    echo "❌ FAILED: Android build failed. Fix build before PR."
    exit 1
fi

echo "   Building iOS..."
if flutter build ios --release --no-codesign; then
    echo "✅ PASSED: iOS build successful"
else
    echo "❌ FAILED: iOS build failed. Fix build before PR."
    exit 1
fi

# Step 3: Test Suite
echo "🧪 Step 3: Test Suite (ALL must pass)"
if flutter test; then
    echo "✅ PASSED: All tests successful"
else
    echo "❌ FAILED: Tests failed. Fix tests before PR."
    exit 1
fi

# Step 4: App Execution Verification (Optional but Recommended)
echo "📱 Step 4: App Execution Verification"
echo "   Manual verification required:"
echo "   - flutter run -d chrome --release"
echo "   - flutter run -d android --release" 
echo "   - flutter run -d 'iPhone Simulator' --release"

echo ""
echo "🎉 ALL PLATFORM VERIFICATIONS PASSED!"
echo "✅ Ready to create Pull Request"
echo "================================================="
```

#### PR Creation Requirements Update

**Updated GitHub Workflow Standards:**

1. **BEFORE creating PR**: Run `scripts/platform-verification.sh`
2. **PR Description MUST include**:
   ```markdown
   ## Platform Verification ✅
   
   - [x] ✅ Flutter Analysis: <50 issues (Actual: X issues)
   - [x] ✅ Web Build: Successful
   - [x] ✅ Android Build: Successful  
   - [x] ✅ iOS Build: Successful
   - [x] ✅ Tests: All passing
   - [x] ✅ Web App: Launches and runs correctly
   - [x] ✅ Android App: Launches and runs correctly
   - [x] ✅ iOS App: Launches and runs correctly
   ```

3. **PR Review Requirements**: Reviewers MUST verify platform verification checklist before approving

#### Consequences of Non-Compliance

**PR WITHOUT platform verification will be:**
- ❌ **Immediately rejected** without review
- 🔄 **Sent back for fixes** with platform verification requirement
- ⚠️ **Flagged for process violation** in project records

**This ensures:**
- ✅ **Production-ready code** in all PRs
- ✅ **Cross-platform compatibility** guaranteed
- ✅ **No build-breaking changes** in development branch
- ✅ **Consistent quality standards** across all contributions

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

**Related Documentation**:
- See `DEVELOPMENT_GUIDE.md` for complete development workflow and command usage
- See `.claude/commands/implement-issue.md` for automated agent assignment process
- See `scripts/develop-feature.sh` for automated branch creation and setup

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

**Command Documentation**: Detailed command implementations are in `.claude/commands/` directory.

**Available Commands**:
- `/project:brainstorm-feature "description"` - Implemented in `.claude/commands/brainstorm-feature.md`
- `/project:implement-issue <number>` - Implemented in `.claude/commands/implement-issue.md`
- `/project:create-feature <name>` - Feature scaffolding automation

**Shell Script Commands**: For manual execution, use scripts in `scripts/` directory (see `DEVELOPMENT_GUIDE.md` for usage).

Create these additional custom slash commands for repeated workflows:

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

### Documentation Style (MANDATORY)
- **All .md files**: Use concise bullet points, NO lengthy paragraphs
- **Comments**: One line max, explain WHY not WHAT
- **Descriptions**: Max 100 words, essential info only
- **Reference**: See `docs/github_instruction.md` for examples

## UI/UX Design Guidelines

**Complete UI/UX specifications are documented in `docs/ui_guideline.md`**

This comprehensive guide includes:
- **Color Palette**: Primary brand colors, answer button colors, neutral colors, and dark mode support
- **Typography System**: Font hierarchies, text sizes, and weights for all UI elements
- **Component Library**: Standardized buttons, inputs, cards, and layout components
- **Animation Standards**: Consistent timing, easing curves, and micro-interactions
- **Spacing System**: 8dp grid-based spacing constants
- **Platform Adaptations**: Material Design (Android) and Cupertino (iOS) considerations
- **Accessibility**: Color contrast requirements and touch target guidelines
- **Performance**: Best practices for gradients, shadows, and animations

### Implementation Structure
All UI constants and components must be implemented in:
```
lib/shared/
├── constants/
│   ├── app_colors.dart         # Color palette from ui_guideline.md
│   ├── app_text_styles.dart    # Typography system
│   ├── app_spacing.dart        # Spacing constants
│   ├── app_animations.dart     # Animation durations/curves
│   └── app_dimensions.dart     # Component sizes
├── theme/
│   ├── app_theme.dart          # Material theme configuration
│   └── dark_theme.dart         # Dark mode theme
└── widgets/
    └── primitives/             # Base components using constants
```

**Important**: All sub-agents must reference `docs/ui_guideline.md` for UI implementation details and use only the approved design system constants.

## Deployment Pipeline

**Complete Workflow Reference**: See `DEVELOPMENT_GUIDE.md` for detailed 13-week development timeline and phase-by-phase implementation guide.

**Quick Pipeline Overview**:
1. **Explore**: Read and understand existing code structure
2. **Plan**: Create GitHub issue following standards (max 100 words) - see `docs/github_instruction.md`
3. **Design**: Use UI guidelines and centralized components (defined in this file)
4. **Test**: Write tests first following TDD approach - see `.claude/agents/testing-specialist.md`
5. **Code**: Implement with clear commit messages (`type(scope): description`) - see `docs/github_instruction.md`
6. **Review**: Use Claude Code subagents with specific feedback - see `.claude/agents/code-reviewer.md`
7. **Test E2E**: Run Playwright MCP tests for web platform
8. **Deploy**: Firebase deployment via GitHub Actions
9. **Monitor**: Performance monitoring and analytics
10. **Iterate**: User feedback integration for continuous improvement

**Automation**: Use `scripts/quality-check.sh` before creating PRs and `scripts/firebase-ops.sh` for deployment operations.