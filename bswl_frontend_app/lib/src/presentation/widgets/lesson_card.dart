import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final double progress;
  final IconData icon;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.progress,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.012), // Responsive margin
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Responsive icon container
            Container(
              width: screenWidth * 0.12, // 12% of screen width
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon, 
                color: AppColors.primary,
                size: screenWidth * 0.06, // Responsive icon size
              ),
            ),
            SizedBox(width: screenWidth * 0.04), // Responsive spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035, // Responsive font size
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.006), // Responsive spacing
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                    backgroundColor: Colors.grey[300],
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // Responsive spacing
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: screenWidth * 0.032, // Responsive font size
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
