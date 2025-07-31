# US-001: Email/Password Sign Up

## User Story
As a new user, I want to sign up with email/password so that I can save my progress and create quizzes.

## Acceptance Criteria
- [ ] User can access registration from login page
- [ ] User can access registration from home page when not authenticated
- [ ] Email validation (proper format, not already registered)
- [ ] Password requirements (min 8 chars, 1 uppercase, 1 number, 1 special char)
- [ ] Password confirmation field matches
- [ ] Display name required (3-20 characters)
- [ ] Success redirects to email verification prompt
- [ ] Errors show clear, actionable messages
- [ ] Loading states during registration
- [ ] Account created in Firebase Auth
- [ ] User profile created in Firestore

## Navigation Flow

### Current State
```
/splash → /home (no auth check)
/register exists but not integrated into main flow
```

### Required Implementation
```
1. Entry Points:
   - /home → "Sign Up" button → /register
   - /login → "Create account" link → /register
   - /game/join → Post-game prompt → /register
   
2. Registration Flow:
   /register (RegisterPage)
   ├── Form Submission
   ├── Firebase Auth createUserWithEmailAndPassword
   ├── Create Firestore user document
   ├── Send verification email
   └── Navigate to /register/verify-email

3. Post-Registration:
   /register/verify-email (new screen)
   ├── Show "Check your email" message
   ├── Resend email button
   ├── "I've verified" button → /home (authenticated)
   └── Skip for now → /home (unverified user)
```

## Technical Implementation

### 1. Update Router Configuration
```dart
// lib/core/navigation/app_router.dart

// Add new route
GoRoute(
  path: 'verify-email',
  name: RouteNames.verifyEmail,
  builder: (context, state) => const EmailVerificationPage(),
),
```

### 2. Enable Auth Guards
```dart
// Re-enable redirect logic (currently commented out)
redirect: (context, state) async {
  final authGuard = guards[state.fullPath];
  if (authGuard != null) {
    return authGuard.canActivate(context, state);
  }
  return null;
},
```

### 3. Update RegisterPage Navigation
```dart
// lib/features/authentication/presentation/pages/register_page.dart

// After successful registration:
void _handleRegistrationSuccess() async {
  // Create user profile in Firestore
  await _createUserProfile();
  
  // Send verification email
  await user.sendEmailVerification();
  
  // Navigate to verification page
  context.go('/register/verify-email');
}
```

### 4. Update Home Page
```dart
// lib/features/home/presentation/pages/home_page.dart

// Add sign up button for unauthenticated users
if (!isAuthenticated) {
  ElevatedButton(
    onPressed: () => context.go('/register'),
    child: Text('Sign Up'),
  ),
}
```

### 5. Create User Profile Service
```dart
// lib/features/authentication/domain/services/user_profile_service.dart

Future<void> createUserProfile(User firebaseUser) async {
  final profile = UserProfile(
    uid: firebaseUser.uid,
    email: firebaseUser.email!,
    displayName: displayNameController.text,
    createdAt: FieldValue.serverTimestamp(),
    stats: UserStats.initial(),
    preferences: UserPreferences.defaults(),
  );
  
  await FirebaseFirestore.instance
    .collection('users')
    .doc(firebaseUser.uid)
    .set(profile.toJson());
}
```

## Validation Rules

### Email Validation
- Valid email format (regex: `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`)
- Not already registered (check Firebase Auth)
- Domain not in blocked list (optional)

### Password Requirements
```dart
class PasswordValidator {
  static const minLength = 8;
  static final hasUpperCase = RegExp(r'[A-Z]');
  static final hasDigit = RegExp(r'[0-9]');
  static final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  
  static String? validate(String password) {
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!hasUpperCase.hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }
    if (!hasDigit.hasMatch(password)) {
      return 'Password must contain a number';
    }
    if (!hasSpecialChar.hasMatch(password)) {
      return 'Password must contain a special character';
    }
    return null;
  }
}
```

### Display Name Validation
- 3-20 characters
- Alphanumeric + spaces only
- No offensive words (basic filter)
- Trimmed of whitespace

## Error Handling

### Firebase Auth Errors
```dart
switch (e.code) {
  case 'email-already-in-use':
    return 'An account already exists with this email';
  case 'invalid-email':
    return 'Please enter a valid email address';
  case 'operation-not-allowed':
    return 'Email/password accounts are not enabled';
  case 'weak-password':
    return 'Please choose a stronger password';
  default:
    return 'Registration failed. Please try again';
}
```

## Testing Requirements

### Unit Tests
- [ ] Email validation logic
- [ ] Password validation logic
- [ ] Display name validation
- [ ] Error message mapping

### Integration Tests
- [ ] Complete registration flow
- [ ] Firebase Auth account creation
- [ ] Firestore profile creation
- [ ] Email verification sending
- [ ] Navigation to verification page

### E2E Tests
- [ ] User can register from home page
- [ ] User can register from login page
- [ ] Validation errors display correctly
- [ ] Successful registration redirects properly
- [ ] User profile accessible after registration

## Dependencies
- Firebase Auth configured
- Firestore database rules updated
- Email verification templates configured
- Auth guards re-enabled in router

## Related Issues
- Depends on: Auth guards re-enablement
- Blocks: US-005 (Email verification)
- Related: US-002 (Google sign-in)

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Code reviewed and approved
- [ ] No linting errors
- [ ] Documentation updated
- [ ] Works on Web, iOS, and Android