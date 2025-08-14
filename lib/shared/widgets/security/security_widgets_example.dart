import 'package:flutter/material.dart';
import 'biometric_prompt_widget.dart';
import 'session_management_widgets.dart';
import 'device_management_widgets.dart' as device_mgmt;
import 'security_settings_widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// Example usage of security widgets for authentication security and session management
/// This file demonstrates proper implementation patterns for all security components
/// Reference: docs/ui_guideline.md
class SecurityWidgetsExample extends StatefulWidget {
  const SecurityWidgetsExample({super.key});

  @override
  State<SecurityWidgetsExample> createState() => _SecurityWidgetsExampleState();
}

class _SecurityWidgetsExampleState extends State<SecurityWidgetsExample> {
  SecuritySettings _currentSettings = const SecuritySettings();

  // Example data
  final List<SessionInfo> _activeSessions = [
    SessionInfo(
      id: '1',
      deviceName: 'iPhone 14 Pro',
      deviceType: device_mgmt.DeviceType.mobile,
      location: 'New York, NY',
      ipAddress: '192.168.1.100',
      lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: SessionStatus.active,
    ),
    SessionInfo(
      id: '2',
      deviceName: 'MacBook Pro',
      deviceType: device_mgmt.DeviceType.desktop,
      location: 'New York, NY',
      ipAddress: '192.168.1.101',
      lastActive: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: SessionStatus.idle,
    ),
  ];

  final List<device_mgmt.DeviceInfo> _trustedDevices = [
    device_mgmt.DeviceInfo(
      id: '1',
      name: 'iPhone 14 Pro',
      deviceType: device_mgmt.DeviceType.mobile,
      platform: 'iOS 17.2',
      location: 'New York, NY',
      lastSeen: DateTime.now(),
      trustLevel: device_mgmt.TrustLevel.trusted,
      isCurrentDevice: true,
    ),
    device_mgmt.DeviceInfo(
      id: '2',
      name: 'MacBook Pro',
      deviceType: device_mgmt.DeviceType.desktop,
      platform: 'macOS Sonoma',
      location: 'New York, NY',
      lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
      trustLevel: device_mgmt.TrustLevel.trusted,
    ),
    device_mgmt.DeviceInfo(
      id: '3',
      name: 'Chrome Browser',
      deviceType: device_mgmt.DeviceType.web,
      platform: 'Windows 11',
      location: 'Unknown Location',
      lastSeen: DateTime.now().subtract(const Duration(days: 7)),
      trustLevel: device_mgmt.TrustLevel.recognized,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Components Demo'),
        backgroundColor: AppColors.vibrantPurple,
        foregroundColor: AppColors.pureWhite,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biometric Authentication Demo
            _buildSectionHeader('Biometric Authentication'),
            _buildDemoButton(
              'Show Biometric Prompt',
              () => _showBiometricPrompt(),
            ),
            SizedBox(height: AppSpacing.spacingS),
            _buildDemoButton('Show Setup Wizard', () => _showBiometricSetup()),
            SizedBox(height: AppSpacing.spacingXL),

            // Session Management Demo
            _buildSectionHeader('Session Management'),
            Column(
              children: _activeSessions
                  .map(
                    (session) => SessionListTile(
                      sessionInfo: session,
                      isCurrentSession: session.id == '1',
                      onTerminate: () => _terminateSession(session.id),
                      onViewDetails: () => _viewSessionDetails(session),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AppSpacing.spacingM),
            _buildDemoButton(
              'Session Timeout Settings',
              () => _showSessionTimeoutPicker(),
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Device Management Demo
            _buildSectionHeader('Device Management'),
            Column(
              children: _trustedDevices
                  .map(
                    (device) => device_mgmt.DeviceManagementCard(
                      deviceInfo: device,
                      isCurrentDevice: device.isCurrentDevice,
                      onRevokeTrust: () => _revokeDeviceTrust(device.id),
                      onViewDetails: () => _viewDeviceDetails(device),
                      onEditName: () => _editDeviceName(device),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AppSpacing.spacingM),
            _buildDemoButton(
              'New Device Approval',
              () => _showNewDeviceApproval(),
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Trust Level Indicators Demo
            _buildSectionHeader('Trust Level Indicators'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    device_mgmt.TrustLevelIndicator(
                      trustLevel: device_mgmt.TrustLevel.trusted,
                      size: 32,
                      showText: true,
                    ),
                    SizedBox(height: AppSpacing.spacingS),
                    device_mgmt.TrustLevelIndicator(
                      trustLevel: device_mgmt.TrustLevel.recognized,
                      size: 32,
                      showText: true,
                    ),
                    SizedBox(height: AppSpacing.spacingS),
                    device_mgmt.TrustLevelIndicator(
                      trustLevel: device_mgmt.TrustLevel.untrusted,
                      size: 32,
                      showText: true,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.spacingXL),

            // Security Settings Demo
            _buildSectionHeader('Security Settings'),
            SecuritySettingsPanel(
              settings: _currentSettings,
              onSettingsChanged: (newSettings) {
                setState(() {
                  _currentSettings = newSettings;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.spacingM),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDemoButton(String title, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vibrantPurple,
          side: BorderSide(color: AppColors.vibrantPurple),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
        ),
        child: Text(title),
      ),
    );
  }

  void _showBiometricPrompt() {
    showDialog(
      context: context,
      builder: (context) => BiometricPromptWidget(
        title: 'Authenticate',
        subtitle: 'Use your biometric to continue',
        biometricType: BiometricType.fingerprint,
        onAuthenticate: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication successful!')),
          );
        },
        onCancel: () => Navigator.of(context).pop(),
        onFallback: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fallback to PIN/Password')),
          );
        },
      ),
    );
  }

  void _showBiometricSetup() {
    showDialog(
      context: context,
      builder: (context) => BiometricSetupWizard(
        availableBiometrics: [BiometricType.fingerprint, BiometricType.face],
        onBiometricSelected: (biometric) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Selected ${biometric.name}')));
        },
        onSkip: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showSessionTimeoutPicker() {
    showDialog(
      context: context,
      builder: (context) => SessionTimeoutPicker(
        currentTimeout: _currentSettings.sessionTimeout,
        onTimeoutChanged: (timeout) {
          setState(() {
            _currentSettings = _currentSettings.copyWith(
              sessionTimeout: timeout,
            );
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Session timeout updated')));
        },
      ),
    );
  }

  void _showNewDeviceApproval() {
    final newDevice = device_mgmt.DeviceInfo(
      id: 'new-device',
      name: 'iPad Pro',
      deviceType: device_mgmt.DeviceType.tablet,
      platform: 'iOS 17.2',
      location: 'San Francisco, CA',
      lastSeen: DateTime.now(),
      trustLevel: device_mgmt.TrustLevel.untrusted,
    );

    showDialog(
      context: context,
      builder: (context) => device_mgmt.NewDeviceApprovalFlow(
        newDevice: newDevice,
        onApprove: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Device approved')));
        },
        onDeny: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Device access denied')));
        },
        onViewDetails: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('View device details')));
        },
      ),
    );
  }

  void _terminateSession(String sessionId) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Session $sessionId terminated')));
  }

  void _viewSessionDetails(SessionInfo session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${session.deviceName}')),
    );
  }

  void _revokeDeviceTrust(String deviceId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device trust revoked for $deviceId')),
    );
  }

  void _viewDeviceDetails(device_mgmt.DeviceInfo device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${device.name}')),
    );
  }

  void _editDeviceName(device_mgmt.DeviceInfo device) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editing name for ${device.name}')));
  }
}
