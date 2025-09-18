import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/bottomNavBar.dart';
import 'package:tugas_17_flutter/utils/shared_preference.dart';
import 'package:tugas_17_flutter/view/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLogin = await PreferenceHandler.isLoggedIn();

    final token = await PreferenceHandler.getToken();

    await Future.delayed(const Duration(seconds: 2));

    if (isLogin == true && token != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavigator()),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
