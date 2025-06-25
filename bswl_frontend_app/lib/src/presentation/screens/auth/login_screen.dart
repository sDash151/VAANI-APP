import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Always update local error message after login attempt
      if (!authProvider.isAuthenticated) {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Invalid email or password.';
        });
        debugPrint('LOGIN ERROR: [31m[1m[47m[30m' +
            (_errorMessage ?? '') +
            '\u001b[0m');
        Helpers.showSnackBar(context, _errorMessage!);
        await Vibration.vibrate(pattern: [500, 200, 500]);
        return;
      }
      // Navigation handled by AuthWrapper or here if needed
    } catch (e) {
      if (mounted) {
        setState(() {
          // Always use the latest error from authProvider if available
          _errorMessage = authProvider.errorMessage ??
              'An unexpected error occurred. Please try again later.';
        });
        debugPrint('LOGIN ERROR (catch): [31m[1m[47m[30m' +
            (_errorMessage ?? '') +
            '\u001b[0m');
        Helpers.showSnackBar(context, _errorMessage!);
        await Vibration.vibrate(pattern: [500, 200, 500]);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Always sync error message from provider to local state for UI display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && authProvider.errorMessage != _errorMessage) {
        setState(() {
          _errorMessage = authProvider.errorMessage;
        });
      }
    });

    return Scaffold(
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildLoginBody(context),
    );
  }

  Widget _buildLoginBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            _buildHeader(),
            const SizedBox(height: 48),
            _buildLoginForm(),
            const SizedBox(height: 32),
            _buildFooterOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Sign language animation placeholder
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.waving_hand,
            size: 60,
            color: AppColors.primary,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shake(duration: 2000.ms, hz: 2)
            .fadeIn(duration: 500.ms),

        const SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: TextStyles.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).animate().slideY(duration: 500.ms).fadeIn(),
        Text(
          'Sign in to continue learning',
          style: TextStyles.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().slideY(duration: 500.ms, delay: 100.ms).fadeIn(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_rounded, color: Colors.red, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login Failed',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          ],

          // Email field
          RoundedTextField(
            controller: _emailController,
            labelText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ).animate().slideX(begin: -0.1, duration: 400.ms).fadeIn(),

          const SizedBox(height: 20),

          // Password field
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ).animate().slideX(begin: -0.1, duration: 500.ms).fadeIn(),

          const SizedBox(height: 16),

          // Remember me & Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    'Remember me',
                    style: TextStyles.textTheme.bodyMedium,
                  ),
                ],
              ),

              // Forgot password
              VibrationFeedbackWidget(
                onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: TextStyles.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).animate().slideX(begin: 0.1, duration: 600.ms).fadeIn(),

          const SizedBox(height: 32),

          // Sign in button
          GradientButton(
            onPressed: _isLoading ? null : _submitForm,
            text: 'Sign In',
            isLoading: _isLoading,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ).animate().slideY(duration: 700.ms).fadeIn(),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: TextStyles.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ).animate().fadeIn(duration: 800.ms),

          const SizedBox(height: 24),

          // Social login buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: FontAwesomeIcons.google,
                iconColor: Color(0xFFEA4335), // Google's red
                onPressed: () => _socialLogin('google'),
              ),
              // const SizedBox(width: 20),
              // _buildSocialButton(
              //   icon: Icons.facebook,
              //   onPressed: () => _socialLogin('facebook'),
              // ),
              // const SizedBox(width: 20),
              // _buildSocialButton(
              //   icon: Icons.apple,
              //   onPressed: () => _socialLogin('apple'),
              // ),
            ],
          ).animate().slideY(duration: 900.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      {required IconData icon, Color? iconColor, VoidCallback? onPressed}) {
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
              "Don't have an account? ",
              style: TextStyles.textTheme.bodyMedium,
            ),
            VibrationFeedbackWidget(
              onTap: () => Navigator.pushNamed(context, '/signup'),
              child: Text(
                'Sign Up',
                style: TextStyles.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().slideY(duration: 1000.ms).fadeIn(),

        const SizedBox(height: 40),

        // Accessibility note
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

  Future<void> _socialLogin(String provider) async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().socialLogin(provider);
      // Navigation handled by AuthWrapper
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, ' {provider} login failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
