import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';

/// Security settings panel with comprehensive security preferences
/// Follows Kahoot-style design with security-focused UX patterns
/// Reference: docs/ui_guideline.md
class SecuritySettingsPanel extends StatefulWidget {
  final SecuritySettings settings;
  final ValueChanged<SecuritySettings> onSettingsChanged;

  const SecuritySettingsPanel({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SecuritySettingsPanel> createState() => _SecuritySettingsPanelState();
}

class _SecuritySettingsPanelState extends State<SecuritySettingsPanel> {
  late SecuritySettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  void _updateSetting(SecuritySettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Two-Factor Authentication Section
          _buildSectionHeader(
            'Two-Factor Authentication',
            'Add an extra layer of security to your account',
            Icons.security,
          ),
          SizedBox(height: AppSpacing.spacingM),
          _buildTwoFactorAuthCard(),
          SizedBox(height: AppSpacing.spacingXL),

          // Biometric Authentication Section
          _buildSectionHeader(
            'Biometric Authentication',
            'Use fingerprint or face recognition for quick access',
            Icons.fingerprint,
          ),
          SizedBox(height: AppSpacing.spacingM),
          _buildBiometricAuthCard(),
          SizedBox(height: AppSpacing.spacingXL),

          // Password Security Section
          _buildSectionHeader(
            'Password Security',
            'Manage your password requirements and policies',
            Icons.lock,
          ),
          SizedBox(height: AppSpacing.spacingM),
          _buildPasswordSecurityCard(),
          SizedBox(height: AppSpacing.spacingXL),

          // Session Management Section
          _buildSectionHeader(
            'Session Management',
            'Control how long you stay signed in',
            Icons.access_time,
          ),
          SizedBox(height: AppSpacing.spacingM),
          _buildSessionManagementCard(),
          SizedBox(height: AppSpacing.spacingXL),

          // Account Security Section
          _buildSectionHeader(
            'Account Security',
            'Additional security measures for your account',
            Icons.shield,
          ),
          SizedBox(height: AppSpacing.spacingM),
          _buildAccountSecurityCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.spacingS),
          decoration: BoxDecoration(
            color: AppColors.vibrantPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.vibrantPurple, size: 24),
        ),
        SizedBox(width: AppSpacing.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.spacingXS),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTwoFactorAuthCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: AppSpacing.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Factor Authentication',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        _currentSettings.twoFactorEnabled
                            ? 'Enabled with ${_currentSettings.twoFactorMethod.name}'
                            : 'Disabled',
                        style: AppTextStyles.caption.copyWith(
                          color: _currentSettings.twoFactorEnabled
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _currentSettings.twoFactorEnabled,
                  onChanged: (value) {
                    _updateSetting(
                      _currentSettings.copyWith(twoFactorEnabled: value),
                    );
                  },
                  activeColor: AppColors.vibrantPurple,
                ),
              ],
            ),

            if (_currentSettings.twoFactorEnabled) ...[
              SizedBox(height: AppSpacing.spacingM),
              Divider(color: AppColors.lightGray),
              SizedBox(height: AppSpacing.spacingM),

              // Two-factor method selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Authentication Method',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.spacingS),

                  ...TwoFactorMethod.values.map(
                    (method) => _buildTwoFactorMethodTile(method),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.spacingM),

              // Setup/manage button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle 2FA setup/management
                  },
                  icon: Icon(Icons.settings, size: 18),
                  label: Text(
                    _currentSettings.twoFactorEnabled
                        ? 'Manage 2FA'
                        : 'Setup 2FA',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.vibrantPurple,
                    side: BorderSide(color: AppColors.vibrantPurple),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.spacingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.buttonRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorMethodTile(TwoFactorMethod method) {
    final isSelected = _currentSettings.twoFactorMethod == method;

    return InkWell(
      onTap: () {
        _updateSetting(_currentSettings.copyWith(twoFactorMethod: method));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingS,
        ),
        margin: EdgeInsets.only(bottom: AppSpacing.spacingS),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.vibrantPurple.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.vibrantPurple : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getTwoFactorMethodIcon(method),
              color: isSelected
                  ? AppColors.vibrantPurple
                  : AppColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: Text(
                _getTwoFactorMethodName(method),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.vibrantPurple,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricAuthCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: AppSpacing.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biometric Login',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        _currentSettings.biometricEnabled
                            ? 'Quick access enabled'
                            : 'Use PIN/Password only',
                        style: AppTextStyles.caption.copyWith(
                          color: _currentSettings.biometricEnabled
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _currentSettings.biometricEnabled,
                  onChanged: (value) {
                    _updateSetting(
                      _currentSettings.copyWith(biometricEnabled: value),
                    );
                  },
                  activeColor: AppColors.vibrantPurple,
                ),
              ],
            ),

            if (_currentSettings.biometricEnabled) ...[
              SizedBox(height: AppSpacing.spacingM),
              Container(
                width: double.infinity,
                padding: AppSpacing.allS,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppSpacing.spacingS),
                    Text(
                      'Biometric authentication is set up',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSecurityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: AppSpacing.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Requirements',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.spacingM),

            // Password strength requirements
            _buildPasswordRequirement(
              'Minimum 8 characters',
              _currentSettings.passwordMinLength >= 8,
            ),
            _buildPasswordRequirement(
              'Include uppercase letters',
              _currentSettings.requireUppercase,
            ),
            _buildPasswordRequirement(
              'Include lowercase letters',
              _currentSettings.requireLowercase,
            ),
            _buildPasswordRequirement(
              'Include numbers',
              _currentSettings.requireNumbers,
            ),
            _buildPasswordRequirement(
              'Include special characters',
              _currentSettings.requireSpecialChars,
            ),
            SizedBox(height: AppSpacing.spacingM),

            // Password expiry
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Expiry',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        _currentSettings.passwordExpiryEnabled
                            ? 'Every ${_currentSettings.passwordExpiryDays} days'
                            : 'Never expires',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _currentSettings.passwordExpiryEnabled,
                  onChanged: (value) {
                    _updateSetting(
                      _currentSettings.copyWith(passwordExpiryEnabled: value),
                    );
                  },
                  activeColor: AppColors.vibrantPurple,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.spacingM),

            // Change password button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle password change
                },
                icon: Icon(Icons.lock_reset, size: 18),
                label: Text('Change Password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vibrantPurple,
                  side: BorderSide(color: AppColors.vibrantPurple),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isEnabled) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.spacingS),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isEnabled ? AppColors.success : AppColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: AppSpacing.spacingS),
          Text(
            requirement,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionManagementCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: AppSpacing.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Timeout',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.spacingS),
            Text(
              'Automatically sign out after: ${_formatDuration(_currentSettings.sessionTimeout)}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.spacingM),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Show session timeout picker
                },
                icon: Icon(Icons.timer, size: 18),
                label: Text('Change Timeout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vibrantPurple,
                  side: BorderSide(color: AppColors.vibrantPurple),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSecurityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: AppSpacing.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Security',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.spacingM),

            // Login notifications
            _buildSecurityToggle(
              'Login Notifications',
              'Get notified of new sign-ins',
              _currentSettings.loginNotificationsEnabled,
              (value) => _updateSetting(
                _currentSettings.copyWith(loginNotificationsEnabled: value),
              ),
            ),

            // Suspicious activity alerts
            _buildSecurityToggle(
              'Suspicious Activity Alerts',
              'Get alerted to unusual account activity',
              _currentSettings.suspiciousActivityAlertsEnabled,
              (value) => _updateSetting(
                _currentSettings.copyWith(
                  suspiciousActivityAlertsEnabled: value,
                ),
              ),
            ),

            // Account lockout
            _buildSecurityToggle(
              'Account Lockout Protection',
              'Lock account after failed login attempts',
              _currentSettings.accountLockoutEnabled,
              (value) => _updateSetting(
                _currentSettings.copyWith(accountLockoutEnabled: value),
              ),
            ),

            if (_currentSettings.accountLockoutEnabled) ...[
              SizedBox(height: AppSpacing.spacingS),
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.spacingXL),
                child: Text(
                  'Lock after ${_currentSettings.maxFailedAttempts} failed attempts',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.spacingXS),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.vibrantPurple,
          ),
        ],
      ),
    );
  }

  IconData _getTwoFactorMethodIcon(TwoFactorMethod method) {
    switch (method) {
      case TwoFactorMethod.sms:
        return Icons.sms;
      case TwoFactorMethod.email:
        return Icons.email;
      case TwoFactorMethod.authenticatorApp:
        return Icons.smartphone;
    }
  }

  String _getTwoFactorMethodName(TwoFactorMethod method) {
    switch (method) {
      case TwoFactorMethod.sms:
        return 'SMS Text Message';
      case TwoFactorMethod.email:
        return 'Email';
      case TwoFactorMethod.authenticatorApp:
        return 'Authenticator App';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}

/// Data model for security settings
class SecuritySettings {
  final bool twoFactorEnabled;
  final TwoFactorMethod twoFactorMethod;
  final bool biometricEnabled;
  final int passwordMinLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final bool passwordExpiryEnabled;
  final int passwordExpiryDays;
  final Duration sessionTimeout;
  final bool loginNotificationsEnabled;
  final bool suspiciousActivityAlertsEnabled;
  final bool accountLockoutEnabled;
  final int maxFailedAttempts;

  const SecuritySettings({
    this.twoFactorEnabled = false,
    this.twoFactorMethod = TwoFactorMethod.sms,
    this.biometricEnabled = false,
    this.passwordMinLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = false,
    this.passwordExpiryEnabled = false,
    this.passwordExpiryDays = 90,
    this.sessionTimeout = const Duration(hours: 1),
    this.loginNotificationsEnabled = true,
    this.suspiciousActivityAlertsEnabled = true,
    this.accountLockoutEnabled = true,
    this.maxFailedAttempts = 5,
  });

  SecuritySettings copyWith({
    bool? twoFactorEnabled,
    TwoFactorMethod? twoFactorMethod,
    bool? biometricEnabled,
    int? passwordMinLength,
    bool? requireUppercase,
    bool? requireLowercase,
    bool? requireNumbers,
    bool? requireSpecialChars,
    bool? passwordExpiryEnabled,
    int? passwordExpiryDays,
    Duration? sessionTimeout,
    bool? loginNotificationsEnabled,
    bool? suspiciousActivityAlertsEnabled,
    bool? accountLockoutEnabled,
    int? maxFailedAttempts,
  }) {
    return SecuritySettings(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      passwordMinLength: passwordMinLength ?? this.passwordMinLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireLowercase: requireLowercase ?? this.requireLowercase,
      requireNumbers: requireNumbers ?? this.requireNumbers,
      requireSpecialChars: requireSpecialChars ?? this.requireSpecialChars,
      passwordExpiryEnabled:
          passwordExpiryEnabled ?? this.passwordExpiryEnabled,
      passwordExpiryDays: passwordExpiryDays ?? this.passwordExpiryDays,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      loginNotificationsEnabled:
          loginNotificationsEnabled ?? this.loginNotificationsEnabled,
      suspiciousActivityAlertsEnabled:
          suspiciousActivityAlertsEnabled ??
          this.suspiciousActivityAlertsEnabled,
      accountLockoutEnabled:
          accountLockoutEnabled ?? this.accountLockoutEnabled,
      maxFailedAttempts: maxFailedAttempts ?? this.maxFailedAttempts,
    );
  }
}

enum TwoFactorMethod { sms, email, authenticatorApp }
