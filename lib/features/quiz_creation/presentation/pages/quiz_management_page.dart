import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/navigation/route_constants.dart';
import '../widgets/quiz_list_item.dart';

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

  // Mock data for demo
  final List<Map<String, dynamic>> _quizzes = [
    {
      'id': '1',
      'title': 'World Geography Quiz',
      'description': 'Test your knowledge of world geography',
      'category': 'Geography',
      'questions': 15,
      'plays': 234,
      'rating': 4.5,
      'isPublic': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '2',
      'title': 'Science Basics',
      'description': 'Elementary science questions for beginners',
      'category': 'Science',
      'questions': 10,
      'plays': 156,
      'rating': 4.2,
      'isPublic': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '3',
      'title': 'History Timeline',
      'description': 'Important dates and events in history',
      'category': 'History',
      'questions': 20,
      'plays': 89,
      'rating': 4.8,
      'isPublic': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

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

  List<Map<String, dynamic>> get _filteredQuizzes {
    var filtered = _quizzes;

    // Apply filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((quiz) {
        switch (_selectedFilter) {
          case 'public':
            return quiz['isPublic'] == true;
          case 'private':
            return quiz['isPublic'] == false;
          case 'popular':
            return quiz['plays'] > 100;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((quiz) {
        return quiz['title'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            quiz['description'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            quiz['category'].toString().toLowerCase().contains(
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

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text('My Quizzes', style: AppTextStyles.sectionHeader),
        actions: [
          IconButton(
            onPressed: () {
              // Show search
              _showSearchDialog();
            },
            icon: const Icon(Icons.search, color: AppColors.charcoal),
            tooltip: 'Search quizzes',
          ),
          const SizedBox(width: AppSpacing.spacingS),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
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
                  _buildFilterChip('public', 'Public', Icons.public),
                  const SizedBox(width: AppSpacing.spacingS),
                  _buildFilterChip('private', 'Private', Icons.lock),
                  const SizedBox(width: AppSpacing.spacingS),
                  _buildFilterChip('popular', 'Popular', Icons.trending_up),
                ],
              ),
            ),
          ),
          // Stats summary
          Container(
            color: AppColors.offWhite,
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  'Total Quizzes',
                  _quizzes.length.toString(),
                  Icons.quiz,
                  AppColors.vibrantPurple,
                ),
                _buildStatCard(
                  'Total Plays',
                  _quizzes
                      .fold<int>(0, (sum, quiz) => sum + (quiz['plays'] as int))
                      .toString(),
                  Icons.play_circle_outline,
                  AppColors.turquoise,
                ),
                _buildStatCard(
                  'Avg Rating',
                  (_quizzes.fold<double>(
                            0,
                            (sum, quiz) => sum + (quiz['rating'] as double),
                          ) /
                          _quizzes.length)
                      .toStringAsFixed(1),
                  Icons.star_outline,
                  AppColors.warmYellow,
                ),
              ],
            ),
          ),
          // Quiz list
          Expanded(
            child: _filteredQuizzes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(
                      isDesktop ? AppSpacing.spacingXL : AppSpacing.spacingL,
                    ),
                    itemCount: _filteredQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _filteredQuizzes[index];
                      return SlideTransition(
                        position: _listAnimationController.drive(
                          Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(
                              curve: Interval(
                                index * 0.1,
                                1.0,
                                curve: AppAnimations.easeOut,
                              ),
                            ),
                          ),
                        ),
                        child: QuizListItem(
                          quiz: quiz,
                          onTap: () {
                            context.push('/quiz/${quiz['id']}');
                          },
                          onEdit: () {
                            context.push('/quiz/${quiz['id']}/edit');
                          },
                          onDelete: () {
                            _showDeleteConfirmation(quiz);
                          },
                          onShare: () {
                            _shareQuiz(quiz);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
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
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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

  void _showDeleteConfirmation(Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Quiz?', style: AppTextStyles.sectionHeader),
        content: Text(
          'Are you sure you want to delete "${quiz['title']}"? This action cannot be undone.',
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
              // Delete quiz
              setState(() {
                _quizzes.removeWhere((q) => q['id'] == quiz['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Quiz deleted successfully'),
                  backgroundColor: AppColors.success,
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

  void _shareQuiz(Map<String, dynamic> quiz) {
    // Share quiz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share link copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
