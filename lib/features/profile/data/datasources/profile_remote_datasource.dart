import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

/// Remote data source for profile operations using Firebase
/// Following CLAUDE.md patterns and free tier compliance
abstract class ProfileRemoteDataSource {
  /// Get user profile by ID
  Future<UserProfileModel> getProfile(String userId);

  /// Update user profile
  Future<UserProfileModel> updateProfile(UserProfileModel profile);

  /// Upload avatar image
  Future<String> uploadAvatar(String userId, File imageFile);

  /// Delete avatar image
  Future<void> deleteAvatar(String userId);

  /// Check username availability
  Future<bool> isUsernameAvailable(String username);

  /// Update user statistics
  Future<UserProfileModel> updateUserStats(String userId, UserStatsModel stats);

  /// Update user preferences
  Future<UserProfileModel> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
  );

  /// Update privacy settings
  Future<UserProfileModel> updatePrivacySettings(
    String userId,
    PrivacySettingsModel privacySettings,
  );

  /// Update onboarding status
  Future<UserProfileModel> updateOnboardingStatus(
    String userId,
    OnboardingStatusModel onboardingStatus,
  );

  /// Delete user account
  Future<void> deleteAccount(String userId);

  /// Search profiles by username
  Future<List<UserProfileModel>> searchProfiles(String query);

  /// Get top users by points
  Future<List<UserProfileModel>> getTopUsers(int limit);

  /// Stream profile for real-time updates
  Stream<UserProfileModel> watchProfile(String userId);

  /// Block/unblock user
  Future<void> blockUser(String userId, String targetUserId);
  Future<void> unblockUser(String userId, String targetUserId);

  /// Get blocked users
  Future<List<String>> getBlockedUsers(String userId);

  /// Report user
  Future<void> reportUser(
    String reporterId,
    String reportedUserId,
    String reason,
  );
}

/// Firebase implementation of ProfileRemoteDataSource
class ProfileFirebaseDataSource implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileFirebaseDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  /// Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _blockedUsersCollection =>
      _firestore.collection('blocked_users');
  CollectionReference get _reportsCollection =>
      _firestore.collection('user_reports');

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Getting profile: $userId');

      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        throw ServerException(message: 'Profile not found', code: '404');
      }

      final data = doc.data() as Map<String, dynamic>;
      return UserProfileModel.fromFirestore(data);
    } catch (e) {
      AppLogger.error('Get profile failed', e);
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get profile', code: '500');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Updating profile: ${profile.id}',
      );

      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      await _usersCollection
          .doc(profile.id)
          .update(updatedProfile.toFirestore());

      return updatedProfile;
    } catch (e) {
      AppLogger.error('Update profile failed', e);
      throw ServerException(message: 'Failed to update profile', code: '500');
    }
  }

  @override
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Uploading avatar: $userId');

      // Create storage reference
      final storageRef = _storage.ref().child(
        'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}',
      );

      // Upload file
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Avatar upload successful: $userId',
      );
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Avatar upload failed', e);
      throw ServerException(message: 'Failed to upload avatar', code: '500');
    }
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Deleting avatar: $userId');

      // List all files in user's avatar folder
      final listResult = await _storage
          .ref()
          .child('avatars/$userId')
          .listAll();

      // Delete all avatar files
      for (final item in listResult.items) {
        await item.delete();
      }

      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Avatar deletion successful: $userId',
      );
    } catch (e) {
      AppLogger.error('Avatar deletion failed', e);
      throw ServerException(message: 'Failed to delete avatar', code: '500');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Checking username availability: $username',
      );

      final query = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      AppLogger.error('Username check failed', e);
      throw ServerException(
        message: 'Failed to check username availability',
        code: '500',
      );
    }
  }

  @override
  Future<UserProfileModel> updateUserStats(
    String userId,
    UserStatsModel stats,
  ) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Updating user stats: $userId',
      );

      await _usersCollection.doc(userId).update({
        'stats': stats.toFirestore(),
        'updatedAt': DateTime.now(),
      });

      return await getProfile(userId);
    } catch (e) {
      AppLogger.error('Update user stats failed', e);
      throw ServerException(
        message: 'Failed to update user statistics',
        code: '500',
      );
    }
  }

  @override
  Future<UserProfileModel> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
  ) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Updating user preferences: $userId',
      );

      await _usersCollection.doc(userId).update({
        'preferences': preferences.toFirestore(),
        'updatedAt': DateTime.now(),
      });

      return await getProfile(userId);
    } catch (e) {
      AppLogger.error('Update user preferences failed', e);
      throw ServerException(
        message: 'Failed to update user preferences',
        code: '500',
      );
    }
  }

  @override
  Future<UserProfileModel> updatePrivacySettings(
    String userId,
    PrivacySettingsModel privacySettings,
  ) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Updating privacy settings: $userId',
      );

      await _usersCollection.doc(userId).update({
        'privacySettings': privacySettings.toFirestore(),
        'updatedAt': DateTime.now(),
      });

      return await getProfile(userId);
    } catch (e) {
      AppLogger.error('Update privacy settings failed', e);
      throw ServerException(
        message: 'Failed to update privacy settings',
        code: '500',
      );
    }
  }

  @override
  Future<UserProfileModel> updateOnboardingStatus(
    String userId,
    OnboardingStatusModel onboardingStatus,
  ) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Updating onboarding status: $userId',
      );

      await _usersCollection.doc(userId).update({
        'onboardingStatus': onboardingStatus.toFirestore(),
        'updatedAt': DateTime.now(),
      });

      return await getProfile(userId);
    } catch (e) {
      AppLogger.error('Update onboarding status failed', e);
      throw ServerException(
        message: 'Failed to update onboarding status',
        code: '500',
      );
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Deleting account: $userId');

      // Use batch write for atomic deletion
      final batch = _firestore.batch();

      // Delete user profile
      batch.delete(_usersCollection.doc(userId));

      // Delete user's blocked users records
      final blockedQuery = await _blockedUsersCollection
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in blockedQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's reports
      final reportsQuery = await _reportsCollection
          .where('reportedUserId', isEqualTo: userId)
          .get();
      for (final doc in reportsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Delete avatar files
      try {
        await deleteAvatar(userId);
      } catch (e) {
        // Log but don't fail account deletion if avatar deletion fails
        AppLogger.warning('Avatar deletion failed during account deletion', e);
      }

      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Account deletion successful: $userId',
      );
    } catch (e) {
      AppLogger.error('Account deletion failed', e);
      throw ServerException(message: 'Failed to delete account', code: '500');
    }
  }

  @override
  Future<List<UserProfileModel>> searchProfiles(String query) async {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Searching profiles: $query');

      final querySnapshot = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: '${query}z')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => UserProfileModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Search profiles failed', e);
      throw ServerException(message: 'Failed to search profiles', code: '500');
    }
  }

  @override
  Future<List<UserProfileModel>> getTopUsers(int limit) async {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Getting top users: $limit');

      final querySnapshot = await _usersCollection
          .orderBy('stats.totalPoints', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => UserProfileModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Get top users failed', e);
      throw ServerException(message: 'Failed to get top users', code: '500');
    }
  }

  @override
  Stream<UserProfileModel> watchProfile(String userId) {
    try {
      AppLogger.info('ProfileFirebaseDataSource', 'Watching profile: $userId');

      return _usersCollection.doc(userId).snapshots().map((doc) {
        if (!doc.exists) {
          throw ServerException(message: 'Profile not found', code: '404');
        }
        return UserProfileModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
        );
      });
    } catch (e) {
      AppLogger.error('Watch profile failed', e);
      throw ServerException(message: 'Failed to watch profile', code: '500');
    }
  }

  @override
  Future<void> blockUser(String userId, String targetUserId) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Blocking user: $userId -> $targetUserId',
      );

      await _blockedUsersCollection.add({
        'userId': userId,
        'blockedUserId': targetUserId,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      AppLogger.error('Block user failed', e);
      throw ServerException(message: 'Failed to block user', code: '500');
    }
  }

  @override
  Future<void> unblockUser(String userId, String targetUserId) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Unblocking user: $userId -> $targetUserId',
      );

      final query = await _blockedUsersCollection
          .where('userId', isEqualTo: userId)
          .where('blockedUserId', isEqualTo: targetUserId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      AppLogger.error('Unblock user failed', e);
      throw ServerException(message: 'Failed to unblock user', code: '500');
    }
  }

  @override
  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Getting blocked users: $userId',
      );

      final query = await _blockedUsersCollection
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs
          .map(
            (doc) =>
                (doc.data() as Map<String, dynamic>)['blockedUserId'] as String,
          )
          .toList();
    } catch (e) {
      AppLogger.error('Get blocked users failed', e);
      throw ServerException(
        message: 'Failed to get blocked users',
        code: '500',
      );
    }
  }

  @override
  Future<void> reportUser(
    String reporterId,
    String reportedUserId,
    String reason,
  ) async {
    try {
      AppLogger.info(
        'ProfileFirebaseDataSource',
        'Reporting user: $reporterId -> $reportedUserId',
      );

      await _reportsCollection.add({
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'createdAt': DateTime.now(),
        'status': 'pending',
      });
    } catch (e) {
      AppLogger.error('Report user failed', e);
      throw ServerException(message: 'Failed to report user', code: '500');
    }
  }
}
