import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/index.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/datasources/profile_local_datasource.dart';

/// Profile providers for Riverpod dependency injection
/// Following CLAUDE.md patterns and Clean Architecture

// Data source providers
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileFirebaseDataSource();
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return sharedPrefs.when(
    data: (prefs) => ProfileSharedPrefsDataSource(prefs: prefs),
    loading: () => throw Exception('SharedPreferences not yet loaded'),
    error: (error, stack) => throw Exception('Failed to load SharedPreferences: $error'),
  );
});

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    localDataSource: ref.read(profileLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use case providers
final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return UpdateUserProfileUseCase(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  return UploadAvatarUseCase(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final validateUsernameUseCaseProvider = Provider<ValidateUsernameUseCase>((ref) {
  return ValidateUsernameUseCase(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final getUserStatsUseCaseProvider = Provider<GetUserStatsUseCase>((ref) {
  return GetUserStatsUseCase(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final updatePreferencesUseCaseProvider = Provider<UpdatePreferencesUseCase>((ref) {
  return UpdatePreferencesUseCase(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

// Profile state providers
final currentUserProfileProvider = StateNotifierProvider<CurrentUserProfileNotifier, AsyncValue<UserProfileEntity?>>((ref) {
  return CurrentUserProfileNotifier(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final profileCompletionProvider = Provider<double>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.profileCompletionPercentage ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

final profileStatsProvider = Provider<UserStats?>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.stats,
    loading: () => null,
    error: (_, __) => null,
  );
});

final userPreferencesProvider = Provider<UserPreferences?>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.preferences,
    loading: () => null,
    error: (_, __) => null,
  );
});

final privacySettingsProvider = Provider<PrivacySettings?>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.privacySettings,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Profile operations providers
final profileUpdateLoadingProvider = StateProvider<bool>((ref) => false);
final avatarUploadLoadingProvider = StateProvider<bool>((ref) => false);
final usernameValidationProvider = StateProvider<String?>((ref) => null);

/// Current user profile state notifier
class CurrentUserProfileNotifier extends StateNotifier<AsyncValue<UserProfileEntity?>> {
  final ProfileRepository _profileRepository;
  String? _currentUserId;

  CurrentUserProfileNotifier({
    required ProfileRepository profileRepository,
  })  : _profileRepository = profileRepository,
        super(const AsyncValue.loading());

  /// Load user profile
  Future<void> loadProfile(String userId) async {
    if (_currentUserId == userId && state.hasValue) {
      // Already loaded for this user
      return;
    }

    _currentUserId = userId;
    state = const AsyncValue.loading();

    final result = await _profileRepository.getProfile(userId);
    
    state = result.when(
      success: (profile) => AsyncValue.data(profile),
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Update profile
  Future<Result<UserProfileEntity>> updateProfile(UserProfileEntity profile) async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    final result = await _profileRepository.updateProfile(profile);
    
    if (result.isSuccess) {
      state = AsyncValue.data(result.dataOrNull);
    }
    
    return result;
  }

  /// Update user stats
  Future<Result<UserProfileEntity>> updateStats(UserStats stats) async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    final result = await _profileRepository.updateUserStats(_currentUserId!, stats);
    
    if (result.isSuccess) {
      state = AsyncValue.data(result.dataOrNull);
    }
    
    return result;
  }

  /// Update preferences
  Future<Result<UserProfileEntity>> updatePreferences(UserPreferences preferences) async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    final result = await _profileRepository.updateUserPreferences(_currentUserId!, preferences);
    
    if (result.isSuccess) {
      state = AsyncValue.data(result.dataOrNull);
    }
    
    return result;
  }

  /// Update privacy settings
  Future<Result<UserProfileEntity>> updatePrivacySettings(PrivacySettings privacySettings) async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    final result = await _profileRepository.updatePrivacySettings(_currentUserId!, privacySettings);
    
    if (result.isSuccess) {
      state = AsyncValue.data(result.dataOrNull);
    }
    
    return result;
  }

  /// Upload avatar
  Future<Result<String>> uploadAvatar(File imageFile) async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    return await _profileRepository.uploadAvatar(_currentUserId!, imageFile);
  }

  /// Delete avatar
  Future<Result<void>> deleteAvatar() async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    return await _profileRepository.deleteAvatar(_currentUserId!);
  }

  /// Check username availability
  Future<Result<bool>> isUsernameAvailable(String username) async {
    return await _profileRepository.isUsernameAvailable(username);
  }

  /// Get profile completion suggestions
  Future<Result<List<String>>> getCompletionSuggestions() async {
    if (_currentUserId == null) {
      return Result.failure(
        Failure.serverFailure(
          message: 'No user logged in',
        ),
      );
    }

    return await _profileRepository.getProfileCompletionSuggestions(_currentUserId!);
  }

  /// Watch profile for real-time updates
  void watchProfile(String userId) {
    _currentUserId = userId;
    state = const AsyncValue.loading();

    _profileRepository.watchProfile(userId).listen(
      (result) {
        state = result.when(
          success: (profile) => AsyncValue.data(profile),
          failure: (failure) => AsyncValue.error(failure, StackTrace.current),
        );
      },
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  /// Clear profile state
  void clearProfile() {
    _currentUserId = null;
    state = const AsyncValue.data(null);
  }
}

// Network info provider (this should be defined in core/network module)
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Profile search provider for finding other users
final profileSearchProvider = StateNotifierProvider<ProfileSearchNotifier, AsyncValue<List<UserProfileEntity>>>((ref) {
  return ProfileSearchNotifier(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

/// Profile search state notifier
class ProfileSearchNotifier extends StateNotifier<AsyncValue<List<UserProfileEntity>>> {
  final ProfileRepository _profileRepository;

  ProfileSearchNotifier({
    required ProfileRepository profileRepository,
  })  : _profileRepository = profileRepository,
        super(const AsyncValue.data([]));

  /// Search profiles by query
  Future<void> searchProfiles(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    final result = await _profileRepository.searchProfiles(query);
    
    state = result.when(
      success: (profiles) => AsyncValue.data(profiles),
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Clear search results
  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

/// Top users leaderboard provider
final topUsersProvider = FutureProvider.family<List<UserProfileEntity>, int>((ref, limit) async {
  final repository = ref.read(profileRepositoryProvider);
  final result = await repository.getTopUsers(limit);
  
  return result.when(
    success: (users) => users,
    failure: (failure) => throw failure,
  );
});