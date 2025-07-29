Please implement GitHub issue: $ARGUMENTS

**Command Documentation**: This command provides intelligent agent assignment and coordinated implementation of GitHub issues.

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

**STEP 2: PARALLEL DEVELOPMENT WORKFLOW**

```bash
git checkout development
git pull origin development
git checkout -b feature/issue-$ARGUMENTS-{short-description}
```

**STEP 3: AGENT COORDINATION**

**Primary Agent Instructions:**
"Use the [primary-agent] subagent to implement issue #$ARGUMENTS. Follow these requirements:

1. **Read & Analyze**: First read the issue completely and understand requirements
2. **Architecture Planning**: Plan implementation following Clean Architecture (see CLAUDE.md)
3. **TDD Implementation**: Write tests first, then implement (see testing-specialist.md)
4. **UI Compliance**: Use only approved colors/components from CLAUDE.md design system
5. **Quality Standards**: Follow GitHub workflow from docs/github_instaruction.md
6. **Agent Handoff**: When your work requires another agent, use structured handoff protocol:

**HANDOFF TO [NEXT-AGENT]:**
- **Completed**: [What you've implemented]
- **Next Required**: [What the next agent needs to do]
- **Context**: [Important implementation details]
- **Files Modified**: [List of files created/changed]
- **Testing Status**: [What tests are written/needed]

Continue until all required agents have contributed."

**STEP 4: FINAL VALIDATION**

Use the code-reviewer subagent to validate final implementation:
"Use the code-reviewer subagent to review the complete implementation for issue #$ARGUMENTS"

**Quality Assurance**: The code-reviewer validates against all standards documented in CLAUDE.md, including:
- Clean Architecture compliance
- UI design system adherence
- Testing coverage requirements
- Performance standards
- Security guidelines
- **Documentation updates completed by all agents**

**STEP 5: COMMIT, PR CREATION & ISSUE COMMUNICATION**

**CRITICAL**: This step is MANDATORY for every issue implementation. No implementation is complete without proper GitHub workflow.

**Quality Validation & Commit:**
```bash
# Quality validation (or use scripts/quality-check.sh)
flutter test && flutter analyze && dart format .

# Commit with standards from docs/github_instaruction.md
git add .
git commit -m "type(scope): description - closes #$ARGUMENTS

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**MANDATORY Pull Request Creation:**
```bash
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
1. ✅ Code committed with proper message format
2. ✅ Pull request created targeting `development` branch  
3. ✅ Issue commented with implementation summary and PR link
4. ✅ All documentation updates completed

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