import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnswerCard extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const AnswerCard({
    Key? key,
    required this.answer,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = isSelected ? AppColors.accent : AppColors.primaryLight;
    Color bgColor = Colors.white;

    if (isCorrect) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
    } else if (isWrong) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect
                  ? Icons.check_circle
                  : isWrong
                      ? Icons.cancel
                      : isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
              color: isCorrect
                  ? Colors.green
                  : isWrong
                      ? Colors.red
                      : isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}