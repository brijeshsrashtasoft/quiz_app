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

**Command Documentation**: This command provides intelligent agent assignment and coordinated implementation of GitHub issues with strict PR conflict management.

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

**Related Documentation**:
- **CLAUDE.md** - Agent coordination protocols, Clean Architecture patterns, and UI guidelines
- **DEVELOPMENT_GUIDE.md** - Complete development workflow and quality standards
- **docs/github_instaruction.md** - GitHub workflow standards and commit message formats
- **.claude/agents/** - Individual sub-agent roles and responsibilities
- **scripts/develop-feature.sh** - Automated branch creation for issues

**STEP 1: ISSUE ANALYSIS & AGENT ASSIGNMENT**

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

**STEP 2: MANDATORY PR CONFLICT CHECK**

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

**STEP 3: SEQUENTIAL DEVELOPMENT WORKFLOW** 

**Only proceed if NO open PRs exist:**

```bash
# ONLY if no open PRs exist
git checkout development
git pull origin development  # Get latest merged changes
git checkout -b feature/issue-$ARGUMENTS-{short-description}
```

**STEP 4: PARALLEL AGENT COORDINATION (MANDATORY)**

**CRITICAL**: ALWAYS use multiple sub-agents in parallel for maximum speed. Never work directly - ALWAYS delegate to specialized agents.

**Parallel Execution Instructions:**
"Launch multiple specialized agents simultaneously using separate Task tool calls in a single message for issue #$ARGUMENTS:

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
1. **Platform Verification**: Run ./scripts/quality-check.sh after implementation
2. **Parallel Coordination**: Work simultaneously with other assigned agents
3. **Structured Communication**: Use handoff protocol when coordination needed
4. **Quality Standards**: Follow all project standards and documentation"

**STEP 5: MANDATORY FINAL VALIDATION**

**CRITICAL**: After ALL parallel agents complete their work, run final validation:

**Final Validation Process:**
1. **Collect Results**: Gather outputs from all parallel agents
2. **Platform Verification**: Ensure ALL agents verified platforms successfully
3. **Code Review**: Launch code-reviewer subagent to validate complete implementation:
   "Use the code-reviewer subagent to review the complete implementation for issue #$ARGUMENTS"
4. **Integration Check**: Verify all agent contributions work together seamlessly

**🚨 MANDATORY COMPLETION REQUIREMENTS**

**CRITICAL: ALL agents or sub-agents MUST complete 100% of their assigned tasks. NO PARTIAL WORK ALLOWED.**

**Completion Verification Checklist:**
- [ ] ✅ **ALL agent tasks 100% complete** - No pending work from any assigned agent
- [ ] ✅ **Platform verification passed** - All platforms (Web, Android, iOS) build and run successfully  
- [ ] ✅ **Quality metrics achieved** - Tests pass, coverage >80%, no critical errors
- [ ] ✅ **Documentation updated** - All relevant docs updated by each agent
- [ ] ✅ **Custom commands updated** - Any new commands or procedures documented
- [ ] ✅ **Integration validated** - All agent contributions work together seamlessly

**Agent Task Completion Requirements:**
Each assigned agent MUST deliver:
1. **100% Implementation**: Complete all components within their specialization
2. **Comprehensive Testing**: All code covered by appropriate tests (unit/widget/integration)
3. **Platform Compatibility**: Code verified working on all target platforms
4. **Documentation Updates**: Update relevant documentation files
5. **Performance Validation**: Meet all performance requirements in their domain
6. **Integration Points**: Ensure smooth integration with other agents' work

**Verification Commands:**
```bash
# MANDATORY: Verify ALL platforms build successfully
flutter build web --release
flutter build apk --release  
flutter build ios --release --no-codesign

# MANDATORY: Verify ALL tests pass
flutter test --coverage

# MANDATORY: Verify code quality
flutter analyze
dart format --set-exit-if-changed .
```

**NO PULL REQUEST** can be created until ALL completion requirements are met.

**Quality Assurance**: The code-reviewer validates against all standards documented in CLAUDE.md, including:
- Clean Architecture compliance
- UI design system adherence (docs/ui_guideline.md)
- Testing coverage requirements (>80% coverage)
- Performance standards (sub-200ms real-time)
- Security guidelines (Firebase rules, authentication)
- **Platform verification completed by ALL agents**
- **Documentation updates completed by all agents**

**Integration Validation**:
- All platforms build successfully after ALL agent changes
- No conflicts between agent implementations
- Consistent architecture patterns across all agent contributions
- Complete feature functionality with all specializations integrated

**STEP 6: PR CONFLICT RESOLUTION & COMMIT WORKFLOW**

**🚨 CRITICAL: Before creating PR, check for NEW conflicts that may have appeared**

```bash
# MANDATORY: Re-check for open PRs before committing
gh pr list --state open

# If new PRs appeared during work, resolve conflicts first
if [[ $(gh pr list --state open | wc -l) -gt 0 ]]; then
    echo "⚠️  NEW CONFLICT: Another PR was created during development!"
    echo "Resolving conflicts with development branch..."
    
    # Pull latest changes and resolve conflicts
    git fetch origin development
    git merge origin/development
    
    # If conflicts exist, resolve them
    if [[ $? -ne 0 ]]; then
        echo "🔧 CONFLICTS DETECTED: Resolving merge conflicts..."
        echo "1. Review conflicted files"
        echo "2. Resolve conflicts manually"
        echo "3. Run platform verification after resolution"
        echo "4. Commit resolved conflicts"
        
        # After manual conflict resolution:
        git add .
        git commit -m "resolve: merge conflicts with development branch
        
        🤖 Generated with [Claude Code](https://claude.ai/code)
        
        Co-Authored-By: Claude <noreply@anthropic.com>"
        
        # MANDATORY: Verify platforms still build after conflict resolution
        echo "🔍 VERIFYING: Platform builds after conflict resolution..."
        flutter build web --release && echo "✅ Web build successful"
        flutter build apk --debug && echo "✅ Android build successful"
        
        # MANDATORY: Run tests after conflict resolution
        flutter test test/unit/ --reporter compact && echo "✅ Tests passing"
    fi
fi
```

## 🛠️ CONFLICT RESOLUTION REFERENCE

**When conflicts occur, use these resolution patterns:**

**Coverage Files:** `rm coverage/lcov.info` (regenerated by tests)
**Mock Files:** `git rm *.mocks.dart` (regenerated by build_runner)  
**Test Files:** Manually merge logic, update API calls
**Config Files:** Merge both versions, verify platform compatibility

## 📝 GITIGNORE MANAGEMENT

**CRITICAL**: Ensure .gitignore properly excludes generated files to prevent conflicts:

```bash
# Add these entries to .gitignore if not present:
echo "
# Generated files
*.g.dart
*.freezed.dart  
*.mocks.dart
build_runner.yaml

# Test coverage
coverage/
lcov.info" >> .gitignore
```

**Generated Files Policy:**
- **Never commit** `*.mocks.dart` files (generated by mockito)
- **Never commit** `*.g.dart` files (generated by json_annotation)
- **Never commit** `*.freezed.dart` files (generated by freezed)
- **Never commit** coverage files (regenerated by tests)

**Regeneration Commands:**
```bash
dart run build_runner build --delete-conflicting-outputs  # Regenerate all
flutter test --coverage                                   # Regenerate coverage
```

**STEP 7: COMMIT, PR CREATION & ISSUE COMMUNICATION**

**CRITICAL**: This step is MANDATORY for every issue implementation. No implementation is complete without proper GitHub workflow.

**Quality Validation & Platform Verification:**
```bash
# MANDATORY: Run comprehensive quality checks with platform builds
./scripts/quality-check.sh

# This script automatically:
# - Formats code and runs analysis
# - Executes all tests with coverage
# - Verifies platform configuration (Android/iOS Firebase setup)
# - Builds and tests all platforms (Web, Android, iOS on macOS)
# - Provides specific error messages and fixes for common issues
# - Times out builds to prevent infinite hangs

# If quality-check.sh passes, commit with standards from docs/github_instaruction.md
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
git push -u origin feature/issue-$ARGUMENTS-{short-description}

# Create PR targeting development branch (NEVER main directly)
gh pr create --base development --title "type(scope): description" --body "$(cat <<'EOF'
## Summary
- [Brief description of what was implemented]
- [Key architectural decisions or patterns used]
- [Integration points with existing codebase]

## Test Plan
- [x] [Test category 1: unit/widget/integration tests written]
- [x] [Test category 2: specific validation performed]
- [x] [Quality checks: lint, format, analyze passed]
- [x] [Architecture compliance: Clean Architecture patterns followed]

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**MANDATORY Issue Comment:**
```bash
# Comment on original issue with completion summary
gh issue comment $ARGUMENTS --body "$(cat <<'EOF'
## ✅ Issue Implementation Complete

**[Brief title of what was implemented]**

### 🎯 Implementation Summary:
- ✅ **[Feature/Component 1]**: [What was implemented and how]
- ✅ **[Feature/Component 2]**: [Key architectural decisions]
- ✅ **[Testing]**: [Test coverage and validation performed]
- ✅ **[Quality]**: [Standards compliance and quality metrics]

### 📊 Quality Metrics:
- **Test Coverage**: [Coverage percentage or test categories]
- **Architecture Compliance**: [Clean Architecture validation]
- **Security/Performance**: [Relevant standards met]
- **Documentation**: [Documentation updates completed]

### 🔗 Pull Request: #[PR_NUMBER]
Review and merge the implementation at: [GITHUB_PR_URL]

### 🚀 Next Steps:
[Brief description of what comes next in development sequence]

**Status**: ✅ **COMPLETED** - [Implementation is ready for review/merge]

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

**Branch Strategy**: Always target `development` branch for PRs (see parallel development workflow in CLAUDE.md)

**IMPLEMENTATION NOT COMPLETE UNTIL**:
1. ✅ Platform verification passed (all platforms build successfully)
2. ✅ Quality checks passed (tests, analysis, coverage)
3. ✅ Code committed with proper message format
4. ✅ Pull request created targeting `development` branch  
5. ✅ Issue commented with implementation summary and PR link
6. ✅ All documentation updates completed

**Platform Verification Requirements:**
- ✅ Web build successful
- ✅ Android build successful (with proper Firebase configuration)
- ✅ iOS build successful on macOS (with iOS 13.0+ deployment target)
- ✅ All platform-specific configurations validated

**AGENT COORDINATION EXAMPLE:**
Issue #11 (Firebase Setup):
1. flutter-architect → Creates project structure
2. firebase-specialist → Implements Firebase integration  
3. testing-specialist → Adds comprehensive tests
4. code-reviewer → Final validation

Each agent leaves detailed handoff notes for the next!

## DOCUMENTATION UPDATE REQUIREMENT:

**CRITICAL**: Every agent MUST update relevant documentation after completing their work.

**Required Documentation Updates:**
- **CLAUDE.md**: Update architecture, UI guidelines, Firebase config, or technology stack based on your changes
- **DEVELOPMENT_GUIDE.md**: Update workflow, commands, or troubleshooting based on your implementation
- **Agent Documentation**: Update your own agent file and relevant coordination protocols
- **Script Updates**: Modify automation scripts if new procedures are needed

**Documentation Update Format:**
```markdown
## DOCUMENTATION UPDATES COMPLETED:

### [Document Name] Changes:
- [Section] - [What was updated and why]
- [Section] - [New information added]

**Context for Next Agent**: [Summary of changes that affect subsequent work]
```

**Quality Gate**: No work is considered complete until documentation is updated for other agents to have full context.