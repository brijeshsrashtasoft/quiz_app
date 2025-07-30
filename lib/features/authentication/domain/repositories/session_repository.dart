import '../../../../core/utils/result.dart';
import '../entities/session_entity.dart';

/// Session repository contract for authentication security
/// Following CLAUDE.md Clean Architecture patterns
abstract class ISessionRepository {
  /// Create a new session for authenticated user
  Future<Result<SessionEntity>> createSession({
    required String userId,
    required String deviceId,
    Map<String, dynamic>? metadata,
  });

  /// Validate existing session
  Future<Result<SessionEntity>> validateSession(String sessionId);

  /// Refresh session expiration time
  Future<Result<SessionEntity>> refreshSession(String sessionId);

  /// Terminate specific session
  Future<Result<void>> terminateSession(String sessionId);

  /// Terminate all sessions for user
  Future<Result<void>> terminateAllSessions(String userId);

  /// Terminate all sessions except current
  Future<Result<void>> terminateOtherSessions(
    String userId,
    String currentSessionId,
  );

  /// Get active sessions for user
  Future<Result<List<SessionEntity>>> getActiveSessions(String userId);

  /// Get session by ID
  Future<Result<SessionEntity?>> getSessionById(String sessionId);

  /// Update session last accessed time
  Future<Result<void>> updateLastAccessed(String sessionId);

  /// Cleanup expired sessions
  Future<Result<int>> cleanupExpiredSessions();

  /// Get session count for user
  Future<Result<int>> getSessionCount(String userId);

  /// Suspend session (temporarily disable)
  Future<Result<void>> suspendSession(String sessionId);

  /// Resume suspended session
  Future<Result<void>> resumeSession(String sessionId);

  /// Check if user has active sessions
  Future<Result<bool>> hasActiveSessions(String userId);

  /// Watch active sessions for user (real-time)
  Stream<Result<List<SessionEntity>>> watchActiveSessions(String userId);
}
