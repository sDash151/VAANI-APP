import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? profileImageUrl;

  const AppHeader({
    super.key,
    required this.title,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderCurveClipper(curveHeight: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.9), AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with fade + slide animation
            Text(
              title,
              style: TextStyles.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),

            // Profile Avatar with border and shadow
            if (profileImageUrl != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl!),
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
              ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  final double curveHeight;

  const _HeaderCurveClipper({this.curveHeight = 24});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - curveHeight);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - curveHeight / 2,
    );
    path.quadraticBezierTo(
      3 * size.width / 4,
      size.height - curveHeight,
      size.width,
      size.height - curveHeight,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionPressed,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyles.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (actionText != null)
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText!,
                    style: TextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
