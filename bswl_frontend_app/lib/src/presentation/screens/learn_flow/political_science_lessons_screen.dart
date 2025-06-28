import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';

class PoliticalScienceLessonsScreen extends StatelessWidget {
  PoliticalScienceLessonsScreen({Key? key}) : super(key: key);

  // Grouped lessons by topic/part for clarity and modern UI
  final List<Map<String, dynamic>> lessonGroups = [
    {
      'section': 'Constitution & Preamble',
      'lessons': [
        {
          'title':
              'The Preamble and the Salient Features of the Constitution of India'
        },
      ],
    },
    {
      'section': 'Major Political Theories',
      'lessons': [
        {'title': 'Major Political Theories'},
      ],
    },
    {
      'section': 'Distinction Between Society, Nation, State and Government',
      'lessons': [
        {
          'title':
              'Distinction Between Society, Nation, State and Government (Part-1)'
        },
        {
          'title':
              'Distinction Between Society, Nation, State and Government (Part-2)'
        },
        {
          'title':
              'Distance Between Society, Nation State and Government (Part-1)'
        },
      ],
    },
    {
      'section': 'Fundamental Rights',
      'lessons': [
        {'title': 'Fundamental Rights Part-1'},
        {'title': 'Fundamental Rights Part-2'},
      ],
    },
    {
      'section': 'Federal System',
      'lessons': [
        {'title': 'India Federal System'},
      ],
    },
    {
      'section': 'Union Executive',
      'lessons': [
        {'title': 'Union Executive'},
      ],
    },
    {
      'section': 'Supreme Court',
      'lessons': [
        {'title': 'Supreme Court of India'},
        {'title': 'Supreme Court of India Part-2'},
      ],
    },
    {
      'section': 'State Legislature',
      'lessons': [
        {'title': 'State Legislature Part-1'},
        {'title': 'State Legislature Part-2'},
      ],
    },
    {
      'section': 'High Courts',
      'lessons': [
        {'title': 'High Courts and Subordinate Courts'},
      ],
    },
    {
      'section': 'Nation and State',
      'lessons': [
        {'title': 'Nation and State'},
      ],
    },
    {
      'section': 'Local Government',
      'lessons': [
        {'title': 'Structure of Government: Local Government Urban and Rural'},
        {'title': 'Local Government: Urban and Rural'},
      ],
    },
    {
      'section': 'Executive in the States',
      'lessons': [
        {'title': 'Executive in the States'},
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
                title: 'Political Science Lessons',
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
