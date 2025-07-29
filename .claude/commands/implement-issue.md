Please implement the GitHub issue: $ARGUMENTS

Follow these steps strictly:
1. **Explore**: Use `gh issue view $ARGUMENTS` to get complete issue details
2. **Plan**: Read existing relevant files and create implementation plan following TDD approach
3. **Test First**: Write tests that will fail initially (following TDD)
4. **Code**: Implement the minimal code to make tests pass
5. **Verify**: Run tests, linting, and ensure code follows clean architecture
6. **Commit**: Use format `type(scope): description` referring to issue #$ARGUMENTS
7. **Review**: Self-review code for architecture compliance before creating PR

Requirements:
- Follow Clean Architecture pattern strictly
- Use Riverpod for state management
- Implement with Firestore integration where applicable
- Write comprehensive tests (unit, widget, integration)
- Follow commit message standards from CLAUDE.md
- Ensure code passes `flutter analyze` and `dart format`
- Create PR with proper title format and description

Remember: One main goal per implementation, focus on the specific issue requirements only.