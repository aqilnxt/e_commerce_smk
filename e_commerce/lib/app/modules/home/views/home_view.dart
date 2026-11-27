import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/local/storage_service.dart';
import 'package:e_commerce/app/modules/cart/views/components/cart_badge_button.dart';
import 'package:e_commerce/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'components/product_card.dart';
import 'components/promo_banner.dart';
import '../widgets/product_card_shimmer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                children: const [
                  TextSpan(text: 'Kicks'),
                  TextSpan(
                    text: 'Store',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Saklar Dark / Light Mode
          IconButton(
            tooltip: 'Ganti Tema',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.accent : AppColors.lightTextPrimary,
            ),
            onPressed: () {
              if (Get.isRegistered<StorageService>()) {
                Get.find<StorageService>().toggleTheme();
              } else {
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              }
            },
          ),

          // Navigasi ke Keranjang Belanja dengan Badge
          const CartBadgeButton(),

          // Avatar akun: lembar profil jika sudah login, halaman login jika belum
          Obx(() {
            final loggedIn = _isLoggedIn;
            return IconButton(
              tooltip: loggedIn ? 'Akun Saya' : 'Masuk Akun',
              onPressed: () => _openAccount(context),
              icon: loggedIn
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        AuthService.to.displayName.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const Icon(Icons.account_circle_outlined),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        onTap: (index) {
          if (index == 1) Get.toNamed(Routes.WISHLIST);
          if (index == 2) Get.toNamed(Routes.ORDERS);
          if (index == 3) _openAccount(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Akun'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan pengguna, reaktif terhadap authStateChanges()
              Obx(
                () => Text(
                  _isLoggedIn ? 'Halo, ${AuthService.to.displayName}! 👋' : 'Halo, Tamu! 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Temukan sneakers terbaik untuk langkahmu hari ini.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar Input
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari sneakers favoritmu...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Banner Promosi Toko
              const PromoBanner(),
              const SizedBox(height: 20),

              // Filter Kategori Horizontal
              SizedBox(
                height: 40,
                child: Obx(() {
                  // Dibaca di sini karena itemBuilder berjalan di luar scope Obx
                  final selected = controller.selectedCategory.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final isSelected = category == selected;
                      return ChoiceChip(
                        // Lebar chip tidak dihitung ulang setelah font Inter selesai diunduh
                        label: Text(category, overflow: TextOverflow.visible),
                        selected: isSelected,
                        showCheckmark: false,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const StadiumBorder(),
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                        ),
                        onSelected: (_) => controller.changeCategory(category),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Judul Bagian Katalog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Katalog Sneakers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${controller.filteredProducts.length} Produk',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // GridView Produk Katalog
              Obx(() {
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return const ProductGridShimmer(itemCount: 4);
                }

                if (controller.errorMessage.value.isNotEmpty && controller.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.error),
                          const SizedBox(height: 12),
                          const Text(
                            'Gagal Memuat Produk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(controller.errorMessage.value, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: controller.fetchProducts,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = controller.filteredProducts;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return Obx(
                      () => ProductCard(
                        title: product.name,
                        category: product.category,
                        price: product.formattedPrice,
                        rating: product.rating,
                        imageUrl: product.imageUrl,
                        isFavorite: controller.isFavorite(product.id),
                        onTap: () => controller.openDetail(product),
                        onAddToCart: () => controller.addToCart(product),
                        onToggleFavorite: () => controller.toggleFavorite(product.id),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isLoggedIn => Get.isRegistered<AuthService>() && AuthService.to.isLoggedIn.value;

  void _openAccount(BuildContext context) {
    if (_isLoggedIn) {
      _showAccountBottomSheet(context);
    } else {
      Get.toNamed(Routes.LOGIN);
    }
  }

  void _showAccountBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = AuthService.to;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      auth.displayName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.currentUserEmail.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: secondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, size: 14, color: AppColors.success),
                              SizedBox(width: 4),
                              Text(
                                'Terautentikasi Firebase',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Riwayat Pesanan'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.ORDERS);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.favorite_border_rounded),
                title: const Text('Wishlist Favorit'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.WISHLIST);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(0, 48),
                ),
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari Akun'),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Keluar dari Akun?',
      middleText: 'Kamu perlu login lagi untuk checkout dan melihat pesanan.',
      textCancel: 'Batal',
      textConfirm: 'Ya, Keluar',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.error,
      onConfirm: () async {
        Get.back(); // tutup dialog
        Get.back(); // tutup bottom sheet
        await AuthService.to.logout();
        Get.snackbar(
          'Berhasil Keluar',
          'Sampai jumpa lagi di KicksStore!',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      },
    );
  }
}
