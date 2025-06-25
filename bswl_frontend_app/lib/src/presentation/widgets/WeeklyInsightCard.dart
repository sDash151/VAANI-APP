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
    final bool isPositive = progressPercentage >= 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(170, 190, 247, 219), // light pastel green with transparency
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 24),

              // Insight content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Insights",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 12),

                    _buildStatRow(
                      context,
                      icon: Icons.video_library_rounded,
                      value: "$videosWatched videos watched",
                    ),
                    const SizedBox(height: 8),

                    _buildStatRow(
                      context,
                      icon: Icons.assignment_turned_in_rounded,
                      value: "$lessonsCompleted lessons completed",
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${isPositive ? '+' : ''}${(progressPercentage * 100).toStringAsFixed(1)}% from last week",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
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

  Widget _buildStatRow(BuildContext context, {required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
      ],
    );
  }
}
