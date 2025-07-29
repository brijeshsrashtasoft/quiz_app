# GitHub Workflow Standards

- Standards for all team members and sub-agents
- Referenced by automated commands and agents
- Enforced by quality-check scripts

## Core Principles
- One main goal per item
- Clear action language
- Essential information only
- 5-second clarity rule

## Ticket Standards

- **Title**: `[Action] [Component]: [Specific outcome]`
- **Description** (max 100 words):
  - Problem: One sentence
  - Goal: One sentence  
  - Acceptance: 2-3 bullets
- No background stories
- Triggers auto-agent assignment

## Commit Messages
- **Format**: `type(scope): description`
- **Types**: fix, feat, docs, refactor, test, chore
- **Description**: Verb + under 50 chars
- **Examples**: `fix(auth): resolve timeout`, `feat(ui): add button`

## Pull Request Standards

- **Target**: `development` branch only
- **Title**: Same as commit format
- **Description**:
  - Changes: 1-2 sentences
  - Testing: How verified
  - Impact: What affects
- Run `scripts/quality-check.sh` first

## Code Comments
- Explain WHY, never WHAT
- Business logic only
- Remove TODOs before commit
- One line max

## Review Comments
- Be specific to exact lines
- Suggest solutions, not just problems
- Use imperative: "Change X to Y"
- One issue per comment
- Verify architecture compliance

## Writing Rules
- No filler words: "just", "simply", "basically"
- Use specific numbers: "200ms faster"
- No jargon
- Cut everything non-essential

## Automation
- Scripts enforce these standards
- Commands use ticket format
- Update CLAUDE.md when changing