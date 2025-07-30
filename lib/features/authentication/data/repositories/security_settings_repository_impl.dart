import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_session.dart' as domain_entities;
import '../datasources/session_firestore_datasource.dart';
import '../models/session_models.dart';

/// Implementation of SecuritySettingsRepository using Firestore
/// Following CLAUDE.md Clean Architecture and free tier patterns
class SecuritySettingsRepositoryImpl implements SecuritySettingsRepository {
  final SessionFirestoreDataSource _dataSource;

  SecuritySettingsRepositoryImpl({required SessionFirestoreDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<domain_entities.SecuritySettings?>> getSecuritySettings(String userId) async {
    try {
      final settingsModel = await _dataSource.getSecuritySettings(userId);
      
      if (settingsModel == null) {
        return Result.success(null);
      }

      // Convert to domain entity
      final securitySettings = domain_entities.SecuritySettings(
        userId: settingsModel.userId,
        sessionTimeoutMinutes: settingsModel.sessionTimeoutMinutes,
        maxActiveSessions: settingsModel.maxActiveSessions,
        twoFactorEnabled: settingsModel.twoFactorEnabled,
        suspiciousActivityAlerts: settingsModel.suspiciousActivityAlerts,
        lastUpdated: settingsModel.lastUpdated,
      );

      return Result.success(securitySettings);
    } catch (e) {
      AppLogger.error('SecuritySettingsRepository: Failed to get security settings', e);
      return Result.failure(Failure.securityFailure(
        message: 'Failed to get security settings: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<domain_entities.SecuritySettings>> updateSecuritySettings(
    domain_entities.SecuritySettings settings,
  ) async {
    try {
      // Convert domain entity to data model
      final settingsModel = SecuritySettingsModel(
        userId: settings.userId,
        twoFactorEnabled: settings.twoFactorEnabled,
        sessionTimeoutEnabled: settings.sessionTimeoutEnabled,
        sessionTimeoutMinutes: settings.sessionTimeoutMinutes,
        maxActiveSessions: settings.maxActiveSessions,
        suspiciousActivityAlerts: settings.suspiciousActivityAlerts,
        newDeviceAlerts: settings.newDeviceAlerts,
        trustedDevices: settings.trustedDevices,
        lastUpdated: DateTime.now(),
      );

      final updatedModel = await _dataSource.updateSecuritySettings(settingsModel);

      // Convert back to domain entity
      final updatedSettings = domain_entities.SecuritySettings(
        userId: updatedModel.userId,
        sessionTimeoutMinutes: updatedModel.sessionTimeoutMinutes,
        maxActiveSessions: updatedModel.maxActiveSessions,
        twoFactorEnabled: updatedModel.twoFactorEnabled,
        suspiciousActivityAlerts: updatedModel.suspiciousActivityAlerts,
        newDeviceAlerts: updatedModel.newDeviceAlerts,
        trustedDevices: updatedModel.trustedDevices,
        lastUpdated: updatedModel.lastUpdated,
      );

      return Result.success(updatedSettings);
    } catch (e) {
      AppLogger.error('SecuritySettingsRepository: Failed to update security settings', e);
      return Result.failure(Failure.securityFailure(
        message: 'Failed to update security settings: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<domain_entities.SecuritySettings>> createDefaultSettings(String userId) async {
    return createDefaultSecuritySettings(userId);
  }

  Future<Result<domain_entities.SecuritySettings>> createDefaultSecuritySettings(String userId) async {
    try {
      // Create default settings
      final defaultSettings = domain_entities.SecuritySettings(
        userId: userId,
        sessionTimeoutMinutes: 30,
        maxActiveSessions: 5,
        twoFactorEnabled: false, // Default to false for better UX  
        suspiciousActivityAlerts: true,
        newDeviceAlerts: true,
        trustedDevices: [],
        lastUpdated: DateTime.now(),
      );

      return await updateSecuritySettings(defaultSettings);
    } catch (e) {
      AppLogger.error('SecuritySettingsRepository: Failed to create default settings', e);
      return Result.failure(Failure.securityFailure(
        message: 'Failed to create default security settings: ${e.toString()}',
      ));
    }
  }

  @override
  Stream<Result<domain_entities.SecuritySettings?>> watchSecuritySettings(String userId) {
    try {
      // This would require implementation in the data source
      throw UnimplementedError(
        'Security settings watching not implemented in data source. '
        'This would require Firestore streams implementation.',
      );
    } catch (e) {
      AppLogger.error('SecuritySettingsRepository: Failed to setup settings stream', e);
      return Stream.value(
        Result.failure(Failure.securityFailure(
          message: 'Failed to watch security settings: ${e.toString()}',
        )),
      );
    }
  }
}

/// Temporary SecuritySettings domain entity until proper one is created
class SecuritySettings {
  const SecuritySettings({
    required this.userId,
    required this.sessionTimeoutMinutes,
    required this.maxActiveSessions,
    required this.biometricEnabled,
    required this.deviceTrustRequired,
    required this.suspiciousActivityAlerts,
    this.lastUpdated,
  });

  final String userId;
  final int sessionTimeoutMinutes;
  final int maxActiveSessions;
  final bool biometricEnabled;
  final bool deviceTrustRequired;
  final bool suspiciousActivityAlerts;
  final DateTime? lastUpdated;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'maxActiveSessions': maxActiveSessions,
      'biometricEnabled': biometricEnabled,
      'deviceTrustRequired': deviceTrustRequired,
      'suspiciousActivityAlerts': suspiciousActivityAlerts,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

/// Temporary SecuritySettingsRepository interface until proper one is created
abstract class SecuritySettingsRepository {
  Future<Result<domain_entities.SecuritySettings?>> getSecuritySettings(String userId);
  Future<Result<domain_entities.SecuritySettings>> updateSecuritySettings(domain_entities.SecuritySettings settings);
  Future<Result<domain_entities.SecuritySettings>> createDefaultSettings(String userId);
  Stream<Result<domain_entities.SecuritySettings?>> watchSecuritySettings(String userId);
}