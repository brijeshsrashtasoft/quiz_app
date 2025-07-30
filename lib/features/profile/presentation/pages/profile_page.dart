import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';

/// User profile page - main profile screen
/// Following CLAUDE.md patterns and UI guidelines
/// UI implementation will be handled by ui-designer agent
class ProfilePage extends ConsumerStatefulWidget {
  final String? userId;

  const ProfilePage({
    super.key,
    this.userId,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    
    // Load profile on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        ref.read(currentUserProfileProvider.notifier).loadProfile(widget.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final completionPercentage = ref.watch(profileCompletionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page
              // Will be implemented by ui-designer
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Profile not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header with avatar and basic info
                _buildProfileHeader(profile),
                
                const SizedBox(height: 24),
                
                // Profile completion indicator
                _buildCompletionIndicator(completionPercentage),
                
                const SizedBox(height: 24),
                
                // User statistics
                _buildStatsSection(profile),
                
                const SizedBox(height: 24),
                
                // Quick actions
                _buildQuickActions(),
                
                const SizedBox(height: 24),
                
                // Settings sections
                _buildSettingsSection(),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.userId != null) {
                    ref.read(currentUserProfileProvider.notifier).loadProfile(widget.userId!);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar placeholder - UI designer will implement proper avatar widget
            CircleAvatar(
              radius: 40,
              backgroundImage: profile.profileImageUrl != null
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile.profileImageUrl == null
                  ? Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (profile.username != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${profile.username}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator(double percentage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Completion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toInt()}% complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(profile) {
    final stats = profile.stats;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            if (stats != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Games Played', stats.totalGamesPlayed.toString()),
                  ),
                  Expanded(
                    child: _buildStatItem('Games Won', stats.totalGamesWon.toString()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Win Rate', '${profile.winRate.toStringAsFixed(1)}%'),
                  ),
                  Expanded(
                    child: _buildStatItem('Total Points', stats.totalPoints.toString()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Current Streak', stats.currentStreak.toString()),
                  ),
                  Expanded(
                    child: _buildStatItem('Best Streak', stats.bestStreak.toString()),
                  ),
                ],
              ),
            ] else ...[
              const Text('No statistics available. Play some games to see your stats!'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildActionChip(
                  icon: Icons.edit,
                  label: 'Edit Profile',
                  onPressed: () {
                    // Navigate to edit profile
                  },
                ),
                _buildActionChip(
                  icon: Icons.photo_camera,
                  label: 'Change Avatar',
                  onPressed: () {
                    // Open avatar selection
                  },
                ),
                _buildActionChip(
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: () {
                    // Navigate to settings
                  },
                ),
                _buildActionChip(
                  icon: Icons.share,
                  label: 'Share Profile',
                  onPressed: () {
                    // Share profile
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Game Preferences'),
              subtitle: const Text('Sound, difficulty, and game settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to preferences
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              subtitle: const Text('Control who can see your profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with your account'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to help
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Show sign out confirmation
                _showSignOutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle sign out
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}