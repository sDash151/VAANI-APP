import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';

class EnglishLessonsScreen extends StatelessWidget {
  EnglishLessonsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> lessons = [
    // Tiger Comes to Town
    {'title': 'A Tiger Comes to Town - I', 'part': 1},
    {'title': 'A Tiger Comes to Town : Part-2', 'part': 2},
    {'title': 'Tiger Comes to Town', 'part': 1},
    {'title': 'Tiger Comes to the Town Part-2', 'part': 2},
    // Co-operate & Prosper
    {'title': 'Co-Operate and Prosper (Part-1)', 'part': 1},
    {'title': 'Co-operate & Prosper Part-2', 'part': 2},
    {'title': 'Co-operate and Prosper, Part-1', 'part': 1},
    {'title': 'Co-operate and Prosper', 'part': 1},
    // The Village Pharmacy
    {'title': 'The Village Pharmacy', 'part': 1},
    {'title': 'The Village Pharmacy, Part -2', 'part': 2},
    // New Good Things from Rubbish
    {'title': 'New Good Things from Rubbish', 'part': 1},
    {'title': 'The New Good Things from Rubbish, Part-1', 'part': 1},
    // The Shoeshine
    {'title': 'The Shoeshine', 'part': 1},
    // The Truth
    {'title': 'The Truth', 'part': 1},
    // The Little Girl
    {'title': 'The Little Girl', 'part': 1},
    // My Vision for India
    {'title': 'My Vision for India', 'part': 1},
    // Noise: How it Affects Our Lives
    {'title': 'Noise: How it Affects Our Lives', 'part': 1},
    // Once Upon a Time
    {'title': 'Once Upon a Time', 'part': 1},
    // My Elder Brother
    {'title': 'My Elder Brother', 'part': 1},
    // Nine Gold Medals
    {'title': 'Nine Gold Medals', 'part': 1},
    // Indian Weavers
    {'title': 'Indian Weavers', 'part': 1},
    // The Parrot Who Wouldn\'t Talk
    {'title': "The Parrot Who Wouldn't Talk", 'part': 1},
    // Ustad Bismillah Khan
    {'title': 'Ustad Bismillah Khan', 'part': 1},
    // The Return of the Lion
    {'title': 'The Return of the Lion', 'part': 1},
    // My Only Cry
    {'title': 'My Only Cry', 'part': 1},
    // The Last Stone Mason, Part-1
    {'title': 'The Last Stone Mason, Part-1', 'part': 1},
    // My Son Will Not Be a Beggar
    {'title': 'My Son Will Not Be a Beggar', 'part': 1},
    // Father Dear Father
    {'title': 'Father Dear Father', 'part': 1},
    // A Prayer for Healing
    {'title': 'A Prayer for Healing', 'part': 1},
    // Caring for Others
    {'title': 'Caring for Others', 'part': 1},
    // Reading With Understanding
    {'title': 'Reading With Understanding', 'part': 1},
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
                title: 'English Lessons',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return VideoLessonCard(
                      title: lesson['title'],
                      subtitle: 'Tap to watch.',
                      onTap: () {
                        // TODO: Navigate to video player
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
