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
    final isTablet = size.width > 600;
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
                // Refresh the providers
                ref.refresh(userQuizzesProvider);
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
            color: AppColors.shadowLight.withOpacity(0.1),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Search Quizzes', style: AppTextStyles.sectionHeader),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by title, description, or category',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: Icon(Icons.search, color: AppColors.coolGray),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.coolGray,
              ),
            ),
          ),
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            text: 'Done',
            backgroundColor: AppColors.vibrantPurple,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Quiz?', style: AppTextStyles.sectionHeader),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"? This action cannot be undone.',
          style: AppTextStyles.bodyText,
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
              // TODO: Implement actual deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz deletion not implemented yet'),
                  backgroundColor: AppColors.warmYellow,
                ),
              );
            },
            text: 'Delete',
            backgroundColor: AppColors.coralRed,
          ),
        ],
      ),
    );
  }

  void _shareQuiz(Quiz quiz) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quiz sharing not implemented yet'),
        backgroundColor: AppColors.mintGreen,
      ),
    );
  }
}
