import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_spacing.dart';

/// Base placeholder page for development
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? actions;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: AppColors.vibrantPurple),
              const SizedBox(height: AppSpacing.spacingL),
              Text(
                title,
                style: AppTextStyles.sectionHeader,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                subtitle,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingXL),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This page is under development.\nNavigation and routing are working correctly.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Authentication Pages - Re-exports from feature modules
// Actual implementations are in /features/authentication/presentation/pages/

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Profile',
      subtitle: 'Manage your account settings',
      icon: Icons.account_circle,
    );
  }
}

// Home and Dashboard
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Quiz App Home',
      subtitle: 'Welcome to the Kahoot-style quiz app',
      icon: Icons.home,
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Dashboard',
      subtitle: 'Your quiz creation and game history',
      icon: Icons.dashboard,
    );
  }
}

// Quiz Creation Pages
class QuizCreationPage extends StatelessWidget {
  const QuizCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Quiz Creation',
      subtitle: 'Create your interactive quiz',
      icon: Icons.quiz,
    );
  }
}

class QuizCreationFormPage extends StatelessWidget {
  const QuizCreationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Quiz Form',
      subtitle: 'Add questions and answers',
      icon: Icons.edit_note,
    );
  }
}

class QuizCreationPreviewPage extends StatelessWidget {
  const QuizCreationPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Quiz Preview',
      subtitle: 'Review your quiz before publishing',
      icon: Icons.preview,
    );
  }
}

class QuizCreationPublishPage extends StatelessWidget {
  const QuizCreationPublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Publish Quiz',
      subtitle: 'Make your quiz available to players',
      icon: Icons.publish,
    );
  }
}

class QuizDetailsPage extends StatelessWidget {
  final String quizId;

  const QuizDetailsPage({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Quiz Details',
      subtitle: 'Quiz ID: $quizId',
      icon: Icons.info,
    );
  }
}

class QuizEditPage extends StatelessWidget {
  final String quizId;

  const QuizEditPage({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Edit Quiz',
      subtitle: 'Editing Quiz ID: $quizId',
      icon: Icons.edit,
    );
  }
}

// Game Session Pages
class GameJoinPage extends StatelessWidget {
  const GameJoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the comprehensive GameJoinWidget
    return const PlaceholderPage(
      title: 'Join Game',
      subtitle: 'Enter game PIN to join',
      icon: Icons.sports_esports,
    );
  }
}

class GameSessionPage extends StatelessWidget {
  final String sessionId;

  const GameSessionPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Game Session',
      subtitle: 'Session: $sessionId',
      icon: Icons.gamepad,
    );
  }
}

class GameWaitingPage extends StatelessWidget {
  final String sessionId;

  const GameWaitingPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Waiting Room',
      subtitle: 'Session: $sessionId\nWaiting for game to start...',
      icon: Icons.hourglass_empty,
    );
  }
}

class GameQuestionPage extends StatelessWidget {
  final String sessionId;
  final String questionIndex;

  const GameQuestionPage({
    super.key,
    required this.sessionId,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Question ${int.parse(questionIndex) + 1}',
      subtitle: 'Session: $sessionId',
      icon: Icons.help,
    );
  }
}

class GameResultsPage extends StatelessWidget {
  final String sessionId;

  const GameResultsPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Game Results',
      subtitle: 'Session: $sessionId',
      icon: Icons.emoji_events,
    );
  }
}

class GameHostPage extends StatelessWidget {
  const GameHostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Host Game',
      subtitle: 'Set up and host a quiz game',
      icon: Icons.person,
    );
  }
}

class GameHostSetupPlaceholderPage extends StatelessWidget {
  const GameHostSetupPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Host Setup',
      subtitle: 'Configure game settings',
      icon: Icons.settings,
    );
  }
}

// Leaderboard Pages
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Leaderboard',
      subtitle: 'Top players and scores',
      icon: Icons.leaderboard,
    );
  }
}

class GlobalLeaderboardPage extends StatelessWidget {
  const GlobalLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Global Leaderboard',
      subtitle: 'Top players worldwide',
      icon: Icons.public,
    );
  }
}

class SessionLeaderboardPage extends StatelessWidget {
  final String sessionId;

  const SessionLeaderboardPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Session Leaderboard',
      subtitle: 'Results for session: $sessionId',
      icon: Icons.format_list_numbered,
    );
  }
}

// Settings and Utility Pages
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Settings',
      subtitle: 'App preferences and configuration',
      icon: Icons.settings,
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'About',
      subtitle: 'App information and credits',
      icon: Icons.info_outline,
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Help',
      subtitle: 'How to use the quiz app',
      icon: Icons.help_outline,
    );
  }
}

// Error Pages
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the comprehensive NotFoundErrorWidget
    return const PlaceholderPage(
      title: '404 - Not Found',
      subtitle: 'The page you are looking for does not exist',
      icon: Icons.error_outline,
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    // Use the comprehensive ErrorPageWidget
    return PlaceholderPage(
      title: 'Error',
      subtitle: error ?? 'An unexpected error occurred',
      icon: Icons.error,
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.vibrantPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 120, color: AppColors.pureWhite),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'Quiz App',
              style: AppTextStyles.gameTitle.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
            ),
          ],
        ),
      ),
    );
  }
}
