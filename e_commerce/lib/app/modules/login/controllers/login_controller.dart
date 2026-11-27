import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Pengguna yang sudah login tidak perlu melihat formulir login lagi
    if (Get.isRegistered<AuthService>() && AuthService.to.isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.HOME);
      });
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat email wajib diisi';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid (contoh: nama@sekolah.sch.id)';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Kata sandi harus mengandung minimal 1 angka (0-9)';
    }
    return null;
  }

  Future<void> login() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      if (Get.isRegistered<AuthService>()) {
        await AuthService.to.login(emailController.text.trim(), passwordController.text);
      }

      Get.snackbar(
        'Berhasil Masuk 🎉',
        'Selamat datang kembali di KicksStore!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Kembali ke rute yang dicegat AuthMiddleware (misal /checkout) jika ada
      String? returnRoute;
      if (Get.isRegistered<AuthService>()) {
        returnRoute = AuthService.to.redirectRoute;
        AuthService.to.redirectRoute = null;
      }

      if (returnRoute != null && returnRoute.isNotEmpty) {
        Get.offNamed(returnRoute);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Masuk',
        AuthService.mapFirebaseAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
