// lib/services/auth_service.dart
import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constanst.dart'; // Impor konstanta URL dasar kita

class AuthService {
  // Fungsi untuk Registrasi
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/register');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 && responseData['success'] == true) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (error) {
      // Tangani error jaringan atau lainnya
      print('Error di AuthService.register: $error');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${error.toString()}',
      };
    }
  }

  // Fungsi untuk Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/login');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Simpan token dan data pengguna jika login berhasil
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setString('userRole', responseData['user']['role']);
        await prefs.setInt('userId', responseData['user']['id']);
        await prefs.setString('username', responseData['user']['username']);
        await prefs.setString(
          'userEmail',
          responseData['user']['email'],
        ); // Simpan juga email

        return {
          'success': true,
          'message': responseData['message'],
          'token': responseData['token'],
          'user': responseData['user'], // Mengembalikan data pengguna
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
        };
      }
    } catch (error) {
      print('Error di AuthService.login: $error');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${error.toString()}',
      };
    }
  }

  // Fungsi untuk Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('userEmail');
    // Anda juga bisa memanggil API logout di backend jika ada
  }

  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk mendapatkan peran pengguna
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  // Fungsi untuk mendapatkan data pengguna yang disimpan
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) return null; // Tidak ada pengguna yang login

    return {
      'id': prefs.getInt('userId'),
      'username': prefs.getString('username'),
      'email': prefs.getString('userEmail'),
      'role': prefs.getString('userRole'),
    };
  }
}
