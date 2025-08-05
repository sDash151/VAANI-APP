import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/progress_card.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/action_card.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/WeeklyInsightCard.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/header.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/learn_flow/elementary_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/detection_mode_screen.dart';
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
    const DetectionModeScreen(),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 22),
              activeIcon: Icon(Icons.home, size: 22),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined, size: 22),
              activeIcon: Icon(Icons.school, size: 22),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate_outlined, size: 22),
              activeIcon: Icon(Icons.translate, size: 22),
              label: 'Translate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, size: 22),
              activeIcon: Icon(Icons.person, size: 22),
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
    // Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700; // For smaller devices

    // Get the user's name from AuthProvider
    final user = Provider.of<AuthProvider>(context, listen: true).user;
    final String fullName = (user?.fullName ?? '').trim();
    final String firstName =
        fullName.split(' ').firstWhere((s) => s.isNotEmpty, orElse: () => '');
    final String greeting =
        firstName.isNotEmpty ? 'Hello, $firstName!' : 'Hello!';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 5% of screen width
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optimized Header
              AppHeader(
                title: greeting,
                profileImageUrl:
                    "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
              ),

              SizedBox(height: screenHeight * 0.02),

              // Responsive Lottie Animation
              Container(
                height: screenHeight * 0.25, // 25% of screen height
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Lottie.asset(
                    'assets/animations/student.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.025),

              // Progress Card
              const ProgressCard(
                title: "Overall Progress",
                progress: 0.75,
                subtitle: "Keep up the great work!",
                completedLessons: "18",
                totalLessons: "24",
              ),

              SizedBox(height: screenHeight * 0.025),

              // Weekly Insight Card
              WeeklyInsightCard(
                videosWatched: 8,
                lessonsCompleted: 4,
                progressPercentage: 0.15,
              ),

              SizedBox(height: screenHeight * 0.025),

              // Quick Actions Section
              _buildSectionTitle(context, "Quick Actions"),
              SizedBox(height: screenHeight * 0.015),

              // Responsive Action Cards
              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.school,
                      title: "Learn",
                      color: AppColors.primary,
                      onTap: () {
                        // Navigate to Learn screen (index 1 in bottom navigation)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LearnScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.translate,
                      title: "Translate",
                      color: AppColors.accent,
                      onTap: () {
                        // Navigate to Detection Mode screen (index 2 in bottom navigation)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DetectionModeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.025),

              // Continue Learning Section
              _buildSectionTitle(context, "Continue Learning"),
              SizedBox(height: screenHeight * 0.015),

              // Lesson Cards with proper spacing
              LessonCard(
                title: "Basic Greetings",
                progress: 0.75,
                icon: Icons.waving_hand,
                onTap: () {
                  // Navigate directly to Elementary screen for greetings
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ElementaryScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.015),
              LessonCard(
                title: "Numbers 1-20",
                progress: 0.4,
                icon: Icons.numbers,
                onTap: () {
                  // Navigate directly to Elementary screen for numbers
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ElementaryScreen(),
                    ),
                  );
                },
              ),

              // Bottom padding for safe area
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18, // Slightly smaller for better fit
          ),
    );
  }
}
