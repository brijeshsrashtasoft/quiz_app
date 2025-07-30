import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_entity.dart';

part 'user_session.freezed.dart';

/// User session entity for Clean Architecture domain layer
/// Following CLAUDE.md session management patterns
@freezed
class UserSession with _$UserSession {
  const factory UserSession({
    required String sessionId,
    required UserEntity user,
    required DateTime createdAt,
    required DateTime lastAccessedAt,
    required SessionStatus status,
    String? deviceInfo,
    String? ipAddress,
    String? userAgent,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) = _UserSession;
}

/// Session status enumeration
enum SessionStatus { active, expired, terminated, suspended }

/// Device type enumeration for session tracking
enum DeviceType { mobile, tablet, desktop, web, unknown }

/// Session security level for sensitive operations
enum SecurityLevel {
  basic, // Basic authentication
  verified, // Email verified
  enhanced, // Recent re-authentication
  maximum, // Multi-factor authentication
}

/// Extended user session with security features
@freezed
class SecureUserSession with _$SecureUserSession {
  const factory SecureUserSession({
    required UserSession session,
    required SecurityLevel securityLevel,
    required DateTime lastAuthenticationAt,
    required List<String> permissions,
    DeviceType? deviceType,
    String? deviceFingerprint,
    bool? isRemembered,
    DateTime? lastPasswordChangeAt,
    List<String>? activeFeatures,
  }) = _SecureUserSession;
}

/// Extension methods for UserSession
extension UserSessionX on UserSession {
  /// Check if session is currently active
  bool get isActive => status == SessionStatus.active && !isExpired;

  /// Check if session has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if session was recently accessed (within last hour)
  bool get isRecentlyAccessed {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    return lastAccessedAt.isAfter(oneHourAgo);
  }

  /// Get session duration since creation
  Duration get sessionDuration => DateTime.now().difference(createdAt);

  /// Get idle time since last access
  Duration get idleTime => DateTime.now().difference(lastAccessedAt);

  /// Check if session is from mobile device
  bool get isMobileSession {
    if (deviceInfo == null) return false;
    final deviceLower = deviceInfo!.toLowerCase();
    return deviceLower.contains('android') ||
        deviceLower.contains('ios') ||
        deviceLower.contains('mobile');
  }

  /// Check if session is from web browser
  bool get isWebSession {
    if (userAgent == null) return false;
    final agentLower = userAgent!.toLowerCase();
    return agentLower.contains('mozilla') ||
        agentLower.contains('chrome') ||
        agentLower.contains('safari') ||
        agentLower.contains('firefox');
  }

  /// Check if session should be renewed
  bool get needsRenewal {
    // Renewal needed if idle for more than 6 hours or session older than 24 hours
    return idleTime.inHours > 6 || sessionDuration.inHours > 24;
  }

  /// Update session with new access time
  UserSession updateLastAccess() {
    return copyWith(
      lastAccessedAt: DateTime.now(),
      status: isExpired ? SessionStatus.expired : SessionStatus.active,
    );
  }

  /// Terminate session
  UserSession terminate() {
    return copyWith(
      status: SessionStatus.terminated,
      lastAccessedAt: DateTime.now(),
    );
  }

  /// Suspend session
  UserSession suspend() {
    return copyWith(
      status: SessionStatus.suspended,
      lastAccessedAt: DateTime.now(),
    );
  }

  /// Get masked session ID for logging
  String get maskedSessionId {
    if (sessionId.length <= 8) {
      return '*' * sessionId.length;
    }
    return '${sessionId.substring(0, 4)}${'*' * (sessionId.length - 8)}${sessionId.substring(sessionId.length - 4)}';
  }
}

/// Extension methods for SecureUserSession
extension SecureUserSessionX on SecureUserSession {
  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissionsList) {
    return permissionsList.any(
      (permission) => permissions.contains(permission),
    );
  }

  /// Check if user has all of the given permissions
  bool hasAllPermissions(List<String> permissionsList) {
    return permissionsList.every(
      (permission) => permissions.contains(permission),
    );
  }

  /// Check if session allows sensitive operations
  bool get allowsSensitiveOperations {
    return securityLevel == SecurityLevel.enhanced ||
        securityLevel == SecurityLevel.maximum;
  }

  /// Check if recent authentication is required
  bool get requiresRecentAuth {
    final now = DateTime.now();
    final recentAuthThreshold = now.subtract(const Duration(minutes: 30));
    return lastAuthenticationAt.isBefore(recentAuthThreshold);
  }

  /// Check if password was recently changed
  bool get hasRecentPasswordChange {
    if (lastPasswordChangeAt == null) return false;
    final now = DateTime.now();
    final recentChangeThreshold = now.subtract(const Duration(days: 30));
    return lastPasswordChangeAt!.isAfter(recentChangeThreshold);
  }

  /// Get device type from session
  DeviceType get inferredDeviceType {
    if (deviceType != null) return deviceType!;

    if (session.isMobileSession) return DeviceType.mobile;
    if (session.isWebSession) return DeviceType.web;

    return DeviceType.unknown;
  }

  /// Update security level
  SecureUserSession updateSecurityLevel(SecurityLevel newLevel) {
    return copyWith(
      securityLevel: newLevel,
      lastAuthenticationAt: DateTime.now(),
    );
  }

  /// Add permission to session
  SecureUserSession addPermission(String permission) {
    if (permissions.contains(permission)) return this;

    return copyWith(permissions: [...permissions, permission]);
  }

  /// Remove permission from session
  SecureUserSession removePermission(String permission) {
    if (!permissions.contains(permission)) return this;

    return copyWith(
      permissions: permissions.where((p) => p != permission).toList(),
    );
  }
}
