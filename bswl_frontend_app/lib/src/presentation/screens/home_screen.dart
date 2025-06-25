import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/progress_card.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/action_card.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/WeeklyInsightCard.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/header.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/translate_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/profile_screen.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/lesson_card.dart';
import 'package:provider/provider.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const LearnScreen(),
    const TranslateScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Adjusted opacity
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate_outlined),
              activeIcon: Icon(Icons.translate),
              label: 'Translate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the user's name from AuthProvider
    final user = Provider.of<AuthProvider>(context, listen: true).user;
    final String fullName = (user?.fullName ?? '').trim();
    final String firstName =
        fullName.split(' ').firstWhere((s) => s.isNotEmpty, orElse: () => '');
    final String greeting =
        firstName.isNotEmpty ? 'Hello, $firstName!' : 'Hello!';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            AppHeader(
              title: greeting,
              profileImageUrl:
                  "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Lottie.asset(
                'assets/animations/student.json', // Path to your JSON file
                height: 340, // Adjust height as needed
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              ),
            ),

            const SizedBox(height: 16), // Reduced spacing
            const ProgressCard(
              title: "Overall Progress",
              progress: 0.75,
              subtitle: "Keep up the great work!",
              completedLessons: "18",
              totalLessons: "24",
            ),
            const SizedBox(height: 24),

            // Add Weekly Insight Card here
            WeeklyInsightCard(
              videosWatched: 8,
              lessonsCompleted: 4,
              progressPercentage: 0.15, // 15% improvement
            ),
            const SizedBox(height: 24),
            Text("Quick Actions",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    icon: Icons.school,
                    title: "Learn",
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ActionCard(
                    icon: Icons.translate,
                    title: "Translate",
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("Continue Learning",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const LessonCard(
              title: "Basic Greetings",
              progress: 0.75,
              icon: Icons.waving_hand,
            ),
            const SizedBox(height: 16),
            const LessonCard(
              title: "Numbers 1-20",
              progress: 0.4,
              icon: Icons.numbers,
            ),
          ],
        ),
      ),
    );
  }
}
