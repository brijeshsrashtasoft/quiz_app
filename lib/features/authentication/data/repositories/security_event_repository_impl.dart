import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/security_event_entity.dart';
import '../../domain/entities/user_session.dart' show SecuritySettings;
import '../../domain/repositories/security_repository.dart';
import '../datasources/session_firestore_datasource.dart';

/// Implementation of ISecurityRepository using Firestore
/// Following CLAUDE.md Clean Architecture and free tier patterns
class SecurityEventRepositoryImpl implements ISecurityRepository {
  final SessionFirestoreDataSource _dataSource;

  SecurityEventRepositoryImpl({required SessionFirestoreDataSource dataSource})
    : _dataSource = dataSource;

  @override
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
  }) async {
    try {
      // Map SecurityEventEntity to the data layer's SecurityEvent model
      final eventModel = await _dataSource.logSecurityEvent(
        userId: userId,
        eventType: eventType.toString().split('.').last,
        severity: severity.toString().split('.').last,
        description: description,
        deviceId: deviceId,
        ipAddress: ipAddress,
        userAgent: userAgent,
        metadata: metadata,
      );

      // Convert back to domain entity
      final securityEventEntity = SecurityEventEntity(
        id: eventModel.eventId,
        userId: eventModel.userId,
        type: eventType,
        severity: severity,
        description: eventModel.description,
        timestamp: eventModel.timestamp,
        deviceId: eventModel.deviceId ?? '',
        ipAddress: eventModel.ipAddress ?? '',
        sessionId: sessionId,
        metadata: eventModel.metadata,
      );

      return Result.success(securityEventEntity);
    } catch (e) {
      AppLogger.error('SecurityEventRepository: Failed to log security event', e);
      return Result.failure(Failure.securityFailure(
        message: 'Failed to log security event: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<List<SecurityEventEntity>>> getUserEvents({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get events from data source
      final eventModels = await _dataSource.getUserSecurityEvents(
        userId: userId,
        limit: limit,
        since: startDate,
      );

      // Convert to domain entities
      final securityEvents = eventModels.map((model) {
        final eventType = SecurityEventType.values.firstWhere(
          (type) => type.toString().split('.').last == model.eventType,
          orElse: () => SecurityEventType.loginAttempt,
        );
        final severity = SecurityEventSeverity.values.firstWhere(
          (sev) => sev.toString().split('.').last == model.severity,
          orElse: () => SecurityEventSeverity.low,
        );
        
        return SecurityEventEntity(
          id: model.eventId,
          userId: model.userId,
          type: eventType,
          severity: severity,
          description: model.description,
          timestamp: model.timestamp,
          deviceId: model.deviceId ?? '',
          ipAddress: model.ipAddress ?? '',
          metadata: model.metadata,
        );
      }).toList();

      // Apply date filter if specified
      final filteredEvents = endDate != null
          ? securityEvents.where((event) => event.timestamp.isBefore(endDate)).toList()
          : securityEvents;

      return Result.success(filteredEvents);
    } catch (e) {
      AppLogger.error('SecurityEventRepository: Failed to get security events', e);
      return Result.failure(Failure.securityFailure(
        message: 'Failed to get security events: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<List<SecurityEventEntity>>> detectSuspiciousActivity(
    String userId,
  ) async {
    try {
      // Get recent security events to analyze patterns
      final since = DateTime.now().subtract(const Duration(hours: 24));
      final eventModels = await _dataSource.getUserSecurityEvents(
        userId: userId,
        limit: 100,
        since: since,
      );

      // Simple suspicious activity detection
      final suspiciousEvents = eventModels.where((model) {
        return model.eventType == 'loginFailure' || 
               model.eventType == 'multipleFailedAttempts' ||
               model.severity == 'critical';
      }).toList();

      // Convert to domain entities
      final securityEvents = suspiciousEvents.map((model) {
        final eventType = SecurityEventType.values.firstWhere(
          (type) => type.toString().split('.').last == model.eventType,
          orElse: () => SecurityEventType.suspiciousActivity,
        );
        final severity = SecurityEventSeverity.values.firstWhere(
          (sev) => sev.toString().split('.').last == model.severity,
          orElse: () => SecurityEventSeverity.medium,
        );
        
        return SecurityEventEntity(
          id: model.eventId,
          userId: model.userId,
          type: eventType,
          severity: severity,
          description: model.description,
          timestamp: model.timestamp,
          deviceId: model.deviceId ?? '',
          ipAddress: model.ipAddress ?? '',
          metadata: model.metadata,
        );
      }).toList();

      return Result.success(securityEvents);
    } catch (e) {
      AppLogger.error('SecurityEventRepository: Failed to detect suspicious activity', e);
      return Result.failure(Failure.securityFailure(
        message: 'Failed to detect suspicious activity: ${e.toString()}',
      ));
    }
  }

  // Implement remaining ISecurityRepository methods
  @override
  Future<Result<List<SecurityEventEntity>>> getRecentEvents(String userId) async {
    final since = DateTime.now().subtract(const Duration(hours: 24));
    return getUserEvents(userId: userId, startDate: since, limit: 50);
  }

  @override
  Future<Result<List<SecurityEventEntity>>> getCriticalEvents(String userId) async {
    try {
      final result = await getUserEvents(userId: userId, limit: 100);
      return result.when(
        success: (events) {
          final criticalEvents = events.where((e) => e.severity == SecurityEventSeverity.critical).toList();
          return Result.success(criticalEvents);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get critical events: $e'));
    }
  }

  @override
  Future<Result<List<SecurityEventEntity>>> getUnresolvedEvents(String userId) async {
    try {
      final result = await getUserEvents(userId: userId, limit: 100);
      return result.when(
        success: (events) {
          final unresolvedEvents = events.where((e) => !e.resolved).toList();
          return Result.success(unresolvedEvents);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get unresolved events: $e'));
    }
  }

  @override
  Future<Result<SecurityEventEntity>> resolveEvent({
    required String eventId,
    required String resolvedBy,
  }) async {
    // For now, return unimplemented - would need to update the data source
    return Result.failure(Failure.securityFailure(
      message: 'Event resolution not implemented in data source yet',
    ));
  }

  @override
  Future<Result<List<SecurityEventEntity>>> getEventsByType({
    required String userId,
    required SecurityEventType eventType,
    int? limit,
  }) async {
    try {
      final result = await getUserEvents(userId: userId, limit: limit ?? 50);
      return result.when(
        success: (events) {
          final filteredEvents = events.where((e) => e.type == eventType).toList();
          return Result.success(filteredEvents);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get events by type: $e'));
    }
  }

  @override
  Future<Result<List<SecurityEventEntity>>> getEventsByDevice({
    required String userId,
    required String deviceId,
    int? limit,
  }) async {
    try {
      final result = await getUserEvents(userId: userId, limit: limit ?? 50);
      return result.when(
        success: (events) {
          final filteredEvents = events.where((e) => e.deviceId == deviceId).toList();
          return Result.success(filteredEvents);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get events by device: $e'));
    }
  }

  @override
  Future<Result<List<SecurityEventEntity>>> getEventsBySession({
    required String userId,
    required String sessionId,
    int? limit,
  }) async {
    try {
      final result = await getUserEvents(userId: userId, limit: limit ?? 50);
      return result.when(
        success: (events) {
          final filteredEvents = events.where((e) => e.sessionId == sessionId).toList();
          return Result.success(filteredEvents);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get events by session: $e'));
    }
  }

  @override
  Future<Result<int>> getAuthFailureCount({
    required String userId,
    required Duration timeWindow,
  }) async {
    try {
      final since = DateTime.now().subtract(timeWindow);
      final result = await getUserEvents(userId: userId, startDate: since, limit: 100);
      return result.when(
        success: (events) {
          final failureCount = events.where((e) => e.type == SecurityEventType.loginFailure).length;
          return Result.success(failureCount);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get auth failure count: $e'));
    }
  }

  @override
  Future<Result<bool>> hasRecentFailedLogins({
    required String userId,
    required Duration timeWindow,
  }) async {
    try {
      final result = await getAuthFailureCount(userId: userId, timeWindow: timeWindow);
      return result.when(
        success: (count) => Result.success(count > 0),
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to check recent failed logins: $e'));
    }
  }

  @override
  Future<Result<Map<SecurityEventSeverity, int>>> getEventCountBySeverity(
    String userId,
  ) async {
    try {
      final result = await getUserEvents(userId: userId, limit: 500);
      return result.when(
        success: (events) {
          final countMap = <SecurityEventSeverity, int>{};
          for (final severity in SecurityEventSeverity.values) {
            countMap[severity] = events.where((e) => e.severity == severity).length;
          }
          return Result.success(countMap);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to count events by severity: $e'));
    }
  }

  @override
  Future<Result<int>> cleanupOldEvents({required Duration retentionPeriod}) async {
    // Not implemented in data source - would require batch operations
    return Result.failure(Failure.securityFailure(
      message: 'Event cleanup not implemented in data source yet',
    ));
  }

  @override
  Future<Result<SecuritySummary>> getSecuritySummary(String userId) async {
    try {
      final eventsResult = await getUserEvents(userId: userId, limit: 500);
      return eventsResult.when(
        success: (events) {
          final summary = SecuritySummary(
            totalEvents: events.length,
            criticalEvents: events.where((e) => e.severity == SecurityEventSeverity.critical).length,
            unresolvedEvents: events.where((e) => !e.resolved).length,
            recentEvents: events.where((e) => e.isRecent).length,
            lastLoginAt: events.isNotEmpty ? events.first.timestamp : null,
            failedLoginAttempts: events.where((e) => e.type == SecurityEventType.loginFailure).length,
            trustedDevices: 0, // Would need device repository
            activeSessions: 0, // Would need session repository
          );
          return Result.success(summary);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(Failure.securityFailure(message: 'Failed to get security summary: $e'));
    }
  }

  @override
  Stream<Result<SecurityEventEntity>> watchCriticalEvents(String userId) {
    // Not implemented in data source yet - would need Firestore streams
    return Stream.value(Result.failure(Failure.securityFailure(
      message: 'Critical event watching not implemented in data source yet',
    )));
  }

  @override
  Future<Result<List<SecurityEventEntity>>> bulkLogEvents(
    List<SecurityEventEntity> events,
  ) async {
    // Not implemented in data source yet - would need batch operations  
    return Result.failure(Failure.securityFailure(
      message: 'Bulk event logging not implemented in data source yet',
    ));
  }

  @override
  Future<Result<SecuritySettings?>> getSecuritySettings(String userId) async {
    try {
      final settings = await _dataSource.getSecuritySettings(userId);
      return Result.success(settings);
    } catch (e) {
      return Result.failure(Failure.securityFailure(
        message: 'Failed to get security settings: $e',
      ));
    }
  }

  @override
  Future<Result<SecuritySettings>> updateSecuritySettings(
    SecuritySettings settings,
  ) async {
    try {
      await _dataSource.updateSecuritySettings(settings);
      return Result.success(settings);
    } catch (e) {
      return Result.failure(Failure.securityFailure(
        message: 'Failed to update security settings: $e',
      ));
    }
  }

  @override
  Future<Result<SecuritySettings>> createDefaultSettings(String userId) async {
    try {
      final settings = await _dataSource.createDefaultSecuritySettings(userId);
      return Result.success(settings);
    } catch (e) {
      return Result.failure(Failure.securityFailure(
        message: 'Failed to create default security settings: $e',
      ));
    }
  }
}