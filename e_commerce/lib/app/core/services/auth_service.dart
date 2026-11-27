import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Status login global (Firebase Auth) dan rute tujuan setelah login (misal /checkout).
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserEmail = 'auth_user_email';

  late final SharedPreferences _prefs;

  // Null saat Firebase belum diinisialisasi (misal di widget test)
  FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;

  final isLoggedIn = false.obs;
  final currentUserEmail = ''.obs;
  final currentUserId = ''.obs;

  // Rute yang dicegat AuthMiddleware, dibuka lagi setelah login berhasil
  String? redirectRoute;

  /// Nama sapaan dari bagian depan email, contoh siswa.smk@gmail.com → siswa.smk
  String get displayName => currentUserEmail.value.split('@').first;

  Future<AuthService> init({SharedPreferences? prefs, FirebaseAuth? auth}) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
    _auth = auth ?? (Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null);

    if (_auth == null) {
      isLoggedIn.value = _prefs.getBool(_keyIsLoggedIn) ?? false;
      currentUserEmail.value = _prefs.getString(_keyUserEmail) ?? '';
      return this;
    }

    _applyUser(_auth!.currentUser);
    // Sumber kebenaran sesi: login, register, logout, dan token kedaluwarsa
    _authSubscription = _auth!.authStateChanges().listen(_applyUser);
    return this;
  }

  void _applyUser(User? user) {
    isLoggedIn.value = user != null;
    currentUserEmail.value = user?.email ?? '';
    currentUserId.value = user?.uid ?? '';
  }

  // TUJUAN: Mendaftarkan akun pembeli baru ke Cloud Firebase Authentication
  Future<void> register(String email, String password) async {
    if (_auth != null) {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _applyUser(credential.user);
    } else {
      isLoggedIn.value = true;
      currentUserEmail.value = email.trim();
    }
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserEmail, currentUserEmail.value);
  }

  // TUJUAN: Masuk ke akun terdaftar dengan validasi sandi di server Firebase
  Future<void> login(String email, String password) async {
    if (_auth != null) {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _applyUser(credential.user);
    } else {
      isLoggedIn.value = true;
      currentUserEmail.value = email.trim();
    }
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserEmail, currentUserEmail.value);
  }

  // TUJUAN: Mengakhiri sesi login pengguna dan membersihkan tiket akses di memori
  Future<void> logout() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    _applyUser(null);
    redirectRoute = null;
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserEmail);
  }

  /// Menerjemahkan kode error Firebase Auth ke pesan Bahasa Indonesia.
  static String mapFirebaseAuthError(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
    }
    switch (error.code) {
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan oleh admin.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Tunggu beberapa saat lalu coba lagi.';
      case 'operation-not-allowed':
        return 'Metode login Email/Password belum diaktifkan di Firebase Console.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringanmu.';
      default:
        return error.message ?? 'Autentikasi gagal (${error.code}).';
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
