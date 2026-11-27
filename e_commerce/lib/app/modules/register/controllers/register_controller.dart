import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/modules/login/controllers/login_controller.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.toggle();

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != passwordController.text) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    return null;
  }

  Future<void> register() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final registeredEmail = emailController.text.trim();

      // 1. Daftarkan akun baru ke server Firebase Auth
      if (Get.isRegistered<AuthService>()) {
        await AuthService.to.register(registeredEmail, passwordController.text);
      }

      // 2. Periksa apakah pendaftaran dipicu dari rute yang dicegat (misal: /checkout)
      String? returnRoute;
      if (Get.isRegistered<AuthService>()) {
        returnRoute = AuthService.to.redirectRoute;
        AuthService.to.redirectRoute = null;
      }

      if (returnRoute != null && returnRoute.isNotEmpty) {
        // KASUS 1: Datang dari Checkout → tetap login & langsung buka /checkout
        Get.until(
          (route) =>
              route.isFirst ||
              (route.settings.name != Routes.LOGIN && route.settings.name != Routes.REGISTER),
        );
        Get.toNamed(returnRoute);
      } else {
        // KASUS 2: Pendaftaran biasa → logout sementara & kembali ke Login dengan email terisi
        if (Get.isRegistered<AuthService>()) {
          await AuthService.to.logout();
        }
        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().emailController.text = registeredEmail;
        }
        Get.back();
      }

      Get.snackbar(
        'Pendaftaran Berhasil 🎉',
        returnRoute != null
            ? 'Akunmu berhasil dibuat. Silakan lanjutkan pembayaran.'
            : 'Akunmu berhasil didaftarkan. Silakan masuk menggunakan email dan password baru.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Mendaftar',
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
