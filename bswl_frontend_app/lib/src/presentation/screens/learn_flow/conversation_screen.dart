// lib/src/presentation/screens/learn_flow/conversation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/video_lesson_card.dart';
import '../../widgets/page_header.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({Key? key}) : super(key: key);

  static final List<String> _lessonTitles = [
    'Bank Conversation - Apply in Open Account',
    'Polite & Impolite Sentences (Indian Sign Language)',
    'Conversation (1) (Indian Sign Language)',
    'Conversation 1 - Question and Answer (Part - 3) - Indian Sign Language',
    'Conversation 1 - Question and Answer (Part - 1) - Indian Sign Language',
    'Conversation 1 - Question and Answer (Part - 2) - Indian Sign Language',
    'Conversation between Landlord and Tenant (Indian Sign Language)',
    'Conversation 1 - Question and Answer (Part - 5) - Indian Sign Language',
    'Impolite & polite sentences part- 2 (Indian Sign Language)',
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
                title: 'Conversation Lessons',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: _lessonTitles.length,
                  itemBuilder: (context, index) {
                    return VideoLessonCard(
                      title: _lessonTitles[index],
                      subtitle: 'Tap to watch.',
                      onTap: () {
                        Navigator.of(context).push(
                          _cupertinoRoute(const _VideoPlayerPlaceholder()),
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
