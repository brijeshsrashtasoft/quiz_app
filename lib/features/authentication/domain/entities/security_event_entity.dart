import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_event_entity.freezed.dart';

/// Security event entity for monitoring and logging security-related activities
/// Following Clean Architecture domain layer patterns
@freezed
class SecurityEventEntity with _$SecurityEventEntity {
  const factory SecurityEventEntity({
    required String id,
    required String userId,
    required SecurityEventType type,
    required SecurityEventSeverity severity,
    required DateTime timestamp,
    required String deviceId,
    required String ipAddress,
    required String description,
    String? sessionId,
    String? location,
    Map<String, dynamic>? metadata,
    @Default(false) bool resolved,
  }) = _SecurityEventEntity;
}

/// Security event types
enum SecurityEventType {
  login,
  loginFailed,
  loginAttempt,
  loginSuccess,
  loginFailure,
  logout,
  logoutSuccess,
  passwordChange,
  accountLockout,
  suspiciousActivity,
  deviceRegistration,
  deviceTrustChange,
  sessionTimeout,
  biometricFailure,
  multipleFailedAttempts,
  unknownDevice,
  locationChange;

  String get displayName {
    switch (this) {
      case SecurityEventType.login:
        return 'Login';
      case SecurityEventType.loginFailed:
        return 'Login Failed';
      case SecurityEventType.loginAttempt:
        return 'Login Attempt';
      case SecurityEventType.loginSuccess:
        return 'Login Success';
      case SecurityEventType.loginFailure:
        return 'Login Failure';
      case SecurityEventType.logout:
        return 'Logout';
      case SecurityEventType.logoutSuccess:
        return 'Logout Success';
      case SecurityEventType.passwordChange:
        return 'Password Change';
      case SecurityEventType.accountLockout:
        return 'Account Lockout';
      case SecurityEventType.suspiciousActivity:
        return 'Suspicious Activity';
      case SecurityEventType.deviceRegistration:
        return 'Device Registration';
      case SecurityEventType.deviceTrustChange:
        return 'Device Trust Change';
      case SecurityEventType.sessionTimeout:
        return 'Session Timeout';
      case SecurityEventType.biometricFailure:
        return 'Biometric Failure';
      case SecurityEventType.multipleFailedAttempts:
        return 'Multiple Failed Attempts';
      case SecurityEventType.unknownDevice:
        return 'Unknown Device';
      case SecurityEventType.locationChange:
        return 'Location Change';
    }
  }
}

/// Security event severity levels
enum SecurityEventSeverity {
  info,
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case SecurityEventSeverity.info:
        return 'Info';
      case SecurityEventSeverity.low:
        return 'Low';
      case SecurityEventSeverity.medium:
        return 'Medium';
      case SecurityEventSeverity.high:
        return 'High';
      case SecurityEventSeverity.critical:
        return 'Critical';
    }
  }
}

/// Extension methods for SecurityEventEntity
extension SecurityEventEntityX on SecurityEventEntity {
  /// Check if event is critical and needs immediate attention
  bool get isCritical => severity == SecurityEventSeverity.critical;

  /// Check if event is recent (within last hour)
  bool get isRecent {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return timestamp.isAfter(oneHourAgo);
  }

  /// Get event age in hours
  int get ageInHours {
    return DateTime.now().difference(timestamp).inHours;
  }

  /// Check if event requires user notification
  bool get requiresNotification {
    return severity.index >= SecurityEventSeverity.medium.index;
  }

  /// Check if event should trigger security policy
  bool get triggersSecurityPolicy {
    return type == SecurityEventType.multipleFailedAttempts ||
        type == SecurityEventType.suspiciousActivity ||
        severity == SecurityEventSeverity.critical;
  }

  /// Check if event is authentication-related
  bool get isAuthenticationEvent {
    return type == SecurityEventType.loginAttempt ||
        type == SecurityEventType.loginSuccess ||
        type == SecurityEventType.loginFailure ||
        type == SecurityEventType.logoutSuccess ||
        type == SecurityEventType.passwordChange;
  }

  /// Check if event is device-related
  bool get isDeviceEvent {
    return type == SecurityEventType.deviceRegistration ||
        type == SecurityEventType.deviceTrustChange ||
        type == SecurityEventType.unknownDevice;
  }

  /// Check if event is biometric-related
  bool get isBiometricEvent {
    return type == SecurityEventType.biometricFailure;
  }

  /// Check if event is a security threat
  bool get isSecurityThreat {
    return type == SecurityEventType.suspiciousActivity ||
        type == SecurityEventType.multipleFailedAttempts ||
        type == SecurityEventType.accountLockout ||
        severity == SecurityEventSeverity.critical;
  }

  /// Get event type property
  SecurityEventType get eventType => type;
}
