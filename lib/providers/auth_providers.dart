// lib/providers/auth_provider.dart
import 'package:flutter/material.dart'; // Untuk ChangeNotifier
import '../services/auth_services.dart'; // Impor AuthService

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  int? _userId;
  String? _username;
  String? _userEmail;
  String? _userRole;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters untuk mengakses state dari luar
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  int? get userId => _userId;
  String? get username => _username;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setter internal untuk loading dan error message
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Memberi tahu UI bahwa ada perubahan state
  }

  void _setError(String? message) {
    _errorMessage = message;
    // Tidak perlu notifyListeners() di sini jika _setLoading juga akan dipanggil
    // atau panggil jika hanya error yang berubah tanpa loading
  }

  // Fungsi untuk Registrasi
  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    _setError(null); // Bersihkan error sebelumnya

    final response = await _authService.register(username, email, password);

    _setLoading(false);
    if (response['success'] == true) {
      // Tidak ada state yang berubah di AuthProvider saat registrasi berhasil
      // karena pengguna belum login, hanya berhasil membuat akun.
      // Mungkin Anda ingin menampilkan pesan sukses dari response['message'] di UI.
      return true;
    } else {
      _setError(response['message']);
      notifyListeners(); // Perlu jika error diset terpisah dari loading
      return false;
    }
  }

  // Fungsi untuk Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    final response = await _authService.login(email, password);

    _setLoading(false);
    if (response['success'] == true && response['token'] != null) {
      _token = response['token'];
      final userData = response['user'];
      if (userData != null) {
        _userId = userData['id'];
        _username = userData['username'];
        _userEmail = userData['email'];
        _userRole = userData['role'];
      }
      _isAuthenticated = true;
      notifyListeners(); // Memberi tahu UI bahwa state otentikasi berubah
      return true;
    } else {
      _setError(response['message']);
      _isAuthenticated = false; // Pastikan status tidak terautentikasi
      notifyListeners();
      return false;
    }
  }

  // Fungsi untuk Logout
  Future<void> logout() async {
    _setLoading(true); // Opsional, bisa juga langsung
    await _authService.logout();
    _token = null;
    _userId = null;
    _username = null;
    _userEmail = null;
    _userRole = null;
    _isAuthenticated = false;
    _setError(null);
    _setLoading(false); // Pastikan ini dipanggil setelah semua state direset
    // notifyListeners() sudah dipanggil oleh _setLoading(false)
  }

  // Fungsi untuk mencoba auto-login saat aplikasi dimulai
  Future<bool> tryAutoLogin() async {
    _setLoading(
      true,
    ); // Memberi tahu UI bahwa proses auto-login sedang berjalan

    final storedToken = await _authService.getToken();
    if (storedToken == null) {
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }

    // Token ada, coba ambil data pengguna yang tersimpan
    final userData = await _authService.getUserData();
    if (userData != null) {
      _token = storedToken;
      _userId = userData['id'];
      _username = userData['username'];
      _userEmail = userData['email'];
      _userRole = userData['role'];
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } else {
      // Jika ada token tapi tidak ada user data (seharusnya tidak terjadi jika disimpan dengan benar)
      // atau jika Anda ingin memvalidasi token ke server di sini (opsional, lebih aman)
      await logout(); // Logout untuk membersihkan state jika tidak konsisten
      _setLoading(false); // logout() sudah memanggil setLoading(false)
      return false;
    }
  }
}
