import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Artificial delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = ref.read(authControllerProvider);
    if (auth.isLoggedIn) {
      context.go('/home');
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
            Image.asset(
              'assets/images/applogo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Speedo Express',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF1F2430),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFE5E7EB),
                color: Color(0xFFFF5A1F),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
