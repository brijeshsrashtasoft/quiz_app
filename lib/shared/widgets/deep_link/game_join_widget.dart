import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_animations.dart';
import '../buttons/primary_button.dart';
import '../inputs/text_input.dart';
import '../layout/page_layout.dart';
import '../feedback/loading_indicators.dart';
import '../../../core/navigation/route_constants.dart';

/// Game join widget with PIN input and deep link support
/// Handles joining games via PIN codes and deep links
class GameJoinWidget extends ConsumerStatefulWidget {
  final String? initialPin;
  final bool isDeepLink;

  const GameJoinWidget({super.key, this.initialPin, this.isDeepLink = false});

  @override
  ConsumerState<GameJoinWidget> createState() => _GameJoinWidgetState();
}

class _GameJoinWidgetState extends ConsumerState<GameJoinWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializePin();
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppAnimations.easeOut,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _animationController.forward();
  }

  void _initializePin() {
    if (widget.initialPin != null) {
      _pinController.text = widget.initialPin!;
      if (widget.isDeepLink) {
        // Auto-join if coming from deep link
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleJoinGame();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate game join process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      // For demo purposes, navigate to waiting room
      // In real implementation, this would validate the PIN and join the game
      final gamePin = _pinController.text.trim();
      context.go('/game/session-$gamePin/waiting');
    }
  }

  void _handleScanQR() {
    // TODO: Implement QR code scanning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR Scanner coming soon!'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _pinController.text = clipboardData!.text!.trim();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to paste from clipboard'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacingXXL),

            // Header
            _buildHeader(),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Deep Link Notice
            if (widget.isDeepLink) ...[
              _buildDeepLinkNotice(),
              const SizedBox(height: AppSpacing.spacingL),
            ],

            // PIN Input Section
            _buildPinInputSection(),

            const SizedBox(height: AppSpacing.spacingL),

            // Alternative Join Methods
            _buildAlternativeJoinMethods(),

            const SizedBox(height: AppSpacing.spacingXL),

            // Recent Games (if available)
            _buildRecentGames(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Game Icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_esports,
              size: 50,
              color: AppColors.pureWhite,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.spacingL),

        Text(
          'Join a Quiz Game',
          style: AppTextStyles.gameTitle.copyWith(color: AppColors.charcoal),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.spacingS),

        Text(
          'Enter the game PIN to join the fun!',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.coolGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeepLinkNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: Text(
              'You\'re joining via a shared link! The game PIN has been filled automatically.',
              style: AppTextStyles.caption.copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInputSection() {
    return Column(
      children: [
        // PIN Input
        CustomTextInput(
          controller: _pinController,
          label: 'Game PIN',
          hint: 'Enter 6-digit game PIN',
          keyboardType: TextInputType.number,
          prefixIcon: Icon(Icons.pin_outlined, color: AppColors.coolGray),
          suffixIcon: IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _pasteFromClipboard,
            tooltip: 'Paste from clipboard',
          ),
          validator: _validatePin,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleJoinGame(),
          maxLength: 6,
          textStyle: AppTextStyles.questionText.copyWith(
            letterSpacing: 4.0,
            fontFamily: 'monospace',
          ),
        ),

        const SizedBox(height: AppSpacing.spacingL),

        // Error Message
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: Text(_errorMessage!, style: AppTextStyles.errorText),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spacingL),
        ],

        // Join Button
        PrimaryButton(
          text: 'Join Game',
          onPressed: _isLoading ? null : _handleJoinGame,
          isLoading: _isLoading,
          icon: Icons.sports_esports,
        ),
      ],
    );
  }

  Widget _buildAlternativeJoinMethods() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.lightGray)),
            Padding(
              padding: AppSpacing.horizontalM,
              child: Text(
                'OR',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.lightGray)),
          ],
        ),

        const SizedBox(height: AppSpacing.spacingL),

        // QR Scan Button
        PrimaryButton(
          text: 'Scan QR Code',
          onPressed: _handleScanQR,
          icon: Icons.qr_code_scanner,
          backgroundColor: AppColors.mintGreen,
        ),

        const SizedBox(height: AppSpacing.spacingM),

        // Browse Public Games
        PrimaryButton(
          text: 'Browse Public Games',
          onPressed: () {
            // TODO: Navigate to public games list
          },
          icon: Icons.public,
          backgroundColor: AppColors.coolGray,
        ),
      ],
    );
  }

  Widget _buildRecentGames() {
    // Mock recent games data
    final recentGames = [
      {'name': 'Science Quiz', 'pin': '123456', 'host': 'Teacher Smith'},
      {'name': 'History Challenge', 'pin': '789012', 'host': 'Quiz Master'},
    ];

    if (recentGames.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Games',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.charcoal,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: AppSpacing.spacingM),

        ...recentGames.map(
          (game) => _RecentGameTile(
            name: game['name']!,
            pin: game['pin']!,
            host: game['host']!,
            onTap: () {
              _pinController.text = game['pin']!;
              _handleJoinGame();
            },
          ),
        ),
      ],
    );
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Game PIN is required';
    }
    if (value.length != 6) {
      return 'Game PIN must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Game PIN must contain only numbers';
    }
    return null;
  }
}

/// Recent game tile widget
class _RecentGameTile extends StatelessWidget {
  final String name;
  final String pin;
  final String host;
  final VoidCallback onTap;

  const _RecentGameTile({
    required this.name,
    required this.pin,
    required this.host,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingS),
      child: Material(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.vibrantPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.quiz, color: AppColors.vibrantPurple),
                ),

                const SizedBox(width: AppSpacing.spacingM),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.cardTitle),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text('Hosted by $host', style: AppTextStyles.caption),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PIN',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                    Text(
                      pin,
                      style: AppTextStyles.bodyText.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: AppColors.vibrantPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: AppSpacing.spacingS),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.coolGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
