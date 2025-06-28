import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';

class ISLHistoryLessonsScreen extends StatelessWidget {
  ISLHistoryLessonsScreen({Key? key}) : super(key: key);

  final List<String> lessons = [
    'Aspects of Deaf Culture and Linguistic Identity',
    'Sentence Types',
    'The Meaning of Signs',
    'Legislative Provisions for ISL in India',
    'Basic Facts about the History of ISL',
    'Indian Sign Language as a Complete Language',
    'Manual and Non-Manual Components of ISL',
    'News Reading',
    'Sentences Types',
    'Deaf Communities and Sign Languages in Other Countries, in Comparison to ISL',
    'Word-Level Structure',
    'Sign Language in Social Media',
    'ISL as a Complete Language',
    'Stories',
    'Poems & Songs',
    'The Community of Indian Sign Language Users, their Commonalities and Diversity',
    'Status of Use of ISL in Deaf Education',
    'Indian Sign Languages as a Complete Language',
    'Legislative Provisions for ISL in India',
    'Word Level Structures',
    'The Community of Indian Sign Language Users, their Commonalities and Diversity',
    'Status of Use of ISL in Deaf Education',
    'Sentence Types',
    'Indian Sign Languages as a Complete Language',
    'Deaf Communities and Sign Languages in Other Countries, in Comparison to ISL',
    'Legislative Provisions for ISL in India',
    'Basic Facts about the History of ISL',
    'Sign Language in Social Media',
    'Manual and Non-Manual Components of ISL',
    'Status of Use of ISL in Deaf Education',
    'Deaf Communities and Sign Languages in Other Countries, in Comparison to ISL',
    'Word-Level Structure',
    'Basic Facts about the History of ISL',
    'Status of Use of ISL in Deaf Education',
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
                title: 'ISL History Lessons',
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
