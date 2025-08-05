// lib/src/presentation/screens/learn_flow/elementary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/subject_card.dart';
import 'alphabets_lessons_screen.dart'; // Import the Alphabets lessons screen
import 'generic_lesson_screen.dart'; // Import the generic lesson screen
import '../../../services/video_asset_service.dart'; // Import video asset service

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Elementary Categories',
                  onBackPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: screenHeight * 0.015),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(
                      bottom: screenHeight * 0.02,
                      top: screenHeight * 0.005,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenHeight * 0.015,
                      childAspectRatio:
                          1.1, // Increased aspect ratio to prevent overflow
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final subject = categories[index];
                      return SubjectCard(
                        subjectName: subject['title'],
                        icon: subject['icon'],
                        onTap: () {
                          final categoryTitle = subject['title'];
                          final categoryKey = categoryTitle.toLowerCase();

                          // Check if we have video content for this category
                          final availableLessons =
                              VideoAssetService.getLessonTitlesForCategory(
                                  categoryKey);

                          if (categoryTitle == 'Alphabets') {
                            Navigator.push(
                              context,
                              _cupertinoRoute(AlphabetsLessonsScreen()),
                            );
                          } else if (availableLessons.isNotEmpty) {
                            // Use generic lesson screen for categories with videos
                            Navigator.push(
                              context,
                              _cupertinoRoute(
                                GenericLessonScreen(
                                  categoryTitle: categoryTitle,
                                  categoryKey: categoryKey,
                                  lessons: availableLessons,
                                ),
                              ),
                            );
                          } else {
                            // Show placeholder for categories without videos
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Videos for $categoryTitle are coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
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

  // Helper for Cupertino-style page transition
  Route _cupertinoRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
