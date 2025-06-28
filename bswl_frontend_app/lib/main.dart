import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bswl_frontend_app/src/data/repositories/auth_repository.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_theme.dart';
import 'package:bswl_frontend_app/src/presentation/screens/home_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/auth/login_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/auth/signup_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/auth/forgot_password.dart';
import 'package:bswl_frontend_app/src/presentation/screens/auth/reset_password_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/profile/edit_profile_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/profile/change_password_screen.dart';
import 'package:bswl_frontend_app/utils/backend_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ENSURE Flutter is ready
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(); // ✅ Initialize Firebase
  await testBackendConnection(); // TEMP: Test backend connection at startup
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(AuthRepository())..loadCurrentUser(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSWL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final token = args?['token'] as String?;
          if (token == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid or missing reset token.')),
            );
          }
          return ResetPasswordScreen(token: token);
        },
        '/edit-profile': (context) => const EditProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
