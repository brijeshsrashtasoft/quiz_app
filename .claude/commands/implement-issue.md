Please implement GitHub issue: $ARGUMENTS

**🔐 GLOBAL PROJECT PERMISSIONS REQUEST**

**CRITICAL**: This command requires full project file access permissions for all agents to work efficiently.

**REQUEST**: Please grant global file permissions (.*) for this project directory to avoid repeated permission prompts during multi-agent operations.

This includes permission to:
- Read all project files (lib/, test/, docs/, scripts/, .claude/, etc.)
- Write/edit all project files across all directories
- Execute shell commands (git, flutter, dart, etc.)
- Create new files and directories as needed

**Reason**: Multiple specialized agents will work in parallel and need seamless access to modify files across the entire project structure without interrupting the workflow.

---

**⚠️ CRITICAL BRANCH DISCIPLINE ⚠️**
- **MANDATORY**: All work MUST be done from branches created from `development` branch
- **NEVER** analyze, checkout, or work on any branch other than your feature branch
- **IGNORE** all other branches (main, other features) - focus ONLY on `development` → feature branch workflow

**Command Documentation**: This command provides intelligent agent assignment and coordinated implementation of GitHub issues with strict PR conflict management and comprehensive test validation.

## 📋 UNIFIED TICKET TRACKING SYSTEM

**NEW REQUIREMENT**: ONE ticket documentation file per issue using branch name format. ALL agents work in the SAME file with nested checkbox structure.

**Ticket File Name Format:**
```
docs/tickets/{branch-name}.md
```

**Example**: For issue #15 on branch `feature/issue-15-quiz-creation`:
```
docs/tickets/feature-issue-15-quiz-creation.md
```

**MANDATORY Nested Checkbox Structure:**
```markdown
# Issue #$ARGUMENTS - {Issue Title}

## Implementation Progress

### 🔥 Main Implementation Tasks
- [ ] **Core Feature Implementation**
  - [ ] Architecture setup (flutter-architect)
  - [ ] Firebase integration (firebase-specialist) 
  - [ ] UI components (ui-designer)
  - [ ] Testing framework (testing-specialist)
- [ ] **Test Coverage & Validation** 
  - [ ] Unit tests passing (testing-specialist)
  - [ ] Widget tests passing (testing-specialist)
  - [ ] Integration tests passing (testing-specialist)
  - [ ] E2E test scenarios complete (testing-specialist)
- [ ] **Platform Verification**
  - [ ] Web build successful
  - [ ] Android build successful  
  - [ ] iOS build successful
  - [ ] All platforms tested and verified
- [ ] **Quality Assurance**
  - [ ] Code review completed (code-reviewer)
  - [ ] Performance benchmarks met (performance-optimizer)
  - [ ] Documentation updated (all agents)
  - [ ] Cross-references updated (all agents)

### 📊 Agent-Specific Progress

#### flutter-architect Agent
- [ ] Clean Architecture implementation
  - [ ] Domain layer entities
  - [ ] Repository contracts
  - [ ] Use cases implementation
  - [ ] Data layer integration
- [ ] Platform integration verified
- [ ] Documentation updates completed

#### firebase-specialist Agent  
- [ ] Firebase service setup
  - [ ] Authentication configuration
  - [ ] Firestore database design
  - [ ] Security rules implementation
  - [ ] Real-time listeners setup
- [ ] Free tier compliance verified
- [ ] Integration testing completed

#### ui-designer Agent
- [ ] UI component implementation
  - [ ] Kahoot-style design compliance
  - [ ] Responsive layouts
  - [ ] Animation implementations
  - [ ] Accessibility features
- [ ] Design system updates
- [ ] Cross-platform compatibility verified

#### testing-specialist Agent
- [ ] Comprehensive test suite
  - [ ] Unit test coverage >80%
  - [ ] Widget test implementations  
  - [ ] Integration test scenarios
  - [ ] Performance test benchmarks
- [ ] Test framework enhancements
- [ ] CI/CD integration verified

#### code-reviewer Agent
- [ ] Architecture review completed
- [ ] Code quality validation
- [ ] Security audit performed
- [ ] Performance analysis completed
- [ ] Documentation review finished

## Test Execution Status
- [ ] **ALL tests passing**: Required before PR creation
- [ ] **Coverage threshold met**: >80% coverage achieved
- [ ] **Performance benchmarks**: All thresholds satisfied
- [ ] **Platform compatibility**: All builds successful

## Files Modified
[Updated by each agent as they complete work]

## Agent Handoff Log
[Each agent documents their completion and handoff notes]

## Status Summary
Current: [pending/in_progress/testing/review/completed]
Blockers: [None/specific issues]
Next Agent: [Who should work next]

## Last Update
Agent: [agent-name]
Time: [timestamp]
Action: [what was completed]
```

## 🚨 CRITICAL PR CONFLICT PREVENTION WORKFLOW

**MANDATORY REQUIREMENT**: This workflow enforces sequential PR management to prevent merge conflicts when multiple agents work on separate branches.

**Sequential Development Process:**
1. **Check for open PRs** → If ANY exist, STOP and alert user to merge first
2. **Wait for merge completion** → User must merge existing PR before proceeding  
3. **Pull latest changes** → Get merged changes into development branch
4. **Create new branch** → Only after development branch is up-to-date
5. **Implement with agents** → Use parallel agents within single branch
6. **Pre-PR conflict check** → Verify no new PRs appeared during development
7. **Resolve conflicts if needed** → Merge with development and resolve manually
8. **Create PR** → Only when no other open PRs exist

**Why This Workflow**:
- **Prevents complex merge conflicts** between multiple agent branches
- **Ensures linear integration** of features into development branch  
- **Avoids blocking situations** where multiple PRs conflict with each other
- **Maintains code quality** by resolving conflicts before PR creation

**Related Documentation** (Cross-referenced in CLAUDE.md):
- **CLAUDE.md** - Master project documentation and agent coordination protocols
- **DEVELOPMENT_GUIDE.md** - Complete development workflow and quality standards
- **docs/github_instruction.md** - GitHub workflow standards and commit message formats
- **.claude/agents/** - Individual sub-agent roles and responsibilities
- **.claude/agents/pr-review-agent.md** - Pull request review and merge authority
- **scripts/develop-feature.sh** - Automated branch creation for issues

## 🧪 MANDATORY TEST VALIDATION REQUIREMENTS

**NEW CRITICAL REQUIREMENT**: All test cases MUST be updated and passing before PR creation.

**Test Categories That MUST Pass:**
1. **Unit Tests**: All business logic and use cases
2. **Widget Tests**: All UI components and interactions
3. **Integration Tests**: Complete feature workflows
4. **E2E Tests**: End-to-end user scenarios
5. **Performance Tests**: All benchmarks and thresholds

**Test Execution Commands (MANDATORY before PR):**
```bash
# STEP 1: Run all test suites
flutter test                                    # All tests must pass
flutter test --coverage                         # Coverage >80% required
flutter test test/integration/                  # Integration tests
flutter test test/e2e/                         # E2E scenarios

# STEP 2: Verify test updates are current
dart run build_runner build --delete-conflicting-outputs  # Update mocks
flutter analyze                                 # No critical issues
dart format --set-exit-if-changed .           # Code formatting

# STEP 3: Platform-specific test validation
flutter test test/unit/ --platform vm          # Unit tests on VM
flutter test test/widget/ --platform vm        # Widget tests  
flutter test test/integration/ --platform vm   # Integration tests
```

**Test Documentation Updates Required:**
- Update test documentation in `test/README.md`
- Add new test scenarios to relevant test suites
- Update test helper utilities if needed
- Verify test mocks are current and accurate

## STEP 0: MANDATORY BRANCH VERIFICATION & CONTINUATION CHECK

**CRITICAL**: Before any work begins, verify current branch status and check for existing work:

```bash
# Get current branch and issue-specific branch names
current_branch=$(git branch --show-current)
target_branch="feature/issue-$ARGUMENTS"
issue_branch_pattern="^feature/issue-$ARGUMENTS"

# Create unified ticket file name from branch
if [[ "$current_branch" =~ $issue_branch_pattern ]]; then
    TICKET_FILE="docs/tickets/${current_branch}.md"
else
    TICKET_FILE="docs/tickets/feature-issue-$ARGUMENTS-[description].md"
fi

# CASE 1: Already on the correct issue branch - CONTINUE EXISTING WORK
if [[ "$current_branch" =~ $issue_branch_pattern ]]; then
    echo "✅ CONTINUATION MODE: Already on issue #$ARGUMENTS branch ($current_branch)"
    echo "🔍 Checking existing work status..."
    
    # Check for existing ticket file
    if [[ -f "$TICKET_FILE" ]]; then
        echo "📋 Found existing ticket file: $TICKET_FILE"
        echo "🔄 CONTINUING from existing progress..."
        cat "$TICKET_FILE"
    else
        echo "⚠️ NO TICKET FILE FOUND - will create new one"
    fi
    
    # Check git status for uncommitted changes
    if [[ -n $(git status --porcelain) ]]; then
        echo "📝 UNCOMMITTED CHANGES DETECTED:"
        git status --short
        echo ""
        echo "🔄 CONTINUING from existing progress..."
    else
        echo "✅ Working directory clean - checking previous commits..."
        git log --oneline -5 --grep="issue.*$ARGUMENTS" --grep="closes.*#$ARGUMENTS" --grep="#$ARGUMENTS" -i
        echo ""
        echo "🔄 CONTINUING implementation from current progress..."
    fi
    
    # Analyze current implementation status
    echo "📊 CURRENT IMPLEMENTATION STATUS ANALYSIS:"
    echo "- Branch: $current_branch"
    echo "- Files changed in this branch:"
    git diff --name-only $(git merge-base HEAD development)..HEAD | head -10
    echo ""
    
    # Check test status
    echo "🧪 CHECKING TEST STATUS:"
    if flutter test --dry-run 2>/dev/null; then
        echo "✅ Test framework operational"
        echo "🔍 Running quick test validation..."
        flutter test --reporter compact | head -10
    else
        echo "⚠️ Test issues detected - will need to fix during implementation"
    fi
    
    echo "⏭️ SKIPPING branch creation - continuing with existing work..."
    
# CASE 2: On development branch - CREATE NEW BRANCH
elif [[ "$current_branch" == "development" ]]; then
    echo "✅ On development branch - proceeding with normal workflow"
    
# CASE 3: On wrong branch - SWITCH TO DEVELOPMENT  
else
    echo "❌ ERROR: Not on development or correct feature branch ($current_branch)!"
    echo "🔧 Switching to development branch..."
    git checkout development
    
    # Verify switch was successful
    if [[ $(git branch --show-current) != "development" ]]; then
        echo "🚨 FAILED to switch to development branch!"
        echo "Please manually switch to development branch and re-run command"
        exit 1
    fi
fi
```

## STEP 1: ISSUE ANALYSIS & AGENT ASSIGNMENT

First, analyze the issue and assign to appropriate specialized agents:

```bash
gh issue view $ARGUMENTS
```

Based on issue content, determine required agents:

**Agent Assignment Logic** (see CLAUDE.md for detailed coordination protocols):
- **Setup/Infrastructure** → flutter-architect (primary) + firebase-specialist (if Firebase)
- **Authentication** → firebase-specialist (primary) + flutter-architect + ui-designer  
- **UI/Components** → ui-designer (primary) + flutter-architect
- **Real-time Features** → firebase-specialist (primary) + performance-optimizer
- **Testing** → testing-specialist (primary) + flutter-architect
- **Performance** → performance-optimizer (primary) + flutter-architect

**Agent Documentation**: Each agent's specific role is documented in `.claude/agents/[agent-name].md`

## STEP 2: MANDATORY PR CONFLICT CHECK

**🚨 CRITICAL: Before creating ANY new branch or starting work, check for existing open PRs**

```bash
# MANDATORY: Check for open PRs first
gh pr list --state open

# If ANY PR is open, STOP and notify user
echo "⚠️  CONFLICT PREVENTION: Open PR detected!"
echo "Please merge existing PR first before starting new work."
echo "Current agent cannot proceed until conflicts are resolved."
```

**If open PRs exist:**
1. **STOP** - Do not create new branch
2. **Alert User**: "🚨 Open PR detected! Please merge PR #[NUMBER] first to prevent conflicts"
3. **Wait for Resolution**: User must merge open PR before proceeding
4. **Pull Latest**: Only after PR is merged, pull latest changes

## STEP 3: UNIFIED TICKET FILE CREATION

**MANDATORY**: Create or update the single ticket tracking file for this issue.

```bash
# Create ticket file based on branch name
current_branch=$(git branch --show-current)
TICKET_FILE="docs/tickets/${current_branch}.md"

# Create tickets directory if it doesn't exist
mkdir -p docs/tickets

# Create or update ticket file with unified structure
if [[ ! -f "$TICKET_FILE" ]]; then
    echo "📋 Creating new unified ticket file: $TICKET_FILE"
    
    # Get issue details for ticket creation
    ISSUE_TITLE=$(gh issue view $ARGUMENTS --json title -q '.title')
    
    # Create unified ticket file with nested structure
    cat > "$TICKET_FILE" << EOF
# Issue #$ARGUMENTS - ${ISSUE_TITLE}

## Implementation Progress

### 🔥 Main Implementation Tasks
- [ ] **Core Feature Implementation**
  - [ ] Architecture setup (flutter-architect)
  - [ ] Firebase integration (firebase-specialist) 
  - [ ] UI components (ui-designer)
  - [ ] Testing framework (testing-specialist)
- [ ] **Test Coverage & Validation** 
  - [ ] Unit tests passing (testing-specialist)
  - [ ] Widget tests passing (testing-specialist)
  - [ ] Integration tests passing (testing-specialist)
  - [ ] E2E test scenarios complete (testing-specialist)
- [ ] **Platform Verification**
  - [ ] Web build successful
  - [ ] Android build successful  
  - [ ] iOS build successful
  - [ ] All platforms tested and verified
- [ ] **Quality Assurance**
  - [ ] Code review completed (code-reviewer)
  - [ ] Performance benchmarks met (performance-optimizer)
  - [ ] Documentation updated (all agents)
  - [ ] Cross-references updated (all agents)

### 📊 Agent-Specific Progress

#### flutter-architect Agent
- [ ] Clean Architecture implementation
  - [ ] Domain layer entities
  - [ ] Repository contracts
  - [ ] Use cases implementation
  - [ ] Data layer integration
- [ ] Platform integration verified
- [ ] Documentation updates completed

#### firebase-specialist Agent  
- [ ] Firebase service setup
  - [ ] Authentication configuration
  - [ ] Firestore database design
  - [ ] Security rules implementation
  - [ ] Real-time listeners setup
- [ ] Free tier compliance verified
- [ ] Integration testing completed

#### ui-designer Agent
- [ ] UI component implementation
  - [ ] Kahoot-style design compliance
  - [ ] Responsive layouts
  - [ ] Animation implementations
  - [ ] Accessibility features
- [ ] Design system updates
- [ ] Cross-platform compatibility verified

#### testing-specialist Agent
- [ ] Comprehensive test suite
  - [ ] Unit test coverage >80%
  - [ ] Widget test implementations  
  - [ ] Integration test scenarios
  - [ ] Performance test benchmarks
- [ ] Test framework enhancements
- [ ] CI/CD integration verified

#### code-reviewer Agent
- [ ] Architecture review completed
- [ ] Code quality validation
- [ ] Security audit performed
- [ ] Performance analysis completed
- [ ] Documentation review finished

## Test Execution Status
- [ ] **ALL tests passing**: Required before PR creation
- [ ] **Coverage threshold met**: >80% coverage achieved
- [ ] **Performance benchmarks**: All thresholds satisfied
- [ ] **Platform compatibility**: All builds successful

## Files Modified
[Updated by each agent as they complete work]

## Agent Handoff Log
[Each agent documents their completion and handoff notes]

## Status Summary
Current: pending
Blockers: None
Next Agent: flutter-architect (based on issue analysis)

## Last Update
Agent: implement-issue command
Time: $(date)
Action: Ticket file created and issue analysis completed
EOF

    echo "✅ Unified ticket file created: $TICKET_FILE"
else
    echo "📋 Found existing unified ticket file: $TICKET_FILE"
    echo "🔄 Will update progress as agents complete work"
fi
```

## STEP 4: SEQUENTIAL DEVELOPMENT WORKFLOW

**Only proceed if NO open PRs exist:**

**🚨 BRANCH CREATION RULES (MANDATORY):**
- **ALWAYS** create feature branches from `development` branch ONLY  
- **NEVER** create branches from `main` or any other feature branch
- **DO NOT** analyze or reference code from branches other than your assigned feature branch

```bash
# Get current branch status again after PR checks
current_branch=$(git branch --show-current)
issue_branch_pattern="^feature/issue-$ARGUMENTS"

# CONTINUATION MODE: Skip branch creation if already on correct branch  
if [[ "$current_branch" =~ $issue_branch_pattern ]]; then
    echo "🔄 CONTINUATION MODE: Already on correct branch ($current_branch)"  
    echo "⏭️ Skipping branch creation - proceeding with existing work"
    
    # Ensure we have latest changes from development for context
    echo "🔄 Fetching latest development changes for context..."
    git fetch origin development
    
    # Show current branch status  
    git log --oneline -1 --decorate
    echo "✅ Continuing on existing feature branch"
    
# NORMAL MODE: Create new branch from development
else
    echo "🆕 NORMAL MODE: Creating new feature branch"
    
    # ONLY if no open PRs exist and not already on correct branch
    git checkout development
    git pull origin development  # Get latest merged changes
    
    # Create branch with descriptive name
    ISSUE_TITLE=$(gh issue view $ARGUMENTS --json title -q '.title' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g' | cut -c1-30)
    git checkout -b feature/issue-$ARGUMENTS-${ISSUE_TITLE}

    # Update ticket file name with actual branch
    NEW_TICKET_FILE="docs/tickets/$(git branch --show-current).md"
    if [[ -f "$TICKET_FILE" && "$TICKET_FILE" != "$NEW_TICKET_FILE" ]]; then
        mv "$TICKET_FILE" "$NEW_TICKET_FILE"
        TICKET_FILE="$NEW_TICKET_FILE"
        echo "📋 Ticket file renamed to match branch: $TICKET_FILE"
    fi

    # Verify correct branch creation
    git log --oneline -1 --decorate
    echo "✅ Feature branch created from development branch"
fi
```

## STEP 5: PARALLEL AGENT COORDINATION (MANDATORY)

**CRITICAL**: ALWAYS use multiple sub-agents in parallel for maximum speed. Never work directly - ALWAYS delegate to specialized agents.

**ALL AGENTS MUST**:
1. **Use Unified Ticket File**: Update the SAME ticket file with their progress
2. **Update Nested Checkboxes**: Mark their specific tasks as completed
3. **Test Validation**: Ensure their code passes all relevant tests
4. **Cross-Reference Updates**: Update documentation references as required

**CONTEXT-AWARE AGENT INSTRUCTIONS:**

**For CONTINUATION MODE (already on correct branch with existing work):**
"Continue implementation of issue #$ARGUMENTS using multiple specialized agents in parallel. Current branch analysis shows existing progress - agents should:

1. **Read Unified Ticket File**: Check docs/tickets/$(git branch --show-current).md for current progress
2. **Continue TDD Approach**: Build upon existing tests or implement missing test coverage
3. **Update Ticket Progress**: Mark completed tasks in the nested checkbox structure
4. **Maintain Test Currency**: Ensure all tests pass and are up-to-date with changes

**For NORMAL MODE (new implementation):**
"Launch multiple specialized agents simultaneously using separate Task tool calls in a single message for issue #$ARGUMENTS:

**⚠️ AGENT UNIFIED TICKET DISCIPLINE ⚠️**
Each agent MUST:
- Work ONLY on the current feature/issue-$ARGUMENTS branch  
- Update the UNIFIED ticket file: docs/tickets/$(git branch --show-current).md
- Mark their nested checkbox tasks as completed
- Ensure ALL tests pass before marking tasks complete
- Update cross-references in documentation files as required
- NEVER create separate ticket files - use the ONE unified file

**For Setup/Infrastructure Issues**: Launch ALL in parallel:
- flutter-architect subagent: Clean Architecture implementation
- firebase-specialist subagent: Firebase integration and configuration
- testing-specialist subagent: Comprehensive test implementation

**For Authentication Issues**: Launch ALL in parallel:
- firebase-specialist subagent: Firebase Auth implementation
- flutter-architect subagent: Clean Architecture integration  
- ui-designer subagent: Authentication UI components
- testing-specialist subagent: Authentication test coverage

**For UI/Component Issues**: Launch ALL in parallel:
- ui-designer subagent: UI component implementation
- flutter-architect subagent: Architecture integration
- testing-specialist subagent: Widget and integration tests

**For Real-time Features**: Launch ALL in parallel:
- firebase-specialist subagent: Firestore real-time implementation
- performance-optimizer subagent: Performance optimization
- flutter-architect subagent: Architecture integration
- testing-specialist subagent: Real-time test coverage

**EVERY AGENT MUST**:
1. **Unified Ticket Updates**: Update docs/tickets/$(git branch --show-current).md with progress
2. **Test Validation**: ALL tests must pass before marking tasks complete
3. **Cross-Reference Updates**: Update CLAUDE.md and related files with new references
4. **Platform Verification**: Verify builds work on all platforms
5. **Documentation Updates**: Update relevant documentation files
6. **Quality Standards**: Follow all project standards and patterns"

## STEP 6: MANDATORY TEST VALIDATION & QUALITY ASSURANCE

**CRITICAL**: After ALL parallel agents complete their work, run comprehensive test validation:

**Test Validation Process:**
```bash
# MANDATORY: All tests must pass before PR creation
echo "🧪 RUNNING COMPREHENSIVE TEST VALIDATION..."

# Step 1: Update all generated code
dart run build_runner build --delete-conflicting-outputs
echo "✅ Generated code updated"

# Step 2: Run all test suites
flutter test --reporter compact
if [[ $? -ne 0 ]]; then
    echo "❌ TESTS FAILED: Fix all test failures before proceeding"
    exit 1
fi
echo "✅ All tests passing"

# Step 3: Check test coverage
flutter test --coverage
if [[ -f coverage/lcov.info ]]; then
    # Calculate coverage percentage (simplified)
    COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | tail -1 | cut -d' ' -f4 | cut -d'%' -f1)
    if [[ $(echo "$COVERAGE >= 80" | bc -l) -eq 1 ]]; then
        echo "✅ Test coverage: ${COVERAGE}% (meets >80% requirement)"
    else
        echo "❌ INSUFFICIENT COVERAGE: ${COVERAGE}% (requires >80%)"
        echo "Add more tests before proceeding"
        exit 1
    fi
else
    echo "⚠️ Coverage report not generated - verify test execution"
fi

# Step 4: Platform verification with tests
flutter build web --release
flutter build apk --debug  
flutter build ios --debug --no-codesign

echo "✅ All platform builds successful"

# Step 5: Update ticket file with test validation
TICKET_FILE="docs/tickets/$(git branch --show-current).md"
sed -i '' 's/- \[ \] \*\*ALL tests passing\*\*/- [x] **ALL tests passing**/' "$TICKET_FILE"
sed -i '' 's/- \[ \] \*\*Coverage threshold met\*\*/- [x] **Coverage threshold met**/' "$TICKET_FILE"
sed -i '' 's/- \[ \] \*\*Platform compatibility\*\*/- [x] **Platform compatibility**/' "$TICKET_FILE"

echo "✅ Test validation completed and ticket updated"
```

## STEP 7: CODE REVIEW BY PR-REVIEW-AGENT

**MANDATORY**: Launch the pr-review-agent for final validation before PR creation:

```bash
# Launch PR review agent for final validation
echo "🔍 LAUNCHING PR REVIEW AGENT FOR FINAL VALIDATION..."
```

"Use the pr-review-agent subagent to perform comprehensive pre-PR review for issue #$ARGUMENTS:

**Review Requirements**:
1. **Ticket Validation**: Verify all nested checkboxes are completed in unified ticket file
2. **Code Quality**: Ensure Clean Architecture and coding standards compliance
3. **Test Validation**: Confirm >80% coverage and all tests passing
4. **Platform Verification**: Validate all platform builds successful
5. **Documentation Updates**: Verify cross-references updated in all relevant files
6. **Security Audit**: Check for security best practices implementation

**PR Review Agent Authority**:
- ONLY pr-review-agent can approve PR creation
- ONLY pr-review-agent can merge PRs after creation
- If changes required, original implementing agents must complete them

The pr-review-agent will provide final approval or required changes list."

## STEP 8: PR CREATION & ISSUE COMPLETION

**CRITICAL**: This step is MANDATORY for every issue implementation and can ONLY be executed after pr-review-agent approval.

**Quality Validation & Platform Verification:**
```bash
# MANDATORY: Final verification before PR creation
./scripts/quality-check.sh

# Commit with standards from docs/github_instruction.md
git add .
git commit -m "type(scope): description - closes #$ARGUMENTS

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**MANDATORY Pull Request Creation:**
```bash
# FINAL CHECK: Ensure NO open PRs exist before creating new one
OPEN_PRS=$(gh pr list --state open | wc -l)
if [[ $OPEN_PRS -gt 0 ]]; then
    echo "🚨 ABORT: Cannot create PR while others are open!"
    echo "Existing open PRs must be merged first:"
    gh pr list --state open
    exit 1
fi

# Push feature branch
git push -u origin $(git branch --show-current)

# Create PR targeting development branch with unified ticket reference
gh pr create --base development --title "type(scope): description" --body "$(cat <<EOF
## Summary
- [Brief description of what was implemented]
- [Key architectural decisions or patterns used]
- [Integration points with existing codebase]

## Unified Ticket Reference
**Ticket File**: docs/tickets/$(git branch --show-current).md
- All nested checkboxes completed
- All agent tasks verified
- Test validation completed
- Platform verification successful

## Test Plan
- [x] Unit tests: >80% coverage achieved
- [x] Widget tests: All UI components tested
- [x] Integration tests: Complete workflows validated
- [x] Platform tests: Web, Android, iOS builds successful
- [x] Quality checks: lint, format, analyze passed

## Documentation Updates
- [x] CLAUDE.md cross-references updated
- [x] Agent documentation updated
- [x] Related MD files cross-referenced
- [x] Architecture documentation updated

**⚠️ PR Review Authority**: Only pr-review-agent can merge this PR

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Branch Strategy**: Always target `development` branch for PRs (see parallel development workflow in CLAUDE.md)

**IMPLEMENTATION NOT COMPLETE UNTIL**:
1. ✅ All nested checkboxes completed in unified ticket file
2. ✅ ALL tests passing with >80% coverage
3. ✅ Platform verification passed (all platforms build successfully)
4. ✅ Cross-references updated in all relevant documentation
5. ✅ pr-review-agent approval received
6. ✅ Pull request created targeting `development` branch
7. ✅ Issue commented with implementation summary and PR link

## 📚 MANDATORY CROSS-REFERENCE UPDATES

**CRITICAL**: ALL agents MUST update cross-references when creating or modifying any .md files.

**Files That Must Reference New Documentation:**
1. **CLAUDE.md** - Master documentation index
2. **DOCUMENTATION_INDEX.md** - Complete navigation hub
3. **DEVELOPMENT_GUIDE.md** - Development workflow references
4. **Agent files** - Related agent documentation
5. **README.md** - Project overview updates

**Cross-Reference Update Format:**
```markdown
## Recently Added Documentation
- **docs/tickets/{branch-name}.md** - Unified ticket tracking for issue #{number}
- **{new-file}.md** - Description of new documentation

## Related Documentation
- See {file}.md for {specific topic}
- Reference {file}.md for {related workflow}
```

**Quality Gate**: No work is considered complete until ALL cross-references are updated in relevant files.

## 🔒 PR MERGE AUTHORITY

**NEW CRITICAL REQUIREMENT**: Only the pr-review-agent has authority to merge pull requests.

**PR Merge Workflow**:
1. **PR Creation**: Any agent can create PR after following this workflow
2. **PR Review**: ONLY pr-review-agent reviews and approves/requests changes
3. **Change Requests**: Original implementing agents must complete requested changes
4. **Final Approval**: pr-review-agent provides final approval
5. **PR Merge**: ONLY pr-review-agent can merge the approved PR

**No other agent or process can merge PRs** - this ensures quality and consistency.

## 🆓 FREE SERVICES ONLY POLICY

**MANDATORY**: ALL implementations MUST use ONLY free tier services. NO paid APIs or cloud services allowed.

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

**Implementation Guidelines:**
- Use Firestore for all data storage (free tier limits apply)
- Implement business logic in Flutter app (not Cloud Functions)
- Use GitHub Actions for CI/CD (free tier)
- Host web app on Firebase Hosting (free tier)
- Store media in Firebase Storage (free tier limits)