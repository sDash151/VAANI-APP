import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/subject_progress_card.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(title: "Your Progress"),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    const ProgressCard(
                      title: "Overall Progress",
                      progress: 0.65,
                      subtitle: "Keep learning to unlock new levels",
                      completedLessons: "24",
                      totalLessons: "30",
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Learning Stats",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: const [
                        StatCard(
                          title: "Current Streak",
                          value: "7 days",
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                        StatCard(
                          title: "Lessons Completed",
                          value: "24",
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        StatCard(
                          title: "Avg. Score",
                          value: "82%",
                          icon: Icons.bar_chart,
                          color: AppColors.accent,
                        ),
                        StatCard(
                          title: "Time Spent",
                          value: "12h 45m",
                          icon: Icons.timer,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Subject Performance",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SubjectProgressCard(
                          subject: [
                            "English",
                            "Maths",
                            "Science",
                            "Social",
                            "Hindi"
                          ][index],
                          progress: [0.8, 0.6, 0.7, 0.5, 0.9][index],
                          icon: [
                            Icons.language,
                            Icons.calculate,
                            Icons.science,
                            Icons.public,
                            Icons.translate
                          ][index],
                        ),
                      ),
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
}
