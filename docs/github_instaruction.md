## Core Principles
- **One main goal per item** - Each ticket, commit, or comment should focus on a single objective
- **Clear action language** - Use active voice and specific verbs
- **Essential information only** - Remove unnecessary words and filler
- **Immediate clarity** - Reader should understand the purpose within 5 seconds

## Ticket Creation Standards
- **Title format**: `[Action] [Component]: [Specific outcome]`
    - Example: "Fix authentication: Resolve login timeout errors"
    - Example: "Add user dashboard: Display account overview metrics"
- **Description structure**:
    - **Problem**: One sentence describing what's broken/missing
    - **Goal**: One sentence describing desired outcome
    - **Acceptance**: 2-3 bullet points of completion criteria
- **No background stories or context dumps**
- **Maximum 100 words total**

## Commit Message Rules
- **Format**: `type(scope): concise description`
- **Types**: fix, feat, docs, refactor, test, chore
- **Description**: Start with verb, stay under 50 characters
- **Examples**:
    - `fix(auth): resolve session timeout`
    - `feat(dashboard): add revenue chart`
    - `docs(api): update endpoint examples`

## Pull Request Standards
- **Title**: Same as commit message format
- **Description**:
    - **Changes**: 1-2 sentences max
    - **Testing**: How you verified it works
    - **Impact**: What this affects
- **No implementation details in description**

## Code Comments
- **Only explain WHY, never WHAT**
- **Focus on business logic and non-obvious decisions**
- **Remove TODO comments before committing**
- **Maximum one line per comment**

## Review Comments
- **Be specific**: Point to exact lines/issues
- **Suggest solutions**: Don't just identify problems
- **Use imperative mood**: "Change X to Y" not "X should be Y"
- **One issue per comment**

## General Rules
- **Eliminate filler words**: "just", "simply", "basically", "actually"
- **Use specific numbers**: "Reduce load time by 200ms" not "faster"
- **Avoid jargon**: Write for any team member to understand
- **Edit ruthlessly**: Cut everything non-essential