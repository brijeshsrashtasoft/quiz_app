import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase
    extends BaseUseCase<void, UpdateUserProfileParams> {
  final AuthRepository repository;
  UpdateUserProfileUseCase({required this.repository});

  @override
  Future<Result<void>> call(UpdateUserProfileParams params) async {
    if (params.displayName != null && params.displayName!.length > 100) {
      return Result.failure(
        ValidationFailure(
          message: 'Display name too long',
          code: 'invalid-display-name',
        ),
      );
    }
    return await repository.updateUserProfile(
      displayName: params.displayName,
      photoURL: params.photoURL,
    );
  }
}

class UpdateUserProfileParams extends BaseUseCaseParams {
  final String? displayName;
  final String? photoURL;
  const UpdateUserProfileParams({this.displayName, this.photoURL});
  @override
  List<Object?> get props => [displayName, photoURL];
}
