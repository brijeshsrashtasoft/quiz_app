# US-010: Categorize Quizzes

## User Story
As a quiz creator, I want to categorize my quizzes (Science, Geography, etc.) so that others can find relevant content.

## User Journey Map
```
Category Selection Flow:
1. Creator in metadata step → Sees category dropdown
2. Selects from predefined list → Or requests new category
3. Category helps with → Discovery and filtering
4. Players browse by category → Find relevant quizzes
5. Analytics show → Popular categories
```

## Acceptance Criteria
- [ ] Category dropdown in quiz metadata form
- [ ] 15+ predefined categories with icons
- [ ] Single category selection required
- [ ] Category icons displayed throughout app
- [ ] Browse quizzes by category
- [ ] Category-based recommendations
- [ ] Popular categories on home screen
- [ ] Category statistics in analytics
- [ ] Request new category option
- [ ] Admin category management (future)
- [ ] Subcategories support (future)
- [ ] Multi-language category names

## Navigation Flow

### Current State
```
10 predefined categories in domain model
Category dropdown in metadata form
No icons or visual differentiation
No category browsing implemented
```

### Required Implementation
```
1. Enhanced Category System:
   Quiz Creation → Metadata
   ├── Category Selection
   │   ├── Visual category grid
   │   ├── Search categories
   │   ├── Popular categories first
   │   └── Request new category
   │
   └── Category Display
       ├── Icon + color theme
       ├── Localized names
       └── Description tooltip

2. Category Discovery:
   /browse → Categories Tab
   ├── Category Grid View
   │   ├── Icon + name + count
   │   ├── Trending indicator
   │   └── Click → filtered list
   │
   └── Category Page (/category/{id})
       ├── Featured quizzes
       ├── New quizzes
       ├── Popular quizzes
       └── Related categories
```

## Technical Implementation

### 1. Enhanced Category Model
```dart
// lib/core/constants/quiz_categories.dart

enum QuizCategory {
  science(
    id: 'science',
    icon: Icons.science,
    color: Color(0xFF4CAF50),
    defaultName: 'Science',
  ),
  mathematics(
    id: 'mathematics', 
    icon: Icons.calculate,
    color: Color(0xFF2196F3),
    defaultName: 'Mathematics',
  ),
  history(
    id: 'history',
    icon: Icons.history_edu,
    color: Color(0xFF795548),
    defaultName: 'History',
  ),
  geography(
    id: 'geography',
    icon: Icons.public,
    color: Color(0xFF009688),
    defaultName: 'Geography',
  ),
  literature(
    id: 'literature',
    icon: Icons.menu_book,
    color: Color(0xFF9C27B0),
    defaultName: 'Literature',
  ),
  entertainment(
    id: 'entertainment',
    icon: Icons.movie,
    color: Color(0xFFE91E63),
    defaultName: 'Entertainment',
  ),
  sports(
    id: 'sports',
    icon: Icons.sports_soccer,
    color: Color(0xFFFF5722),
    defaultName: 'Sports',
  ),
  technology(
    id: 'technology',
    icon: Icons.computer,
    color: Color(0xFF607D8B),
    defaultName: 'Technology',
  ),
  art(
    id: 'art',
    icon: Icons.palette,
    color: Color(0xFFFF9800),
    defaultName: 'Art & Design',
  ),
  music(
    id: 'music',
    icon: Icons.music_note,
    color: Color(0xFF3F51B5),
    defaultName: 'Music',
  ),
  food(
    id: 'food',
    icon: Icons.restaurant,
    color: Color(0xFFF44336),
    defaultName: 'Food & Cooking',
  ),
  nature(
    id: 'nature',
    icon: Icons.park,
    color: Color(0xFF8BC34A),
    defaultName: 'Nature & Environment',
  ),
  business(
    id: 'business',
    icon: Icons.business,
    color: Color(0xFF00BCD4),
    defaultName: 'Business & Economics',
  ),
  language(
    id: 'language',
    icon: Icons.translate,
    color: Color(0xFFCDDC39),
    defaultName: 'Language & Linguistics',
  ),
  general(
    id: 'general',
    icon: Icons.lightbulb,
    color: Color(0xFF9E9E9E),
    defaultName: 'General Knowledge',
  );

  final String id;
  final IconData icon;
  final Color color;
  final String defaultName;

  const QuizCategory({
    required this.id,
    required this.icon,
    required this.color,
    required this.defaultName,
  });

  String getLocalizedName(String locale) {
    // Future: Load from localization files
    return defaultName;
  }
}

extension QuizCategoryExtension on QuizCategory {
  Widget buildIcon({double size = 24}) {
    return Container(
      padding: EdgeInsets.all(size / 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
  
  Widget buildChip({VoidCallback? onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(defaultName),
      backgroundColor: color.withOpacity(0.1),
      onPressed: onTap,
    );
  }
}
```

### 2. Visual Category Selector
```dart
// lib/features/quiz_creation/presentation/widgets/category_selector.dart

class CategorySelector extends ConsumerStatefulWidget {
  final QuizCategory? selectedCategory;
  final Function(QuizCategory) onCategorySelected;
  
  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  final _searchController = TextEditingController();
  List<QuizCategory> _filteredCategories = QuizCategory.values;
  
  @override
  Widget build(BuildContext context) {
    final categoryStats = ref.watch(categoryStatsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: _filterCategories,
        ),
        
        const SizedBox(height: 16),
        
        // Popular categories section
        if (_searchController.text.isEmpty) ...[
          Text(
            'Popular Categories',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categoryStats.popularCategories[index];
                return category.buildChip(
                  onTap: () => _selectCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Category grid
        Text(
          'All Categories',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredCategories.length,
          itemBuilder: (context, index) {
            final category = _filteredCategories[index];
            final isSelected = widget.selectedCategory == category;
            final quizCount = categoryStats.getCategoryCount(category);
            
            return InkWell(
              onTap: () => _selectCategory(category),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color.withOpacity(0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? category.color
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    category.buildIcon(size: 32),
                    const SizedBox(height: 8),
                    Text(
                      category.defaultName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (quizCount > 0)
                      Text(
                        '$quizCount quizzes',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Request new category
        Center(
          child: TextButton.icon(
            onPressed: _requestNewCategory,
            icon: const Icon(Icons.add),
            label: const Text('Request New Category'),
          ),
        ),
      ],
    );
  }
  
  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = QuizCategory.values;
      } else {
        _filteredCategories = QuizCategory.values.where((category) {
          return category.defaultName
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  
  void _selectCategory(QuizCategory category) {
    widget.onCategorySelected(category);
    
    // Track selection for analytics
    ref.read(analyticsProvider).trackEvent(
      'category_selected',
      parameters: {'category': category.id},
    );
  }
  
  void _requestNewCategory() {
    showDialog(
      context: context,
      builder: (context) => NewCategoryRequestDialog(),
    );
  }
}
```

### 3. Category Browse Page
```dart
// lib/features/browse/presentation/pages/category_browse_page.dart

class CategoryBrowsePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = QuizCategory.values;
    final categoryStats = ref.watch(categoryStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse by Category'),
      ),
      body: CustomScrollView(
        slivers: [
          // Trending categories
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trending Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: min(5, categoryStats.trendingCategories.length),
                    itemBuilder: (context, index) {
                      final category = categoryStats.trendingCategories[index];
                      final growth = categoryStats.getGrowthRate(category);
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _TrendingCategoryCard(
                          category: category,
                          growthRate: growth,
                          onTap: () => _navigateToCategory(context, category),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // All categories grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];
                  final stats = categoryStats.getStats(category);
                  
                  return CategoryCard(
                    category: category,
                    quizCount: stats.totalQuizzes,
                    newThisWeek: stats.newThisWeek,
                    onTap: () => _navigateToCategory(context, category),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToCategory(BuildContext context, QuizCategory category) {
    context.go('/browse/category/${category.id}');
  }
}
```

### 4. Category Statistics Provider
```dart
// lib/features/browse/presentation/providers/category_stats_provider.dart

@riverpod
class CategoryStats extends _$CategoryStats {
  @override
  Future<CategoryStatsData> build() async {
    final repository = ref.read(quizRepositoryProvider);
    
    // Fetch category statistics
    final stats = await repository.getCategoryStatistics();
    
    return stats.fold(
      (failure) => CategoryStatsData.empty(),
      (data) => data,
    );
  }
  
  List<QuizCategory> get popularCategories {
    final stats = state.valueOrNull ?? CategoryStatsData.empty();
    return stats.categories
        .sorted((a, b) => b.totalQuizzes.compareTo(a.totalQuizzes))
        .take(5)
        .map((s) => s.category)
        .toList();
  }
  
  List<QuizCategory> get trendingCategories {
    final stats = state.valueOrNull ?? CategoryStatsData.empty();
    return stats.categories
        .where((s) => s.growthRate > 0)
        .sorted((a, b) => b.growthRate.compareTo(a.growthRate))
        .take(5)
        .map((s) => s.category)
        .toList();
  }
  
  int getCategoryCount(QuizCategory category) {
    final stats = state.valueOrNull ?? CategoryStatsData.empty();
    return stats.categories
        .firstWhereOrNull((s) => s.category == category)
        ?.totalQuizzes ?? 0;
  }
}
```

### 5. Category Filter in Browse
```dart
// lib/features/browse/presentation/widgets/quiz_filter_bar.dart

class QuizFilterBar extends ConsumerWidget {
  final QuizCategory? selectedCategory;
  final Function(QuizCategory?) onCategoryChanged;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All categories chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategoryChanged(null),
            ),
          ),
          
          // Category chips
          ...QuizCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.white : category.color,
                ),
                label: Text(category.defaultName),
                selected: isSelected,
                selectedColor: category.color,
                checkmarkColor: Colors.white,
                onSelected: (_) => onCategoryChanged(category),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

## Category Analytics

### Metrics to Track
- Total quizzes per category
- New quizzes this week/month
- Play count by category
- Average rating by category
- User preferences
- Search queries

### Trending Algorithm
```dart
double calculateTrendScore(CategoryStats stats) {
  final recencyWeight = 0.4;
  final popularityWeight = 0.3;
  final growthWeight = 0.3;
  
  final recencyScore = stats.newThisWeek / max(stats.totalQuizzes, 1);
  final popularityScore = stats.totalPlays / 1000; // Normalized
  final growthScore = stats.weeklyGrowthRate;
  
  return (recencyScore * recencyWeight) +
         (popularityScore * popularityWeight) +
         (growthScore * growthWeight);
}
```

## Localization Support

### Category Translations
```json
// assets/i18n/en.json
{
  "categories": {
    "science": "Science",
    "mathematics": "Mathematics",
    "history": "History",
    ...
  }
}

// assets/i18n/es.json
{
  "categories": {
    "science": "Ciencia",
    "mathematics": "Matemáticas",
    "history": "Historia",
    ...
  }
}
```

## Testing Requirements

### Unit Tests
- [ ] Category model logic
- [ ] Filter functionality
- [ ] Statistics calculations
- [ ] Localization loading

### Integration Tests
- [ ] Category selection flow
- [ ] Browse by category
- [ ] Stats API calls
- [ ] Filter persistence

### E2E Tests
- [ ] Select category in creation
- [ ] Browse categories
- [ ] Filter quizzes
- [ ] Request new category
- [ ] View category stats

## Future Enhancements
- Subcategories (e.g., Science → Physics, Chemistry)
- Multiple category tags
- Custom categories for organizations
- Category recommendations based on history
- Category-specific leaderboards

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: US-051 (Browse quizzes)
- Related: US-052 (Search quizzes)
- Enhances: Content discovery

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Visual category selector complete
- [ ] Category browse page working
- [ ] Statistics tracking implemented
- [ ] Icons and colors consistent
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Localization framework ready
- [ ] Documentation updated