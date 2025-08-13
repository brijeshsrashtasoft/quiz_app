# CLAUDE.md - Project Master Documentation

## 📚 Key Documentation
- **docs/github_instruction.md** - GitHub workflow standards and commit formats  
- **docs/ui_guideline.md** - UI/UX design system and component specifications
- **docs/tickets/{branch-name}.md** - UNIFIED ticket tracking (ONE file per issue)
- **.claude/agents/** - Sub-agent documentation (flutter-architect, firebase-specialist, ui-designer, testing-specialist, code-reviewer, performance-optimizer, test-failure-analyzer, pr-review-agent)
- **.claude/commands/implement-issue.md** - Automated agent assignment with unified tracking

## Project Overview
Kahoot-style interactive quiz app built with Flutter, Firestore, and Clean Architecture. Supports real-time multiplayer quiz sessions across Android, iOS, and web platforms.

**🎯 STATUS**: Foundation complete. Ready for parallel development with 8 issues available.

## Development Approach
- **MAIN APP ONLY**: Focus exclusively on core functionality - NO testing required
- **NO TEST WRITING**: Skip all test creation/modification - main app development only
- **COMPILATION MANDATORY**: All platforms must build successfully (Web, Android, iOS)
- **Workflow**: Explore → Plan → Code → Verify Build → Commit
- **Task Completion Criteria**: flutter analyze (zero issues) + successful compilation

## Unified Ticket System
**Format**: `docs/tickets/{branch-name}.md` (ONE file per issue)
**Structure**: Nested checkboxes for all agents in SAME file
**Updates**: MANDATORY on every status change

## 🆓 FREE SERVICES ONLY POLICY
**CRITICAL**: Only free tier services allowed. NO paid APIs or cloud services.

**Allowed**: Firebase Free Tier, GitHub Free, Flutter, Open source packages
**Prohibited**: Cloud Functions, Firebase ML/AI, Paid APIs, Premium storage, Subscription services

## Architecture
### Clean Architecture Pattern
```
lib/
├── core/                 # Shared utilities and constants
├── features/             # Feature-based organization (auth, quiz, game, leaderboard)
│   └── game_session/     # Game session management
│       ├── data/         # Data sources and repositories
│       ├── domain/       # Entities, use cases, repository interfaces
│       └── presentation/ # Pages, widgets, providers
│           ├── pages/    # GameHostSetupPage, HostGameScreen
│           ├── providers/# GameHostSetupProvider, SessionProviders
│           └── widgets/  # Reusable UI components
└── shared/              # Shared widgets and providers
```

## Essential Commands
```bash
flutter run                    # Debug mode with hot reload
flutter analyze               # Static analysis - MANDATORY before any commit
flutter build web/apk/ios     # Platform builds
dart format .                  # Code formatting
firebase emulators:start      # Local Firebase
```

## 🔍 DART ANALYSIS POLICY (ABSOLUTE ZERO TOLERANCE)
**CRITICAL REQUIREMENT**: ALL agents MUST achieve PERFECT analysis before ANY code changes.

### Analysis Standards:
- **ABSOLUTE ZERO**: No errors, warnings, info, hints, or any analysis output allowed
- **PERFECT STANDARD**: Only "No issues found!" is acceptable
- **PRE-CODE CHECK**: Run `flutter analyze` - must be completely clean
- **POST-CODE CHECK**: Verify zero issues after every single change
- **COMMIT BLOCKER**: NO commits allowed with ANY analysis output

### Flutter API Compliance (MANDATORY):
- **OFFICIAL SOURCES ONLY**: Always use https://docs.flutter.dev/ and https://api.flutter.dev/
- **NO DEPRECATED APIs**: Never use deprecated methods/classes
- **CURRENT API REFERENCE**: Check Flutter docs for correct modern API usage
- **VERSION COMPATIBILITY**: Ensure APIs match current Flutter version
- **BEST PRACTICES**: Follow official Flutter guidelines and conventions

### Enforcement Rules:
1. **Before coding**: `flutter analyze` must show "No issues found!" (zero output)
2. **API verification**: Check Flutter docs for correct API usage before writing code
3. **After changes**: Re-run analysis - must remain at zero issues
4. **Mass fixes**: Use official Flutter migration guides and verified patterns
5. **Documentation check**: Reference https://docs.flutter.dev/ for any API questions
6. **Agent coordination**: All sub-agents must follow this absolute zero policy

## 📋 TASK COMPLETION CRITERIA (MANDATORY)
**EVERY TASK MUST PASS THESE CHECKS BEFORE COMPLETION:**

### Required Verifications:
1. **Flutter Analyze**: `flutter analyze` - MUST show "No issues found!" (absolute zero)
2. **Compilation Check**: `flutter build web` - MUST compile successfully without errors
3. **NO TESTING**: Skip all test writing/modification - main app only
4. **API Compliance**: All code uses current Flutter APIs (no deprecated methods)

### Task NOT Complete Until:
- ✅ Zero analysis issues (no errors, warnings, info, hints)  
- ✅ Successful compilation on target platforms
- ✅ No deprecated API usage
- ❌ NO test writing required

## Sub-Agent System (MANDATORY)

### Available Sub-Agents
- **flutter-architect** - Clean Architecture implementation
- **firebase-specialist** - Firestore, Authentication, real-time features
- **ui-designer** - Kahoot-style UI and design system compliance
- **testing-specialist** - NOT USED (main app development only)
- **code-reviewer** - Quality assurance and compliance
- **performance-optimizer** - Performance optimization
- **pr-review-agent** - **EXCLUSIVE** PR review and merge authority

### Usage Rules
- **ALWAYS DELEGATE** to specialized sub-agents
- **PARALLEL EXECUTION** - Use multiple agents simultaneously
- **MANDATORY** - Even simple tasks must use appropriate sub-agents

## Platform Verification (MANDATORY)

### Pre-PR Requirements (ALL must pass)
```bash
flutter analyze                    # <50 issues required
flutter build web --release       # Web build success
flutter build apk --release       # Android build success  
flutter build ios --release       # iOS build success
```

## PR Authority Protocol
- **PR Creation**: Any agent can create PR
- **PR Review**: ONLY pr-review-agent reviews and approves
- **PR Merge**: ONLY pr-review-agent can merge PRs
- **Auto-Trigger**: implement-issue.md MUST invoke pr-review-agent after PR creation

## Development Workflow

### Branch Strategy
- `main` - Production-ready (protected)
- `development` - Integration branch (all PRs target here)
- `feature/issue-{number}-{description}` - Individual features

### Commit Standards
```bash
git commit -m "type(scope): description - closes #issue-number"
# Types: fix, feat, docs, refactor, chore
```

## Technology Stack

### Core Dependencies
- `flutter_riverpod` - State management
- `go_router` - Routing
- `freezed` - Immutable data classes
- `firebase_core/auth/firestore` - Backend

### Firebase Structure
```
users/{userId} - User profiles
quizzes/{quizId} - Quiz data
game_sessions/{sessionId} - Live game sessions
leaderboards/{sessionId} - Real-time scores
```

## UI/UX Guidelines
**Reference**: `docs/ui_guideline.md` for complete specifications

### Implementation Structure
```
lib/shared/
├── constants/    # Colors, text styles, spacing, animations
├── theme/        # Material/dark themes
└── widgets/      # Reusable UI components
```

## Agent Coordination & Crisis Management

### Blocking Detection
```bash
flutter analyze | head -20    # Check for >50 errors (BLOCKED)
flutter build web/apk/ios    # Compilation verification
dart run build_runner build  # Code generation issues
```

### Recovery Protocol
1. **STOP** parallel agents if >50 errors
2. **TRIAGE** critical issues (architecture/navigation/UI/Firebase)
3. **DEPLOY** specialist agents for fixes
4. **VERIFY** each fix immediately
5. **RESUME** only after <10 errors remain

## Quality Standards

### Code Requirements
- Clean Architecture principles
- Riverpod for state management
- Proper error handling with Result pattern
- Freezed for immutable classes
- Flutter/Dart style guide compliance

### Documentation Requirements
- Concise bullet points (no lengthy paragraphs)
- Max 100 words for descriptions
- One line comments explaining WHY not WHAT
- Cross-references updated in all related files

## Custom Commands
- `/project:implement-issue <number>` - Automated agent assignment
- `/project:brainstorm-feature "description"` - Feature planning
- Use scripts in `scripts/` directory for manual operations

## Performance & Security
- App startup: <3 seconds
- Real-time updates: <200ms latency
- Memory: <100MB mobile
- Never commit secrets
- HTTPS for all communications
- Firebase Security Rules for data protection

---
**Focus**: Main app implementation only. NO testing required - compilation + analysis verification only.
