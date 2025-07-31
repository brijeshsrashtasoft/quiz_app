# Implement Ticket - Orchestration Logic

## Command Execution Flow

When `/project:implement-ticket US-001` is invoked:

### 1. Initialization Phase (Coordinator)
```
coordinator:
  1. Read US-001_email_signup.md → Parse requirements
  2. Read US-001_email_signup_STATUS.md → Check current progress
  3. Analyze codebase:
     - lib/features/authentication/ → Current implementation
     - lib/core/navigation/app_router.dart → Router setup
     - Firebase configuration status
  4. Create implementation plan with parallel tracks
```

### 2. Parallel Agent Deployment

```yaml
Track 1 - Architecture (flutter-architect):
  tasks:
    - Set up auth repository interface
    - Implement user profile service  
    - Configure dependency injection
    - Set up auth state management
  
Track 2 - Backend (firebase-specialist):
  tasks:
    - Firebase Auth integration
    - Firestore user collection setup
    - Email verification configuration
    - Security rules update

Track 3 - UI (ui-designer):
  tasks:
    - RegisterPage form implementation
    - EmailVerificationPage creation
    - Loading states and animations
    - Error message displays

Track 4 - Testing (testing-specialist):
  tasks:
    - Unit test creation
    - Integration test setup
    - E2E test scenarios
    - Test data factories
```

### 3. Coordination Points

```
Sync Point 1 (After 30 min):
  - flutter-architect completes repository interface
  - firebase-specialist implements auth methods
  - Both sync on interface contract
  
Sync Point 2 (After 45 min):
  - ui-designer needs loading states
  - flutter-architect provides state management
  - Coordinate on state structure

Sync Point 3 (After 60 min):
  - All implementation complete
  - testing-specialist runs all tests
  - Identify and fix failures
```

### 4. Real-time Status Updates

```markdown
[15:00:00] 🚀 Starting implementation of US-001

[15:05:00] 📋 Analysis complete:
- 11 acceptance criteria identified
- 23 technical tasks created
- 4 parallel tracks planned

[15:10:00] 👥 Agents deployed:
- flutter-architect: Starting auth architecture
- firebase-specialist: Configuring Firebase
- ui-designer: Creating UI components
- testing-specialist: Setting up test framework

[15:20:00] 📊 Progress Update:
Overall: 25% [█████░░░░░░░░░░░░░░░]
- Architecture: 40% (repository created)
- Backend: 30% (Firebase connected)
- UI: 20% (form layout done)
- Testing: 15% (test structure ready)

[15:30:00] ✅ Sync Point 1 Complete:
- Auth repository interface defined
- Firebase methods implemented
- Integration successful

[15:40:00] ⚠️ Issue Detected:
- UI breakage in login page
- ui-designer investigating...
- Fixed: Missing provider in widget tree

[15:50:00] 🧪 Testing Phase:
- Running unit tests... ✅ 45/45 passed
- Running integration tests... ✅ 12/12 passed
- Starting E2E tests...

[16:00:00] 📱 Platform Testing:
- Web: ✅ All tests passed
- Android: ✅ Build successful, tests passed
- iOS: ⏳ Simulator starting...

[16:15:00] ✅ Implementation Complete!
- All acceptance criteria met
- All tests passing
- No UI breakage detected
- Ticket status updated to 100%
```

### 5. Error Handling Example

```
[15:35:00] ❌ Build Error Detected:
Error: The method 'signUpWithEmailAndPassword' isn't defined

🔧 Deploying fix:
- firebase-specialist: Checking method name
- Found: Should be 'createUserWithEmailAndPassword'
- Fixing in auth_repository_impl.dart
- Retrying build... ✅ Success

[15:42:00] ❌ Test Failure:
Test: email_validation_test.dart
Error: Expected 'Invalid email', got 'Please enter valid email'

🔧 Fixing:
- testing-specialist: Updating expected message
- ui-designer: Ensuring consistent error messages
- Re-running tests... ✅ All passed
```

### 6. Checkpoint Creation

```json
{
  "ticketNumber": "US-001",
  "timestamp": "2024-01-20T15:45:00Z",
  "overallProgress": 75,
  "agentStatus": {
    "flutter-architect": {
      "status": "completed",
      "tasks": ["repository", "service", "state"],
      "progress": 100
    },
    "firebase-specialist": {
      "status": "active",
      "currentTask": "email_verification",
      "progress": 85
    },
    "ui-designer": {
      "status": "completed",
      "tasks": ["forms", "pages", "animations"],
      "progress": 100
    },
    "testing-specialist": {
      "status": "active", 
      "currentTask": "e2e_tests",
      "progress": 60
    }
  },
  "completedCriteria": [
    "email_validation",
    "password_requirements",
    "form_ui",
    "firebase_auth"
  ],
  "blockers": [],
  "nextActions": [
    "Complete email verification setup",
    "Finish E2E tests",
    "iOS platform verification"
  ]
}
```

### 7. Resume Logic

When command is run again after interruption:

```
[16:30:00] 🔄 Resuming implementation of US-001

[16:30:05] 📥 Loading checkpoint from 15:45:00
- Overall progress: 75%
- Completed tasks verified ✅
- 2 agents need to resume work

[16:30:10] 👥 Re-deploying agents:
- firebase-specialist: Resuming email verification (85%)
- testing-specialist: Resuming E2E tests (60%)

[16:35:00] ✅ Email verification complete
[16:40:00] ✅ E2E tests complete
[16:45:00] ✅ iOS verification complete

[16:45:30] 🎉 Implementation Complete!
All criteria met. Ticket US-001 is DONE.
```

## Agent Communication Protocol

### Message Types

```typescript
interface AgentMessage {
  from: AgentType;
  to: AgentType | 'coordinator';
  type: 'status' | 'request' | 'complete' | 'error' | 'sync';
  content: any;
}

// Examples:
{
  from: 'flutter-architect',
  to: 'firebase-specialist',
  type: 'sync',
  content: {
    interface: 'AuthRepository',
    methods: ['signUp', 'signIn', 'signOut']
  }
}

{
  from: 'ui-designer',
  to: 'coordinator',
  type: 'error',
  content: {
    error: 'Missing provider',
    file: 'register_page.dart',
    line: 45
  }
}
```

### Conflict Resolution

When agents modify same file:
1. Coordinator detects conflict
2. Analyzes changes from both agents
3. Merges if non-overlapping
4. Requests agent coordination if overlapping
5. Applies merged changes
6. Re-runs verification

## Continuous Verification

After every change:
1. Hot reload check
2. Widget tree validation  
3. State management check
4. No regression in other features

Every 10 minutes:
1. Full flutter analyze
2. Unit test suite
3. Build verification

Before completion:
1. All platform builds
2. Full E2E test suite
3. Performance benchmarks
4. Security scan