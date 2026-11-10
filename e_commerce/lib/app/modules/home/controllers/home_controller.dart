import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final selectedCategory = 'Semua'.obs;
  final favoriteIds = <String>{}.obs;

  final categories = const ['Semua', 'Lifestyle', 'Running', 'Basketball', 'Skate', 'Casual'];

  static const _catalog = <Map<String, dynamic>>[
    {
      'id': 'shoe-01',
      'name': 'Nike Air Jordan 1 Retro High',
      'category': 'Basketball',
      'price': 2499000,
      'rating': 4.9,
      'imageUrl': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=500&q=80',
      'description': 'Siluet basket ikonik berbahan kulit premium dengan bantalan Air untuk kenyamanan sepanjang hari.',
    },
    {
      'id': 'shoe-02',
      'name': 'Nike Air Force 1 07 Triple White',
      'category': 'Lifestyle',
      'price': 1549000,
      'rating': 4.8,
      'imageUrl': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500&q=80',
      'description': 'Sneakers kulit serba putih dengan sol tebal yang mudah dipadukan untuk gaya harian.',
    },
    {
      'id': 'shoe-03',
      'name': 'Adidas Ultraboost Light Running',
      'category': 'Running',
      'price': 2899000,
      'rating': 4.7,
      'imageUrl': 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=500&q=80',
      'description': 'Sepatu lari ringan dengan bantalan responsif dan upper rajut yang sirkulasi udaranya baik.',
    },
    {
      'id': 'shoe-04',
      'name': 'Puma Suede Classic XXI Black',
      'category': 'Casual',
      'price': 1099000,
      'rating': 4.6,
      'imageUrl': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=500&q=80',
      'description': 'Sepatu suede klasik dengan sol karet antiselip untuk aktivitas santai.',
    },
    {
      'id': 'shoe-05',
      'name': 'New Balance 574 Core Grey',
      'category': 'Lifestyle',
      'price': 1499000,
      'rating': 4.8,
      'imageUrl': 'https://images.unsplash.com/photo-1539185441755-769473a23570?w=500&q=80',
      'description': 'Perpaduan suede dan mesh dengan bantalan empuk untuk dipakai sepanjang hari.',
    },
    {
      'id': 'shoe-06',
      'name': 'Vans Old Skool Classic Skate',
      'category': 'Skate',
      'price': 999000,
      'rating': 4.7,
      'imageUrl': 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=500&q=80',
      'description': 'Sepatu skate kanvas dan suede dengan sol waffle yang mencengkeram kuat.',
    },
  ];

  final List<ProductModel> products = _catalog.map(ProductModel.fromMap).toList();

  CartController get cartController {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController());
  }

  int get cartCount => cartController.totalItemCount;

  List<ProductModel> get filteredProducts {
    final category = selectedCategory.value;
    if (category == 'Semua') return products;
    return products.where((product) => product.category == category).toList();
  }

  void changeCategory(String category) => selectedCategory.value = category;

  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (!favoriteIds.remove(id)) favoriteIds.add(id);
  }

  void addToCart(ProductModel product) {
    cartController.addItem(product);
    Get.snackbar(
      'Ditambahkan',
      '${product.name} ditambahkan ke keranjang!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void openDetail(ProductModel product) {
    Get.toNamed(Routes.DETAIL, arguments: product);
  }
}
