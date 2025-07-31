# Implement Ticket Command

Automates the complete implementation of a user story ticket with continuous verification, testing, and status tracking.

## Usage
```
/project:implement-ticket <ticket-number>
```

Example: `/project:implement-ticket US-001`

## Workflow

### 1. Ticket Analysis Phase
- Read ticket file from `docs/github_tickets/`
- Parse acceptance criteria and technical requirements
- Analyze current codebase implementation
- Create implementation plan

### 2. Implementation Phase
- Deploy multiple specialized agents in parallel
- Follow existing architecture patterns
- Implement features incrementally
- Update ticket status in real-time

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
2. **firebase-specialist**: Backend integration
3. **ui-designer**: UI implementation
4. **testing-specialist**: Test creation and execution
5. **code-reviewer**: Quality assurance

### Parallel Execution
- Frontend and backend development simultaneously
- Test creation alongside implementation
- Continuous integration checks

## Implementation Rules

### Code Standards
1. **Use existing patterns** - Never create new patterns if existing ones work
2. **File organization** - Follow current project structure
3. **No unnecessary files** - Reuse existing components
4. **Clean Architecture** - Maintain separation of concerns

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

👥 Deploying agents:
- flutter-architect: Setting up auth architecture
- firebase-specialist: Configuring Firebase Auth
- ui-designer: Creating registration UI
- testing-specialist: Writing test cases

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