import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Tombol keranjang AppBar dengan badge jumlah item dari CartController
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: 'Keranjang Belanja',
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () => Get.toNamed(Routes.CART),
        ),
        Obx(() {
          final count = cart.totalItemCount;
          if (count == 0) return const SizedBox.shrink();
          return Positioned(
            right: 8,
            top: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
