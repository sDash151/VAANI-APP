// lib/src/presentation/screens/learn_flow/elementary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/subject_card.dart';
import 'alphabets_lessons_screen.dart'; // Import the Alphabets lessons screen

class ElementaryScreen extends StatelessWidget {
  ElementaryScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> categories = [
    {'title': 'Alphabets', 'icon': Icons.sort_by_alpha},
    {'title': 'Greetings', 'icon': Icons.waving_hand},
    {'title': 'Numbers', 'icon': Icons.pin},
    {'title': 'Days', 'icon': Icons.calendar_today},
    {'title': 'Months', 'icon': Icons.date_range},
    {'title': 'Colours', 'icon': Icons.palette},
    {'title': 'Fruits', 'icon': Icons.apple},
    {'title': 'Vegetables', 'icon': Icons.eco},
    {'title': 'Action Words', 'icon': Icons.directions_run},
    {'title': 'Animals', 'icon': Icons.pets},
    {'title': 'Common Birds', 'icon': Icons.emoji_nature},
    {'title': 'Family', 'icon': Icons.family_restroom},
    {'title': 'Food and Beverages', 'icon': Icons.fastfood},
    {'title': 'India', 'icon': Icons.flag},
    {'title': 'Common Wears', 'icon': Icons.checkroom},
    {'title': 'Emotions', 'icon': Icons.emoji_emotions},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F0FF), // light blue top
              Color(0xFFF8FBFF), // almost white bottom
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
                  title: 'Elementary Categories',
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
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final subject = categories[index];
                      return SubjectCard(
                        subjectName: subject['title'],
                        icon: subject['icon'],
                        onTap: () {
                          if (subject['title'] == 'Alphabets') {
                            Navigator.push(
                              context,
                              _cupertinoRoute(AlphabetsLessonsScreen()),
                            );
                          } else {
                            // TODO: Add navigation for other categories if needed
                          }
                        },
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

// Helper for Cupertino-style page transition
Route _cupertinoRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}
