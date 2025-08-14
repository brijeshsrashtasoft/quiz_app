/// Authentication domain layer exports
/// Following CLAUDE.md Clean Architecture patterns
///
/// This file provides centralized access to all authentication domain components
/// for easier imports and better maintainability.
library;

// Entities
export 'entities/user_entity.dart';
export 'entities/auth_state.dart';
export 'entities/user_session.dart';

// Repositories (interfaces only)
export 'repositories/auth_repository.dart';
export 'repositories/user_repository.dart';

// Use cases
export 'usecases/index.dart';

// Value objects
export 'value_objects/index.dart';

// Failures
export 'failures/index.dart';
