// lib/src/presentation/screens/learn_flow/intermediate_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/subject_card.dart';

class IntermediateScreen extends StatelessWidget {
  IntermediateScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> categories = [
    {'title': 'English Grammar', 'icon': Icons.menu_book},
    {'title': 'Question Words', 'icon': Icons.help_outline},
    {'title': 'Parts Of Speech', 'icon': Icons.category},
    {'title': 'Noun', 'icon': Icons.language},
    {'title': 'Pronoun', 'icon': Icons.person},
    {'title': 'Adjectives', 'icon': Icons.edit},
    {'title': 'Verb', 'icon': Icons.run_circle},
    {'title': 'Adverb', 'icon': Icons.speed},
    {'title': 'Preposition', 'icon': Icons.swap_horiz},
    {'title': 'Idioms', 'icon': Icons.lightbulb},
    {'title': 'Phrasal Verbs', 'icon': Icons.merge_type},
    {'title': 'Interjections', 'icon': Icons.subscript},
    {'title': 'Conjunctions', 'icon': Icons.superscript},
    {'title': 'Making Sentence', 'icon': Icons.today},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Intermediate Categories',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onTap: () {},
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
    );
  }
}
