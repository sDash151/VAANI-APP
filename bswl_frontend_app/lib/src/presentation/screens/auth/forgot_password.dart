import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/accessibility/vibration_feedback_widget.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/buttons/gradient_button.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/inputs/rounded_text_field.dart';
import 'package:vibration/vibration.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void showSnackBar(BuildContext context, String message, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: bgColor ?? Colors.redAccent,
    ));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().sendPasswordResetEmail(_emailController.text.trim());
      showSnackBar(context, 'Password reset email sent!', bgColor: Colors.green);
      Navigator.pop(context); // Go back to login screen after success
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to send reset email: ${e.toString()}');
        await Vibration.vibrate(pattern: [500, 200, 500]);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: Column(
          children: [
            const SizedBox(height: 80),
            _buildHeader(),
            const SizedBox(height: 48),
            _buildForm(),
            const SizedBox(height: 32),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_outlined, size: 60, color: AppColors.primary),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shake(duration: 2000.ms, hz: 2)
            .fadeIn(duration: 500.ms),
        const SizedBox(height: 24),
        Text(
          'Forgot Password?',
          style: TextStyles.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
        ).animate().slideY(duration: 500.ms).fadeIn(),
        Text(
          'Enter your email to reset your password',
          style: TextStyles.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ).animate().slideY(duration: 500.ms, delay: 100.ms).fadeIn(),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RoundedTextField(
            controller: _emailController,
            labelText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ).animate().slideX(begin: -0.1, duration: 400.ms).fadeIn(),
          const SizedBox(height: 32),
          GradientButton(
            onPressed: _isLoading ? null : _submitForm,
            text: 'Send Reset Email',
            isLoading: _isLoading,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ).animate().slideY(duration: 700.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Remember your password?", style: TextStyles.textTheme.bodyMedium),
            VibrationFeedbackWidget(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Login',
                style: TextStyles.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().slideY(duration: 1000.ms).fadeIn(),
        const SizedBox(height: 40),
        Text(
          'Tip: Long press any element for vibration feedback',
          style: TextStyles.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ).animate().fadeIn(delay: 1100.ms),
      ],
    );
  }
}
