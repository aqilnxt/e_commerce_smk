import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final String selectedSize;
  final int quantity;

  const CartItemModel({
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });

  String get id => '${product.id}_$selectedSize';

  int get subtotal => product.price * quantity;

  String get formattedSubtotal => formatRupiah(subtotal);

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        product: product,
        selectedSize: selectedSize,
        quantity: quantity ?? this.quantity,
      );

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        product: ProductModel.fromMap(Map<String, dynamic>.from(map['product'] as Map)),
        selectedSize: map['selectedSize'] as String,
        quantity: (map['quantity'] as num).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'product': product.toMap(),
        'selectedSize': selectedSize,
        'quantity': quantity,
      };
}
