// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_providers.dart';
import './home_screen.dart';
import './login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash'; // Nama rute

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Kita gunakan listen: false di initState karena kita hanya ingin memanggil fungsi,
    // bukan membangun ulang widget ini saat AuthProvider berubah di sini.
    // Penundaan singkat untuk memastikan widget sudah ter-render sebelum navigasi
    // dan juga untuk memberi kesan "splash" jika auto login sangat cepat.
    await Future.delayed(Duration(milliseconds: 500));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isLoggedIn = await authProvider.tryAutoLogin();

    if (mounted) {
      // Pastikan widget masih ada di tree sebelum navigasi
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Atau logo aplikasi Anda
      ),
    );
  }
}
