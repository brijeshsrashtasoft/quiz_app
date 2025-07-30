import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';
import '../repositories/security_repository.dart';
import '../entities/security_event_entity.dart';

/// Session management use case for handling user sessions
/// Following CLAUDE.md Clean Architecture patterns
class SessionManagementUseCase {
  final ISessionRepository _sessionRepository;
  final ISecurityRepository _securityRepository;

  SessionManagementUseCase(this._sessionRepository, this._securityRepository);

  /// Create new session for user
  Future<Result<SessionEntity>> createSession(
    CreateSessionParams params,
  ) async {
    // Create session
    final sessionResult = await _sessionRepository.createSession(
      userId: params.userId,
      deviceId: params.deviceId,
      metadata: params.metadata,
    );

    if (sessionResult.isSuccess) {
      // Log security event
      await _securityRepository.logEvent(
        userId: params.userId,
        eventType: SecurityEventType.login,
        severity: SecurityEventSeverity.info,
        description: 'User session created',
        deviceId: params.deviceId,
        sessionId: sessionResult.data!.id,
        metadata: params.metadata,
      );
    }

    return sessionResult;
  }

  /// Validate and refresh session if needed
  Future<Result<SessionEntity>> validateAndRefreshSession(
    ValidateSessionParams params,
  ) async {
    final validationResult = await _sessionRepository.validateSession(
      params.sessionId,
    );

    if (validationResult.isFailure) return validationResult;

    final session = validationResult.data!;

    // Auto-refresh if session needs refresh
    if (session.needsRefresh) {
      return await _sessionRepository.refreshSession(params.sessionId);
    }

    return validationResult;
  }

  /// Terminate user session
  Future<Result<void>> terminateSession(TerminateSessionParams params) async {
    // Get session info for logging
    final sessionResult = await _sessionRepository.getSessionById(
      params.sessionId,
    );

    final terminateResult = await _sessionRepository.terminateSession(
      params.sessionId,
    );

    if (terminateResult.isSuccess && sessionResult.isSuccess) {
      final session = sessionResult.data!;

      // Log security event
      await _securityRepository.logEvent(
        userId: session.userId,
        eventType: SecurityEventType.logout,
        severity: SecurityEventSeverity.info,
        description: params.reason ?? 'User session terminated',
        deviceId: session.deviceId,
        sessionId: params.sessionId,
      );
    }

    return terminateResult;
  }

  /// Terminate all sessions for user
  Future<Result<void>> terminateAllSessions(
    TerminateAllSessionsParams params,
  ) async {
    final result = await _sessionRepository.terminateAllSessions(params.userId);

    if (result.isSuccess) {
      // Log security event
      await _securityRepository.logEvent(
        userId: params.userId,
        eventType: SecurityEventType.sessionRevoked,
        severity: SecurityEventSeverity.warning,
        description: 'All user sessions terminated',
      );
    }

    return result;
  }

  /// Get active sessions for user
  Future<Result<List<SessionEntity>>> getActiveSessions(
    GetActiveSessionsParams params,
  ) async {
    return await _sessionRepository.getActiveSessions(params.userId);
  }

  /// Clean up expired sessions
  Future<Result<int>> cleanupExpiredSessions() async {
    return await _sessionRepository.cleanupExpiredSessions();
  }

  /// Watch active sessions (real-time)
  Stream<Result<List<SessionEntity>>> watchActiveSessions(
    WatchActiveSessionsParams params,
  ) {
    return _sessionRepository.watchActiveSessions(params.userId);
  }
}

/// Parameters for creating a session
class CreateSessionParams {
  final String userId;
  final String deviceId;
  final Map<String, dynamic>? metadata;

  CreateSessionParams({
    required this.userId,
    required this.deviceId,
    this.metadata,
  });
}

/// Parameters for validating a session
class ValidateSessionParams {
  final String sessionId;

  ValidateSessionParams({required this.sessionId});
}

/// Parameters for terminating a session
class TerminateSessionParams {
  final String sessionId;
  final String? reason;

  TerminateSessionParams({required this.sessionId, this.reason});
}

/// Parameters for terminating all sessions
class TerminateAllSessionsParams {
  final String userId;

  TerminateAllSessionsParams({required this.userId});
}

/// Parameters for getting active sessions
class GetActiveSessionsParams {
  final String userId;

  GetActiveSessionsParams({required this.userId});
}

/// Parameters for watching active sessions
class WatchActiveSessionsParams {
  final String userId;

  WatchActiveSessionsParams({required this.userId});
}
