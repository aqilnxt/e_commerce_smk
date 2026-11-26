import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Status login global dan rute tujuan setelah login (misal /checkout).
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserEmail = 'auth_user_email';

  late final SharedPreferences _prefs;

  final isLoggedIn = false.obs;
  final currentUserEmail = ''.obs;

  // Rute yang dicegat AuthMiddleware, dibuka lagi setelah login berhasil
  String? redirectRoute;

  Future<AuthService> init({SharedPreferences? prefs}) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
    isLoggedIn.value = _prefs.getBool(_keyIsLoggedIn) ?? false;
    currentUserEmail.value = _prefs.getString(_keyUserEmail) ?? '';
    return this;
  }

  // shortcut: sesi lokal tanpa verifikasi server, diganti Firebase Auth di Sesi 09
  Future<void> login(String email) async {
    isLoggedIn.value = true;
    currentUserEmail.value = email.trim();
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserEmail, currentUserEmail.value);
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    currentUserEmail.value = '';
    redirectRoute = null;
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserEmail);
  }
}
