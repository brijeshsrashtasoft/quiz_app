import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/session_models.dart';

/// Firebase Firestore data source for session management
/// Following CLAUDE.md Free Tier and security patterns
class SessionFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  SessionFirestoreDataSource({FirebaseFirestore? firestore, Uuid? uuid})
    : _firestore = firestore ?? FirestoreConfig.instance,
      _uuid = uuid ?? const Uuid();

  /// Collection references for security data
  CollectionReference<Map<String, dynamic>> _getUserSessionsCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('sessions');
  }

  CollectionReference<Map<String, dynamic>> _getUserDevicesCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('devices');
  }

  CollectionReference<Map<String, dynamic>> _getUserSecurityEventsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('security_events');
  }

  DocumentReference<Map<String, dynamic>> _getUserSecuritySettingsDoc(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('security');
  }

  // ===========================
  // SESSION MANAGEMENT
  // ===========================

  /// Create a new user session
  Future<UserSessionModel> createSession({
    required String userId,
    required String deviceId,
    required String deviceName,
    required String deviceType,
    required String ipAddress,
    required String userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 30)); // Default timeout

      final session = UserSessionModel(
        sessionId: sessionId,
        userId: userId,
        createdAt: now,
        lastActiveAt: now,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: deviceType,
        ipAddress: ipAddress,
        userAgent: userAgent,
        isActive: true,
        trustLevel: 'unknown',
        expiresAt: expiresAt,
        metadata: metadata,
      );

      final sessionDoc = _getUserSessionsCollection(userId).doc(sessionId);
      await sessionDoc.set(session.toJson());

      AppLogger.firebase(
        'SessionDataSource',
        'Session created: $sessionId for user: $userId',
      );

      return session;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create session', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to create user session',
        code: 'session_create_error',
      );
    }
  }

  /// Update existing session
  Future<UserSessionModel> updateSession({
    required String userId,
    required String sessionId,
    DateTime? lastActiveAt,
    DateTime? expiresAt,
    bool? isActive,
    String? trustLevel,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionDoc = _getUserSessionsCollection(userId).doc(sessionId);
      final updateData = <String, dynamic>{};

      if (lastActiveAt != null) updateData['lastActiveAt'] = lastActiveAt;
      if (expiresAt != null) updateData['expiresAt'] = expiresAt;
      if (isActive != null) updateData['isActive'] = isActive;
      if (trustLevel != null) updateData['trustLevel'] = trustLevel;
      if (metadata != null) updateData['metadata'] = metadata;

      await sessionDoc.update(updateData);

      final updatedDoc = await sessionDoc.get();
      if (!updatedDoc.exists) {
        throw FirestoreException(
          message: 'Session not found after update',
          code: 'session_not_found',
        );
      }

      final updatedSession = UserSessionModel.fromJson(updatedDoc.data()!);

      AppLogger.firebase('SessionDataSource', 'Session updated: $sessionId');

      return updatedSession;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update session', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to update user session',
        code: 'session_update_error',
      );
    }
  }

  /// Get session by ID
  Future<UserSessionModel?> getSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      final sessionDoc = _getUserSessionsCollection(userId).doc(sessionId);
      final snapshot = await sessionDoc.get();

      if (!snapshot.exists) {
        return null;
      }

      return UserSessionModel.fromJson(snapshot.data()!);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get session', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to retrieve session',
        code: 'session_get_error',
      );
    }
  }

  /// Get active sessions for a user
  Future<List<UserSessionModel>> getActiveSessions(String userId) async {
    try {
      final query = _getUserSessionsCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: DateTime.now())
          .orderBy('expiresAt')
          .orderBy('lastActiveAt', descending: true);

      final snapshot = await query.get();

      final sessions = snapshot.docs
          .map((doc) => UserSessionModel.fromJson(doc.data()))
          .toList();

      AppLogger.firebase(
        'SessionDataSource',
        'Retrieved ${sessions.length} active sessions for user: $userId',
      );

      return sessions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get active sessions', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to retrieve active sessions',
        code: 'active_sessions_error',
      );
    }
  }

  /// Get all sessions for a user
  Future<List<UserSessionModel>> getUserSessions(String userId) async {
    try {
      final query = _getUserSessionsCollection(userId)
          .orderBy('createdAt', descending: true)
          .limit(100); // Limit to stay within free tier

      final snapshot = await query.get();

      final sessions = snapshot.docs
          .map((doc) => UserSessionModel.fromJson(doc.data()))
          .toList();

      return sessions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get user sessions', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to retrieve user sessions',
        code: 'user_sessions_error',
      );
    }
  }

  /// Terminate a specific session
  Future<void> terminateSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      final sessionDoc = _getUserSessionsCollection(userId).doc(sessionId);
      await sessionDoc.update({'isActive': false, 'expiresAt': DateTime.now()});

      AppLogger.firebase('SessionDataSource', 'Session terminated: $sessionId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to terminate session', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to terminate session',
        code: 'session_terminate_error',
      );
    }
  }

  /// Terminate all sessions for a user except current
  Future<void> terminateOtherSessions({
    required String userId,
    required String currentSessionId,
  }) async {
    try {
      final activeSessions = await getActiveSessions(userId);
      final batch = _firestore.batch();

      for (final session in activeSessions) {
        if (session.sessionId != currentSessionId) {
          final sessionDoc = _getUserSessionsCollection(
            userId,
          ).doc(session.sessionId);
          batch.update(sessionDoc, {
            'isActive': false,
            'expiresAt': DateTime.now(),
          });
        }
      }

      await batch.commit();

      AppLogger.firebase(
        'SessionDataSource',
        'Other sessions terminated for user: $userId',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to terminate other sessions', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to terminate other sessions',
        code: 'terminate_others_error',
      );
    }
  }

  /// Clean up expired sessions
  Future<int> cleanupExpiredSessions(String userId) async {
    try {
      final expiredQuery = _getUserSessionsCollection(userId)
          .where('expiresAt', isLessThan: DateTime.now())
          .limit(100); // Process in batches

      final snapshot = await expiredQuery.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }

      AppLogger.firebase(
        'SessionDataSource',
        'Cleaned up ${snapshot.docs.length} expired sessions',
      );

      return snapshot.docs.length;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup expired sessions', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to cleanup expired sessions',
        code: 'cleanup_sessions_error',
      );
    }
  }

  /// Stream of user sessions
  Stream<List<UserSessionModel>> watchUserSessions(String userId) {
    try {
      return _getUserSessionsCollection(userId)
          .orderBy('lastActiveAt', descending: true)
          .limit(50)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => UserSessionModel.fromJson(doc.data()))
                .toList(),
          );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to watch user sessions', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to watch user sessions',
        code: 'watch_sessions_error',
      );
    }
  }

  // ===========================
  // DEVICE MANAGEMENT
  // ===========================

  /// Register a new device
  Future<UserDeviceModel> registerDevice({
    required String userId,
    required String deviceId,
    required String deviceName,
    required String deviceType,
    required String platform,
    String? fcmToken,
    Map<String, dynamic>? deviceFingerprint,
  }) async {
    try {
      final now = DateTime.now();

      final device = UserDeviceModel(
        deviceId: deviceId,
        userId: userId,
        deviceName: deviceName,
        deviceType: deviceType,
        platform: platform,
        firstSeenAt: now,
        lastSeenAt: now,
        trustLevel: 'unknown',
        isRevoked: false,
        fcmToken: fcmToken,
        deviceFingerprint: deviceFingerprint,
        sessionIds: [],
      );

      final deviceDoc = _getUserDevicesCollection(userId).doc(deviceId);
      await deviceDoc.set(device.toJson());

      AppLogger.firebase(
        'SessionDataSource',
        'Device registered: $deviceId for user: $userId',
      );

      return device;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to register device', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to register device',
        code: 'device_register_error',
      );
    }
  }

  /// Get user devices
  Future<List<UserDeviceModel>> getUserDevices(String userId) async {
    try {
      final query = _getUserDevicesCollection(userId)
          .where('isRevoked', isEqualTo: false)
          .orderBy('lastSeenAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => UserDeviceModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get user devices', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to retrieve user devices',
        code: 'user_devices_error',
      );
    }
  }

  /// Update device
  Future<UserDeviceModel> updateDevice({
    required String userId,
    required String deviceId,
    String? deviceName,
    DateTime? lastSeenAt,
    String? fcmToken,
    String? trustLevel,
    List<String>? sessionIds,
  }) async {
    try {
      final deviceDoc = _getUserDevicesCollection(userId).doc(deviceId);
      final updateData = <String, dynamic>{};

      if (deviceName != null) updateData['deviceName'] = deviceName;
      if (lastSeenAt != null) updateData['lastSeenAt'] = lastSeenAt;
      if (fcmToken != null) updateData['fcmToken'] = fcmToken;
      if (trustLevel != null) updateData['trustLevel'] = trustLevel;
      if (sessionIds != null) updateData['sessionIds'] = sessionIds;

      await deviceDoc.update(updateData);

      final updatedDoc = await deviceDoc.get();
      return UserDeviceModel.fromJson(updatedDoc.data()!);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update device', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to update device',
        code: 'device_update_error',
      );
    }
  }

  // ===========================
  // SECURITY EVENTS
  // ===========================

  /// Log a security event
  Future<SecurityEventModel> logSecurityEvent({
    required String userId,
    required String eventType,
    required String severity,
    required String description,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final eventId = _uuid.v4();
      final event = SecurityEventModel(
        eventId: eventId,
        userId: userId,
        eventType: eventType,
        timestamp: DateTime.now(),
        severity: severity,
        description: description,
        deviceId: deviceId,
        ipAddress: ipAddress,
        userAgent: userAgent,
        metadata: metadata,
      );

      final eventDoc = _getUserSecurityEventsCollection(userId).doc(eventId);
      await eventDoc.set(event.toJson());

      AppLogger.firebase(
        'SessionDataSource',
        'Security event logged: $eventType for user: $userId',
      );

      return event;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log security event', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to log security event',
        code: 'security_event_error',
      );
    }
  }

  /// Get security events for a user
  Future<List<SecurityEventModel>> getUserSecurityEvents({
    required String userId,
    int? limit,
    DateTime? since,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _getUserSecurityEventsCollection(
        userId,
      ).orderBy('timestamp', descending: true);

      if (since != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: since);
      }

      if (limit != null) {
        query = query.limit(limit);
      } else {
        query = query.limit(100); // Default limit for free tier
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => SecurityEventModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get security events', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to retrieve security events',
        code: 'security_events_error',
      );
    }
  }

  // ===========================
  // SECURITY SETTINGS
  // ===========================

  /// Get security settings for a user
  Future<SecuritySettingsModel?> getSecuritySettings(String userId) async {
    try {
      final settingsDoc = _getUserSecuritySettingsDoc(userId);
      final snapshot = await settingsDoc.get();

      if (!snapshot.exists) {
        return null;
      }

      return SecuritySettingsModel.fromJson(snapshot.data()!);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get security settings', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to retrieve security settings',
        code: 'security_settings_error',
      );
    }
  }

  /// Update security settings
  Future<SecuritySettingsModel> updateSecuritySettings(
    SecuritySettingsModel settings,
  ) async {
    try {
      final settingsDoc = _getUserSecuritySettingsDoc(settings.userId);
      await settingsDoc.set(settings.toJson());

      AppLogger.firebase(
        'SessionDataSource',
        'Security settings updated for user: ${settings.userId}',
      );

      return settings;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update security settings', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to update security settings',
        code: 'security_settings_update_error',
      );
    }
  }
}
