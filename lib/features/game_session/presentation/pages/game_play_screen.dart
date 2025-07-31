import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../shared/widgets/quiz/countdown_timer.dart';
import '../../../../shared/widgets/quiz/question_display.dart';
import '../widgets/answer_selection_grid.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/score_display.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final bool isHost;

  const GamePlayScreen({super.key, this.isHost = false});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _questionTransitionController;
  late AnimationController _answerRevealController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int? _selectedAnswer;
  bool _showResults = false;
  int _currentScore = 0;

  // Mock question data
  final _currentQuestion = {
    'id': '1',
    'text': 'What is the largest planet in our solar system?',
    'answers': [
      {'text': 'Earth', 'isCorrect': false},
      {'text': 'Jupiter', 'isCorrect': true},
      {'text': 'Saturn', 'isCorrect': false},
      {'text': 'Mars', 'isCorrect': false},
    ],
    'timeLimit': 20,
    'points': 1000,
  };

  @override
  void initState() {
    super.initState();
    _questionTransitionController = AnimationController(
      duration: AppAnimations.newQuestionDuration,
      vsync: this,
    );

    _answerRevealController = AnimationController(
      duration: AppAnimations.correctAnswerDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _questionTransitionController,
        curve: AppAnimations.newQuestionCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionTransitionController,
        curve: AppAnimations.easeIn,
      ),
    );

    _questionTransitionController.forward();
  }

  @override
  void dispose() {
    _questionTransitionController.dispose();
    _answerRevealController.dispose();
    super.dispose();
  }

  void _handleAnswerSelected(int index) {
    if (_selectedAnswer == null && !_showResults) {
      setState(() {
        _selectedAnswer = index;
      });

      // Submit answer logic
      _submitAnswer(index);
    }
  }

  void _submitAnswer(int index) {
    // TODO: Submit answer to backend

    // Show results after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showResults = true;
          if (_currentQuestion['answers'][index]['isCorrect'] as bool) {
            _currentScore += _currentQuestion['points'] as int;
          }
        });
        _answerRevealController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeLimit = _currentQuestion['timeLimit'] as int;

    return PageLayout(
      title: widget.isHost ? 'Hosting Game' : 'Playing Game',
      actions: [
        ScoreDisplay(score: _currentScore),
        const SizedBox(width: AppSpacing.spacingM),
        ConnectionStatusIndicator(isConnected: true, onReconnect: () {}),
      ],
      child: AnimatedBuilder(
        animation: _questionTransitionController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Timer
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.spacingL),
                    child: CountdownTimer(
                      duration: Duration(seconds: timeLimit),
                      onComplete: () {
                        if (_selectedAnswer == null) {
                          // Auto-submit no answer
                          _submitAnswer(-1);
                        }
                      },
                    ),
                  ),

                  // Question display
                  Expanded(
                    child: Center(
                      child: QuestionDisplay(
                        question: _currentQuestion['text'] as String,
                        questionNumber: 1,
                        totalQuestions: 10,
                      ),
                    ),
                  ),

                  // Answer grid
                  if (!widget.isHost)
                    AnswerSelectionGrid(
                      answers: List<String>.from(
                        (_currentQuestion['answers'] as List).map(
                          (a) => a['text'],
                        ),
                      ),
                      selectedIndex: _selectedAnswer,
                      showResults: _showResults,
                      correctIndex: _showResults
                          ? (_currentQuestion['answers'] as List).indexWhere(
                              (a) => a['isCorrect'] as bool,
                            )
                          : null,
                      onAnswerSelected: _handleAnswerSelected,
                      revealController: _answerRevealController,
                    )
                  else
                    // Host view - show answer statistics
                    Container(
                      padding: AppSpacing.allL,
                      child: Column(
                        children: [
                          Text(
                            '${_showResults ? "Results" : "Waiting for answers..."}',
                            style: AppTextStyles.sectionHeader,
                          ),
                          const SizedBox(height: AppSpacing.spacingL),
                          // TODO: Show real-time answer statistics
                          if (_showResults) _buildAnswerStatistics(),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppSpacing.spacingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerStatistics() {
    // Mock statistics
    final stats = [
      {'answer': 'Earth', 'count': 5, 'percentage': 25},
      {'answer': 'Jupiter', 'count': 10, 'percentage': 50},
      {'answer': 'Saturn', 'count': 3, 'percentage': 15},
      {'answer': 'Mars', 'count': 2, 'percentage': 10},
    ];

    return Column(
      children: stats.map((stat) {
        final isCorrect = stat['answer'] == 'Jupiter';
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
          padding: AppSpacing.allM,
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.turquoise.withOpacity(0.1)
                : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? AppColors.turquoise : AppColors.lightGray,
              width: isCorrect ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  stat['answer'] as String,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text('${stat['count']} players', style: AppTextStyles.caption),
              const SizedBox(width: AppSpacing.spacingM),
              Container(
                width: 60,
                child: Text(
                  '${stat['percentage']}%',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCorrect ? AppColors.turquoise : AppColors.charcoal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
