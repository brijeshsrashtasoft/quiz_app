import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

/// Sign out use case
class SignOutUseCase extends BaseUseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      AppLogger.info('SignOutUseCase: Attempting sign out');
      return await repository.signOut();
    } catch (e) {
      AppLogger.error('SignOutUseCase: Unexpected error', e);
      return Result.failure(
        AuthFailure(
          message: 'An unexpected error occurred during sign out',
          code: 'unexpected-error',
        ),
      );
    }
  }
}
