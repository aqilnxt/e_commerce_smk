import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

class CourierOption {
  final String name;
  final String estimatedTime;
  final int cost;

  const CourierOption({required this.name, required this.estimatedTime, required this.cost});
}

class CheckoutController extends GetxController {
  static const _validCoupons = {'SMKBISA', 'KICKS10'};

  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController notesController;
  late final TextEditingController couponController;

  final selectedCourierIndex = 0.obs;
  final selectedPaymentMethod = 0.obs;
  final isLoading = false.obs;

  // Tantangan Sesi 08: kupon promo
  final discountAmount = 0.obs;
  final appliedCouponCode = ''.obs;

  final List<CourierOption> courierOptions = const [
    CourierOption(name: 'JNE Reguler', estimatedTime: '2-3 hari kerja', cost: 25000),
    CourierOption(name: 'SiCepat BEST', estimatedTime: '1-2 hari kerja', cost: 22000),
    CourierOption(
      name: 'GoSend Instant',
      estimatedTime: 'Tiba hari ini (Instant 3-4 jam)',
      cost: 35000,
    ),
  ];

  CartController get cart => Get.find<CartController>();

  int get itemCount => cart.totalItemCount;
  int get subtotal => cart.subtotal;
  int get tax => cart.tax;
  int get courierFee => cart.items.isEmpty ? 0 : courierOptions[selectedCourierIndex.value].cost;
  int get promoDiscount => discountAmount.value;
  int get grandTotal {
    final total = subtotal + tax + courierFee - promoDiscount;
    return total < 0 ? 0 : total;
  }

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    notesController = TextEditingController();
    couponController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
    couponController.dispose();
    super.onClose();
  }

  void selectCourier(int index) => selectedCourierIndex.value = index;

  void selectPaymentMethod(int index) => selectedPaymentMethod.value = index;

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama penerima wajib diisi';
    if (value.trim().length < 3) return 'Nama penerima minimal 3 karakter';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor WhatsApp wajib diisi';
    final phone = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,11}$').hasMatch(phone)) {
      return 'Nomor WhatsApp tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Alamat lengkap wajib diisi';
    if (value.trim().length < 15) return 'Alamat terlalu singkat, sertakan jalan, RT/RW, dan kota';
    return null;
  }

  void applyCoupon(String couponCode) {
    final code = couponCode.trim().toUpperCase();
    if (_validCoupons.contains(code)) {
      discountAmount.value = 25000;
      appliedCouponCode.value = code;
      Get.snackbar(
        'Kupon Berhasil Dipasang! 🎉',
        'Hemat Rp 25.000 untuk pesanan sneakers impianmu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Kupon Tidak Valid',
        'Kode kupon promo tidak ditemukan atau telah kedaluwarsa.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> placeOrder() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) return;
    if (cart.items.isEmpty) {
      Get.snackbar(
        'Keranjang Kosong',
        'Tambahkan sepatu ke keranjang sebelum membuat pesanan.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    // Simulasi proses pembayaran, pesanan disimpan ke Firestore di Sesi 10
    await Future.delayed(const Duration(milliseconds: 1200));
    await cart.clearCartAsync();
    isLoading.value = false;

    Get.defaultDialog(
      title: 'Pesanan Berhasil! 🎉',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: 'Terima kasih! Pesanan sneakers impianmu sedang diproses.',
      textConfirm: 'Lihat Riwayat Pesanan',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      barrierDismissible: false,
      onConfirm: () {
        Get.back();
        Get.offAllNamed(Routes.ORDERS);
      },
    );
  }
}
