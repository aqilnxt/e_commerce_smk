import 'package:get/get.dart';

import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import 'package:e_commerce/app/data/models/cart_item_model.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

class CartController extends GetxController {
  static const taxRate = 0.11;
  static const freeShippingThreshold = 2000000;
  static const flatShippingFee = 25000;

  final CartLocalDataSource? _localDataSource;

  CartController({CartLocalDataSource? localDataSource}) : _localDataSource = localDataSource;

  final items = <CartItemModel>[].obs;

  CartLocalDataSource? get _dataSource =>
      _localDataSource ??
      (Get.isRegistered<CartLocalDataSource>() ? Get.find<CartLocalDataSource>() : null);

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  int get tax => (subtotal * taxRate).round();

  int get shippingFee => items.isEmpty || subtotal >= freeShippingThreshold ? 0 : flatShippingFee;

  int get totalAmount => subtotal + tax + shippingFee;

  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
  }

  void _loadCartFromStorage() {
    final savedItems = _dataSource?.getCartItems() ?? [];
    if (savedItems.isNotEmpty) {
      items.assignAll(savedItems);
    }
  }

  Future<void> addItemAsync(ProductModel product, {int quantity = 1, String size = '42'}) async {
    final newItem = CartItemModel(product: product, selectedSize: size, quantity: quantity);
    final existing = items.firstWhereOrNull((item) => item.id == newItem.id);

    if (existing == null) {
      items.add(newItem);
      await _dataSource?.saveCartItem(newItem);
    } else {
      existing.quantity += quantity;
      items.refresh();
      await _dataSource?.saveCartItem(existing);
    }
  }

  Future<void> increaseQuantity(String id) async {
    final item = items.firstWhereOrNull((item) => item.id == id);
    if (item == null) return;
    item.quantity++;
    items.refresh();
    await _dataSource?.saveCartItem(item);
  }

  Future<void> decreaseQuantity(String id) async {
    final item = items.firstWhereOrNull((item) => item.id == id);
    if (item == null) return;
    if (item.quantity <= 1) {
      await removeItem(id);
      return;
    }
    item.quantity--;
    items.refresh();
    await _dataSource?.saveCartItem(item);
  }

  Future<void> removeItem(String id) async {
    items.removeWhere((item) => item.id == id);
    await _dataSource?.removeCartItem(id);
  }

  Future<void> clearCartAsync() async {
    items.clear();
    await _dataSource?.clearCart();
  }
}
