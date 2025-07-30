Create a new feature following clean architecture: $ARGUMENTS

**PARALLEL DEVELOPMENT SETUP**:
```bash
git checkout development
git pull origin development  
git checkout -b feature/new-$ARGUMENTS-implementation
```

**Feature Implementation Structure**:

1. **Setup Feature Structure**:
   - Create `lib/features/$ARGUMENTS/` with clean architecture folders
   - Set up `data/`, `domain/`, and `presentation/` layers

2. **UI Constants First** (Required):
   - Use only approved colors from CLAUDE.md color system
   - Use centralized components (PrimaryButton, QuizTextField, etc.)
   - Follow typography and spacing standards
   - Implement proper responsive design

3. **Domain Layer** (TDD approach):
   - Create entity with Freezed data class
   - Define repository interface  
   - Implement use cases with Result pattern
   - Write unit tests for domain logic

4. **Data Layer**:
   - Create Firestore data source
   - Implement data models with JSON serialization
   - Create repository implementation
   - Write integration tests for data layer

5. **Presentation Layer**:
   - Create Riverpod providers for state management
   - Implement UI pages using centralized components
   - Follow MVVM pattern strictly
   - Use approved colors and spacing only
   - Write widget tests

6. **MANDATORY Agent Completion Requirements**:
   - **ALL agents must complete 100% of assigned tasks**
   - **Platform verification required**: All platforms (Web, Android, iOS) must build successfully
   - **Documentation updates mandatory**: All relevant docs must be updated
   - **Custom commands updated**: Any new procedures must be documented
   - **Integration validated**: All agent contributions must work together seamlessly

7. **Integration & PR**:
   ```bash
   # MANDATORY: Platform verification before PR
   flutter build web --release
   flutter build apk --release  
   flutter build ios --release --no-codesign
   
   # MANDATORY: Quality checks
   flutter test --coverage && flutter analyze && dart format .
   
   # Commit only after ALL verification passes
   git add . && git commit -m "feat($ARGUMENTS): implement feature - closes #issue

   🤖 Generated with [Claude Code](https://claude.ai/code)
   
   Co-Authored-By: Claude <noreply@anthropic.com>"
   
   git push -u origin feature/new-$ARGUMENTS-implementation
   gh pr create --base development --title "feat($ARGUMENTS): implement feature"
   ```

**CRITICAL**: 
- Never hardcode colors/spacing - use constants from CLAUDE.md only!
- **NO PR creation until ALL completion requirements are met**
- All agents must complete 100% of their tasks before any PR submission