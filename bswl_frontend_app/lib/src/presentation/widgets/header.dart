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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ClipPath(
      clipper: _HeaderCurveClipper(
          curveHeight: screenHeight * 0.02), // Responsive curve
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // 5% of screen width
          vertical: screenHeight * 0.025, // 2.5% of screen height
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primaryLight
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with responsive font size
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w900, // Extra bold for better visibility
                  fontSize: screenWidth * 0.055, // Larger font size
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                    ),
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
            ),

            // Profile Avatar with responsive size
            if (profileImageUrl != null) ...[
              SizedBox(width: screenWidth * 0.03), // Responsive spacing
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.8), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl!),
                  radius: screenWidth * 0.06, // Responsive radius
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
              ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.2),
            ],
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: screenWidth * 0.04, // Responsive font size
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actionText != null)
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: 6,
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText!,
                    style: TextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035, // Responsive font size
                    ),
                  ),
                ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 6),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
