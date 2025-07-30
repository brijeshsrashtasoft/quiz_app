import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending email verification
/// Following CLAUDE.md Clean Architecture patterns
class VerifyEmailUseCase extends BaseUseCaseNoParams<void> {
  final AuthRepository repository;

  VerifyEmailUseCase({required this.repository});

  @override
  Future<Result<void>> call() async {
    return await repository.sendEmailVerification();
  }
}

/// Use case for checking if current user's email is verified
/// Following CLAUDE.md Clean Architecture patterns
class CheckEmailVerificationUseCase extends BaseUseCaseNoParams<bool> {
  final AuthRepository repository;

  CheckEmailVerificationUseCase({required this.repository});

  @override
  Future<Result<bool>> call() async {
    return Result.success(repository.isEmailVerified);
  }
}
