# Auto-Fix Runtime Command

This command runs the app on a real emulator/device, monitors logs for errors/exceptions, and automatically fixes problems directly without documentation. Hot restarts automatically after agents fix issues.

**⚠️ CRITICAL PROJECT REQUIREMENTS**:
- **🆓 FREE SERVICES ONLY**: NO paid APIs, cloud functions, or premium services allowed
- **📱 PLATFORM VERIFICATION**: All platforms (Web, Android, iOS) MUST build successfully
- **🎨 UI GUIDELINES**: MANDATORY compliance with approved color system and components
- **🤖 AGENT COORDINATION**: ALWAYS use specialized sub-agents, never work directly

## Command Usage

```
/project:auto-fix-runtime [--device=device-id] [--max-attempts=5] [--log-level=error|warning|info]
```

## Parameters

- `--device` (optional): Specific device ID (default: auto-detect)
- `--max-attempts` (optional): Maximum fix attempts per issue (default: 5)
- `--log-level` (optional): Minimum log level to monitor (default: error)

## Examples

```bash
# Run with auto-detection and default settings
/project:auto-fix-runtime

# Run on specific device with custom attempts
/project:auto-fix-runtime --device=emulator-5554 --max-attempts=3

# Monitor warnings and errors
/project:auto-fix-runtime --log-level=warning
```

## 🆓 FREE SERVICES ONLY POLICY

**MANDATORY**: ALL fixes MUST use ONLY free tier services. NO paid APIs or cloud services allowed.

**Allowed Free Services:**
- **Firebase Free Tier**: Authentication, Firestore (limited), Hosting
- **GitHub**: Free tier with Actions (2000 minutes/month)
- **Flutter**: Open source framework
- **Dart packages**: Only free/open source packages

**Prohibited (NO PAID SERVICES):**
- ❌ Cloud Functions (Firebase paid feature)
- ❌ Firebase ML/AI services
- ❌ Third-party paid APIs
- ❌ Premium cloud storage
- ❌ Paid CI/CD services
- ❌ Any subscription-based services

## 🎨 UI GUIDELINES COMPLIANCE

**MANDATORY**: All UI fixes MUST comply with approved design system from docs/ui_guideline.md

### Approved Color System
**Primary Colors**: `#6C5CE7` (Purple), `#00D2D3` (Turquoise), `#FF6B6B` (Coral), `#4ECDC4` (Mint), `#FFE66D` (Yellow)
**Neutrals**: `#2D3436`, `#636E72`, `#F5F3F4`, `#FFFFFF`, `#DFE6E9`
**Dark Mode**: `#1E1E1E` (Background), `#2D2D2D` (Surface), `#F5F3F4` (Text)

### Component Requirements
- Use ONLY centralized components from lib/shared/widgets/
- Follow 8dp spacing grid system
- Maintain consistent border radius (12-16dp)
- Use approved animations and transitions

## Process Flow

### Phase 1: App Launch & Monitoring Setup
1. **Device Selection**: Auto-detect or use specified device
2. **App Launch**: Start app in debug mode with log streaming
3. **Monitor Setup**: Begin real-time log analysis
4. **User Interface**: Show monitoring status and issue reporting prompt

### Phase 2: Issue Detection & Collection
1. **Automatic Detection**: Catch exceptions, errors, and UI breakages from logs
2. **User Reporting**: Accept user-reported issues via interactive prompt
3. **Issue Classification**: Categorize by type (UI, Firebase, Navigation, etc.)
4. **Context Gathering**: Collect relevant logs, stack traces, and app state

### Phase 3: Automated Resolution Loop
1. **Agent Assignment**: Select appropriatepecialist agent
2. **Fix Implementation**: Agent analyzes and implements fix directly
3. **Auto Hot Restart**: Automatically hot restart after fix is applied
4. **Monitor**: Check if issue persists in logs
5. **Iteration**: Repeat until resolved or max attempts reached

**CRITICAL Platform Verification Requirements**:
```bash
# After EVERY fix attempt, verify builds:
flutter build web --release
flutter build apk --debug
```

### Phase 4: Summary Reporting
1. **No Documentation**: Focus on fixing issues directly
2. **Console Output**: Show fix progress in terminal only
3. **Final Report**: Brief summary of fixes applied

---

## 🚀 DIRECT FIX APPROACH

**NO DOCUMENTATION**: Focus on immediate fixes without creating tracking files.

## Implementation

You are the **Runtime Auto-Fix Orchestrator** responsible for:

1. **Environment Setup & App Launch**
   - Detect/select appropriate device
   - Launch app with enhanced logging
   - Set up real-time log monitoring

2. **Issue Detection & Auto-Fix**
   - Monitor logs for exceptions, errors, UI issues
   - Immediately assign to appropriate agent
   - Auto hot restart after fix applied

3. **Automated Fix Coordination**
   - Invoke appropriate specialist agents
   - Manage fix attempts and iterations
   - Handle hot reload/restart as needed

4. **Automatic Fix Application**
   - Apply fixes silently
   - Hot restart automatically
   - Monitor logs for fix confirmation

## Step-by-Step Execution

### Step 1: Setup & Launch
```bash
# Detect available devices
flutter devices

# Launch app with verbose logging
flutter run -d {device-id} --verbose

# Begin log monitoring (parallel process)
```

### Step 2: Interactive Monitoring Interface
```
🚀 APP RUNTIME MONITOR ACTIVE
============================
📱 Device: {device_name}
🔍 Monitoring: Errors & Exceptions
⌨️ Commands:
   - Type issue description and press Enter to report
   - Type 'status' to see current issues
   - Type 'quit' to end session

👀 Watching for runtime issues...
```

### Step 3: Issue Detection & Response

#### Automatic Detection Example:
```
❌ EXCEPTION DETECTED:
Type: RenderFlex overflow
Location: HomeScreen (line 45)
Widget: Row containing quiz cards

🔍 Analyzing issue...
🤖 Assigning to ui-designer agent...
🔧 Applying fix...
♻️ Hot restarting...
✅ Issue resolved!
```

#### Log Detection Example:
```
❌ ERROR in logs: Button tap handler null exception

🔍 Detecting issue context...
🤖 Assigning to flutter-architect agent...
🔧 Implementing fix...
♻️ Hot restarting automatically...
✅ Fix applied!
```

### Step 4: Agent Invocation

For each detected/reported issue:

```
Task(
  description="Fix runtime issue",
  prompt="Fix the runtime issue DIRECTLY without creating documentation:
  
  **REQUIREMENTS**:
  - Use ONLY free tier services (NO paid APIs)
  - Follow UI guidelines from docs/ui_guideline.md
  - Apply fix immediately to code
  - NO documentation or ticket creation
  
  Issue Type: {issue_type}
  Description: {issue_description}
  Stack Trace: {stack_trace}
  Context Logs: {recent_logs}
  Device Info: {device_info}
  
  Analyze the issue, implement a fix, and document your changes.
  Focus on: {specific_focus_area}
  
  Create/update: docs/runtime-issues/{issue_id}.md",
  subagent_type="{appropriate_agent}"
)
```

### Step 5: Automatic Fix & Restart Loop

```
🔧 Fix Attempt 1/5: Implementing solution...
✅ Fix applied to code!
♻️ Hot restarting automatically...
👀 Monitoring logs for issue recurrence...
```

If issue persists in logs:
- Invoke agent for next attempt
- Auto hot restart after each fix
- Repeat until resolved or max attempts

### Step 6: Session Summary

```
📊 RUNTIME MONITORING SESSION SUMMARY
====================================

⏱️ Session Duration: 15 minutes
📱 Device: Pixel 6 emulator

🔍 Issues Detected: 4
  - ✅ RenderFlex overflow (fixed in 2 attempts)
  - ✅ Firebase permission error (fixed in 1 attempt)
  - ✅ Navigation stack issue (fixed in 3 attempts)
  - ❌ Quiz timer display bug (unresolved after 5 attempts)

👤 User Reports: 2
  - ✅ Button tap issue (fixed in 1 attempt)
  - ✅ Color theme inconsistency (fixed in 2 attempts)

🔧 Fixes Applied:
  - RenderFlex overflow → Fixed with Flexible widget
  - Firebase permission → Added missing rules
  - Navigation stack → Corrected route handling
  - Timer display → Fixed state update
  - Button tap → Added null check
  - Theme colors → Updated to match guidelines

🎯 Success Rate: 5/6 issues resolved (83%)
```

## Agent Assignment Logic

### Error Type to Agent Mapping

**CRITICAL**: ALWAYS use specialized agents - NEVER attempt fixes directly!

| Error Pattern | Primary Agent | Secondary Agent | Mandatory Guidelines |
| **RenderFlex, Overflow, Layout** | `ui-designer` | `flutter-architect` | Use approved colors/spacing |
| **Firebase, Firestore, Auth** | `firebase-specialist` | `flutter-architect` | Free tier only |
| **Navigation, Route, GoRouter** | `flutter-architect` | - | Clean Architecture |
| **Performance, Memory, Lag** | `performance-optimizer` | `flutter-architect` | <3s startup, <200ms updates |
| **State Management, Riverpod** | `flutter-architect` | - | Follow MVVM pattern |
| **Widget Tree, BuildContext** | `flutter-architect` | `ui-designer` | Use centralized components |
| **Network, API, Connectivity** | `firebase-specialist` | `flutter-architect` | HTTPS only, no paid APIs |
| **Animation, Transition** | `ui-designer` | `performance-optimizer` | Follow animation standards |

### User Report Keywords

| Keywords | Likely Issue | Agent |
|----------|-------------|-------|
| "slow", "lag", "freeze" | Performance | `performance-optimizer` |
| "crash", "close", "exit" | Critical error | `test-failure-analyzer` → appropriate specialist |
| "button", "tap", "click" | UI interaction | `ui-designer` |
| "login", "auth", "user" | Authentication | `firebase-specialist` |
| "color", "theme", "style" | Visual design | `ui-designer` |
| "data", "load", "save" | Data management | `firebase-specialist` |

## Interactive User Experience

### Issue Reporting Flow
```
👤 User Input: "The home screen takes too long to load quiz data"

🤖 Assistant: 
   📝 Issue recorded: Slow quiz data loading
   🔍 Analyzing performance metrics...
   📊 Found: Firestore query taking 3.2s
   🚀 Initiating performance optimization...
   
   [Agent works on optimization]
   
   ♻️ Applying optimized query with indexing...
   ✅ Changes applied via hot reload!
   
   ❓ Please check the home screen now. Is the loading time improved? (yes/no/describe):
```

### Continuous Monitoring
```
While user interacts with app:

[Background monitoring active]
↓
[User navigates to Quiz Creation]
↓
❌ EXCEPTION: Null check operator on null value
   at QuizCreationScreen.build (line 67)
↓
🤖 Auto-fixing null safety issue...
↓
♻️ Hot reload successful!
↓
✅ Issue resolved automatically - Quiz Creation screen now stable
```

## Hot Reload vs Full Restart

### Hot Reload (Preferred):
- UI changes
- Business logic updates
- State management fixes
- Style/theme changes

### Full Restart Required:
- Route configuration changes
- Main app initialization
- Plugin updates
- Major architectural changes

Command automatically determines reload type based on changes made.

## Console Output Only

All progress shown in terminal - no documentation files created.

## Success Criteria

- ✅ App runs continuously with real-time monitoring
- ✅ All exceptions/errors are automatically detected
- ✅ User can report issues interactively
- ✅ Appropriate agents are assigned based on issue type
- ✅ **Platform Verification**: ALL platforms build after fixes
- ✅ **UI Compliance**: All fixes follow approved design system
- ✅ **Free Services**: NO paid APIs or services used
- ✅ Fixes are applied via hot reload when possible
- ✅ User verification is requested after each fix
- ✅ **Direct Fixes**: Apply fixes immediately without documentation
- ✅ **Auto Hot Restart**: Restart automatically after fixes
- ✅ Session summary provides actionable insights

## Agent Handoff Protocol

**MANDATORY**: Each agent MUST:
1. Analyze the error directly from logs
2. Apply fix immediately to code
3. Follow UI guidelines for any visual fixes
4. Use only free tier services
5. NO documentation creation
6. Focus on fixing the issue quickly

## Integration with Development Workflow

1. **Pre-Release Testing**: Run before deployments to catch runtime issues
2. **Feature Development**: Monitor while testing new features
3. **User Testing**: Have testers use this during UAT sessions
4. **Production Debugging**: Reproduce and fix reported production issues

## Quality Gates & Validation

**MANDATORY Before Session End**:
```bash
# Platform verification
flutter analyze                    # <50 issues required
flutter build web --release       # Must succeed
flutter build apk --release       # Must succeed

# Documentation verification
ls docs/runtime-issues/           # All issues documented
grep -r "Resolved: Yes" docs/runtime-issues/  # Resolution status
```

## Related Documentation

**Cross-Referenced in CLAUDE.md**:
- **CLAUDE.md** - Master project documentation
- **docs/ui_guideline.md** - UI/UX design system
- **docs/github_instruction.md** - Commit standards
- **.claude/agents/** - Specialized agent roles
- **.claude/commands/implement-issue.md** - Issue implementation workflow

This command creates a powerful feedback loop between runtime behavior, automated fixes, and user verification while maintaining strict project standards!