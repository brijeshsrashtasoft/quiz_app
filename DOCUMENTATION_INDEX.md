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

---

## ⚡ Custom Commands (`.claude/commands/`)

#### **implement-issue.md** - Intelligent Issue Implementation
- **Purpose**: Automated agent assignment and coordinated GitHub issue implementation
- **Usage**: `/project:implement-issue <number>`
- **Features**: 
  - Automatic agent assignment based on issue type
  - Structured handoff protocols
  - Quality validation workflow
  - GitHub integration with branch creation
- **Dependencies**: All sub-agent files, GitHub workflow standards

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

## 🔄 Cross-Reference Matrix

| **Document** | **References** | **Referenced By** |
|--------------|----------------|-------------------|
| **CLAUDE.md** | None (Master) | All docs, agents, commands, scripts |
| **DEVELOPMENT_GUIDE.md** | CLAUDE.md, github_instaruction.md, agents/, commands/ | Scripts, developers |
| **github_instaruction.md** | CLAUDE.md, DEVELOPMENT_GUIDE.md | All agents, commands, scripts |
| **flutter-architect.md** | CLAUDE.md, github_instaruction.md, DEVELOPMENT_GUIDE.md | implement-issue.md |
| **firebase-specialist.md** | CLAUDE.md, DEVELOPMENT_GUIDE.md, scripts/firebase-ops.sh | implement-issue.md |
| **ui-designer.md** | CLAUDE.md, flutter-architect.md | implement-issue.md |
| **testing-specialist.md** | CLAUDE.md, DEVELOPMENT_GUIDE.md, scripts/quality-check.sh | implement-issue.md |
| **code-reviewer.md** | CLAUDE.md, github_instaruction.md | implement-issue.md |
| **performance-optimizer.md** | CLAUDE.md, firebase-specialist.md | implement-issue.md |
| **implement-issue.md** | All agent files, CLAUDE.md, github_instaruction.md | DEVELOPMENT_GUIDE.md |
| **brainstorm-feature.md** | CLAUDE.md, implement-issue.md, github_instaruction.md | DEVELOPMENT_GUIDE.md |

---

## 📋 Usage Guidelines

### **For Developers**
1. **Start Here**: Read CLAUDE.md for project overview and standards
2. **Daily Workflow**: Use DEVELOPMENT_GUIDE.md for command reference
3. **GitHub Process**: Follow docs/github_instaruction.md for issues and PRs
4. **Implementation**: Use `/project:implement-issue <number>` for development

### **For Sub-Agents**
1. **Role Understanding**: Read your specific agent file in `.claude/agents/`
2. **Project Context**: Reference CLAUDE.md for architecture and design standards
3. **Communication**: Follow handoff protocols and GitHub standards
4. **Quality Assurance**: Validate against all referenced documentation

### **For Feature Planning**
1. **Brainstorming**: Use `/project:brainstorm-feature "description"`
2. **Implementation**: Follow recommendations to create GitHub issues
3. **Development**: Use `/project:implement-issue <number>` for execution
4. **Quality**: Run `scripts/quality-check.sh` before PR creation

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

**Command Files**:
- Implementation logic changes
- Workflow step modifications
- Integration updates

### **Cross-Reference Validation**
- When updating any document, verify all cross-references remain accurate
- Update the cross-reference matrix in this index
- Test all referenced commands and scripts
- Validate agent coordination still works correctly

---

## 🎯 Quick Navigation

**Need architecture guidance?** → `CLAUDE.md`
**Need workflow help?** → `DEVELOPMENT_GUIDE.md`
**Need GitHub standards?** → `docs/github_instaruction.md`
**Need agent-specific help?** → `.claude/agents/[agent-name].md`
**Need to implement an issue?** → Use `/project:implement-issue <number>`
**Need to brainstorm a feature?** → Use `/project:brainstorm-feature "description"`
**Need automation help?** → `scripts/[script-name].sh`

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

**Last Updated**: 2025-07-29
**Version**: 1.1 (Added agent documentation update requirements)
**Maintainer**: Project Team