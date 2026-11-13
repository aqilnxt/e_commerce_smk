import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';

/// Kerangka kartu produk berkilau selama katalog dimuat.
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    // Materi menulis grey[750], shade itu tidak ada di Flutter
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    Widget bar({double? width, required double height}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: Container(color: baseColor)),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(width: 60, height: 10),
                    const SizedBox(height: 8),
                    bar(width: double.infinity, height: 12),
                    const SizedBox(height: 6),
                    bar(width: 90, height: 12),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        bar(width: 70, height: 14),
                        bar(width: 28, height: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid 2 kolom berisi kartu shimmer, ukurannya sama dengan grid katalog asli.
class ProductGridShimmer extends StatelessWidget {
  final int itemCount;

  const ProductGridShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }
}
