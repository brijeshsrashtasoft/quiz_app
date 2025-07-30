import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for getting user by ID
/// Following CLAUDE.md business logic patterns
class GetUserByIdUseCase extends BaseUseCase<UserEntity, GetUserByIdParams> {
  final UserRepository repository;

  GetUserByIdUseCase({required this.repository});

  @override
  Future<Result<UserEntity>> call(GetUserByIdParams params) async {
    return await repository.getUserById(params.userId);
  }
}

/// Parameters for GetUserByIdUseCase
class GetUserByIdParams {
  final String userId;

  const GetUserByIdParams({required this.userId});
}
