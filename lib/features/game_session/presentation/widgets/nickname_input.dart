import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

class NicknameInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final int maxLength;

  const NicknameInput({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.maxLength = 15,
  });

  @override
  State<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends State<NicknameInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Avatar preview
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vibrantPurple.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.controller.text.isEmpty
                          ? '?'
                          : widget.controller.text[0].toUpperCase(),
                      style: AppTextStyles.gameTitle.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingL),

                // Nickname input field
                AnimatedContainer(
                  duration: AppAnimations.shortAnimation,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isFocused
                          ? AppColors.vibrantPurple
                          : AppColors.lightGray,
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: AppColors.vibrantPurple.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Focus(
                    onFocusChange: (focused) {
                      setState(() => _isFocused = focused);
                      if (focused) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    },
                    child: TextField(
                      controller: widget.controller,
                      onSubmitted: widget.onSubmitted,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.sectionHeader,
                      maxLength: widget.maxLength,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter nickname',
                        hintStyle: AppTextStyles.inputHint,
                        border: InputBorder.none,
                        contentPadding: AppSpacing.allL,
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingS),

                // Character counter
                Text(
                  '${widget.controller.text.length}/${widget.maxLength}',
                  style: AppTextStyles.caption.copyWith(
                    color: widget.controller.text.length >= widget.maxLength
                        ? AppColors.coralRed
                        : AppColors.coolGray,
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingL),

                // Suggested nicknames
                Wrap(
                  spacing: AppSpacing.spacingS,
                  runSpacing: AppSpacing.spacingS,
                  children: [
                    _SuggestionChip(
                      label: 'Quiz Master',
                      onTap: () => widget.controller.text = 'Quiz Master',
                    ),
                    _SuggestionChip(
                      label: 'Brain Storm',
                      onTap: () => widget.controller.text = 'Brain Storm',
                    ),
                    _SuggestionChip(
                      label: 'Smart Cookie',
                      onTap: () => widget.controller.text = 'Smart Cookie',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.offWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingS,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.vibrantPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
