import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';

class AlphabetsLessonsScreen extends StatelessWidget {
  AlphabetsLessonsScreen({Key? key}) : super(key: key);

  final List<String> lessons = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
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
                title: 'Alphabets',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    return VideoLessonCard(
                      title: lessons[index],
                      subtitle: 'Tap to watch.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(lessons[index]),
                              ),
                              body: Center(
                                child: Text(
                                  'Video player for "${lessons[index]}" coming soon!',
                                  style: theme.textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (index * 100).ms)
                        .slideY(begin: 0.15);
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
