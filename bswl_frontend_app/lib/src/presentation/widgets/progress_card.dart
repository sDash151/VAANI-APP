import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';

class ProgressCard extends StatelessWidget {
  final double progress;
  final String completedLessons;
  final String totalLessons;
  final String title;
  final String subtitle;

  const ProgressCard({
    super.key,
    required this.progress,
    required this.completedLessons,
    required this.totalLessons,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Responsive progress circle
          SizedBox(
            width: screenWidth * 0.18, // 18% of screen width
            height: screenWidth * 0.18,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: screenWidth * 0.035, // Responsive font size
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.04), // Responsive spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04, // Responsive font size
                      ),
                ),
                SizedBox(height: screenHeight * 0.008),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: screenWidth * 0.032, // Responsive font size
                      ),
                ),
                SizedBox(height: screenHeight * 0.006),
                Text(
                  "$completedLessons of $totalLessons lessons completed",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: screenWidth * 0.03, // Responsive font size
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
