import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/modules/home/controllers/home_controller.dart';

class WishlistController extends GetxController {
  final ProductRepository _productRepository;

  WishlistController([ProductRepository? productRepository])
    : _productRepository = productRepository ?? Get.find<ProductRepository>();

  final RxList<ProductModel> wishlist = <ProductModel>[].obs;

  HomeController get homeController => Get.find<HomeController>();

  CartController get cartController => Get.find<CartController>();

  List<ProductModel> get wishlistItems => wishlist;

  int get totalCount => wishlist.length;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  void loadWishlist() {
    wishlist.assignAll(_productRepository.getWishlist());
  }

  Future<void> removeFromWishlist(String productId) async {
    final item = wishlist.firstWhereOrNull((e) => e.id == productId);
    if (item == null) return;

    await _productRepository.toggleWishlist(item);
    loadWishlist();
    if (Get.isRegistered<HomeController>()) {
      homeController.favoriteIds.remove(productId);
    }
    _notify('Dihapus', '${item.name} dihapus dari wishlist.', AppColors.darkSurfaceCard);
  }

  Future<void> moveToCart(ProductModel product) async {
    await cartController.addItemAsync(product);
    await _productRepository.toggleWishlist(product);
    loadWishlist();
    if (Get.isRegistered<HomeController>()) {
      homeController.favoriteIds.remove(product.id);
    }
    _notify('Keranjang', '${product.name} dipindahkan ke keranjang belanja!', AppColors.success);
  }

  void clearWishlist() {
    Get.defaultDialog(
      title: 'Kosongkan Wishlist?',
      titleStyle: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
      middleText:
          'Apakah Anda yakin ingin menghapus seluruh sepatu favorit dari memori penyimpanan lokal?',
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          await Hive.box<ProductModel>(ProductLocalDataSourceImpl.wishlistBoxName).clear();
          wishlist.clear();
          if (Get.isRegistered<HomeController>()) {
            homeController.favoriteIds.clear();
          }
          Get.back();
          _notify(
            'Wishlist Dikosongkan',
            'Seluruh produk favorit berhasil dihapus dari penyimpanan.',
            AppColors.darkSurfaceCard,
          );
        },
        child: const Text('Hapus Semua'),
      ),
    );
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
