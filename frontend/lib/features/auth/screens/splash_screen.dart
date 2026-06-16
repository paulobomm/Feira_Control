import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await context.read<AuthProvider>().checkAuth();
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      context.go(auth.user!.isAdmin ? '/admin' : '/feirante');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 80, color: Colors.deepOrange),
            SizedBox(height: 16),
            Text(
              'FeiraControl',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.deepOrange),
          ],
        ),
      ),
    );
  }
}
