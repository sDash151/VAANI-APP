// lib/src/presentation/screens/learn_flow/category_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_header.dart';
import './lesson_detail_screen.dart';
import './quiz_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String subjectName;
  final String category;

  const CategoryScreen({
    Key? key,
    required this.subjectName,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual API data
    final List<Map<String, dynamic>> modules = [
      {
        'title': '$category Concepts Part 1',
        'description': 'Learn foundational principles',
        'duration': '15:30',
      },
      {
        'title': '$category Concepts Part 2',
        'description': 'Advanced applications',
        'duration': '18:45',
      },
      {
        'title': '$category Problem Solving',
        'description': 'Practical examples and exercises',
        'duration': '22:10',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: '$subjectName - $category',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: modules.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildModuleCard(
                    context: context,
                    module: modules[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required Map<String, dynamic> module,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.card, // fixed from cardBackground
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_circle_fill, 
                    color: AppColors.primary, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(
                backgroundColor: AppColors.primaryLight,
                label: Text(
                  module['duration'],
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.play_circle_fill, 
                    color: AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetailPage(
                        lessonTitle: module['title'],
                        subjectName: subjectName,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.quiz, color: AppColors.accent),
                label: const Text(
                  "Quiz",
                  style: TextStyle(color: AppColors.accent),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        lessonTitle: module['title'],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}