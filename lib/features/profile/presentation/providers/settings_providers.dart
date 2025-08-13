import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/domain/entities/auth_state.dart';
import '../../../../shared/theme/theme_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';

/// Settings state class
class SettingsState {
  final UserPreferences preferences;
  final PrivacySettings privacySettings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.preferences,
    required this.privacySettings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    UserPreferences? preferences,
    PrivacySettings? privacySettings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      preferences: preferences ?? this.preferences,
      privacySettings: privacySettings ?? this.privacySettings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Settings state notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final UpdatePreferencesUseCase _updatePreferencesUseCase;
  final Ref _ref;

  SettingsNotifier(this._updatePreferencesUseCase, this._ref)
    : super(
        SettingsState(
          preferences: const UserPreferences(),
          privacySettings: const PrivacySettings(),
        ),
      ) {
    _loadSettings();
  }

  /// Load settings from local storage and user profile
  Future<void> _loadSettings() async {
    try {
      state = state.copyWith(isLoading: true);

      // Load from SharedPreferences first for immediate response
      await _loadLocalSettings();

      // Then sync with remote profile if user is authenticated
      final authState = _ref.read(authStateProvider);
      authState.whenData((state) async {
        if (state.isAuthenticated) {
          await _syncWithRemoteProfile();
        }
      });
    } catch (e) {
      AppLogger.error('Failed to load settings', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings',
      );
    }
  }

  /// Load settings from local storage
  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final preferences = UserPreferences(
      soundEnabled: prefs.getBool('settings_sound') ?? true,
      notificationsEnabled: prefs.getBool('settings_notifications') ?? true,
      vibrationEnabled: prefs.getBool('settings_vibration') ?? true,
      theme: prefs.getString('settings_theme') ?? 'light',
      language: prefs.getString('settings_language') ?? 'en',
      difficultyPreference: prefs.getString('settings_difficulty') ?? 'medium',
      showOnlineStatus: prefs.getBool('settings_online_status') ?? true,
      allowFriendRequests: prefs.getBool('settings_friend_requests') ?? true,
    );

    final privacySettings = PrivacySettings(
      profileVisible: prefs.getBool('privacy_profile_visible') ?? true,
      statsVisible: prefs.getBool('privacy_stats_visible') ?? true,
      emailVisible: prefs.getBool('privacy_email_visible') ?? false,
      allowGameInvites: prefs.getBool('privacy_game_invites') ?? true,
      showInLeaderboards: prefs.getBool('privacy_leaderboards') ?? true,
      shareDataForAnalytics: prefs.getBool('privacy_analytics') ?? false,
    );

    state = state.copyWith(
      preferences: preferences,
      privacySettings: privacySettings,
      isLoading: false,
      error: null,
    );
  }

  /// Sync with remote user profile
  Future<void> _syncWithRemoteProfile() async {
    // This would load from the user profile repository
    // For now, we'll use local settings as the source of truth
    AppLogger.info('Settings', 'Settings synced with remote profile');
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences newPreferences) async {
    try {
      state = state.copyWith(isLoading: true);

      // Save to local storage immediately
      await _savePreferencesLocally(newPreferences);

      // Update state
      state = state.copyWith(
        preferences: newPreferences,
        isLoading: false,
        error: null,
      );

      // Sync theme changes
      if (newPreferences.theme != state.preferences.theme) {
        _ref
            .read(themeModeProvider.notifier)
            .setThemeMode(_getThemeModeFromString(newPreferences.theme));
      }

      // Sync with remote if user is authenticated
      final authState = _ref.read(authStateProvider);
      authState.whenData((state) async {
        state.maybeWhen(
          authenticated: (user) async {
            await _syncPreferencesWithRemote(user.id, newPreferences);
          },
          orElse: () {},
        );
      });

      AppLogger.info('Settings', 'Preferences updated successfully');
    } catch (e) {
      AppLogger.error('Failed to update preferences', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update preferences',
      );
    }
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettings newPrivacySettings) async {
    try {
      state = state.copyWith(isLoading: true);

      // Save to local storage
      await _savePrivacySettingsLocally(newPrivacySettings);

      // Update state
      state = state.copyWith(
        privacySettings: newPrivacySettings,
        isLoading: false,
        error: null,
      );

      // Sync with remote if user is authenticated
      final authState = _ref.read(authStateProvider);
      authState.whenData((state) async {
        state.maybeWhen(
          authenticated: (user) async {
            await _syncPrivacySettingsWithRemote(user.id, newPrivacySettings);
          },
          orElse: () {},
        );
      });

      AppLogger.info('Settings', 'Privacy settings updated successfully');
    } catch (e) {
      AppLogger.error('Failed to update privacy settings', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update privacy settings',
      );
    }
  }

  /// Save preferences to local storage
  Future<void> _savePreferencesLocally(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setBool('settings_sound', preferences.soundEnabled),
      prefs.setBool('settings_notifications', preferences.notificationsEnabled),
      prefs.setBool('settings_vibration', preferences.vibrationEnabled),
      prefs.setString('settings_theme', preferences.theme),
      prefs.setString('settings_language', preferences.language),
      prefs.setString('settings_difficulty', preferences.difficultyPreference),
      prefs.setBool('settings_online_status', preferences.showOnlineStatus),
      prefs.setBool(
        'settings_friend_requests',
        preferences.allowFriendRequests,
      ),
    ]);
  }

  /// Save privacy settings to local storage
  Future<void> _savePrivacySettingsLocally(
    PrivacySettings privacySettings,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setBool('privacy_profile_visible', privacySettings.profileVisible),
      prefs.setBool('privacy_stats_visible', privacySettings.statsVisible),
      prefs.setBool('privacy_email_visible', privacySettings.emailVisible),
      prefs.setBool('privacy_game_invites', privacySettings.allowGameInvites),
      prefs.setBool('privacy_leaderboards', privacySettings.showInLeaderboards),
      prefs.setBool('privacy_analytics', privacySettings.shareDataForAnalytics),
    ]);
  }

  /// Sync preferences with remote profile
  Future<void> _syncPreferencesWithRemote(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      final params = UpdatePreferencesParams(
        userId: userId,
        preferences: preferences,
      );

      final result = await _updatePreferencesUseCase(params);

      if (!result.isSuccess) {
        AppLogger.warning('Settings', 'Failed to sync preferences with remote');
      }
    } catch (e) {
      AppLogger.error('Failed to sync preferences with remote', e);
    }
  }

  /// Sync privacy settings with remote profile
  Future<void> _syncPrivacySettingsWithRemote(
    String userId,
    PrivacySettings privacySettings,
  ) async {
    // This would be implemented when privacy settings usecase is created
    AppLogger.info('Settings', 'Privacy settings sync not yet implemented');
  }

  /// Convert theme string to ThemeMode
  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// Individual preference update methods for UI

  Future<void> updateSoundEnabled(bool enabled) async {
    await updatePreferences(state.preferences.copyWith(soundEnabled: enabled));
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await updatePreferences(
      state.preferences.copyWith(notificationsEnabled: enabled),
    );
  }

  Future<void> updateVibrationEnabled(bool enabled) async {
    await updatePreferences(
      state.preferences.copyWith(vibrationEnabled: enabled),
    );
  }

  Future<void> updateTheme(String theme) async {
    await updatePreferences(state.preferences.copyWith(theme: theme));
  }

  Future<void> updateShowOnlineStatus(bool show) async {
    await updatePreferences(state.preferences.copyWith(showOnlineStatus: show));
  }

  Future<void> updateProfileVisible(bool visible) async {
    await updatePrivacySettings(
      state.privacySettings.copyWith(profileVisible: visible),
    );
  }

  Future<void> updateStatsVisible(bool visible) async {
    await updatePrivacySettings(
      state.privacySettings.copyWith(statsVisible: visible),
    );
  }

  Future<void> updateAllowGameInvites(bool allow) async {
    await updatePrivacySettings(
      state.privacySettings.copyWith(allowGameInvites: allow),
    );
  }

  Future<void> updateShowInLeaderboards(bool show) async {
    await updatePrivacySettings(
      state.privacySettings.copyWith(showInLeaderboards: show),
    );
  }

  /// Clear all settings (for account deletion/logout)
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all settings-related keys
    final settingsKeys = [
      'settings_sound',
      'settings_notifications',
      'settings_vibration',
      'settings_theme',
      'settings_language',
      'settings_difficulty',
      'settings_online_status',
      'settings_friend_requests',
      'privacy_profile_visible',
      'privacy_stats_visible',
      'privacy_email_visible',
      'privacy_game_invites',
      'privacy_leaderboards',
      'privacy_analytics',
    ];

    for (final key in settingsKeys) {
      await prefs.remove(key);
    }

    // Reset to default state
    state = SettingsState(
      preferences: const UserPreferences(),
      privacySettings: const PrivacySettings(),
    );

    AppLogger.info('Settings', 'All settings cleared');
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final updatePreferencesUseCase = ref.read(updatePreferencesUseCaseProvider);
    return SettingsNotifier(updatePreferencesUseCase, ref);
  },
);

/// Individual settings providers for easy access
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  return ref.watch(settingsProvider).preferences;
});

final privacySettingsProvider = Provider<PrivacySettings>((ref) {
  return ref.watch(settingsProvider).privacySettings;
});

final isSettingsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isLoading;
});

/// Mock provider for update preferences use case
/// This should be replaced with the actual implementation when the repository is ready
final updatePreferencesUseCaseProvider = Provider<UpdatePreferencesUseCase>((
  ref,
) {
  return MockUpdatePreferencesUseCase();
});

/// Mock implementation for development
class MockUpdatePreferencesUseCase extends UpdatePreferencesUseCase {
  MockUpdatePreferencesUseCase()
    : super(profileRepository: MockProfileRepository());

  @override
  Future<Result<UserProfileEntity>> call(UpdatePreferencesParams params) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Always return success for development
    AppLogger.info(
      'MockUpdatePreferencesUseCase',
      'Mock preferences update successful',
    );

    return Result.success(
      UserProfileEntity(
        id: params.userId,
        name: 'Mock User',
        email: 'user@example.com',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        preferences: params.preferences,
      ),
    );
  }
}

/// Mock profile repository
class MockProfileRepository implements ProfileRepository {
  @override
  Future<Result<UserProfileEntity>> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(
      UserProfileEntity(
        id: userId,
        name: 'Mock User',
        email: 'user@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: preferences,
      ),
    );
  }

  // Mock implementations for all required methods
  @override
  Future<Result<UserProfileEntity>> getProfile(String userId) async {
    return Result.success(
      UserProfileEntity(
        id: userId,
        name: 'Mock User',
        email: 'user@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<UserProfileEntity>> updateProfile(
    UserProfileEntity profile,
  ) async {
    return Result.success(profile);
  }

  @override
  Future<Result<void>> deleteAccount(String userId) async {
    return Result.success(null);
  }

  @override
  Future<Result<String>> uploadAvatar(String userId, dynamic imageFile) async {
    return Result.success('mock-avatar-url');
  }

  @override
  Future<Result<void>> deleteAvatar(String userId) async {
    return Result.success(null);
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async {
    return Result.success(true);
  }

  @override
  Future<Result<UserProfileEntity>> updateUserStats(
    String userId,
    dynamic stats,
  ) async {
    return getProfile(userId);
  }

  @override
  Future<Result<UserProfileEntity>> updatePrivacySettings(
    String userId,
    PrivacySettings settings,
  ) async {
    return getProfile(userId);
  }

  @override
  Future<Result<UserProfileEntity>> updateOnboardingStatus(
    String userId,
    dynamic status,
  ) async {
    return getProfile(userId);
  }

  @override
  Future<Result<List<UserProfileEntity>>> searchProfiles(String query) async {
    return Result.success([]);
  }

  @override
  Future<Result<List<UserProfileEntity>>> getTopUsers(int limit) async {
    return Result.success([]);
  }

  @override
  Future<Result<List<UserProfileEntity>>> getUserConnections(
    String userId,
  ) async {
    return Result.success([]);
  }

  @override
  Stream<Result<UserProfileEntity>> watchProfile(String userId) async* {
    yield await getProfile(userId);
  }

  @override
  Future<Result<List<String>>> getProfileCompletionSuggestions(
    String userId,
  ) async {
    return Result.success(['Complete your profile', 'Add a profile picture']);
  }

  @override
  Future<Result<bool>> validateProfileData(UserProfileEntity profile) async {
    return Result.success(true);
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserActivitySummary(
    String userId,
  ) async {
    return Result.success({});
  }

  @override
  Future<Result<UserProfileEntity>> updateUserLevel(String userId) async {
    return getProfile(userId);
  }

  @override
  Future<Result<List<UserProfileEntity>>> getUsersByRegion(
    String region,
  ) async {
    return Result.success([]);
  }

  @override
  Future<Result<void>> blockUser(String userId, String targetUserId) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> unblockUser(String userId, String targetUserId) async {
    return Result.success(null);
  }

  @override
  Future<Result<List<String>>> getBlockedUsers(String userId) async {
    return Result.success([]);
  }

  @override
  Future<Result<void>> reportUser(
    String userId,
    String targetUserId,
    String reason,
  ) async {
    return Result.success(null);
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getUserReports(
    String userId,
  ) async {
    return Result.success([]);
  }
}
