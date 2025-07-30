import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/session_entity.dart';
import '../entities/device_entity.dart';
import '../entities/security_event_entity.dart';
import '../entities/user_session.dart' show SecuritySettings;
import '../repositories/session_repository.dart';
import '../repositories/device_repository.dart';
import '../repositories/security_repository.dart';

/// Use case for creating a new user session
class CreateSessionUseCase
    extends BaseUseCase<SessionEntity, CreateSessionParams> {
  final ISessionRepository repository;

  CreateSessionUseCase({required this.repository});

  @override
  Future<Result<SessionEntity>> call(CreateSessionParams params) async {
    return await repository.createSession(
      userId: params.userId,
      deviceId: params.deviceId,
      metadata: {
        'deviceName': params.deviceName,
        'deviceType': params.deviceType,
        'ipAddress': params.ipAddress,
        'userAgent': params.userAgent,
        ...?params.metadata,
      },
    );
  }
}

class CreateSessionParams {
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String ipAddress;
  final String userAgent;
  final Map<String, dynamic>? metadata;

  CreateSessionParams({
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.userAgent,
    this.metadata,
  });
}

/// Use case for getting active sessions for a user
class GetActiveSessionsUseCase
    extends BaseUseCase<List<SessionEntity>, String> {
  final ISessionRepository repository;

  GetActiveSessionsUseCase({required this.repository});

  @override
  Future<Result<List<SessionEntity>>> call(String userId) async {
    return await repository.getActiveSessions(userId);
  }
}

/// Use case for terminating a session
class TerminateSessionUseCase
    extends BaseUseCase<void, TerminateSessionParams> {
  final ISessionRepository repository;

  TerminateSessionUseCase({required this.repository});

  @override
  Future<Result<void>> call(TerminateSessionParams params) async {
    return await repository.terminateSession(params.sessionId);
  }
}

class TerminateSessionParams {
  final String sessionId;

  TerminateSessionParams({required this.sessionId});
}

/// Use case for terminating all other sessions except current
class TerminateOtherSessionsUseCase
    extends BaseUseCase<void, TerminateOtherSessionsParams> {
  final ISessionRepository repository;

  TerminateOtherSessionsUseCase({required this.repository});

  @override
  Future<Result<void>> call(TerminateOtherSessionsParams params) async {
    return await repository.terminateOtherSessions(
      params.userId,
      params.currentSessionId,
    );
  }
}

class TerminateOtherSessionsParams {
  final String userId;
  final String currentSessionId;

  TerminateOtherSessionsParams({
    required this.userId,
    required this.currentSessionId,
  });
}

/// Use case for watching user sessions in real-time
class WatchSessionEntitysUseCase
    extends BaseStreamUseCase<List<SessionEntity>, String> {
  final ISessionRepository repository;

  WatchSessionEntitysUseCase({required this.repository});

  @override
  Stream<Result<List<SessionEntity>>> call(String userId) {
    return repository.watchActiveSessions(userId);
  }
}

/// Use case for registering a new device
class RegisterDeviceUseCase
    extends BaseUseCase<DeviceEntity, RegisterDeviceParams> {
  final IDeviceRepository repository;

  RegisterDeviceUseCase({required this.repository});

  @override
  Future<Result<DeviceEntity>> call(RegisterDeviceParams params) async {
    return await repository.registerDevice(
      userId: params.userId,
      deviceName: params.deviceName,
      platform: params.platform,
      osVersion: params.osVersion ?? 'Unknown',
      deviceModel: params.deviceType,
      fingerprint: params.deviceFingerprint?.toString(),
      metadata: {
        'deviceId': params.deviceId,
        'fcmToken': params.fcmToken,
        ...?params.deviceFingerprint,
      },
    );
  }
}

class RegisterDeviceParams {
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String platform;
  final String? osVersion;
  final String? fcmToken;
  final Map<String, dynamic>? deviceFingerprint;

  RegisterDeviceParams({
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    this.osVersion,
    this.fcmToken,
    this.deviceFingerprint,
  });
}

/// Use case for getting user devices
class GetDeviceEntitysUseCase extends BaseUseCase<List<DeviceEntity>, String> {
  final IDeviceRepository repository;

  GetDeviceEntitysUseCase({required this.repository});

  @override
  Future<Result<List<DeviceEntity>>> call(String userId) async {
    return await repository.getUserDevices(userId);
  }
}

/// Use case for checking if device is trusted
class IsDeviceTrustedUseCase extends BaseUseCase<bool, IsDeviceTrustedParams> {
  final IDeviceRepository repository;

  IsDeviceTrustedUseCase({required this.repository});

  @override
  Future<Result<bool>> call(IsDeviceTrustedParams params) async {
    final deviceResult = await repository.getDeviceById(params.deviceId);
    return deviceResult.when(
      success: (device) => Result.success(
        device != null && device.isTrusted && device.userId == params.userId,
      ),
      failure: (failure) => Result.failure(failure),
    );
  }
}

class IsDeviceTrustedParams {
  final String deviceId;
  final String userId;

  IsDeviceTrustedParams({required this.deviceId, required this.userId});
}

/// Use case for logging security events
class LogSecurityEventEntityUseCase
    extends BaseUseCase<SecurityEventEntity, LogSecurityEventEntityParams> {
  final ISecurityRepository repository;

  LogSecurityEventEntityUseCase({required this.repository});

  @override
  Future<Result<SecurityEventEntity>> call(
    LogSecurityEventEntityParams params,
  ) async {
    return await repository.logEvent(
      userId: params.userId,
      eventType: params.eventType,
      severity: params.severity,
      description: params.description,
      deviceId: params.deviceId,
      ipAddress: params.ipAddress,
      userAgent: params.userAgent,
      metadata: params.metadata,
    );
  }
}

class LogSecurityEventEntityParams {
  final String userId;
  final SecurityEventType eventType;
  final SecurityEventSeverity severity;
  final String description;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;

  LogSecurityEventEntityParams({
    required this.userId,
    required this.eventType,
    required this.severity,
    required this.description,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });
}

/// Use case for getting user security events
class GetUserSecurityEventEntitysUseCase
    extends
        BaseUseCase<List<SecurityEventEntity>, GetSecurityEventEntitysParams> {
  final ISecurityRepository repository;

  GetUserSecurityEventEntitysUseCase({required this.repository});

  @override
  Future<Result<List<SecurityEventEntity>>> call(
    GetSecurityEventEntitysParams params,
  ) async {
    return await repository.getUserEvents(
      userId: params.userId,
      limit: params.limit,
      startDate: params.since,
    );
  }
}

class GetSecurityEventEntitysParams {
  final String userId;
  final int? limit;
  final DateTime? since;

  GetSecurityEventEntitysParams({required this.userId, this.limit, this.since});
}

/// Use case for detecting suspicious activity
class DetectSuspiciousActivityUseCase
    extends BaseUseCase<bool, DetectSuspiciousActivityParams> {
  final ISecurityRepository repository;

  DetectSuspiciousActivityUseCase({required this.repository});

  @override
  Future<Result<bool>> call(DetectSuspiciousActivityParams params) async {
    final eventsResult = await repository.detectSuspiciousActivity(
      params.userId,
    );
    return eventsResult.when(
      success: (events) => Result.success(events.isNotEmpty),
      failure: (failure) => Result.failure(failure),
    );
  }
}

class DetectSuspiciousActivityParams {
  final String userId;
  final Duration timeWindow;

  DetectSuspiciousActivityParams({
    required this.userId,
    required this.timeWindow,
  });
}

/// Use case for getting security settings
class GetSecuritySettingsUseCase
    extends BaseUseCase<SecuritySettings?, String> {
  final ISecurityRepository repository;

  GetSecuritySettingsUseCase({required this.repository});

  @override
  Future<Result<SecuritySettings?>> call(String userId) async {
    return await repository.getSecuritySettings(userId);
  }
}

/// Use case for updating security settings
class UpdateSecuritySettingsUseCase
    extends BaseUseCase<SecuritySettings, SecuritySettings> {
  final ISecurityRepository repository;

  UpdateSecuritySettingsUseCase({required this.repository});

  @override
  Future<Result<SecuritySettings>> call(SecuritySettings settings) async {
    return await repository.updateSecuritySettings(settings);
  }
}

/// Use case for creating default security settings
class CreateDefaultSecuritySettingsUseCase
    extends BaseUseCase<SecuritySettings, String> {
  final ISecurityRepository repository;

  CreateDefaultSecuritySettingsUseCase({required this.repository});

  @override
  Future<Result<SecuritySettings>> call(String userId) async {
    return await repository.createDefaultSettings(userId);
  }
}
