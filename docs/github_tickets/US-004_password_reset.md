# US-004: Password Reset

## User Story
As a registered user, I want to reset my password so that I can regain access if I forget it.

## Acceptance Criteria
- [ ] "Forgot password?" link on login page
- [ ] Dedicated password reset page with email input
- [ ] Email validation before sending reset link
- [ ] Clear success message after email sent
- [ ] Reset email contains secure link
- [ ] Link expires after 24 hours
- [ ] Password reset form with new password and confirmation
- [ ] Password requirements enforced (same as registration)
- [ ] Auto-login after successful reset
- [ ] Clear error messages for all failure cases
- [ ] Rate limiting (max 3 requests per hour)
- [ ] Works on all platforms (web, iOS, Android)

## Navigation Flow

### Current State
```
/forgot-password page exists but not integrated
No deep link handling for reset tokens
No post-reset flow
```

### Required Implementation
```
1. Password Reset Request Flow:
   /login → "Forgot password?" → /forgot-password
   ├── Enter email
   ├── Validate email exists
   ├── Send reset email via Firebase
   ├── Show success message
   └── Offer to go back to login

2. Email Reset Link Flow:
   Email link → App deep link handler
   ├── Validate reset code
   ├── Navigate to /reset-password?code=XXX
   ├── Enter new password
   ├── Confirm password
   ├── Update in Firebase
   └── Auto-login → /home

3. Error Flows:
   - Invalid/expired link → /forgot-password with error
   - User not found → Generic "check email" message
   - Rate limited → Show cooldown timer
```

## Technical Implementation

### 1. Update Forgot Password Page
```dart
// lib/features/authentication/presentation/pages/forgot_password_page.dart

class ForgotPasswordPage extends ConsumerStatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    if (_emailSent) {
      return _buildSuccessScreen();
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_reset, size: 80),
              const SizedBox(height: 24),
              Text(
                'Forgot your password?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email and we\'ll send you a link to reset your password.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: EmailValidator.validate,
                enabled: !authState.isLoading,
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: authState.isLoading ? null : _sendResetEmail,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Send Reset Link'),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuccessScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Check your email!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a password reset link to:\n${_emailController.text}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: _sendResetEmail,
                child: const Text('Resend Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check rate limiting
    final canSend = await _checkRateLimit();
    if (!canSend) {
      _showRateLimitError();
      return;
    }
    
    final result = await ref
        .read(authRepositoryProvider)
        .sendPasswordResetEmail(_emailController.text);
    
    result.fold(
      (failure) => _showError(failure),
      (_) => setState(() => _emailSent = true),
    );
  }
}
```

### 2. Password Reset Repository Method
```dart
// lib/features/authentication/data/repositories/authentication_repository_impl.dart

Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
  try {
    // Configure action code settings for deep linking
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://yourapp.com/reset-password',
      handleCodeInApp: true,
      iOSBundleId: 'com.yourcompany.quizapp',
      androidPackageName: 'com.yourcompany.quizapp',
      androidInstallApp: true,
      androidMinimumVersion: '1',
    );
    
    await _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
    
    // Log reset attempt for rate limiting
    await _logResetAttempt(email);
    
    return const Right(null);
  } on FirebaseAuthException catch (e) {
    return Left(_handleResetError(e));
  }
}

AuthFailure _handleResetError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      // Don't reveal if user exists
      return const AuthFailure.generic(
        'If an account exists, a reset link has been sent',
      );
    case 'invalid-email':
      return const AuthFailure.invalidEmail();
    case 'too-many-requests':
      return const AuthFailure.tooManyRequests();
    default:
      return AuthFailure.generic(e.message ?? 'Reset failed');
  }
}
```

### 3. Deep Link Handler
```dart
// lib/core/navigation/deep_link_handler.dart

class DeepLinkHandler {
  static Future<String?> handlePasswordResetLink(Uri uri) async {
    final code = uri.queryParameters['oobCode'];
    final mode = uri.queryParameters['mode'];
    
    if (mode == 'resetPassword' && code != null) {
      // Verify code is valid
      try {
        await FirebaseAuth.instance.verifyPasswordResetCode(code);
        return '/reset-password?code=$code';
      } catch (e) {
        return '/forgot-password?error=invalid_link';
      }
    }
    
    return null;
  }
}
```

### 4. Reset Password Page (New)
```dart
// lib/features/authentication/presentation/pages/reset_password_page.dart

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String resetCode;
  
  const ResetPasswordPage({
    Key? key,
    required this.resetCode,
  }) : super(key: key);
  
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 80),
              const SizedBox(height: 24),
              Text(
                'Create a new password',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: PasswordValidator.validate,
                enabled: !authState.isLoading,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                enabled: !authState.isLoading,
              ),
              
              const SizedBox(height: 8),
              
              const PasswordRequirements(),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: authState.isLoading ? null : _resetPassword,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      // Confirm password reset with new password
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.resetCode,
        newPassword: _passwordController.text,
      );
      
      // Auto-login with new password
      final email = await _getEmailFromResetCode();
      if (email != null) {
        await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
          email,
          _passwordController.text,
        );
      }
      
      // Navigate to home
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successful!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      _showError(e);
    }
  }
}
```

### 5. Rate Limiting Service
```dart
// lib/features/authentication/data/services/rate_limit_service.dart

class RateLimitService {
  final SharedPreferences _prefs;
  
  static const _resetAttemptsKey = 'password_reset_attempts';
  static const _maxAttempts = 3;
  static const _windowHours = 1;
  
  Future<bool> canSendResetEmail(String email) async {
    final attempts = _getResetAttempts();
    final now = DateTime.now();
    
    // Remove old attempts
    attempts.removeWhere((attempt) {
      final attemptTime = DateTime.parse(attempt['timestamp']);
      return now.difference(attemptTime).inHours >= _windowHours;
    });
    
    // Check if email has too many recent attempts
    final emailAttempts = attempts.where((a) => a['email'] == email).length;
    
    return emailAttempts < _maxAttempts;
  }
  
  Future<Duration?> getTimeUntilNextAttempt(String email) async {
    final attempts = _getResetAttempts()
        .where((a) => a['email'] == email)
        .toList();
    
    if (attempts.length < _maxAttempts) return null;
    
    // Find oldest attempt in window
    attempts.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    final oldestTime = DateTime.parse(attempts.first['timestamp']);
    final nextAllowedTime = oldestTime.add(Duration(hours: _windowHours));
    
    return nextAllowedTime.difference(DateTime.now());
  }
  
  Future<void> logResetAttempt(String email) async {
    final attempts = _getResetAttempts();
    attempts.add({
      'email': email,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _prefs.setString(_resetAttemptsKey, jsonEncode(attempts));
  }
}
```

### 6. Router Configuration
```dart
// lib/core/navigation/app_router.dart

// Add reset password route
GoRoute(
  path: 'reset-password',
  name: RouteNames.resetPassword,
  builder: (context, state) {
    final code = state.uri.queryParameters['code'];
    if (code == null) {
      return const ErrorPage(message: 'Invalid reset link');
    }
    return ResetPasswordPage(resetCode: code);
  },
),

// Update deep link handling
onDeepLink: (uri) async {
  final route = await DeepLinkHandler.handlePasswordResetLink(uri);
  if (route != null) {
    router.go(route);
  }
},
```

## Email Template

### Reset Email Content
```html
Subject: Reset your Quiz App password

Hi there,

You requested to reset your password for Quiz App. Click the link below to create a new password:

[Reset Password Button]

This link will expire in 24 hours. If you didn't request this, you can safely ignore this email.

If you're having trouble with the button, copy and paste this link:
{{reset_link}}

Thanks,
The Quiz App Team
```

## Security Considerations

### Rate Limiting
- Maximum 3 reset attempts per email per hour
- Track attempts in local storage
- Show remaining cooldown time

### Link Security
- Single-use reset codes
- 24-hour expiration
- HTTPS-only reset links
- Verify code before showing reset form

### Password Requirements
- Same as registration (8+ chars, uppercase, number, special)
- Cannot reuse recent passwords (Firebase handles this)
- Force re-authentication for sensitive changes

## Testing Requirements

### Unit Tests
- [ ] Email validation
- [ ] Rate limiting logic
- [ ] Password validation
- [ ] Deep link parsing

### Integration Tests
- [ ] Send reset email flow
- [ ] Reset password with valid code
- [ ] Handle expired/invalid codes
- [ ] Rate limiting enforcement
- [ ] Auto-login after reset

### E2E Tests
- [ ] Complete reset flow from login
- [ ] Deep link handling on all platforms
- [ ] Error handling for edge cases
- [ ] Success message and redirect

## Error Messages

```dart
const resetErrors = {
  'expired_link': 'This reset link has expired. Please request a new one.',
  'invalid_link': 'This reset link is invalid. Please request a new one.',
  'user_not_found': 'If an account exists, a reset email has been sent.',
  'rate_limited': 'Too many attempts. Please try again later.',
  'network_error': 'Connection error. Please check your internet.',
};
```

## Related Issues
- Depends on: Email configuration in Firebase
- Related: US-001 (Sign up)
- Related: US-005 (Email verification)
- Enhances: Account recovery

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Deep linking configured for all platforms
- [ ] Rate limiting implemented
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Email template configured
- [ ] Code reviewed and approved
- [ ] Security review completed