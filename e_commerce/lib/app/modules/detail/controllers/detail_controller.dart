import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/modules/home/controllers/home_controller.dart';

class DetailController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();

  CartController get cartController {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController());
  }

  final product = Rx<ProductModel?>(null);

  final sizes = const ['39', '40', '41', '42', '43', '44'];
  final selectedSize = '42'.obs;
  final quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    product.value = Get.arguments as ProductModel? ?? homeController.products.first;
  }

  bool get isFavorite =>
      product.value != null && homeController.isFavorite(product.value!.id);

  void incrementQuantity() => quantity.value++;

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  void toggleFavorite() {
    final product = this.product.value;
    if (product == null) return;
    homeController.toggleFavorite(product.id);
    Get.snackbar(
      isFavorite ? 'Wishlist Ditambahkan' : 'Wishlist Dihapus',
      isFavorite ? '${product.name} disimpan ke favorit!' : '${product.name} dihapus dari favorit.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isFavorite ? AppColors.accent : AppColors.darkSurfaceCard,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void addToCart() {
    final product = this.product.value;
    if (product == null) return;
    cartController.addItem(
      product,
      quantity: quantity.value,
      size: selectedSize.value,
    );
    Get.snackbar(
      'Berhasil Ditambahkan',
      '${quantity.value} item ${product.name} (Size ${selectedSize.value}) masuk ke keranjang!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
