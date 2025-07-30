import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/security_event_entity.dart';
import '../repositories/security_repository.dart';

/// Security monitoring use case for handling security events and audit logs
/// Following CLAUDE.md Clean Architecture patterns
class SecurityMonitoringUseCase {
  final ISecurityRepository _securityRepository;

  SecurityMonitoringUseCase(this._securityRepository);

  /// Log a security event
  Future<Result<SecurityEventEntity>> logSecurityEvent(
    LogSecurityEventParams params,
  ) async {
    return await _securityRepository.logEvent(
      userId: params.userId,
      eventType: params.eventType,
      severity: params.severity,
      description: params.description,
      deviceId: params.deviceId,
      sessionId: params.sessionId,
      ipAddress: params.ipAddress,
      userAgent: params.userAgent,
      metadata: params.metadata,
    );
  }

  /// Get security events for user
  Future<Result<List<SecurityEventEntity>>> getUserSecurityEvents(
    GetUserSecurityEventsParams params,
  ) async {
    return await _securityRepository.getUserEvents(
      userId: params.userId,
      limit: params.limit,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }

  /// Get recent security events (last 24 hours)
  Future<Result<List<SecurityEventEntity>>> getRecentEvents(
    GetRecentEventsParams params,
  ) async {
    return await _securityRepository.getRecentEvents(params.userId);
  }

  /// Get critical security events
  Future<Result<List<SecurityEventEntity>>> getCriticalEvents(
    GetCriticalEventsParams params,
  ) async {
    return await _securityRepository.getCriticalEvents(params.userId);
  }

  /// Get unresolved security events
  Future<Result<List<SecurityEventEntity>>> getUnresolvedEvents(
    GetUnresolvedEventsParams params,
  ) async {
    return await _securityRepository.getUnresolvedEvents(params.userId);
  }

  /// Resolve a security event
  Future<Result<SecurityEventEntity>> resolveSecurityEvent(
    ResolveSecurityEventParams params,
  ) async {
    return await _securityRepository.resolveEvent(
      eventId: params.eventId,
      resolvedBy: params.resolvedBy,
    );
  }

  /// Detect suspicious activity
  Future<Result<List<SecurityEventEntity>>> detectSuspiciousActivity(
    DetectSuspiciousActivityParams params,
  ) async {
    return await _securityRepository.detectSuspiciousActivity(params.userId);
  }

  /// Check for recent failed login attempts
  Future<Result<bool>> hasRecentFailedLogins(
    HasRecentFailedLoginsParams params,
  ) async {
    return await _securityRepository.hasRecentFailedLogins(
      userId: params.userId,
      timeWindow: params.timeWindow,
    );
  }

  /// Get authentication failure count
  Future<Result<int>> getAuthFailureCount(
    GetAuthFailureCountParams params,
  ) async {
    return await _securityRepository.getAuthFailureCount(
      userId: params.userId,
      timeWindow: params.timeWindow,
    );
  }

  /// Get security summary for user
  Future<Result<SecuritySummary>> getSecuritySummary(
    GetSecuritySummaryParams params,
  ) async {
    return await _securityRepository.getSecuritySummary(params.userId);
  }

  /// Get event count by severity
  Future<Result<Map<SecurityEventSeverity, int>>> getEventCountBySeverity(
    GetEventCountBySeverityParams params,
  ) async {
    return await _securityRepository.getEventCountBySeverity(params.userId);
  }

  /// Clean up old security events
  Future<Result<int>> cleanupOldEvents(CleanupOldEventsParams params) async {
    return await _securityRepository.cleanupOldEvents(
      retentionPeriod: params.retentionPeriod,
    );
  }

  /// Bulk log multiple security events
  Future<Result<List<SecurityEventEntity>>> bulkLogEvents(
    BulkLogEventsParams params,
  ) async {
    return await _securityRepository.bulkLogEvents(params.events);
  }

  /// Watch critical events (real-time)
  Stream<Result<SecurityEventEntity>> watchCriticalEvents(
    WatchCriticalEventsParams params,
  ) {
    return _securityRepository.watchCriticalEvents(params.userId);
  }

  /// Analyze security patterns and generate insights
  Future<Result<SecurityAnalysis>> analyzeSecurityPatterns(
    AnalyzeSecurityPatternsParams params,
  ) async {
    final eventsResult = await _securityRepository.getUserEvents(
      userId: params.userId,
      limit: 100, // Last 100 events
    );

    if (eventsResult.isFailure)
      return Result.failure(eventsResult.failureOrNull!);

    final events = eventsResult.data!;

    // Analyze patterns
    final criticalEvents = events.where((e) => e.isCritical).length;
    final authenticationEvents = events
        .where((e) => e.isAuthenticationEvent)
        .length;
    final deviceEvents = events.where((e) => e.isDeviceEvent).length;
    final biometricEvents = events.where((e) => e.isBiometricEvent).length;
    final recentEvents = events.where((e) => e.isRecent).length;

    // Check for suspicious patterns
    final failedLogins = events
        .where(
          (e) => e.eventType == SecurityEventType.loginFailed && e.isRecent,
        )
        .length;
    final suspiciousEvents = events.where((e) => e.isSecurityThreat).length;

    final riskLevel = _calculateRiskLevel(
      criticalEvents,
      failedLogins,
      suspiciousEvents,
      events.length,
    );

    return Result.success(
      SecurityAnalysis(
        totalEvents: events.length,
        criticalEvents: criticalEvents,
        authenticationEvents: authenticationEvents,
        deviceEvents: deviceEvents,
        biometricEvents: biometricEvents,
        recentEvents: recentEvents,
        failedLogins: failedLogins,
        suspiciousEvents: suspiciousEvents,
        riskLevel: riskLevel,
        recommendations: _generateRecommendations(
          riskLevel,
          failedLogins,
          suspiciousEvents,
        ),
      ),
    );
  }

  /// Calculate risk level based on security events
  SecurityRiskLevel _calculateRiskLevel(
    int criticalEvents,
    int failedLogins,
    int suspiciousEvents,
    int totalEvents,
  ) {
    final criticalRatio = totalEvents > 0 ? criticalEvents / totalEvents : 0.0;

    if (criticalEvents > 5 || suspiciousEvents > 3 || criticalRatio > 0.3) {
      return SecurityRiskLevel.high;
    } else if (criticalEvents > 2 || failedLogins > 5 || criticalRatio > 0.1) {
      return SecurityRiskLevel.medium;
    } else if (failedLogins > 0 || suspiciousEvents > 0) {
      return SecurityRiskLevel.low;
    } else {
      return SecurityRiskLevel.minimal;
    }
  }

  /// Generate security recommendations
  List<String> _generateRecommendations(
    SecurityRiskLevel riskLevel,
    int failedLogins,
    int suspiciousEvents,
  ) {
    final recommendations = <String>[];

    switch (riskLevel) {
      case SecurityRiskLevel.high:
        recommendations.add('Immediate security review required');
        recommendations.add('Consider temporarily locking account');
        recommendations.add('Review all active sessions and devices');
        break;
      case SecurityRiskLevel.medium:
        recommendations.add('Review recent security events');
        recommendations.add('Consider enabling additional security measures');
        break;
      case SecurityRiskLevel.low:
        recommendations.add('Monitor for continued suspicious activity');
        break;
      case SecurityRiskLevel.minimal:
        recommendations.add('Security status looks good');
        break;
    }

    if (failedLogins > 3) {
      recommendations.add('Multiple failed login attempts detected');
    }

    if (suspiciousEvents > 0) {
      recommendations.add('Suspicious activity patterns detected');
    }

    return recommendations;
  }
}

/// Parameters for logging security event
class LogSecurityEventParams {
  final String userId;
  final SecurityEventType eventType;
  final SecurityEventSeverity severity;
  final String description;
  final String? deviceId;
  final String? sessionId;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;

  LogSecurityEventParams({
    required this.userId,
    required this.eventType,
    required this.severity,
    required this.description,
    this.deviceId,
    this.sessionId,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });
}

/// Parameters for getting user security events
class GetUserSecurityEventsParams {
  final String userId;
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserSecurityEventsParams({
    required this.userId,
    this.limit,
    this.startDate,
    this.endDate,
  });
}

/// Parameters for getting recent events
class GetRecentEventsParams {
  final String userId;

  GetRecentEventsParams({required this.userId});
}

/// Parameters for getting critical events
class GetCriticalEventsParams {
  final String userId;

  GetCriticalEventsParams({required this.userId});
}

/// Parameters for getting unresolved events
class GetUnresolvedEventsParams {
  final String userId;

  GetUnresolvedEventsParams({required this.userId});
}

/// Parameters for resolving security event
class ResolveSecurityEventParams {
  final String eventId;
  final String resolvedBy;

  ResolveSecurityEventParams({required this.eventId, required this.resolvedBy});
}

/// Parameters for detecting suspicious activity
class DetectSuspiciousActivityParams {
  final String userId;

  DetectSuspiciousActivityParams({required this.userId});
}

/// Parameters for checking recent failed logins
class HasRecentFailedLoginsParams {
  final String userId;
  final Duration timeWindow;

  HasRecentFailedLoginsParams({required this.userId, required this.timeWindow});
}

/// Parameters for getting auth failure count
class GetAuthFailureCountParams {
  final String userId;
  final Duration timeWindow;

  GetAuthFailureCountParams({required this.userId, required this.timeWindow});
}

/// Parameters for getting security summary
class GetSecuritySummaryParams {
  final String userId;

  GetSecuritySummaryParams({required this.userId});
}

/// Parameters for getting event count by severity
class GetEventCountBySeverityParams {
  final String userId;

  GetEventCountBySeverityParams({required this.userId});
}

/// Parameters for cleaning up old events
class CleanupOldEventsParams {
  final Duration retentionPeriod;

  CleanupOldEventsParams({required this.retentionPeriod});
}

/// Parameters for bulk logging events
class BulkLogEventsParams {
  final List<SecurityEventEntity> events;

  BulkLogEventsParams({required this.events});
}

/// Parameters for watching critical events
class WatchCriticalEventsParams {
  final String userId;

  WatchCriticalEventsParams({required this.userId});
}

/// Parameters for analyzing security patterns
class AnalyzeSecurityPatternsParams {
  final String userId;

  AnalyzeSecurityPatternsParams({required this.userId});
}

/// Security risk level enumeration
enum SecurityRiskLevel { minimal, low, medium, high }

/// Security analysis result
class SecurityAnalysis {
  final int totalEvents;
  final int criticalEvents;
  final int authenticationEvents;
  final int deviceEvents;
  final int biometricEvents;
  final int recentEvents;
  final int failedLogins;
  final int suspiciousEvents;
  final SecurityRiskLevel riskLevel;
  final List<String> recommendations;

  SecurityAnalysis({
    required this.totalEvents,
    required this.criticalEvents,
    required this.authenticationEvents,
    required this.deviceEvents,
    required this.biometricEvents,
    required this.recentEvents,
    required this.failedLogins,
    required this.suspiciousEvents,
    required this.riskLevel,
    required this.recommendations,
  });
}
