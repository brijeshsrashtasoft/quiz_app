import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase
    extends BaseUseCase<void, SendPasswordResetParams> {
  final AuthRepository repository;

  SendPasswordResetUseCase({required this.repository});

  @override
  Future<Result<void>> call(SendPasswordResetParams params) async {
    try {
      if (!_isValidEmail(params.email)) {
        return Result.failure(
          ValidationFailure(message: 'Please enter a valid email address'),
        );
      }
      return await repository.sendPasswordResetEmail(email: params.email);
    } catch (e) {
      return Result.failure(
        AuthFailure(
          message: 'Failed to send password reset email',
          code: 'password-reset-error',
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }
}

class SendPasswordResetParams extends BaseUseCaseParams {
  final String email;
  const SendPasswordResetParams({required this.email});
  @override
  List<Object?> get props => [email];
}
