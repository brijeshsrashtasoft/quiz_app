Please implement GitHub issue: $ARGUMENTS

**STEP 1: ISSUE ANALYSIS & AGENT ASSIGNMENT**

First, analyze the issue and assign to appropriate specialized agents:

```bash
gh issue view $ARGUMENTS
```

Based on issue content, determine required agents:

**Agent Assignment Logic:**
- **Setup/Infrastructure** → flutter-architect (primary) + firebase-specialist (if Firebase)
- **Authentication** → firebase-specialist (primary) + flutter-architect + ui-designer  
- **UI/Components** → ui-designer (primary) + flutter-architect
- **Real-time Features** → firebase-specialist (primary) + performance-optimizer
- **Testing** → testing-specialist (primary) + flutter-architect
- **Performance** → performance-optimizer (primary) + flutter-architect

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
2. **Architecture Planning**: Plan implementation following Clean Architecture
3. **TDD Implementation**: Write tests first, then implement
4. **UI Compliance**: Use only approved colors/components from CLAUDE.md
5. **Agent Handoff**: When your work requires another agent, explicitly state:

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

**STEP 5: COMMIT & PR**

```bash
flutter test && flutter analyze && dart format .
git add .
git commit -m "type(scope): description - closes #$ARGUMENTS"
git push -u origin feature/issue-$ARGUMENTS-{short-description}
gh pr create --base development --title "type(scope): description"
```

**AGENT COORDINATION EXAMPLE:**
Issue #11 (Firebase Setup):
1. flutter-architect → Creates project structure
2. firebase-specialist → Implements Firebase integration  
3. testing-specialist → Adds comprehensive tests
4. code-reviewer → Final validation

Each agent leaves detailed handoff notes for the next!