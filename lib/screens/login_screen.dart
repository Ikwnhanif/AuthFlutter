// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_providers.dart';
import './register_screen.dart';
import './home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false; // Untuk toggle lihat password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      // Validasi gagal
      return;
    }
    _formKey.currentState!
        .save(); // Tidak terlalu diperlukan jika menggunakan controller

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      bool isLoggedIn = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (isLoggedIn && mounted) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        // Jika login gagal, errorMessage di AuthProvider akan diset
        // Kita bisa menampilkan SnackBar di sini jika mau, atau biarkan UI (Text widget) menampilkannya
        if (mounted && authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // Tangani error yang mungkin tidak ditangkap oleh AuthProvider
      // (seharusnya sudah ditangani di AuthProvider dan AuthService)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan yang tidak diketahui. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Error di _submitLogin: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil status isLoading dari AuthProvider
    // Kita menggunakan context.watch agar widget ini rebuild saat isLoading berubah
    final isLoading = context.watch<AuthProvider>().isLoading;
    final errorMessageFromProvider = context.watch<AuthProvider>().errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Pengguna'),
        automaticallyImplyLeading: false, // Menyembunyikan tombol back
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Selamat Datang!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Silakan login untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Masukkan format email yang valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan password Anda',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    // Anda bisa menambahkan validasi panjang password di sini jika mau
                    // if (value.length < 6) {
                    //   return 'Password minimal 6 karakter';
                    // }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Menampilkan error message dari provider jika ada dan tidak sedang loading
                // Ini adalah alternatif dari SnackBar
                if (errorMessageFromProvider != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      errorMessageFromProvider,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : _submitLogin, // Disable tombol saat loading
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Login'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Belum punya akun?'),
                    TextButton(
                      child: Text(
                        'Daftar di sini',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pushNamed(RegisterScreen.routeName);
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
