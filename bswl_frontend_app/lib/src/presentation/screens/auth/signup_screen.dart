import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart'
    as my_auth;
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import 'package:bswl_frontend_app/src/presentation/theme/text_styles.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/accessibility/vibration_feedback_widget.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/buttons/gradient_button.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/inputs/rounded_text_field.dart';
import 'package:bswl_frontend_app/src/utils/helpers.dart';
import 'package:vibration/vibration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Haptic feedback on invalid form
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<my_auth.AuthProvider>();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await authProvider.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      if (authProvider.errorMessage == null && authProvider.isAuthenticated) {
        // Send email verification
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && !fbUser.emailVerified) {
          await fbUser.sendEmailVerification();
          if (mounted) {
            Helpers.showSnackBar(
              context,
              'A verification email has been sent to $email. Please verify your email before logging in.',
            );
          }
        }
        // After successful signup, sync user to backend
        if (authProvider.user != null) {
          await _syncUserToBackend(authProvider.user);
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Sign up failed. Please try again.';
        });
        Helpers.showSnackBar(context, _errorMessage!);
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        if (await Vibration.hasVibrator()) {
          await Vibration.vibrate(pattern: [500, 200, 500]);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _syncUserToBackend(user) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': user.uid,
          'fullName': user.fullName,
          'email': user.email,
          'photoUrl': user.photoUrl,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Optionally handle error
        debugPrint('Failed to sync user: \\${response.body}');
      }
    } catch (e) {
      debugPrint('Error syncing user to backend: \\${e.toString()}');
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Enter at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // Animated header with a sign-up title
              _buildHeader().animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 48),

              // Sign-up form
              _buildSignUpForm(inputDecoration)
                  .animate()
                  .slideX(begin: -0.1, duration: 500.ms)
                  .fadeIn(),

              const SizedBox(height: 32),

              // Footer options (navigate to Login)
              _buildFooterOptions(context).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Placeholder for an animation or icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_alt_1,
            size: 60,
            color: AppColors.primary,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shake(duration: 2000.ms, hz: 2)
            .fadeIn(duration: 500.ms),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: TextStyles.textTheme.displayLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ).animate().slideY(duration: 500.ms).fadeIn(),
        Text(
          'Join to continue learning',
          style: TextStyles.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ).animate().slideY(duration: 500.ms, delay: 100.ms).fadeIn(),
      ],
    );
  }

  Widget _buildSignUpForm(InputDecoration inputDecoration) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Full Name
          RoundedTextField(
            controller: _fullNameController,
            labelText: 'Full Name',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: _validateFullName,
          ),
          const SizedBox(height: 20),

          // Email
          RoundedTextField(
            controller: _emailController,
            labelText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),

          // Password
          RoundedTextField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          // Confirm Password
          RoundedTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
            ),
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) => _submitForm(),
          ),
          const SizedBox(height: 24),

          // Show error message if any
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
          ],

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GradientButton(
              onPressed: _isLoading ? null : _submitForm,
              text: 'Sign Up',
              isLoading: _isLoading,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider and social sign-up prompt
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: TextStyles.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ).animate().fadeIn(duration: 800.ms),
          const SizedBox(height: 24),

          // Social sign-up buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: FontAwesomeIcons.google,
                iconColor: Color(0xFFEA4335), // Google's red
                onPressed: () => _socialSignUp('google'),
              ),
              const SizedBox(width: 20),
              _buildSocialButton(
                icon: Icons.facebook,
                onPressed: () => _socialSignUp('facebook'),
              ),
              const SizedBox(width: 20),
              _buildSocialButton(
                icon: Icons.apple,
                onPressed: () => _socialSignUp('apple'),
              ),
            ],
          ).animate().slideY(duration: 900.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    Color? iconColor,
    VoidCallback? onPressed,
  }) {
    return VibrationFeedbackWidget(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 32, color: iconColor),
      ),
    );
  }

  Widget _buildFooterOptions(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
              style: TextStyles.textTheme.bodyMedium,
            ),
            VibrationFeedbackWidget(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
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

  Future<void> _socialSignUp(String provider) async {
    setState(() => _isLoading = true);
    try {
      await context.read<my_auth.AuthProvider>().socialSignUp(provider);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (_) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          ' {provider} sign-up failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
