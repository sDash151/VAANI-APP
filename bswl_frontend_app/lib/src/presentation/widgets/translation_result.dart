import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';

class TranslationResult extends StatelessWidget {
  final String hindiText;
  final String englishText;

  const TranslationResult({
    super.key,
    required this.hindiText,
    required this.englishText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hindi",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {},
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hindiText,
              style: Theme.of(context).textTheme.displaySmall,
            ).animate().fadeIn(duration: 300.ms),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "English",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {},
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              englishText,
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
