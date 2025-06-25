import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/achievement_badge.dart';
import '../../widgets/achievement_progress_card.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(title: "Achievements"),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      "Your Badges",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 16,
                      children: [
                        AchievementBadge(
                          icon: Icons.star,
                          title: "First Steps",
                          achieved: true,
                        ),
                        AchievementBadge(
                          icon: Icons.emoji_events,
                          title: "Quiz Master",
                          achieved: true,
                        ),
                        AchievementBadge(
                          icon: Icons.local_fire_department,
                          title: "5 Day Streak",
                          achieved: true,
                        ),
                        AchievementBadge(
                          icon: Icons.lightbulb,
                          title: "Quick Learner",
                          achieved: false,
                        ),
                        AchievementBadge(
                          icon: Icons.book,
                          title: "Bookworm",
                          achieved: false,
                        ),
                        AchievementBadge(
                          icon: Icons.verified_user,
                          title: "Subject Expert",
                          achieved: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "In Progress",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AchievementProgressCard(
                          title: ["Complete 10 Lessons", "Score 90% on a Quiz", "7-Day Streak"][index],
                          progress: [0.7, 0.4, 0.6][index],
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