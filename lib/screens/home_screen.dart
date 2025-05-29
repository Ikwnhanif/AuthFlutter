// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_providers.dart';
import './login_screen.dart'; // Untuk navigasi saat logout

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    // Mengambil data pengguna dari AuthProvider
    // Menggunakan watch agar UI update jika data pengguna berubah (meskipun jarang terjadi setelah login)
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda'),
        automaticallyImplyLeading: false, // Menyembunyikan tombol back
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Panggil fungsi logout dari AuthProvider
              // Gunakan listen: false karena kita berada dalam callback onPressed
              await Provider.of<AuthProvider>(context, listen: false).logout();

              // Setelah logout, arahkan kembali ke LoginScreen
              // dan hapus semua rute sebelumnya dari stack
              if (context.mounted) {
                // Pastikan widget masih ada di tree
                Navigator.of(
                  context,
                ).pushReplacementNamed(LoginScreen.routeName);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 20),
              if (authProvider.isAuthenticated && authProvider.username != null)
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Agar card menyesuaikan konten
                      children: [
                        Text(
                          'Anda login sebagai:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Username: ${authProvider.username}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Email: ${authProvider.userEmail ?? "Tidak ada email"}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Role: ${authProvider.userRole ?? "Tidak ada peran"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 15),
                        // Contoh menampilkan konten berdasarkan peran
                        if (authProvider.userRole == 'admin')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              'Anda memiliki akses sebagai Admin!',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  'Silakan login untuk melihat konten.',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 30),
              // Anda bisa menambahkan lebih banyak konten atau tombol di sini
              // ElevatedButton(
              //   onPressed: () {
              //     // Aksi lain
              //   },
              //   child: Text('Fitur Khusus'),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
