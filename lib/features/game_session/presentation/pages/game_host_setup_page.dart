import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/cards/quiz_card.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/game_host_setup_providers.dart';

/// Game Host Setup Page - Intermediate configuration page between quiz selection and hosting
/// Allows hosts to configure game settings before starting a session
/// Follows Clean Architecture and Kahoot-style UI patterns
class GameHostSetupPage extends ConsumerStatefulWidget {
  final String? selectedQuizId;

  const GameHostSetupPage({super.key, this.selectedQuizId});

  @override
  ConsumerState<GameHostSetupPage> createState() => _GameHostSetupPageState();
}

class _GameHostSetupPageState extends ConsumerState<GameHostSetupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  // UI state
  bool _showAdvancedSettings = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuizIfProvided();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadQuizIfProvided() async {
    if (widget.selectedQuizId != null) {
      try {
        // Load the quiz details if ID is provided
        final userQuizzes = await ref.read(userQuizzesProvider.future);
        final quiz = userQuizzes.firstWhere(
          (q) => q.id == widget.selectedQuizId,
          orElse: () => throw Exception('Quiz not found'),
        );

        if (mounted) {
          // Update the configuration provider with the selected quiz
          ref
              .read(gameHostSetupProvider.notifier)
              .loadConfigurationFromQuiz(quiz);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load quiz: ${e.toString()}',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.pureWhite,
                ),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToQuizSelection() {
    context.push('/quiz-selection');
  }

  void _toggleAdvancedSettings() {
    setState(() {
      _showAdvancedSettings = !_showAdvancedSettings;
    });
  }

  void _updateMaxPlayers(double value) {
    ref.read(gameHostSetupProvider.notifier).updateMaxPlayers(value.round());
  }

  void _updateQuestionTimeLimit(double value) {
    ref
        .read(gameHostSetupProvider.notifier)
        .updateQuestionTimeLimit(value.round());
  }

  Future<void> _startGameSession() async {
    final configuration = ref.read(gameHostSetupProvider);

    if (configuration.selectedQuiz == null) return;

    try {
      // Get the configured settings
      final settings = configuration.toGameSessionSettings();

      // Navigate to host game screen with quiz ID and settings
      // The host game screen will create the session with these settings
      context.push(
        '${RouteConstants.gameHost}?quizId=${configuration.selectedQuiz!.id}',
        extra: {'settings': settings, 'isPublic': configuration.isPublicRoom},
      );
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to start game session: ${e.toString()}',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final configuration = ref.watch(gameHostSetupProvider);

    if (!isAuthenticated) {
      return PageLayout(
        title: 'Host Game Setup',
        body: _buildUnauthenticatedState(),
      );
    }

    return PageLayout(
      title: 'Host Game Setup',
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: _buildSetupContent(configuration),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: AppColors.coolGray),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Authentication Required',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'Please sign in to host game sessions',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: () => context.go(RouteConstants.login),
            text: 'Sign In',
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildSetupContent(GameHostSetupConfiguration configuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section with instructions
        _buildHeaderSection(),
        const SizedBox(height: AppSpacing.spacingL),

        // Quiz selection section
        _buildQuizSelectionSection(configuration),
        const SizedBox(height: AppSpacing.spacingL),

        // Game configuration section
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGameConfigurationSection(configuration),
                const SizedBox(height: AppSpacing.spacingL),
                _buildRoomSettingsSection(configuration),
                const SizedBox(height: AppSpacing.spacingL),
                _buildAdvancedSettingsSection(configuration),
                const SizedBox(height: AppSpacing.spacingXL),
              ],
            ),
          ),
        ),

        // Action buttons
        _buildActionButtons(configuration),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allL,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.pureWhite,
                size: AppDimensions.iconL,
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Text(
                'Game Setup',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            'Configure your game settings before hosting. Players will join using a generated PIN.',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.pureWhite.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSelectionSection(GameHostSetupConfiguration configuration) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: AppColors.vibrantPurple,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                'Selected Quiz',
                style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),

          if (configuration.selectedQuiz != null) ...[
            QuizCard(
              title: configuration.selectedQuiz!.title,
              description: configuration.selectedQuiz!.description,
              questionCount: configuration.selectedQuiz!.questions.length,
              difficulty: _getDifficultyFromQuiz(configuration.selectedQuiz!),
              category: configuration.selectedQuiz!.metadata.category,
              isSelected: true,
              onTap: _navigateToQuizSelection,
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: AppSpacing.allL,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.lightGray,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusM,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: AppColors.coolGray,
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  Text(
                    'No Quiz Selected',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  Text(
                    'Tap here to select a quiz to host',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.coolGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            SecondaryButton(
              onPressed: _navigateToQuizSelection,
              text: 'Select Quiz',
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameConfigurationSection(
    GameHostSetupConfiguration configuration,
  ) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppColors.mintGreen,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                'Game Configuration',
                style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingL),

          // Max Players Slider
          _buildSliderSetting(
            title: 'Maximum Players',
            value: configuration.maxPlayers.toDouble(),
            min: 2,
            max: 100,
            divisions: 98,
            onChanged: _updateMaxPlayers,
            valueDisplay: '${configuration.maxPlayers} players',
            icon: Icons.people,
            color: AppColors.turquoise,
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Question Time Limit Slider
          _buildSliderSetting(
            title: 'Question Time Limit',
            value: configuration.questionTimeLimit.toDouble(),
            min: 5,
            max: 60,
            divisions: 55,
            onChanged: _updateQuestionTimeLimit,
            valueDisplay: '${configuration.questionTimeLimit} seconds',
            icon: Icons.timer,
            color: AppColors.warmYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSettingsSection(GameHostSetupConfiguration configuration) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.meeting_room,
                color: AppColors.coralRed,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                'Room Settings',
                style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingL),

          // Room Type Toggle
          _buildToggleSetting(
            title: 'Room Type',
            subtitle: configuration.isPublicRoom
                ? 'Public - Anyone can join with PIN'
                : 'Private - Invite only',
            value: configuration.isPublicRoom,
            onChanged: (value) {
              ref
                  .read(gameHostSetupProvider.notifier)
                  .updateIsPublicRoom(value);
            },
            icon: configuration.isPublicRoom ? Icons.public : Icons.lock,
            color: configuration.isPublicRoom
                ? AppColors.mintGreen
                : AppColors.coralRed,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection(
    GameHostSetupConfiguration configuration,
  ) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleAdvancedSettings,
            child: Row(
              children: [
                Icon(
                  Icons.expand_more,
                  color: AppColors.vibrantPurple,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Text(
                  'Advanced Settings',
                  style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
                ),
                const Spacer(),
                Icon(
                  _showAdvancedSettings ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.vibrantPurple,
                ),
              ],
            ),
          ),

          if (_showAdvancedSettings) ...[
            const SizedBox(height: AppSpacing.spacingL),

            _buildToggleSetting(
              title: 'Show Correct Answers',
              subtitle: 'Display correct answers after each question',
              value: configuration.showCorrectAnswers,
              onChanged: (value) {
                ref
                    .read(gameHostSetupProvider.notifier)
                    .updateShowCorrectAnswers(value);
              },
              icon: Icons.check_circle,
              color: AppColors.success,
            ),

            const SizedBox(height: AppSpacing.spacingM),

            _buildToggleSetting(
              title: 'Shuffle Questions',
              subtitle: 'Randomize question order for each player',
              value: configuration.shuffleQuestions,
              onChanged: (value) {
                ref
                    .read(gameHostSetupProvider.notifier)
                    .updateShuffleQuestions(value);
              },
              icon: Icons.shuffle,
              color: AppColors.warmYellow,
            ),

            const SizedBox(height: AppSpacing.spacingM),

            _buildToggleSetting(
              title: 'Allow Replay',
              subtitle: 'Let players replay the quiz after completion',
              value: configuration.allowReplay,
              onChanged: (value) {
                ref
                    .read(gameHostSetupProvider.notifier)
                    .updateAllowReplay(value);
              },
              icon: Icons.replay,
              color: AppColors.mintGreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueDisplay,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: AppDimensions.iconS),
            const SizedBox(width: AppSpacing.spacingS),
            Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: AppSpacing.horizontalM.add(
                const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusS,
                ),
              ),
              child: Text(
                valueDisplay,
                style: AppTextStyles.bodyText.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingS),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.3),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppDimensions.iconM),
        const SizedBox(width: AppSpacing.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          activeTrackColor: color.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildActionButtons(GameHostSetupConfiguration configuration) {
    return Container(
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(top: BorderSide(color: AppColors.lightGray, width: 1)),
      ),
      child: Column(
        children: [
          // Start Game Session button (primary action)
          PrimaryButton(
            onPressed: configuration.selectedQuiz != null
                ? _startGameSession
                : null,
            text: configuration.selectedQuiz != null
                ? 'Start Game Session'
                : 'Select a Quiz First',
            width: double.infinity,
            isDisabled: configuration.selectedQuiz == null,
          ),
          const SizedBox(height: AppSpacing.spacingM),

          // Back button
          SecondaryButton(
            onPressed: () => context.pop(),
            text: 'Back',
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  /// Helper method to calculate difficulty from quiz
  String _getDifficultyFromQuiz(Quiz quiz) {
    if (quiz.questions.isEmpty) return 'Easy';

    // Calculate average time limit
    final avgTimeLimit =
        quiz.questions.fold(0, (sum, q) => sum + q.questionTimeLimit) /
        quiz.questions.length;

    if (avgTimeLimit <= 10) return 'Hard'; // Quick questions = harder
    if (avgTimeLimit <= 20) return 'Medium';
    return 'Easy'; // More time = easier
  }
}
