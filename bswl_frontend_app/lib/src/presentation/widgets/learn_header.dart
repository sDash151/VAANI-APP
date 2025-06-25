import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';

class LearnHeader extends StatelessWidget {
  final String? profileImageUrl;

  const LearnHeader({super.key, this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn Sign Language',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 30,
                    color: const Color.fromARGB(255, 253, 252, 252),
                    fontWeight: FontWeight.bold,
                    shadows: [
                    const Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3.0,
                    color: Colors.black26,
                    ),
                  ],
                 ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),


                  const SizedBox(height: 8),

                  Text(
                    'Choose a subject to get started',
                    style: TextStyles.textTheme.bodyLarge?.copyWith(
                      fontSize: 19,
                      color: Colors.white70,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.4),
                ],
              ),

              // Profile or Icon
              if (profileImageUrl != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(profileImageUrl!),
                    backgroundColor: Colors.white,
                  ).animate().fadeIn().scale(),
                )
              else
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.sign_language,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ).animate().fadeIn().scale(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 30,
    );
    path.quadraticBezierTo(
      3 * size.width / 4,
      size.height - 60,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
