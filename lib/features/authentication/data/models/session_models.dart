import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_session.dart';

part 'session_models.freezed.dart';
part 'session_models.g.dart';

/// Data model for UserSession with Firestore serialization
@freezed
class UserSessionModel with _$UserSessionModel {
  const factory UserSessionModel({
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
  }) = _UserSessionModel;

  factory UserSessionModel.fromJson(Map<String, dynamic> json) =>
      _$UserSessionModelFromJson(json);

  factory UserSessionModel.fromEntity(UserSession entity) {
    return UserSessionModel(
      sessionId: entity.sessionId,
      userId: entity.userId,
      createdAt: entity.createdAt,
      lastActiveAt: entity.lastActiveAt,
      deviceId: entity.deviceId,
      deviceName: entity.deviceName,
      deviceType: entity.deviceType,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      isActive: entity.isActive,
      trustLevel: entity.trustLevel,
      expiresAt: entity.expiresAt,
      metadata: entity.metadata,
    );
  }

  UserSession toEntity() {
    return UserSession(
      sessionId: sessionId,
      userId: userId,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      ipAddress: ipAddress,
      userAgent: userAgent,
      isActive: isActive,
      trustLevel: trustLevel,
      expiresAt: expiresAt,
      metadata: metadata,
    );
  }
}

/// Data model for UserDevice with Firestore serialization
@freezed
class UserDeviceModel with _$UserDeviceModel {
  const factory UserDeviceModel({
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
  }) = _UserDeviceModel;

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) =>
      _$UserDeviceModelFromJson(json);

  factory UserDeviceModel.fromEntity(UserDevice entity) {
    return UserDeviceModel(
      deviceId: entity.deviceId,
      userId: entity.userId,
      deviceName: entity.deviceName,
      deviceType: entity.deviceType,
      platform: entity.platform,
      firstSeenAt: entity.firstSeenAt,
      lastSeenAt: entity.lastSeenAt,
      trustLevel: entity.trustLevel,
      isRevoked: entity.isRevoked,
      fcmToken: entity.fcmToken,
      deviceFingerprint: entity.deviceFingerprint,
      sessionIds: entity.sessionIds,
    );
  }

  UserDevice toEntity() {
    return UserDevice(
      deviceId: deviceId,
      userId: userId,
      deviceName: deviceName,
      deviceType: deviceType,
      platform: platform,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt,
      trustLevel: trustLevel,
      isRevoked: isRevoked,
      fcmToken: fcmToken,
      deviceFingerprint: deviceFingerprint,
      sessionIds: sessionIds,
    );
  }
}

/// Data model for SecurityEvent with Firestore serialization
@freezed
class SecurityEventModel with _$SecurityEventModel {
  const factory SecurityEventModel({
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
  }) = _SecurityEventModel;

  factory SecurityEventModel.fromJson(Map<String, dynamic> json) =>
      _$SecurityEventModelFromJson(json);

  factory SecurityEventModel.fromEntity(SecurityEvent entity) {
    return SecurityEventModel(
      eventId: entity.eventId,
      userId: entity.userId,
      eventType: entity.eventType,
      timestamp: entity.timestamp,
      severity: entity.severity,
      description: entity.description,
      deviceId: entity.deviceId,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      metadata: entity.metadata,
    );
  }

  SecurityEvent toEntity() {
    return SecurityEvent(
      eventId: eventId,
      userId: userId,
      eventType: eventType,
      timestamp: timestamp,
      severity: severity,
      description: description,
      deviceId: deviceId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      metadata: metadata,
    );
  }
}

/// Data model for SecuritySettings with Firestore serialization
@freezed
class SecuritySettingsModel with _$SecuritySettingsModel {
  const factory SecuritySettingsModel({
    required String userId,
    @Default(true) bool twoFactorEnabled,
    @Default(true) bool sessionTimeoutEnabled,
    @Default(30) int sessionTimeoutMinutes,
    @Default(5) int maxActiveSessions,
    @Default(true) bool suspiciousActivityAlerts,
    @Default(true) bool newDeviceAlerts,
    @Default([]) List<String> trustedDevices,
    DateTime? lastUpdated,
  }) = _SecuritySettingsModel;

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsModelFromJson(json);

  factory SecuritySettingsModel.fromEntity(SecuritySettings entity) {
    return SecuritySettingsModel(
      userId: entity.userId,
      twoFactorEnabled: entity.twoFactorEnabled,
      sessionTimeoutEnabled: entity.sessionTimeoutEnabled,
      sessionTimeoutMinutes: entity.sessionTimeoutMinutes,
      maxActiveSessions: entity.maxActiveSessions,
      suspiciousActivityAlerts: entity.suspiciousActivityAlerts,
      newDeviceAlerts: entity.newDeviceAlerts,
      trustedDevices: entity.trustedDevices,
      lastUpdated: entity.lastUpdated,
    );
  }

  SecuritySettings toEntity() {
    return SecuritySettings(
      userId: userId,
      twoFactorEnabled: twoFactorEnabled,
      sessionTimeoutEnabled: sessionTimeoutEnabled,
      sessionTimeoutMinutes: sessionTimeoutMinutes,
      maxActiveSessions: maxActiveSessions,
      suspiciousActivityAlerts: suspiciousActivityAlerts,
      newDeviceAlerts: newDeviceAlerts,
      trustedDevices: trustedDevices,
      lastUpdated: lastUpdated,
    );
  }
}
