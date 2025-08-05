import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';

class WeeklyInsightCard extends StatelessWidget {
  final int videosWatched;
  final int lessonsCompleted;
  final double progressPercentage;

  const WeeklyInsightCard({
    super.key,
    required this.videosWatched,
    required this.lessonsCompleted,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isPositive = progressPercentage >= 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
          decoration: BoxDecoration(
            color: const Color.fromARGB(170, 190, 247, 219), // light pastel green with transparency
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Responsive icon box
              Container(
                width: screenWidth * 0.18, // 18% of screen width
                height: screenWidth * 0.18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: screenWidth * 0.08, // Responsive icon size
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: screenWidth * 0.04), // Responsive spacing

              // Insight content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Insights",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: screenWidth * 0.04, // Responsive font size
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.01), // Responsive spacing

                    _buildStatRow(
                      context,
                      icon: Icons.video_library_rounded,
                      value: "$videosWatched videos watched",
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.006), // Responsive spacing

                    _buildStatRow(
                      context,
                      icon: Icons.assignment_turned_in_rounded,
                      value: "$lessonsCompleted lessons completed",
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.006), // Responsive spacing

                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: isPositive ? Colors.green : Colors.red,
                          size: screenWidth * 0.045, // Responsive icon size
                        ),
                        SizedBox(width: screenWidth * 0.02), // Responsive spacing
                        Expanded(
                          child: Text(
                            "${isPositive ? '+' : ''}${(progressPercentage * 100).toStringAsFixed(1)}% from last week",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenWidth * 0.032, // Responsive font size
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, {
    required IconData icon, 
    required String value, 
    required double screenWidth
  }) {
    return Row(
      children: [
        Icon(
          icon, 
          size: screenWidth * 0.045, // Responsive icon size
          color: AppColors.textSecondary
        ),
        SizedBox(width: screenWidth * 0.025), // Responsive spacing
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.032, // Responsive font size
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
