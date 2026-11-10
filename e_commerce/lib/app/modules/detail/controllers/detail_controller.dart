import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/modules/home/controllers/home_controller.dart';

class DetailController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();

  late final Map<String, dynamic> product;

  final sizes = const ['39', '40', '41', '42', '43', '44'];
  final selectedSize = '42'.obs;
  final quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as Map<String, dynamic>? ?? homeController.products.first;
  }

  String get formattedPrice => homeController.currencyFormatter.format(product['price']);

  bool get isFavorite => homeController.isFavorite(product['id'] as String);

  void incrementQuantity() => quantity.value++;

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  void toggleFavorite() {
    homeController.toggleFavorite(product['id'] as String);
    Get.snackbar(
      isFavorite ? 'Wishlist Ditambahkan' : 'Wishlist Dihapus',
      isFavorite
          ? '${product['name']} disimpan ke favorit!'
          : '${product['name']} dihapus dari favorit.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isFavorite ? AppColors.accent : AppColors.darkSurfaceCard,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void addToCart() => homeController.addToCart(product, quantity: quantity.value);
}
