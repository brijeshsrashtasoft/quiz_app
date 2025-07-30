import '../../../../core/utils/result.dart';
import '../entities/security_event_entity.dart';
import '../entities/user_session.dart' show SecuritySettings;

/// Security repository contract for security event logging and monitoring
/// Following CLAUDE.md Clean Architecture patterns
abstract class ISecurityRepository {
  /// Log a security event
  Future<Result<SecurityEventEntity>> logEvent({
    required String userId,
    required SecurityEventType eventType,
    required SecurityEventSeverity severity,
    required String description,
    String? deviceId,
    String? sessionId,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  });

  /// Get security events for user
  Future<Result<List<SecurityEventEntity>>> getUserEvents({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get recent security events for user (last 24 hours)
  Future<Result<List<SecurityEventEntity>>> getRecentEvents(String userId);

  /// Get critical security events for user
  Future<Result<List<SecurityEventEntity>>> getCriticalEvents(String userId);

  /// Get unresolved security events
  Future<Result<List<SecurityEventEntity>>> getUnresolvedEvents(String userId);

  /// Mark security event as resolved
  Future<Result<SecurityEventEntity>> resolveEvent({
    required String eventId,
    required String resolvedBy,
  });

  /// Get events by type
  Future<Result<List<SecurityEventEntity>>> getEventsByType({
    required String userId,
    required SecurityEventType eventType,
    int? limit,
  });

  /// Get events by device
  Future<Result<List<SecurityEventEntity>>> getEventsByDevice({
    required String userId,
    required String deviceId,
    int? limit,
  });

  /// Get events by session
  Future<Result<List<SecurityEventEntity>>> getEventsBySession({
    required String userId,
    required String sessionId,
    int? limit,
  });

  /// Check for suspicious activity patterns
  Future<Result<List<SecurityEventEntity>>> detectSuspiciousActivity(
    String userId,
  );

  /// Get authentication failure count in time window
  Future<Result<int>> getAuthFailureCount({
    required String userId,
    required Duration timeWindow,
  });

  /// Check if user has recent failed login attempts
  Future<Result<bool>> hasRecentFailedLogins({
    required String userId,
    required Duration timeWindow,
  });

  /// Get event count by severity
  Future<Result<Map<SecurityEventSeverity, int>>> getEventCountBySeverity(
    String userId,
  );

  /// Clean up old security events (older than retention period)
  Future<Result<int>> cleanupOldEvents({required Duration retentionPeriod});

  /// Get security summary for user
  Future<Result<SecuritySummary>> getSecuritySummary(String userId);

  /// Watch critical events (real-time)
  Stream<Result<SecurityEventEntity>> watchCriticalEvents(String userId);

  /// Bulk log multiple events
  Future<Result<List<SecurityEventEntity>>> bulkLogEvents(
    List<SecurityEventEntity> events,
  );

  /// Get security settings for user
  Future<Result<SecuritySettings?>> getSecuritySettings(String userId);

  /// Update security settings for user
  Future<Result<SecuritySettings>> updateSecuritySettings(
    SecuritySettings settings,
  );

  /// Create default security settings for user
  Future<Result<SecuritySettings>> createDefaultSettings(String userId);
}

/// Security summary for dashboard/overview
class SecuritySummary {
  final int totalEvents;
  final int criticalEvents;
  final int unresolvedEvents;
  final int recentEvents;
  final DateTime? lastLoginAt;
  final int failedLoginAttempts;
  final int trustedDevices;
  final int activeSessions;

  SecuritySummary({
    required this.totalEvents,
    required this.criticalEvents,
    required this.unresolvedEvents,
    required this.recentEvents,
    this.lastLoginAt,
    required this.failedLoginAttempts,
    required this.trustedDevices,
    required this.activeSessions,
  });
}
