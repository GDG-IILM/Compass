// lib/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../dashboard/dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check authentication status
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (mounted) {
        if (user != null) {
          // User is logged in, navigate to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          // User is not logged in, navigate to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your splash screen image
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/SplashScreen.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Optional loading indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}