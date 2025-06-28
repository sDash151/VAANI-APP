import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';

class EnvironmentalScienceLessonsScreen extends StatelessWidget {
  EnvironmentalScienceLessonsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> lessonGroups = [
    {
      'section': 'Environment & Human Society',
      'lessons': [
        {'title': 'Environment and Human Society, Part-1'},
        {'title': 'Environment & Human Society, Part-4'},
      ],
    },
    {
      'section': 'Degradation of Natural Environment',
      'lessons': [
        {'title': 'Degradation of Natural Environment, Part-1'},
        {'title': 'Degradation of Natural Environment, Part-2'},
        {'title': 'Degradation of Natural Environment'},
      ],
    },
    {
      'section': 'Human Societies',
      'lessons': [
        {'title': 'Human Societies'},
      ],
    },
    {
      'section': 'Principles of Ecology',
      'lessons': [
        {'title': 'Principles of Ecology, Part-1'},
        {'title': 'Principles of Ecology, Part-2'},
        {
          'title': 'Principles of Ecology, Part-1'
        }, // Duplicate as per user list
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Environmental Science',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: lessonGroups.length,
                  itemBuilder: (context, groupIdx) {
                    final group = lessonGroups[groupIdx];
                    final section = group['section'] as String;
                    final lessons = group['lessons'] as List;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            section,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...List.generate(lessons.length, (lessonIdx) {
                          final lesson = lessons[lessonIdx];
                          return VideoLessonCard(
                            title: lesson['title'],
                            subtitle: 'Tap to watch.',
                            onTap: () {
                              // TODO: Navigate to video player
                            },
                          )
                              .animate()
                              .fadeIn(
                                  duration: 500.ms,
                                  delay: ((groupIdx * 3 + lessonIdx) * 100).ms)
                              .slideY(begin: 0.15);
                        }),
                        const SizedBox(height: 8),
                      ],
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
