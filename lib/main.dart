// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_providers.dart';
import './screens/splash_screen.dart'; // Akan kita buat
import './screens/login_screen.dart'; // Akan kita buat
import './screens/register_screen.dart'; // Akan kita buat
import './screens/home_screen.dart'; // Akan kita buat

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Menggunakan MultiProvider jika Anda memiliki lebih dari satu provider global
    // Untuk saat ini, kita hanya punya AuthProvider
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(), // Membuat instance AuthProvider
      child: MaterialApp(
        title: 'Flutter Auth App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.pink,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Layar awal akan ditentukan oleh SplashScreen atau logika di bawah
        home: SplashScreen(), // Kita mulai dengan SplashScreen
        // Anda bisa juga menggunakan Consumer<AuthProvider> di sini untuk logika awal
        // home: Consumer<AuthProvider>(
        //   builder: (ctx, auth, _) => auth.isAuthenticated
        //       ? HomeScreen()
        //       : FutureBuilder(
        //           future: auth.tryAutoLogin(),
        //           builder: (ctx, authResultSnapshot) =>
        //               authResultSnapshot.connectionState ==
        //                       ConnectionState.waiting
        //                   ? SplashScreen() // Tampilkan splash screen selama tryAutoLogin
        //                   : auth.isAuthenticated ? HomeScreen() : LoginScreen(),
        //         ),
        // ),
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
          RegisterScreen.routeName: (ctx) => RegisterScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          SplashScreen.routeName: (ctx) => SplashScreen(),
          // Tambahkan rute lain jika ada
        },
      ),
    );
  }
}
