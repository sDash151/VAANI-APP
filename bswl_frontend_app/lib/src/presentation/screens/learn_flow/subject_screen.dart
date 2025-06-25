// lib/src/presentation/screens/learn_flow/subject_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_header.dart';
import '../../widgets/progress_card.dart';
import './category_screen.dart'; // New import

class SubjectPage extends StatelessWidget {
  final String subjectName;
  final String subjectIcon;

  const SubjectPage({
    Key? key,
    required this.subjectName,
    required this.subjectIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: subjectName,
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              ProgressCard(
                progress: 0.4,
                completedLessons: '1',
                totalLessons: '3',
                title: "Overall Progress",
                subtitle: "Complete lessons to improve your score",
              ),
              const SizedBox(height: 24),
              // Category Section
              Expanded(
                child: ListView(
                  children: [
                    _buildCategoryCard(
                      context: context,
                      title: 'Introduction',
                      icon: Icons.library_books,
                      description: 'Fundamental concepts and overview',
                      category: 'Introduction',
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context: context,
                      title: 'Basic',
                      icon: Icons.school,
                      description: 'Core principles and techniques',
                      category: 'Basic',
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context: context,
                      title: 'Advanced',
                      icon: Icons.rocket_launch,
                      description: 'In-depth knowledge and applications',
                      category: 'Advanced',
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

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              subjectName: subjectName,
              category: category,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}