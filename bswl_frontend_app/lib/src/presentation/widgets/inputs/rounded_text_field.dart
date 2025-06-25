import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';

/// A rounded, reusable text field widget with customizable properties.
/// Ideal for form inputs like email, password, name, etc.
class RoundedTextField extends StatelessWidget {
  /// Controller for the text input.
  final TextEditingController controller;

  /// Label text displayed above the input.
  final String labelText;

  /// Icon displayed at the start of the input field.
  final IconData? prefixIcon;

  /// Whether the text should be obscured (e.g., for passwords).
  final bool obscureText;

  /// An optional suffix widget (e.g., visibility toggle).
  final Widget? suffixIcon;

  /// Keyboard type (e.g., TextInputType.emailAddress, TextInputType.text).
  final TextInputType keyboardType;

  /// Validator function for form validation.
  final String? Function(String?)? validator;

  /// Action button for the keyboard (e.g., TextInputAction.next, done).
  final TextInputAction textInputAction;

  /// Callback when the user submits the field (e.g., presses "Enter").
  final void Function(String)? onFieldSubmitted;

  /// Maximum number of lines. Default is 1.
  final int maxLines;

  /// Whether the field is enabled or disabled.
  final bool enabled;

  const RoundedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a consistent input decoration for rounded fields
    final inputDecoration = InputDecoration(
      labelText: labelText,
      labelStyle: TextStyles.textTheme.bodyMedium
          ?.copyWith(color: AppColors.textSecondary),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primary)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      decoration: inputDecoration,
      style: TextStyles.textTheme.bodyMedium,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
