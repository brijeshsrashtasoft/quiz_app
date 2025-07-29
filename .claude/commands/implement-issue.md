Please implement the GitHub issue: $ARGUMENTS

**PARALLEL DEVELOPMENT WORKFLOW - ALWAYS FOLLOW**:

1. **Setup Branch**: 
   ```bash
   git checkout development
   git pull origin development
   git checkout -b feature/issue-$ARGUMENTS-{short-description}
   ```

2. **Explore**: Use `gh issue view $ARGUMENTS` to get complete issue details

3. **Plan**: Read existing files and create TDD implementation plan

4. **Implement**: 
   - Write tests first (TDD approach)
   - Use UI guidelines and centralized components from CLAUDE.md
   - Follow Clean Architecture pattern strictly
   - Use approved colors and spacing constants only
   - Implement Firestore integration where applicable

5. **Verify**: 
   ```bash
   flutter test
   flutter analyze
   dart format .
   ```

6. **Commit**: 
   ```bash
   git add .
   git commit -m "type(scope): description - closes #$ARGUMENTS"
   ```

7. **Create PR to development**: 
   ```bash
   git push -u origin feature/issue-$ARGUMENTS-{short-description}
   gh pr create --base development --title "type(scope): description" --body "PR template filled"
   ```

**CRITICAL REQUIREMENTS**:
- NEVER create PR to `main` - ALWAYS to `development`
- Use centralized components and approved colors only
- Follow UI guidelines for consistent design
- Write comprehensive tests before implementation
- Ensure architecture compliance (data/domain/presentation layers)