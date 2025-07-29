import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for creating a new user
/// Following CLAUDE.md business logic patterns
class CreateUserUseCase extends BaseUseCase<UserEntity, CreateUserParams> {
  final UserRepository repository;

  CreateUserUseCase({required this.repository});

  @override
  Future<Result<UserEntity>> call(CreateUserParams params) async {
    return await repository.createUser(params.user);
  }
}

/// Parameters for CreateUserUseCase
class CreateUserParams {
  final UserEntity user;

  const CreateUserParams({required this.user});
}
