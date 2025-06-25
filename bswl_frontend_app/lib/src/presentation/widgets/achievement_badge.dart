import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool achieved;

  const AchievementBadge({
    Key? key,
    required this.icon,
    required this.title,
    required this.achieved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: achieved ? AppColors.primaryLight : AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: achieved ? AppColors.accent : AppColors.textSecondary,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 40,
            color: achieved ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: achieved ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}