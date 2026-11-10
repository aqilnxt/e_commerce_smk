import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/modules/home/controllers/home_controller.dart';

class WishlistController extends GetxController {
  HomeController get homeController => Get.find<HomeController>();

  CartController get cartController => Get.find<CartController>();

  List<ProductModel> get wishlistItems =>
      homeController.products.where((product) => homeController.isFavorite(product.id)).toList();

  void removeFromWishlist(ProductModel product) {
    homeController.toggleFavorite(product.id);
    _notify('Dihapus', '${product.name} dihapus dari wishlist.', AppColors.darkSurfaceCard);
  }

  void moveToCart(ProductModel product) {
    cartController.addItem(product);
    homeController.toggleFavorite(product.id);
    _notify('Keranjang', '${product.name} dipindahkan ke keranjang belanja!', AppColors.success);
  }

  void _notify(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
