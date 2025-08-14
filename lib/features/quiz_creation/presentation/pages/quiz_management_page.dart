import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/quiz_card.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/quiz_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/quiz.dart';

/// Quiz management page to view and manage created quizzes
class QuizManagementPage extends ConsumerStatefulWidget {
  const QuizManagementPage({super.key});

  @override
  ConsumerState<QuizManagementPage> createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends ConsumerState<QuizManagementPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _listAnimationController;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  List<Quiz> _getFilteredQuizzes(List<Quiz> quizzes) {
    var filtered = quizzes;

    // Apply filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((quiz) {
        switch (_selectedFilter) {
          case 'public':
            return !quiz.isDraft && quiz.isPublic;
          case 'private':
            return !quiz.isDraft && !quiz.isPublic;
          case 'drafts':
            return quiz.isDraft;
          case 'published':
            return !quiz.isDraft;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((quiz) {
        return quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            quiz.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            quiz.metadata.category.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;

    // Watch both published and draft quizzes
    final userQuizzesAsync = ref.watch(userQuizzesProvider);
    final userDraftQuizzesAsync = ref.watch(userDraftQuizzesProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('My Quizzes', style: AppTextStyles.sectionHeader),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSearchDialog();
            },
            icon: const Icon(Icons.search, color: AppColors.charcoal),
            tooltip: 'Search quizzes',
          ),
          const SizedBox(width: AppSpacing.spacingS),
        ],
      ),
      body: _buildBody(
        userQuizzesAsync,
        userDraftQuizzesAsync,
        currentUser,
        isDesktop,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RouteConstants.quizCreation);
        },
        backgroundColor: AppColors.vibrantPurple,
        icon: const Icon(Icons.add),
        label: Text('Create Quiz', style: AppTextStyles.buttonMedium),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<Quiz>> userQuizzesAsync,
    AsyncValue<List<Quiz>> userDraftQuizzesAsync,
    dynamic currentUser,
    bool isDesktop,
  ) {
    // Show sign-in prompt if user is not authenticated
    if (currentUser == null) {
      return _buildSignInPrompt();
    }

    return userQuizzesAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (publishedQuizzes) {
        return userDraftQuizzesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
          data: (draftQuizzes) {
            final allQuizzes = [...publishedQuizzes, ...draftQuizzes];
            final filteredQuizzes = _getFilteredQuizzes(allQuizzes);

            return Column(
              children: [
                // Filter chips
                _buildFilterChips(),
                // Stats summary
                _buildStatsSection(allQuizzes),
                // Quiz list
                Expanded(
                  child: filteredQuizzes.isEmpty
                      ? _buildEmptyState()
                      : _buildQuizList(filteredQuizzes, isDesktop),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: AppColors.coolGray),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'Sign In Required',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              'Please sign in to view and manage your quizzes',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacingXL),
            PrimaryButton(
              onPressed: () {
                context.push(RouteConstants.login);
              },
              text: 'Sign In',
              icon: Icons.login,
              backgroundColor: AppColors.vibrantPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
          ),
          SizedBox(height: AppSpacing.spacingL),
          Text('Loading your quizzes...', style: AppTextStyles.bodyText),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.coralRed),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'Error Loading Quizzes',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.coralRed,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              error,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacingXL),
            PrimaryButton(
              onPressed: () {
                // Refresh the providers - explicitly ignore return values for refresh operations
                // ignore: unused_result
                ref.refresh(userQuizzesProvider);
                // ignore: unused_result
                ref.refresh(userDraftQuizzesProvider);
              },
              text: 'Try Again',
              icon: Icons.refresh,
              backgroundColor: AppColors.vibrantPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.pureWhite,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingL,
        vertical: AppSpacing.spacingM,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All Quizzes', Icons.apps),
            const SizedBox(width: AppSpacing.spacingS),
            _buildFilterChip('published', 'Published', Icons.public),
            const SizedBox(width: AppSpacing.spacingS),
            _buildFilterChip('drafts', 'Drafts', Icons.edit),
            const SizedBox(width: AppSpacing.spacingS),
            _buildFilterChip('public', 'Public', Icons.visibility),
            const SizedBox(width: AppSpacing.spacingS),
            _buildFilterChip('private', 'Private', Icons.lock),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<Quiz> quizzes) {
    final publishedCount = quizzes.where((q) => !q.isDraft).length;
    final draftCount = quizzes.where((q) => q.isDraft).length;
    final totalQuestions = quizzes.fold<int>(
      0,
      (sum, quiz) => sum + quiz.questions.length,
    );

    return Container(
      color: AppColors.offWhite,
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            'Total Quizzes',
            quizzes.length.toString(),
            Icons.quiz,
            AppColors.vibrantPurple,
          ),
          _buildStatCard(
            'Published',
            publishedCount.toString(),
            Icons.public,
            AppColors.mintGreen,
          ),
          _buildStatCard(
            'Drafts',
            draftCount.toString(),
            Icons.edit,
            AppColors.warmYellow,
          ),
          _buildStatCard(
            'Questions',
            totalQuestions.toString(),
            Icons.help_outline,
            AppColors.turquoise,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(List<Quiz> filteredQuizzes, bool isDesktop) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isDesktop ? AppSpacing.spacingXL : AppSpacing.spacingL,
      ),
      itemCount: filteredQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = filteredQuizzes[index];
        return SlideTransition(
          position: _listAnimationController.drive(
            Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).chain(
              CurveTween(
                curve: Interval(index * 0.1, 1.0, curve: AppAnimations.easeOut),
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.spacingM),
            child: QuizCard(
              title: quiz.title,
              description: quiz.description,
              questionCount: quiz.questions.length,
              difficulty: _getDifficultyFromQuiz(quiz),
              category: quiz.metadata.category,
              onTap: () {
                if (quiz.isDraft) {
                  context.push(RouteConstants.quizEditPath(quiz.id));
                } else {
                  context.push(RouteConstants.quizDetailsPath(quiz.id));
                }
              },
              isDraft: quiz.isDraft,
              isPublic: quiz.isPublic,
              onEdit: () {
                context.push(RouteConstants.quizEditPath(quiz.id));
              },
              onDelete: () {
                _showDeleteConfirmation(quiz);
              },
              onShare: quiz.isDraft
                  ? null
                  : () {
                      _shareQuiz(quiz);
                    },
            ),
          ),
        );
      },
    );
  }

  String _getDifficultyFromQuiz(Quiz quiz) {
    if (quiz.questions.isEmpty) return 'Easy';

    final avgTimeLimit =
        quiz.questions.fold(0, (sum, q) => sum + q.questionTimeLimit) /
        quiz.questions.length;

    if (avgTimeLimit <= 10) return 'Hard';
    if (avgTimeLimit <= 20) return 'Medium';
    return 'Easy';
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? AppColors.pureWhite : AppColors.coolGray,
      ),
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isSelected ? AppColors.pureWhite : AppColors.coolGray,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      backgroundColor: AppColors.offWhite,
      selectedColor: AppColors.vibrantPurple,
      checkmarkColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.vibrantPurple : AppColors.lightGray,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            value,
            style: AppTextStyles.sectionHeader.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 80, color: AppColors.lightGray),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              _searchQuery.isNotEmpty ? 'No quizzes found' : 'No quizzes yet',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.coolGray,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Create your first quiz to get started',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
            ),
            const SizedBox(height: AppSpacing.spacingXL),
            if (_searchQuery.isEmpty)
              PrimaryButton(
                onPressed: () {
                  context.push(RouteConstants.quizCreation);
                },
                text: 'Create Your First Quiz',
                icon: Icons.add,
                backgroundColor: AppColors.vibrantPurple,
              ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search, color: AppColors.vibrantPurple, size: 24),
                  const SizedBox(width: AppSpacing.spacingS),
                  Text('Search & Filter', style: AppTextStyles.sectionHeader),
                  const Spacer(),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Text(
                        'Clear',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.coralRed,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),

              // Search input with enhanced design
              Container(
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: TextField(
                  autofocus: true,
                  controller: TextEditingController(text: _searchQuery),
                  decoration: InputDecoration(
                    hintText: 'Search by title, description, or category',
                    hintStyle: AppTextStyles.inputHint,
                    prefixIcon: Icon(Icons.search, color: AppColors.coolGray),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.coolGray),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacingM,
                      vertical: AppSpacing.spacingM,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.spacingL),

              // Quick filter suggestions
              Text(
                'Quick Filters',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingM),

              Wrap(
                spacing: AppSpacing.spacingS,
                runSpacing: AppSpacing.spacingS,
                children: [
                  _buildQuickFilterChip('General Knowledge'),
                  _buildQuickFilterChip('Science'),
                  _buildQuickFilterChip('History'),
                  _buildQuickFilterChip('Technology'),
                  _buildQuickFilterChip('Sports'),
                ],
              ),

              const SizedBox(height: AppSpacing.spacingXL),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'all';
                        });
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spacingM,
                        ),
                        side: BorderSide(color: AppColors.coolGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset All',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingM),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () => Navigator.pop(context),
                      text: 'Apply',
                      backgroundColor: AppColors.vibrantPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchQuery = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.vibrantPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.vibrantPurple.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          category,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.vibrantPurple,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.coralRed, size: 24),
            const SizedBox(width: AppSpacing.spacingS),
            Text('Delete Quiz?', style: AppTextStyles.sectionHeader),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              decoration: BoxDecoration(
                color: AppColors.coralRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.coralRed.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz: ${quiz.title}',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXS),
                  Text(
                    '${quiz.questions.length} questions will be permanently deleted',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              'This action cannot be undone. All game sessions using this quiz will also be affected.',
              style: AppTextStyles.bodyText,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.coolGray,
              ),
            ),
          ),
          PrimaryButton(
            onPressed: () {
              Navigator.pop(context);
              _performQuizDeletion(quiz);
            },
            text: 'Delete Forever',
            backgroundColor: AppColors.coralRed,
            icon: Icons.delete_forever,
          ),
        ],
      ),
    );
  }

  void _performQuizDeletion(Quiz quiz) {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingM),
            Text('Deleting quiz...'),
          ],
        ),
        backgroundColor: AppColors.coralRed,
        duration: Duration(seconds: 3),
      ),
    );

    // TODO: Implement actual deletion with proper error handling
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.spacingS),
                Text('Quiz deletion feature is not yet implemented'),
              ],
            ),
            backgroundColor: AppColors.warmYellow,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _shareQuiz(Quiz quiz) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: AppColors.mintGreen, size: 24),
                const SizedBox(width: AppSpacing.spacingS),
                Text('Share Quiz', style: AppTextStyles.sectionHeader),
              ],
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz, color: AppColors.vibrantPurple, size: 40),
                  const SizedBox(width: AppSpacing.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: AppTextStyles.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${quiz.questions.length} questions • ${quiz.metadata.category}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _copyQuizLink(quiz);
                    },
                    text: 'Copy Link',
                    icon: Icons.link,
                    backgroundColor: AppColors.turquoise,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareQuizCode(quiz);
                    },
                    text: 'Share Code',
                    icon: Icons.qr_code,
                    backgroundColor: AppColors.vibrantPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacingM),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyQuizLink(Quiz quiz) {
    // Generate shareable link (placeholder implementation)
    // final link = 'https://myquizapp.com/quiz/${quiz.id}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.spacingS),
            Text('Quiz sharing feature coming soon!'),
          ],
        ),
        backgroundColor: AppColors.mintGreen,
        action: SnackBarAction(
          label: 'Got it',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _shareQuizCode(Quiz quiz) {
    // Generate shareable code (placeholder implementation)
    final code = quiz.id.substring(0, 6).toUpperCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Quiz Code', style: AppTextStyles.sectionHeader),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Players can join using this code:',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingL),
              decoration: BoxDecoration(
                color: AppColors.vibrantPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.vibrantPurple),
              ),
              child: Text(
                code,
                style: AppTextStyles.gameTitle.copyWith(
                  color: AppColors.vibrantPurple,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              'Feature coming soon!',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.coolGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            text: 'Got it',
            backgroundColor: AppColors.vibrantPurple,
          ),
        ],
      ),
    );
  }
}
