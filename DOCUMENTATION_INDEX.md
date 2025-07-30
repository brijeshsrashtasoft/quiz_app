# 📚 Documentation Index - Kahoot Quiz App

This index provides a comprehensive overview of all project documentation with cross-references and usage guidance.

## 🗂️ Documentation Hierarchy

### **Master Documentation**

#### **CLAUDE.md** - Project Master Documentation
- **Purpose**: Central source of truth for architecture, design, and development standards
- **Key Sections**:
  - Clean Architecture + MVVM patterns
  - UI/UX Design Guidelines (colors, components, typography)
  - Firebase/Firestore configuration and database design
  - Sub-agent coordination protocols
  - Technology stack and dependencies
  - Performance requirements and security guidelines
- **Referenced By**: All sub-agents, custom commands, automation scripts
- **Update Frequency**: When architecture or design standards change

#### **DEVELOPMENT_GUIDE.md** - Complete Development Workflow
- **Purpose**: Practical development guide with commands, timeline, and troubleshooting
- **Key Sections**:
  - Command usage and workflow guidance
  - 13-week development timeline and milestones
  - Runnable automation scripts documentation
  - Quality gates and testing procedures
  - Troubleshooting common issues
- **Referenced By**: Developers for daily workflow, scripts for automation
- **Update Frequency**: When workflow processes change

#### **docs/github_instaruction.md** - GitHub Workflow Standards
- **Purpose**: GitHub-specific workflow standards and communication guidelines
- **Key Sections**:
  - Issue creation standards and formats
  - Commit message conventions
  - Pull request templates and review guidelines
  - Code comment and communication standards
- **Referenced By**: All sub-agents for consistent communication, automation scripts
- **Update Frequency**: When GitHub processes change

---

## 🤖 Sub-Agent Documentation

### **Specialized Agent Files** (`.claude/agents/`)

#### **flutter-architect.md** - Clean Architecture Specialist
- **Expertise**: Clean Architecture, project structure, Riverpod state management
- **Primary Assignments**: Setup/Infrastructure, Architecture design
- **Key Responsibilities**: Folder structure, layer separation, dependency injection
- **Handoff Partners**: firebase-specialist, ui-designer, testing-specialist

#### **firebase-specialist.md** - Firebase Integration Expert
- **Expertise**: Firestore, Authentication, real-time features, security rules
- **Primary Assignments**: Authentication, Real-time features, Firebase integration
- **Key Responsibilities**: Database design, security rules, performance optimization
- **Handoff Partners**: flutter-architect, performance-optimizer, testing-specialist

#### **ui-designer.md** - UI/UX Design Specialist
- **Expertise**: Flutter widgets, Kahoot-style UI, design system compliance
- **Primary Assignments**: UI/Components, Design system implementation
- **Key Responsibilities**: Component creation, design consistency, animations
- **Handoff Partners**: flutter-architect, testing-specialist

#### **testing-specialist.md** - TDD and Quality Assurance
- **Expertise**: Test-Driven Development, comprehensive testing, quality gates
- **Primary Assignments**: Testing infrastructure, Test coverage validation
- **Key Responsibilities**: Unit/Widget/Integration tests, >80% coverage
- **Handoff Partners**: All agents for test validation

#### **code-reviewer.md** - Quality Assurance Validator
- **Expertise**: Code quality, architecture compliance, security validation
- **Primary Assignments**: Final validation for all implementations
- **Key Responsibilities**: Architecture compliance, security review, quality standards
- **Handoff Partners**: Final validation for all agent work

#### **performance-optimizer.md** - Performance Specialist
- **Expertise**: Flutter performance, memory management, real-time optimization
- **Primary Assignments**: Performance issues, Real-time feature optimization
- **Key Responsibilities**: <200ms latency, <100MB memory, 60fps animations
- **Handoff Partners**: firebase-specialist, flutter-architect

#### **pr-review-agent.md** - **EXCLUSIVE** PR Review & Merge Authority (NEW)
- **Expertise**: Comprehensive PR review, quality assurance, merge authority
- **Primary Assignments**: PR validation, final approval, merge decisions
- **Key Responsibilities**: **ONLY** agent authorized to merge PRs, enforce quality gates
- **Authority Level**: **EXCLUSIVE** - No other agent can merge PRs

---

## ⚡ Custom Commands (`.claude/commands/`)

#### **implement-issue.md** - Enhanced Issue Implementation (UPDATED)
- **Purpose**: Automated agent assignment with unified ticket tracking and test validation
- **Usage**: `/implement-issue <number>`
- **NEW FEATURES**: 
  - **UNIFIED TICKET SYSTEM**: ONE ticket file per issue using branch name format
  - **NESTED CHECKBOX STRUCTURE**: All agents work in same file with hierarchical todos
  - **MANDATORY TEST VALIDATION**: All test categories must pass before PR creation
  - **PR REVIEW INTEGRATION**: Only pr-review-agent can merge PRs
  - **CROSS-REFERENCE TRACKING**: Documentation update requirements built-in
- **Dependencies**: All sub-agent files, pr-review-agent.md, unified ticket format

#### **brainstorm-feature.md** - Comprehensive Feature Planning
- **Purpose**: 8-step feature analysis and implementation planning
- **Usage**: `/project:brainstorm-feature "feature description"`
- **Features**:
  - Technical architecture planning
  - UI/UX design requirements
  - Testing strategy development
  - Firebase considerations
  - GitHub issue creation recommendations
- **Dependencies**: CLAUDE.md architecture patterns, UI guidelines

---

## 🛠️ Automation Scripts (`scripts/`)

#### **daily-dev.sh** - Daily Development Workflow
- **Purpose**: Automated daily development setup and environment validation
- **Features**: Git sync, dependency updates, environment checks, test execution
- **Dependencies**: CLAUDE.md commands, GitHub workflow

#### **develop-feature.sh** - Feature Development Setup
- **Purpose**: Automated branch creation and feature development setup
- **Usage**: `./scripts/develop-feature.sh <issue-number>`
- **Features**: Branch creation, issue analysis, implementation guidance
- **Dependencies**: GitHub CLI, issue creation standards

#### **quality-check.sh** - Pre-PR Quality Validation
- **Purpose**: Comprehensive quality validation before pull request creation
- **Features**: Code formatting, analysis, testing, coverage reporting, build verification
- **Dependencies**: Flutter tools, testing framework, coverage tools

#### **firebase-ops.sh** - Firebase Operations Helper
- **Purpose**: Streamlined Firebase deployment and operations
- **Usage**: `./scripts/firebase-ops.sh [start|deploy|rules|functions]`
- **Features**: Emulator management, deployment automation, environment switching
- **Dependencies**: Firebase CLI, project configuration

---

## 📋 UNIFIED TICKET TRACKING SYSTEM (NEW)

### **Current Unified System**
| Format | Purpose | Used By | Example |
|--------|---------|---------|---------|
| **docs/tickets/{branch-name}.md** | ONE ticket per issue with nested checkboxes | ALL agents | `docs/tickets/feature-issue-15-quiz-creation.md` |

### **Legacy Ticket Files (DEPRECATED)**
| Format | Status | Migration Notes |
|--------|--------|-----------------|
| **docs/tickets/issue-{number}-{branch}.md** | LEGACY | Use unified branch-name format instead |

### **Unified Ticket Structure**
All agents work in the SAME file with nested checkbox hierarchies:
```markdown
# Issue #{number} - {Issue Title}

## Implementation Progress
### 🔥 Main Implementation Tasks
- [ ] **Core Feature Implementation**
  - [ ] Architecture setup (flutter-architect)
  - [ ] Firebase integration (firebase-specialist)
  - [ ] UI components (ui-designer)
  - [ ] Testing framework (testing-specialist)

#### flutter-architect Agent
- [ ] Clean Architecture implementation
  - [ ] Domain layer entities
  - [ ] Repository contracts

## Test Execution Status  
- [ ] **ALL tests passing**: Required before PR creation
- [ ] **Coverage threshold met**: >80% coverage achieved
```

## 🔒 PR REVIEW & MERGE AUTHORITY WORKFLOW (NEW)

### **EXCLUSIVE PR Merge Authority**
| Step | Actor | Documentation | Authority Level |
|------|-------|---------------|-----------------|
| **Implementation** | Specialized agents | implement-issue.md | Can create PRs |
| **PR Review** | pr-review-agent ONLY | pr-review-agent.md | **EXCLUSIVE** review authority |
| **Change Requests** | Original agents | pr-review-agent.md | Must complete changes |
| **PR Merge** | pr-review-agent ONLY | pr-review-agent.md | **EXCLUSIVE** merge authority |

### **Mandatory PR Approval Criteria**
- ✅ **Unified Ticket Complete**: All nested checkboxes marked [x]
- ✅ **Test Validation**: >80% coverage, all test categories pass
- ✅ **Platform Verification**: Web, Android, iOS builds successful
- ✅ **Documentation Updates**: Cross-references updated in all relevant files

## 🔄 Cross-Reference Matrix (UPDATED)

| **Document** | **References** | **Referenced By** |
|--------------|----------------|-------------------|
| **CLAUDE.md** | DOCUMENTATION_INDEX.md, pr-review-agent.md (Master) | All docs, agents, commands, scripts |
| **DOCUMENTATION_INDEX.md** | CLAUDE.md, ALL project files | CLAUDE.md, all agents |
| **pr-review-agent.md** | CLAUDE.md, implement-issue.md, ALL agent files | CLAUDE.md, implement-issue.md |
| **implement-issue.md** | All agent files, pr-review-agent.md, CLAUDE.md | DEVELOPMENT_GUIDE.md, CLAUDE.md |
| **github_instaruction.md** | CLAUDE.md, pr-review-agent.md | All agents, commands, scripts |
| **flutter-architect.md** | CLAUDE.md, implement-issue.md, DOCUMENTATION_INDEX.md | implement-issue.md, pr-review-agent.md |
| **firebase-specialist.md** | CLAUDE.md, DOCUMENTATION_INDEX.md | implement-issue.md, pr-review-agent.md |
| **ui-designer.md** | CLAUDE.md, DOCUMENTATION_INDEX.md | implement-issue.md, pr-review-agent.md |
| **testing-specialist.md** | CLAUDE.md, DOCUMENTATION_INDEX.md | implement-issue.md, pr-review-agent.md |
| **code-reviewer.md** | CLAUDE.md, pr-review-agent.md | implement-issue.md, pr-review-agent.md |
| **performance-optimizer.md** | CLAUDE.md, DOCUMENTATION_INDEX.md | implement-issue.md, pr-review-agent.md |
| **brainstorm-feature.md** | CLAUDE.md, implement-issue.md | DEVELOPMENT_GUIDE.md |

---

## 📋 Usage Guidelines

### **For Developers**
1. **Start Here**: Read CLAUDE.md for project overview and standards
2. **Daily Workflow**: Use DEVELOPMENT_GUIDE.md for command reference
3. **GitHub Process**: Follow docs/github_instaruction.md for issues and PRs
4. **Implementation**: Use `/implement-issue <number>` for development (UPDATED COMMAND)
5. **PR Process**: Only pr-review-agent can merge PRs (NEW REQUIREMENT)

### **For Sub-Agents (UPDATED WORKFLOW)**
1. **Role Understanding**: Read your specific agent file in `.claude/agents/`
2. **Project Context**: Reference CLAUDE.md for architecture and design standards
3. **Unified Tickets**: ALL agents work in SAME ticket file using nested checkboxes
4. **Test Validation**: ALL tests must pass before marking tasks complete
5. **Cross-Reference Updates**: Update documentation references when creating/modifying .md files
6. **PR Authority**: ONLY pr-review-agent can merge PRs - others can only create

### **For Feature Planning**
1. **Brainstorming**: Use `/project:brainstorm-feature "description"`
2. **Implementation**: Follow recommendations to create GitHub issues
3. **Development**: Use `/implement-issue <number>` for execution (UPDATED)
4. **Quality**: Run `scripts/quality-check.sh` before PR creation
5. **PR Review**: Wait for pr-review-agent approval before merge (NEW)

---

## 🔄 Maintenance Guidelines

### **When to Update Documentation**

**CLAUDE.md**:
- Architecture pattern changes
- UI design system modifications
- Technology stack updates
- Agent coordination protocol changes

**DEVELOPMENT_GUIDE.md**:
- Workflow process changes
- Command usage updates
- Timeline modifications
- Troubleshooting additions

**github_instaruction.md**:
- GitHub workflow changes
- Communication standard updates
- Issue/PR template modifications

**Agent Files**:
- Role responsibility changes
- Handoff protocol updates
- Quality standard modifications
- NEW: pr-review-agent authority updates

**Command Files**:
- Implementation logic changes
- Workflow step modifications
- Integration updates
- NEW: Unified ticket format changes
- NEW: Test validation requirement updates

### **Cross-Reference Validation (ENHANCED)**
- When updating any document, verify all cross-references remain accurate
- Update the cross-reference matrix in this index
- Test all referenced commands and scripts
- Validate agent coordination still works correctly
- **NEW: pr-review-agent validation** - All documentation updates reviewed during PR process
- **NEW: Unified ticket integration** - Ensure ticket format consistency

---

## 🎯 Quick Navigation

**Need architecture guidance?** → `CLAUDE.md`
**Need workflow help?** → `DEVELOPMENT_GUIDE.md`
**Need GitHub standards?** → `docs/github_instaruction.md`
**Need agent-specific help?** → `.claude/agents/[agent-name].md`
**Need to implement an issue?** → Use `/implement-issue <number>` (UPDATED)
**Need to brainstorm a feature?** → Use `/project:brainstorm-feature "description"`
**Need automation help?** → `scripts/[script-name].sh`
**Need PR review/merge?** → Only `pr-review-agent` has authority (NEW)
**Need unified ticket help?** → Check `docs/tickets/{branch-name}.md` format (NEW)

---

## 🔄 Documentation Maintenance Protocol

### **Agent Documentation Update Requirements**

**CRITICAL**: All sub-agents MUST update relevant documentation after completing their work to ensure other agents have complete context.

**Required Updates by Agent Type:**

**flutter-architect:**
- Update CLAUDE.md architecture sections
- Modify DEVELOPMENT_GUIDE.md workflow if needed
- Update own agent documentation with new patterns

**firebase-specialist:**
- Update CLAUDE.md Firebase configuration and database design
- Modify scripts/firebase-ops.sh if new operations added
- Update DEVELOPMENT_GUIDE.md troubleshooting

**ui-designer:**
- Update CLAUDE.md UI/UX Design Guidelines
- Add new components to Component Library section
- Update color system if approved variants created

**testing-specialist:**
- Update CLAUDE.md testing strategy and quality standards
- Modify DEVELOPMENT_GUIDE.md testing procedures
- Update scripts/quality-check.sh if new validations added

**code-reviewer:**
- Update CLAUDE.md quality guidelines based on review insights
- Modify docs/github_instaruction.md review standards
- Update DEVELOPMENT_GUIDE.md troubleshooting

**performance-optimizer:**
- Update CLAUDE.md performance requirements with benchmarks
- Modify DEVELOPMENT_GUIDE.md with performance procedures
- Document optimization strategies for future reference

**pr-review-agent:** (NEW)
- Update CLAUDE.md PR review standards based on review insights
- Modify implement-issue.md workflow requirements
- Update DOCUMENTATION_INDEX.md cross-reference matrix

### **Documentation Update Format**

All agents must use this format when updating documentation:

```markdown
## DOCUMENTATION UPDATES COMPLETED:

### [Document Name] Changes:
- [Section] - [What was updated and why]
- [Section] - [New information added]

**Context for Next Agent**: [Summary of changes affecting subsequent work]
```

### **Cross-Reference Validation**

When updating any document:
1. Verify all cross-references remain accurate
2. Update the cross-reference matrix if relationships change
3. Ensure consistency across all referenced documents
4. Test any command or script references mentioned

---

---

## 🆕 RECENT UPDATES & NEW FEATURES

### **Version 2.0 Updates (Latest)**
- ✅ **NEW: pr-review-agent** - Exclusive PR merge authority agent added
- ✅ **UPDATED: implement-issue.md** - Enhanced with unified ticket tracking and test validation
- ✅ **NEW: Unified Ticket System** - ONE ticket file per issue using branch name format
- ✅ **NEW: Mandatory Test Validation** - All test categories must pass before PR creation
- ✅ **UPDATED: Cross-Reference Matrix** - Complete matrix with new agent relationships
- ✅ **NEW: PR Review Workflow** - Only pr-review-agent can merge PRs

### **Breaking Changes**
- **Command Update**: `/project:implement-issue` → `/implement-issue` 
- **Ticket Format**: `issue-{number}-{branch}.md` → `{branch-name}.md`
- **PR Authority**: Any agent could merge → ONLY pr-review-agent can merge
- **Test Requirements**: Optional testing → MANDATORY >80% coverage

### **Migration Guide**
1. **Existing Tickets**: Convert to unified format during next implementation
2. **Agent Workflows**: All agents must use nested checkbox structure
3. **PR Process**: Wait for pr-review-agent approval before merge
4. **Documentation**: Update cross-references when creating/modifying .md files

---

**Last Updated**: $(date)
**Version**: 2.0 (Added unified ticket system, pr-review-agent, and enhanced test validation)
**Maintainer**: Project Team with pr-review-agent quality assurance