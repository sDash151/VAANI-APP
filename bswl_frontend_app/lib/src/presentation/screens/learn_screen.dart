import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/learn_header.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_flow/elementary_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_flow/intermediate_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_flow/conversation_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_flow/morals_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_flow/Advanced_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {'name': 'Elementary', 'icon': Icons.school},
      {'name': 'Intermediate', 'icon': Icons.auto_stories},
      {'name': 'Conversation', 'icon': Icons.forum},
      {'name': 'Morals', 'icon': Icons.volunteer_activism},
      {'name': 'Advanced', 'icon': Icons.rocket_launch},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 🎨 Decorative Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.05), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 🌟 Main Content with LearnHeader
          Column(
            children: [
              // 👤 Animated Wave Header
              const LearnHeader(profileImageUrl: null),

              const SizedBox(height: 16),

              // 📚 Title with Animation
              Animate(
                effects: [
                  FadeEffect(duration: 500.ms),
                  SlideEffect(duration: 500.ms)
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Subjects',
                    style: GoogleFonts.montserrat(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔢 Subject Grid with Animation
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      if (subject['name'] == 'Elementary') {
                        return SubjectCard(
                          subjectName: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ElementaryScreen(),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideY(begin: 0.2);
                      } else if (subject['name'] == 'Intermediate') {
                        return SubjectCard(
                          subjectName: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IntermediateScreen(),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideY(begin: 0.2);
                      } else if (subject['name'] == 'Conversation') {
                        return SubjectCard(
                          subjectName: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideY(begin: 0.2);
                      } else if (subject['name'] == 'Morals') {
                        return SubjectCard(
                          subjectName: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoralsScreen(),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideY(begin: 0.2);
                      } else if (subject['name'] == 'Advanced') {
                        return SubjectCard(
                          subjectName: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdvancedScreen(),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideY(begin: 0.2);
                      }
                      // Defensive: Should never reach here, but return a SizedBox if so
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubjectCard extends StatefulWidget {
  final String subjectName;
  final IconData icon;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.icon,
    required this.onTap,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.subjectName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
