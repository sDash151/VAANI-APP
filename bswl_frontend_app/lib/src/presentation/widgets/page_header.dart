import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;

  const PageHeader({
    Key? key,
    required this.title,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: onBackPressed,
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }
}