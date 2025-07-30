// Mockito annotations for authentication security and session management
import 'package:mockito/annotations.dart';
import 'package:quiz_app/features/authentication/domain/repositories/security_repository.dart';
import 'package:quiz_app/features/authentication/domain/repositories/session_repository.dart';
import 'package:quiz_app/features/authentication/domain/repositories/device_repository.dart';
import 'package:quiz_app/features/authentication/domain/repositories/biometric_repository.dart';

@GenerateMocks([
  ISecurityRepository,
  ISessionRepository,
  IDeviceRepository,
  IBiometricRepository,
])
void main() {}
