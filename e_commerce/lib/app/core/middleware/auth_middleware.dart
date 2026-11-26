import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Mencegah pengguna yang belum login membuka rute sensitif seperti /checkout.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn.value) {
      // 1. Catat rute asal agar user bisa kembali setelah login
      AuthService.to.redirectRoute = route;

      // 2. Beri notifikasi edukatif kepada pengguna
      // Ditunda satu frame: snackbar yang dibuat di tengah perpindahan rute tidak tampil
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.snackbar(
          'Akses Dibatasi',
          'Silakan masuk akun terlebih dahulu untuk melanjutkan proses pemesanan.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          icon: const Icon(Icons.lock_outline_rounded, color: Colors.orangeAccent),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        ),
      );

      // 3. Alihkan rute ke halaman login
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
