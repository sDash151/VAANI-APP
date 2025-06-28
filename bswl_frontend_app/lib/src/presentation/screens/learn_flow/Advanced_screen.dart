// lib/src/presentation/screens/learn_flow/science_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/subject_card.dart';
import 'english_lessons_screen.dart'; // Import the new screen here
import 'isl_history_lessons_screen.dart'; // Import the ISL History screen here
import 'political_science_lessons_screen.dart'; // Import the Political Science screen
import 'environmental_science_lessons_screen.dart'; // Import the Environmental Science screen
import 'mathematics_lessons_screen.dart'; // Import the Mathematics screen

class AdvancedScreen extends StatelessWidget {
  AdvancedScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> topics = [
    {
      'title': 'ISL History',
      'icon': Icons.history_edu,
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ISLHistoryLessonsScreen(),
          ),
        );
      }
    },
    {
      'title': 'English',
      'icon': Icons.language,
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnglishLessonsScreen(),
          ),
        );
      }
    },
    {
      'title': 'Political Science',
      'icon': Icons.account_balance,
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoliticalScienceLessonsScreen(),
          ),
        );
      }
    },
    {
      'title': 'Environmental Science',
      'icon': Icons.eco,
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnvironmentalScienceLessonsScreen(),
          ),
        );
      }
    },
    {
      'title': 'Mathematics',
      'icon': Icons.calculate,
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MathematicsLessonsScreen(),
          ),
        );
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F0FF),
              Color(0xFFF8FBFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Advanced Topics',
                  onBackPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return SubjectCard(
                        subjectName: topic['title'],
                        icon: topic['icon'],
                        onTap: topic['onTap'] != null
                            ? () => topic['onTap'](context)
                            : () {},
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                          .slideY(begin: 0.2);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
