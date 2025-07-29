Create a new feature following clean architecture: $ARGUMENTS

Follow this structure for feature: $ARGUMENTS

1. **Setup Feature Structure**:
   - Create `lib/features/$ARGUMENTS/` with clean architecture folders
   - Set up `data/`, `domain/`, and `presentation/` layers
   
2. **Domain Layer First** (TDD approach):
   - Create entity with Freezed data class
   - Define repository interface
   - Implement use cases with proper error handling
   - Write unit tests for domain logic
   
3. **Data Layer**:
   - Create Firestore data source
   - Implement data models with JSON serialization
   - Create repository implementation
   - Write integration tests for data layer
   
4. **Presentation Layer**:
   - Create Riverpod providers for state management
   - Implement UI pages following MVVM pattern
   - Create reusable widgets
   - Write widget tests
   
5. **Integration**:
   - Connect all layers through dependency injection
   - Update routing if needed
   - Run full test suite
   - Ensure `flutter analyze` passes

Requirements:
- Follow exact folder structure from CLAUDE.md
- Use Result pattern for error handling
- Implement proper loading states
- Follow GitHub commit message standards
- Create comprehensive tests for all layers