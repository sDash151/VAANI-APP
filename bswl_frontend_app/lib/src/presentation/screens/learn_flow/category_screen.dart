// lib/src/presentation/screens/learn_flow/category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
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
                child: GridView.builder(
                  itemCount: modules.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Animate(
                      effects: [
                        FadeEffect(duration: 500.ms, delay: (index * 80).ms),
                        SlideEffect(
                            duration: 500.ms,
                            delay: (index * 80).ms,
                            begin: const Offset(0, 0.1)),
                      ],
                      child: _ModuleGridItem(
                        title: modules[index]['title'],
                        description: modules[index]['description'],
                        duration: modules[index]['duration'],
                        onLessonTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonDetailPage(
                                lessonTitle: modules[index]['title'],
                                subjectName: subjectName,
                              ),
                            ),
                          );
                        },
                        onQuizTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                                lessonTitle: modules[index]['title'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleGridItem extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final VoidCallback? onLessonTap;
  final VoidCallback? onQuizTap;

  const _ModuleGridItem({
    Key? key,
    required this.title,
    required this.description,
    required this.duration,
    this.onLessonTap,
    this.onQuizTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.play_circle_fill,
                    color: colorScheme.onPrimary, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                          color:
                              colorScheme.onPrimaryContainer.withOpacity(0.7)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Chip(
                backgroundColor: colorScheme.secondaryContainer,
                label: Text(
                  duration,
                  style: textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSecondaryContainer),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.play_circle_fill, color: colorScheme.primary),
                onPressed: onLessonTap,
                tooltip: 'Start Lesson',
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: Icon(Icons.quiz, color: colorScheme.secondary),
                label: Text(
                  "Quiz",
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.secondary),
                ),
                onPressed: onQuizTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
