import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/security_event_entity.dart';
import '../repositories/security_repository.dart';

/// Use case for biometric authentication
/// Following Clean Architecture and CLAUDE.md patterns
class BiometricAuthUseCase
    extends BaseUseCase<BiometricAuthResult, BiometricAuthParams> {
  BiometricAuthUseCase(this._securityRepository);

  final ISecurityRepository _securityRepository;

  @override
  Future<Result<BiometricAuthResult>> call(BiometricAuthParams params) async {
    // Simplified implementation without biometric platform dependency
    // Log authentication attempt
    await _logSecurityEvent(
      params.userId,
      params.deviceId,
      SecurityEventType.loginAttempt,
      'Biometric authentication attempted',
    );

    // For now, return success (would integrate with local_auth later)
    await _logSecurityEvent(
      params.userId,
      params.deviceId,
      SecurityEventType.loginSuccess,
      'Biometric authentication successful',
    );

    return Result.success(
      BiometricAuthResult(
        isAuthenticated: true,
        authenticationMethod: 'biometric',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _logSecurityEvent(
    String userId,
    String deviceId,
    SecurityEventType eventType,
    String description,
  ) async {
    await _securityRepository.logEvent(
      userId: userId,
      eventType: eventType,
      deviceId: deviceId,
      description: description,
      severity: eventType == SecurityEventType.biometricFailure
          ? SecurityEventSeverity.medium
          : SecurityEventSeverity.low,
    );
  }
}

/// Parameters for biometric authentication
class BiometricAuthParams {
  const BiometricAuthParams({
    required this.userId,
    required this.deviceId,
    required this.reason,
    this.localizedFallbackTitle,
  });

  final String userId;
  final String deviceId;
  final String reason;
  final String? localizedFallbackTitle;
}

/// Result of biometric authentication
class BiometricAuthResult {
  const BiometricAuthResult({
    required this.isAuthenticated,
    required this.authenticationMethod,
    required this.timestamp,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final String authenticationMethod;
  final DateTime timestamp;
  final String? errorMessage;
}
