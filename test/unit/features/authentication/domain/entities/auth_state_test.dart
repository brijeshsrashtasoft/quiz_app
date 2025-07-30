import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import '../../../../../test_config.dart';
import '../helpers/auth_domain_test_helpers.dart';

/// Comprehensive unit tests for AuthState domain entity
/// Following TDD principles and CLAUDE.md testing patterns
/// Covers: All states, extensions, equality, edge cases
void main() {
  testGroup('AuthState', TestCategory.unit, () {
    late UserEntity testUser;

    setUpAll(() {
      testUser = AuthDomainTestHelpers.createTestUserEntity(
        id: 'test-user-123',
        name: 'Test User',
        email: 'test@example.com',
      );
    });

    group('State Creation', () {
      testCase('should create authenticated state', TestCategory.unit, () {
        // Act
        final state = AuthState.authenticated(user: testUser);

        // Assert
        expect(state, isA<AuthenticatedState>());
        state.when(
          authenticated: (user) {
            expect(user, equals(testUser));
          },
          unauthenticated: () => fail('Should not be unauthenticated'),
          loading: () => fail('Should not be loading'),
          error: (_, __) => fail('Should not be error'),
        );
      });

      testCase('should create unauthenticated state', TestCategory.unit, () {
        // Act
        final state = AuthState.unauthenticated();

        // Assert
        expect(state, isA<UnauthenticatedState>());
        state.when(
          authenticated: (_) => fail('Should not be authenticated'),
          unauthenticated: () => expect(true, isTrue),
          loading: () => fail('Should not be loading'),
          error: (_, __) => fail('Should not be error'),
        );
      });

      testCase('should create loading state', TestCategory.unit, () {
        // Act
        final state = AuthState.loading();

        // Assert
        expect(state, isA<LoadingAuthState>());
        state.when(
          authenticated: (_) => fail('Should not be authenticated'),
          unauthenticated: () => fail('Should not be unauthenticated'),
          loading: () => expect(true, isTrue),
          error: (_, __) => fail('Should not be error'),
        );
      });

      testCase(
        'should create error state with message only',
        TestCategory.unit,
        () {
          // Arrange
          const errorMessage = 'Authentication failed';

          // Act
          final state = AuthState.error(message: errorMessage);

          // Assert
          expect(state, isA<ErrorAuthState>());
          state.when(
            authenticated: (_) => fail('Should not be authenticated'),
            unauthenticated: () => fail('Should not be unauthenticated'),
            loading: () => fail('Should not be loading'),
            error: (message, code) {
              expect(message, equals(errorMessage));
              expect(code, isNull);
            },
          );
        },
      );

      testCase(
        'should create error state with message and code',
        TestCategory.unit,
        () {
          // Arrange
          const errorMessage = 'Invalid credentials';
          const errorCode = 'AUTH_INVALID_CREDENTIALS';

          // Act
          final state = AuthState.error(message: errorMessage, code: errorCode);

          // Assert
          expect(state, isA<ErrorAuthState>());
          state.when(
            authenticated: (_) => fail('Should not be authenticated'),
            unauthenticated: () => fail('Should not be unauthenticated'),
            loading: () => fail('Should not be loading'),
            error: (message, code) {
              expect(message, equals(errorMessage));
              expect(code, equals(errorCode));
            },
          );
        },
      );
    });

    group('State Equality and Hash Code', () {
      testCase(
        'should have equal authenticated states with same user',
        TestCategory.unit,
        () {
          // Arrange
          final state1 = AuthState.authenticated(user: testUser);
          final state2 = AuthState.authenticated(user: testUser);

          // Assert
          expect(state1, equals(state2));
          expect(state1.hashCode, equals(state2.hashCode));
        },
      );

      testCase(
        'should have equal unauthenticated states',
        TestCategory.unit,
        () {
          // Arrange
          final state1 = AuthState.unauthenticated();
          final state2 = AuthState.unauthenticated();

          // Assert
          expect(state1, equals(state2));
          expect(state1.hashCode, equals(state2.hashCode));
        },
      );

      testCase('should have equal loading states', TestCategory.unit, () {
        // Arrange
        final state1 = AuthState.loading();
        final state2 = AuthState.loading();

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      testCase(
        'should have equal error states with same message and code',
        TestCategory.unit,
        () {
          // Arrange
          final state1 = AuthState.error(message: 'Error', code: 'CODE');
          final state2 = AuthState.error(message: 'Error', code: 'CODE');

          // Assert
          expect(state1, equals(state2));
          expect(state1.hashCode, equals(state2.hashCode));
        },
      );

      testCase('should not be equal when states differ', TestCategory.unit, () {
        // Arrange
        final authenticatedState = AuthState.authenticated(user: testUser);
        final unauthenticatedState = AuthState.unauthenticated();
        final loadingState = AuthState.loading();
        final errorState = AuthState.error(message: 'Error');

        final states = [
          authenticatedState,
          unauthenticatedState,
          loadingState,
          errorState,
        ];

        // Assert
        for (int i = 0; i < states.length; i++) {
          for (int j = i + 1; j < states.length; j++) {
            expect(states[i], isNot(equals(states[j])));
            expect(states[i].hashCode, isNot(equals(states[j].hashCode)));
          }
        }
      });

      testCase(
        'should not be equal when users differ in authenticated state',
        TestCategory.unit,
        () {
          // Arrange
          final otherUser = AuthDomainTestHelpers.createTestUserEntity(
            id: 'other-user-456',
            name: 'Other User',
            email: 'other@example.com',
          );

          final state1 = AuthState.authenticated(user: testUser);
          final state2 = AuthState.authenticated(user: otherUser);

          // Assert
          expect(state1, isNot(equals(state2)));
          expect(state1.hashCode, isNot(equals(state2.hashCode)));
        },
      );

      testCase(
        'should not be equal when error messages differ',
        TestCategory.unit,
        () {
          // Arrange
          final state1 = AuthState.error(message: 'Error 1');
          final state2 = AuthState.error(message: 'Error 2');

          // Assert
          expect(state1, isNot(equals(state2)));
          expect(state1.hashCode, isNot(equals(state2.hashCode)));
        },
      );
    });

    group('Extension Methods - Boolean Checks', () {
      group('isAuthenticated', () {
        testCase(
          'should return true for authenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.authenticated(user: testUser);

            // Assert
            expect(state.isAuthenticated, isTrue);
          },
        );

        testCase(
          'should return false for unauthenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.unauthenticated();

            // Assert
            expect(state.isAuthenticated, isFalse);
          },
        );

        testCase(
          'should return false for loading state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.loading();

            // Assert
            expect(state.isAuthenticated, isFalse);
          },
        );

        testCase('should return false for error state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.error(message: 'Error');

          // Assert
          expect(state.isAuthenticated, isFalse);
        });
      });

      group('isUnauthenticated', () {
        testCase(
          'should return false for authenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.authenticated(user: testUser);

            // Assert
            expect(state.isUnauthenticated, isFalse);
          },
        );

        testCase(
          'should return true for unauthenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.unauthenticated();

            // Assert
            expect(state.isUnauthenticated, isTrue);
          },
        );

        testCase(
          'should return false for loading state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.loading();

            // Assert
            expect(state.isUnauthenticated, isFalse);
          },
        );

        testCase('should return false for error state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.error(message: 'Error');

          // Assert
          expect(state.isUnauthenticated, isFalse);
        });
      });

      group('isLoading', () {
        testCase(
          'should return false for authenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.authenticated(user: testUser);

            // Assert
            expect(state.isLoading, isFalse);
          },
        );

        testCase(
          'should return false for unauthenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.unauthenticated();

            // Assert
            expect(state.isLoading, isFalse);
          },
        );

        testCase('should return true for loading state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.loading();

          // Assert
          expect(state.isLoading, isTrue);
        });

        testCase('should return false for error state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.error(message: 'Error');

          // Assert
          expect(state.isLoading, isFalse);
        });
      });

      group('hasError', () {
        testCase(
          'should return false for authenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.authenticated(user: testUser);

            // Assert
            expect(state.hasError, isFalse);
          },
        );

        testCase(
          'should return false for unauthenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.unauthenticated();

            // Assert
            expect(state.hasError, isFalse);
          },
        );

        testCase(
          'should return false for loading state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.loading();

            // Assert
            expect(state.hasError, isFalse);
          },
        );

        testCase('should return true for error state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.error(message: 'Error');

          // Assert
          expect(state.hasError, isTrue);
        });
      });
    });

    group('Extension Methods - Data Access', () {
      group('user getter', () {
        testCase(
          'should return user for authenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.authenticated(user: testUser);

            // Assert
            expect(state.user, equals(testUser));
          },
        );

        testCase(
          'should return null for unauthenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.unauthenticated();

            // Assert
            expect(state.user, isNull);
          },
        );

        testCase('should return null for loading state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.loading();

          // Assert
          expect(state.user, isNull);
        });

        testCase('should return null for error state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.error(message: 'Error');

          // Assert
          expect(state.user, isNull);
        });
      });

      group('errorMessage getter', () {
        testCase(
          'should return null for authenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.authenticated(user: testUser);

            // Assert
            expect(state.errorMessage, isNull);
          },
        );

        testCase(
          'should return null for unauthenticated state',
          TestCategory.unit,
          () {
            // Arrange
            final state = AuthState.unauthenticated();

            // Assert
            expect(state.errorMessage, isNull);
          },
        );

        testCase('should return null for loading state', TestCategory.unit, () {
          // Arrange
          final state = AuthState.loading();

          // Assert
          expect(state.errorMessage, isNull);
        });

        testCase(
          'should return error message for error state',
          TestCategory.unit,
          () {
            // Arrange
            const errorMessage = 'Authentication failed';
            final state = AuthState.error(message: errorMessage);

            // Assert
            expect(state.errorMessage, equals(errorMessage));
          },
        );
      });
    });

    group('Copy With and Immutability', () {
      testCase(
        'should support copyWith for authenticated state',
        TestCategory.unit,
        () {
          // Arrange
          final originalState = AuthState.authenticated(user: testUser) as AuthenticatedState;
          final newUser = AuthDomainTestHelpers.createTestUserEntity(
            id: 'new-user-456',
            name: 'New User',
            email: 'new@example.com',
          );

          // Act
          final copiedState = originalState.copyWith(user: newUser);

          // Assert
          expect(copiedState, isA<AuthenticatedState>());
          expect(copiedState.user, equals(newUser));
          expect(originalState.user, equals(testUser)); // Original unchanged
        },
      );

      testCase(
        'should support copyWith for error state',
        TestCategory.unit,
        () {
          // Arrange
          final originalState = AuthState.error(
            message: 'Original error',
            code: 'ORIG_CODE',
          ) as ErrorAuthState;

          // Act
          final copiedState = originalState.copyWith(
            message: 'New error message',
            code: 'NEW_CODE',
          );

          // Assert
          expect(copiedState, isA<ErrorAuthState>());
          expect(copiedState.errorMessage, equals('New error message'));
          copiedState.when(
            authenticated: (_) => fail('Should not be authenticated'),
            unauthenticated: () => fail('Should not be unauthenticated'),
            loading: () => fail('Should not be loading'),
            error: (message, code) {
              expect(message, equals('New error message'));
              expect(code, equals('NEW_CODE'));
            },
          );
        },
      );
    });

    group('Edge Cases and Error Handling', () {
      testCase('should handle empty error message', TestCategory.unit, () {
        // Act & Assert - Should not throw
        expect(() => AuthState.error(message: ''), returnsNormally);

        final state = AuthState.error(message: '');
        expect(state.errorMessage, equals(''));
      });

      testCase('should handle very long error message', TestCategory.unit, () {
        // Arrange
        final longMessage = 'Error: ' + 'a' * 1000;

        // Act & Assert - Should not throw
        expect(() => AuthState.error(message: longMessage), returnsNormally);

        final state = AuthState.error(message: longMessage);
        expect(state.errorMessage, equals(longMessage));
      });

      testCase(
        'should handle special characters in error message',
        TestCategory.unit,
        () {
          // Arrange
          const specialMessage = 'Error: 특수문자 éñ 中文 🚫 @#\$%^&*()';

          // Act & Assert - Should not throw
          expect(
            () => AuthState.error(message: specialMessage),
            returnsNormally,
          );

          final state = AuthState.error(message: specialMessage);
          expect(state.errorMessage, equals(specialMessage));
        },
      );

      testCase('should handle null code in error state', TestCategory.unit, () {
        // Act & Assert - Should not throw
        expect(
          () => AuthState.error(message: 'Error', code: null),
          returnsNormally,
        );

        final state = AuthState.error(message: 'Error', code: null);
        state.when(
          authenticated: (_) => fail('Should not be authenticated'),
          unauthenticated: () => fail('Should not be unauthenticated'),
          loading: () => fail('Should not be loading'),
          error: (message, code) {
            expect(message, equals('Error'));
            expect(code, isNull);
          },
        );
      });
    });

    group('State Transitions and Patterns', () {
      testCase(
        'should represent typical loading to authenticated flow',
        TestCategory.unit,
        () {
          // Arrange
          final states = [
            AuthState.loading(),
            AuthState.authenticated(user: testUser),
          ];

          // Assert - Each state should be valid
          expect(states[0].isLoading, isTrue);
          expect(states[1].isAuthenticated, isTrue);
          expect(states[1].user, equals(testUser));
        },
      );

      testCase(
        'should represent typical loading to error flow',
        TestCategory.unit,
        () {
          // Arrange
          final states = [
            AuthState.loading(),
            AuthState.error(message: 'Sign in failed'),
          ];

          // Assert - Each state should be valid
          expect(states[0].isLoading, isTrue);
          expect(states[1].hasError, isTrue);
          expect(states[1].errorMessage, equals('Sign in failed'));
        },
      );

      testCase(
        'should represent typical authenticated to unauthenticated flow',
        TestCategory.unit,
        () {
          // Arrange
          final states = [
            AuthState.authenticated(user: testUser),
            AuthState.loading(), // Optional loading during sign out
            AuthState.unauthenticated(),
          ];

          // Assert - Each state should be valid
          expect(states[0].isAuthenticated, isTrue);
          expect(states[1].isLoading, isTrue);
          expect(states[2].isUnauthenticated, isTrue);
        },
      );
    });

    group('toString and Debugging', () {
      testCase(
        'should have meaningful toString for authenticated state',
        TestCategory.unit,
        () {
          // Arrange
          final state = AuthState.authenticated(user: testUser);

          // Act
          final toString = state.toString();

          // Assert
          expect(toString, contains('AuthState.authenticated'));
          expect(toString, contains('user'));
        },
      );

      testCase(
        'should have meaningful toString for unauthenticated state',
        TestCategory.unit,
        () {
          // Arrange
          final state = AuthState.unauthenticated();

          // Act
          final toString = state.toString();

          // Assert
          expect(toString, contains('AuthState.unauthenticated'));
        },
      );

      testCase(
        'should have meaningful toString for loading state',
        TestCategory.unit,
        () {
          // Arrange
          final state = AuthState.loading();

          // Act
          final toString = state.toString();

          // Assert
          expect(toString, contains('AuthState.loading'));
        },
      );

      testCase(
        'should have meaningful toString for error state',
        TestCategory.unit,
        () {
          // Arrange
          final state = AuthState.error(
            message: 'Test error',
            code: 'TEST_ERROR',
          );

          // Act
          final toString = state.toString();

          // Assert
          expect(toString, contains('AuthState.error'));
          expect(toString, contains('message'));
          expect(toString, contains('code'));
        },
      );
    });

    group('Performance and Memory', () {
      testCase(
        'should not create memory leaks with repeated state creation',
        TestCategory.unit,
        () {
          // Act - Create many states
          final states = List.generate(1000, (index) {
            switch (index % 4) {
              case 0:
                return AuthState.authenticated(user: testUser);
              case 1:
                return AuthState.unauthenticated();
              case 2:
                return AuthState.loading();
              case 3:
                return AuthState.error(message: 'Error $index');
              default:
                return AuthState.loading();
            }
          });

          // Assert - Should complete without issues
          expect(states.length, equals(1000));
          expect(states.first, isA<AuthenticatedState>());
          expect(states.last, isA<ErrorAuthState>());
        },
      );

      testCase(
        'should handle rapid state changes efficiently',
        TestCategory.unit,
        () {
          // Arrange
          final stopwatch = Stopwatch()..start();

          // Act - Rapid state transitions
          var currentState = AuthState.unauthenticated();
          for (int i = 0; i < 100; i++) {
            currentState = AuthState.loading();
            currentState = AuthState.authenticated(user: testUser);
            currentState = AuthState.unauthenticated();
          }

          stopwatch.stop();

          // Assert - Should complete quickly
          expect(stopwatch.elapsedMilliseconds, lessThan(100));
          expect(currentState.isUnauthenticated, isTrue);
        },
      );
    });
  });
}
