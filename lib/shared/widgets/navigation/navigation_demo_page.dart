import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';
import 'breadcrumb_navigation.dart';
import 'navigation_loading_states.dart';
import '../layout/page_layout.dart';
import '../buttons/primary_button.dart';

/// Demo page showcasing all navigation UI components
/// Useful for testing and design system validation
class NavigationDemoPage extends StatefulWidget {
  const NavigationDemoPage({super.key});

  @override
  State<NavigationDemoPage> createState() => _NavigationDemoPageState();
}

class _NavigationDemoPageState extends State<NavigationDemoPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showBreadcrumbs = true;
  bool _showProgress = false;
  double _progress = 0.0;
  late AnimationController _demoController;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Navigation Components Demo',
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingL),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                        Icons.navigation,
                        color: AppColors.pureWhite,
                        size: 48,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: const Duration(seconds: 3)),
                  const SizedBox(height: AppSpacing.spacingM),
                  Text(
                    'Navigation UI Components',
                    style: AppTextStyles.gameTitle.copyWith(
                      color: AppColors.pureWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  Text(
                    'Kahoot-style navigation with responsive design and smooth animations',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.pureWhite.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.spacingXL),

            // Breadcrumb Navigation Demo
            _buildSection(
              'Breadcrumb Navigation',
              'Contextual navigation for complex hierarchies',
              [
                if (_showBreadcrumbs) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: Column(
                      children: [
                        BreadcrumbNavigation(
                          items: const [
                            BreadcrumbItem(
                              title: 'Quiz Creation',
                              route: '/quiz-creation',
                              icon: Icons.quiz_outlined,
                            ),
                            BreadcrumbItem(
                              title: 'Form Builder',
                              route: '/quiz-creation/form',
                              icon: Icons.edit_outlined,
                            ),
                            BreadcrumbItem(title: 'Question Setup'),
                          ],
                        ),
                        const Divider(height: 1),
                        CompactBreadcrumb(
                          items: const [
                            BreadcrumbItem(
                              title: 'Game Session',
                              route: '/game/abc123',
                              icon: Icons.sports_esports,
                            ),
                            BreadcrumbItem(
                              title: 'Question 3 of 10',
                              icon: Icons.quiz,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Toggle Breadcrumbs',
                          onPressed: () {
                            setState(() {
                              _showBreadcrumbs = !_showBreadcrumbs;
                            });
                          },
                          backgroundColor: AppColors.mintGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.spacingXL),

            // Loading States Demo
            _buildSection(
              'Loading States',
              'Visual feedback for navigation and data loading',
              [
                if (_isLoading)
                  Container(
                    height: 300,
                    child: NavigationLoadingStates.fullScreenLoading(
                      message: 'Loading quiz data...',
                      showLogo: true,
                    ),
                  )
                else ...[
                  // Shimmer demo
                  Container(
                    height: 200,
                    child:
                        NavigationLoadingStates.shimmerPageLoading(
                              showAppBar: true,
                              showBottomNav: false,
                              contentLines: 3,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              duration: const Duration(milliseconds: 1500),
                            ),
                  ),
                  const SizedBox(height: AppSpacing.spacingM),

                  // Inline loading demo
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spacingL),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: NavigationLoadingStates.inlineLoading(
                      message: 'Preparing quiz questions...',
                      compact: false,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.spacingM),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: _isLoading ? 'Stop Loading' : 'Show Loading',
                        onPressed: () {
                          setState(() {
                            _isLoading = !_isLoading;
                          });
                        },
                        backgroundColor: AppColors.vibrantPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacingXL),

            // Progress Navigation Demo
            _buildSection(
              'Progress Navigation',
              'Step-by-step navigation with progress indicators',
              [
                if (_showProgress) ...[
                  NavigationLoadingStates.navigationProgress(
                    progress: _progress,
                    currentStep: 'Setting up quiz parameters...',
                    steps: const [
                      'Basic Info',
                      'Questions',
                      'Settings',
                      'Preview',
                      'Publish',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacingM),

                  // Progress controls
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _progress,
                          onChanged: (value) {
                            setState(() {
                              _progress = value;
                            });
                          },
                          activeColor: AppColors.vibrantPurple,
                          inactiveColor: AppColors.lightGray,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.spacingM),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: _showProgress ? 'Hide Progress' : 'Show Progress',
                        onPressed: () {
                          setState(() {
                            _showProgress = !_showProgress;
                            if (_showProgress) {
                              _progress = 0.6; // Show at 60%
                            }
                          });
                        },
                        backgroundColor: AppColors.turquoise,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacingXL),

            // Navigation Skeleton Demo
            _buildSection(
              'Navigation Skeleton',
              'Loading placeholders for navigation elements',
              [NavigationLoadingStates.navigationSkeleton()],
            ),

            const SizedBox(height: AppSpacing.spacingXL),

            // Animation Demo
            _buildSection(
              'Navigation Animations',
              'Smooth transitions and micro-interactions',
              [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightGray),
                  ),
                  child: Column(
                    children: [
                      // Demo navigation items with animations
                      ...List.generate(4, (index) {
                        final items = [
                          {
                            'icon': Icons.home,
                            'label': 'Home',
                            'color': AppColors.vibrantPurple,
                          },
                          {
                            'icon': Icons.quiz,
                            'label': 'Create',
                            'color': AppColors.turquoise,
                          },
                          {
                            'icon': Icons.sports_esports,
                            'label': 'Play',
                            'color': AppColors.mintGreen,
                          },
                          {
                            'icon': Icons.leaderboard,
                            'label': 'Scores',
                            'color': AppColors.warmYellow,
                          },
                        ];

                        final item = items[index];

                        return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.spacingS,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: item['color'] as Color,
                                  ),
                                ),
                                title: Text(item['label'] as String),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            )
                            .animate(delay: Duration(milliseconds: index * 100))
                            .slideX(
                              begin: -0.2,
                              end: 0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutQuart,
                            )
                            .fadeIn(
                              duration: const Duration(milliseconds: 300),
                            );
                      }),

                      const SizedBox(height: AppSpacing.spacingM),

                      PrimaryButton(
                        text: 'Replay Animation',
                        onPressed: () {
                          _demoController.reset();
                          _demoController.forward();
                        },
                        backgroundColor: AppColors.coralRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(color: AppColors.coolGray),
          ),
          const SizedBox(height: AppSpacing.spacingL),
          ...children,
        ],
      ),
    );
  }
}
