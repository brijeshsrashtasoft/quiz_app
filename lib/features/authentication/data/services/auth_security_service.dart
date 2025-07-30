import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/session_repository_impl.dart';
import '../repositories/device_repository_impl.dart';
import '../repositories/security_event_repository_impl.dart';
import '../repositories/security_settings_repository_impl.dart'
    hide SecuritySettings;
import '../datasources/session_firestore_datasource.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/security_event_entity.dart';

/// Service for managing authentication security and sessions
/// Following CLAUDE.md Free Tier compliance and security patterns
class AuthSecurityService {
  final SessionRepositoryImpl _sessionRepository;
  final DeviceRepositoryImpl _deviceRepository;
  final SecurityEventRepositoryImpl _securityEventRepository;
  final SecuritySettingsRepositoryImpl _securitySettingsRepository;
  final DeviceInfoPlugin _deviceInfo;
  final Uuid _uuid;

  AuthSecurityService({
    SessionFirestoreDataSource? dataSource,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
  }) : _sessionRepository = SessionRepositoryImpl(
         dataSource: dataSource ?? SessionFirestoreDataSource(),
       ),
       _deviceRepository = DeviceRepositoryImpl(
         dataSource: dataSource ?? SessionFirestoreDataSource(),
       ),
       _securityEventRepository = SecurityEventRepositoryImpl(
         dataSource: dataSource ?? SessionFirestoreDataSource(),
       ),
       _securitySettingsRepository = SecuritySettingsRepositoryImpl(
         dataSource: dataSource ?? SessionFirestoreDataSource(),
       ),
       _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _uuid = uuid ?? const Uuid();

  /// Initialize security features for a new user session
  Future<Result<UserSession>> initializeUserSession({
    required String userId,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      // Get device information
      final deviceInfo = await _getDeviceInfo();

      // Register or update device
      final deviceResult = await _registerOrUpdateDevice(
        userId: userId,
        deviceInfo: deviceInfo,
      );

      if (deviceResult.isFailure) {
        return Result.failure(
          Failure.deviceFailure(
            message: 'Failed to register device: ${deviceResult.error}',
          ),
        );
      }

      // Create new session
      final sessionResult = await _sessionRepository.createSession(
        userId: userId,
        deviceId: deviceInfo['deviceId']!,
        metadata: {
          'deviceName': deviceInfo['deviceName']!,
          'deviceType': deviceInfo['deviceType']!,
          'ipAddress': ipAddress ?? 'unknown',
          'userAgent': userAgent ?? 'unknown',
          'platform': deviceInfo['platform'],
          'appVersion': deviceInfo['appVersion'],
          'loginMethod': 'email_password',
        },
      );

      if (sessionResult.isFailure) {
        return Result.failure(sessionResult.error!);
      }

      // Convert SessionEntity back to UserSession for service layer
      final sessionEntity = sessionResult.data!;
      final userSession = UserSession(
        sessionId: sessionEntity.id,
        userId: sessionEntity.userId,
        createdAt: sessionEntity.createdAt,
        lastActiveAt: sessionEntity.lastActivityAt,
        deviceId: sessionEntity.deviceId,
        deviceName: sessionEntity.deviceName,
        deviceType: sessionEntity.deviceType,
        ipAddress: sessionEntity.ipAddress,
        userAgent: sessionEntity.userAgent ?? 'unknown',
        expiresAt: sessionEntity.expiresAt,
        isActive: sessionEntity.isActive,
        trustLevel: sessionEntity.isTrusted ? 'trusted' : 'unknown',
        metadata: {'location': sessionEntity.location ?? ''},
      );

      // Log successful login event
      await _logSecurityEvent(
        userId: userId,
        eventType: FirebaseConstants.loginSuccessEvent,
        severity: FirebaseConstants.lowSeverity,
        description: 'User logged in successfully',
        deviceId: deviceInfo['deviceId'],
        ipAddress: ipAddress,
        userAgent: userAgent,
      );

      // Check for suspicious activity
      await _checkSuspiciousActivity(userId);

      AppLogger.firebase(
        'AuthSecurityService',
        'Session initialized for user: $userId',
      );

      return Result.success(userSession);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize user session', e, stackTrace);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to initialize session: ${e.toString()}',
        ),
      );
    }
  }

  /// Refresh authentication token if needed
  Future<Result<String?>> refreshTokenIfNeeded() async {
    try {
      final needsRefresh = await AuthConfig.needsTokenRefresh();
      if (needsRefresh) {
        final token = await AuthConfig.refreshIdToken();
        AppLogger.firebase(
          'AuthSecurityService',
          'Token refreshed successfully',
        );
        return Result.success(token);
      }

      // Token is still valid
      final token = await AuthConfig.getIdToken();
      return Result.success(token);
    } catch (e) {
      AppLogger.error('Failed to refresh token', e);
      return Result.failure(
        Failure.authFailure(message: 'Token refresh failed: ${e.toString()}'),
      );
    }
  }

  /// Terminate user session and log security event
  Future<Result<void>> terminateSession({
    required String userId,
    required String sessionId,
    String reason = 'user_logout',
  }) async {
    try {
      // Terminate the session
      final result = await _sessionRepository.terminateSession(sessionId);

      if (result.isFailure) {
        return result;
      }

      // Log session termination event
      await _logSecurityEvent(
        userId: userId,
        eventType: FirebaseConstants.sessionTerminatedEvent,
        severity: FirebaseConstants.lowSeverity,
        description: 'Session terminated: $reason',
        metadata: {'sessionId': sessionId, 'reason': reason},
      );

      AppLogger.firebase(
        'AuthSecurityService',
        'Session terminated: $sessionId',
      );

      return Result.success(null);
    } catch (e) {
      AppLogger.error('Failed to terminate session', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to terminate session: ${e.toString()}',
        ),
      );
    }
  }

  /// Terminate all other sessions except current
  Future<Result<void>> terminateOtherSessions({
    required String userId,
    required String currentSessionId,
  }) async {
    try {
      final result = await _sessionRepository.terminateOtherSessions(
        currentSessionId,
        userId,
      );

      if (result.isFailure) {
        return result;
      }

      // Log security event
      await _logSecurityEvent(
        userId: userId,
        eventType: FirebaseConstants.sessionTerminatedEvent,
        severity: FirebaseConstants.mediumSeverity,
        description: 'All other sessions terminated by user',
        metadata: {
          'currentSessionId': currentSessionId,
          'action': 'terminate_others',
        },
      );

      return Result.success(null);
    } catch (e) {
      AppLogger.error('Failed to terminate other sessions', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to terminate other sessions: ${e.toString()}',
        ),
      );
    }
  }

  /// Get active sessions for user
  Future<Result<List<UserSession>>> getActiveSessions(String userId) async {
    try {
      // Clean up expired sessions first (commented out - not implemented)
      // await _sessionRepository.cleanupExpiredSessions();

      final result = await _sessionRepository.getActiveSessions(userId);

      // Convert SessionEntity list to UserSession list
      return result.when(
        success: (sessionEntities) {
          final userSessions = sessionEntities
              .map(
                (entity) => UserSession(
                  sessionId: entity.id,
                  userId: entity.userId,
                  createdAt: entity.createdAt,
                  lastActiveAt: entity.lastActivityAt,
                  deviceId: entity.deviceId,
                  deviceName: entity.deviceName,
                  deviceType: entity.deviceType,
                  ipAddress: entity.ipAddress,
                  userAgent: entity.userAgent ?? 'unknown',
                  expiresAt: entity.expiresAt,
                  isActive: entity.isActive,
                  trustLevel: entity.isTrusted ? 'trusted' : 'unknown',
                  metadata: entity.metadata ?? {},
                ),
              )
              .toList();
          return Result.success(userSessions);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      AppLogger.error('Failed to get active sessions', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Failed to get active sessions: ${e.toString()}',
        ),
      );
    }
  }

  /// Watch user sessions in real-time
  Stream<Result<List<UserSession>>> watchUserSessions(String userId) {
    // This method doesn't exist in the repository yet
    // For now return an empty stream
    return Stream.value(Result.success(<UserSession>[]));
  }

  /// Check if current session is valid
  Future<Result<bool>> isCurrentSessionValid() async {
    try {
      final user = AuthConfig.currentUser;
      if (user == null) {
        return Result.success(false);
      }

      // Check token validity
      final tokenResult = await refreshTokenIfNeeded();
      if (tokenResult.isFailure) {
        return Result.success(false);
      }

      return Result.success(true);
    } catch (e) {
      AppLogger.error('Failed to validate current session', e);
      return Result.success(false);
    }
  }

  /// Log failed login attempt
  Future<void> logFailedLoginAttempt({
    required String email,
    required String errorCode,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      // For failed logins, we don't have userId, so we'll log with email
      await _securityEventRepository.logEvent(
        userId: 'unknown', // We don't have userId for failed logins
        eventType: SecurityEventType.loginFailure,
        severity: SecurityEventSeverity.medium,
        description:
            'Failed login attempt for email: $email (Error: $errorCode)',
        ipAddress: ipAddress,
        userAgent: userAgent,
        metadata: {
          'email': email,
          'errorCode': errorCode,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      AppLogger.error('Failed to log failed login attempt', e);
      // Don't throw - this is logging only
    }
  }

  /// Get device information for current device
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final deviceId = _uuid
          .v4(); // In real app, you'd want persistent device ID

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'deviceId': deviceId,
          'deviceName': '${androidInfo.brand} ${androidInfo.model}',
          'deviceType': 'mobile',
          'platform': 'android',
          'appVersion': '1.0.0', // Get from package info
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'deviceId': deviceId,
          'deviceName': '${iosInfo.name} ${iosInfo.model}',
          'deviceType': 'mobile',
          'platform': 'ios',
          'appVersion': '1.0.0', // Get from package info
        };
      } else {
        // Web or other platforms
        return {
          'deviceId': deviceId,
          'deviceName': 'Web Browser',
          'deviceType': 'desktop',
          'platform': 'web',
          'appVersion': '1.0.0',
        };
      }
    } catch (e) {
      AppLogger.error('Failed to get device info', e);
      return {
        'deviceId': _uuid.v4(),
        'deviceName': 'Unknown Device',
        'deviceType': 'unknown',
        'platform': 'unknown',
        'appVersion': '1.0.0',
      };
    }
  }

  /// Register or update device information
  Future<Result<UserDevice>> _registerOrUpdateDevice({
    required String userId,
    required Map<String, String> deviceInfo,
  }) async {
    try {
      // Check if device already exists
      final existingDevices = await _deviceRepository.getUserDevices(userId);

      if (existingDevices.isSuccess) {
        final device = existingDevices.data!
            .where((d) => d.id == deviceInfo['deviceId'])
            .firstOrNull;

        if (device != null) {
          // Update existing device last seen (not implemented yet)
          // return await _deviceRepository.updateLastSeen(device.id);

          // For now, return the existing device
          final userDevice = UserDevice(
            deviceId: device.id,
            userId: device.userId,
            deviceName: device.deviceName,
            deviceType: device.platform,
            platform: device.platform,
            firstSeenAt: device.registeredAt,
            lastSeenAt: device.lastSeenAt,
            trustLevel: device.isTrusted ? 'trusted' : 'unknown',
          );
          return Result.success(userDevice);
        }
      }

      // Register new device
      final result = await _deviceRepository.registerDevice(
        userId: userId,
        deviceName: deviceInfo['deviceName']!,
        platform: deviceInfo['platform']!,
        osVersion: deviceInfo['appVersion']!,
        deviceModel: deviceInfo['deviceType']!,
        fingerprint: deviceInfo['deviceId']!,
        metadata: deviceInfo,
      );

      if (result.isSuccess) {
        // Log new device event
        await _logSecurityEvent(
          userId: userId,
          eventType: 'new_device',
          severity: 'medium',
          description: 'New device registered: ${deviceInfo['deviceName']}',
          deviceId: deviceInfo['deviceId'],
          metadata: deviceInfo,
        );

        // Convert DeviceEntity to UserDevice
        final device = result.data!;
        final userDevice = UserDevice(
          deviceId: device.id,
          userId: device.userId,
          deviceName: device.deviceName,
          deviceType: device.platform,
          platform: device.platform,
          firstSeenAt: device.registeredAt,
          lastSeenAt: device.lastSeenAt,
          trustLevel: device.isTrusted ? 'trusted' : 'unknown',
        );
        return Result.success(userDevice);
      }

      return Result.failure(result.error!);
    } catch (e) {
      AppLogger.error('Failed to register/update device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to register device: ${e.toString()}',
        ),
      );
    }
  }

  /// Log security event
  Future<void> _logSecurityEvent({
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
      await _securityEventRepository.logEvent(
        userId: userId,
        eventType: _parseEventType(eventType),
        severity: _parseSeverity(severity),
        description: description,
        deviceId: deviceId,
        ipAddress: ipAddress,
        userAgent: userAgent,
        metadata: metadata,
      );
    } catch (e) {
      AppLogger.error('Failed to log security event', e);
      // Don't throw - this is logging only
    }
  }

  /// Check for suspicious activity patterns
  Future<void> _checkSuspiciousActivity(String userId) async {
    try {
      final result = await _securityEventRepository.detectSuspiciousActivity(
        userId,
      );

      if (result.isSuccess && result.data!.isNotEmpty) {
        await _logSecurityEvent(
          userId: userId,
          eventType: 'suspicious_activity',
          severity: 'high',
          description: 'Suspicious activity pattern detected',
          metadata: {
            'detectionTime': DateTime.now().toIso8601String(),
            'timeWindow': '1 hour',
          },
        );
      }
    } catch (e) {
      AppLogger.error('Failed to check suspicious activity', e);
      // Don't throw - this is monitoring only
    }
  }

  /// Initialize default security settings for new user
  Future<Result<SecuritySettings>> initializeSecuritySettings(
    String userId,
  ) async {
    try {
      // Check if settings already exist
      final existingSettings = await _securitySettingsRepository
          .getSecuritySettings(userId);

      if (existingSettings.isSuccess && existingSettings.data != null) {
        return Result.success(existingSettings.data!);
      }

      // Create default settings
      return await _securitySettingsRepository.createDefaultSettings(userId);
    } catch (e) {
      AppLogger.error('Failed to initialize security settings', e);
      return Result.failure(
        Failure.securityFailure(
          message: 'Failed to initialize security settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Get user security settings
  Future<Result<SecuritySettings?>> getSecuritySettings(String userId) async {
    return await _securitySettingsRepository.getSecuritySettings(userId);
  }

  /// Update user security settings
  Future<Result<SecuritySettings>> updateSecuritySettings(
    SecuritySettings settings,
  ) async {
    try {
      final result = await _securitySettingsRepository.updateSecuritySettings(
        settings,
      );

      if (result.isSuccess) {
        await _logSecurityEvent(
          userId: settings.userId,
          eventType: 'security_settings_updated',
          severity: 'low',
          description: 'Security settings updated by user',
          metadata: {'updatedFields': settings.toJson()},
        );
      }

      return result;
    } catch (e) {
      AppLogger.error('Failed to update security settings', e);
      return Result.failure(
        Failure.securityFailure(
          message: 'Failed to update security settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Helper methods to parse event types and severities
  SecurityEventType _parseEventType(String eventType) {
    switch (eventType) {
      case 'login_success':
        return SecurityEventType.loginSuccess;
      case 'login_failed':
        return SecurityEventType.loginFailure;
      case 'session_terminated':
        return SecurityEventType.sessionTimeout;
      case 'new_device':
        return SecurityEventType.deviceRegistration;
      case 'suspicious_activity':
        return SecurityEventType.suspiciousActivity;
      default:
        return SecurityEventType.loginAttempt;
    }
  }

  SecurityEventSeverity _parseSeverity(String severity) {
    switch (severity) {
      case 'low':
        return SecurityEventSeverity.low;
      case 'medium':
        return SecurityEventSeverity.medium;
      case 'high':
        return SecurityEventSeverity.high;
      case 'critical':
        return SecurityEventSeverity.critical;
      default:
        return SecurityEventSeverity.low;
    }
  }
}
