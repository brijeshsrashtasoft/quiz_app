# TDD + Clean Architecture Integration Guide

## Overview

This guide demonstrates how to implement Test-Driven Development (TDD) with Clean Architecture patterns in our Kahoot-style quiz app, following CLAUDE.md specifications.

## TDD Workflow Integration

### 1. TDD Phases with Clean Architecture

#### RED Phase: Write Failing Tests First
```bash
# Start TDD cycle for a new feature component
./scripts/tdd-workflow.sh red authentication usecase

# This creates:
# - Test template that fails initially
# - Proper test structure following Clean Architecture
# - Mock setup for dependencies
```

#### GREEN Phase: Make Tests Pass
```bash
# Implement minimal code to pass tests
./scripts/tdd-workflow.sh green authentication usecase

# This creates:
# - Implementation template
# - Follows Clean Architecture patterns
# - Minimal code to make tests pass
```

#### REFACTOR Phase: Improve Code Quality
```bash
# Refactor while keeping tests green
./scripts/tdd-workflow.sh refactor authentication usecase

# This:
# - Runs full test suite
# - Performs code analysis
# - Validates architecture compliance
```

### 2. TDD Templates for Each Architecture Layer

#### Entity TDD Pattern
```dart
// test/unit/features/feature_name/domain/entities/entity_test.dart

import 'package:flutter_test/flutter_test.dart';
import '../../../../../helpers/tdd_templates.dart';

void main() {
  group('UserEntity - TDD Implementation', () {
    // RED: Write failing test first
    test('should create valid entity instance', () {
      // This would fail initially - drives implementation
      expect(() => UserEntity(), throwsA(isA<UnimplementedError>()));
    });

    // GREEN: Implement minimal entity to pass
    test('should support value equality', () {
      // Drives Freezed implementation
      final entity1 = UserEntity(/* params */);
      final entity2 = UserEntity(/* same params */);
      expect(entity1, equals(entity2));
    });

    // REFACTOR: Add comprehensive tests
    EntityTestTemplate.runBasicTests<UserEntity>(
      createValidEntity: () => UserEntity(/* valid data */),
      createInvalidEntity: () => UserEntity(/* invalid data */),
      entityName: 'UserEntity',
      businessLogicMethods: ['isValid', 'canPerformAction'],
    );
  });
}
```

#### Use Case TDD Pattern
```dart
// test/unit/features/feature_name/domain/usecases/usecase_test.dart

@GenerateMocks([UserRepository])
void main() {
  late CreateUserUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = CreateUserUseCase(repository: mockRepository);
  });

  group('CreateUserUseCase - TDD Implementation', () {
    // RED: Write failing test
    test('should return success when repository succeeds', () async {
      // Arrange
      final params = CreateUserParams(user: testUser);
      when(mockRepository.createUser(testUser))
          .thenAnswer((_) async => Result.success(testUser));

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.createUser(testUser)).called(1);
    });

    // GREEN: Implement minimal use case
    // REFACTOR: Add comprehensive scenarios
    UseCaseTestTemplate.runBasicTests<CreateUserUseCase, UserEntity, CreateUserParams>(
      createUseCase: () => CreateUserUseCase(repository: mockRepository),
      createValidParams: () => CreateUserParams(user: testUser),
      createInvalidParams: () => CreateUserParams(user: invalidUser),
      useCaseName: 'CreateUserUseCase',
      mockRepository: mockRepository,
    );
  });
}
```

#### Repository TDD Pattern
```dart
// test/unit/features/feature_name/data/repositories/repository_test.dart

@GenerateMocks([UserDataSource])
void main() {
  late UserRepositoryImpl repository;
  late MockUserDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockUserDataSource();
    repository = UserRepositoryImpl(dataSource: mockDataSource);
  });

  group('UserRepositoryImpl - TDD Implementation', () {
    // RED: Write failing test
    test('should return entity when data source succeeds', () async {
      // Arrange
      when(mockDataSource.createUser(any))
          .thenAnswer((_) async => Result.success(testUserModel));

      // Act
      final result = await repository.createUser(testUser);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<UserEntity>());
    });

    // GREEN: Implement repository with data mapping
    // REFACTOR: Add error handling and validation
    RepositoryTestTemplate.runBasicTests<UserRepositoryImpl, UserEntity, MockUserDataSource>(
      createRepository: () => UserRepositoryImpl(dataSource: mockDataSource),
      createValidEntity: () => testUser,
      repositoryName: 'UserRepositoryImpl',
      entityName: 'UserEntity',
      mockDataSourceFactory: () => mockDataSource,
    );
  });
}
```

#### Data Source TDD Pattern
```dart
// test/unit/features/feature_name/data/datasources/datasource_test.dart

void main() {
  late UserFirestoreDataSource dataSource;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = UserFirestoreDataSource(firestore: fakeFirestore);
  });

  group('UserFirestoreDataSource - TDD Implementation', () {
    // RED: Write failing test
    test('should create document in Firestore', () async {
      // Act
      final result = await dataSource.createUser(testUserModel);

      // Assert
      expect(result.isSuccess, isTrue);
      
      // Verify Firestore document was created
      final doc = await fakeFirestore.collection('users').doc(testUserModel.id).get();
      expect(doc.exists, isTrue);
    });

    // GREEN: Implement Firestore operations
    // REFACTOR: Add error handling and serialization
    DataSourceTestTemplate.runBasicTests<UserFirestoreDataSource, UserModel>(
      createDataSource: () => UserFirestoreDataSource(firestore: fakeFirestore),
      createValidModel: () => testUserModel,
      dataSourceName: 'UserFirestoreDataSource',
      modelName: 'UserModel',
      fakeFirestoreFactory: () => fakeFirestore,
    );
  });
}
```

### 3. TDD Workflow Scripts

#### Start New Feature with TDD
```bash
# Create failing tests for all layers
./scripts/tdd-workflow.sh red quiz_creation entity
./scripts/tdd-workflow.sh red quiz_creation usecase  
./scripts/tdd-workflow.sh red quiz_creation repository
./scripts/tdd-workflow.sh red quiz_creation datasource

# Implement minimal code to pass tests
./scripts/tdd-workflow.sh green quiz_creation entity
./scripts/tdd-workflow.sh green quiz_creation usecase
./scripts/tdd-workflow.sh green quiz_creation repository  
./scripts/tdd-workflow.sh green quiz_creation datasource

# Refactor and improve
./scripts/tdd-workflow.sh refactor quiz_creation entity
./scripts/tdd-workflow.sh refactor quiz_creation usecase
./scripts/tdd-workflow.sh refactor quiz_creation repository
./scripts/tdd-workflow.sh refactor quiz_creation datasource
```

#### Continuous TDD with Watch Mode
```bash
# Start continuous test execution during development
./scripts/tdd-workflow.sh watch

# This automatically runs tests when files change
# Provides immediate feedback on TDD RED/GREEN cycles
```

#### Architecture Compliance Testing
```bash
# Verify Clean Architecture compliance
./scripts/tdd-workflow.sh architecture

# Runs comprehensive architecture tests:
# - Dependency direction validation
# - Interface segregation checks
# - Error handling pattern verification
# - Naming convention compliance
```

## 4. Architecture Testing Integration

### Dependency Direction Tests
```dart
test('Domain layer should not import Data layer', () async {
  final domainFiles = await _getDomainFiles();
  final violations = <String>[];

  for (final file in domainFiles) {
    final content = await File(file).readAsString();
    if (content.contains('import') && content.contains('/data/')) {
      violations.add(file);
    }
  }

  expect(violations, isEmpty, 
    reason: 'Domain layer violating dependency rules: $violations');
});
```

### Result Pattern Compliance
```dart
test('All use cases should return Result type', () async {
  final useCaseFiles = await _getUseCaseFiles();
  final violations = <String>[];

  for (final file in useCaseFiles) {
    final content = await File(file).readAsString();
    if (!content.contains('Future<Result<') && 
        !content.contains('extends BaseUseCase')) {
      violations.add(file);
    }
  }

  expect(violations, isEmpty,
    reason: 'Use cases not following Result pattern: $violations');
});
```

## 5. TDD Best Practices

### Write Tests That Drive Design
```dart
group('TDD Design Example: User Email Validation', () {
  test('RED: Should validate email format', () async {
    // Write test for desired behavior FIRST
    final invalidUser = testUser.copyWith(email: 'invalid-email');
    final params = CreateUserParams(user: invalidUser);

    // This test drives implementation of email validation
    final result = await useCase.call(params);
    
    expect(result.isFailure, isTrue);
    expect(result.error?.userMessage, contains('Invalid email'));
  });

  test('GREEN: Should accept valid email formats', () async {
    // Implement minimal validation to make both tests pass
    final validUser = testUser.copyWith(email: 'valid@example.com');
    final params = CreateUserParams(user: validUser);

    final result = await useCase.call(params);
    
    expect(result.isSuccess, isTrue);
  });

  test('REFACTOR: Should handle edge cases', () async {
    // Add comprehensive test cases
    final testCases = [
      ('user@domain.com', true),
      ('user.name+tag@domain.co.uk', true),
      ('invalid.email', false),
      ('', false),
      ('user@', false),
    ];

    for (final (email, shouldSucceed) in testCases) {
      final user = testUser.copyWith(email: email);
      final result = await useCase.call(CreateUserParams(user: user));
      
      expect(result.isSuccess, equals(shouldSucceed),
        reason: 'Email $email validation failed');
    }
  });
});
```

### Mock Properly for Unit Tests
```dart
// Good: Mock external dependencies
when(mockRepository.createUser(any))
    .thenAnswer((_) async => Result.success(testUser));

// Good: Verify interactions
verify(mockRepository.createUser(testUser)).called(1);

// Good: Test error scenarios
when(mockRepository.createUser(any))
    .thenAnswer((_) async => Result.failure(networkFailure));
```

### Use Test Data Builders
```dart
class UserTestDataBuilder {
  static UserEntity validUser({String? name, String? email}) {
    return UserEntity(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: DateTime.now(),
      stats: defaultStats(),
      preferences: defaultPreferences(),
    );
  }

  static UserEntity invalidUser({String? reason}) {
    switch (reason) {
      case 'empty_name': return validUser(name: '');
      case 'invalid_email': return validUser(email: 'invalid');
      default: return validUser(email: '');
    }
  }
}
```

## 6. Integration with Development Workflow

### Pre-Commit TDD Validation
```bash
# Add to git pre-commit hook
#!/bin/bash
echo "Running TDD validation..."

# Run all tests
if ! flutter test; then
    echo "❌ Tests failing - fix before commit"
    exit 1
fi

# Run architecture compliance tests
if ! flutter test test/architecture/; then
    echo "❌ Architecture violations - fix before commit"
    exit 1
fi

echo "✅ TDD validation passed"
```

### CI/CD Integration
```yaml
# .github/workflows/tdd-validation.yml
name: TDD Validation
on: [push, pull_request]

jobs:
  tdd-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Run TDD Tests
        run: |
          flutter test --coverage
          flutter test test/architecture/
          
      - name: Validate Architecture Compliance
        run: ./scripts/tdd-workflow.sh architecture
        
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

## 7. Performance Testing with TDD

### Load Testing Use Cases
```dart
test('should handle high-frequency user creation', () async {
  final params = CreateUserParams(user: testUser);
  when(mockRepository.createUser(any))
      .thenAnswer((_) async => Result.success(testUser));

  final stopwatch = Stopwatch()..start();
  
  // Create 1000 users concurrently
  final futures = List.generate(1000, 
    (_) => useCase.call(params));
  await Future.wait(futures);
  
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(5000));
  verify(mockRepository.createUser(any)).called(1000);
});
```

### Memory Leak Testing
```dart
test('should not cause memory leaks with repeated calls', () async {
  final params = CreateUserParams(user: testUser);
  when(mockRepository.createUser(any))
      .thenAnswer((_) async => Result.success(testUser));

  // Perform many operations
  for (int i = 0; i < 10000; i++) {
    final result = await useCase.call(params);
    expect(result.isSuccess, isTrue);
  }

  // Memory usage should remain stable
  verify(mockRepository.createUser(any)).called(10000);
});
```

## 8. Real-time Feature TDD

### Stream-based Use Cases
```dart
test('should provide real-time user updates', () async {
  final userStream = Stream.fromIterable([
    Result.success(testUser),
    Result.success(testUser.copyWith(name: 'Updated Name')),
  ]);

  when(mockRepository.watchUser(any))
      .thenAnswer((_) => userStream);

  final streamUseCase = WatchUserUseCase(repository: mockRepository);
  final params = WatchUserParams(userId: testUser.id);

  final results = await streamUseCase.call(params).take(2).toList();

  expect(results, hasLength(2));
  expect(results.every((r) => r.isSuccess), isTrue);
  expect(results.last.data?.name, equals('Updated Name'));
});
```

## 9. Error Recovery Testing

### Network Resilience
```dart
test('should retry failed operations with exponential backoff', () async {
  final params = CreateUserParams(user: testUser);
  
  // First two calls fail, third succeeds
  when(mockRepository.createUser(any))
      .thenAnswer((_) async => Result.failure(networkFailure))
      .thenAnswer((_) async => Result.failure(networkFailure))
      .thenAnswer((_) async => Result.success(testUser));

  final resilientUseCase = ResilientCreateUserUseCase(
    repository: mockRepository,
    maxRetries: 3,
  );

  final result = await resilientUseCase.call(params);

  expect(result.isSuccess, isTrue);
  verify(mockRepository.createUser(any)).called(3);
});
```

## 10. Platform-Specific TDD

### Web-specific Testing
```dart
@TestOn('chrome')
test('should work correctly in web environment', () async {
  // Web-specific test logic
  final params = CreateUserParams(user: testUser);
  final result = await useCase.call(params);
  
  expect(result.isSuccess, isTrue);
});
```

### Mobile-specific Testing
```dart
@TestOn('vm')
test('should work correctly on mobile devices', () async {
  // Mobile-specific test logic
  final params = CreateUserParams(user: testUser);
  final result = await useCase.call(params);
  
  expect(result.isSuccess, isTrue);
});
```

## Summary

This TDD + Clean Architecture integration provides:

1. **Structured TDD Workflow**: RED → GREEN → REFACTOR cycles with automation
2. **Architecture Compliance**: Automated validation of Clean Architecture principles
3. **Comprehensive Testing**: Templates for all architectural layers
4. **Performance Validation**: Load testing and memory leak detection
5. **Real-time Features**: Stream-based TDD patterns
6. **Error Resilience**: Network failure and recovery testing
7. **Platform Coverage**: Web and mobile-specific test scenarios

Use the provided scripts and templates to maintain high code quality while following TDD best practices throughout the development process.