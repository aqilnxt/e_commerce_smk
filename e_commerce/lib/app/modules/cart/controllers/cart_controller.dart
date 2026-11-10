import 'package:get/get.dart';

import 'package:e_commerce/app/data/models/cart_item_model.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

class CartController extends GetxController {
  static const taxRate = 0.11;
  static const freeShippingThreshold = 2000000;
  static const flatShippingFee = 25000;

  final items = <CartItemModel>[].obs;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  int get tax => (subtotal * taxRate).round();

  int get shippingFee =>
      items.isEmpty || subtotal >= freeShippingThreshold ? 0 : flatShippingFee;

  int get totalAmount => subtotal + tax + shippingFee;

  void addItem(ProductModel product, {int quantity = 1, String size = '42'}) {
    final item = CartItemModel(product: product, selectedSize: size, quantity: quantity);
    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity + quantity);
    }
  }

  void increaseQuantity(String id) {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
  }

  void decreaseQuantity(String id) {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    }
  }

  void removeItem(String id) => items.removeWhere((item) => item.id == id);

  void clearCart() => items.clear();
}
