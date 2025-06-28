// lib/src/presentation/screens/learn_flow/morals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/video_lesson_card.dart';
import '../../widgets/page_header.dart';

class MoralsScreen extends StatelessWidget {
  const MoralsScreen({Key? key}) : super(key: key);

  static final List<String> _moralTitles = [
    'The Honest Woodcutter (Indian Sign Language)',
    'The Lion and the Mouse (Indian Sign Language)',
    'The Boy Who Cried Wolf (Indian Sign Language)',
    'The Wind and the Sun (Indian Sign Language)',
    'The Tortoise and the Hare (Indian Sign Language)',
    "The Peacock's Complaint (Indian Sign Language)",
    'King Midas and the golden touch (Indian Sign Language)',
    'The milkmaid and her pail (Indian Sign Language)',
    'The Ant and the Grasshopper (Indian Sign Language)',
    'Belling the Cat (Indian Sign Language)',
    'The Dog and His Reflection (Indian Sign Language)',
    'The Ass in the Lion\'s Skin (Indian Sign Language)',
    'The Sour Grapes (Indian Sign Language)',
    'The Bundle of Sticks (Indian Sign Language)',
    'The Bear and the Two Travellers (Indian Sign Language)',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Moral Stories',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: isTablet
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1.9,
                        ),
                        itemCount: _moralTitles.length,
                        itemBuilder: (context, index) {
                          return VideoLessonCard(
                            title: _moralTitles[index],
                            subtitle: 'Tap to watch.',
                            onTap: () {
                              Navigator.of(context).push(
                                _cupertinoRoute(
                                    const _VideoPlayerPlaceholder()),
                              );
                            },
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: (index * 100).ms)
                              .slideY(begin: 0.15);
                        },
                      )
                    : ListView.builder(
                        itemCount: _moralTitles.length,
                        itemBuilder: (context, index) {
                          return VideoLessonCard(
                            title: _moralTitles[index],
                            subtitle: 'Tap to watch.',
                            onTap: () {
                              Navigator.of(context).push(
                                _cupertinoRoute(
                                    const _VideoPlayerPlaceholder()),
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

class _VideoPlayerPlaceholder extends StatelessWidget {
  const _VideoPlayerPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Center(
        child: Container(
          width: 220,
          height: 140,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.play_circle_fill_rounded,
              size: 60, color: colorScheme.primary),
        ),
      ),
    );
  }
}
