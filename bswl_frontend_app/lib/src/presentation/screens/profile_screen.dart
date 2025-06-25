import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:bswl_frontend_app/src/presentation/screens/progress/progress_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/achievements/achievements_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/notifications/notifications_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/settings/settings_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/support/help_support_screen.dart';
import 'package:bswl_frontend_app/src/services/streak_service.dart';
import 'package:intl/intl.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/page_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final enrolledCourses = 12;
    final completedCourses = 8;
    final learningHours = 42;
    final streakDays = 16;
    final streakService = StreakService();

    return Scaffold(
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // New wave header
              _ProfileHeader(
                name: user?.fullName ?? "Guest",
                email: user?.email ?? "No Email",
                streakDays: streakDays,
              ),
              // StreakGridCard connected to backend
              FutureBuilder<List<int>>(
                future: streakService.fetchUserStreak(user?.uid ?? 'demo'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Failed to load streak data'),
                    );
                  } else {
                    // Build date list and streak map for the last 12 weeks
                    final weeks = 12;
                    final now = DateTime.now();
                    final firstDay =
                        now.subtract(Duration(days: (weeks * 7) - 1));
                    final dates = List<DateTime>.generate(
                        weeks * 7, (i) => firstDay.add(Duration(days: i)));
                    final streakMap = <String, int>{};
                    for (int i = 0;
                        i < dates.length && i < (snapshot.data?.length ?? 0);
                        i++) {
                      streakMap[DateFormat('yyyy-MM-dd').format(dates[i])] =
                          snapshot.data![i];
                    }
                    return StreakGridCard(
                      dates: dates,
                      streakData: streakMap,
                      weeks: weeks,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildLearningStats(
                  enrolledCourses, completedCourses, learningHours),
              const SizedBox(height: 24),
              _buildProgressSection(context),
              const SizedBox(height: 24),
              _buildAchievementsSection(context),
              const SizedBox(height: 24),
              _buildSettingsSection(context),
              const SizedBox(height: 32),
              _buildLogoutButton(context, authProvider),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningStats(int enrolled, int completed, int hours) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.school, 'Enrolled', '$enrolled'),
          _buildStatItem(Icons.check_circle, 'Completed', '$completed'),
          _buildStatItem(Icons.access_time, 'Hours', '$hours'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 16),
          _buildProgressItem(context, 'English', 0.75),
          const SizedBox(height: 12),
          _buildProgressItem(context, 'Social Studies', 0.45),
          const SizedBox(height: 12),
          _buildProgressItem(context, 'Mathematics', 0.30),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('View All Courses',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      BuildContext context, String course, double percent) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressPage(),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(course,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              Text('${(percent * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: percent,
            backgroundColor: Colors.grey[200]!,
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(10),
            animation: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAchievementBadge(context, Icons.emoji_events, 'Master', 3),
              _buildAchievementBadge(context, Icons.star, 'Streak', 16),
              _buildAchievementBadge(context, Icons.bolt, 'Speedster', 2),
              _buildAchievementBadge(
                  context, Icons.workspace_premium, 'Pro', 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context, IconData icon, String title, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AchievementsPage(),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text('$count',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const Divider(height: 0, indent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: 'Settings',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(height: 0, indent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            onTap: () => Navigator.pushNamed(context, '/payments'),
          ),
          const Divider(height: 0, indent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () => Navigator.pushNamed(context, '/help'),
          ),
          const Divider(height: 0, indent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Widget? page;
          if (title == 'Notifications') {
            page = NotificationsPage();
          } else if (title == 'Settings') {
            page = SettingsPage();
          } else if (title == 'Payment Methods') {
            page = PaymentsPage();
          } else if (title == 'Help Center') {
            page = HelpSupportPage();
          }
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            );
          } else {
            onTap();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: OutlinedButton(
        onPressed: () async {
          if (!context.mounted)
            return; // Prevent showing dialog if context is not mounted
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
          if (confirmed != true || !context.mounted) return;

          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(child: CircularProgressIndicator()),
          );

          // Pop the loading dialog BEFORE signOut
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            Navigator.pop(context);
          }

          String? error;
          try {
            print('LOGOUT: Calling signOut...');
            await authProvider.signOut();
            print('LOGOUT: signOut completed');
          } catch (e) {
            error = e.toString();
            print('LOGOUT ERROR: ' + error);
          }

          // After signOut, check if context is still mounted before navigating or showing snackbar
          if (!context.mounted) {
            print(
                'LOGOUT: Context is not mounted after signOut, cannot navigate.');
            return;
          }
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout failed: ' + error)),
            );
          } else {
            print('LOGOUT: Navigating to /login');
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.red[400]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red[400], size: 20),
            const SizedBox(width: 10),
            Text('Logout',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final int streakDays;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ProfileWaveClipper(),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative icon in the background
            Positioned(
              right: 20,
              top: 20,
              child: const SizedBox.shrink()
                  .animate()
                  .fadeIn(duration: 900.ms)
                  .scaleXY(begin: 0.5),
            ),

            // Main Column with user profile info
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.white.withOpacity(0.2),
                      child: Lottie.asset(
                        'assets/animations/BOY2.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scaleXY(begin: 0.8, curve: Curves.easeOutBack),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 3.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyles.textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3),
                const SizedBox(height: 16),
                if (streakDays > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[700]?.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text('$streakDays day streak',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn().scaleXY(begin: 0.8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 40,
      size.width * 0.5,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 20,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Updated PaymentsPage widget
class PaymentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: "Payment Methods",
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: Center(child: Text('Payments page coming soon!')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreakGridCard extends StatelessWidget {
  final List<DateTime> dates;
  final Map<String, int> streakData;
  final int maxPerDay;
  final int weeks;

  const StreakGridCard({
    super.key,
    required this.dates,
    required this.streakData,
    this.maxPerDay = 4,
    this.weeks = 12,
  });

  Color _getColor(int value) {
    if (value == 0) return Colors.grey[200]!;
    if (value == 1) return const Color(0xFFA8E6A3);
    if (value == 2) return const Color(0xFF6FCF97);
    if (value == 3) return const Color(0xFF27AE60);
    return const Color(0xFF145A32);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = now.subtract(Duration(days: (weeks * 7) - 1));
    final grid = List.generate(
        weeks,
        (w) => List.generate(7, (d) {
              final date = firstDay.add(Duration(days: w * 7 + d));
              final key = DateFormat('yyyy-MM-dd').format(date);
              return streakData[key] ?? 0;
            }));
    final monthLabels = <String>[];
    for (int w = 0; w < weeks; w++) {
      final date = firstDay.add(Duration(days: w * 7));
      final label = DateFormat('MMM').format(date);
      if (w == 0 || label != monthLabels.last) {
        monthLabels.add(label);
      } else {
        monthLabels.add('');
      }
    }
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth - 40; // 20px margin each side
    final cellSize = (gridWidth - 24 - (weeks * 2)) /
        weeks; // 24 for day labels, 2px spacing per col
    final cellSizeClamped = cellSize.clamp(12.0, 22.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Streak (Problems Solved)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 24),
              ...monthLabels.map((label) => SizedBox(
                    width: cellSizeClamped,
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: List.generate(7, (d) {
                  final day =
                      DateFormat('E').format(firstDay.add(Duration(days: d)));
                  return SizedBox(
                    height: cellSizeClamped,
                    width: 24,
                    child: Text(day[0], style: const TextStyle(fontSize: 10)),
                  );
                }),
              ),
              // Grid cells (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(weeks, (w) {
                      return Column(
                        children: List.generate(7, (d) {
                          return Container(
                            width: cellSizeClamped,
                            height: cellSizeClamped,
                            margin: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 1),
                            decoration: BoxDecoration(
                              color: _getColor(grid[w][d]),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      );
                    }),
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
