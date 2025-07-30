import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_firestore_datasource.dart';

/// Implementation of ISessionRepository using Firestore
/// Following CLAUDE.md Clean Architecture and free tier patterns
class SessionRepositoryImpl implements ISessionRepository {
  final SessionFirestoreDataSource _dataSource;

  SessionRepositoryImpl({required SessionFirestoreDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<SessionEntity>> createSession({
    required String userId,
    required String deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create session using data source - will need to map UserSession to SessionEntity
      final userSession = await _dataSource.createSession(
        userId: userId,
        deviceId: deviceId,
        deviceName: metadata?['deviceName'] ?? 'Unknown Device',
        deviceType: metadata?['deviceType'] ?? 'unknown',
        ipAddress: metadata?['ipAddress'] ?? '0.0.0.0',
        userAgent: metadata?['userAgent'] ?? 'Unknown',
        metadata: metadata,
      );

      // Convert UserSession to SessionEntity
      final sessionEntity = SessionEntity(
        id: userSession.sessionId,
        userId: userSession.userId,
        deviceId: userSession.deviceId,
        deviceName: userSession.deviceName,
        deviceType: userSession.deviceType,
        ipAddress: userSession.ipAddress,
        createdAt: userSession.createdAt,
        lastActivityAt: userSession.lastActiveAt,
        expiresAt:
            userSession.expiresAt ??
            DateTime.now().add(const Duration(hours: 24)),
        isActive: userSession.isActive,
        isTrusted: userSession.trustLevel == 'trusted',
        location: userSession.ipAddress, // Using IP as location for now
        userAgent: userSession.userAgent,
        metadata: userSession.metadata,
      );

      return Result.success(sessionEntity);
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to create session', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to create session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<SessionEntity>> validateSession(String sessionId) async {
    try {
      // For validation, we need userId but the interface doesn't provide it
      // This is a design issue - we'll need to refactor later
      // For now, throw a descriptive error
      throw UnimplementedError(
        'validateSession requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to validate session', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to validate session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<SessionEntity>> refreshSession(String sessionId) async {
    try {
      throw UnimplementedError(
        'refreshSession requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to refresh session', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to refresh session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> terminateSession(String sessionId) async {
    try {
      throw UnimplementedError(
        'terminateSession requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to terminate session', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to terminate session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> terminateAllSessions(String userId) async {
    try {
      final activeSessions = await _dataSource.getActiveSessions(userId);

      for (final session in activeSessions) {
        await _dataSource.terminateSession(
          userId: userId,
          sessionId: session.sessionId,
        );
      }

      return Result.success(null);
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to terminate all sessions', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to terminate all sessions: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> terminateOtherSessions(
    String currentSessionId,
    String userId,
  ) async {
    try {
      await _dataSource.terminateOtherSessions(
        userId: userId,
        currentSessionId: currentSessionId,
      );

      return Result.success(null);
    } catch (e) {
      AppLogger.error(
        'SessionRepository: Failed to terminate other sessions',
        e,
      );
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to terminate other sessions: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<SessionEntity>>> getActiveSessions(String userId) async {
    try {
      final userSessions = await _dataSource.getActiveSessions(userId);

      final sessionEntities = userSessions
          .map(
            (userSession) => SessionEntity(
              id: userSession.sessionId,
              userId: userSession.userId,
              deviceId: userSession.deviceId,
              deviceName: userSession.deviceName,
              deviceType: userSession.deviceType,
              ipAddress: userSession.ipAddress,
              createdAt: userSession.createdAt,
              lastActivityAt: userSession.lastActiveAt,
              expiresAt:
                  userSession.expiresAt ??
                  DateTime.now().add(const Duration(hours: 24)),
              isActive: userSession.isActive,
              isTrusted: userSession.trustLevel == 'trusted',
              location: userSession.ipAddress,
              userAgent: userSession.userAgent,
              metadata: userSession.metadata,
            ),
          )
          .toList();

      return Result.success(sessionEntities);
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to get active sessions', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to get active sessions: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<SessionEntity?>> getSessionById(String sessionId) async {
    try {
      throw UnimplementedError(
        'getSessionById requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to get session by id', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to get session by id: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateLastAccessed(String sessionId) async {
    try {
      throw UnimplementedError(
        'updateLastAccessed requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to update last accessed', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to update last accessed: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<int>> cleanupExpiredSessions() async {
    try {
      // Global cleanup is not possible with Firestore subcollections without Cloud Functions
      // This would require system-level access or expensive cross-collection queries
      throw UnimplementedError(
        'Global session cleanup not supported in free tier. '
        'Use per-user cleanup when users access their sessions.',
      );
    } catch (e) {
      AppLogger.error(
        'SessionRepository: Failed to cleanup expired sessions',
        e,
      );
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to cleanup expired sessions: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<int>> getSessionCount(String userId) async {
    try {
      final sessions = await _dataSource.getUserSessions(userId);
      return Result.success(sessions.length);
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to get session count', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to get session count: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> suspendSession(String sessionId) async {
    try {
      throw UnimplementedError(
        'suspendSession requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to suspend session', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to suspend session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> resumeSession(String sessionId) async {
    try {
      throw UnimplementedError(
        'resumeSession requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to resume session', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to resume session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> hasActiveSessions(String userId) async {
    try {
      final activeSessions = await getActiveSessions(userId);
      if (activeSessions.isFailure) {
        return Result.failure(activeSessions.error!);
      }
      return Result.success(activeSessions.data!.isNotEmpty);
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to check active sessions', e);
      return Result.failure(
        Failure.sessionFailure(
          message: 'Failed to check active sessions: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Result<List<SessionEntity>>> watchActiveSessions(String userId) {
    try {
      return _dataSource
          .watchUserSessions(userId)
          .map((userSessions) {
            final sessionEntities = userSessions
                .where((session) => session.isActive)
                .map(
                  (userSession) => SessionEntity(
                    id: userSession.sessionId,
                    userId: userSession.userId,
                    deviceId: userSession.deviceId,
                    deviceName: userSession.deviceName,
                    deviceType: userSession.deviceType,
                    ipAddress: userSession.ipAddress,
                    createdAt: userSession.createdAt,
                    lastActivityAt: userSession.lastActiveAt,
                    expiresAt:
                        userSession.expiresAt ??
                        DateTime.now().add(const Duration(hours: 24)),
                    isActive: userSession.isActive,
                    isTrusted: userSession.trustLevel == 'trusted',
                    location: userSession.ipAddress,
                    userAgent: userSession.userAgent,
                    metadata: userSession.metadata,
                  ),
                )
                .toList();
            return Result.success(sessionEntities);
          })
          .handleError((error) {
            AppLogger.error('SessionRepository: Stream error', error);
            return Result<List<SessionEntity>>.failure(
              Failure.sessionFailure(
                message: 'Failed to watch sessions: ${error.toString()}',
              ),
            );
          });
    } catch (e) {
      AppLogger.error('SessionRepository: Failed to setup session stream', e);
      return Stream.value(
        Result.failure(
          Failure.sessionFailure(
            message: 'Failed to watch sessions: ${e.toString()}',
          ),
        ),
      );
    }
  }
}
