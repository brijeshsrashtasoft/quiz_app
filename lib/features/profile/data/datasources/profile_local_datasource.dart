import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

/// Local data source for profile caching and offline support
/// Following CLAUDE.md patterns and performance optimization
abstract class ProfileLocalDataSource {
  /// Cache user profile locally
  Future<void> cacheProfile(UserProfileModel profile);

  /// Get cached profile
  Future<UserProfileModel?> getCachedProfile(String userId);

  /// Remove cached profile
  Future<void> removeCachedProfile(String userId);

  /// Clear all cached profiles
  Future<void> clearAllCachedProfiles();

  /// Cache user preferences
  Future<void> cacheUserPreferences(String userId, UserPreferencesModel preferences);

  /// Get cached user preferences
  Future<UserPreferencesModel?> getCachedUserPreferences(String userId);

  /// Cache user stats
  Future<void> cacheUserStats(String userId, UserStatsModel stats);

  /// Get cached user stats
  Future<UserStatsModel?> getCachedUserStats(String userId);

  /// Check if profile is cached
  Future<bool> isProfileCached(String userId);

  /// Get cache timestamp for profile
  Future<DateTime?> getProfileCacheTimestamp(String userId);

  /// Cache last sync timestamp
  Future<void> setLastSyncTimestamp(String userId, DateTime timestamp);

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp(String userId);
}

/// SharedPreferences implementation of ProfileLocalDataSource
class ProfileSharedPrefsDataSource implements ProfileLocalDataSource {
  final SharedPreferences _prefs;

  ProfileSharedPrefsDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  /// Key generators for consistent storage
  String _profileKey(String userId) => 'profile_$userId';
  String _preferencesKey(String userId) => 'preferences_$userId';
  String _statsKey(String userId) => 'stats_$userId';
  String _cacheTimestampKey(String userId) => 'cache_timestamp_$userId';
  String _syncTimestampKey(String userId) => 'sync_timestamp_$userId';

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Caching profile: ${profile.id}');

      final profileJson = json.encode(profile.toJson());
      final cacheTimestamp = DateTime.now().toIso8601String();

      await _prefs.setString(_profileKey(profile.id), profileJson);
      await _prefs.setString(_cacheTimestampKey(profile.id), cacheTimestamp);

      AppLogger.info('ProfileLocalDataSource', 'Profile cached successfully: ${profile.id}');
    } catch (e) {
      AppLogger.error('Cache profile failed', e);
      throw CacheException(message: 'Failed to cache profile');
    }
  }

  @override
  Future<UserProfileModel?> getCachedProfile(String userId) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Getting cached profile: $userId');

      final profileJson = _prefs.getString(_profileKey(userId));
      if (profileJson == null) {
        AppLogger.info('ProfileLocalDataSource', 'No cached profile found: $userId');
        return null;
      }

      final profileMap = json.decode(profileJson) as Map<String, dynamic>;
      final profile = UserProfileModel.fromJson(profileMap);

      AppLogger.info('ProfileLocalDataSource', 'Cached profile retrieved: $userId');
      return profile;
    } catch (e) {
      AppLogger.error('Get cached profile failed', e);
      // If cache is corrupted, remove it and return null
      await removeCachedProfile(userId);
      return null;
    }
  }

  @override
  Future<void> removeCachedProfile(String userId) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Removing cached profile: $userId');

      await _prefs.remove(_profileKey(userId));
      await _prefs.remove(_cacheTimestampKey(userId));
      await _prefs.remove(_syncTimestampKey(userId));
      await _prefs.remove(_preferencesKey(userId));
      await _prefs.remove(_statsKey(userId));

      AppLogger.info('ProfileLocalDataSource', 'Cached profile removed: $userId');
    } catch (e) {
      AppLogger.error('Remove cached profile failed', e);
      throw CacheException(message: 'Failed to remove cached profile');
    }
  }

  @override
  Future<void> clearAllCachedProfiles() async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Clearing all cached profiles');

      final keys = _prefs.getKeys();
      final profileKeys = keys.where((key) => 
        key.startsWith('profile_') || 
        key.startsWith('preferences_') || 
        key.startsWith('stats_') ||
        key.startsWith('cache_timestamp_') ||
        key.startsWith('sync_timestamp_')
      ).toList();

      for (final key in profileKeys) {
        await _prefs.remove(key);
      }

      AppLogger.info('ProfileLocalDataSource', 'All cached profiles cleared');
    } catch (e) {
      AppLogger.error('Clear all cached profiles failed', e);
      throw CacheException(message: 'Failed to clear cached profiles');
    }
  }

  @override
  Future<void> cacheUserPreferences(String userId, UserPreferencesModel preferences) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Caching user preferences: $userId');

      final preferencesJson = json.encode(preferences.toJson());
      await _prefs.setString(_preferencesKey(userId), preferencesJson);

      AppLogger.info('ProfileLocalDataSource', 'User preferences cached: $userId');
    } catch (e) {
      AppLogger.error('Cache user preferences failed', e);
      throw CacheException(message: 'Failed to cache user preferences');
    }
  }

  @override
  Future<UserPreferencesModel?> getCachedUserPreferences(String userId) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Getting cached user preferences: $userId');

      final preferencesJson = _prefs.getString(_preferencesKey(userId));
      if (preferencesJson == null) {
        AppLogger.info('ProfileLocalDataSource', 'No cached preferences found: $userId');
        return null;
      }

      final preferencesMap = json.decode(preferencesJson) as Map<String, dynamic>;
      final preferences = UserPreferencesModel.fromJson(preferencesMap);

      AppLogger.info('ProfileLocalDataSource', 'Cached preferences retrieved: $userId');
      return preferences;
    } catch (e) {
      AppLogger.error('Get cached user preferences failed', e);
      // If cache is corrupted, remove it and return null
      await _prefs.remove(_preferencesKey(userId));
      return null;
    }
  }

  @override
  Future<void> cacheUserStats(String userId, UserStatsModel stats) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Caching user stats: $userId');

      final statsJson = json.encode(stats.toJson());
      await _prefs.setString(_statsKey(userId), statsJson);

      AppLogger.info('ProfileLocalDataSource', 'User stats cached: $userId');
    } catch (e) {
      AppLogger.error('Cache user stats failed', e);
      throw CacheException(message: 'Failed to cache user stats');
    }
  }

  @override
  Future<UserStatsModel?> getCachedUserStats(String userId) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Getting cached user stats: $userId');

      final statsJson = _prefs.getString(_statsKey(userId));
      if (statsJson == null) {
        AppLogger.info('ProfileLocalDataSource', 'No cached stats found: $userId');
        return null;
      }

      final statsMap = json.decode(statsJson) as Map<String, dynamic>;
      final stats = UserStatsModel.fromJson(statsMap);

      AppLogger.info('ProfileLocalDataSource', 'Cached stats retrieved: $userId');
      return stats;
    } catch (e) {
      AppLogger.error('Get cached user stats failed', e);
      // If cache is corrupted, remove it and return null
      await _prefs.remove(_statsKey(userId));
      return null;
    }
  }

  @override
  Future<bool> isProfileCached(String userId) async {
    try {
      return _prefs.containsKey(_profileKey(userId));
    } catch (e) {
      AppLogger.error('Check profile cached failed', e);
      return false;
    }
  }

  @override
  Future<DateTime?> getProfileCacheTimestamp(String userId) async {
    try {
      final timestampString = _prefs.getString(_cacheTimestampKey(userId));
      if (timestampString == null) return null;

      return DateTime.parse(timestampString);
    } catch (e) {
      AppLogger.error('Get profile cache timestamp failed', e);
      return null;
    }
  }

  @override
  Future<void> setLastSyncTimestamp(String userId, DateTime timestamp) async {
    try {
      AppLogger.info('ProfileLocalDataSource', 'Setting last sync timestamp: $userId');

      await _prefs.setString(_syncTimestampKey(userId), timestamp.toIso8601String());
    } catch (e) {
      AppLogger.error('Set last sync timestamp failed', e);
      throw CacheException(message: 'Failed to set last sync timestamp');
    }
  }

  @override
  Future<DateTime?> getLastSyncTimestamp(String userId) async {
    try {
      final timestampString = _prefs.getString(_syncTimestampKey(userId));
      if (timestampString == null) return null;

      return DateTime.parse(timestampString);
    } catch (e) {
      AppLogger.error('Get last sync timestamp failed', e);
      return null;
    }
  }
}