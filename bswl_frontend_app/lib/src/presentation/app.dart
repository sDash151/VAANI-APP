import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/presentation/screens/auth/login_screen.dart';
import 'package:bswl_frontend_app/src/presentation/screens/home_screen.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart';

class InfosyncApp extends StatelessWidget {
  const InfosyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return authProvider.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
