import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';

class FeatureCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isAnimated;
  final String? riveAsset;
  final double width;
  final double height;
  final bool showBadge;
  final String? badgeText;
  final bool isSelected;
  final bool enableVibration;

  const FeatureCard({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.color = AppColors.primary,
    this.onTap,
    this.isAnimated = true,
    this.riveAsset,
    this.width = 112,
    this.height = 120,
    this.showBadge = false,
    this.badgeText,
    this.isSelected = false,
    this.enableVibration = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (onTap != null) {
            if (enableVibration) {
              Vibration.vibrate(duration: 10); // Tactile feedback
            }
            onTap!();
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: width,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              children: [
                // Main Card with animated border
                AnimatedContainer(
                  duration: 300.ms,
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: onTap,
                        splashColor: color.withOpacity(0.2),
                        highlightColor: color.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated icon/Rive section
                              AnimatedContainer(
                                duration: 300.ms,
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: _buildIconSection(),
                              ),
                              const SizedBox(height: 12),
                              // Title with gradient text
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      color,
                                      Color.lerp(color, Colors.black, 0.2)!
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  title,
                                  style:
                                      TextStyles.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style:
                                      TextStyles.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(
                      autoPlay: false,
                      onPlay: (controller) => controller.forward(),
                    )
                    .scaleXY(
                      begin: 0.95,
                      end: 1,
                      duration: 300.ms,
                    )
                    .fadeIn(duration: 200.ms),

                // Badge
                if (showBadge && badgeText != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badgeText!,
                        style: TextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        .animate()
                        .scaleXY(
                          begin: 0,
                          end: 1,
                          duration: 300.ms,
                        )
                        .fadeIn(duration: 200.ms),
                  ),
              ],
            ),
          ),
        ));
  }

  Widget _buildIconSection() {
    if (riveAsset != null) {
      return SizedBox(
          width: 36,
          height: 36,
          child: Lottie.asset('assets/animations/your_animation.json'));
    } else if (icon != null) {
      return Icon(
        icon,
        size: 24,
        color: color,
      )
          .animate(
            onPlay: (controller) => isAnimated
                ? controller.repeat(reverse: true)
                : controller.forward(),
          )
          .moveY(
            begin: 0,
            end: -5,
            duration: 800.ms,
            curve: Curves.easeInOut,
          );
    }
    return const SizedBox.shrink();
  }
}

// Enhanced wide card version with sign language focus
class WideFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final int progress;
  final String? category;
  final bool isLocked;

  const WideFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.color = AppColors.primary,
    required this.onTap,
    this.progress = 0,
    this.category,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLocked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  // Icon with progress ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: progress / 100,
                          strokeWidth: 3,
                          backgroundColor: color.withValues(),
                          color: color,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with category badge
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyles.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (category != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  category!,
                                  style:
                                      TextStyles.textTheme.bodySmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyles.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        if (progress > 0)
                          LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                            backgroundColor: color.withValues(),
                            color: color,
                          ),
                      ],
                    ),
                  ),
                  // Action indicator
                  if (!isLocked) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: color,
                    ),
                  ],
                ],
              ),
              // Lock overlay
              if (isLocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: -0.1,
          end: 0,
          duration: 300.ms,
        );
  }
}

// Special card for sign language categories
class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;
  final int lessonCount;

  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.color = AppColors.primary,
    required this.onTap,
    this.lessonCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(),
                color.withValues(),
                Colors.white,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: 0,
                top: 0,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/sign_pattern.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyles.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(),
                      ),
                    ),
                    const Spacer(),
                    // Lesson count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$lessonCount lessons',
                        style: TextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Decorative sign language image
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
        );
  }
}
