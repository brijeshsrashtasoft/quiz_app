# Visual E2E Test Runner with Auto-Resolution

This command runs visual integration tests on your device/emulator and automatically resolves any failures through specialized agents.

## Command Usage

```
/project:run-visual-e2e-tests [test-file] [--platform=android|ios] [--device=device-id] [--max-attempts=5]
```

## Parameters

- `test-file` (optional): Specific test file to run (default: all integration tests)
- `--platform` (optional): Target platform (default: android)
- `--device` (optional): Specific device ID (default: auto-detect)
- `--max-attempts` (optional): Maximum resolution attempts per test (default: 5)

## Examples

```bash
# Run all visual E2E tests with auto-resolution
/project:run-visual-e2e-tests

# Run specific test file
/project:run-visual-e2e-tests simple_visual_test.dart

# Run on iOS device
/project:run-visual-e2e-tests --platform=ios

# Run with custom device and max attempts
/project:run-visual-e2e-tests --device=emulator-5554 --max-attempts=3
```

## Process Flow

### Phase 1: Test Execution
1. **Device Detection**: Automatically detect and select target device
2. **Visual Launch**: Launch app visually on device screen
3. **Test Execution**: Run integration tests with visual feedback
4. **Failure Detection**: Monitor for any test failures or UI issues

### Phase 2: Automatic Failure Resolution (if failures detected)
1. **Failure Analysis**: Use `test-failure-analyzer` agent to document issues
2. **Agent Assignment**: Delegate to appropriate specialist agent
3. **Resolution Implementation**: Apply fixes and verify changes
4. **Re-test Cycle**: Re-run tests until all pass or max attempts reached

### Phase 3: Completion & Reporting
1. **Final Status**: Report overall test results
2. **Documentation**: Update all failure reports with final status
3. **Summary**: Provide comprehensive test execution summary

---

## Implementation

You are the **Visual E2E Test Orchestrator** responsible for:

1. **Test Environment Setup**
   - Detect available devices and select appropriate target
   - Ensure device is ready for visual testing
   - Verify test environment prerequisites

2. **Visual Test Execution**
   - Launch integration tests on physical device/emulator
   - Monitor test execution and capture any failures
   - Provide real-time feedback about what's happening on screen

3. **Automatic Failure Resolution**
   - For ANY test failure, immediately invoke `test-failure-analyzer` agent
   - Coordinate with specialized resolver agents based on failure type
   - Implement iterative resolution until tests pass or max attempts reached

4. **Progress Reporting**
   - Keep user informed about test progress and resolution attempts
   - Show visual confirmation of what's happening on device
   - Provide detailed summary of all actions taken

## Step-by-Step Execution

### Step 1: Environment Setup
```bash
# Detect devices
flutter devices

# Verify integration test setup
flutter analyze integration_test/

# Check prerequisites
```

### Step 2: Launch Visual Tests
```bash
# Based on parameters, run appropriate test command:
flutter test integration_test/{test-file} -d {device-id} --verbose

# If no specific test file, run all:
flutter test integration_test/ -d {device-id} --verbose
```

### Step 3: Monitor and Handle Failures

For each test failure detected:

1. **Immediate Analysis**
   ```
   Task(
     description="Analyze test failure",
     prompt="Analyze this test failure and create comprehensive documentation:
     
     Test Output: {failure_output}
     Test File: {test_file}
     Device: {device_info}
     Platform: {platform}
     
     Create detailed failure report in docs/testcase/{test_name}.md
     Include root cause analysis and assign appropriate resolver agent.",
     subagent_type="test-failure-analyzer"
   )
   ```

2. **Automatic Resolution**
   ```
   Task(
     description="Resolve test failure",
     prompt="Fix the test failure documented in docs/testcase/{test_name}.md
     
     Failure Report: {failure_doc_path}
     Resolution Attempt: {attempt_number}
     Max Attempts: {max_attempts}
     
     Implement the fix and update the documentation with resolution details.",
     subagent_type="test-resolver"
   )
   ```

3. **Re-test Verification**
   ```bash
   # Re-run the specific failed test
   flutter test {failed_test_file} -d {device-id}
   ```

4. **Iterate Until Success**
   - If test still fails and attempts < max_attempts: repeat resolution
   - If test passes: mark as resolved and continue
   - If max attempts reached: document as unresolved and continue

### Step 4: Final Reporting

```
VISUAL E2E TEST EXECUTION SUMMARY
================================

🎯 Tests Executed: {total_tests}
✅ Tests Passed: {passed_count}
❌ Tests Failed: {failed_count}
🔄 Tests Resolved: {resolved_count}
⚠️ Tests Unresolved: {unresolved_count}

📱 Platform: {platform}
📱 Device: {device_info}

🔍 Failure Details:
{detailed_failure_summary}

📁 Documentation Created:
{list_of_created_docs}

🎉 Overall Result: {PASS|FAIL|PARTIAL}
```

## Agent Coordination

### Test Failure Types & Agent Assignment

| Failure Category | Primary Agent | Typical Issues |
|------------------|---------------|----------------|
| **Splash Screen Issues** | `ui-designer` | Loading states, navigation timing, visual elements |
| **Home Screen Issues** | `ui-designer` + `flutter-architect` | Layout, data loading, user interactions |
| **Authentication Flow** | `firebase-specialist` | Auth state, login/logout, session management |
| **Navigation Issues** | `flutter-architect` | Route transitions, deep links, navigation stack |
| **Performance Issues** | `performance-optimizer` | Timeouts, memory leaks, slow rendering |
| **Widget Test Issues** | `testing-specialist` | Test infrastructure, finders, assertions |

### Communication Protocol

Each agent receives:
- **Complete failure context** from `docs/testcase/{test_name}.md`
- **Current attempt number** and remaining attempts
- **Device and platform information**
- **Clear success criteria** for resolution

## User Experience

### What You'll See

1. **Initial Launch**
   ```
   🎬 Starting Visual E2E Tests
   📱 Launching on device: {device_name}
   🧪 Running tests: {test_list}
   ```

2. **During Test Execution**
   ```
   ▶️ Running: splash_screen_test.dart
   📱 Watch your device - you should see splash screen loading...
   ✅ Test passed: splash screen displays correctly
   
   ▶️ Running: home_screen_test.dart
   📱 Watch your device - navigating to home screen...
   ❌ Test failed: Home screen layout overflow
   ```

3. **During Auto-Resolution**
   ```
   🔍 Analyzing failure: home_screen_test.dart
   📝 Created report: docs/testcase/home_screen_layout_overflow.md
   🛠️ Assigning to ui-designer agent for resolution...
   
   🔧 Attempt 1: Fixing layout overflow issues
   📱 Re-testing on device...
   ✅ Test now passes!
   ```

4. **Final Summary**
   ```
   🏁 All tests completed successfully!
   📊 Results: 8/8 tests passing
   🔧 Auto-resolved: 2 issues
   📁 Documentation: docs/testcase/ (updated)
   ```

## Integration with Whole App

As you integrate more features:

1. **Add New Test Files**: Place in `integration_test/features/{feature_name}/`
2. **Update Test Discovery**: Command automatically finds and runs all integration tests
3. **Specialized Agents**: Each agent handles their domain expertise (auth, quiz creation, game sessions, etc.)
4. **Incremental Testing**: Run specific features or full app testing
5. **Regression Prevention**: Automatic detection of new failures in existing features

## Success Criteria

- ✅ All integration tests run visually on device
- ✅ Any test failures are automatically analyzed and documented
- ✅ Appropriate specialist agents are assigned based on failure type
- ✅ Iterative resolution continues until tests pass or max attempts reached
- ✅ Comprehensive documentation is maintained for all issues
- ✅ User gets clear visual feedback throughout the process
- ✅ Final summary provides complete test execution overview

This command will scale with your app as you add authentication, quiz creation, game sessions, leaderboards, and all other features!