import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';

class MathematicsLessonsScreen extends StatelessWidget {
  MathematicsLessonsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> lessonGroups = [
    {
      'section': 'Polynomials & Algebraic Expressions',
      'lessons': [
        {'title': 'Addition & Subtraction of Polynomial'},
        {'title': 'Special Products & Factorization Part 1 & 2'},
        {
          'title':
              'Understand & Identify Polynomial as Special Case of Algebraic Expression (Part-3)'
        },
        {'title': 'Algebraic Expression Part-3'},
      ],
    },
    {
      'section': 'Number System',
      'lessons': [
        {'title': 'Number System'},
        {'title': 'Number System, Video Part-2'},
        {'title': 'Number System - Prime & Composite System'},
        {'title': 'Rationals & Irrationals Numbers'},
      ],
    },
    {
      'section': 'Exponents & Radicals',
      'lessons': [
        {'title': 'Exponents & Radicals'},
        {'title': 'Exponents & Radicals Part-2'},
      ],
    },
    {
      'section': 'HCF & LCM',
      'lessons': [
        {'title': 'HCF & LCM of Numbers (Part-2)'},
      ],
    },
    {
      'section': 'Percentage',
      'lessons': [
        {'title': 'Percentage and Its Applications'},
        {'title': 'Vocabulary & Percentage'},
      ],
    },
    {
      'section': 'Quadratic Equations',
      'lessons': [
        {'title': 'Quadratic Equations Introduction, Part-1'},
        {'title': 'Quadratic Formula'},
      ],
    },
    {
      'section': 'Arithmetic Progression',
      'lessons': [
        {'title': 'Arithmetic Progression (Intro)'},
        {'title': 'Arithmetic Progressions'},
        {'title': 'Arithmetic Progressions - Sum of first N terms of AP'},
        {'title': 'Arithmetic Progressions - Check Your Progress 7.3'},
      ],
    },
    {
      'section': 'Check Your Progress',
      'lessons': [
        {'title': 'Check Your Progress - 6-1'},
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
                title: 'Mathematics Lessons',
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
