import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service penyimpanan lokal yang hidup selama aplikasi berjalan.
class StorageService extends GetxService {
  static const _themeKey = 'is_dark_mode';

  late SharedPreferences _prefs;
  final _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get themeMode => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<StorageService> init({bool initHive = true}) async {
    // 1. Muat preferensi primitif melalui SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = _prefs.getBool(_themeKey) ?? false;

    // 2. Siapkan Hive CE, box-nya baru dipakai di Sesi 07
    if (initHive) {
      await Hive.initFlutter();
    }

    return this;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _prefs.setBool(_themeKey, _isDarkMode.value);

    Get.changeThemeMode(themeMode);

    final isDark = _isDarkMode.value;
    Get.snackbar(
      isDark ? 'Mode Gelap Diaktifkan' : 'Mode Terang Diaktifkan',
      isDark
          ? 'Tampilan hemat daya dan nyaman untuk mata telah aktif.'
          : 'Tampilan cerah bersemangat telah aktif.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF4F46E5),
      colorText: Colors.white,
      icon: Icon(
        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: isDark ? Colors.amber : Colors.white,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
