# GitHub Workflow Standards - Kahoot Quiz App

**Project Context**: This document defines GitHub workflow standards for the Kahoot-style quiz app project. All team members and sub-agents must follow these guidelines.

**Related Documentation**:
- **CLAUDE.md** - Master project documentation with architecture and sub-agent coordination
- **DEVELOPMENT_GUIDE.md** - Complete development workflow and command usage
- **.claude/agents/** - Sub-agent specific roles and responsibilities
- **.claude/commands/** - Custom command implementations

**Usage**: Referenced by all sub-agents for consistent communication and development practices.

---

## Core Principles
- **One main goal per item** - Each ticket, commit, or comment should focus on a single objective
- **Clear action language** - Use active voice and specific verbs
- **Essential information only** - Remove unnecessary words and filler
- **Immediate clarity** - Reader should understand the purpose within 5 seconds

## Ticket Creation Standards

**Integration**: These standards are used by the `/project:implement-issue` command (see `.claude/commands/implement-issue.md`) for automated agent assignment.

- **Title format**: `[Action] [Component]: [Specific outcome]`
    - Example: "Fix authentication: Resolve login timeout errors"
    - Example: "Add user dashboard: Display account overview metrics"
- **Description structure**:
    - **Problem**: One sentence describing what's broken/missing
    - **Goal**: One sentence describing desired outcome
    - **Acceptance**: 2-3 bullet points of completion criteria
- **No background stories or context dumps**
- **Maximum 100 words total**

**Agent Assignment**: Issue keywords trigger automatic assignment to specialized sub-agents (see `CLAUDE.md` for agent coordination details).

## Commit Message Rules
- **Format**: `type(scope): concise description`
- **Types**: fix, feat, docs, refactor, test, chore
- **Description**: Start with verb, stay under 50 characters
- **Examples**:
    - `fix(auth): resolve session timeout`
    - `feat(dashboard): add revenue chart`
    - `docs(api): update endpoint examples`

## Pull Request Standards

**Branch Strategy**: All PRs target `development` branch, never `main` directly (see parallel development workflow in `CLAUDE.md`).

- **Title**: Same as commit message format
- **Description**:
    - **Changes**: 1-2 sentences max
    - **Testing**: How you verified it works
    - **Impact**: What this affects
- **No implementation details in description**

**Quality Gates**: Use `scripts/quality-check.sh` before creating PRs (see `DEVELOPMENT_GUIDE.md` for usage).

## Code Comments
- **Only explain WHY, never WHAT**
- **Focus on business logic and non-obvious decisions**
- **Remove TODO comments before committing**
- **Maximum one line per comment**

## Review Comments

**Sub-Agent Reviews**: The code-reviewer sub-agent (see `.claude/agents/code-reviewer.md`) follows these standards for consistent feedback.

- **Be specific**: Point to exact lines/issues
- **Suggest solutions**: Don't just identify problems
- **Use imperative mood**: "Change X to Y" not "X should be Y"
- **One issue per comment**

**Architecture Compliance**: Reviews must verify adherence to Clean Architecture patterns and UI guidelines defined in `CLAUDE.md`.

## General Rules

**Sub-Agent Communication**: All specialized sub-agents use these rules for consistent handoff protocols (see sub-agent coordination in `CLAUDE.md`).

- **Eliminate filler words**: "just", "simply", "basically", "actually"
- **Use specific numbers**: "Reduce load time by 200ms" not "faster"
- **Avoid jargon**: Write for any team member to understand
- **Edit ruthlessly**: Cut everything non-essential

---

## Automation Integration

**Scripts**: The following automation scripts reference these standards:
- `scripts/develop-feature.sh` - Creates branches following naming conventions
- `scripts/quality-check.sh` - Enforces code quality before PRs
- `scripts/daily-dev.sh` - Daily workflow automation

**Custom Commands**: 
- `/project:implement-issue <number>` - Uses issue standards for agent assignment
- `/project:brainstorm-feature "description"` - Follows ticket creation format

**Documentation Updates**: When modifying these standards, update references in `CLAUDE.md` and `DEVELOPMENT_GUIDE.md`.