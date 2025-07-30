import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for deleting user account completely
/// Handles account deletion with proper cleanup
/// Following CLAUDE.md patterns and security considerations
class DeleteAccountUseCase extends BaseUseCase<void, DeleteAccountParams> {
  final ProfileRepository profileRepository;

  DeleteAccountUseCase({required this.profileRepository});

  @override
  Future<Result<void>> call(DeleteAccountParams params) async {
    try {
      AppLogger.info(
        'DeleteAccountUseCase',
        'Deleting account for user: ${params.userId}',
      );

      // Validate user permissions (only user can delete their own account)
      if (params.requestingUserId != params.userId && !params.isAdminRequest) {
        return Result.failure(
          Failure.authFailure(
            message: 'You can only delete your own account',
          ),
        );
      }

      // Confirm deletion with password or confirmation token
      if (!params.isConfirmed) {
        return Result.failure(
          Failure.serverFailure(
            message: 'Account deletion must be confirmed',
          ),
        );
      }

      final startTime = DateTime.now();

      // Delete account and all associated data
      final deleteResult = await profileRepository.deleteAccount(params.userId);
      if (!deleteResult.isSuccess) {
        return Result.failure(deleteResult.failureOrNull!);
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete Account Use Case', duration);
      AppLogger.info(
        'DeleteAccountUseCase',
        'Account deletion successful for user: ${params.userId}',
      );

      return Result.success(null);
    } catch (e) {
      AppLogger.error('Account deletion failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to delete account. Please contact support.',
        ),
      );
    }
  }
}

/// Parameters for DeleteAccountUseCase
class DeleteAccountParams extends BaseUseCaseParams {
  final String userId;
  final String requestingUserId;
  final bool isConfirmed;
  final bool isAdminRequest;
  final String? confirmationToken;

  const DeleteAccountParams({
    required this.userId,
    required this.requestingUserId,
    required this.isConfirmed,
    this.isAdminRequest = false,
    this.confirmationToken,
  });

  @override
  String toString() =>
      'DeleteAccountParams(userId: $userId, requestingUserId: $requestingUserId, isConfirmed: $isConfirmed)';
}
