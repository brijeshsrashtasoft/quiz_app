import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase extends BaseUseCase<void, NoParams> {
  final AuthRepository repository;
  SendEmailVerificationUseCase({required this.repository});

  @override
  Future<Result<void>> call(NoParams params) async {
    return await repository.sendEmailVerification();
  }
}
