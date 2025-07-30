import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_session.freezed.dart';
part 'user_session.g.dart';

/// User session entity for tracking active sessions
/// Following CLAUDE.md Clean Architecture patterns
@freezed
class UserSession with _$UserSession {
  const factory UserSession({
    required String sessionId,
    required String userId,
    required DateTime createdAt,
    required DateTime lastActiveAt,
    required String deviceId,
    required String deviceName,
    required String deviceType,
    required String ipAddress,
    required String userAgent,
    @Default(false) bool isActive,
    @Default('unknown') String trustLevel,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) = _UserSession;

  factory UserSession.fromJson(Map<String, dynamic> json) =>
      _$UserSessionFromJson(json);
}

/// User device entity for tracking registered devices
@freezed
class UserDevice with _$UserDevice {
  const factory UserDevice({
    required String deviceId,
    required String userId,
    required String deviceName,
    required String deviceType,
    required String platform,
    required DateTime firstSeenAt,
    required DateTime lastSeenAt,
    @Default('unknown') String trustLevel,
    @Default(false) bool isRevoked,
    String? fcmToken,
    Map<String, dynamic>? deviceFingerprint,
    List<String>? sessionIds,
  }) = _UserDevice;

  factory UserDevice.fromJson(Map<String, dynamic> json) =>
      _$UserDeviceFromJson(json);
}

/// Security event entity for audit logging
@freezed
class SecurityEvent with _$SecurityEvent {
  const factory SecurityEvent({
    required String eventId,
    required String userId,
    required String eventType,
    required DateTime timestamp,
    required String severity,
    required String description,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) = _SecurityEvent;

  factory SecurityEvent.fromJson(Map<String, dynamic> json) =>
      _$SecurityEventFromJson(json);
}

/// Security settings entity for user preferences
@freezed
class SecuritySettings with _$SecuritySettings {
  const factory SecuritySettings({
    required String userId,
    @Default(true) bool twoFactorEnabled,
    @Default(true) bool sessionTimeoutEnabled,
    @Default(30) int sessionTimeoutMinutes,
    @Default(5) int maxActiveSessions,
    @Default(true) bool suspiciousActivityAlerts,
    @Default(true) bool newDeviceAlerts,
    @Default([]) List<String> trustedDevices,
    DateTime? lastUpdated,
  }) = _SecuritySettings;

  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsFromJson(json);
}
