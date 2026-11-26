import 'package:hive_ce/hive.dart';

import 'package:e_commerce/app/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  List<CartItemModel> getCartItems();
  Future<void> saveCartItem(CartItemModel item);
  Future<void> removeCartItem(String cartItemId);
  Future<void> clearCart();
}

/// Akses box Hive CE 'cart_box' agar isi keranjang bertahan setelah aplikasi ditutup.
class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String cartBoxName = 'cart_box';

  Box<CartItemModel> get _cartBox => Hive.box<CartItemModel>(cartBoxName);

  @override
  List<CartItemModel> getCartItems() => _cartBox.values.toList();

  @override
  Future<void> saveCartItem(CartItemModel item) async {
    await _cartBox.put(item.id, item);
  }

  @override
  Future<void> removeCartItem(String cartItemId) async {
    await _cartBox.delete(cartItemId);
  }

  @override
  Future<void> clearCart() async {
    await _cartBox.clear();
  }
}
