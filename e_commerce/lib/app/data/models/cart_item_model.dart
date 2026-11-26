import 'package:hive_ce/hive.dart';

import 'product_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 1)
class CartItemModel {
  // Kombinasi id produk dan ukuran, misal: 'shoe-01_42'
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ProductModel product;

  @HiveField(2)
  final String selectedSize;

  // Tidak final karena berubah saat tombol (+) atau (-) ditekan
  @HiveField(3)
  int quantity;

  CartItemModel({String? id, required this.product, required this.selectedSize, this.quantity = 1})
    : id = id ?? '${product.id}_$selectedSize';

  int get subtotal => product.price * quantity;

  String get formattedSubtotal => formatRupiah(subtotal);

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
    id: map['id'] as String?,
    product: ProductModel.fromMap(Map<String, dynamic>.from(map['product'] as Map)),
    selectedSize: map['selectedSize'] as String,
    quantity: (map['quantity'] as num).toInt(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'product': product.toMap(),
    'selectedSize': selectedSize,
    'quantity': quantity,
  };
}
