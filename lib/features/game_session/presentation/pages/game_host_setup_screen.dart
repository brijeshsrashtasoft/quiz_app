import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../../../../shared/widgets/inputs/game_setup_inputs.dart';
import '../../../../shared/widgets/primitives/app_card.dart';
import '../../../../shared/widgets/cards/quiz_card.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';
import '../../../quiz_creation/presentation/providers/quiz_providers.dart';

/// Game Host Setup Screen - Configuration page before creating game session
/// Allows hosts to configure game settings, room settings, and advanced options
/// Following Kahoot-style design with engaging animations and clear UX
class GameHostSetupScreen extends ConsumerStatefulWidget {
  final String quizId;

  const GameHostSetupScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<GameHostSetupScreen> createState() => _GameHostSetupScreenState();
}

class _GameHostSetupScreenState extends ConsumerState<GameHostSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Form controllers and state
  final _descriptionController = TextEditingController();
  
  // Game Settings
  double _timePerQuestion = 20.0; // seconds
  int _maxPlayers = 50;
  bool _randomizeQuestions = true;
  
  // Room Settings  
  bool _isPublicRoom = false;
  
  // Advanced Settings
  bool _showLeaderboardDuringGame = true;
  bool _allowLateJoins = false;
  bool _autoStartWhenFull = false;
  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuizData();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppAnimations.longAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  void _loadQuizData() {
    // Load quiz data to populate default settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will trigger the quiz provider to load the specific quiz
      ref.read(quizByIdProvider(widget.quizId));
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createGameSession() {
    // Navigate to host game screen with all configurations
    final queryParams = {
      'quizId': widget.quizId,
      'timePerQuestion': _timePerQuestion.toInt().toString(),
      'maxPlayers': _maxPlayers.toString(),
      'randomizeQuestions': _randomizeQuestions.toString(),
      'isPublicRoom': _isPublicRoom.toString(),
      'showLeaderboard': _showLeaderboardDuringGame.toString(),
      'allowLateJoins': _allowLateJoins.toString(),
      'autoStartWhenFull': _autoStartWhenFull.toString(),
      'description': _descriptionController.text.trim(),
    };
    
    final uri = Uri(
      path: RouteConstants.gameHost,
      queryParameters: queryParams,
    );
    
    context.push(uri.toString());
  }

  String _formatTime(double seconds) {
    if (seconds < 60) {
      return '${seconds.toInt()}s';
    } else {
      final minutes = seconds / 60;
      return '${minutes.toStringAsFixed(1)}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Game Setup',
          style: AppTextStyles.sectionHeader,
        ),
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: quizAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.vibrantPurple,
              ),
            ),
            error: (error, stack) => _buildErrorState(error),
            data: (quiz) => _buildSetupContent(quiz),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.spacingL),
          Text(
            'Quiz Not Found',
            style: AppTextStyles.gameTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            'The selected quiz could not be loaded.',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingXL),
          PrimaryButton(
            onPressed: () => context.pop(),
            text: 'Go Back',
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildSetupContent(Quiz quiz) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPaddingAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuizPreview(quiz),
                  const SizedBox(height: AppSpacing.spacingXL),
                  _buildGameSettings(),
                  const SizedBox(height: AppSpacing.spacingXL),
                  _buildRoomSettings(),
                  const SizedBox(height: AppSpacing.spacingXL),
                  _buildAdvancedOptions(),
                  const SizedBox(height: AppSpacing.spacingXL),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuizPreview(Quiz quiz) {
    return AppCard(
      padding: AppSpacing.allM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allS,
                decoration: BoxDecoration(
                  color: AppColors.vibrantPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.quiz,
                  color: AppColors.vibrantPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Quiz',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      quiz.title,
                      style: AppTextStyles.sectionHeader,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Container(
            padding: AppSpacing.allS,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildQuizStat(
                  icon: Icons.help_outline,
                  label: 'Questions',
                  value: quiz.questions.length.toString(),
                ),
                const SizedBox(width: AppSpacing.spacingL),
                _buildQuizStat(
                  icon: Icons.category,
                  label: 'Category',
                  value: quiz.metadata.category,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.spacingXS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameSettings() {
    return _buildSection(
      title: 'Game Settings',
      icon: Icons.settings,
      iconColor: AppColors.turquoise,
      children: [
        LabeledSlider(
          label: 'Time per Question',
          value: _timePerQuestion,
          min: 5.0,
          max: 120.0,
          divisions: 23,
          tickLabels: ['5s', '30s', '60s', '2m'],
          onChanged: (value) {
            setState(() {
              _timePerQuestion = value;
            });
          },
          helperText: 'How long players have to answer each question',
          valueFormatter: _formatTime,
        ),
        const SizedBox(height: AppSpacing.spacingL),
        NumberInput(
          label: 'Maximum Players',
          value: _maxPlayers,
          min: 2,
          max: 200,
          onChanged: (value) {
            setState(() {
              _maxPlayers = value;
            });
          },
          helperText: 'Maximum number of players that can join',
          suffix: 'players',
        ),
        const SizedBox(height: AppSpacing.spacingL),
        SettingToggle(
          title: 'Randomize Questions',
          description: 'Questions appear in random order for each player',
          value: _randomizeQuestions,
          onChanged: (value) {
            setState(() {
              _randomizeQuestions = value;
            });
          },
          icon: Icons.shuffle,
          activeColor: AppColors.turquoise,
        ),
      ],
    );
  }

  Widget _buildRoomSettings() {
    return _buildSection(
      title: 'Room Settings',
      icon: Icons.meeting_room,
      iconColor: AppColors.mintGreen,
      children: [
        SettingToggle(
          title: 'Public Room',
          description: _isPublicRoom 
              ? 'Anyone can find and join this game'
              : 'Only players with the PIN can join',
          value: _isPublicRoom,
          onChanged: (value) {
            setState(() {
              _isPublicRoom = value;
            });
          },
          icon: _isPublicRoom ? Icons.public : Icons.lock,
          activeColor: AppColors.mintGreen,
        ),
        const SizedBox(height: AppSpacing.spacingL),
        CustomTextInput(
          controller: _descriptionController,
          label: 'Game Description (Optional)',
          hint: 'Add a description for your game...',
          maxLines: 3,
          helperText: 'Help players understand what this game is about',
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return _buildSection(
      title: 'Advanced Options',
      icon: Icons.tune,
      iconColor: AppColors.warmYellow,
      isCollapsible: true,
      isExpanded: _showAdvancedOptions,
      onExpandChanged: (expanded) {
        setState(() {
          _showAdvancedOptions = expanded;
        });
      },
      children: [
        SettingToggle(
          title: 'Show Leaderboard During Game',
          description: 'Players can see live rankings between questions',
          value: _showLeaderboardDuringGame,
          onChanged: (value) {
            setState(() {
              _showLeaderboardDuringGame = value;
            });
          },
          icon: Icons.leaderboard,
          activeColor: AppColors.warmYellow,
        ),
        const SizedBox(height: AppSpacing.spacingL),
        SettingToggle(
          title: 'Allow Late Joins',
          description: 'Players can join after the game has started',
          value: _allowLateJoins,
          onChanged: (value) {
            setState(() {
              _allowLateJoins = value;
            });
          },
          icon: Icons.person_add,
          activeColor: AppColors.warmYellow,
        ),
        const SizedBox(height: AppSpacing.spacingL),
        SettingToggle(
          title: 'Auto-start When Full',
          description: 'Game starts automatically when max players join',
          value: _autoStartWhenFull,
          onChanged: (value) {
            setState(() {
              _autoStartWhenFull = value;
            });
          },
          icon: Icons.play_arrow,
          activeColor: AppColors.warmYellow,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    bool isCollapsible = false,
    bool isExpanded = true,
    ValueChanged<bool>? onExpandChanged,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Section header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(isCollapsible ? 0 : 12),
              ),
              onTap: isCollapsible ? () => onExpandChanged?.call(!isExpanded) : null,
              child: Container(
                padding: AppSpacing.allM,
                child: Row(
                  children: [
                    Container(
                      padding: AppSpacing.allS,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.sectionHeader,
                      ),
                    ),
                    if (isCollapsible)
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: AppAnimations.shortAnimation,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Section content
          if (!isCollapsible || isExpanded)
            Container(
              padding: AppSpacing.allM,
              decoration: isCollapsible 
                  ? const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: AppSpacing.allL,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              onPressed: () => context.pop(),
              text: 'Cancel',
            ),
          ),
          const SizedBox(width: AppSpacing.spacingM),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              onPressed: _createGameSession,
              text: 'Create Game',
              icon: Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}