# Implement Ticket Command

Automates the complete implementation of a user story ticket with continuous verification, testing, and status tracking.

## Usage
```
/project:implement-ticket <ticket-number>
```

Example: `/project:implement-ticket US-001`

## Workflow

### 0. Firebase Pre-Flight Checklist (MANDATORY BEFORE ANY IMPLEMENTATION)
- **Firebase Project Verification**:
  - Verify Firebase project exists in Firebase Console
  - Check `firebase.json` and `.firebaserc` configuration
  - Confirm `google-services.json` (Android) exists in `android/app/`
  - Confirm `GoogleService-Info.plist` (iOS) exists in `ios/Runner/`
  - Verify `web/index.html` has Firebase config script
- **Firebase SDK Initialization**:
  - Check `lib/main.dart` for `Firebase.initializeApp()`
  - Verify Firebase options configuration for all platforms
  - Test Firebase connection with simple read operation
- **Firestore Setup Verification**:
  - Check Firestore security rules allow read/write
  - Verify Firestore indexes are created
  - Test basic CRUD operations work
  - Confirm real-time listeners receive updates
- **Firebase Emulator Check**:
  - Verify `firebase emulators:start` runs without errors
  - Check app connects to emulators in debug mode
  - Test data persistence in emulator

### 1. Ticket Analysis Phase
- Read ticket file from `docs/github_tickets/`
- Parse acceptance criteria and technical requirements
- Analyze current codebase implementation
- Analyze test codebase if not create present create a implementation plan for Unit tests, Integration tests & E2E tests
- Create implementation plan for main app and testcase

### 2. Implementation Phase
- Deploy multiple specialized agents in parallel
- Create shared TodoWrite list for cross-agent coordination
- Follow existing architecture patterns
- Implement features incrementally
- Create missing main app code and modify existing code as needed
- Implement test case suites incrementally following main app folder structure
- Create missing test cases and modify existing test cases as needed
- Update ticket status in real-time by finding specific ticket in `docs/github_tickets/`
- NEVER create any new .md file for tracking - use existing ticket file that contains the ticket number in filename 

### 3. Verification Phase
- Run static analysis (`flutter analyze`)
- Execute unit tests
- Run integration tests
- Perform E2E testing on emulators

### 4. Status Tracking
- Update ticket file with progress
- Mark completed items with ✅
- Track pending items with ⏳
- Log errors and fixes

## Agent Deployment Strategy

### Primary Coordinator
Manages overall implementation and tracks progress across all sub-agents.

### Specialized Sub-Agents
1. **flutter-architect**: Architecture and structure
2. **firebase-specialist**: Backend integration (ENHANCED RESPONSIBILITIES)
   - MUST verify Firebase initialization before ANY work
   - MUST test real-time data flow for EVERY feature
   - MUST implement proper error handling for ALL Firebase calls
   - MUST use repositories with streams for real-time updates
   - MUST update security rules for new collections
   - MUST test offline functionality
3. **ui-designer**: UI implementation
4. **testing-specialist**: Test creation and execution
5. **code-reviewer**: Quality assurance

### Agent Coordination Guidelines
1. **Shared TodoWrite List** - Primary coordinator creates initial todo list that ALL agents can see
2. **Cross-Agent Communication** - Agents must check shared todos to avoid conflicts
3. **Aligned Implementation** - If conflicting work detected, agents must coordinate approach
4. **Progress Updates** - Each agent updates shared todos when starting/completing tasks
5. **No Duplicate Work** - Check todos before starting any implementation
6. **Test-Code Sync** - Testing specialist coordinates with implementers for coverage

### Parallel Execution
- Frontend and backend development simultaneously
- Test creation alongside implementation
- Continuous integration checks
- Real-time coordination through shared TodoWrite

## Implementation Rules

### Code Standards
1. **Use existing patterns** - Never create new patterns if existing ones work
2. **File organization** - Follow current project structure
3. **No unnecessary files** - Reuse existing components
4. **Clean Architecture** - Maintain separation of concerns
5. **NO NEW MD FILES** - Never create .md files for planning/tracking - use existing ticket files
6. **Existing Ticket System** - Find ticket file in docs/github_tickets/ by ticket number in filename

### Development Process
1. **Read before write** - Always check existing code first
2. **Incremental changes** - Small, testable commits
3. **Continuous testing** - Test after each change
4. **Error handling** - Implement comprehensive error cases

### Testing Requirements
1. **Unit tests** - Minimum 85% coverage
2. **Integration tests** - All Firebase operations
3. **E2E tests** - Complete user flows on:
   - Android emulator
   - iOS simulator  
   - Web browser

### Mandatory Implementation Tasks
1. **Main App Code** - MUST create missing functionality and modify existing code
2. **Test Cases** - MUST create missing tests and modify existing tests
3. **Both Required** - Cannot skip either main code or tests
4. **Full Coverage** - Tests must cover all new/modified functionality
5. **Platform Testing** - Verify on all target platforms

### Firebase Implementation Standards (CRITICAL)
1. **Repository Pattern** - ALL Firestore operations MUST go through repositories
2. **Stream Controllers** - Use StreamBuilder for real-time data
3. **Error Handling** - Wrap ALL Firebase calls in try-catch with proper error messages
4. **Offline Support** - Enable offline persistence: `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true)`
5. **Security Rules** - MUST update Firestore rules for new collections
6. **Data Models** - Use Freezed classes with proper fromJson/toJson
7. **Real-time Updates** - Use snapshots() not get() for live data
8. **Batch Operations** - Use batch writes for multiple document updates

## Status Management

### Ticket File Updates
```markdown
## Implementation Status

### Overall Progress: 45% ⏳

### Acceptance Criteria
- [x] ✅ User can access registration from login page
- [x] ✅ Email validation implemented
- [ ] ⏳ Password requirements (in progress)
- [ ] ❌ Loading states (blocked - fixing state management)
- [ ] ⏰ Success redirects (pending)

### Technical Tasks
- [x] ✅ Router configuration updated
- [x] ✅ Firebase Auth integration
- [ ] ⏳ User profile service (50% complete)
- [ ] ⏰ Error handling

### Testing Status
- [x] ✅ Unit tests: email validation
- [ ] ⏳ Integration tests: Firebase calls
- [ ] ⏰ E2E tests: Registration flow

### Current Blockers
- State management issue in auth_provider.dart
- Firebase emulator connection on iOS

### Last Updated: 2024-01-20 14:30:00
```

## Verification Checklist

### Pre-Implementation
- [ ] Ticket file exists and is readable
- [ ] Related code files identified
- [ ] No conflicting work in progress
- [ ] Dependencies available

### Firebase Pre-Implementation (MANDATORY - STOP if any fail)
- [ ] Firebase project linked (check .firebaserc)
- [ ] Platform configs present (google-services.json, GoogleService-Info.plist, web config)
- [ ] Firebase.initializeApp() called in main.dart
- [ ] Test write to Firestore successful
- [ ] Test read from Firestore successful
- [ ] Real-time listener receives updates
- [ ] Firebase Auth initialized (even if not using auth)
- [ ] Emulators running and connected
- [ ] Security rules allow test operations
- [ ] No Firebase errors in console logs

### During Implementation
- [ ] No UI breakage after each change
- [ ] `flutter analyze` passes (< 50 errors)
- [ ] Hot reload works correctly
- [ ] State management consistent

### Post-Implementation
- [ ] All acceptance criteria met
- [ ] All tests passing
- [ ] No regression in existing features
- [ ] Performance benchmarks met

## Error Recovery

### Build Failures
1. Run `flutter clean`
2. Delete `.dart_tool/` and `pubspec.lock`
3. Run `flutter pub get`
4. Regenerate code with `build_runner`

### Test Failures
1. Identify failing test
2. Check for environment issues
3. Fix implementation
4. Re-run specific test
5. Run full test suite

### State Corruption
1. Clear app data
2. Reset Firebase emulators
3. Clean build
4. Fresh install

### Firebase Connection Issues (CRITICAL DEBUG STEPS)
1. **Check Firebase Initialization**:
   ```dart
   // In main.dart - MUST have this
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```
2. **Verify Platform Configuration**:
   - Android: Check `android/app/google-services.json` matches Firebase project
   - iOS: Check `ios/Runner/GoogleService-Info.plist` matches Firebase project
   - Web: Check Firebase config in `web/index.html`
3. **Test Basic Connection**:
   ```dart
   // Test Firestore connection
   try {
     await FirebaseFirestore.instance.collection('test').doc('test').set({'test': true});
     print('Firebase connected successfully');
   } catch (e) {
     print('Firebase connection failed: $e');
   }
   ```
4. **Enable Debug Logging**:
   ```dart
   FirebaseFirestore.instance.settings = Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
   );
   ```
5. **Check Security Rules**:
   ```
   // Temporary test rules (DO NOT use in production)
   match /{document=**} {
     allow read, write: if true;
   }
   ```

## Continuous Execution

### Resume Capability
When command is run again:
1. Read current ticket status
2. Identify incomplete tasks
3. Check for new blockers
4. Continue from last checkpoint
5. Re-verify completed items

### Checkpoint System
- Save progress every 10 minutes
- Create restore points before major changes
- Log all actions for rollback

## Success Criteria

### Definition of Done
- ✅ All acceptance criteria implemented
- ✅ All tests passing (unit, integration, E2E)
- ✅ No UI breakage on any platform
- ✅ No errors in `flutter analyze`
- ✅ Code reviewed and approved
- ✅ Documentation updated
- ✅ Ticket file shows 100% completion

### Platform Verification
- ✅ Android: Tested on API 30+ emulator
- ✅ iOS: Tested on iOS 14+ simulator
- ✅ Web: Tested on Chrome, Firefox, Safari

## Command Behavior

### Execution Flow
1. **Parse** - Read and understand ticket
2. **Plan** - Create implementation strategy
3. **Execute** - Deploy agents to implement
4. **Verify** - Test on all platforms
5. **Update** - Mark progress in ticket
6. **Iterate** - Repeat until done

### Exit Conditions
- All tasks completed successfully
- User explicitly cancels
- Unrecoverable error (with detailed log)

### Progress Reporting
- Real-time status updates
- Detailed logs of actions
- Clear error messages
- Next steps guidance

## Example Execution

```bash
/project:implement-ticket US-001

🚀 Starting implementation of US-001: Email/Password Sign Up

📋 Analyzing ticket requirements...
✅ Found 12 acceptance criteria
✅ Identified 8 technical tasks

📝 Creating shared TodoWrite list for agent coordination:
- [ ] Setup auth architecture (flutter-architect)
- [ ] Configure Firebase Auth (firebase-specialist)
- [ ] Create registration UI (ui-designer)
- [ ] Write unit tests for auth (testing-specialist)
- [ ] Write integration tests (testing-specialist)

👥 Deploying agents:
- flutter-architect: Checking todos, starting auth architecture
- firebase-specialist: Checking todos, configuring Firebase Auth
- ui-designer: Checking todos, creating registration UI
- testing-specialist: Checking todos, writing test cases

🔨 Implementation Progress:
[████████████████░░░░] 80% - Implementing password validation

✅ Completed:
- Router configuration
- Email validation
- Firebase integration
- UI components

⏳ In Progress:
- Password strength indicator
- Error message display

🧪 Running tests...
✅ Unit tests: 45/45 passed
✅ Integration tests: 12/12 passed
⏳ E2E tests: Running on Android...

📱 Platform Testing:
✅ Web: All tests passed
✅ Android: All tests passed
⏳ iOS: Testing in progress...

💾 Ticket status updated: 85% complete

⏸️ Checkpoint saved. Run command again to continue.
```

## Important Notes

1. **Never use `cat` command** - Always use Claude file tools
2. **Multiple agents** - Deploy specialists for parallel work
3. **Iterative approach** - Fix errors until everything works
4. **Status persistence** - Always update ticket file
5. **No shortcuts** - Complete all requirements fully