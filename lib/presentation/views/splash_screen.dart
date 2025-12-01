import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/global.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final session = supabase.auth.currentSession;

    if (session != null) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/imageload.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'PAMELA CRUISE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phân tích Chất thải Hàng hải',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
