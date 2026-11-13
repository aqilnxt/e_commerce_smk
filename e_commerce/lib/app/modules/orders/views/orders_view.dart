import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/routes/app_pages.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTab = 0.obs;

    final filterTabs = ['Semua', 'Diproses', 'Dikirim', 'Selesai'];

    // Data mockup riwayat pesanan (persiapan Cloud Firestore)
    final mockOrders = [
      {
        'id': 'ORD-20261020-001',
        'date': '20 Okt 2026, 10:30 WIB',
        'status': 'Diproses',
        'statusColor': AppColors.warning,
        'title': 'Nike Air Jordan 1 Retro High',
        'size': 42,
        'qty': 1,
        'total': 'Rp 2.499.000',
        'image': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=500&q=80',
      },
      {
        'id': 'ORD-20261018-088',
        'date': '18 Okt 2026, 14:20 WIB',
        'status': 'Dikirim',
        'statusColor': AppColors.primary,
        'title': 'Puma Suede Classic XXI Black',
        'size': 40,
        'qty': 1,
        'total': 'Rp 1.099.000',
        'image': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=500&q=80',
      },
      {
        'id': 'ORD-20261014-042',
        'date': '14 Okt 2026, 09:15 WIB',
        'status': 'Selesai',
        'statusColor': AppColors.success,
        'title': 'Adidas Ultraboost Light Running',
        'size': 41,
        'qty': 1,
        'total': 'Rp 2.899.000',
        'image': 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=500&q=80',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.offAllNamed(Routes.HOME),
        ),
        title: const Text('Riwayat Pesanan'),
        actions: [
          IconButton(
            tooltip: 'Masuk Akun',
            icon: const Icon(Icons.login_rounded),
            onPressed: () => Get.toNamed(Routes.LOGIN),
          ),
          IconButton(
            tooltip: 'Belanja Lagi',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => Get.offAllNamed(Routes.HOME),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Status Pesanan (Horizontal Chips)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filterTabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Obx(() {
                  final isSelected = selectedTab.value == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => selectedTab.value = index,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filterTabs[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Kartu Invoice Pesanan
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = mockOrders[index];
                final statusColor = order['statusColor'] as Color;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Kartu: No Invoice & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                order['id'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order['status'] as String,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const Divider(height: 20),

                      // Item Ringkasan
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 64,
                              height: 64,
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              child: Image.network(
                                order['image'] as String,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['title'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Size ${order['size']} • ${order['qty']} Barang',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Footer Kartu: Total Bayar & Aksi Tombol
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Belanja',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              Text(
                                order['total'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                'Lacak Pesanan',
                                'Pesanan ${order['id']} sedang dalam status ${order['status']}.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primary,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            },
                            child: const Text('Lacak Pesanan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
